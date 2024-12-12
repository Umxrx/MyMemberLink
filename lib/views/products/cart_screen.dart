import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mymemberlink/model/cart.dart';
import 'package:mymemberlink/model/product.dart';
import 'package:mymemberlink/model/user.dart';
import 'package:mymemberlink/myconfig.dart';

class CartScreen extends StatefulWidget {
  final User user;
  const CartScreen({super.key, required this.user});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Cart> cartList = [];
  List<Product> productList = [];
  List<int> numList = [];
  final ScrollController _listScrollController = ScrollController(keepScrollOffset: false);
  final df = DateFormat('[dd/MM/yyyy] hh:mm a');
  int numofpage = 1;
  int curpage = 1;
  int numofresult = 0;
  late double screenWidth, screenHeight;
  var color;
  String status = 'LOADING...';

  @override
  void initState() {
    super.initState();
    loadCartData().then((onValue) {setState(() {});});
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), "Cart"),
        backgroundColor: Colors.blue[800],
        elevation: 10.0,
        foregroundColor: Colors.white,
      ),
      body: productList.isEmpty
          ? const Center(
              child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10,),
                  Text(style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2, color: Color.fromARGB(255, 65, 65, 65)), "LOADING..."),
                ],
              )),
            )
          : Column(
              children: [
                const SizedBox(height: 10,),
                Container(
                  alignment: Alignment.center,
                  child: Text(style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]), "Page: $curpage/$numofpage | Result: $numofresult"),
                ),
                Expanded(
                  child: ListView.builder(
                      controller: _listScrollController,
                      itemCount: cartList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            color: getColor(index),
                            elevation: 10,
                            child: ListTile(
                              onLongPress: () {
                                deleteDialog(index);
                              },
                              leading: SizedBox(
                                child: Image.network(
                                  errorBuilder: (context, error, stackTrace) =>
                                      SizedBox(
                                        height: screenHeight / 5,
                                        child: Image.asset(
                                          "assets/icon/error_notfound.png",
                                        ),
                                      ),
                                  width: screenWidth / 5,
                                  height: screenHeight / 6,
                                  fit: BoxFit.cover,
                                  scale: 4,
                                  "${MyConfig.servername}/memberlink/assets/products/${productList[index].productFilename}"),
                              ),
                              minLeadingWidth: screenWidth / 5,
                              minTileHeight: screenHeight / 6,
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productList[index].productName.toString(),
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 2,),
                                  Text(
                                    df.format(DateTime.parse(
                                      productList[index].productDate.toString())),
                                    style: const TextStyle(fontSize: 10, color: Colors.white54),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 2,),
                                ],
                              ),
                              subtitle: Text(
                                productList[index].productDescription.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.justify,
                              ),
                          
                              // leading: const Icon(Icons.article),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      int prodCount = int.parse(cartList[index]
                                          .productQuantity
                                          .toString());
                                      if (prodCount > 1) {
                                        decrementCart(int.parse(cartList[index].productId.toString()));
                                      } else {
                                        deleteDialog(index);
                                      }
                                    },
                                    color: Colors.white,
                                  ),
                                  Text(
                                    cartList[index]
                                        .productQuantity
                                        .toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    color: Colors.white,
                                    onPressed: () {
                                      if (int.parse(productList[index]
                                              .productQuantity
                                              .toString()) >
                                          int.parse(cartList[index]
                                              .productQuantity
                                              .toString())) {
                                        incrementCart(int.parse(cartList[index].productId.toString()));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text("Product out of stock"),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: numofpage,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      //build the list for textbutton with scroll
                      if ((curpage - 1) == index) {
                        //set current page number active
                        color = Colors.blue;
                      } else {
                        color = Colors.black;
                      }
                      return TextButton(
                          onPressed: () {
                            curpage = index + 1;
                            loadCartData().then((onValue) {setState(() {
                            });});
                          },
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(color: color, fontSize: 18),
                          ));
                    },
                  ),
                ),
              ],
            ),
  );
  }

  Future<void> loadCartData() async {
    await http
        .get(Uri.parse("${MyConfig.servername}/memberlink/api/load_cart.php?pageno=$curpage&userid=${widget.user.userId.toString()}"))
        .then((response) {
      log(response.body.toString());
      if (response.statusCode == 200) {
        log(response.body);
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          var result = data['data'];
          cartList.clear();
          productList.clear();
          for (var item in result['cart']) {
            Cart myCart = Cart.fromJson(item);
            cartList.add(myCart);
            for (var prod in result['product']) {
              Product myProduct = Product.fromJson(prod);
              productList.add(myProduct);
            }
          }
          setState(() {
            status = 'LOADING...';
            numofpage = data['numofpage'];
            numofresult = data['numberofresult'];
          });
        } else {
          setState(() {
            cartList.clear();
            productList.clear();
            status = "NO DATA";
          });
        }
      } else {
        status = "ERROR";
        log("Error");
        setState(() {});
      }
    });
  }

  void deleteDialog(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Remove \"${productList[index].productName.toString()}\"",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: getColor(index),
            content: const Text("Confirm remove this product?", style: TextStyle(color: Colors.white70),),
            actions: [
              TextButton(
                  onPressed: () {
                    deleteProduct(index);
                    Navigator.pop(context);
                  },
                  child: const Text("Remove", style: TextStyle(color: Colors.red),)),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel", style: TextStyle(color: Colors.white),))
            ],
          );
        });
    setState(() {
      loadCartData().then((onValue) {setState(() {});});
    });
  }

  void deleteProduct(int index) {
    http.post(
        Uri.parse("${MyConfig.servername}/memberlink/api/remove_product.php"),
        body: {"cartid": cartList[index].cartId.toString()}).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        log(data.toString());
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Product successfully removed"),
            backgroundColor: Colors.green,
          ));
          loadCartData().then((onValue) {setState(() {});}); //reload data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Something went wrong..."),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
    setState(() {
      
    });
  }

  Color? getColor(int index) {
    Color? colorResult;
    if (index == 0) {
      colorResult = Colors.blue;
    }
    else if (index == 1) {
      colorResult = const Color.fromARGB(255, 31, 136, 223);
    }
    else if (index == 2) {
      colorResult = const Color.fromARGB(255, 28, 123, 201);
    }
    else if (index == 3) {
      colorResult = const Color.fromARGB(255, 24, 108, 177);
    }
    else if (index == 4) {
      colorResult = const Color.fromARGB(255, 21, 96, 156);
    }
    else if (index == 5) {
      colorResult = const Color.fromARGB(255, 19, 83, 136);
    }
    else if (index == 6) {
      colorResult = const Color.fromARGB(255, 17, 73, 119);
    }
    else if (index == 7) {
      colorResult = const Color.fromARGB(255, 16, 65, 105);
    }
    else if (index == 8) {
      colorResult = const Color.fromARGB(255, 14, 57, 92);
    }
    else {
      colorResult = const Color.fromARGB(255, 12, 49, 80);
    }
    return colorResult;
  }
  
  void decrementCart(int productId) async {
    await http.post(
      Uri.parse("${MyConfig.servername}/memberlink/api/decrement_cart.php"),
      body: {"userid": widget.user.userId.toString(), "productid": '$productId'})
      .then((response) {
        log('${response.body}');
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text(style: TextStyle(color: Colors.white), 'Item removed successfully'),
              backgroundColor: Colors.green[700],
              duration: const Duration(seconds: 1),
            ));
          }
          else {
            log(response.body);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text(style: TextStyle(color: Colors.white), 'Something went wrong'),
              backgroundColor: Colors.green[700],
              duration: const Duration(seconds: 1),
            ));
          }
        }
      });
    setState(() {
      loadCartData().then((onValue) {setState(() {});});
    });
  }

  void incrementCart(int productId) async {
    await http.post(
      Uri.parse("${MyConfig.servername}/memberlink/api/increment_cart.php"),
      body: {"userid": widget.user.userId.toString(), "productid": '$productId'})
      .then((response) {
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text(style: TextStyle(color: Colors.white), 'Item added successfully'),
              backgroundColor: Colors.green[700],
              duration: const Duration(seconds: 1),
            ));
          }
          else {
            log(response.body);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text(style: TextStyle(color: Colors.white), 'Something went wrong'),
              backgroundColor: Colors.green[700],
              duration: const Duration(seconds: 1),
            ));
          }
        }
      });
    setState(() {
      loadCartData().then((onValue) {setState(() {});});
    });
  }
}
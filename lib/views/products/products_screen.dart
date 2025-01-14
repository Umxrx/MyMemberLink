import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mymemberlink/model/product.dart';
import 'package:mymemberlink/model/user.dart';
import 'package:mymemberlink/myconfig.dart';
import 'package:mymemberlink/shared/mydrawer.dart';
import 'package:mymemberlink/views/products/cart_screen.dart';
import 'package:mymemberlink/views/products/product_details.dart';

class ProductsScreen extends StatefulWidget {
  final User user;
  const ProductsScreen({super.key, required this.user});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> productsList = [];
  late double screenWidth, screenHeight;
  final df = DateFormat('[dd/MM/yyyy] hh:mm a');
  int numofpage = 1;
  int curpage = 1;
  int numofresult = 0;
  int cartCount = 0;
  String status = "LOADING...";
  var color;

  @override
  void initState() {
    super.initState();
    loadProductsData();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {}
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
          onPressed: () async {
            // ignore: unused_local_variable
            final what = await Navigator.push(
              context,
              MaterialPageRoute(builder: (content) =>
                CartScreen(
                  user: widget.user,
                )
              )
            );
            setState(() {
              cartCount == 0 ? loadCartCount() : loadCartCount();
            });
          },
          icon: cartCount == 0
          ? const Icon(Icons.trolley)
          : Badge(
            isLabelVisible: true,
            label: Text('$cartCount'),
            offset: const Offset(8, -10),
            backgroundColor: Colors.red,
            textColor: Colors.white,
            child: const Icon(
              Icons.trolley,
              size: 24,
            ),
          )
          ),
        ],
      ),
      body: productsList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  status.contains('LOADING...')
                  ? const CircularProgressIndicator()
                  : Column(
                    children: [
                      SizedBox(
                        height: screenHeight / 5,
                        child: Image.asset('assets/icon/error_notfound.png'),
                      ),
                      const SizedBox(height: 10,),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Text(
                    status,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 65, 65, 65),
                        fontSize: 14,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: GridView.count(
                      childAspectRatio: 0.75,
                      crossAxisCount: 2,
                      children: List.generate(productsList.length, (index) {
                        return Card(
                          elevation: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade200,
                                  Colors.blue.shade900,
                                ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              )
                            ),
                            child: InkWell(
                              //splashColor: Colors.red,
                              // onLongPress: () {
                              //   deleteDialog(index);
                              // },
                              onTap: () async {
                                Product prod = productsList[index];
                                // ignore: unused_local_variable
                                final what = await Navigator.push(context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        ProductDetailsScreen(
                                          user: widget.user,
                                          product: prod,
                                        ),
                                    transitionsBuilder:
                                        (context, animation, secondaryAnimation, child) {
                                      const begin = Offset(1.0, 0.0); // Slide in from the right
                                      const end = Offset.zero;
                                      const curve = Curves.ease;
                                
                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));
                                      var offsetAnimation = animation.drive(tween);
                                
                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
                                  ),
                                ).then((value) { setState(() {});});
                                setState(() {
                                  cartCount == 0 ? loadCartCount() : loadCartCount();
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                                child: Column(
                                  children: [
                                  SizedBox(
                                    child: Image.network(
                                        errorBuilder: (context, error, stackTrace) =>
                                            SizedBox(
                                              height: screenHeight/6,
                                              child: Image.asset(
                                                "assets/icon/error_notfound.png",
                                              ),
                                            ),
                                        width: screenWidth / 2,
                                        height: screenHeight / 6,
                                        fit: BoxFit.cover,
                                        scale: 4,
                                        "${MyConfig.servername}/memberlink/assets/products/${productsList[index].productFilename}"),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Text(
                                            productsList[index].productName.toString(),
                                            style: const TextStyle(
                                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        fit: FlexFit.loose,
                                        flex: 1,
                                        child: Text(truncateString(
                                            productsList[index].productDescription.toString(), 45),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3.6,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(getPrice(double.parse(productsList[index].productPrice.toString())),
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          const Icon(
                                            Icons.location_pin,
                                            size: 10,
                                            color: Colors.white,
                                          ),
                                          Text(lastLocation(productsList[index].productLocation.toString()),
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ]),
                              ),
                            ),
                          ),
                        );
                      })),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.05,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: numofpage,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if ((curpage - 1) == index) {
                      color = Colors.blue;
                    } else {
                      color = Colors.black;
                    }
                    return TextButton(
                        onPressed: () {
                          curpage = index + 1;
                          loadProductsData();
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
      drawer: MyDrawer(
        user: widget.user,
      ),
      floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // ignore: unused_local_variable
              final what = await Navigator.push(
                context,
                MaterialPageRoute(builder: (content) =>
                  CartScreen(
                    user: widget.user,
                  )
                )
              );
              setState(() {
                cartCount == 0 ? loadCartCount() : loadCartCount();
              });
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 10,
            tooltip: "Your Cart",
            shape: RoundedRectangleBorder(side: const BorderSide(width: 2, color: Colors.white, strokeAlign: 1.0), borderRadius: BorderRadius.circular(100)),
            child: cartCount == 0
              ? const Icon(Icons.trolley)
              : Badge(
                  isLabelVisible: true,
                  label: Text('$cartCount'),
                  offset: const Offset(8, -8),
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  child: const Icon(
                    Icons.trolley,
                    size: 24,
                  ),
                ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  String truncateString(String str, int length) {
    if (str.length > length) {
      str = str.substring(0, length);
      return "$str...";
    } else {
      return str;
    }
  }

  void loadProductsData() {
    http
        .get(Uri.parse("${MyConfig.servername}/memberlink/api/load_products.php?pageno=$curpage"))
        .then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          var result = data['data']['products'];
          productsList.clear();
          for (var item in result) {
            Product myproduct = Product.fromJson(item);
            productsList.add(myproduct);
          }
          setState(() {
            status = 'LOADING...';
            numofpage = data['numofpage'];
            numofresult = data['numberofresult'];
            loadCartCount();
          });
        } else {
          setState(() {
            productsList.clear();
            status = 'NO DATA';
          });
        }
      } else {
        status = "ERROR";
        log("Error");
        setState(() {});
      }
    });
  }

  void loadCartCount() {
    http
        .post(Uri.parse("${MyConfig.servername}/memberlink/api/count_cart.php"),
        body: {'userid': widget.user.userId.toString()})
        .then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          var result = data['data'];
          if (result != null) {
            setState(() {
              cartCount = int.parse(result.toString());
            });
          }
        }
      }
    });
  }

  // void deleteDialog(int index) {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //             title: Text(
  //               "Delete \"${truncateString(productsList[index].productName.toString(), 20)}\"",
  //               style: const TextStyle(fontSize: 18),
  //             ),
  //             content:
  //                 const Text("Are you sure you want to delete this product?"),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text("No"),
  //               ),
  //               TextButton(
  //                 onPressed: () {
  //                   deleteProduct(index);
  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text("Yes"),
  //               )
  //             ]);
  //       });
  // }

  void deleteProduct(int index) {
    http.post(
        Uri.parse("${MyConfig.servername}/memberlink/api/remove_product.php"),
        body: {
          "productid": productsList[index].productId.toString()
        }).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        log(data.toString());
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Success"),
            backgroundColor: Colors.green,
          ));
          loadProductsData(); //reload data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed"),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }

  String lastLocation(String text) {
    var words = text.split(',');
    return words.last.trim();
  }

  String getPrice(double price) {
    String newPrice = 'RM${price.toStringAsFixed(2)}';
    return newPrice;
  }
}
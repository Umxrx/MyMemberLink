import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mymemberlink/model/product.dart';
import 'package:mymemberlink/myconfig.dart';
import 'package:mymemberlink/shared/mydrawer.dart';
import 'package:mymemberlink/views/products/cart_screen.dart';
import 'package:mymemberlink/views/products/product_details.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> productsList = [];
  late double screenWidth, screenHeight;
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  String status = "LOADING...";
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
          IconButton(onPressed: () {
            //
          }, icon: const Icon(Icons.refresh))
        ],
      ),
      body: productsList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
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
          : GridView.count(
              childAspectRatio: 0.75,
              crossAxisCount: 2,
              children: List.generate(productsList.length, (index) {
                return Card(
                  child: InkWell(
                    splashColor: Colors.red,
                    onLongPress: () {
                      deleteDialog(index);
                    },
                    onTap: () {
                      showProductDetailsDialog(index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                      child: Column(children: [
                        Text(
                          productsList[index].productName.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis),
                        ),
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
                          child: Text(
                            productsList[index].productCategory.toString(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(df.format(DateTime.parse(
                            productsList[index].productDate.toString()))),
                        Text(truncateString(
                            productsList[index].productDescription.toString(), 45)),
                      ]),
                    ),
                  ),
                );
              })),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(context,
                MaterialPageRoute(builder: (content) => const CartScreen()));
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 10,
            tooltip: "Your Cart",
            shape: RoundedRectangleBorder(side: const BorderSide(width: 2, color: Colors.white, strokeAlign: 1.0), borderRadius: BorderRadius.circular(100)),
            child: const Icon(Icons.trolley),
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
        .get(Uri.parse("${MyConfig.servername}/memberlink/api/load_products.php"))
        .then((response) {
      log(response.body.toString());
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          var result = data['data']['products'];
          productsList.clear();
          for (var item in result) {
            Product myproduct = Product.fromJson(item);
            productsList.add(myproduct);
          }
          setState(() {});
        } else {
          status = "NO DATA";
        }
      } else {
        status = "ERROR";
        log("Error");
        setState(() {});
      }
    });
  }

  void showProductDetailsDialog(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(productsList[index].productName.toString()),
            content: SingleChildScrollView(
              child: Column(children: [
                Image.network(
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                          "assets/icon/error_notfound.png",
                        ),
                    width: screenWidth,
                    height: screenHeight / 4,
                    fit: BoxFit.cover,
                    scale: 4,
                    "${MyConfig.servername}/memberlink/assets/products/${productsList[index].productFilename}"),
                Text(productsList[index].productCategory.toString()),
                Text(df.format(
                    DateTime.parse(productsList[index].productDate.toString()))),
                Text(productsList[index].productLocation.toString()),
                const SizedBox(height: 10),
                Text(
                  productsList[index].productDescription.toString(),
                  textAlign: TextAlign.justify,
                )
              ]),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Product myproduct = productsList[index];
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (content) => ProductDetailsScreen(
                                product: myproduct,
                              )
                            )
                          );
                  loadProductsData();
                },
                child: const Text("Show Product"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Close"),
              )
            ],
          );
        });
  }

  void deleteDialog(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(
                "Delete \"${truncateString(productsList[index].productName.toString(), 20)}\"",
                style: const TextStyle(fontSize: 18),
              ),
              content:
                  const Text("Are you sure you want to delete this product?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () {
                    deleteProduct(index);
                    Navigator.pop(context);
                  },
                  child: const Text("Yes"),
                )
              ]);
        });
  }

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
}
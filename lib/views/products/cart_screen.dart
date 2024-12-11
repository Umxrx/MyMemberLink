import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mymemberlink/model/product.dart';
import 'package:mymemberlink/myconfig.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Product> productsList = [];
  String status = 'LOADING...';

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
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

  void deleteNews(int index) {
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
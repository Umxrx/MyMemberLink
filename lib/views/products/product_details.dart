import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mymemberlink/model/product.dart';
import 'package:mymemberlink/model/user.dart';
import 'package:mymemberlink/myconfig.dart';
import 'package:http/http.dart' as http;

class ProductDetailsScreen extends StatefulWidget {
  final User user;
  final Product product;

  const ProductDetailsScreen({super.key, required this.user, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late double screenWidth, screenHeight;
  final df = DateFormat('dd/MM/yyyy hh:mm a');

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Details",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight * 0.35,
                width: screenWidth,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    "${MyConfig.servername}/memberlink/assets/products/${widget.product.productFilename}",
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  widget.product.productName.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  widget.product.productCategory.toString(),
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Date Available: ${df.format(DateTime.parse(widget.product.productDate.toString()))}",
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                "Product ID: ${widget.product.productId}",
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Text(
                widget.product.productDescription.toString(),
                style: const TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),
              Text(
                "Price: ${getPrice(double.parse(widget.product.productPrice.toString()))}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 8),
              Text(
                "Quantity Available: ${widget.product.productQuantity}",
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onAddToCart,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text("Add to Cart"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Not available yet"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Buy Now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onAddToCart() {
    String userId = widget.user.userId.toString();
    String productId = widget.product.productId.toString();
    http.post(
      Uri.parse("${MyConfig.servername}/memberlink/api/product_exist.php"),
      body: {"userid": userId, "productid": productId})
      .then((response) {
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            log('${data['data']['cart'][0]['product_quantity']}');
            log(widget.product.productQuantity.toString());
            if (int.parse(data['data']['cart'][0]['product_quantity']) < int.parse(widget.product.productQuantity.toString())) {
              http.post(
              Uri.parse("${MyConfig.servername}/memberlink/api/increment_cart.php"),
              body: {"userid": userId, "productid": productId})
              .then((response) {
                if (response.statusCode == 200) {
                  var data = jsonDecode(response.body);
                  if (data['status'] == 'success') {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text(style: TextStyle(color: Colors.white), 'Item added to cart successfully'),
                      backgroundColor: Colors.green[700],
                      duration: const Duration(seconds: 2),
                    ));
                  }
                  else {
                    log(response.body);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text(style: TextStyle(color: Colors.white), 'Something went wrong'),
                      backgroundColor: Colors.green[700],
                      duration: const Duration(seconds: 2),
                    ));
                  }
                }
              });
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(style: TextStyle(color: Colors.white), 'Insufficient item'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ));
            }
          }
          else {
            // Insert to cart
            http.post(
              Uri.parse("${MyConfig.servername}/memberlink/api/insert_cart.php"),
              body: {"userid": userId, "productid": productId})
              .then((response) {
                if (response.statusCode == 200) {
                  var data = jsonDecode(response.body);
                  if (data['status'] == 'success') {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text(style: TextStyle(color: Colors.white), 'Item added to cart successfully'),
                      backgroundColor: Colors.green[700],
                      duration: const Duration(seconds: 2),
                    ));
                  }
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(style: TextStyle(color: Colors.white), 'Something went wrong'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ));
                  }
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(style: TextStyle(color: Colors.white), 'Something went wrong'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ));
                }
              });
          }
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(style: TextStyle(color: Colors.white), 'Something went wrong'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ));
        }
      });
    
  }

  String getPrice(double price) {
    return 'RM${price.toStringAsFixed(2)}';
  }
}

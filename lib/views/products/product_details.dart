import 'package:flutter/material.dart';
import 'package:mymemberlink/model/product.dart';
//organizational t-shirts, mugs, bags, pens and more.
class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
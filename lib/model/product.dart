class Product {
  String? productId;
  String? productName;
  String? productFilename;
  String? productCategory; //
  String? productDate; //
  String? productLocation; //
  String? productDescription;
  String? productQuantity;
  String? productPrice;
// name, picture, description, quantity, price, etc
  Product(
      {this.productId,
      this.productName,
      this.productFilename,
      this.productCategory,
      this.productDate,
      this.productLocation,
      this.productDescription,
      this.productQuantity,
      this.productPrice,});

  Product.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    productName = json['product_name'];
    productFilename = json['product_filename'];
    productCategory = json['product_category'];
    productDate = json['product_date'];
    productLocation = json['product_location'];
    productDescription = json['product_description'];
    productQuantity = json['product_quantity'];
    productPrice = json['product_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['product_filename'] = productFilename;
    data['product_category'] = productCategory;
    data['product_date'] = productDate;
    data['product_location'] = productLocation;
    data['product_description'] = productDescription;
    data['product_quantity'] = productQuantity;
    data['product_price'] = productPrice;
    return data;
  }
}
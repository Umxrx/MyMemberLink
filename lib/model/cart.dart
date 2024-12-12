class Cart {
  String? cartId;
  String? userId;
  String? productId;
  String? productQuantity;
  String? cartTimestamp;

  Cart(
      {this.cartId,
      this.userId,
      this.productId,
      this.productQuantity,
      this.cartTimestamp,});

  Cart.fromJson(Map<String, dynamic> json) {
    cartId = json['cart_id'];
    userId = json['user_id'];
    productId = json['product_id'];
    productQuantity = json['product_quantity'];
    cartTimestamp = json['cart_timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cart_id'] = cartId;
    data['user_id'] = userId;
    data['product_id'] = productId;
    data['product_quantity'] = productQuantity;
    data['cart_timestamp'] = cartTimestamp;
    return data;
  }
}
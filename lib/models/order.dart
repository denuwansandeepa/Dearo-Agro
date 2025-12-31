class Order {
  final String shippingAddress;
  final String paymentMethod;

  Order({required this.shippingAddress, required this.paymentMethod});

  Map<String, dynamic> toJson() {
    return {
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
    };
  }
}

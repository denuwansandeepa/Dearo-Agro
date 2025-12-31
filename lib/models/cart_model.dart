class CartItem {
  final String id;
  final String name;
  final String image;
  final double quantity;
  final double price;

  CartItem({required this.id, required this.name, required this.image, required this.quantity, required this.price});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id']['\$oid'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class CartModel {
  final List<CartItem> items;
  final double total;

  CartModel({required this.items, required this.total});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e))
          .toList(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

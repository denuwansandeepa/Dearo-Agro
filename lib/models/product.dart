class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final String category;
  final int quantity;
  final String harvestId;
  final double? currentAmount; // Add this field

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.quantity,
    required this.harvestId,
    this.currentAmount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? 'Unnamed Product',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      category: json['category'] ?? 'Uncategorized',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      harvestId: (json['harvestId'] ?? '').toString(),
      currentAmount: json['currentAmount']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'quantity': quantity,
      'harvestId': harvestId,
      'currentAmount': currentAmount,
    };
  }
}

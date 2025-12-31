class Crop {
  final String id;
  final String name;
  final String imageUrl;
  final String category;  // <-- add this

  Crop({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,  // <-- add this
  });

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        category: json['category'] ?? '', // <-- parse category
      );
}

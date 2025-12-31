class TechnicalInquiry {
  final String id;
  final String title;
  final String description;
  final String date;
  final String? status;
  final String? imagePath;
  final String? documentPath;

  TechnicalInquiry({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.status,
    this.imagePath,
    this.documentPath,
  });

  factory TechnicalInquiry.fromJson(Map<String, dynamic> json) {
    return TechnicalInquiry(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      date: json['date'],
      status: json['status'],
      imagePath: json['imagePath'],
      documentPath: json['documentPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'status': status,
      'imagePath': imagePath,
      'documentPath': documentPath,
    };
  }
}
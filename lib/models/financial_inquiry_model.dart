class FinancialInquiry {
  final String id;
  final String title;
  final String description;
  final String date;
  final String? imagePath;
  final String? documentPath;
  final String? status;

  FinancialInquiry({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.imagePath,
    this.documentPath,
    this.status,
  });

  factory FinancialInquiry.fromJson(Map<String, dynamic> json) {
    return FinancialInquiry(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      description: json['description'],
      date: json['date'],
      imagePath: json['imagePath'],
      documentPath: json['documentPath'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'imagePath': imagePath,
      'documentPath': documentPath,
      'status': status,
    };
  }
}
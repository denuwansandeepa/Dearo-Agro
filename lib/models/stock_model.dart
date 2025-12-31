class Stock {
  final String id;
  final String memberId;
  final String fullName;
  final String mobileNumber;
  final String address;
  final String cropName;
  final double totalAmount;
  final double currentAmount;
  final double pricePerKg;
  final DateTime harvestDate;
  final DateTime? createdAt;
  final double currentPrice;
  final int quantity;
  final bool isProductListed;

  Stock({
    required this.id,
    required this.memberId,
    required this.fullName,
    required this.mobileNumber,
    required this.address,
    required this.cropName,
    required this.totalAmount,
    required this.currentAmount,
    required this.pricePerKg,
    required this.harvestDate,
    this.createdAt,
    required this.currentPrice,
    required this.quantity,
    required this.isProductListed,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? "",
      memberId: json['memberId'] ?? '',
      fullName: json['fullName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      address: json['address'] ?? '',
      cropName: json['cropName'] ?? '',
      totalAmount: _parseDouble(json['totalAmount']),
      currentAmount: _parseDouble(json['currentAmount']),
      pricePerKg: _parseDouble(json['pricePerKg']),
      harvestDate: DateTime.parse(json['harvestDate']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      currentPrice: _parseDouble(json['currentPrice']),
      quantity: _parseInt(json['quantity']),
      isProductListed: json['isProductListed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'address': address,
      'cropName': cropName,
      'totalAmount': totalAmount,
      'currentAmount': currentAmount,
      'pricePerKg': pricePerKg,
      'harvestDate': harvestDate.toIso8601String(),
      'currentPrice': currentPrice,
      'quantity': quantity,
      'isProductListed': isProductListed,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double get totalValue => totalAmount * pricePerKg;
}

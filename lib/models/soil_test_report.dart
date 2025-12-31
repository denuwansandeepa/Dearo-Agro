class SoilTestReport {
  final String? id;
  final String ph;
  final String nitrogen;
  final String phosphorus;
  final String potassium;
  final String micronutrients;
  final String soilTexture;
  final String? farmerId;

  SoilTestReport({
    this.id,
    required this.ph,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.micronutrients,
    required this.soilTexture,
    this.farmerId,
  });

  factory SoilTestReport.fromJson(Map<String, dynamic> json) {
    return SoilTestReport(
      id: json['_id'] ?? json['id'],
      ph: json['ph'],
      nitrogen: json['nitrogen'],
      phosphorus: json['phosphorus'],
      potassium: json['potassium'],
      micronutrients: json['micronutrients'],
      soilTexture: json['soilTexture'],
      farmerId: json['farmerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ph': ph,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'micronutrients': micronutrients,
      'soilTexture': soilTexture,
      if (farmerId != null) 'farmerId': farmerId,
    };
  }
}

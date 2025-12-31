class CropUpdate {
  String? id;
  String? memberId;
  String addDate;
  String description;
  String? fertilizerType;
  double? fertilizerAmount;
  String? fertilizerUnit;

  CropUpdate({
    this.id,
    this.memberId,
    required this.addDate,
    required this.description,
    this.fertilizerType,
    this.fertilizerAmount,
    this.fertilizerUnit,
  });

  factory CropUpdate.fromJson(Map<String, dynamic> json) {
    return CropUpdate(
      id: json['_id'],
      memberId: json['memberId'],
      addDate: json['addDate'],
      description: json['description'],
      fertilizerType: json['fertilizerType'],
      fertilizerAmount: json['fertilizerAmount'] != null
          ? (json['fertilizerAmount'] as num).toDouble()
          : null,
      fertilizerUnit: json['fertilizerUnit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (memberId != null) 'memberId': memberId,
      'addDate': addDate,
      'description': description,
      if (fertilizerType != null) 'fertilizerType': fertilizerType,
      if (fertilizerAmount != null) 'fertilizerAmount': fertilizerAmount,
      if (fertilizerUnit != null) 'fertilizerUnit': fertilizerUnit,
    };
  }
}

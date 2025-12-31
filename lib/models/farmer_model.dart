class Farmer {
  final String id;
  final String fullName;
  final String mobileNumber;
  final String? password;
  final String? groupId;
  final String? groupName;
  final String? profileImage;
  final String? userType;
  final String? branchName;
  final DateTime? createdAt;

  Farmer({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    this.password,
    this.groupId,
    this.groupName,
    this.profileImage,
    this.userType,
    this.branchName,
    this.createdAt,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? 'Unnamed Farmer',
      mobileNumber: json['mobileNumber'] ?? 'No mobile number',
      password: json['password'],
      groupId: json['groupId'],
      groupName: json['groupName'],
      profileImage: json['profileImage'],
      userType: json['userType'] ?? 'Farmer',
      branchName: json['branchName'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}

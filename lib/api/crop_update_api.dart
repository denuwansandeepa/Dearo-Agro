import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/crop_update_model.dart';

class CropUpdateApi {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  Future<String?> _getUserId() async {
    return await _storage.read(key: "userId");
  }

  Future<String> submitCropUpdate(CropUpdate update,
      {bool isUpdate = false}) async {
    final userId = await _getUserId();
    if (userId == null) throw Exception("User not logged in");

    update.memberId = userId;

    final url = isUpdate
        ? "https://dearoagro-backend.onrender.com/api/cropupdate"
        : "https://dearoagro-backend.onrender.com/api/cropsubmit";

    try {
      final response = isUpdate
          ? await _dio.put(url, data: update.toJson())
          : await _dio.post(url, data: update.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data["message"];
      } else {
        throw Exception("Failed to submit crop update: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error submitting crop update: ${e.toString()}");
    }
  }
}

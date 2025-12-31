import 'package:dio/dio.dart';
import '../models/cultivation_model.dart';

class CultivationApi {
  final Dio _dio = Dio();
  final String baseUrl = "https://dearoagro-backend.onrender.com/api";

  Future<String> submitOrUpdateCultivation(Cultivation cultivation, {bool isUpdate = false}) async {
    final url = "$baseUrl/${isUpdate ? 'update' : 'submit'}";
    final response = isUpdate
        ? await _dio.put(url, data: cultivation.toJson())
        : await _dio.post(url, data: cultivation.toJson());

    return response.data["message"];
  }
}

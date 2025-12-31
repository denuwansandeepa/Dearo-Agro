import 'dart:convert';
import 'package:farmeragriapp/models/crop.dart';
import 'package:http/http.dart' as http;

class CropApi {
  static const String baseUrl = 'https://dearoagro-backend.onrender.com/api/crops';

  static Future<List<Crop>> fetchCrops() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Crop.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load crops');
    }
  }
}

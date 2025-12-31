import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/farmer_model.dart';

class FarmerApi {
  static const String baseUrl =
      'https://dearoagro-backend.onrender.com/api/farmers';

  static Future<List<Farmer>> fetchFarmers() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Farmer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch farmers');
      }
    } catch (error) {
      throw Exception('Error fetching farmers: $error');
    }
  }

  static Future<void> deleteFarmer(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete farmer');
      }
    } catch (error) {
      throw Exception('Error deleting farmer: $error');
    }
  }

  static Future<void> updateFarmer(String id, Farmer farmerData) async {
    try {
      if (id.isEmpty || id == 'undefined') {
        throw Exception('Invalid farmer ID');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': farmerData.fullName,
          'mobileNumber': farmerData.mobileNumber,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update farmer');
      }
    } catch (error) {
      throw Exception('Error updating farmer: $error');
    }
  }

  static Future<void> createFarmer(Farmer farmerData) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': farmerData.fullName,
          'mobileNumber': farmerData.mobileNumber,
          'password': farmerData.password,
          'branchName': farmerData.branchName,
        }),
      );


      if (response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create farmer');
      }
    } catch (error) {
      throw Exception('Error creating farmer: $error');
    }
  }
}

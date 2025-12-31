import 'dart:convert';
import 'package:farmeragriapp/models/technical_inquiry_model.dart';
import 'package:http/http.dart' as http;

class TechnicalInquiryApi {
  static const String baseUrl = 'https://dearoagro-backend.onrender.com';

  TechnicalInquiryApi(String baseUrl);

  Future<List<TechnicalInquiry>> getInquiries() async {
    final response = await http.get(Uri.parse('$baseUrl/api/tinquiries'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => TechnicalInquiry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load inquiries');
    }
  }

  Future<void> deleteInquiry(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/tinquiry/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete inquiry');
    }
  }

  Future<void> updateInquiry(TechnicalInquiry inquiry) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tinquiry/${inquiry.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(inquiry.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update inquiry');
    }
  }

  Future<void> createInquiry(TechnicalInquiry inquiry, String farmerId,
      {String? imagePath, String? documentPath}) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/api/tinquiry'))
          ..fields['title'] = inquiry.title
          ..fields['description'] = inquiry.description
          ..fields['date'] = inquiry.date
          ..fields['farmerId'] = farmerId;

    if (imagePath != null) {
      request.files
          .add(await http.MultipartFile.fromPath('imagePath', imagePath));
    }

    if (documentPath != null) {
      request.files
          .add(await http.MultipartFile.fromPath('documentPath', documentPath));
    }

    final response = await request.send();
    if (response.statusCode != 201) {
      throw Exception('Failed to create inquiry');
    }
  }

  Future<List<TechnicalInquiry>> getInquiriesByFarmer(String farmerId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/tinquiries/farmer/$farmerId'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => TechnicalInquiry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load inquiries for farmer');
    }
  }
}

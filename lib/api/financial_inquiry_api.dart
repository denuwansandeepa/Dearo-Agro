import 'dart:convert';
import 'package:farmeragriapp/models/financial_inquiry_model.dart';
import 'package:http/http.dart' as http;

class FinancialInquiryApi {
  static const String baseUrl = 'https://dearoagro-backend.onrender.com';

  FinancialInquiryApi();

  Future<List<FinancialInquiry>> getInquiries() async {
    final response = await http.get(Uri.parse('$baseUrl/api/finquiries'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => FinancialInquiry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load inquiries');
    }
  }

  Future<void> deleteInquiry(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/finquiry/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete inquiry');
    }
  }

  Future<void> updateInquiry(FinancialInquiry inquiry) async {
    final response = await http.put(
      Uri.parse('$baseUrl/finquiry/${inquiry.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(inquiry.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update inquiry');
    }
  }
}

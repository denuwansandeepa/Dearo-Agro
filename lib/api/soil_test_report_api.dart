import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/soil_test_report.dart';

class SoilTestReportApi {
  final String baseUrl;
  SoilTestReportApi(this.baseUrl);

  Future<bool> submitReport(SoilTestReport report) async {
    final url = Uri.parse('$baseUrl/soil-test');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(report.toJson()),
    );
    if (response.statusCode != 201) {
      print('Backend error: ${response.body}');
    }
    return response.statusCode == 201;
  }

  Future<List<SoilTestReport>> getReportsByFarmer(String farmerId) async {
    final url = Uri.parse('$baseUrl/soil-test/farmer/$farmerId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => SoilTestReport.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load reports');
    }
  }

  Future<bool> deleteReport(String id) async {
    final url = Uri.parse('$baseUrl/soil-test/$id');
    final response = await http.delete(url);
    return response.statusCode == 200;
  }

  Future<bool> updateReport(SoilTestReport report) async {
    if (report.id == null) throw Exception('Report ID is required for update');
    final url = Uri.parse('$baseUrl/soil-test/${report.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(report.toJson()),
    );
    return response.statusCode == 200;
  }
}

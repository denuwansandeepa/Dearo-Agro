import 'dart:convert';
import 'package:farmeragriapp/services/auth_service.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthApi {
  static const String baseUrl = 'https://dearoagro-backend.onrender.com/api/auth';

  static Future<http.Response> signUp(User user) async {
    final url = Uri.parse('$baseUrl/signup');
    

    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );
  }
   static Future<http.Response> signIn(User user) async {
    final url = Uri.parse('$baseUrl/signin');
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );
  }
  static Future<http.Response> getWithToken(String endpoint) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    
    return await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  static Future<http.Response> postWithToken(String endpoint, dynamic body) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    
    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );
  }


  
}

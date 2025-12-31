import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/cart_model.dart';

class CartApi {
  static const String baseUrl = 'https://dearoagro-backend.onrender.com/api/cart';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  static const FlutterSecureStorage storage = FlutterSecureStorage();

  // Get token from secure storage
  static Future<String?> _getToken() async {
    return await storage.read(key: "authToken");
  }

  static Future<bool> addToCart(String stockId, double quantity) async {
  final token = await _getToken();

  if (token == null) {
    print("No token found");
    return false;
  }

  print("Sending token: $token"); // Debug token

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'stockId': stockId,
        'quantity': quantity,
      }),
    );

    print("Add to cart response: ${response.statusCode} ${response.body}");
    
    if (response.statusCode != 200) {
      print("Error details: ${response.body}");
    }
    
    return response.statusCode == 200;
  } catch (e) {
    print("Exception during addToCart: $e");
    return false;
  }
}
  static Future<CartModel?> fetchCart() async {
    final token = await _getToken();

    if (token == null) {
      print("No token found");
      return null;
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        ...headers,
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return CartModel.fromJson(json.decode(response.body));
    } else {
      print("Failed to fetch cart: ${response.statusCode} ${response.body}");
      return null;
    }
  }
}

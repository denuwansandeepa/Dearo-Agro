import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductApi {
  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('https://dearoagro-backend.onrender.com/api/products'),
    );
    if (response.statusCode == 200) {
      print('Debug: First product = ${json.decode(response.body)}');
      final data = json.decode(response.body);
      final List<dynamic> productsList = data is List ? data : [data];
      return productsList.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}

void main() async {
  final products = await ProductApi.fetchProducts();
  for (var product in products) {
    print('Debug: productId=${product.id}, name=${product.name}');
    if (product.id.isEmpty) {
      print('Invalid productId: productId is empty');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_model.dart';

class StockApi {
  static const String baseUrl =
      'https://dearoagro-backend.onrender.com/api/stocks';

  // Fetch all listed products (isProductListed = true)
  static Future<List<Stock>> fetchListedProducts() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/products/listed'), // keep this route
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Defensive check
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        final List<dynamic> stocksList = data['data'];
        return stocksList.map((item) => Stock.fromJson(item)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load listed products: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching listed products: $e');
  }
}

  // Fetch stocks by user ID
  static Future<List<Stock>> fetchStocksByUserId(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fetch/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Stock.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load stocks');
      }
    } catch (e) {
      throw Exception('Error fetching stocks: $e');
    }
  }

  // Delete stock
  static Future<void> deleteStock(String stockId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete/$stockId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete stock');
      }
    } catch (e) {
      throw Exception('Error deleting stock: $e');
    }
  }

  // Toggle product listing status
  static Future<Stock> toggleProductListing(
      String stockId, bool isListed) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/toggle/$stockId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isProductListed': isListed}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Stock.fromJson(data['data']);
      } else {
        throw Exception('Failed to toggle product listing');
      }
    } catch (e) {
      throw Exception('Error toggling product listing: $e');
    }
  }

  // Update stock current amount after order
  static Future<Stock> updateCurrentAmount(
      String stockId, double orderAmount) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update-current-amount/$stockId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'orderAmount': orderAmount}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Stock.fromJson(data['data']);
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Invalid order amount');
      } else if (response.statusCode == 404) {
        throw Exception('Stock not found');
      } else {
        throw Exception('Failed to update stock amount');
      }
    } catch (e) {
      throw Exception('Error updating stock amount: $e');
    }
  }

  // Get all stocks
  static Future<List<Stock>> fetchAllStocks() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Stock.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load all stocks');
      }
    } catch (e) {
      throw Exception('Error fetching all stocks: $e');
    }
  }

  // Get stock by ID
  static Future<Stock> fetchStockById(String stockId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$stockId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Stock.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Stock not found');
      } else {
        throw Exception('Failed to load stock');
      }
    } catch (e) {
      throw Exception('Error fetching stock: $e');
    }
  }

  // Create new stock
  static Future<Stock> createStock({
    required String memberId,
    required String fullName,
    required String mobileNumber,
    required String address,
    required String cropName,
    required double totalAmount,
    double? currentAmount,
    required double pricePerKg,
    required DateTime harvestDate,
    double? currentPrice,
    double? quantity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'memberId': memberId,
          'fullName': fullName,
          'mobileNumber': mobileNumber,
          'address': address,
          'cropName': cropName,
          'totalAmount': totalAmount,
          'currentAmount': currentAmount ?? totalAmount,
          'pricePerKg': pricePerKg,
          'harvestDate': harvestDate.toIso8601String(),
          'currentPrice': currentPrice ?? 0,
          'quantity': quantity ?? 0,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Stock.fromJson(data['data']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to create stock');
      }
    } catch (e) {
      throw Exception('Error creating stock: $e');
    }
  }

  // Update stock
  static Future<Stock> updateStock(
      String stockId, Map<String, dynamic> updateData) async {
    try {
      final body = {'id': stockId, ...updateData};

      final response = await http.put(
        Uri.parse('$baseUrl/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Stock.fromJson(data['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Stock not found');
      } else {
        throw Exception('Failed to update stock');
      }
    } catch (e) {
      throw Exception('Error updating stock: $e');
    }
  }

  // Get dashboard summary
  static Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/summary'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load dashboard summary');
      }
    } catch (e) {
      throw Exception('Error fetching dashboard summary: $e');
    }
  }

  // Get listed products (alternative route)
  static Future<List<Stock>> fetchListedProductsAlt() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/listed/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> stocksList = data['data'] ?? [];
        return stocksList.map((item) => Stock.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load listed products');
      }
    } catch (e) {
      throw Exception('Error fetching listed products: $e');
    }
  }
}

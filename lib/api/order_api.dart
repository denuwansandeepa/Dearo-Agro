import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService {
  final String baseUrl;

  OrderService(this.baseUrl);

  // Create order from cart
  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData, String authToken) async {
    final url = Uri.parse('$baseUrl/orders');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(orderData),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception('Order creation failed: ${responseData['message']}');
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to create order: ${errorData['message'] ?? response.body}');
    }
  }

  // Fetch buyer's orders
  Future<Map<String, dynamic>> fetchBuyerOrders(String authToken) async {
    final url = Uri.parse('$baseUrl/orders');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return {
          'success': true,
          'count': responseData['count'] ?? 0,
          'orders': responseData['orders'] ?? []
        };
      } else {
        throw Exception('Failed to fetch orders: ${responseData['message']}');
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to fetch orders: ${errorData['message'] ?? response.body}');
    }
  }

  // Fetch order details by ID
  Future<Map<String, dynamic>> fetchOrderDetails(
      String orderId, String authToken) async {
    final url = Uri.parse('$baseUrl/orders/$orderId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return responseData['order'];
      } else {
        throw Exception(
            'Failed to fetch order details: ${responseData['message']}');
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to fetch order details: ${errorData['message'] ?? response.body}');
    }
  }

  // Delete order by ID
  Future<Map<String, dynamic>> deleteOrder(
      String orderId, String authToken) async {
    final url = Uri.parse('$baseUrl/orders/$orderId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception('Failed to delete order: ${responseData['message']}');
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to delete order: ${errorData['message'] ?? response.body}');
    }
  }

  // Update order status
  Future<Map<String, dynamic>> updateOrderStatus(
      String orderId, String status, String authToken) async {
    final url = Uri.parse('$baseUrl/orders/$orderId/status');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception(
            'Failed to update order status: ${responseData['message']}');
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to update order status: ${errorData['message'] ?? response.body}');
    }
  }
}

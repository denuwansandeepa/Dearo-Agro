import 'package:dio/dio.dart';
import '../models/expense_model.dart';

class ExpenseApi {
  final Dio _dio = Dio();

  final String _submitUrl = "https://dearoagro-backend.onrender.com/api/esubmit";
  final String _updateUrl = "https://dearoagro-backend.onrender.com/api/eupdate";

  Future<String> submitExpense(Expense expense) async {
    final response = await _dio.post(_submitUrl, data: expense.toJson());
    return response.data["message"];
  }

  Future<String> updateExpense(Expense expense) async {
    final response = await _dio.put(_updateUrl, data: expense.toJson());
    return response.data["message"];
  }
}

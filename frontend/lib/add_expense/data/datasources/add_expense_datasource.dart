import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/add_expense/data/services/add_expense_service.dart';
import 'package:xyphora_frontend/core/exceptions.dart';

@lazySingleton
class AddExpenseDatasource {
  final AddExpenseService _service;

  AddExpenseDatasource(this._service);

  Future<Map<String, dynamic>> fetchCategories() async {
    try {
      final response = await _service.fetchCategories();
      final data = response['data'] as List<dynamic>? ?? [];
      return {
        'success': true,
        'data': data.cast<Map<String, dynamic>>(),
      };
    } catch (error) {
      _handleError(error);
    }
  }

  Future<Map<String, dynamic>> fetchEvents() async {
    try {
      final response = await _service.fetchEvents();
      final data = response['data'] as List<dynamic>? ?? [];
      return {
        'success': true,
        'data': data.cast<Map<String, dynamic>>(),
      };
    } catch (error) {
      _handleError(error);
    }
  }

  Future<Map<String, dynamic>> fetchEvent(int eventId) async {
    try {
      final response = await _service.fetchEvent(eventId);
      return {
        'success': true,
        'data': response['data'] as Map<String, dynamic>? ?? {},
      };
    } catch (error) {
      _handleError(error);
    }
  }

  Future<Map<String, dynamic>> createExpense({
    int? eventId,
    int? categoryId,
    required String title,
    required double amount,
    String currency = 'VND',
    String? description,
    String? expenseDate,
    String? splitMethod,
    List<int> payerIds = const [],
    List<Map<String, dynamic>> splits = const [],
  }) async {
    try {
      return await _service.saveExpense(
        eventId: eventId,
        categoryId: categoryId,
        title: title,
        amount: amount,
        currency: currency,
        description: description,
        expenseDate: expenseDate,
        splitMethod: splitMethod,
        payerIds: payerIds,
        splits: splits,
      );
    } catch (error) {
      _handleError(error);
    }
  }

  Future<Map<String, dynamic>> updateExpense({
    required int expenseId,
    int? eventId,
    int? categoryId,
    required String title,
    required double amount,
    String currency = 'VND',
    String? description,
    String? expenseDate,
    String? splitMethod,
    List<int> payerIds = const [],
    List<Map<String, dynamic>> splits = const [],
  }) async {
    try {
      return await _service.updateExpense(
        expenseId: expenseId,
        eventId: eventId,
        categoryId: categoryId,
        title: title,
        amount: amount,
        currency: currency,
        description: description,
        expenseDate: expenseDate,
        splitMethod: splitMethod,
        payerIds: payerIds,
        splits: splits,
      );
    } catch (error) {
      _handleError(error);
    }
  }

  Future<Map<String, dynamic>> deleteExpense(int expenseId) async {
    try {
      return await _service.deleteExpense(expenseId);
    } catch (error) {
      _handleError(error);
    }
  }

  Never _handleError(Object error) {
    if (error is ExceptionWithMessage) {
      throw error;
    } else if (error is DioException) {
      final data = error.response?.data;
      String? serverMessage;
      if (data is Map) {
        serverMessage = data['message']?.toString();
      }
      if (error.response?.statusCode == 401) {
        serverMessage = 'Phiên đăng nhập đã hết hạn';
      }
      throw ExceptionWithMessage(mess: serverMessage ?? 'Lỗi kết nối máy chủ');
    } else {
      throw ExceptionWithMessage(mess: error.toString());
    }
  }
}
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/expense_history/data/services/expense_history_service.dart';
import 'package:xyphora_frontend/expense_history/domain/models/expense_history_item.dart';
import 'package:xyphora_frontend/core/exceptions.dart';

@lazySingleton
class ExpenseHistoryDatasource {
  final ExpenseHistoryService _service;

  ExpenseHistoryDatasource(this._service);

  Future<ExpensePageResult> fetchExpenses({
    int? eventId,
    int page = 1,
    int perPage = 15,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? categoryId,
    int? payerId,
    String? search,
    String? mySplitStatus,
    String sort = 'desc',
  }) async {
    try {
      final response = await _service.fetchExpenses(
        eventId: eventId,
        page: page,
        perPage: perPage,
        dateFrom: dateFrom,
        dateTo: dateTo,
        categoryId: categoryId,
        payerId: payerId,
        search: search,
        mySplitStatus: mySplitStatus,
        sort: sort,
      );
      return ExpensePageResult.fromJson(response);
    } catch (error) {
      _handleError(error);
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final response = await _service.fetchCategories();
      final data = response['data'] as List<dynamic>? ?? [];
      return data.cast<Map<String, dynamic>>();
    } catch (error) {
      _handleError(error);
    }
  }

  Future<List<Map<String, dynamic>>> fetchEvents() async {
    try {
      final response = await _service.fetchEvents();
      final data = response['data'] as List<dynamic>? ?? [];
      return data.cast<Map<String, dynamic>>();
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
      throw ExceptionWithMessage(mess: serverMessage ?? 'Lỗi kết nối máy chủ');
    } else {
      throw ExceptionWithMessage(mess: error.toString());
    }
  }
}
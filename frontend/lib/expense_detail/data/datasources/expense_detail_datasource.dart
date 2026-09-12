import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/expense_detail/data/services/expense_detail_service.dart';
import 'package:xyphora_frontend/expense_detail/domain/models/expense_detail.dart';
import 'package:xyphora_frontend/core/exceptions.dart';

@lazySingleton
class ExpenseDetailDatasource {
  final ExpenseDetailService _service;

  ExpenseDetailDatasource(this._service);

  Future<ExpenseDetail> fetchExpenseDetail(int expenseId) async {
    try {
      final response = await _service.fetchExpenseDetail(expenseId);
      final data = response['data'] as Map<String, dynamic>? ?? {};
      return ExpenseDetail.fromJson(data);
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
      } else if (error.response?.statusCode == 403) {
        serverMessage = 'Bạn không có quyền xem chi tiêu này';
      } else if (error.response?.statusCode == 404) {
        serverMessage = 'Chi tiêu không tồn tại';
      }
      throw ExceptionWithMessage(mess: serverMessage ?? 'Lỗi kết nối máy chủ');
    } else {
      throw ExceptionWithMessage(mess: error.toString());
    }
  }
}
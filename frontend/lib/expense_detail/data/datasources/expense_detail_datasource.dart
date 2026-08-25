import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../config/token_storage.dart';
import '../../domain/models/expense_detail.dart';

class ExpenseDetailDatasource {
  static final String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.read();
    final auth = token == null ? null : 'Bearer $token';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': ?auth,
    };
  }

  Future<ExpenseDetail> fetchExpenseDetail(int expenseId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/expenses/$expenseId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ExpenseDetail.fromJson(body['data'] as Map<String, dynamic>);
    }

    String message = 'Không thể tải chi tiết chi tiêu';
    if (response.statusCode == 401) {
      message = 'Phiên đăng nhập đã hết hạn';
    } else if (response.statusCode == 403) {
      message = 'Bạn không có quyền xem chi tiêu này';
    } else if (response.statusCode == 404) {
      message = 'Chi tiêu không tồn tại';
    } else {
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        message = body['message']?.toString() ?? message;
      } catch (_) {}
    }

    throw Exception(message);
  }

  Future<Map<String, dynamic>> deleteExpense(int expenseId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/expenses/$expenseId/delete'),
        headers: await _headers(),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': body['message']};
      }

      return {'success': false, 'message': body['message'] ?? 'Không thể xóa'};
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../config/token_storage.dart';

class AddGroupExpenseDatasource {
  static final String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, dynamic>> fetchEvent(int eventId) async {
    try {
      final token = await TokenStorage.read();
      if (token == null) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': body['data'] as Map<String, dynamic>? ?? const {},
        };
      }
      return {'success': false, 'message': body['message'] ?? 'Lỗi tải sự kiện'};
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }

  Future<Map<String, dynamic>> fetchCategories() async {
    try {
      final token = await TokenStorage.read();
      if (token == null) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': (body['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>(),
        };
      }
      return {'success': false, 'message': body['message'] ?? 'Lỗi tải danh mục'};
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }

  Future<Map<String, dynamic>> createExpense({
    required int eventId,
    int? categoryId,
    required String title,
    required double amount,
    String currency = 'VND',
    String? description,
    String? expenseDate,
    String splitMethod = 'equal',
    List<int> payerIds = const [],
    List<Map<String, dynamic>> splits = const [],
  }) async {
    try {
      final token = await TokenStorage.read();
      if (token == null) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/expenses/create'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'event_id': eventId,
          'category_id': ?categoryId,
          'title': title,
          'amount': amount,
          'currency': currency,
          if (description != null && description.isNotEmpty)
            'description': description,
          'expense_date': ?expenseDate,
          'split_method': splitMethod,
          'payer_ids': payerIds,
          if (splits.isNotEmpty) 'splits': splits,
        }),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        return {'success': true, 'message': body['message'], 'data': body['data']};
      }

      String errorMsg = body['message'] ?? 'Dữ liệu không hợp lệ';
      if (body['errors'] != null) {
        final errors = body['errors'] as Map<String, dynamic>;
        errorMsg = errors.values.first[0];
      }
      return {'success': false, 'message': errorMsg};
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }
}
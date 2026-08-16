import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/expense_model.dart';
import '../../../config/api_config.dart';
import '../../../config/token_storage.dart';

class AddExpenseDatasource {
  static final String baseUrl = ApiConfig.baseUrl;

  static final List<ExpenseModel> _mockExpenses = [
    ExpenseModel(
      id: '1',
      title: 'Ăn trưa cùng đồng nghiệp',
      amount: 185000,
      currency: 'VND',
      description: 'Nhà hàng Nhật Bản',
      category: 'Ăn uống',
      date: '2026-07-29',
    ),
    ExpenseModel(
      id: '2',
      title: 'Grab đi làm',
      amount: 45000,
      currency: 'VND',
      description: 'Đi làm sáng',
      category: 'Di chuyển',
      date: '2026-07-29',
    ),
    ExpenseModel(
      id: '3',
      title: 'Cà phê sáng',
      amount: 35000,
      currency: 'VND',
      description: 'Highlands Cà phê',
      category: 'Ăn uống',
      date: '2026-07-28',
    ),
    ExpenseModel(
      id: '4',
      title: 'Mua sách',
      amount: 120000,
      currency: 'VND',
      description: 'Sách lập trình Flutter',
      category: 'Giáo dục',
      date: '2026-07-27',
    ),
    ExpenseModel(
      id: '5',
      title: 'Tiền điện tháng 7',
      amount: 350000,
      currency: 'VND',
      description: 'Hóa đơn tiền điện',
      category: 'Hóa đơn',
      date: '2026-07-25',
    ),
  ];

  List<ExpenseModel> getMockExpenses() => _mockExpenses;

  ExpenseModel? getMockExpenseById(String id) {
    try {
      return _mockExpenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  ExpenseModel addMockExpense(ExpenseModel expense) {
    final newExpense = expense.copyWith(
      id: (_mockExpenses.length + 1).toString(),
      date: DateTime.now().toIso8601String().split('T')[0],
    );
    _mockExpenses.insert(0, newExpense);
    return newExpense;
  }

  Future<Map<String, dynamic>> fetchEvents() async {
    try {
      final token = await TokenStorage.read();
      if (token == null) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/events'),
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
      return {'success': false, 'message': body['message'] ?? 'Lỗi tải sự kiện'};
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }

  Future<Map<String, dynamic>> createExpense({
    required int eventId,
    required String title,
    required double amount,
    String currency = 'VND',
    String? description,
    String? expenseDate,
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
          'title': title,
          'amount': amount,
          'currency': currency,
          if (description != null && description.isNotEmpty)
            'description': description,
          'expense_date': ?expenseDate,
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
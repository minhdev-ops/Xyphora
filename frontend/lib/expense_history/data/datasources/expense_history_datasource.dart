import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../config/token_storage.dart';
import '../../domain/models/expense_history_item.dart';

class ExpenseHistoryDatasource {
  static final String baseUrl = ApiConfig.baseUrl;

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.read();
    final auth = token == null ? null : 'Bearer $token';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': ?auth,
    };
  }

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
    final query = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
      'sort': sort,
      if (eventId != null) 'event_id': '$eventId',
      if (dateFrom != null) 'date_from': _formatDate(dateFrom),
      if (dateTo != null) 'date_to': _formatDate(dateTo),
      if (categoryId != null) 'category_id': '$categoryId',
      if (payerId != null) 'payer_id': '$payerId',
      if (search != null && search.isNotEmpty) 'search': search,
      'my_split_status': ?mySplitStatus,
    };

    final uri = Uri.parse('$baseUrl/expenses').replace(queryParameters: query);
    final response = await http.get(uri, headers: await _headers());

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Lỗi tải danh sách chi tiêu');
    }
    return ExpensePageResult.fromJson(body);
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final uri = Uri.parse('$baseUrl/categories');
    final response = await http.get(uri, headers: await _headers());

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Lỗi tải danh mục');
    }
    return (body['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchEvents() async {
    final uri = Uri.parse('$baseUrl/events');
    final response = await http.get(uri, headers: await _headers());

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Lỗi tải sự kiện');
    }
    return (body['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }
}
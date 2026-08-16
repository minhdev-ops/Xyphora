import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../config/token_storage.dart';
import '../../domain/models/category_stat_item.dart';

class CategoryListDatasource {
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

  Future<List<CategoryStatItem>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return (body['data'] as List<dynamic>? ?? [])
          .map((e) => CategoryStatItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    String message = 'Không thể tải danh mục';
    if (response.statusCode == 401) {
      message = 'Phiên đăng nhập đã hết hạn';
    } else {
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        message = body['message']?.toString() ?? message;
      } catch (_) {}
    }

    throw Exception(message);
  }
}
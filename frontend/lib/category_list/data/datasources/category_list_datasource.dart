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

    throw _parseError(response, 'Không thể tải danh mục');
  }

  Future<Map<String, dynamic>> createCategory({
    required String name,
    String? icon,
    String? color,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'icon': ?icon,
        'color': ?color,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw _parseError(response, 'Không thể tạo danh mục');
  }

  Future<Map<String, dynamic>> updateCategory({
    required int categoryId,
    required String name,
    String? icon,
    String? color,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/categories/$categoryId'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'icon': ?icon,
        'color': ?color,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw _parseError(response, 'Không thể cập nhật danh mục');
  }

  Future<void> deleteCategory(int categoryId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/categories/$categoryId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return;
    }

    throw _parseError(response, 'Không thể xóa danh mục');
  }

  Exception _parseError(http.Response response, String fallback) {
    String message = fallback;
    if (response.statusCode == 401) {
      message = 'Phiên đăng nhập đã hết hạn';
    } else {
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        message = body['message']?.toString() ?? message;
      } catch (_) {}
    }
    return Exception(message);
  }
}
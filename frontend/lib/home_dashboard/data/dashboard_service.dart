import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../config/token_storage.dart';

class DashboardService {
  static final String baseUrl = ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    final token = await TokenStorage.read();
    return token;
  }

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/home/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint('[Dashboard] status=${response.statusCode} body=${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': body['data']};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Phiên đăng nhập đã hết hạn'};
      } else {
        return {'success': false, 'message': 'Lỗi tải dữ liệu ${response.statusCode}'};
      }
    } catch (e) {
      debugPrint('[Dashboard] error: $e');
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }
}
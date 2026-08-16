import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/api_config.dart';

class DashboardService {
  static final String baseUrl = ApiConfig.baseUrl;
  static final _storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
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

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': body['data']};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Phiên đăng nhập đã hết hạn'};
      } else {
        return {'success': false, 'message': 'Lỗi tải dữ liệu'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }
}
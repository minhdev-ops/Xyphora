import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/api_config.dart';

class NotificationService {
  static String get baseUrl => ApiConfig.baseUrl;
  static final _storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> getNotifications({String? type}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      var url = '$baseUrl/notifications';
      if (type != null && type.isNotEmpty) {
        url += '?type=$type';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': 'Không thể tải thông báo'};
      }
    } catch (e) {
      debugPrint('Get notifications error: $e');
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }

  Future<Map<String, dynamic>> markAsRead(int notificationId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': 'Không thể cập nhật trạng thái thông báo'};
      }
    } catch (e) {
      debugPrint('Mark as read error: $e');
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }
}

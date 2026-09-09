import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/api_config.dart';

class ProfileService {
  static String get baseUrl => ApiConfig.baseUrl;
  static final _storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Không thể tải hồ sơ'};
      }
    } catch (e) {
      debugPrint('Get profile error: $e');
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }

  Future<void> logout() async {
    try {
      final token = await _getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        await _storage.delete(key: 'auth_token');
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({String? name, String? avatarPath}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      var uri = Uri.parse('$baseUrl/user/profile');
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (name != null && name.isNotEmpty) {
        request.fields['name'] = name;
      }

      if (avatarPath != null && avatarPath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('avatar', avatarPath));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': 'Không thể cập nhật hồ sơ'};
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }

  Future<Map<String, dynamic>> updateSettings({String? language, bool? notificationsEnabled}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      final body = <String, dynamic>{};
      if (language != null) body['language'] = language;
      if (notificationsEnabled != null) body['notifications_enabled'] = notificationsEnabled;

      final response = await http.put(
        Uri.parse('$baseUrl/user/settings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': 'Không thể cập nhật cài đặt'};
      }
    } catch (e) {
      debugPrint('Update settings error: $e');
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/api_config.dart';


class AuthService {
  static const String baseUrl = ApiConfig.baseUrl;
  static const _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Đăng ký thành công, lưu token
        await _saveToken(data['access_token']);
        return {'success': true, 'message': data['message']};
      } else if (response.statusCode == 422) {
        // Lỗi kiểm tra dữ liệu từ Laravel
        String errorMsg = data['message'] ?? 'Dữ liệu không hợp lệ';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          errorMsg = errors.values.first[0]; // Lấy câu báo lỗi chi tiết đầu tiên
        }
        return {'success': false, 'message': errorMsg};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Lỗi đăng ký'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveToken(data['access_token']);
        return {'success': true, 'message': data['message'] ?? 'Đăng nhập thành công'};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': data['message'] ?? 'Mật khẩu không đúng'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': data['message'] ?? 'Email chưa được đăng ký'};
      } else if (response.statusCode == 422) {
        String errorMsg = data['message'] ?? 'Dữ liệu không hợp lệ';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          errorMsg = errors.values.first[0];
        }
        return {'success': false, 'message': errorMsg};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Email hoặc mật khẩu không đúng'};
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }

  Future<void> _saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
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
      // Bỏ qua lỗi kết nối khi logout
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Mã OTP đã được gửi'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': data['message'] ?? 'Email chưa được đăng ký'};
      } else if (response.statusCode == 422) {
        String errorMsg = data['message'] ?? 'Dữ liệu không hợp lệ';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          errorMsg = errors.values.first[0];
        }
        return {'success': false, 'message': errorMsg};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Lỗi gửi mã OTP'};
      }
    } catch (e) {
      debugPrint('Forgot password error: $e');
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(
      String email, String otp, String password, String passwordConfirmation) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Đặt lại mật khẩu thành công'};
      } else if (response.statusCode == 400) {
        return {'success': false, 'message': data['message'] ?? 'Mã OTP không đúng hoặc đã hết hạn'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': data['message'] ?? 'Không tìm thấy tài khoản'};
      } else if (response.statusCode == 422) {
        String errorMsg = data['message'] ?? 'Dữ liệu không hợp lệ';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          errorMsg = errors.values.first[0];
        }
        return {'success': false, 'message': errorMsg};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Lỗi đặt lại mật khẩu'};
      }
    } catch (e) {
      debugPrint('Reset password error: $e');
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }
}

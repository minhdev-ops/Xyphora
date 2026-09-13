import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/auth/domain/models/user.dart';
import 'package:xyphora_frontend/config/backend_config.dart';
import 'package:xyphora_frontend/config/token_storage.dart';

@lazySingleton
class AuthService {
  final Dio _dio;
  final String baseUrl;

  AuthService() : _dio = Dio(), baseUrl = BackendConfig.baseUrl {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.read();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));
  }

  Options get _options => Options(
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  Future<void> _saveToken(String token) async {
    await TokenStorage.write(token);
  }

  Future<Map<String, dynamic>> _handleAuthResponse(
    Response response, {
    bool shouldSaveToken = false,
  }) async {
    final data = response.data as Map<String, dynamic>;
    final statusCode = response.statusCode ?? 0;

    if (statusCode >= 200 && statusCode < 300) {
      String? token;
      // Support both flat and nested response formats
      if (data['access_token'] != null) {
        token = data['access_token'] as String;
      } else if (data['data'] != null && data['data']['access_token'] != null) {
        token = data['data']['access_token'] as String;
      }

      if (shouldSaveToken && token != null) {
        await _saveToken(token);
      }

      return {
        'success': true,
        'message': data['message'] as String? ?? 'Thành công',
        'data': data['data'] ?? data,
      };
    } else {
      String message = data['message'] as String? ?? 'Lỗi không xác định';
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        message = errors.values.first[0] as String? ?? message;
      }
      return {
        'success': false,
        'message': message,
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await _dio.post(
      '$baseUrl/register',
      data: {'name': name, 'email': email, 'password': password},
      options: _options,
    );
    return _handleAuthResponse(response, shouldSaveToken: true);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      '$baseUrl/login',
      data: {'email': email, 'password': password},
      options: _options,
    );
    return _handleAuthResponse(response, shouldSaveToken: true);
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    final response = await _dio.post(
      '$baseUrl/auth/google',
      data: {'id_token': idToken},
      options: _options,
    );
    return _handleAuthResponse(response, shouldSaveToken: true);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _dio.post(
      '$baseUrl/forgot-password',
      data: {'email': email},
      options: _options,
    );
    return _handleAuthResponse(response);
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String password,
    String passwordConfirmation,
  ) async {
    final response = await _dio.post(
      '$baseUrl/reset-password',
      data: {
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      options: _options,
    );
    return _handleAuthResponse(response);
  }

  Future<void> logout() async {
    final token = await TokenStorage.read();
    if (token != null) {
      await _dio.post(
        '$baseUrl/logout',
        options: _options,
      );
      await TokenStorage.delete();
    }
  }

  Future<String?> getToken() async {
    return await TokenStorage.read();
  }

  Future<UserModel?> getCurrentUser() async {
    final response = await _dio.get(
      '$baseUrl/user',
      options: _options,
    );
    final data = response.data as Map<String, dynamic>;
    final userData = data['data'] as Map<String, dynamic>?;
    if (userData == null) return null;
    return UserModel(
      id: userData['id'].toString(),
      name: userData['name'] as String? ?? '',
      email: userData['email'] as String? ?? '',
      avatarUrl: userData['avatar'] as String?,
    );
  }
}
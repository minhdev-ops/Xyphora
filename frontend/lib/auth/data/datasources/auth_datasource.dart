import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/auth/data/services/auth_service.dart';
import 'package:xyphora_frontend/auth/domain/models/user.dart';
import 'package:xyphora_frontend/core/exceptions.dart';

@lazySingleton
class AuthDatasource {
  final AuthService _service;

  AuthDatasource(this._service);

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      return await _service.register(name, email, password);
    } catch (error) {
      _handleError(error);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      return await _service.login(email, password);
    } catch (error) {
      _handleError(error);
    }
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    try {
      return await _service.googleLogin(idToken);
    } catch (error) {
      _handleError(error);
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      return await _service.forgotPassword(email);
    } catch (error) {
      _handleError(error);
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      return await _service.resetPassword(email, otp, password, passwordConfirmation);
    } catch (error) {
      _handleError(error);
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      return await _service.getCurrentUser();
    } catch (error) {
      _handleError(error);
    }
  }

  Future<void> logout() async {
    try {
      await _service.logout();
    } catch (error) {
      _handleError(error);
    }
  }

  Future<String?> getToken() async {
    try {
      return await _service.getToken();
    } catch (error) {
      _handleError(error);
    }
  }

  Never _handleError(Object error) {
    if (error is ExceptionWithMessage) {
      throw error;
    } else if (error is DioException) {
      final data = error.response?.data;
      String? serverMessage;
      if (data is Map) {
        serverMessage = data['message']?.toString();
      }
      throw ExceptionWithMessage(mess: serverMessage ?? 'Lỗi kết nối máy chủ');
    } else {
      throw ExceptionWithMessage(mess: error.toString());
    }
  }
}
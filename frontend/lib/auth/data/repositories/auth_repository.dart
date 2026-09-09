import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/auth/data/datasources/auth_datasource.dart';
import 'package:xyphora_frontend/auth/domain/models/user.dart';

@lazySingleton
class AuthRepository {
  final AuthDatasource _datasource;

  AuthRepository(this._datasource);

  Future<Map<String, dynamic>> register(String name, String email, String password) {
    return _datasource.register(name, email, password);
  }

  Future<Map<String, dynamic>> login(String email, String password) {
    return _datasource.login(email, password);
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) {
    return _datasource.googleLogin(idToken);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) {
    return _datasource.forgotPassword(email);
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String password,
    String passwordConfirmation,
  ) {
    return _datasource.resetPassword(email, otp, password, passwordConfirmation);
  }

  Future<UserModel?> getCurrentUser() {
    return _datasource.getCurrentUser();
  }

  Future<void> logout() {
    return _datasource.logout();
  }

  Future<String?> getToken() {
    return _datasource.getToken();
  }
}
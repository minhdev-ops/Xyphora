import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/config/backend_config.dart';
import 'package:xyphora_frontend/config/token_storage.dart';

@lazySingleton
class ExpenseDetailService {
  final Dio _dio;
  final String baseUrl;

  ExpenseDetailService() : _dio = Dio(), baseUrl = BackendConfig.baseUrl {
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

  Future<Map<String, dynamic>> fetchExpenseDetail(int expenseId) async {
    final response = await _dio.get(
      '$baseUrl/expenses/$expenseId',
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteExpense(int expenseId) async {
    final response = await _dio.post(
      '$baseUrl/expenses/$expenseId/delete',
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }
}
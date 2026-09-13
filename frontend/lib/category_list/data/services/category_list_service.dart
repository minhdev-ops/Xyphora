import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/config/backend_config.dart';
import 'package:xyphora_frontend/config/token_storage.dart';

@lazySingleton
class CategoryListService {
  final Dio _dio;
  final String baseUrl;

  CategoryListService() : _dio = Dio(), baseUrl = BackendConfig.baseUrl {
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

  Future<Map<String, dynamic>> fetchCategories() async {
    final response = await _dio.get(
      '$baseUrl/categories',
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createCategory({
    required String name,
    String? icon,
    String? color,
  }) async {
    final response = await _dio.post(
      '$baseUrl/categories',
      data: {
        'name': name,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
      },
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCategory({
    required int categoryId,
    required String name,
    String? icon,
    String? color,
  }) async {
    final response = await _dio.put(
      '$baseUrl/categories/$categoryId',
      data: {
        'name': name,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
      },
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteCategory(int categoryId) async {
    await _dio.delete(
      '$baseUrl/categories/$categoryId',
      options: _options,
    );
  }
}
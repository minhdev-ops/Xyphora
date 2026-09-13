import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/config/backend_config.dart';
import 'package:xyphora_frontend/config/token_storage.dart';

@lazySingleton
class ExpenseHistoryService {
  final Dio _dio;
  final String baseUrl;

  ExpenseHistoryService() : _dio = Dio(), baseUrl = BackendConfig.baseUrl {
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>> fetchExpenses({
    int? eventId,
    int page = 1,
    int perPage = 15,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? categoryId,
    int? payerId,
    String? search,
    String? mySplitStatus,
    String sort = 'desc',
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'sort': sort,
      if (eventId != null) 'event_id': eventId,
      if (dateFrom != null) 'date_from': _formatDate(dateFrom),
      if (dateTo != null) 'date_to': _formatDate(dateTo),
      if (categoryId != null) 'category_id': categoryId,
      if (payerId != null) 'payer_id': payerId,
      if (search != null && search.isNotEmpty) 'search': search,
      if (mySplitStatus != null) 'my_split_status': mySplitStatus,
    };

    final response = await _dio.get(
      '$baseUrl/expenses',
      queryParameters: query,
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchCategories() async {
    final response = await _dio.get(
      '$baseUrl/categories',
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchEvents() async {
    final response = await _dio.get(
      '$baseUrl/events',
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }
}
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/config/backend_config.dart';
import 'package:xyphora_frontend/config/token_storage.dart';

@lazySingleton
class AddExpenseService {
  final Dio _dio;
  final String baseUrl;

  AddExpenseService() : _dio = Dio(), baseUrl = BackendConfig.baseUrl {
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

  Future<Map<String, dynamic>> fetchEvents() async {
    final response = await _dio.get(
      '$baseUrl/events',
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchEvent(int eventId) async {
    final response = await _dio.get(
      '$baseUrl/events/$eventId',
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> saveExpense({
    int? eventId,
    int? categoryId,
    required String title,
    required double amount,
    String currency = 'VND',
    String? description,
    String? expenseDate,
    String? splitMethod,
    List<int> payerIds = const [],
    List<Map<String, dynamic>> splits = const [],
  }) async {
    final response = await _dio.post(
      '$baseUrl/expenses/create',
      data: {
        if (eventId != null) 'event_id': eventId,
        if (categoryId != null) 'category_id': categoryId,
        'title': title,
        'amount': amount,
        'currency': currency,
        if (description != null && description.isNotEmpty) 'description': description,
        if (expenseDate != null) 'expense_date': expenseDate,
        if (eventId != null && splitMethod != null) 'split_method': splitMethod,
        if (eventId != null && payerIds.isNotEmpty) 'payer_ids': payerIds,
        if (eventId != null && splits.isNotEmpty) 'splits': splits,
      },
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateExpense({
    required int expenseId,
    int? eventId,
    int? categoryId,
    required String title,
    required double amount,
    String currency = 'VND',
    String? description,
    String? expenseDate,
    String? splitMethod,
    List<int> payerIds = const [],
    List<Map<String, dynamic>> splits = const [],
  }) async {
    final response = await _dio.post(
      '$baseUrl/expenses/$expenseId/update',
      data: {
        if (eventId != null) 'event_id': eventId,
        if (categoryId != null) 'category_id': categoryId,
        'title': title,
        'amount': amount,
        'currency': currency,
        if (description != null && description.isNotEmpty) 'description': description,
        if (expenseDate != null) 'expense_date': expenseDate,
        if (eventId != null && splitMethod != null) 'split_method': splitMethod,
        if (eventId != null && payerIds.isNotEmpty) 'payer_ids': payerIds,
        if (eventId != null && splits.isNotEmpty) 'splits': splits,
      },
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
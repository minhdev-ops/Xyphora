import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/category_list/data/services/category_list_service.dart';
import 'package:xyphora_frontend/category_list/domain/models/category_stat_item.dart';
import 'package:xyphora_frontend/core/exceptions.dart';

@lazySingleton
class CategoryListDatasource {
  final CategoryListService _service;

  CategoryListDatasource(this._service);

  Future<List<CategoryStatItem>> fetchCategories() async {
    try {
      final response = await _service.fetchCategories();
      final data = response['data'] as List<dynamic>? ?? [];
      return data.map((e) => CategoryStatItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (error) {
      _handleError(error);
    }
  }

  Future<Map<String, dynamic>> createCategory({
    required String name,
    String? icon,
    String? color,
  }) async {
    try {
      return await _service.createCategory(name: name, icon: icon, color: color);
    } catch (error) {
      _handleError(error);
    }
  }

  Future<Map<String, dynamic>> updateCategory({
    required int categoryId,
    required String name,
    String? icon,
    String? color,
  }) async {
    try {
      return await _service.updateCategory(
        categoryId: categoryId,
        name: name,
        icon: icon,
        color: color,
      );
    } catch (error) {
      _handleError(error);
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      await _service.deleteCategory(categoryId);
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
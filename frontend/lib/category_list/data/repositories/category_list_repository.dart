import '../datasources/category_list_datasource.dart';
import '../../domain/models/category_stat_item.dart';

class CategoryListRepository {
  final CategoryListDatasource _datasource = CategoryListDatasource();

  Future<List<CategoryStatItem>> fetchCategories() {
    return _datasource.fetchCategories();
  }

  Future<Map<String, dynamic>> createCategory({
    required String name,
    String? icon,
    String? color,
  }) {
    return _datasource.createCategory(name: name, icon: icon, color: color);
  }

  Future<Map<String, dynamic>> updateCategory({
    required int categoryId,
    required String name,
    String? icon,
    String? color,
  }) {
    return _datasource.updateCategory(
      categoryId: categoryId,
      name: name,
      icon: icon,
      color: color,
    );
  }

  Future<void> deleteCategory(int categoryId) {
    return _datasource.deleteCategory(categoryId);
  }
}
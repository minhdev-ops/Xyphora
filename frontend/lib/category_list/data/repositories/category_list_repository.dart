import '../datasources/category_list_datasource.dart';
import '../../domain/models/category_stat_item.dart';

class CategoryListRepository {
  final CategoryListDatasource _datasource = CategoryListDatasource();

  Future<List<CategoryStatItem>> fetchCategories() {
    return _datasource.fetchCategories();
  }
}
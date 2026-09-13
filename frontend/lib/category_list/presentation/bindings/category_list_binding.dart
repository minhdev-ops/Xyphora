import 'package:get/get.dart';
import 'package:xyphora_frontend/category_list/data/services/category_list_service.dart';
import 'package:xyphora_frontend/category_list/data/datasources/category_list_datasource.dart';
import 'package:xyphora_frontend/category_list/data/repositories/category_list_repository.dart';
import '../controllers/category_list_controller.dart';

class CategoryListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryListService>(() => CategoryListService());
    Get.lazyPut<CategoryListDatasource>(() => CategoryListDatasource(Get.find<CategoryListService>()));
    Get.lazyPut<CategoryListRepository>(() => CategoryListRepository(Get.find<CategoryListDatasource>()));
    Get.lazyPut<CategoryListController>(() => CategoryListController(Get.find<CategoryListRepository>()));
  }
}
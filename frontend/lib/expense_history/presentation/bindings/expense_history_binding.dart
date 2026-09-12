import 'package:get/get.dart';
import 'package:xyphora_frontend/expense_history/data/services/expense_history_service.dart';
import 'package:xyphora_frontend/expense_history/data/datasources/expense_history_datasource.dart';
import 'package:xyphora_frontend/expense_history/data/repositories/expense_history_repository.dart';
import '../controllers/expense_history_controller.dart';

class ExpenseHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpenseHistoryService>(() => ExpenseHistoryService());
    Get.lazyPut<ExpenseHistoryDatasource>(() => ExpenseHistoryDatasource(Get.find<ExpenseHistoryService>()));
    Get.lazyPut<ExpenseHistoryRepository>(() => ExpenseHistoryRepository(Get.find<ExpenseHistoryDatasource>()));
    Get.lazyPut<ExpenseHistoryController>(() => ExpenseHistoryController(Get.find<ExpenseHistoryRepository>()));
  }
}
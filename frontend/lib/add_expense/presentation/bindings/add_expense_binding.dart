import 'package:get/get.dart';
import 'package:xyphora_frontend/add_expense/data/services/add_expense_service.dart';
import 'package:xyphora_frontend/add_expense/data/datasources/add_expense_datasource.dart';
import 'package:xyphora_frontend/add_expense/data/repositories/add_expense_repository.dart';
import '../controllers/add_expense_controller.dart';

class AddExpenseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddExpenseService>(() => AddExpenseService());
    Get.lazyPut<AddExpenseDatasource>(() => AddExpenseDatasource(Get.find<AddExpenseService>()));
    Get.lazyPut<AddExpenseRepository>(() => AddExpenseRepository(Get.find<AddExpenseDatasource>()));
    Get.lazyPut<AddExpenseController>(() => AddExpenseController(Get.find<AddExpenseRepository>()));
  }
}
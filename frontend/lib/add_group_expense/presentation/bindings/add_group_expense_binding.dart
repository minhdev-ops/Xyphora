import 'package:get/get.dart';
import 'package:xyphora_frontend/add_expense/data/repositories/add_expense_repository.dart';
import '../controllers/add_group_expense_controller.dart';

class AddGroupExpenseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddGroupExpenseController>(
      () => AddGroupExpenseController(Get.find<AddExpenseRepository>()),
    );
  }
}
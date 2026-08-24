import 'package:get/get.dart';
import '../controllers/expense_history_controller.dart';

class ExpenseHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpenseHistoryController>(() => ExpenseHistoryController());
  }
}
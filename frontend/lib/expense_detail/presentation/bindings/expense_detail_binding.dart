import 'package:get/get.dart';
import '../controllers/expense_detail_controller.dart';

class ExpenseDetailBinding extends Bindings {
  final int expenseId;

  ExpenseDetailBinding(this.expenseId);

  @override
  void dependencies() {
    Get.lazyPut<ExpenseDetailController>(
      () => ExpenseDetailController(expenseId: expenseId),
    );
  }
}

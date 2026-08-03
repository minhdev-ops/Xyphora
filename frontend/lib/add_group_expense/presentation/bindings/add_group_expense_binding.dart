import 'package:get/get.dart';
import '../controllers/add_group_expense_controller.dart';

class AddGroupExpenseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddGroupExpenseController>(() => AddGroupExpenseController());
  }
}

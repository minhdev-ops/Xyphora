import 'package:get/get.dart';
import 'package:xyphora_frontend/expense_detail/data/services/expense_detail_service.dart';
import 'package:xyphora_frontend/expense_detail/data/datasources/expense_detail_datasource.dart';
import 'package:xyphora_frontend/expense_detail/data/repositories/expense_detail_repository.dart';
import '../controllers/expense_detail_controller.dart';

class ExpenseDetailBinding extends Bindings {
  final int expenseId;

  ExpenseDetailBinding(this.expenseId);

  @override
  void dependencies() {
    Get.lazyPut<ExpenseDetailService>(() => ExpenseDetailService());
    Get.lazyPut<ExpenseDetailDatasource>(() => ExpenseDetailDatasource(Get.find<ExpenseDetailService>()));
    Get.lazyPut<ExpenseDetailRepository>(() => ExpenseDetailRepository(Get.find<ExpenseDetailDatasource>()));
    Get.lazyPut<ExpenseDetailController>(
      () => ExpenseDetailController(Get.find<ExpenseDetailRepository>(), expenseId),
    );
  }
}
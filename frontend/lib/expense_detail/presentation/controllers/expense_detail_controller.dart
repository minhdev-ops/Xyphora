import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/repositories/expense_detail_repository.dart';
import '../../domain/models/expense_detail.dart';

class ExpenseDetailController extends GetxController {
  final ExpenseDetailRepository _repository = ExpenseDetailRepository();

  final int expenseId;

  ExpenseDetailController({required this.expenseId});

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final detail = Rxn<ExpenseDetail>();

  @override
  void onInit() {
    super.onInit();
    loadDetail();
  }

  Future<void> loadDetail() async {
    isLoading.value = true;
    errorMessage.value = null;
    update();

    try {
      final result = await _repository.fetchExpenseDetail(expenseId);
      debugPrint(
        '[ExpenseDetail] loaded expenseId=$expenseId splits=${result.splits.length}',
      );
      detail.value = result;
    } catch (e, st) {
      debugPrint('[ExpenseDetail] ERROR expenseId=$expenseId: $e\n$st');
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    }

    isLoading.value = false;
    update();
  }

  String formatCurrency(double amount) {
    final str = amount.abs().round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return '${buffer.toString()}đ';
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    final dt = DateTime.tryParse(date);
    if (dt == null) return date;
    return '${dt.day} tháng ${dt.month}, ${dt.year}';
  }
}

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:xyphora_frontend/statistics/data/repositories/statistics_repository.dart';
import 'package:xyphora_frontend/statistics/domain/models/statistics_model.dart';
import 'package:xyphora_frontend/core/exceptions.dart';

class StatisticsController extends GetxController {
  final StatisticsRepository _repository;

  StatisticsController(this._repository);

  final isLoading = false.obs;
  final totalExpense = 0.0.obs;
  final changeRate = 0.0.obs;
  final categoryStats = <CategoryStat>[].obs;
  final monthlyStats = <MonthlyStat>[].obs;
  final _monthlyTransactions = <String, List<TransactionItem>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    isLoading.value = true;
    try {
      final data = await _repository.fetchStatistics();
      totalExpense.value = data.totalExpense;
      changeRate.value = data.changeRate;
      categoryStats.assignAll(data.categoryStats);
      monthlyStats.assignAll(data.monthlyStats);
      _monthlyTransactions.assignAll(data.monthlyTransactions);
    } catch (e) {
      debugPrint('StatisticsController load error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<TransactionItem> transactionsOf(String monthLabel) =>
      _monthlyTransactions[monthLabel] ?? const [];

  String formatCurrency(double amount) {
    final digits = amount.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()}đ';
  }
}
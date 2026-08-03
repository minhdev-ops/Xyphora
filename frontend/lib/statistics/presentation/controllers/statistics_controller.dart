import 'package:get/get.dart';
import '../../data/repositories/statistics_repository.dart';
import '../../domain/models/statistics_model.dart';

class StatisticsController extends GetxController {
  final StatisticsRepository _repository = StatisticsRepository();

  double get totalExpense => _repository.getTotalExpense();

  double get changeRate => _repository.getChangeRate();

  List<CategoryStat> get categoryStats => _repository.getCategoryStats();

  List<MonthlyStat> get monthlyStats => _repository.getMonthlyStats();

  List<TransactionItem> transactionsOf(String monthLabel) =>
      _repository.getMonthlyTransactions(monthLabel);

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

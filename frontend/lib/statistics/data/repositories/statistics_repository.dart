import '../datasources/statistics_datasource.dart';
import '../../domain/models/statistics_model.dart';

class StatisticsRepository {
  final StatisticsDatasource _datasource = StatisticsDatasource();

  double getTotalExpense() => _datasource.getTotalExpense();

  double getChangeRate() => _datasource.getChangeRate();

  List<CategoryStat> getCategoryStats() => _datasource.getCategoryStats();

  List<MonthlyStat> getMonthlyStats() => _datasource.getMonthlyStats();

  List<TransactionItem> getMonthlyTransactions(String monthLabel) =>
      _datasource.getMonthlyTransactions(monthLabel);
}

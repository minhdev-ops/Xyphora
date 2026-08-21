import '../datasources/statistics_datasource.dart';

class StatisticsRepository {
  final StatisticsDatasource _datasource = StatisticsDatasource();

  Future<StatisticsData> fetchStatistics() {
    return _datasource.fetchStatistics();
  }
}

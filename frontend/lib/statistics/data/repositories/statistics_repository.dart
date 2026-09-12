import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/statistics/data/datasources/statistics_datasource.dart';
import 'package:xyphora_frontend/statistics/domain/models/statistics_model.dart';

@lazySingleton
class StatisticsRepository {
  final StatisticsDatasource _datasource;

  StatisticsRepository(this._datasource);

  Future<StatisticsData> fetchStatistics() {
    return _datasource.fetchStatistics();
  }
}
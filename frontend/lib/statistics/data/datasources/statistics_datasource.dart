import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/statistics/data/services/statistics_service.dart';
import 'package:xyphora_frontend/statistics/domain/models/statistics_model.dart';
import 'package:xyphora_frontend/core/exceptions.dart';

@lazySingleton
class StatisticsDatasource {
  final StatisticsService _service;

  StatisticsDatasource(this._service);

  Future<StatisticsData> fetchStatistics() async {
    try {
      final response = await _service.fetchStatistics();
      final data = response['data'] as Map<String, dynamic>? ?? {};

      final totalExpense = (data['totalExpense'] as num?)?.toDouble() ?? 0.0;
      final changeRate = (data['changeRate'] as num?)?.toDouble() ?? 0.0;

      final rawCategories = (data['categoryStats'] as List<dynamic>? ?? []);
      final categoryStats = rawCategories.map((c) {
        final map = c as Map<String, dynamic>;
        return CategoryStat(
          name: map['name'] as String? ?? 'Khác',
          amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
          color: (map['color'] as num?)?.toInt() ?? 0xFF64748B,
          percent: (map['percent'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      final rawMonthly = (data['monthlyStats'] as List<dynamic>? ?? []);
      final monthlyStats = rawMonthly.map((m) {
        final map = m as Map<String, dynamic>;
        return MonthlyStat(
          label: map['label'] as String? ?? '',
          value: (map['value'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      final rawTxMap = (data['monthlyTransactions'] as Map<String, dynamic>? ?? {});
      final monthlyTransactions = <String, List<TransactionItem>>{};
      rawTxMap.forEach((key, value) {
        final txList = (value as List<dynamic>? ?? []).map((t) {
          final map = t as Map<String, dynamic>;
          return TransactionItem(
            name: map['name'] as String? ?? '',
            categoryName: map['categoryName'] as String? ?? 'Khác',
            amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
            color: (map['color'] as num?)?.toInt() ?? 0xFF64748B,
          );
        }).toList();
        monthlyTransactions[key] = txList;
      });

      return StatisticsData(
        totalExpense: totalExpense,
        changeRate: changeRate,
        categoryStats: categoryStats,
        monthlyStats: monthlyStats,
        monthlyTransactions: monthlyTransactions,
      );
    } catch (error) {
      _handleError(error);
    }
  }

  Never _handleError(Object error) {
    if (error is ExceptionWithMessage) {
      throw error;
    } else if (error is DioException) {
      final data = error.response?.data;
      String? serverMessage;
      if (data is Map) {
        serverMessage = data['message']?.toString();
      }
      throw ExceptionWithMessage(mess: serverMessage ?? 'Lỗi kết nối máy chủ');
    } else {
      throw ExceptionWithMessage(mess: error.toString());
    }
  }
}
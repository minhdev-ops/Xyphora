import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../config/token_storage.dart';
import '../../domain/models/statistics_model.dart';

class StatisticsData {
  final double totalExpense;
  final double changeRate;
  final List<CategoryStat> categoryStats;
  final List<MonthlyStat> monthlyStats;
  final Map<String, List<TransactionItem>> monthlyTransactions;

  StatisticsData({
    required this.totalExpense,
    required this.changeRate,
    required this.categoryStats,
    required this.monthlyStats,
    required this.monthlyTransactions,
  });
}

class StatisticsDatasource {
  static final String baseUrl = ApiConfig.baseUrl;

  Future<StatisticsData> fetchStatistics() async {
    try {
      final token = await TokenStorage.read();
      if (token == null || token.isEmpty) {
        return _emptyData();
      }

      final response = await http.get(
        Uri.parse('$baseUrl/statistics/general'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        debugPrint('Statistics API error: ${response.statusCode}');
        return _emptyData();
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? {};

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
    } catch (e) {
      debugPrint('Error fetching statistics: $e');
      return _emptyData();
    }
  }

  StatisticsData _emptyData() {
    final monthlyStats = <MonthlyStat>[];
    final monthlyTxMap = <String, List<TransactionItem>>{};
    for (var i = 1; i <= 12; i++) {
      monthlyStats.add(MonthlyStat(label: 'T$i', value: 0.0));
      monthlyTxMap['T$i'] = [];
    }
    return StatisticsData(
      totalExpense: 0.0,
      changeRate: 0.0,
      categoryStats: const [],
      monthlyStats: monthlyStats,
      monthlyTransactions: monthlyTxMap,
    );
  }
}

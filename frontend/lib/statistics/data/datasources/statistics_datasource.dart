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
        Uri.parse('$baseUrl/expenses?per_page=100'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        return _emptyData();
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final rawItems =
          (body['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      final summary = body['summary'] as Map<String, dynamic>? ?? {};

      if (rawItems.isEmpty) {
        return _emptyData();
      }

      double total = (summary['my_total_amount'] as num?)?.toDouble() ??
          (summary['total_amount'] as num?)?.toDouble() ??
          0.0;

      if (total == 0.0) {
        total = rawItems.fold(
          0.0,
          (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0),
        );
      }

      final categoryTotals = <String, Map<String, dynamic>>{};
      final monthlyTotals = <int, double>{};
      final monthlyTxMap = <String, List<TransactionItem>>{};

      for (var i = 1; i <= 12; i++) {
        monthlyTotals[i] = 0.0;
        monthlyTxMap['T$i'] = [];
      }

      final colorPalette = [
        0xFF4CAF50,
        0xFF3B82F6,
        0xFF8B5CF6,
        0xFFF59E0B,
        0xFFEF4444,
        0xFF10B981,
        0xFFEC4899,
      ];
      int colorIdx = 0;

      for (final item in rawItems) {
        final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
        final catName = item['category_name'] as String? ?? 'Khác';
        final title = item['title'] as String? ?? 'Chi tiêu';
        final dateStr = item['expense_date'] as String?;

        if (!categoryTotals.containsKey(catName)) {
          categoryTotals[catName] = {
            'amount': 0.0,
            'color': colorPalette[colorIdx % colorPalette.length],
          };
          colorIdx++;
        }
        categoryTotals[catName]!['amount'] =
            (categoryTotals[catName]!['amount'] as double) + amount;

        if (dateStr != null) {
          final date = DateTime.tryParse(dateStr);
          if (date != null) {
            final m = date.month;
            monthlyTotals[m] = (monthlyTotals[m] ?? 0.0) + amount;
            final label = 'T$m';
            monthlyTxMap[label]?.add(
              TransactionItem(
                name: title,
                categoryName: catName,
                amount: amount,
                color: categoryTotals[catName]!['color'] as int,
              ),
            );
          }
        }
      }

      final categoryStats = <CategoryStat>[];
      categoryTotals.forEach((name, map) {
        final amt = map['amount'] as double;
        final pct = total > 0 ? ((amt / total) * 100).round() : 0;
        categoryStats.add(
          CategoryStat(
            name: name,
            amount: amt,
            color: map['color'] as int,
            percent: pct,
          ),
        );
      });

      final monthlyStats = <MonthlyStat>[];
      for (var i = 1; i <= 12; i++) {
        monthlyStats.add(
          MonthlyStat(
            label: 'T$i',
            value: monthlyTotals[i] ?? 0.0,
          ),
        );
      }

      return StatisticsData(
        totalExpense: total,
        changeRate: 0.0,
        categoryStats: categoryStats,
        monthlyStats: monthlyStats,
        monthlyTransactions: monthlyTxMap,
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

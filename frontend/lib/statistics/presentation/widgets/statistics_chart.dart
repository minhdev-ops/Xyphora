import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/statistics_model.dart';
import 'month_detail_card.dart';
import 'statistics_card_box.dart';

class DonutChartCard extends StatelessWidget {
  final List<CategoryStat> categories;

  const DonutChartCard({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return StatisticsCardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Theo danh mục",
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A4331),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 150,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        for (final category in categories)
                          PieChartSectionData(
                            value: category.amount,
                            color: Color(category.color),
                            radius: 42,
                            showTitle: false,
                          ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 26,
                      startDegreeOffset: -90,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final category in categories)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(category.color),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                category.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1A4331),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${category.percent}%',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A4331),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BarChartCard extends StatefulWidget {
  final List<MonthlyStat> monthlyStats;
  final String Function(double) formatCurrency;
  final List<TransactionItem> Function(String monthLabel) transactionsOf;

  const BarChartCard({
    super.key,
    required this.monthlyStats,
    required this.formatCurrency,
    required this.transactionsOf,
  });

  @override
  State<BarChartCard> createState() => _BarChartCardState();
}

class _BarChartCardState extends State<BarChartCard> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final monthlyStats = widget.monthlyStats;
    final maxValue = monthlyStats
        .map((stat) => stat.value)
        .reduce((a, b) => max(a, b));

    final selected = _selectedIndex;
    final selectedStat = (selected != null && selected < monthlyStats.length)
        ? monthlyStats[selected]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatisticsCardBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Chi tiêu theo tháng",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A4331),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Nhấn vào cột để xem chi tiết",
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8A8A8A),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: monthlyStats.length * 48,
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      maxY: maxValue * 1.2,
                      minY: 0,
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(
                        touchCallback: (event, response) {
                          if (event is! FlTapUpEvent) return;
                          final spot = response?.spot;
                          if (spot == null) return;
                          setState(() {
                            final tapped = spot.touchedBarGroupIndex;
                            _selectedIndex = (_selectedIndex == tapped)
                                ? null
                                : tapped;
                          });
                        },
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => Colors.transparent,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                              null,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= monthlyStats.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  monthlyStats[index].label,
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF5A7563),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        for (var i = 0; i < monthlyStats.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: monthlyStats[i].value,
                                width: 22,
                                borderRadius: BorderRadius.circular(6),
                                color: const Color(0xFF34A853),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (selectedStat != null) ...[
          const SizedBox(height: 16),
          MonthDetailCard(
            monthLabel: selectedStat.label,
            transactions: widget.transactionsOf(selectedStat.label),
            formatCurrency: widget.formatCurrency,
            onClose: () => setState(() => _selectedIndex = null),
          ),
        ],
      ],
    );
  }
}

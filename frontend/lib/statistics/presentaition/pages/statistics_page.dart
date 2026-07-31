import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/statistics_controller.dart';
import '../widgets/statistics_header.dart';
import '../widgets/statistics_summary_card.dart';
import '../widgets/statistics_chart.dart';
import '../../../home_dashboard/presentation/widgets/custom_bottom_nav_bar.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final StatisticsController controller = Get.find<StatisticsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      body: SafeArea(
        child: Column(
          children: [
            const StatisticsHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SummaryCard(
                      totalText: controller.formatCurrency(
                        controller.totalExpense,
                      ),
                      changeText:
                          '↑ ${controller.changeRate.toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 16),
                    DonutChartCard(categories: controller.categoryStats),
                    const SizedBox(height: 16),
                    BarChartCard(
                      monthlyStats: controller.monthlyStats,
                      formatCurrency: controller.formatCurrency,
                      transactionsOf: controller.transactionsOf,
                    ),
                    const SizedBox(height: 16),
                    CategoryDetailCard(
                      categories: controller.categoryStats,
                      totalExpense: controller.totalExpense,
                      formatCurrency: controller.formatCurrency,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 1),
    );
  }
}

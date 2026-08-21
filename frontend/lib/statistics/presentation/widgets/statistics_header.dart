import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/app_theme.dart';
import '../../../expense_history/presentation/bindings/expense_history_binding.dart';
import '../../../expense_history/presentation/pages/expense_history_page.dart';
import '../../../home_dashboard/presentation/pages/home_dashboard_page.dart';

class StatisticsHeader extends StatelessWidget {
  const StatisticsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.offAll(
                () => const HomeDashboardPage(),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 300),
              ),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Thống kê",
              style: AppTextStyles.amountMedium,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Get.to(
                () => const ExpenseHistoryPage(),
                binding: ExpenseHistoryBinding(),
              ),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
                  color: Color(0xFFF2F7F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: Color(0xFF1D1D1D),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Thống kê",
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1D1D1D),
              ),
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
                decoration: const BoxDecoration(
                  color: Color(0xFFF4FAF6),
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(
                      color: Color(0xFF0C3D2B),
                      width: 1.2,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 20,
                  color: Color(0xFF0C3D2B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/expense_history_controller.dart';

class ExpenseHistorySummary extends GetView<ExpenseHistoryController> {
  const ExpenseHistorySummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF0C3D2B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${controller.totalCount.value} khoản chi tiêu',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SummaryColumn(
                    label: 'Tổng chi tiêu',
                    value: controller.formatCurrency(controller.totalAmount.value),
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: VerticalDivider(
                    color: Colors.white.withValues(alpha: 0.2),
                    thickness: 1,
                  ),
                ),
                Expanded(
                  child: _SummaryColumn(
                    label: 'Phần của tôi',
                    value: controller.formatCurrency(
                      controller.myTotalAmount.value,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
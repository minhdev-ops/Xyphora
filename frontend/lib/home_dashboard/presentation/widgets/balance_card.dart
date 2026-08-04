import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  String _formatCurrency(double amount, {bool showSign = false}) {
    final isNegative = amount < 0;
    final absAmount = amount.abs().toInt();
    final str = absAmount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    final prefix = showSign ? (isNegative ? '-' : '+') : '';
    return '$prefix${buffer.toString()}đ';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (controller) {
      final total = controller.totalBalance.value;
      final toYou = controller.debtToYou.value;
      final youOwe = controller.yourDebt.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE2F0E5), // Light green-tinted card background
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFCBE0D1), // Subtle border
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng số dư của bạn',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5A7563),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatCurrency(total, showSign: true),
              style: GoogleFonts.nunito(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0C3D2B), // Bold forest green color
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Left Column: Người nợ bạn
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Người nợ bạn',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5A7563),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(toYou),
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0C3D2B), // Green text
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider
                Container(
                  height: 36,
                  width: 1,
                  color: const Color(0xFFCBE0D1),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                // Right Column: Bạn nợ người
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bạn nợ người',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5A7563),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(youOwe),
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFD32F2F), // Red text
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
      },
    );
  }
}

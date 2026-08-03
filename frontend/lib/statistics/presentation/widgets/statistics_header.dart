import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FAF6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF0C3D2B).withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                "Tháng 7/2026",
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0C3D2B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

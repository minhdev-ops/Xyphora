import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../controllers/add_group_expense_controller.dart';

class GroupExpenseHeader extends StatelessWidget {
  const GroupExpenseHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AddGroupExpenseController controller =
        Get.find<AddGroupExpenseController>();

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                controller.clearAll();
                Navigator.pop(context);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F7F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 24,
                  color: Color(0xFF424242),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Thêm Chi Tiêu",
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1D1D1D),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => controller.saveExpense(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C3D2B),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                "Lưu",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

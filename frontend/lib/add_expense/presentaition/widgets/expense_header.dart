import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../controllers/add_expense_controller.dart';

class ExpenseHeader extends StatelessWidget {
  const ExpenseHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AddExpenseController controller = Get.find<AddExpenseController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  controller.clearAll();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2F0E5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 24,
                    color: Color(0xFF0C3D2B),
                  ),
                ),
              ),
            ),
          ),
          Text(
            "Thêm Chi Tiêu",
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1D1D1D),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
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
            ),
          ),
        ],
      ),
    );
  }
}

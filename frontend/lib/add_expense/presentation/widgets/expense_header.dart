import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/app_theme.dart';
import '../controllers/add_expense_controller.dart';

class ExpenseHeader extends GetView<AddExpenseController> {
  const ExpenseHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 24,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Thêm chi tiêu",
                    style: AppTextStyles.amountMedium,
                  ),
                  if (controller.eventTitle.value != null)
                    Text(
                      controller.eventTitle.value!,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: controller.isSaving.value
                  ? null
                  : () => controller.saveExpense(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Obx(
                () => controller.isSaving.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        "Lưu",
                        style: AppTextStyles.buttonPrimary,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

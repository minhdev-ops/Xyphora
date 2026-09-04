import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../add_expense/domain/models/expense_model.dart';
import '../../../add_expense/presentation/pages/edit_expense_page.dart';
import '../../../add_expense/data/datasources/add_expense_datasource.dart';
import '../../../config/app_theme.dart';
import '../../../config/app_format.dart';
import '../../domain/models/spending_model.dart';
import '../controllers/dashboard_controller.dart';

class SpendingDetailPage extends GetView<DashboardController> {
  final SpendingModel spending;

  const SpendingDetailPage({super.key, required this.spending});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ),
        ),
        title: Text(
          'Chi tiet chi tieu',
          style: AppTextStyles.titleLarge,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Get.snackbar('Tùy chọn', 'Chức năng đang được phát triển');
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Green Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.divider,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        spending.icon,
                        color: spending.themeColor,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      spending.title,
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppFormat.currency(spending.amount),
                      style: AppTextStyles.amountLarge,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        spending.category,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Info Detail Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: AppRadius.rXl,
                  boxShadow: AppShadow.cardSoft,
                ),
                child: Column(
                  children: [
                    // Row 1: Ngày
                    _buildDetailRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'NGÀY',
                      value: spending.date,
                    ),
                    const Divider(
                      height: 24,
                      color: AppColors.divider,
                      thickness: 1,
                    ),
                    _buildDetailRow(
                      icon: Icons.wallet_giftcard_outlined,
                      label: 'PHƯƠNG THỨC',
                      value: spending.paymentMethod,
                    ),
                    const Divider(
                      height: 24,
                      color: AppColors.divider,
                      thickness: 1,
                    ),
                    _buildDetailRow(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'GHI CHÚ',
                      value: spending.note.isNotEmpty
                          ? spending.note
                          : 'Không có ghi chú',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Action Buttons
              GestureDetector(
                onTap: () async {
                  final result = await Get.to<ExpenseModel>(
                    () => const EditExpensePage(),
                    arguments: {
                      'id': '${spending.expenseId}',
                      'title': spending.title,
                      'amount': spending.amount,
                      'currency': 'VND',
                      'category': spending.category,
                      'paymentMethod': spending.paymentMethod,
                      'note': spending.note,
                      'date': spending.date,
                      'event_id': spending.eventId,
                    },
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                  );
                  if (result != null) {
                    controller.loadDashboardData();
                    Get.back();
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.edit_note_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Chỉnh sửa chi tiêu',
                        style: AppTextStyles.title,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Get.defaultDialog(
                    title: 'Xóa chi tiêu',
                    middleText: 'Bạn có chắc chắn muốn xóa khoản chi tiêu này?',
                    textCancel: 'Hủy',
                    textConfirm: 'Xóa',
                    confirmTextColor: Colors.white,
                    buttonColor: AppColors.error,
                    onConfirm: () async {
                      final datasource = AddExpenseDatasource();
                      final result = await datasource.deleteExpense(spending.expenseId);
                      if (result['success'] == true) {
                        controller.spendings.removeWhere((s) =>
                          s.expenseId == spending.expenseId
                        );
                        controller.monthlySpendingTotal.value -= spending.amount;
                        controller.spendingCount.value = controller.spendings.length;
                        Get.back();
                        Get.back();
                        Get.snackbar(
                          'Thành công',
                          'Đã xóa khoản chi tiêu',
                          backgroundColor: AppColors.error.withValues(alpha: 0.8),
                          colorText: Colors.white,
                        );
                      } else {
                        Get.back();
                        Get.snackbar(
                          'Lỗi',
                          result['message'] ?? 'Không thể xóa',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      }
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.errorBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.errorBorder,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Xóa chi tiêu',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.inputBg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: AppColors.textSecondary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.small,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.titleMedium,
            ),
          ],
        ),
      ],
    );
  }
}

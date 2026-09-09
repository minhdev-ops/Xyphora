import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/app_theme.dart';
import '../../../config/app_format.dart';
import '../../../config/category_icons.dart';
import '../../../expense_detail/presentation/bindings/expense_detail_binding.dart';
import '../../../expense_detail/presentation/pages/expense_detail_page.dart';
import '../../domain/models/expense_model.dart';
import '../controllers/event_controller.dart';

class ExpensesTab extends GetView<EventController> {
  const ExpensesTab({super.key});

  static const Map<String, String> _fallbackEmojis = {
    'Khách sạn 2 đêm': '🏨',
    'Cà phê sáng': '☕',
    'Ăn tối tại BBQ': '🍖',
    'Vé tham quan': '🎫',
    'Xăng xe': '⛽',
  };

  String _emojiFor(String title) => _fallbackEmojis[title] ?? '💳';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => _SummarySection(
          myTotal: controller.myTotalExpense,
          totalExpense: controller.totalExpense,
        )),
        const SizedBox(height: 20),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingExpenses.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (controller.hasExpensesError.value) {
              return _ErrorState(
                message: controller.expensesErrorMessage.value,
                onRetry: controller.loadExpenses,
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: controller.loadExpenses,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 200) {
                    controller.loadMoreExpenses();
                  }
                  return false;
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    for (final group in controller.expenseGroups) ...[
                      Text(
                        group.formattedDate,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final expense in group.expenses)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ExpenseItemView(
                            expense: expense,
                            controller: controller,
                            emojiFor: _emojiFor,
                          ),
                        ),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ExpenseItemView extends StatelessWidget {
  final ExpenseModel expense;
  final EventController controller;
  final String Function(String) emojiFor;

  const _ExpenseItemView({
    required this.expense,
    required this.controller,
    required this.emojiFor,
  });

  @override
  Widget build(BuildContext context) {
    final icon = controller.categoryIconFor(expense.id);
    final color = categoryColorFor(icon);

    return GestureDetector(
      onTap: () {
        final expenseId = int.tryParse(expense.id) ?? 0;
        Get.to(
          () => ExpenseDetailPage(expenseId: expenseId),
          binding: ExpenseDetailBinding(expenseId),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: AppRadius.rLg,
          boxShadow: AppShadow.card,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: icon != null
                    ? color.withValues(alpha: 0.12)
                    : AppColors.inputBg,
                borderRadius: AppRadius.rSm,
              ),
              alignment: Alignment.center,
              child: icon != null
                  ? Icon(categoryIconFor(icon), size: 22, color: color)
                  : Text(
                      emojiFor(expense.title),
                      style: const TextStyle(fontSize: 20),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Trả bởi ${controller.payerName(expense.payerId)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Text(
              AppFormat.currency(expense.amount),
              style: AppTextStyles.amountSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final double myTotal;
  final double totalExpense;

  const _SummarySection({
    required this.myTotal,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: AppRadius.rLg,
          boxShadow: AppShadow.card,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Chi tiêu của tôi',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppFormat.currency(myTotal),
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: VerticalDivider(
                color: AppColors.borderLight,
                thickness: 1,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Tổng chi tiêu',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppFormat.currency(totalExpense),
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 44,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Thử lại',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/category_icons.dart';
import '../../../expense_detail/presentation/bindings/expense_detail_binding.dart';
import '../../../expense_detail/presentation/pages/expense_detail_page.dart';
import '../../domain/models/expense_model.dart';
import '../controllers/event_detail_controller.dart';

class ExpensesTab extends GetView<EventDetailController> {
  const ExpensesTab({super.key});

  String _formatVND(double amount) {
    final str = amount.abs().toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return '${buf.toString()}đ';
  }

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
        _SummarySection(
          myTotal: controller.myTotalExpense.value,
          totalExpense: controller.totalExpense.value,
          formatVND: _formatVND,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingExpenses.value) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0A4226)),
              );
            }

            if (controller.hasExpensesError.value) {
              return _ErrorState(
                message: controller.expensesErrorMessage.value,
                onRetry: controller.loadExpenses,
              );
            }

            return RefreshIndicator(
              color: const Color(0xFF0A4226),
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A4226),
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final expense in group.expenses)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ExpenseItemView(
                            expense: expense,
                            controller: controller,
                            formatVND: _formatVND,
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
  final EventDetailController controller;
  final String Function(double) formatVND;
  final String Function(String) emojiFor;

  const _ExpenseItemView({
    required this.expense,
    required this.controller,
    required this.formatVND,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: icon != null
                    ? color.withValues(alpha: 0.12)
                    : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12),
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Paid by ${controller.payerName(expense.payerId)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatVND(expense.amount),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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
  final String Function(double) formatVND;

  const _SummarySection({
    required this.myTotal,
    required this.totalExpense,
    required this.formatVND,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'Chi tiêu của tôi',
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatVND(myTotal),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A4226),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: VerticalDivider(
                color: Colors.grey.withValues(alpha: 0.2),
                thickness: 1,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'Tổng chi tiêu',
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatVND(totalExpense),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A4226),
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
            color: Color(0xFFB8CFC0),
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
                color: const Color(0xFF5A7563),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A4226),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  static const _expenseEmojis = {
    'Khách sạn 2 đêm': '🏨',
    'Cà phê sáng': '☕',
    'Ăn tối tại BBQ': '🍖',
    'Vé tham quan': '🎫',
    'Xăng xe': '⛽',
  };

  String _emojiFor(String title) => _expenseEmojis[title] ?? '💳';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummarySection(
          myTotal: controller.myTotalExpense,
          totalExpense: controller.totalExpense,
          formatVND: _formatVND,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
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
                    child: ExpenseItem(
                      emoji: _emojiFor(expense.title),
                      title: expense.title,
                      subtitle: 'Paid by ${controller.payerName(expense.payerId)}',
                      amount: expense.amount,
                      formatVND: _formatVND,
                    ),
                  ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
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
                    style: TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 12,
                    ),
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
                    style: TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 12,
                    ),
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

class ExpenseItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final double amount;
  final String Function(double) formatVND;

  const ExpenseItem({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.formatVND,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatVND(amount),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_detail_controller.dart';

class BalancesTab extends GetView<EventDetailController> {
  const BalancesTab({super.key});

  String _formatVND(double amount) {
    final str = amount.abs().toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return '${buf.toString()}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _StatusCard(
            totalOwed: controller.totalOwed,
            formatVND: _formatVND,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0A4226),
                side: const BorderSide(color: Color(0xFF0A4226)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Xem tất cả gợi ý thanh toán',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Số dư',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A4226),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: controller.balances
                  .map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BalanceItem(
                          name: b.name,
                          amount: b.amount,
                          formatVND: _formatVND,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final double totalOwed;
  final String Function(double) formatVND;

  const _StatusCard({
    required this.totalOwed,
    required this.formatVND,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          const Text('🤑', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bạn được nhận ${formatVND(totalOwed)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B9B5A),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Xem ai cần trả tiền cho bạn',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E), size: 20),
        ],
      ),
    );
  }
}

class BalanceItem extends StatelessWidget {
  final String name;
  final double amount;
  final String Function(double) formatVND;

  const BalanceItem({
    super.key,
    required this.name,
    required this.amount,
    required this.formatVND,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = amount >= 0;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final color = isPositive ? const Color(0xFF1B9B5A) : const Color(0xFFFF3B30);
    final sign = isPositive ? '+' : '-';
    final displayAmount = formatVND(amount);

    return Container(
      padding: const EdgeInsets.all(16),
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
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFF0F0F0),
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF555555),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            '$sign$displayAmount',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

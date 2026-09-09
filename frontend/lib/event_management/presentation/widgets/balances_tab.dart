import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/app_theme.dart';
import '../../../config/app_format.dart';
import '../controllers/event_controller.dart';

class BalancesTab extends GetView<EventController> {
  const BalancesTab({super.key});

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
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.rPill,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Xem tất cả gợi ý thanh toán',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Số dư',
            style: AppTextStyles.title,
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

  const _StatusCard({
    required this.totalOwed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.rLg,
        boxShadow: AppShadow.card,
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
                  'Bạn được nhận ${AppFormat.currency(totalOwed)}',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Xem ai cần trả tiền cho bạn',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }
}

class BalanceItem extends StatelessWidget {
  final String name;
  final double amount;

  const BalanceItem({
    super.key,
    required this.name,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = amount >= 0;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final color = isPositive ? AppColors.success : AppColors.error;
    final sign = isPositive ? '+' : '-';
    final displayAmount = AppFormat.currency(amount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.rLg,
        boxShadow: AppShadow.card,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.inputBg,
            child: Text(
              initial,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.titleMedium,
            ),
          ),
          Text(
            '$sign$displayAmount',
            style: GoogleFonts.nunito(
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
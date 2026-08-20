import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/category_icons.dart';
import '../../../expense_detail/presentation/bindings/expense_detail_binding.dart';
import '../../../expense_detail/presentation/pages/expense_detail_page.dart';
import '../../domain/models/expense_history_item.dart';

class ExpenseHistoryItemCard extends StatelessWidget {
  final ExpenseHistoryItem item;

  const ExpenseHistoryItemCard({
    super.key,
    required this.item,
  });

  String _formatAmount(double amount, String currency) {
    final digits = amount.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }
    final symbol = switch (currency) {
      'USD' => '\$',
      'EUR' => '€',
      'JPY' => '¥',
      _ => 'đ',
    };
    return '${buffer.toString()}$symbol';
  }

  String _splitMethodLabel(String method) {
    return switch (method) {
      'percentage' => 'Theo %',
      'exact' => 'Theo tiền',
      'share' => 'Theo phần',
      _ => 'Chia đều',
    };
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = categoryColorFor(item.categoryColor);

    final isPersonal = item.eventTitle == null;
    final subtitle = isPersonal
        ? 'Cá nhân · Bạn trả'
        : item.payerName == null
            ? '${item.eventTitle} · Nhiều người trả'
            : '${item.eventTitle} · ${item.payerName} trả';

    return GestureDetector(
      onTap: () => Get.to(
        () => ExpenseDetailPage(expenseId: item.expenseId),
        binding: ExpenseDetailBinding(item.expenseId),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      ),
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
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                categoryIconFor(item.categoryIcon),
                size: 22,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A4331),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8A8A8A),
                    ),
                  ),
                  if (!isPersonal && item.splitCount > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${item.splitCount} người · ${_splitMethodLabel(item.splitMethod)}',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
                  ],
                  if (item.isMyDebt || item.isPaid) ...[
                    const SizedBox(height: 4),
                    _StatusBadge(item: item),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatAmount(item.amount, item.currency),
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A4331),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.categoryName ?? 'Khác',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ExpenseHistoryItem item;

  const _StatusBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.isMyDebt) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE8D9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Bạn nợ ${item.payerName ?? ''}',
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFE8590C),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F0E5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Đã thanh toán',
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0C3D2B),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/category_icons.dart';
import '../../domain/models/expense_history_item.dart';

class ExpenseHistoryItemCard extends StatelessWidget {
  final ExpenseHistoryItem item;
  final String Function(double) formatCurrency;

  const ExpenseHistoryItemCard({
    super.key,
    required this.item,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = categoryColorFor(item.categoryColor);
    final payerName = item.payerName ?? 'Ai đó';

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
                  item.eventTitle == null
                      ? '$payerName trả'
                      : '${item.eventTitle} · $payerName trả',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8A8A8A),
                  ),
                ),
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
                formatCurrency(item.amount),
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
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ],
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
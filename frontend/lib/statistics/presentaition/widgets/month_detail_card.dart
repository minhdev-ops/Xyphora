import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/statistics_model.dart';
import 'statistics_card_box.dart';

class MonthDetailCard extends StatelessWidget {
  final String monthLabel;
  final List<TransactionItem> transactions;
  final String Function(double) formatCurrency;
  final VoidCallback onClose;

  const MonthDetailCard({
    super.key,
    required this.monthLabel,
    required this.transactions,
    required this.formatCurrency,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final total = transactions.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    return StatisticsCardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chi tiết tháng $monthLabel',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A4331),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${transactions.length} khoản · ${formatCurrency(total)}',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8A8A8A),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2F0E5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Color(0xFF1A4331),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < transactions.length; i++) ...[
            TransactionItemWidget(
              item: transactions[i],
              formatCurrency: formatCurrency,
            ),
            if (i < transactions.length - 1)
              Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          ],
          const SizedBox(height: 8),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A4331),
                ),
              ),
              Text(
                formatCurrency(total),
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A4331),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionItemWidget extends StatelessWidget {
  final TransactionItem item;
  final String Function(double) formatCurrency;

  const TransactionItemWidget({
    super.key,
    required this.item,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFE2F0E5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(item.color),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A4331),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8A8A8A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatCurrency(item.amount),
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A4331),
            ),
          ),
        ],
      ),
    );
  }
}

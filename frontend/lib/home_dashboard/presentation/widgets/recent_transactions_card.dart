import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/transaction_model.dart';

class RecentTransactionsCard extends StatelessWidget {
  const RecentTransactionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      TransactionModel(
        title: 'Đi chợ',
        subtitle: 'Cá nhân',
        amount: '-\$85.20',
        type: TransactionType.shopping,
      ),
      TransactionModel(
        title: 'Tiệc Pizza',
        subtitle: 'Nhóm',
        amount: '-\$120.00',
        extraInfo: 'Bạn nợ \$40.00',
        type: TransactionType.dining,
      ),
      TransactionModel(
        title: 'Tiền điện',
        subtitle: 'Chung cư',
        amount: '-\$64.50',
        type: TransactionType.utility,
      ),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giao dịch gần đây',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D1D1D),
                ),
              ),
              Text(
                'Xem tất cả',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F5C43),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List.generate(transactions.length * 2 - 1, (index) {
              if (index.isOdd) {
                return Divider(
                  height: 1,
                  indent: 72,
                  endIndent: 20,
                  color: const Color(0xFFE8E8E8).withValues(alpha: 0.5),
                );
              }
              return _buildTransactionItem(transactions[index ~/ 2]);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          _buildIcon(tx.type),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1D1D1D),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${tx.subtitle} • ${_getDateLabel(tx.type)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8A8A8A),
                      ),
                    ),
                    if (tx.extraInfo != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        tx.extraInfo!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0F5C43),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            tx.amount,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1D1D1D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(TransactionType type) {
    IconData iconData;
    Color bgColor;
    Color iconColor;

    switch (type) {
      case TransactionType.shopping:
        iconData = Icons.shopping_cart_outlined;
        bgColor = const Color(0xFFE8F5E9);
        iconColor = const Color(0xFF2C7A58);
        break;
      case TransactionType.dining:
        iconData = Icons.diamond_outlined;
        bgColor = const Color(0xFFE3F2FD);
        iconColor = const Color(0xFF1976D2);
        break;
      case TransactionType.utility:
        iconData = Icons.flash_on_outlined;
        bgColor = const Color(0xFFF1F8E9);
        iconColor = const Color(0xFF0F5C43);
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  String _getDateLabel(TransactionType type) {
    switch (type) {
      case TransactionType.shopping:
        return 'Hôm nay';
      case TransactionType.dining:
        return 'Hôm qua';
      case TransactionType.utility:
        return '12 tháng 5';
    }
  }
}

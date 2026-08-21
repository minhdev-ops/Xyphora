import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/app_theme.dart';
import '../../../config/app_format.dart';
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
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: AppRadius.rSm,
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
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
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
                  AppFormat.currency(item.amount, currencyCode: item.currency),
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
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
          color: AppColors.warningBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Bạn nợ ${item.payerName ?? ''}',
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.warning,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Đã thanh toán',
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
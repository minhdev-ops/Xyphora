import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.rXl,
        boxShadow: AppShadow.cardSoft,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              borderRadius: AppRadius.rSm,
            ),
            child: const Icon(
              Icons.list_alt_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Quan ly danh muc',
              style: AppTextStyles.titleMedium,
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 22,
          ),
        ],
      ),
    );
  }
}

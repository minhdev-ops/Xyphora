import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../config/category_icons.dart';
import '../controllers/add_group_expense_controller.dart';

class GroupExpenseDetail extends GetView<AddGroupExpenseController> {
  const GroupExpenseDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('DANH MỤC'),
          const SizedBox(height: 8),
          _buildCategorySelector(),
          const SizedBox(height: 16),
          _sectionTitle('NGÀY'),
          const SizedBox(height: 8),
          _buildDateSelector(context),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: const Color(0xFF1A4331),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Obx(() {
      if (controller.isLoadingCategories.value) {
        return const SizedBox(
          height: 44,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF0C3D2B),
              ),
            ),
          ),
        );
      }

      return Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE2F0E5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButton<int>(
          value: controller.selectedCategoryId.value ?? 0,
          isExpanded: true,
          isDense: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF0C3D2B),
          ),
          items: [
            ...controller.categories.map(
              (category) => DropdownMenuItem<int>(
                value: (category['category_id'] as num).toInt(),
                child: Row(
                  children: [
                    Icon(
                      categoryIconFor(category['icon']?.toString()),
                      size: 18,
                      color: categoryColorFor(category['color']?.toString()),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category['name']?.toString() ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF0C3D2B),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          onChanged: controller.selectCategory,
        ),
      );
    });
  }

  Widget _buildDateSelector(BuildContext context) {
    return Obx(() {
      final date = controller.selectedDate.value;
      return GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            helpText: 'Chọn ngày chi tiêu',
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF0C3D2B),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            controller.selectDate(picked);
          }
        },
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE2F0E5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: Color(0xFF0C3D2B),
              ),
              const SizedBox(width: 10),
              Text(
                '${date.day} tháng ${date.month}, ${date.year}',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0C3D2B),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: Color(0xFF0C3D2B),
              ),
            ],
          ),
        ),
      );
    });
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../config/category_icons.dart';
import '../controllers/add_expense_controller.dart';

class ExpenseCard extends StatelessWidget {
  final AddExpenseController controller;
  final GlobalKey chipKey;

  const ExpenseCard({
    super.key,
    required this.controller,
    required this.chipKey,
  });

  static const double _chipHeight = 44;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: controller.toggleCurrencyPicker,
                child: Container(
                  key: chipKey,
                  height: _chipHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F0E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => Text(
                          controller.selectedCurrency.value,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: const Color(0xFF0C3D2B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: Color(0xFF0C3D2B),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: controller.showKeypad,
                  child: Obx(
                    () => Container(
                      height: _chipHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F0E5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          width: 1.5,
                          color: controller.isKeypadVisible.value
                              ? const Color(0xFF0C3D2B).withValues(alpha: 0.35)
                              : const Color(0xFF0C3D2B).withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Obx(
                                () => Text(
                                  controller.expression.value.isEmpty
                                      ? '0'
                                      : controller.expression.value,
                                  style: GoogleFonts.nunito(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: controller.expression.value.isEmpty
                                        ? const Color(0xFF5A7563)
                                        : const Color(0xFF0C3D2B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Su kien selector
          Text(
            'Sự kiện',
            style: GoogleFonts.nunito(
              color: const Color(0xFF5A7563),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.isLoadingEvents.value) {
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
                value: controller.events.any(
                  (e) =>
                      (e['event_id'] as num).toInt() ==
                      controller.selectedEventId.value,
                )
                    ? controller.selectedEventId.value
                    : -1,
                isExpanded: true,
                isDense: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF0C3D2B),
                ),
                items: [
                  DropdownMenuItem<int>(
                    value: -1,
                    child: Text(
                      'Không có sự kiện',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF5A7563),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...controller.events.map(
                    (event) => DropdownMenuItem<int>(
                      value: (event['event_id'] as num).toInt(),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.event_rounded,
                            size: 18,
                            color: Color(0xFF0C3D2B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event['title']?.toString() ?? '',
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
                onChanged: controller.selectEvent,
              ),
            );
          }),
          const SizedBox(height: 16),
          // Ngay chi tieu
          Text(
            'Ngày',
            style: GoogleFonts.nunito(
              color: const Color(0xFF5A7563),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final date = controller.selectedDate.value;
            return GestureDetector(
              onTap: () async {
                controller.hideKeypad();
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
          }),
          const SizedBox(height: 16),
          // Danh muc selector
          Text(
            'Danh mục',
            style: GoogleFonts.nunito(
              color: const Color(0xFF5A7563),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
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
                value: controller.categories.any(
                  (category) =>
                      (category['category_id'] as num).toInt() ==
                      controller.selectedCategoryId.value,
                )
                    ? controller.selectedCategoryId.value
                    : null,
                isExpanded: true,
                isDense: true,
                hint: Text(
                  'Chọn danh mục',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF5A7563),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF0C3D2B),
                ),
                items: [
                  ...controller.categories
                      .map(
                        (category) => DropdownMenuItem<int>(
                          value: (category['category_id'] as num).toInt(),
                          child: Row(
                            children: [
                              Icon(
                                categoryIconFor(
                                  category['icon']?.toString(),
                                ),
                                size: 18,
                                color: categoryColorFor(
                                  category['color']?.toString(),
                                ),
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
          }),
          const SizedBox(height: 16),
          TextField(
            controller: controller.descriptionController,
            onTap: controller.hideKeypad,
            onChanged: (value) => controller.updateDescription(value),
            minLines: 1,
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: "Mô tả khoản chi tiêu...",
              hintStyle: GoogleFonts.nunito(
                color: const Color(0xFF5A7563),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: const Color(0xFFE2F0E5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

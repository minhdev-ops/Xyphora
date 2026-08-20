import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/category_icons.dart';
import '../controllers/expense_history_controller.dart';

class ExpenseHistoryFilterBar extends GetView<ExpenseHistoryController> {
  const ExpenseHistoryFilterBar({super.key});

  Widget _dropdownShell({required Widget child}) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F0E5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _dropdownShell(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: controller.events.any(
                        (e) =>
                            (e['event_id'] as num).toInt() ==
                            controller.selectedEventId.value,
                      )
                          ? controller.selectedEventId.value
                          : null,
                      isExpanded: true,
                      isDense: true,
                      hint: Text(
                        'Tất cả sự kiện',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF5A7563),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF0C3D2B),
                      ),
                      items: controller.events
                          .map(
                            (e) => DropdownMenuItem<int>(
                              value: (e['event_id'] as num).toInt(),
                              child: Text(
                                e['title']?.toString() ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(
                                  color: const Color(0xFF0C3D2B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: controller.events.isEmpty
                          ? null
                          : controller.selectEvent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dropdownShell(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.months.any(
                        (m) => m['value'] == controller.selectedMonth.value,
                      )
                          ? controller.selectedMonth.value
                          : null,
                      isExpanded: true,
                      isDense: true,
                      hint: Text(
                        'Tất cả tháng',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF5A7563),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF0C3D2B),
                      ),
                      items: controller.months
                          .map(
                            (m) => DropdownMenuItem<String>(
                              value: m['value'],
                              child: Text(
                                m['label'] ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(
                                  color: const Color(0xFF0C3D2B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: controller.selectMonth,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: Color(0xFF9E9E9E),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller.searchController,
                        textInputAction: TextInputAction.search,
                        onChanged: controller.onSearchChanged,
                        onSubmitted: (_) => controller.applySearch(),
                        style: GoogleFonts.nunito(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm chi tiêu...',
                          hintStyle: GoogleFonts.nunito(
                            color: const Color(0xFF9E9E9E),
                            fontSize: 13,
                          ),
                          isDense: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Obx(
                      () => controller.searchQuery.value.isNotEmpty
                          ? GestureDetector(
                              onTap: controller.clearSearch,
                              child: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Color(0xFF9E9E9E),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Obx(
              () => GestureDetector(
                onTap: () => controller.toggleOnlyMyDebt(
                  !controller.onlyMyDebt.value,
                ),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: controller.onlyMyDebt.value
                        ? const Color(0xFF0C3D2B)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: controller.onlyMyDebt.value
                        ? null
                        : Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.volunteer_activism_rounded,
                        size: 18,
                        color: controller.onlyMyDebt.value
                            ? Colors.white
                            : const Color(0xFF0C3D2B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Nợ của tôi',
                        style: GoogleFonts.nunito(
                          color: controller.onlyMyDebt.value
                              ? Colors.white
                              : const Color(0xFF0C3D2B),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(
          () => controller.categories.isEmpty
              ? const SizedBox.shrink()
              : SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = controller.categories[index];
                      final id = (category['category_id'] as num).toInt();
                      final isActive =
                          controller.selectedCategoryId.value == id;
                      final categoryColor = categoryColorFor(
                        category['color']?.toString(),
                      );
                      return GestureDetector(
                        onTap: () => controller.selectCategory(
                          isActive ? null : id,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isActive ? categoryColor : Colors.white,
                            borderRadius: BorderRadius.circular(50),
                            border: isActive
                                ? null
                                : Border.all(color: const Color(0xFFD0D0D0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                categoryIconFor(
                                  category['icon']?.toString(),
                                ),
                                size: 15,
                                color: isActive
                                    ? Colors.white
                                    : categoryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                category['name']?.toString() ?? '',
                                style: GoogleFonts.nunito(
                                  color: isActive
                                      ? Colors.white
                                      : const Color(0xFF555555),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
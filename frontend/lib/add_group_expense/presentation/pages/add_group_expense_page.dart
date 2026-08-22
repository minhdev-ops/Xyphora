import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/add_group_expense_controller.dart';

/// Trang thêm chi tiêu nhóm – mở từ EventDetailView FAB.
/// Dùng lại các widget của add_expense nhưng bind với AddGroupExpenseController.
class GroupExpensePage extends GetView<AddGroupExpenseController> {
  GroupExpensePage({super.key});

  late final GlobalKey _chipKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      body: SafeArea(
        child: Builder(
          builder: (ctx) => Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  controller.hideCurrencyPicker();
                  controller.hideKeypad();
                },
                child: Column(
                  children: [
                    // ── Header ──────────────────────────────────────────────
                    _GroupExpenseHeader(controller: controller),
                    // ── Body ────────────────────────────────────────────────
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (_) {
                          controller.hideCurrencyPicker();
                          return false;
                        },
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: _GroupExpenseCard(
                                  controller: controller,
                                  chipKey: _chipKey,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Payers + split section
                              Obx(() {
                                if (controller.isLoadingMembers.value) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF0A4226),
                                    ),
                                  );
                                }
                                if (controller.members.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: _PayersSection(controller: controller),
                                );
                              }),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // ── Keypad ───────────────────────────────────────────────
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {},
                      child: Obx(
                        () => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: controller.isKeypadVisible.value
                              ? const _InlineKeypad(key: ValueKey('kp'))
                              : const SizedBox.shrink(key: ValueKey('no-kp')),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // ── Currency picker overlay ───────────────────────────────────
              Obx(() {
                if (!controller.isCurrencyPickerVisible.value) {
                  return const SizedBox.shrink();
                }
                final stackBox = ctx.findRenderObject() as RenderBox?;
                final chipBox =
                    _chipKey.currentContext?.findRenderObject() as RenderBox?;
                if (stackBox == null || chipBox == null) {
                  return const SizedBox.shrink();
                }
                final chipTL = chipBox.localToGlobal(Offset.zero);
                final stackTL = stackBox.localToGlobal(Offset.zero);
                return Positioned(
                  top: chipTL.dy - stackTL.dy + chipBox.size.height + 8,
                  left: chipTL.dx - stackTL.dx,
                  child: _CurrencyPicker(controller: controller),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────────────

class _GroupExpenseHeader extends StatelessWidget {
  final AddGroupExpenseController controller;
  const _GroupExpenseHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                controller.clearAll();
                Get.back();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 24,
                  color: Color(0xFF637074),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thêm chi tiêu nhóm',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0A4226),
                        ),
                      ),
                      if (controller.eventTitle.value != null)
                        Text(
                          controller.eventTitle.value!,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: const Color(0xFF637074),
                          ),
                        ),
                    ],
                  )),
            ),
            Obx(() => ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A4226),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Lưu',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Expense Card (amount + desc + date) ────────────────────────────────────

class _GroupExpenseCard extends StatelessWidget {
  final AddGroupExpenseController controller;
  final GlobalKey chipKey;
  const _GroupExpenseCard(
      {required this.controller, required this.chipKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount display
          Obx(() => GestureDetector(
                onTap: controller.showKeypad,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Currency chip
                    GestureDetector(
                      key: chipKey,
                      onTap: controller.toggleCurrencyPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              controller.selectedCurrency.value,
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0A4226),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down,
                                size: 16, color: Color(0xFF0A4226)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.expression.value.isEmpty
                            ? '0'
                            : controller.expression.value,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.nunito(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0A4226),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          // Description
          TextField(
            controller: controller.descriptionController,
            onChanged: controller.updateDescription,
            decoration: InputDecoration(
              hintText: 'Mô tả chi tiêu...',
              hintStyle: GoogleFonts.nunito(
                color: const Color(0xFFB0BEC5),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF0A4226)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // Date picker
          Obx(() => GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDate.value,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF0A4226),
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) controller.selectDate(picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4FAF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: Color(0xFF0A4226)),
                      const SizedBox(width: 10),
                      Text(
                        '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0A4226),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Payers Section ──────────────────────────────────────────────────────────

class _PayersSection extends StatelessWidget {
  final AddGroupExpenseController controller;
  const _PayersSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Người trả',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0A4226),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.members.map((m) {
                  final selected = controller.selectedPayers.contains(m.id);
                  return GestureDetector(
                    onTap: () => controller.togglePayer(m.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF0A4226)
                            : const Color(0xFFF4FAF6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF0A4226)
                              : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Text(
                        m.name,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF0A4226),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 20),
          Text(
            'Cách chia',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0A4226),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Row(
                children: AddGroupExpenseController.splitOptions.map((opt) {
                  final active = controller.selectedSplitMode.value == opt.$1;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.selectSplitMode(opt.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF0A4226)
                              : const Color(0xFFF4FAF6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: active
                                ? const Color(0xFF0A4226)
                                : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: Text(
                          opt.$2,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: active
                                ? Colors.white
                                : const Color(0xFF0A4226),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }
}

// ─── Inline Keypad ───────────────────────────────────────────────────────────

class _InlineKeypad extends StatelessWidget {
  const _InlineKeypad({super.key});

  static const _keys = [
    ['7', '8', '9', '÷'],
    ['4', '5', '6', '×'],
    ['1', '2', '3', '-'],
    ['C', '0', '⌫', '+'],
    ['•', '', '=', ''],
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddGroupExpenseController>();
    return Container(
      color: const Color(0xFFF4FAF6),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: _keys.map((row) {
          return Row(
            children: row.map((key) {
              if (key.isEmpty) return const Expanded(child: SizedBox());
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: GestureDetector(
                    onTap: () => controller.onKeyPressed(key),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: '÷×-+C⌫='.contains(key)
                            ? const Color(0xFFE8F5E9)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          key,
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: '÷×-+C⌫='.contains(key)
                                ? const Color(0xFF0A4226)
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Currency picker overlay ──────────────────────────────────────────────

class _CurrencyPicker extends StatelessWidget {
  final AddGroupExpenseController controller;
  const _CurrencyPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: controller.sortedCurrencies.map((currency) {
          final active = currency == controller.selectedCurrency.value;
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => controller.selectCurrency(currency),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Text(
                    currency,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.w500,
                      color: active
                          ? const Color(0xFF0C3D2B)
                          : Colors.black.withValues(alpha: 0.55),
                    ),
                  ),
                  if (active) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_rounded,
                        size: 18, color: Color(0xFF0C3D2B)),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

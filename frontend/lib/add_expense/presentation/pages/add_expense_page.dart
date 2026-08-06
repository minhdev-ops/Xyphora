import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/add_expense_controller.dart';
import '../widgets/expense_header.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_calculator.dart';
import '../widgets/receipt_attachment.dart';

class ExpensePage extends GetView<AddExpenseController> {
  ExpensePage({super.key});

  late final GlobalKey _chipKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return Stack(
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
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            controller.hideCurrencyPicker();
                            return false;
                          },
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const ExpenseHeader(),
                                const SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: ExpenseCard(
                                    controller: controller,
                                    chipKey: _chipKey,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: ReceiptAttachment(),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {},
                        child: Obx(
                          () => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: controller.isKeypadVisible.value
                                ? const Padding(
                                    key: ValueKey('keypad'),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: ExpenseCalculator(),
                                  )
                                : const SizedBox.shrink(
                                    key: ValueKey('no-keypad'),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Obx(() {
                  final visible = controller.isCurrencyPickerVisible.value;
                  if (!visible) {
                    return const SizedBox.shrink();
                  }

                  final RenderBox? stackBox =
                      context.findRenderObject() as RenderBox?;
                  final RenderBox? chipBox =
                      _chipKey.currentContext
                          ?.findRenderObject() as RenderBox?;
                  if (stackBox == null || chipBox == null) {
                    return const SizedBox.shrink();
                  }

                  final Offset chipTopLeft = chipBox.localToGlobal(Offset.zero);
                  final Offset stackTopLeft = stackBox.localToGlobal(
                    Offset.zero,
                  );

                  return Positioned(
                    top:
                        chipTopLeft.dy -
                        stackTopLeft.dy +
                        chipBox.size.height +
                        8,
                    left: chipTopLeft.dx - stackTopLeft.dx,
                    child: _buildCurrencyPicker(),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrencyPicker() {
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
        children: [
          for (final currency in controller.sortedCurrencies)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => controller.selectCurrency(currency),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Text(
                      currency,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight:
                            currency == controller.selectedCurrency.value
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: currency == controller.selectedCurrency.value
                            ? const Color(0xFF0C3D2B)
                            : Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                    if (currency == controller.selectedCurrency.value) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: Color(0xFF0C3D2B),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

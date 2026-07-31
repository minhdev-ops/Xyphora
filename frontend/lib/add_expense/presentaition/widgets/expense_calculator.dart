import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/add_expense_controller.dart';
import 'expense_keypad_button.dart';

const double _keyGap = 6;

class ExpenseCalculator extends StatelessWidget {
  const ExpenseCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    final AddExpenseController controller = Get.find<AddExpenseController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = (constraints.maxWidth - _keyGap * 3) / 4;
        final rowHeight = cellWidth / 1.15 + _keyGap;

        return Column(
          children: [
            _buildRow(controller, ["C", "⌫", "÷", "×"], rowHeight),
            _buildRow(controller, ["7", "8", "9", "-"], rowHeight),
            _buildRow(controller, ["4", "5", "6", "+"], rowHeight),
            _buildRow(controller, ["1", "2", "3", "•"], rowHeight),
            _buildBottomRow(controller, rowHeight),
          ],
        );
      },
    );
  }

  Widget _buildRow(
    AddExpenseController controller,
    List<String> keys,
    double height,
  ) {
    return SizedBox(
      height: height,
      child: Row(
        children: keys.map((text) {
          bool isAction = ["C", "⌫", "÷", "×", "-", "+"].contains(text);
          bool isPrimary = text == "=";

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(_keyGap),
              child: ExpenseKeypadButton(
                text: text,
                isPrimary: isPrimary,
                isAction: isAction,
                onTap: () => controller.onKeyPressed(text),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomRow(AddExpenseController controller, double height) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(_keyGap),
              child: ExpenseKeypadButton(
                text: "0",
                onTap: () => controller.onKeyPressed("0"),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(_keyGap),
              child: ExpenseKeypadButton(
                text: "000",
                onTap: () => controller.onKeyPressed("000"),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(_keyGap),
              child: ExpenseKeypadButton(
                text: "=",
                isPrimary: true,
                onTap: () => controller.onKeyPressed("="),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/add_group_expense_controller.dart';
import 'group_expense_keypad_button.dart';

const double _keyGap = 6;

class GroupExpenseCalculator extends GetView<AddGroupExpenseController> {
  const GroupExpenseCalculator({super.key});

  @override
  Widget build(BuildContext context) {
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
    AddGroupExpenseController controller,
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
              child: GroupExpenseKeypadButton(
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

  Widget _buildBottomRow(AddGroupExpenseController controller, double height) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(_keyGap),
              child: GroupExpenseKeypadButton(
                text: "0",
                onTap: () => controller.onKeyPressed("0"),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(_keyGap),
              child: GroupExpenseKeypadButton(
                text: "000",
                onTap: () => controller.onKeyPressed("000"),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(_keyGap),
              child: GroupExpenseKeypadButton(
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

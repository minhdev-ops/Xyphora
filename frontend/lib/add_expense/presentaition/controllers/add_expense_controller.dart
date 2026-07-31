import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../data/repositories/add_expense_repository.dart';
import '../../domain/models/expense_model.dart';

class AddExpenseController extends GetxController {
  final AddExpenseRepository _repository = AddExpenseRepository();

  static const int maxExpressionLength = 12;
  static const List<String> currencies = ['VND', 'USD', 'EUR', 'JPY'];

  final amount = 0.0.obs;
  final expression = ''.obs;
  final description = ''.obs;
  final selectedCurrency = 'VND'.obs;
  final isKeypadVisible = false.obs;
  final isCurrencyPickerVisible = false.obs;

  List<String> get sortedCurrencies => [
    selectedCurrency.value,
    ...currencies.where((c) => c != selectedCurrency.value),
  ];

  final TextEditingController descriptionController = TextEditingController();

  List<ExpenseModel> get mockExpenses => _repository.getMockExpenses();

  void onKeyPressed(String key) {
    HapticFeedback.lightImpact();
    hideCurrencyPicker();
    switch (key) {
      case 'C':
        _clearExpression();
        break;
      case '⌫':
        _handleBackspace();
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
        if (expression.value.length < maxExpressionLength) {
          _handleOperator(key);
        }
        break;
      case '•':
        if (expression.value.length < maxExpressionLength &&
            !expression.value.contains('•')) {
          expression.value += '•';
        }
        break;
      case '=':
        _calculateResult();
        break;
      default:
        if (expression.value.length < maxExpressionLength) {
          expression.value += key;
        }
    }
  }

  void _handleBackspace() {
    if (expression.value.isNotEmpty) {
      expression.value = expression.value.substring(
        0,
        expression.value.length - 1,
      );
    }
  }

  void _handleOperator(String op) {
    if (expression.value.isEmpty) return;
    final lastChar = expression.value[expression.value.length - 1];
    if ('+-×÷'.contains(lastChar)) {
      expression.value =
          expression.value.substring(0, expression.value.length - 1) + op;
    } else {
      expression.value += op;
    }
  }

  void _clearExpression() {
    expression.value = '';
    amount.value = 0.0;
  }

  void _calculateResult() {
    if (expression.value.isEmpty) return;
    try {
      final result = _evaluateExpression(expression.value);
      if (!result.isFinite) {
        throw const FormatException();
      }
      amount.value = result;
      expression.value = result.toStringAsFixed(0);
    } catch (_) {
      Get.snackbar(
        'Lỗi',
        'Biểu thức không hợp lệ',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  double _evaluateExpression(String expr) {
    String sanitized = expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('•', '.');

    final List<String> tokens = [];
    String currentNum = '';

    for (int i = 0; i < sanitized.length; i++) {
      final char = sanitized[i];
      if ('0123456789.'.contains(char)) {
        currentNum += char;
      } else if ('+-*/'.contains(char)) {
        if (currentNum.isNotEmpty) {
          tokens.add(currentNum);
          currentNum = '';
        }
        tokens.add(char);
      }
    }
    if (currentNum.isNotEmpty) tokens.add(currentNum);

    if (tokens.isEmpty) return 0;

    List<String> pass1 = [tokens[0]];
    for (int i = 1; i < tokens.length - 1; i += 2) {
      final op = tokens[i];
      final next = tokens[i + 1];
      if (op == '*' || op == '/') {
        final last = double.parse(pass1.removeLast());
        final nextNum = double.parse(next);
        pass1.add(
          op == '*' ? (last * nextNum).toString() : (last / nextNum).toString(),
        );
      } else {
        pass1.add(op);
        pass1.add(next);
      }
    }

    double result = double.parse(pass1[0]);
    for (int i = 1; i < pass1.length - 1; i += 2) {
      final op = pass1[i];
      final next = double.parse(pass1[i + 1]);
      if (op == '+') {
        result += next;
      } else if (op == '-') {
        result -= next;
      }
    }

    return result;
  }

  void saveExpense() {
    if (amount.value <= 0 && expression.value.isNotEmpty) {
      _calculateResult();
    }

    if (amount.value <= 0) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập số tiền hợp lệ',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final expense = ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: description.value.isEmpty ? 'Chi tiêu mới' : description.value,
      amount: amount.value,
      currency: selectedCurrency.value,
      description: description.value,
      date: DateTime.now().toIso8601String().split('T')[0],
    );

    _repository.addMockExpense(expense);

    Get.back(result: expense);
    Get.snackbar(
      'Thành công',
      'Đã thêm chi tiêu',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void updateDescription(String value) {
    description.value = value;
  }

  void showKeypad() {
    FocusManager.instance.primaryFocus?.unfocus();
    hideCurrencyPicker();
    isKeypadVisible.value = true;
  }

  void hideKeypad() {
    hideCurrencyPicker();
    isKeypadVisible.value = false;
  }

  void toggleCurrencyPicker() {
    FocusManager.instance.primaryFocus?.unfocus();
    hideKeypad();
    isCurrencyPickerVisible.toggle();
  }

  void hideCurrencyPicker() {
    isCurrencyPickerVisible.value = false;
  }

  void selectCurrency(String value) {
    selectedCurrency.value = value;
    isCurrencyPickerVisible.value = false;
    hideKeypad();
  }

  void clearAll() {
    amount.value = 0.0;
    expression.value = '';
    description.value = '';
    descriptionController.clear();
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }
}

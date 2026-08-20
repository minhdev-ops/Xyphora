import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../data/repositories/add_group_expense_repository.dart';
import '../../domain/models/group_expense_model.dart';

class AddGroupExpenseController extends GetxController {
  final AddGroupExpenseRepository _repository = AddGroupExpenseRepository();

  static const int maxExpressionLength = 12;
  static const List<String> currencies = ['VND', 'USD', 'EUR', 'JPY'];
  static const List<(String, String)> splitOptions = [
    ('equal', 'Chia đều'),
    ('percent', 'Theo %'),
    ('amount', 'Theo tiền'),
  ];

  int? eventId;
  String? eventTitle;

  final amount = 0.0.obs;
  final expression = ''.obs;
  final description = ''.obs;
  final selectedCurrency = 'VND'.obs;
  final selectedDate = DateTime.now().obs;
  final isKeypadVisible = false.obs;
  final isCurrencyPickerVisible = false.obs;
  final selectedPayers = <String>[].obs;
  final selectedSplitMode = 'equal'.obs;
  final isSaving = false.obs;
  final isLoadingMembers = false.obs;
  final isLoadingCategories = false.obs;

  final members = <GroupMember>[].obs;
  final categories = <Map<String, dynamic>>[].obs;
  final selectedCategoryId = RxnInt();

  final Map<String, TextEditingController> _splitControllers = {};

  List<String> get sortedCurrencies => [
    selectedCurrency.value,
    ...currencies.where((c) => c != selectedCurrency.value),
  ];

  final TextEditingController descriptionController = TextEditingController();

  TextEditingController splitControllerFor(String memberId) {
    return _splitControllers.putIfAbsent(
      memberId,
      () => TextEditingController(),
    );
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      eventId = args['event_id'] is int ? args['event_id'] as int : int.tryParse('${args['event_id']}');
      eventTitle = args['event_title']?.toString();
    }
    loadMembers();
    loadCategories();
  }

  Future<void> loadMembers() async {
    final id = eventId;
    if (id == null) return;

    isLoadingMembers.value = true;
    update();

    final result = await _repository.fetchEvent(id);

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>? ?? const {};
      final participants = (data['participants'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      members.assignAll(participants.map(GroupMember.fromParticipant).toList());

      // Mac dinh nguoi tra = nguoi dang dang nhap (is_me), neu khong co thi nguoi dau tien
      final me = members.firstWhereOrNull((m) => m.isMe);
      selectedPayers.assignAll([(me ?? members.firstOrNull)?.id].whereType<String>());
    } else {
      Get.snackbar(
        'Lỗi',
        result['message'] ?? 'Không thể tải danh sách thành viên',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }

    isLoadingMembers.value = false;
    update();
  }

  Future<void> loadCategories() async {
    isLoadingCategories.value = true;
    update();

    final result = await _repository.fetchCategories();

    if (result['success'] == true) {
      categories.assignAll(result['data'] as List<Map<String, dynamic>>);
      if (selectedCategoryId.value == null && categories.isNotEmpty) {
        selectedCategoryId.value =
            (categories.first['category_id'] as num).toInt();
      }
    } else {
      Get.snackbar(
        'Lỗi',
        result['message'] ?? 'Không thể tải danh sách danh mục',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }

    isLoadingCategories.value = false;
    update();
  }

  void selectCategory(int? categoryId) {
    selectedCategoryId.value = (categoryId == null || categoryId == 0)
        ? null
        : categoryId;
    update();
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    update();
  }

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
          final remaining = maxExpressionLength - expression.value.length;
          expression.value += key.length > remaining
              ? key.substring(0, remaining)
              : key;
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

  void togglePayer(String memberId) {
    HapticFeedback.lightImpact();
    hideCurrencyPicker();
    if (selectedPayers.contains(memberId)) {
      selectedPayers.remove(memberId);
    } else {
      selectedPayers.add(memberId);
    }
  }

  void selectSplitMode(String mode) {
    HapticFeedback.lightImpact();
    selectedSplitMode.value = mode;
    _autofillSplitValues();
  }

  void _autofillSplitValues() {
    if (members.isEmpty) return;

    final mode = selectedSplitMode.value;
    if (mode == 'equal') return;

    final count = members.length;
    final base = mode == 'percent' ? 100.0 / count : amount.value / count;

    for (final member in members) {
      splitControllerFor(member.id).text = _fmtNum(base);
    }
  }

  String _fmtNum(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(2);
  }

  List<Map<String, dynamic>> _buildSplitPayload() {
    final mode = selectedSplitMode.value;
    if (mode == 'equal' || members.isEmpty) return const [];

    final splits = <Map<String, dynamic>>[];

    if (mode == 'percent') {
      for (final member in members) {
        final value = double.tryParse(
          splitControllerFor(member.id).text.replaceAll(',', '.'),
        );
        if (value == null || value < 0) return const [];
        splits.add({
          'participant_id': int.parse(member.id),
          'percentage': value,
        });
      }
    } else {
      for (final member in members) {
        final value = double.tryParse(
          splitControllerFor(member.id).text.replaceAll(',', '.'),
        );
        if (value == null || value < 0) return const [];
        splits.add({
          'participant_id': int.parse(member.id),
          'amount': value,
        });
      }
    }

    return splits;
  }

  bool _validateSplits() {
    final mode = selectedSplitMode.value;
    if (mode == 'equal' || members.isEmpty) return true;

    if (mode == 'percent') {
      final total = members.fold<double>(
        0,
        (sum, m) =>
            sum +
            (double.tryParse(
                  splitControllerFor(m.id).text.replaceAll(',', '.'),
                ) ??
                0),
      );
      if ((total - 100).abs() > 0.5) {
        return false;
      }
    } else {
      final total = members.fold<double>(
        0,
        (sum, m) =>
            sum +
            (double.tryParse(
                  splitControllerFor(m.id).text.replaceAll(',', '.'),
                ) ??
                0),
      );
      if ((total - amount.value).abs() > 0.5) {
        return false;
      }
    }

    return true;
  }

  Future<void> saveExpense() async {
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

    if (selectedPayers.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn ít nhất 1 người trả',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (!_validateSplits()) {
      final mode = selectedSplitMode.value;
      Get.snackbar(
        'Lỗi',
        mode == 'percent'
            ? 'Tổng phần trăm phải bằng 100%'
            : 'Tổng số tiền phải bằng tổng chi tiêu',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final id = eventId;
    if (id == null) {
      Get.snackbar(
        'Lỗi',
        'Không xác định được sự kiện',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isSaving.value = true;
    update();

    final payerIds = selectedPayers
        .map(int.tryParse)
        .whereType<int>()
        .toList();

    final result = await _repository.saveExpense(
      eventId: id,
      categoryId: selectedCategoryId.value,
      title: description.value.isEmpty ? 'Chi tiêu nhóm' : description.value,
      amount: amount.value,
      currency: selectedCurrency.value,
      description: description.value,
      expenseDate: selectedDate.value.toIso8601String().split('T').first,
      splitMethod: selectedSplitMode.value,
      payerIds: payerIds,
      splits: _buildSplitPayload(),
    );

    isSaving.value = false;
    update();

    if (result['success'] == true) {
      Get.back(result: true);
      Get.snackbar(
        'Thành công',
        result['message'] ?? 'Đã thêm chi tiêu nhóm',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      clearAll();
    } else {
      Get.snackbar(
        'Thất bại',
        result['message'] ?? 'Không thể thêm chi tiêu nhóm',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
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
    hideKeypad();
    hideCurrencyPicker();
    amount.value = 0.0;
    expression.value = '';
    description.value = '';
    descriptionController.clear();
    selectedDate.value = DateTime.now();
    selectedCategoryId.value =
        categories.isEmpty ? null : (categories.first['category_id'] as num).toInt();
    selectedSplitMode.value = 'equal';
    for (final controller in _splitControllers.values) {
      controller.clear();
    }
    final me = members.firstWhereOrNull((m) => m.isMe);
    selectedPayers.assignAll([me?.id].whereType<String>());
  }

  @override
  void onClose() {
    descriptionController.dispose();
    for (final controller in _splitControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }
}
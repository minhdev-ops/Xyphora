import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../add_expense/data/repositories/add_expense_repository.dart';
import '../../../add_expense/domain/models/group_member.dart';
import '../../../event_management/presentation/controllers/event_detail_controller.dart';
import '../../../home_dashboard/presentation/controllers/dashboard_controller.dart';

/// Controller dành riêng cho luồng thêm chi tiêu nhóm từ màn EventDetail.
/// Nhận [eventId] và [eventTitle] từ arguments hoặc EventDetailController.
class AddGroupExpenseController extends GetxController {
  final AddExpenseRepository _repository = AddExpenseRepository();

  static const int maxExpressionLength = 12;
  static const List<String> currencies = ['VND', 'USD', 'EUR', 'JPY'];
  static const List<(String, String)> splitOptions = [
    ('equal', 'Chia đều'),
    ('percentage', 'Theo %'),
    ('exact', 'Theo tiền'),
  ];

  // ── State ──────────────────────────────────────────────────────────────────
  final amount = 0.0.obs;
  final expression = ''.obs;
  final description = ''.obs;
  final selectedCurrency = 'VND'.obs;
  final isKeypadVisible = false.obs;
  final isCurrencyPickerVisible = false.obs;
  final isSaving = false.obs;
  final selectedDate = DateTime.now().obs;

  // Danh mục
  final categories = <Map<String, dynamic>>[].obs;
  final selectedCategoryId = RxnInt();
  final isLoadingCategories = false.obs;

  // Event (được set từ ngoài)
  final selectedEventId = RxnInt();
  final eventTitle = RxnString();

  // Thành viên nhóm
  final members = <GroupMember>[].obs;
  final selectedPayers = <String>[].obs;
  final selectedSplitMode = 'equal'.obs;
  final isLoadingMembers = false.obs;

  final Map<String, TextEditingController> _splitControllers = {};
  final TextEditingController descriptionController = TextEditingController();

  // ── Helpers ────────────────────────────────────────────────────────────────
  List<String> get sortedCurrencies => [
        selectedCurrency.value,
        ...currencies.where((c) => c != selectedCurrency.value),
      ];

  TextEditingController splitControllerFor(String memberId) =>
      _splitControllers.putIfAbsent(memberId, () => TextEditingController());

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    // Lấy event_id / event_title từ arguments (nếu có)
    final args = Get.arguments;
    if (args is Map) {
      final rawId = args['event_id'];
      final id = rawId is int ? rawId : int.tryParse('$rawId');
      if (id != null) {
        selectedEventId.value = id;
        eventTitle.value = args['event_title']?.toString();
        loadMembers(id);
      }
    } else {
      // Fallback: lấy từ EventDetailController nếu đang mở từ EventDetailView
      if (Get.isRegistered<EventDetailController>()) {
        final detailCtrl = Get.find<EventDetailController>();
        final rawId = int.tryParse(detailCtrl.event.value.id);
        if (rawId != null) {
          selectedEventId.value = rawId;
          eventTitle.value = detailCtrl.event.value.title;
          loadMembers(rawId);
        }
      }
    }
    loadCategories();
  }

  // ── Data Loading ───────────────────────────────────────────────────────────
  Future<void> loadMembers(int eventId) async {
    isLoadingMembers.value = true;
    final result = await _repository.fetchEvent(eventId);
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>? ?? const {};
      final participants =
          (data['participants'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      members.assignAll(participants.map(GroupMember.fromParticipant).toList());

      final me = members.firstWhereOrNull((m) => m.isMe);
      selectedPayers.assignAll(
        [(me ?? members.firstOrNull)?.id].whereType<String>(),
      );

      if (eventTitle.value == null) {
        eventTitle.value = data['title']?.toString();
      }
    } else {
      Get.snackbar(
        'Lỗi',
        result['message'] ?? 'Không thể tải danh sách thành viên',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    isLoadingMembers.value = false;
  }

  Future<void> loadCategories() async {
    isLoadingCategories.value = true;
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
  }

  // ── Input Actions ──────────────────────────────────────────────────────────
  void selectCategory(int? categoryId) {
    selectedCategoryId.value =
        (categoryId == null || categoryId == 0) ? null : categoryId;
  }

  void selectDate(DateTime date) => selectedDate.value = date;

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
    final base = mode == 'percentage' ? 100.0 / count : amount.value / count;
    for (final member in members) {
      splitControllerFor(member.id).text = _fmtNum(base);
    }
  }

  String _fmtNum(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(2);
  }

  // ── Keypad ─────────────────────────────────────────────────────────────────
  void onKeyPressed(String key) {
    HapticFeedback.lightImpact();
    hideCurrencyPicker();
    switch (key) {
      case 'C':
        _clearExpression();
      case '⌫':
        _handleBackspace();
      case '+':
      case '-':
      case '×':
      case '÷':
        if (expression.value.length < maxExpressionLength) {
          _handleOperator(key);
        }
      case '•':
        if (expression.value.length < maxExpressionLength &&
            !expression.value.contains('•')) {
          expression.value += '•';
        }
      case '=':
        _calculateResult();
      default:
        if (expression.value.length < maxExpressionLength) {
          final remaining = maxExpressionLength - expression.value.length;
          expression.value +=
              key.length > remaining ? key.substring(0, remaining) : key;
        }
    }
  }

  void _handleBackspace() {
    if (expression.value.isNotEmpty) {
      expression.value =
          expression.value.substring(0, expression.value.length - 1);
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
      if (!result.isFinite) throw const FormatException();
      amount.value = result;
      expression.value = result.toStringAsFixed(0);
    } catch (_) {
      Get.snackbar('Lỗi', 'Biểu thức không hợp lệ',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  double _evaluateExpression(String expr) {
    final sanitized =
        expr.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('•', '.');
    final List<String> tokens = [];
    String currentNum = '';
    for (final char in sanitized.split('')) {
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

    final pass1 = [tokens[0]];
    for (int i = 1; i < tokens.length - 1; i += 2) {
      final op = tokens[i];
      final next = tokens[i + 1];
      if (op == '*' || op == '/') {
        final last = double.parse(pass1.removeLast());
        final nextNum = double.parse(next);
        pass1.add(op == '*'
            ? (last * nextNum).toString()
            : (last / nextNum).toString());
      } else {
        pass1.add(op);
        pass1.add(next);
      }
    }

    double result = double.parse(pass1[0]);
    for (int i = 1; i < pass1.length - 1; i += 2) {
      final op = pass1[i];
      final next = double.parse(pass1[i + 1]);
      if (op == '+') { result += next; }
      else if (op == '-') { result -= next; }
    }
    return result;
  }

  // ── Validation ─────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _buildSplitPayload() {
    final mode = selectedSplitMode.value;
    if (mode == 'equal' || members.isEmpty) return const [];
    final splits = <Map<String, dynamic>>[];
    for (final member in members) {
      final value = double.tryParse(
          splitControllerFor(member.id).text.replaceAll(',', '.'));
      if (value == null || value < 0) return const [];
      if (mode == 'percentage') {
        splits.add({'participant_id': int.parse(member.id), 'percentage': value});
      } else {
        splits.add({'participant_id': int.parse(member.id), 'amount': value});
      }
    }
    return splits;
  }

  bool _validateSplits() {
    final mode = selectedSplitMode.value;
    if (mode == 'equal' || members.isEmpty) return true;
    final total = members.fold<double>(
      0,
      (sum, m) =>
          sum +
          (double.tryParse(
                splitControllerFor(m.id).text.replaceAll(',', '.'),
              ) ??
              0),
    );
    if (mode == 'percentage') return (total - 100).abs() <= 0.5;
    return (total - amount.value).abs() <= 0.5;
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> saveExpense() async {
    if (amount.value <= 0 && expression.value.isNotEmpty) _calculateResult();

    if (amount.value <= 0) {
      Get.snackbar('Lỗi', 'Vui lòng nhập số tiền hợp lệ',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (selectedPayers.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng chọn ít nhất 1 người trả',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (!_validateSplits()) {
      final mode = selectedSplitMode.value;
      Get.snackbar(
        'Lỗi',
        mode == 'percentage'
            ? 'Tổng phần trăm phải bằng 100%'
            : 'Tổng số tiền phải bằng tổng chi tiêu',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isSaving.value = true;
    final rawTitle = description.value.isEmpty ? 'Chi tiêu nhóm' : description.value;
    final title = rawTitle.length > 150 ? rawTitle.substring(0, 150) : rawTitle;
    final payerIds =
        selectedPayers.map(int.tryParse).whereType<int>().toList();

    final result = await _repository.saveEventExpense(
      eventId: selectedEventId.value!,
      categoryId: selectedCategoryId.value,
      title: title,
      amount: amount.value,
      currency: selectedCurrency.value,
      description: description.value,
      expenseDate: selectedDate.value.toIso8601String().split('T').first,
      splitMethod: selectedSplitMode.value,
      payerIds: payerIds,
      splits: _buildSplitPayload(),
    );
    isSaving.value = false;

    if (result['success'] == true) {
      // Refresh EventDetailController nếu đang mở
      if (Get.isRegistered<EventDetailController>()) {
        final detailCtrl = Get.find<EventDetailController>();
        await detailCtrl.loadExpenses();
      }
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadDashboardData();
      }
      Get.back(result: true);
      Get.snackbar('Thành công', result['message'] ?? 'Đã thêm chi tiêu',
          backgroundColor: Colors.green, colorText: Colors.white);
      clearAll();
    } else {
      Get.snackbar('Thất bại', result['message'] ?? 'Không thể thêm chi tiêu',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // ── UI Helpers ─────────────────────────────────────────────────────────────
  void updateDescription(String value) => description.value = value;

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

  void hideCurrencyPicker() => isCurrencyPickerVisible.value = false;

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
    selectedCategoryId.value = categories.isEmpty
        ? null
        : (categories.first['category_id'] as num).toInt();
    selectedPayers.clear();
    selectedSplitMode.value = 'equal';
    for (final c in _splitControllers.values) {
      c.clear();
    }
  }

  @override
  void onClose() {
    descriptionController.dispose();
    for (final c in _splitControllers.values) {
      c.dispose();
    }
    super.onClose();
  }
}

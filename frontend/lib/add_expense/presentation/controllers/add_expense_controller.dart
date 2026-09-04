import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../home_dashboard/presentation/controllers/dashboard_controller.dart';
import '../../data/repositories/add_expense_repository.dart';
import '../../domain/models/group_member.dart';

class AddExpenseController extends GetxController {
  final AddExpenseRepository _repository = AddExpenseRepository();

  static const int maxExpressionLength = 12;
  static const List<String> currencies = ['VND', 'USD', 'EUR', 'JPY'];
  static const List<(String, String)> splitOptions = [
    ('equal', 'Chia đều'),
    ('percentage', 'Theo %'),
    ('exact', 'Theo tiền'),
  ];

  final amount = 0.0.obs;
  final expression = ''.obs;
  final description = ''.obs;
  final selectedCurrency = 'VND'.obs;
  final isKeypadVisible = false.obs;
  final isCurrencyPickerVisible = false.obs;
  final isSaving = false.obs;

  // Ngay chi tieu (mac dinh hom nay)
  final selectedDate = DateTime.now().obs;

  // Danh muc
  final categories = <Map<String, dynamic>>[].obs;
  final selectedCategoryId = RxnInt();
  final isLoadingCategories = false.obs;

  // Su kien
  final events = <Map<String, dynamic>>[].obs;
  final selectedEventId = RxnInt();
  final eventTitle = RxnString();
  final isLoadingEvents = false.obs;

  // Thanh vien su kien + nguoi tra + cach chia
  final members = <GroupMember>[].obs;
  final selectedPayers = <String>[].obs;
  final selectedSplitMode = 'equal'.obs;
  final isLoadingMembers = false.obs;

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
      final rawId = args['event_id'];
      final id = rawId is int ? rawId : int.tryParse('$rawId');
      if (id != null) {
        selectedEventId.value = id;
        eventTitle.value = args['event_title']?.toString();
      }
    }
    loadEvents();
    loadCategories();
  }

  Future<void> loadEvents() async {
    isLoadingEvents.value = true;
    update();

    final result = await _repository.fetchEvents();

    if (result['success'] == true) {
      events.assignAll(
        (result['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>(),
      );
    } else {
      Get.snackbar(
        'Lỗi',
        result['message'] ?? 'Không thể tải danh sách sự kiện',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }

    final id = selectedEventId.value;
    if (id != null) {
      final match = events.firstWhereOrNull(
        (e) => (e['event_id'] as num).toInt() == id,
      );
      if (match != null) {
        eventTitle.value = match['title']?.toString();
      }
      loadMembers(id);
    }

    isLoadingEvents.value = false;
    update();
  }

  void selectEvent(int? eventId) {
    final id = (eventId == null || eventId == -1) ? null : eventId;

    selectedEventId.value = id;
    selectedSplitMode.value = 'equal';
    members.clear();
    selectedPayers.clear();
    for (final controller in _splitControllers.values) {
      controller.clear();
    }

    if (id == null) {
      eventTitle.value = null;
    } else {
      final match = events.firstWhereOrNull(
        (e) => (e['event_id'] as num).toInt() == id,
      );
      eventTitle.value = match?['title']?.toString() ?? 'Sự kiện';
      loadMembers(id);
    }
    update();
  }

  Future<void> loadMembers(int eventId) async {
    isLoadingMembers.value = true;
    update();

    final result = await _repository.fetchEvent(eventId);

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>? ?? const {};
      final participants = (data['participants'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      members.assignAll(
        participants.map(GroupMember.fromParticipant).toList(),
      );

      // Mac dinh nguoi tra = nguoi dang dang nhap (is_me), neu khong co thi nguoi dau tien
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
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(2);
  }

  List<Map<String, dynamic>> _buildSplitPayload() {
    final mode = selectedSplitMode.value;
    if (mode == 'equal' || members.isEmpty) return const [];

    final splits = <Map<String, dynamic>>[];

    if (mode == 'percentage') {
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

    if (mode == 'percentage') {
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

    final eventId = selectedEventId.value;
    if (eventId != null) {
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
          mode == 'percentage'
              ? 'Tổng phần trăm phải bằng 100%'
              : 'Tổng số tiền phải bằng tổng chi tiêu',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
    }

    isSaving.value = true;
    update();

    final rawTitle = description.value.isEmpty
        ? (eventId != null ? 'Chi tiêu nhóm' : 'Chi tiêu mới')
        : description.value;
    final title =
        rawTitle.length > 150 ? rawTitle.substring(0, 150) : rawTitle;

    final payerIds = selectedPayers
        .map(int.tryParse)
        .whereType<int>()
        .toList();

    final result = await _repository.saveExpense(
      eventId: eventId,
      categoryId: selectedCategoryId.value,
      title: title,
      amount: amount.value,
      currency: selectedCurrency.value,
      description: description.value,
      expenseDate: selectedDate.value.toIso8601String().split('T').first,
      splitMethod: eventId != null ? selectedSplitMode.value : null,
      payerIds: eventId != null ? payerIds : const [],
      splits: eventId != null ? _buildSplitPayload() : const [],
    );

    isSaving.value = false;
    update();

    if (result['success'] == true) {
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadDashboardData();
      }
      Get.back(result: true);
      Get.snackbar(
        'Thành công',
        result['message'] ?? 'Đã thêm chi tiêu',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      clearAll();
    } else {
      Get.snackbar(
        'Thất bại',
        result['message'] ?? 'Không thể thêm chi tiêu',
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
    selectedEventId.value = null;
    eventTitle.value = null;
    members.clear();
    selectedPayers.clear();
    selectedSplitMode.value = 'equal';
    for (final controller in _splitControllers.values) {
      controller.clear();
    }
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/app_theme.dart';
import '../../../config/category_icons.dart';
import '../../data/repositories/add_expense_repository.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/models/group_member.dart';

class EditExpenseController extends GetxController {
  final AddExpenseRepository _repository = AddExpenseRepository();

  late final int expenseId;
  final isSaving = false.obs;

  final amount = 0.0.obs;
  final expression = ''.obs;
  final description = ''.obs;
  final selectedCurrency = 'VND'.obs;
  final isKeypadVisible = false.obs;
  final isCurrencyPickerVisible = false.obs;
  final selectedDate = DateTime.now().obs;

  final categories = <Map<String, dynamic>>[].obs;
  final selectedCategoryId = RxnInt();
  final isLoadingCategories = false.obs;

  final events = <Map<String, dynamic>>[].obs;
  final selectedEventId = RxnInt();
  final eventTitle = RxnString();
  final isLoadingEvents = false.obs;

  final members = <GroupMember>[].obs;
  final selectedPayers = <String>[].obs;
  final selectedSplitMode = 'equal'.obs;
  final isLoadingMembers = false.obs;

  final Map<String, TextEditingController> _splitControllers = {};
  final TextEditingController descriptionController = TextEditingController();

  static const List<String> currencies = ['VND', 'USD', 'EUR', 'JPY'];
  static const List<(String, String)> splitOptions = [
    ('equal', 'Chia đều'),
    ('percent', 'Theo %'),
    ('amount', 'Theo tiền'),
  ];

  List<String> get sortedCurrencies => [
    selectedCurrency.value,
    ...currencies.where((c) => c != selectedCurrency.value),
  ];

  TextEditingController splitControllerFor(String memberId) {
    return _splitControllers.putIfAbsent(memberId, () => TextEditingController());
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    expenseId = int.parse(args['id'].toString());
    amount.value = (args['amount'] as num?)?.toDouble() ?? 0.0;
    expression.value = amount.value > 0 ? amount.value.toStringAsFixed(0) : '';
    description.value = args['note']?.toString() ?? '';
    descriptionController.text = description.value;
    selectedCurrency.value = args['currency']?.toString() ?? 'VND';

    final dateStr = args['date']?.toString();
    if (dateStr != null && dateStr.isNotEmpty) {
      selectedDate.value = DateTime.tryParse(dateStr) ?? DateTime.now();
    }

    final eventId = args['event_id'];
    if (eventId != null) {
      final id = eventId is int ? eventId : int.tryParse('$eventId');
      if (id != null && id > 0) {
        selectedEventId.value = id;
        eventTitle.value = args['event_title']?.toString();
      }
    }

    loadCategories().then((_) {
      final catName = args['category']?.toString();
      if (catName != null && catName.isNotEmpty) {
        final match = categories.firstWhereOrNull(
          (c) => (c['name']?.toString() ?? '') == catName,
        );
        if (match != null) {
          selectedCategoryId.value = (match['category_id'] as num).toInt();
        }
      }
    });

    loadEvents().then((_) {
      if (selectedEventId.value != null) {
        loadMembers(selectedEventId.value!);
      }
    });
  }

  Future<void> loadCategories() async {
    isLoadingCategories.value = true;
    update();
    final result = await _repository.fetchCategories();
    if (result['success'] == true) {
      categories.assignAll(result['data'] as List<Map<String, dynamic>>);
    }
    isLoadingCategories.value = false;
    update();
  }

  Future<void> loadEvents() async {
    isLoadingEvents.value = true;
    update();
    final result = await _repository.fetchEvents();
    if (result['success'] == true) {
      events.assignAll(
        (result['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>(),
      );
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
      members.assignAll(participants.map(GroupMember.fromParticipant).toList());
      final me = members.firstWhereOrNull((m) => m.isMe);
      selectedPayers.assignAll(
        [(me ?? members.firstOrNull)?.id].whereType<String>(),
      );
    }
    isLoadingMembers.value = false;
    update();
  }

  void selectCategory(int? categoryId) {
    selectedCategoryId.value = (categoryId == null || categoryId == 0) ? null : categoryId;
    update();
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    update();
  }

  void selectCurrency(String value) {
    selectedCurrency.value = value;
    isCurrencyPickerVisible.value = false;
    isKeypadVisible.value = false;
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

  void hideCurrencyPicker() {
    isCurrencyPickerVisible.value = false;
  }

  void toggleCurrencyPicker() {
    FocusManager.instance.primaryFocus?.unfocus();
    hideKeypad();
    isCurrencyPickerVisible.toggle();
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
  }

  void onKeyPressed(String key) {
    HapticFeedback.lightImpact();
    hideCurrencyPicker();
    switch (key) {
      case 'C':
        expression.value = '';
        amount.value = 0.0;
        break;
      case '⌫':
        if (expression.value.isNotEmpty) {
          expression.value = expression.value.substring(
            0, expression.value.length - 1,
          );
        }
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
        if (expression.value.length < 12) {
          _handleOperator(key);
        }
        break;
      case '•':
        if (expression.value.length < 12 && !expression.value.contains('•')) {
          expression.value += '•';
        }
        break;
      case '=':
        _calculateResult();
        break;
      default:
        if (expression.value.length < 12) {
          expression.value += key;
        }
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

  void _calculateResult() {
    if (expression.value.isEmpty) return;
    try {
      String sanitized = expression.value
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

      if (tokens.isEmpty) return;

      List<String> pass1 = [tokens[0]];
      for (int i = 1; i < tokens.length - 1; i += 2) {
        final op = tokens[i];
        final next = tokens[i + 1];
        if (op == '*' || op == '/') {
          final last = double.parse(pass1.removeLast());
          final nextNum = double.parse(next);
          pass1.add(op == '*' ? (last * nextNum).toString() : (last / nextNum).toString());
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

      if (!result.isFinite) throw const FormatException();
      amount.value = result;
      expression.value = result.toStringAsFixed(0);
    } catch (_) {
      Get.snackbar('Lỗi', 'Biểu thức không hợp lệ',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
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
        splits.add({'participant_id': int.parse(member.id), 'percentage': value});
      }
    } else {
      for (final member in members) {
        final value = double.tryParse(
          splitControllerFor(member.id).text.replaceAll(',', '.'),
        );
        if (value == null || value < 0) return const [];
        splits.add({'participant_id': int.parse(member.id), 'amount': value});
      }
    }
    return splits;
  }

  Future<void> saveExpense() async {
    if (amount.value <= 0 && expression.value.isNotEmpty) {
      _calculateResult();
    }
    if (amount.value <= 0) {
      Get.snackbar('Lỗi', 'Vui lòng nhập số tiền hợp lệ',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isSaving.value = true;
    update();

    final eventId = selectedEventId.value;
    final rawTitle = description.value.isEmpty
        ? (eventId != null ? 'Chi tiêu nhóm' : 'Chi tiêu mới')
        : description.value;
    final title = rawTitle.length > 150 ? rawTitle.substring(0, 150) : rawTitle;
    final payerIds = selectedPayers.map(int.tryParse).whereType<int>().toList();

    final result = await _repository.updateExpense(
      expenseId: expenseId,
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
      Get.back(
        result: ExpenseModel(
          id: expenseId.toString(),
          title: title,
          amount: amount.value,
          currency: selectedCurrency.value,
          description: description.value,
          category: categoryLabel,
          date: selectedDate.value.toIso8601String().split('T').first,
        ),
      );
      Get.snackbar('Thành công', 'Đã cập nhật chi tiêu',
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar('Thất bại', result['message'] ?? 'Không thể cập nhật',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  String get categoryLabel {
    final match = categories.firstWhereOrNull(
      (c) => (c['category_id'] as num).toInt() == selectedCategoryId.value,
    );
    return match?['name']?.toString() ?? 'Khác';
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

// =============================================================================
// EditExpensePage
// =============================================================================
class EditExpensePage extends StatelessWidget {
  const EditExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditExpenseController>(
      init: EditExpenseController(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          body: SafeArea(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    ctrl.hideCurrencyPicker();
                    ctrl.hideKeypad();
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (_) {
                            ctrl.hideCurrencyPicker();
                            return false;
                          },
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildHeader(context, ctrl),
                                const SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: _buildExpenseCard(context, ctrl),
                                ),
                                const SizedBox(height: 24),
                                Obx(() {
                                  if (ctrl.selectedEventId.value == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: _buildPayersSection(ctrl),
                                  );
                                }),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Obx(() => ctrl.isKeypadVisible.value
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildCalculator(ctrl),
                            )
                          : const SizedBox.shrink()),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Obx(() {
                  if (!ctrl.isCurrencyPickerVisible.value) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    top: 160,
                    right: 20,
                    child: _buildCurrencyPicker(ctrl),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, EditExpenseController ctrl) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 24,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('Sửa chi tiêu', style: AppTextStyles.amountMedium),
            const Spacer(),
            ElevatedButton(
              onPressed: ctrl.isSaving.value ? null : () => ctrl.saveExpense(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Obx(() => ctrl.isSaving.value
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Lưu', style: AppTextStyles.buttonPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, EditExpenseController ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount
          Row(
            children: [
              GestureDetector(
                onTap: ctrl.toggleCurrencyPicker,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F3EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() => Text(ctrl.selectedCurrency.value,
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary))),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: AppColors.textPrimary),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: ctrl.showKeypad,
                  child: Obx(() => Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F3EC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        width: 1.5,
                        color: ctrl.isKeypadVisible.value
                            ? AppColors.textPrimary.withValues(alpha: 0.4)
                            : Colors.transparent,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          ctrl.expression.value.isEmpty ? '0' : ctrl.expression.value,
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: ctrl.expression.value.isEmpty
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Event
          _buildLabel('Sự kiện'),
          const SizedBox(height: 6),
          Obx(() {
            if (ctrl.isLoadingEvents.value) return _buildLoadingField();
            return _buildDropdown<int>(
              value: ctrl.events.any(
                (e) => (e['event_id'] as num).toInt() == ctrl.selectedEventId.value,
              )
                  ? ctrl.selectedEventId.value
                  : -1,
              items: [
                const DropdownMenuItem(value: -1, child: Text('Không có sự kiện')),
                ...ctrl.events.map((e) => DropdownMenuItem(
                  value: (e['event_id'] as num).toInt(),
                  child: Text(e['title']?.toString() ?? '', overflow: TextOverflow.ellipsis),
                )),
              ],
              onChanged: ctrl.selectEvent,
              prefixIcon: Icons.event_note_rounded,
            );
          }),
          const SizedBox(height: 16),

          // Date
          _buildLabel('Ngày'),
          const SizedBox(height: 6),
          Obx(() {
            final date = ctrl.selectedDate.value;
            return GestureDetector(
              onTap: () async {
                ctrl.hideKeypad();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(primary: AppColors.primary),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) ctrl.selectDate(picked);
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: const Color(0xFFE8F3EC), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 19, color: AppColors.textPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('${date.day} tháng ${date.month}, ${date.year}',
                          style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: AppColors.textPrimary),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),

          // Category
          _buildLabel('Danh mục'),
          const SizedBox(height: 6),
          Obx(() {
            if (ctrl.isLoadingCategories.value) return _buildLoadingField();
            final selectedCat = ctrl.categories.firstWhereOrNull(
              (c) => (c['category_id'] as num).toInt() == ctrl.selectedCategoryId.value,
            );
            return _buildDropdown<int>(
              value: ctrl.selectedCategoryId.value,
              items: ctrl.categories.map((c) => DropdownMenuItem(
                value: (c['category_id'] as num).toInt(),
                child: Row(
                  children: [
                    Icon(categoryIconFor(c['icon']?.toString()),
                        size: 18, color: categoryColorFor(c['color']?.toString())),
                    const SizedBox(width: 8),
                    Expanded(child: Text(c['name']?.toString() ?? '', overflow: TextOverflow.ellipsis)),
                  ],
                ),
              )).toList(),
              onChanged: ctrl.selectCategory,
              prefixIcon: selectedCat != null
                  ? categoryIconFor(selectedCat['icon']?.toString())
                  : Icons.category_outlined,
              hint: 'Chọn danh mục',
            );
          }),
          const SizedBox(height: 16),

          // Description
          TextField(
            controller: ctrl.descriptionController,
            onTap: ctrl.hideKeypad,
            onChanged: (v) => ctrl.description.value = v,
            minLines: 1,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Mô tả khoản chi tiêu...',
              hintStyle: GoogleFonts.nunito(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
              filled: true,
              fillColor: const Color(0xFFE8F3EC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              counterText: '',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.textPrimary.withValues(alpha: 0.35), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayersSection(EditExpenseController ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Người trả'),
          const SizedBox(height: 8),
          Obx(() {
            if (ctrl.isLoadingMembers.value) return _buildLoadingField();
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ctrl.members.map((m) {
                final selected = ctrl.selectedPayers.contains(m.id);
                return GestureDetector(
                  onTap: () => ctrl.togglePayer(m.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.divider,
                        width: 1,
                      ),
                    ),
                    child: Text(m.name,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppColors.textPrimary,
                        )),
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 16),

          _buildLabel('Phương thức chia'),
          const SizedBox(height: 8),
          Obx(() => Row(
            children: EditExpenseController.splitOptions.map((opt) {
              final selected = ctrl.selectedSplitMode.value == opt.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () => ctrl.selectSplitMode(opt.$1),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(opt.$2,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppColors.textPrimary,
                        )),
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildCalculator(EditExpenseController ctrl) {
    final keys = [
      ['7', '8', '9', '÷'],
      ['4', '5', '6', '×'],
      ['1', '2', '3', '-'],
      ['C', '0', '⌫', '+'],
      ['•', '=', '', ''],
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Column(
        children: keys.map((row) {
          return Row(
            children: row.map((key) {
              if (key.isEmpty) return const Expanded(child: SizedBox());
              final isOp = '+-×÷'.contains(key);
              final isEq = key == '=';
              final isSpecial = key == 'C' || key == '⌫';
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: GestureDetector(
                    onTap: () => ctrl.onKeyPressed(key),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isEq
                            ? AppColors.primary
                            : isOp
                                ? AppColors.primaryDark
                                : isSpecial
                                    ? AppColors.errorBg
                                    : const Color(0xFFF4FAF6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        key,
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isEq
                              ? Colors.white
                              : isOp
                                  ? Colors.white
                                  : isSpecial
                                      ? AppColors.error
                                      : AppColors.textPrimary,
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

  Widget _buildCurrencyPicker(EditExpenseController ctrl) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ctrl.sortedCurrencies.map((currency) {
          final selected = currency == ctrl.selectedCurrency.value;
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => ctrl.selectCurrency(currency),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Text(currency,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? AppColors.textPrimary : Colors.black.withValues(alpha: 0.55),
                      )),
                  if (selected) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_rounded, size: 18, color: AppColors.textPrimary),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: GoogleFonts.nunito(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w700));
  }

  Widget _buildLoadingField() {
    return const SizedBox(
      height: 48,
      child: Center(
        child: SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required IconData prefixIcon,
    String? hint,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: const Color(0xFFE8F3EC), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(prefixIcon, size: 20, color: AppColors.textPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                isDense: true,
                hint: hint != null
                    ? Text(hint,
                        style: GoogleFonts.nunito(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600))
                    : null,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary, size: 22),
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

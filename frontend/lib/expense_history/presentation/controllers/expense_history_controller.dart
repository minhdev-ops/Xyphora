import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/expense_history_repository.dart';
import '../../domain/models/expense_history_item.dart';

class ExpenseHistoryController extends GetxController {
  final ExpenseHistoryRepository _repository = ExpenseHistoryRepository();

  final items = <ExpenseHistoryItem>[].obs;
  final categories = <Map<String, dynamic>>[].obs;
  final events = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final totalAmount = 0.0.obs;
  final myTotalAmount = 0.0.obs;
  final totalCount = 0.obs;

  final selectedEventId = RxnInt();
  final selectedCategoryId = RxnInt();
  final selectedMonth = RxnString();
  final onlyMyDebt = false.obs;
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final ScrollController scrollController = ScrollController();

  int _page = 1;

  List<Map<String, String>> get months {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final d = DateTime(now.year, now.month - i, 1);
      return {
        'value': '${d.year}-${d.month.toString().padLeft(2, '0')}',
        'label': 'Tháng ${d.month}/${d.year}',
      };
    });
  }

  DateTimeRange? get _selectedDateRange {
    final m = selectedMonth.value;
    if (m == null) return null;
    final parts = m.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    return DateTimeRange(
      start: DateTime(year, month, 1),
      end: DateTime(year, month + 1, 0),
    );
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadInitial();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  Future<void> loadInitial() async {
    isLoading.value = true;
    hasError.value = false;
    items.clear();
    _page = 1;
    hasMore.value = true;

    await Future.wait([
      _fetch(),
      if (categories.isEmpty) _loadCategories(),
      if (events.isEmpty) _loadEvents(),
    ]);

    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) return;
    isLoadingMore.value = true;
    _page++;
    await _fetch(append: true);
    isLoadingMore.value = false;
  }

  @override
  Future<void> refresh() => loadInitial();

  Future<void> _fetch({bool append = false}) async {
    try {
      final range = _selectedDateRange;
      final search = searchQuery.value.trim();
      final result = await _repository.fetchExpenses(
        eventId: selectedEventId.value,
        page: _page,
        dateFrom: range?.start,
        dateTo: range?.end,
        categoryId: selectedCategoryId.value,
        search: search.isEmpty ? null : search,
        mySplitStatus: onlyMyDebt.value ? 'pending' : null,
      );

      if (append) {
        items.addAll(result.items);
      } else {
        items.assignAll(result.items);
      }
      totalAmount.value = result.totalAmount;
      myTotalAmount.value = result.myTotalAmount;
      totalCount.value = result.total;
      hasMore.value = result.currentPage < result.lastPage;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (append) {
        _page--;
        Get.snackbar('Lỗi', msg,
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      } else {
        hasError.value = true;
        errorMessage.value = msg;
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      categories.assignAll(await _repository.fetchCategories());
    } catch (e) {
      debugPrint('loadCategories error: $e');
    }
  }

  Future<void> _loadEvents() async {
    try {
      events.assignAll(await _repository.fetchEvents());
    } catch (e) {
      debugPrint('loadEvents error: $e');
    }
  }

  void selectEvent(int? id) {
    if (selectedEventId.value == id) return;
    selectedEventId.value = id;
    loadInitial();
  }

  void selectCategory(int? id) {
    if (selectedCategoryId.value == id) return;
    selectedCategoryId.value = id;
    loadInitial();
  }

  void selectMonth(String? value) {
    if (selectedMonth.value == value) return;
    selectedMonth.value = value;
    loadInitial();
  }

  void toggleOnlyMyDebt(bool value) {
    if (onlyMyDebt.value == value) return;
    onlyMyDebt.value = value;
    loadInitial();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void applySearch() {
    loadInitial();
  }

  void clearSearch() {
    if (searchQuery.value.isEmpty) return;
    searchController.clear();
    searchQuery.value = '';
    loadInitial();
  }

  String formatCurrency(double amount) {
    final digits = amount.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()}đ';
  }
}
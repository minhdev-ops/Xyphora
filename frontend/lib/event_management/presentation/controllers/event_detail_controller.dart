import 'package:get/get.dart';
import '../../../expense_history/data/repositories/expense_history_repository.dart';
import '../../../expense_history/domain/models/expense_history_item.dart';
import '../../domain/models/event_detail_model.dart';
import '../../domain/models/event_model.dart';
import '../../domain/models/expense_model.dart';

class EventDetailController extends GetxController {
  final ExpenseHistoryRepository _expenseRepository =
      ExpenseHistoryRepository();

  final RxInt currentTab = 0.obs;

  final expenseGroups = <ExpenseGroup>[].obs;
  final myTotalExpense = 0.0.obs;
  final totalExpense = 0.0.obs;
  final isLoadingExpenses = false.obs;
  final hasExpensesError = false.obs;
  final expensesErrorMessage = ''.obs;

  final Map<int, String> _payerNames = {};
  final Map<int, String?> _categoryIcons = {};
  final List<ExpenseHistoryItem> _allItems = [];
  int _page = 1;
  bool _hasMore = true;
  int? _eventId;

  EventModel? get event => null;
  List<BalanceItem> get balances => const [];
  List<String> get photos => const [];

  double get totalOwed => 0.0;
  String get myUserId => '';

  int? get eventId => _eventId;

  static const List<String> _months = [
    'tháng 1', 'tháng 2', 'tháng 3', 'tháng 4', 'tháng 5', 'tháng 6',
    'tháng 7', 'tháng 8', 'tháng 9', 'tháng 10', 'tháng 11', 'tháng 12',
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final eventId = args is Map ? args['event_id'] : null;
    if (eventId is int) {
      _eventId = eventId;
      loadExpenses();
    } else {
      expenseGroups.clear();
      myTotalExpense.value = 0.0;
      totalExpense.value = 0.0;
    }
  }

  Future<void> loadExpenses() async {
    final eventId = _eventId;
    if (eventId == null) return;

    isLoadingExpenses.value = true;
    hasExpensesError.value = false;
    _allItems.clear();
    _page = 1;
    _hasMore = true;

    try {
      final result = await _expenseRepository.fetchExpenses(
        eventId: eventId,
        page: _page,
        perPage: 50,
      );
      _allItems.addAll(result.items);
      _hasMore = result.currentPage < result.lastPage;
      _applyData(result.myTotalAmount, result.totalAmount);
    } catch (e) {
      hasExpensesError.value = true;
      expensesErrorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingExpenses.value = false;
    }
  }

  Future<void> loadMoreExpenses() async {
    final eventId = _eventId;
    if (eventId == null || isLoadingExpenses.value || !_hasMore) return;

    _page++;
    try {
      final result = await _expenseRepository.fetchExpenses(
        eventId: eventId,
        page: _page,
        perPage: 50,
      );
      _allItems.addAll(result.items);
      _hasMore = result.currentPage < result.lastPage;
      _applyData(result.myTotalAmount, result.totalAmount);
    } catch (e) {
      _page--;
    }
  }

  void _applyData(double myTotal, double total) {
    _payerNames.clear();
    _categoryIcons.clear();

    final byDate = <DateTime, List<ExpenseModel>>{};
    for (final item in _allItems) {
      final date = DateTime.tryParse(item.expenseDate ?? '');
      if (date == null) continue;
      if (item.payerParticipantId != null) {
        _payerNames[item.payerParticipantId!] = item.payerName ?? 'Ai đó';
      }
      _categoryIcons[item.expenseId] = item.categoryIcon;

      byDate.putIfAbsent(date, () => []).add(ExpenseModel(
            id: '${item.expenseId}',
            eventId: '${_eventId ?? item.eventId}',
            title: item.title,
            amount: item.amount,
            dayPaid: date,
            payerId: '${item.payerParticipantId ?? 0}',
            splits: const [],
          ));
    }

    final groups = byDate.entries
        .map((e) => ExpenseGroup(
              date: e.key,
              formattedDate: _formatGroupDate(e.key),
              expenses: e.value,
            ))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    expenseGroups.assignAll(groups);
    myTotalExpense.value = myTotal;
    totalExpense.value = total;
  }

  String _formatGroupDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]}, ${date.year}';
  }

  String payerName(String payerId) {
    final id = int.tryParse(payerId);
    if (id != null && _payerNames.containsKey(id)) {
      return _payerNames[id] ?? 'Unknown';
    }
    final p = event?.participants.firstWhereOrNull((p) => p.userId == payerId);
    return p?.user?.name ?? 'Ai đó';
  }

  String? categoryIconFor(String expenseId) {
    final id = int.tryParse(expenseId);
    return id != null ? _categoryIcons[id] : null;
  }

  void switchTab(int index) {
    currentTab.value = index;
  }
}
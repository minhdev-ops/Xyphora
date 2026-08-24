import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../auth/data/auth_service.dart';
import '../../data/event_service.dart';
import '../../data/repositories/event_repository.dart';
import '../../domain/models/event_detail_model.dart';
import '../../domain/models/event_model.dart';
import '../../domain/models/expense_model.dart';
import 'event_controller.dart';

class EventDetailController extends GetxController {
  final EventRepository _repository;
  final AuthService _authService = Get.find<AuthService>();
  final EventModel? initialEvent;

  EventDetailController(this._repository, {this.initialEvent});

  // ── Tab / Loading state ────────────────────────────────────────────────────
  final RxInt currentTab = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString myUserId = ''.obs;
  final Rx<EventModel> event = EventDetailMock.event.obs;

  // ── Expenses async state ───────────────────────────────────────────────────
  final RxBool isLoadingExpenses = false.obs;
  final RxBool hasExpensesError = false.obs;
  final RxString expensesErrorMessage = ''.obs;

  // ── Computed helpers ───────────────────────────────────────────────────────
  bool get _isDummy => event.value.id.startsWith('ev');

  /// ID sự kiện hiện tại – dùng khi navigate sang GroupExpensePage.
  String get eventId => event.value.id;

  List<ExpenseGroup> get expenseGroups {
    if (_isDummy) return EventDetailMock.expenseGroups;
    return _buildExpenseGroups(event.value.expenses);
  }

  List<BalanceItem> get balances {
    if (_isDummy) return EventDetailMock.balances;
    return _computeBalances(event.value);
  }

  List<String> get photos {
    if (_isDummy) return EventDetailMock.photos;
    return const [];
  }

  double get myTotalExpense {
    if (_isDummy) return EventDetailMock.myTotalExpense;
    double total = 0;
    for (final expense in event.value.expenses) {
      for (final split in expense.splits) {
        final p = event.value.participants
            .firstWhereOrNull((p) => p.id == split.participantId);
        if (p != null && p.userId == myUserId.value) {
          total += split.amount;
        }
      }
    }
    return total;
  }

  double get totalExpense {
    if (_isDummy) return EventDetailMock.totalExpense;
    return event.value.expenses.fold(0, (sum, e) => sum + e.amount);
  }

  double get totalOwed {
    if (_isDummy) return EventDetailMock.totalOwed;
    return balances
        .where((b) => b.amount > 0)
        .fold(0, (sum, b) => sum + b.amount);
  }

  /// Trả về icon name (String) tương ứng với category của chi tiêu.
  /// Trả về null nếu không có icon.
  String? categoryIconFor(String expenseId) {
    final expense = event.value.expenses
        .firstWhereOrNull((e) => e.id == expenseId);
    return expense?.categoryIcon;
  }

  String payerName(String payerId) {
    final p =
        event.value.participants.firstWhereOrNull((p) => p.userId == payerId);
    if (p == null) return 'Unknown';
    final name = p.user?.name ?? p.displayName;
    return name.isNotEmpty ? name : 'Unknown';
  }

  void switchTab(int index) => currentTab.value = index;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    final initial = initialEvent;
    if (initial != null) {
      event.value = initial;
      loadEvent(initial);
    }
  }

  // ── Data loading ───────────────────────────────────────────────────────────
  Future<void> loadEvent(EventModel initialEvent) async {
    isLoading.value = true;
    event.value = initialEvent;
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) myUserId.value = user.id;
      final token = await _authService.getToken();
      if (token == null || initialEvent.id.startsWith('ev')) return;
      final detail =
          await _repository.getEvent(token: token, eventId: initialEvent.id);
      event.value = detail;
    } catch (e) {
      debugPrint('EventDetailController.loadEvent error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Tải lại danh sách chi tiêu từ API (dùng sau khi thêm chi tiêu mới).
  Future<void> loadExpenses() async {
    if (_isDummy) return;
    isLoadingExpenses.value = true;
    hasExpensesError.value = false;
    expensesErrorMessage.value = '';
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Vui lòng đăng nhập lại');
      final detail =
          await _repository.getEvent(token: token, eventId: event.value.id);
      event.value = detail;
    } catch (e) {
      hasExpensesError.value = true;
      expensesErrorMessage.value =
          'Không thể tải chi tiêu. Vui lòng thử lại.';
      debugPrint('EventDetailController.loadExpenses error: $e');
    } finally {
      isLoadingExpenses.value = false;
    }
  }

  /// Pagination – hiện tại tải lại toàn bộ (backend chưa có cursor).
  /// Có thể mở rộng để hỗ trợ pagination thật sự.
  Future<void> loadMoreExpenses() async {
    if (isLoadingExpenses.value || _isDummy) return;
    await loadExpenses();
  }

  Future<String> getInviteLink() async {
    final current = event.value;
    if (current.id.startsWith('ev')) {
      throw EventApiException('Không thể tạo link mời cho dữ liệu mẫu');
    }
    final token = await _authService.getToken();
    if (token == null) {
      throw EventApiException('Vui lòng đăng nhập để tạo link mời');
    }
    final response = await _repository.getInviteLink(
        token: token, eventId: current.id);
    final data = response['data'] as Map<String, dynamic>? ?? {};
    final link = data['invite_link'] as String? ?? '';
    if (link.isEmpty) {
      throw EventApiException('Không lấy được link mời');
    }
    return link;
  }

  Future<void> deleteEvent() async {
    final current = event.value;
    final token = await _authService.getToken();
    if (token == null || current.id.startsWith('ev')) return;
    await _repository.deleteEvent(token: token, eventId: current.id);
    Get.find<EventController>().removeEvent(current.id);
  }

  // ── Private helpers ────────────────────────────────────────────────────────
  List<ExpenseGroup> _buildExpenseGroups(List<ExpenseModel> expenses) {
    final map = <DateTime, List<ExpenseModel>>{};
    for (final e in expenses) {
      final day = DateTime(e.dayPaid.year, e.dayPaid.month, e.dayPaid.day);
      map.putIfAbsent(day, () => []);
      map[day]!.add(e);
    }
    final sortedDays = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return sortedDays
        .map((day) => ExpenseGroup(
              date: day,
              formattedDate: EventDetailMock.formatDate(day),
              expenses: map[day]!,
            ))
        .toList();
  }

  List<BalanceItem> _computeBalances(EventModel e) {
    final net = <String, double>{};
    for (final expense in e.expenses) {
      net[expense.payerId] = (net[expense.payerId] ?? 0) + expense.amount;
      for (final split in expense.splits) {
        net[split.participantId] =
            (net[split.participantId] ?? 0) - split.amount;
      }
    }
    return net.entries.map((entry) {
      final p =
          e.participants.firstWhereOrNull((p) => p.id == entry.key);
      final name = p?.user?.name ?? p?.displayName ?? 'Thành viên';
      return BalanceItem(name: name, amount: entry.value);
    }).toList();
  }
}
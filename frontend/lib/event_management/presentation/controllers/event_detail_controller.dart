import 'package:get/get.dart';
import '../../domain/models/event_detail_model.dart';
import '../../domain/models/event_model.dart';

class EventDetailController extends GetxController {
  final RxInt currentTab = 0.obs;

  final EventModel event = EventDetailMock.event;
  final List<ExpenseGroup> expenseGroups = EventDetailMock.expenseGroups;
  final List<BalanceItem> balances = EventDetailMock.balances;
  final List<String> photos = EventDetailMock.photos;

  double get myTotalExpense => EventDetailMock.myTotalExpense;
  double get totalExpense => EventDetailMock.totalExpense;
  double get totalOwed => EventDetailMock.totalOwed;
  String get myUserId => EventDetailMock.myUserId;

  String payerName(String payerId) {
    final p = event.participants.firstWhereOrNull((p) => p.userId == payerId);
    return p?.user?.name ?? 'Unknown';
  }

  void switchTab(int index) {
    currentTab.value = index;
  }
}

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../auth/data/auth_service.dart';
import '../../data/repositories/event_repository.dart';
import '../../domain/models/event_detail_model.dart';
import '../../domain/models/event_model.dart';
import 'event_controller.dart';

class EventDetailController extends GetxController {
  final EventRepository _repository;

  EventDetailController(this._repository);

  final RxInt currentTab = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString myUserId = ''.obs;
  final Rx<EventModel> event = EventDetailMock.event.obs;

  List<ExpenseGroup> get expenseGroups => EventDetailMock.expenseGroups;
  List<BalanceItem> get balances => EventDetailMock.balances;
  List<String> get photos => EventDetailMock.photos;

  double get myTotalExpense => EventDetailMock.myTotalExpense;
  double get totalExpense => EventDetailMock.totalExpense;
  double get totalOwed => EventDetailMock.totalOwed;

  String payerName(String payerId) {
    final p = event.value.participants.firstWhereOrNull((p) => p.userId == payerId);
    if (p == null) return 'Unknown';
    final name = p.user?.name ?? p.displayName;
    return name.isNotEmpty ? name : 'Unknown';
  }

  void switchTab(int index) {
    currentTab.value = index;
  }

  Future<void> loadEvent(EventModel initialEvent) async {
    isLoading.value = true;
    event.value = initialEvent;
    try {
      final authService = AuthService();
      final user = await authService.getCurrentUser();
      if (user != null) myUserId.value = user.id;
      final token = await authService.getToken();
      if (token == null || initialEvent.id.startsWith('ev')) return;
      final detail = await _repository.getEvent(token: token, eventId: initialEvent.id);
      event.value = detail;
    } catch (e) {
      debugPrint('EventDetailController.loadEvent error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEvent({
    required String title,
    required String description,
    required String icon,
  }) async {
    final current = event.value;
    final token = await AuthService().getToken();
    if (token == null || current.id.startsWith('ev')) return;
    final updated = await _repository.updateEvent(
      token: token,
      eventId: current.id,
      data: {'title': title, 'description': description, 'icon': icon},
    );
    event.value = updated;
    Get.find<EventController>().updateEvent(updated);
  }

  Future<void> deleteEvent() async {
    final current = event.value;
    final token = await AuthService().getToken();
    if (token == null || current.id.startsWith('ev')) return;
    await _repository.deleteEvent(token: token, eventId: current.id);
    Get.find<EventController>().removeEvent(current.id);
  }
}

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../auth/data/auth_service.dart';
import '../../data/repositories/event_repository.dart';
import '../../domain/models/event_model.dart';

class EventController extends GetxController {
  final EventRepository _repository;

  EventController(this._repository);

  String myUserId = '';

  final RxList<EventModel> events = <EventModel>[].obs;
  final RxString currentFilter = 'Tất cả'.obs;
  final RxBool isLoading = false.obs;

  List<EventModel> get filteredEvents {
    switch (currentFilter.value) {
      case 'Đang mở':
        return events.where((e) => e.getUserBalance(myUserId) != 0).toList();
      case 'Đã xong':
        return events.where((e) => e.getUserBalance(myUserId) == 0).toList();
      default:
        return events.toList();
    }
  }

  double getTotalOwed() {
    double total = 0;
    for (var e in events) {
      double bal = e.getUserBalance(myUserId);
      if (bal > 0) total += bal;
    }
    return total;
  }

  double getTotalDebt() {
    double total = 0;
    for (var e in events) {
      double bal = e.getUserBalance(myUserId);
      if (bal < 0) total += bal.abs();
    }
    return total;
  }

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  Future<void> loadEvents({String? token}) async {
    isLoading.value = true;
    try {
      final authService = AuthService();
      final authToken = token ?? await authService.getToken();
      final user = await authService.getCurrentUser();
      if (user != null) myUserId = user.id;
      final result = await _repository.getEvents(token: authToken);
      events.assignAll(result);
    } catch (e) {
      debugPrint('EventController.loadEvents error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void addEvent(EventModel event) {
    events.insert(0, event);
  }

  void updateEvent(EventModel event) {
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
    } else {
      events.insert(0, event);
    }
  }

  void removeEvent(String eventId) {
    events.removeWhere((e) => e.id == eventId);
  }
}

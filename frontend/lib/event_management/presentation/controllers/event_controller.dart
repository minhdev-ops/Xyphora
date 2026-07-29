import 'package:get/get.dart';
import '../../data/repositories/event_repository.dart';
import '../../domain/models/event_model.dart';

class EventController extends GetxController {
  final EventRepository _repository;

  EventController(this._repository);

  final String myUserId = 'user_1';

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
      final result = await _repository.getEvents(token: token);
      events.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }
}

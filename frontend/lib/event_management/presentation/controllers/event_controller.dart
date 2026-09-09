import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../../domain/models/event_detail_model.dart';
import '../../domain/models/event_model.dart';
import '../../domain/models/participant_model.dart';
import '../pages/event_page.dart';
import 'package:xyphora_frontend/core/exceptions.dart';

class EventController extends GetxController {
  static const List<String> emojis = [
    '🎉', '⛰️', '🍽️', '🎂', '🏖️', '🏠', '🎊', '⚽',
  ];

  final EventRepository _repository;
  final AuthRepository _authRepository;

  EventController(this._repository, this._authRepository);

  String myUserId = '';

  // Event List State
  final RxList<EventModel> events = <EventModel>[].obs;
  final RxString currentFilter = 'Tất cả'.obs;
  final RxBool isLoading = false.obs;

  // Event Detail State
  final RxInt currentTab = 0.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxString myUserIdDetail = ''.obs;
  final Rx<EventModel> currentEvent = EventDetailMock.event.obs;

  final RxBool isLoadingExpenses = false.obs;
  final RxBool hasExpensesError = false.obs;
  final RxString expensesErrorMessage = ''.obs;

  // Create/Edit Event State
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController participantController = TextEditingController();
  final RxString selectedEmoji = '🎉'.obs;
  final RxList<ParticipantModel> participants = <ParticipantModel>[].obs;
  final RxBool isAddingParticipant = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isSaving = false.obs;
  int _participantCounter = 0;

  // Join Event State
  String? _joinToken;
  final RxBool isLoadingJoin = true.obs;
  final RxBool isClaiming = false.obs;
  final RxString joinEventTitle = ''.obs;
  final RxString joinEventIcon = ''.obs;
  final RxList<Map<String, dynamic>> joinParticipants = <Map<String, dynamic>>[].obs;

  // Computed properties for Event List
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

  // Computed properties for Event Detail
  bool get _isDummy => int.tryParse(currentEvent.value.id) == null;
  String get eventId => currentEvent.value.id;

  List<ExpenseGroup> get expenseGroups {
    if (_isDummy) return EventDetailMock.expenseGroups;
    return ExpenseGroup.fromExpenses(currentEvent.value.expenses);
  }

  List<BalanceItem> get balances {
    if (_isDummy) return EventDetailMock.balances;
    return BalanceItem.compute(currentEvent.value, myUserIdDetail.value);
  }

  List<String> get photos {
    if (_isDummy) return EventDetailMock.photos;
    return const [];
  }

  double get myTotalExpense {
    if (_isDummy) return EventDetailMock.myTotalExpense;
    double total = 0;
    for (final expense in currentEvent.value.expenses) {
      for (final split in expense.splits) {
        final p = currentEvent.value.participants
            .firstWhereOrNull((p) => p.id == split.participantId);
        if (p != null && p.userId == myUserIdDetail.value) {
          total += split.amount;
        }
      }
    }
    return total;
  }

  double get totalExpense {
    if (_isDummy) return EventDetailMock.totalExpense;
    return currentEvent.value.expenses.fold(0, (sum, e) => sum + e.amount);
  }

  double get totalOwed {
    if (_isDummy) return EventDetailMock.totalOwed;
    return balances
        .where((b) => b.amount > 0)
        .fold(0, (sum, b) => sum + b.amount);
  }

  String? categoryIconFor(String expenseId) {
    final expense = currentEvent.value.expenses
        .firstWhereOrNull((e) => e.id == expenseId);
    return expense?.categoryIcon;
  }

  String payerName(String payerId) {
    final p = currentEvent.value.participants
        .firstWhereOrNull((p) => p.id == payerId);
    if (p == null) return 'Unknown';
    final name = p.user?.name ?? p.displayName;
    return name.isNotEmpty ? name : 'Unknown';
  }

  void switchTab(int index) => currentTab.value = index;

  // Event List Methods
  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  Future<void> loadEvents() async {
    isLoading.value = true;
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) myUserId = user.id;
      final result = await _repository.getEvents();
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

  // Event Detail Methods
  void loadEventDetail(EventModel event) {
    currentEvent.value = event;
    _loadEventDetail();
  }

  Future<void> _loadEventDetail() async {
    isLoadingDetail.value = true;
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) myUserIdDetail.value = user.id;
      if (int.tryParse(currentEvent.value.id) == null) return;
      final detail = await _repository.getEvent(currentEvent.value.id);
      currentEvent.value = detail;
    } catch (e) {
      debugPrint('EventController._loadEventDetail error: $e');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> loadExpenses() async {
    if (_isDummy) return;
    isLoadingExpenses.value = true;
    hasExpensesError.value = false;
    expensesErrorMessage.value = '';
    try {
      final detail = await _repository.getEvent(currentEvent.value.id);
      currentEvent.value = detail;
    } catch (e) {
      hasExpensesError.value = true;
      expensesErrorMessage.value = 'Không thể tải chi tiêu. Vui lòng thử lại.';
      debugPrint('EventController.loadExpenses error: $e');
    } finally {
      isLoadingExpenses.value = false;
    }
  }

  Future<void> loadMoreExpenses() async {
    if (isLoadingExpenses.value || _isDummy) return;
    await loadExpenses();
  }

  Future<String> getInviteLink() async {
    final current = currentEvent.value;
    if (int.tryParse(current.id) == null) {
      throw ExceptionWithMessage(mess: 'Không thể tạo link mời cho dữ liệu mẫu');
    }
    final response = await _repository.getInviteLink(current.id);
    final data = response['data'] as Map<String, dynamic>? ?? {};
    final link = data['invite_link'] as String? ?? '';
    if (link.isEmpty) {
      throw ExceptionWithMessage(mess: 'Không lấy được link mời');
    }
    return link;
  }

  Future<void> deleteEvent() async {
    final current = currentEvent.value;
    if (int.tryParse(current.id) == null) return;
    await _repository.deleteEvent(current.id);
    removeEvent(current.id);
    Get.back();
  }

  // Create/Edit Event Methods
  void resetCreateEditState({EventModel? event}) {
    titleController.clear();
    descriptionController.clear();
    participantController.clear();
    selectedEmoji.value = '🎉';
    participants.clear();
    isAddingParticipant.value = false;
    isCreating.value = false;
    isSaving.value = false;
    _participantCounter = 0;

    if (event != null) {
      titleController.text = event.title;
      descriptionController.text = event.description;
      selectedEmoji.value = event.emoji.isNotEmpty ? event.emoji : '🎉';
      participants.addAll(
        event.participants.where((p) => p.userId != event.ownerId),
      );
      _participantCounter = event.participants.length;
    }
  }

  void selectEmoji(String emoji) => selectedEmoji.value = emoji;

  void startAddParticipant() {
    participantController.clear();
    isAddingParticipant.value = true;
  }

  void cancelAddParticipant() {
    FocusManager.instance.primaryFocus?.unfocus();
    isAddingParticipant.value = false;
  }

  void confirmAddParticipant({String? eventId}) {
    final name = participantController.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập tên người tham gia',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    _participantCounter++;
    participants.add(
      ParticipantModel(
        id: 'draft_p$_participantCounter',
        eventId: eventId ?? 'draft',
        userId: 'guest_$_participantCounter',
        displayName: name,
      ),
    );
    isAddingParticipant.value = false;
  }

  void removeParticipant(ParticipantModel participant) {
    participants.remove(participant);
  }

  Future<void> createEvent() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập tên sự kiện',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final token = await _authRepository.getToken();
    if (token == null) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng đăng nhập để tạo sự kiện',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    isCreating.value = true;
    try {
      final event = await _repository.createEvent({
        'title': title,
        'description': descriptionController.text.trim(),
        'icon': selectedEmoji.value,
        'participants': participants
            .map((p) => {'display_name': p.displayName})
            .toList(),
      });

      addEvent(event);
      Get.back();
      Get.snackbar(
        'Thành công',
        'Đã tạo sự kiện mới',
        backgroundColor: const Color(0xFF0C3D2B),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } on ExceptionWithMessage catch (e) {
      Get.snackbar(
        'Lỗi',
        e.mess,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể kết nối đến máy chủ',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> saveEvent(EventModel event) async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập tên sự kiện',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final token = await _authRepository.getToken();
    if (token == null) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng đăng nhập để chỉnh sửa sự kiện',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    isSaving.value = true;
    try {
      final updated = await _repository.updateEvent(
        event.id,
        {
          'title': title,
          'description': descriptionController.text.trim(),
          'icon': selectedEmoji.value,
          'participants': participants.map((p) {
            final id = int.tryParse(p.id);
            return id != null
                ? {'participant_id': id, 'display_name': p.name}
                : {'display_name': p.name};
          }).toList(),
        },
      );

      currentEvent.value = updated;
      updateEvent(updated);
      Get.back();
      Get.snackbar(
        'Thành công',
        'Đã cập nhật sự kiện',
        backgroundColor: const Color(0xFF0C3D2B),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } on ExceptionWithMessage catch (e) {
      Get.snackbar(
        'Lỗi',
        e.mess,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể kết nối đến máy chủ',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Join Event Methods
  void loadJoinEvent(String token) {
    _joinToken = token;
    _loadJoinEvent();
  }

  Future<void> _loadJoinEvent() async {
    final token = _joinToken;
    if (token == null) return;

    isLoadingJoin.value = true;
    try {
      final authToken = await _authRepository.getToken();
      if (authToken == null) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng đăng nhập để tham gia sự kiện',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
      final response = await _repository.joinEvent(token);
      final data = response['data'] as Map<String, dynamic>? ?? {};
      final event = data['event'] as Map<String, dynamic>? ?? {};
      joinEventTitle.value = event['title'] as String? ?? '';
      joinEventIcon.value = event['icon'] as String? ?? '🎉';
      joinParticipants.assignAll(
        (data['participants'] as List? ?? []).cast<Map<String, dynamic>>(),
      );
    } on ExceptionWithMessage catch (e) {
      Get.snackbar(
        'Lỗi',
        e.mess,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể kết nối đến máy chủ',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingJoin.value = false;
    }
  }

  Future<void> claimParticipant(int participantId, String displayName) async {
    final token = _joinToken;
    if (token == null) return;

    if (isClaiming.value) return;
    isClaiming.value = true;
    try {
      final authToken = await _authRepository.getToken();
      if (authToken == null) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng đăng nhập để tham gia sự kiện',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
      await _repository.claimParticipant(token, participantId);
      Get.snackbar(
        'Thành công',
        'Bạn đã tham gia sự kiện "$displayName"',
        backgroundColor: const Color(0xFF0C3D2B),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      Get.offAll(() => const EventPage());
    } on ExceptionWithMessage catch (e) {
      Get.snackbar(
        'Lỗi',
        e.mess,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      if (e.mess.contains('chọn bởi người khác') ||
          e.mess.contains('hết hạn') ||
          e.mess.contains('không hợp lệ')) {
        _loadJoinEvent();
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể kết nối đến máy chủ',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isClaiming.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    participantController.dispose();
    super.onClose();
  }
}
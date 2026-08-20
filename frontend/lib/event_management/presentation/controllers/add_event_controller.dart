import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/data/auth_service.dart';
import '../../data/event_service.dart';
import '../../domain/models/event_model.dart';
import '../../domain/models/participant_model.dart';
import 'event_controller.dart';

class AddEventController extends GetxController {
  static const List<String> emojis = [
    '🎉', '⛰️', '🍽️', '🎂', '🏖️', '🏠', '🎊', '⚽',
  ];

  final AuthService _authService = Get.find<AuthService>();
  final EventService _eventService = Get.find<EventService>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController participantController = TextEditingController();
  final RxString selectedEmoji = '🎉'.obs;
  final RxList<ParticipantModel> participants = <ParticipantModel>[].obs;
  final RxBool isAddingParticipant = false.obs;
  final RxBool isCreating = false.obs;
  int _participantCounter = 0;

  void selectEmoji(String emoji) => selectedEmoji.value = emoji;

  void startAddParticipant() {
    participantController.clear();
    isAddingParticipant.value = true;
  }

  void cancelAddParticipant() {
    FocusManager.instance.primaryFocus?.unfocus();
    isAddingParticipant.value = false;
  }

  void confirmAddParticipant() {
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
        eventId: 'draft',
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

    final token = await _authService.getToken();
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
      final response = await _eventService.createEvent(token, {
        'title': title,
        'description': descriptionController.text.trim(),
        'icon': selectedEmoji.value,
        'participants': participants
            .map((p) => {'display_name': p.displayName})
            .toList(),
      });

      final data = response['data'] as Map<String, dynamic>? ?? {};
      final event = _eventFromResponse(data);

      Get.find<EventController>().addEvent(event);
      Get.back();
      Get.snackbar(
        'Thành công',
        'Đã tạo sự kiện mới',
        backgroundColor: const Color(0xFF0C3D2B),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } on EventApiException catch (e) {
      Get.snackbar(
        'Lỗi',
        e.message,
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

  EventModel _eventFromResponse(Map<String, dynamic> json) {
    final id = json['event_id'].toString();
    return EventModel(
      id: id,
      ownerId: json['owner_id'].toString(),
      emoji: json['icon'] as String? ?? '',
      title: json['title'] as String? ?? '',
      currency: json['currency'] as String? ?? 'VND',
      description: json['description'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      participants: (json['participants'] as List? ?? [])
          .map((p) => ParticipantModel(
                id: p['participant_id'].toString(),
                eventId: id,
                userId: p['user_id']?.toString() ?? '',
                displayName: p['display_name'] as String? ?? '',
              ))
          .toList(),
      expenses: [],
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    participantController.dispose();
    super.onClose();
  }
}

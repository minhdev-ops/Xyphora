import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/data/auth_service.dart';
import '../../data/event_service.dart';
import '../../data/repositories/event_repository.dart';
import '../../domain/models/event_model.dart';
import '../../domain/models/participant_model.dart';
import 'add_event_controller.dart';
import 'event_controller.dart';
import 'event_detail_controller.dart';

class EditEventController extends GetxController {
  final EventRepository _repository;
  final AuthService _authService = Get.find<AuthService>();
  final EventModel event;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController participantController = TextEditingController();
  final RxString selectedEmoji = '🎉'.obs;
  final RxList<ParticipantModel> participants = <ParticipantModel>[].obs;
  final RxBool isAddingParticipant = false.obs;
  final RxBool isSaving = false.obs;
  int _participantCounter = 0;

  EditEventController(this._repository, {required this.event}) {
    titleController.text = event.title;
    descriptionController.text = event.description;
    selectedEmoji.value = event.emoji.isNotEmpty ? event.emoji : '🎉';
    participants.addAll(
      event.participants.where((p) => p.userId != event.ownerId),
    );
    _participantCounter = event.participants.length;
  }

  List<String> get emojis => AddEventController.emojis;

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
        eventId: event.id,
        userId: 'guest_$_participantCounter',
        displayName: name,
      ),
    );
    isAddingParticipant.value = false;
  }

  void removeParticipant(ParticipantModel participant) {
    participants.remove(participant);
  }

  Future<void> save() async {
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
        token: token,
        eventId: event.id,
        data: {
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

      if (Get.isRegistered<EventDetailController>()) {
        Get.find<EventDetailController>().event.value = updated;
      }
      Get.find<EventController>().updateEvent(updated);
      Get.back();
      Get.snackbar(
        'Thành công',
        'Đã cập nhật sự kiện',
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
      isSaving.value = false;
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/domain/models/user.dart';
import '../../domain/models/event_model.dart';
import '../../domain/models/participant_model.dart';
import 'event_controller.dart';

class AddEventController extends GetxController {
  static const List<String> emojis = [
    '🎉', '⛰️', '🍽️', '🎂', '🏖️', '🏠', '🎊', '⚽',
  ];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController participantController = TextEditingController();
  final RxString selectedEmoji = '🎉'.obs;
  final RxList<ParticipantModel> participants = <ParticipantModel>[].obs;
  final RxBool isAddingParticipant = false.obs;
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
        user: UserModel(
          id: 'guest_$_participantCounter',
          name: name,
          email: '',
        ),
      ),
    );
    isAddingParticipant.value = false;
  }

  void removeParticipant(ParticipantModel participant) {
    participants.remove(participant);
  }

  void createEvent() {
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

    final eventController = Get.find<EventController>();
    final eventId = DateTime.now().millisecondsSinceEpoch.toString();

    final event = EventModel(
      id: eventId,
      ownerId: eventController.myUserId,
      emoji: selectedEmoji.value,
      title: title,
      description: descriptionController.text.trim(),
      createdAt: DateTime.now(),
      participants: [
        ParticipantModel(
          id: '${eventId}_p1',
          eventId: eventId,
          userId: eventController.myUserId,
          user: UserModel(
            id: eventController.myUserId,
            name: 'Bạn',
            email: 'ban@email.com',
          ),
        ),
        ...participants.asMap().entries.map((e) => ParticipantModel(
              id: '${eventId}_p${e.key + 2}',
              eventId: eventId,
              userId: e.value.userId,
              user: e.value.user,
            )),
      ],
      expenses: [],
    );

    eventController.addEvent(event);
    Get.back();
    Get.snackbar(
      'Thành công',
      'Đã tạo sự kiện mới',
      backgroundColor: const Color(0xFF0C3D2B),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
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

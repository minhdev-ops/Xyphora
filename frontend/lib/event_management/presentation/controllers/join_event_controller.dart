import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/data/auth_service.dart';
import '../../data/event_service.dart';
import '../pages/event_page.dart';

class JoinEventController extends GetxController {
  final String token;
  final EventService _service = EventService();

  JoinEventController(this.token);

  final RxBool isLoading = true.obs;
  final RxBool isClaiming = false.obs;
  final RxString eventTitle = ''.obs;
  final RxString eventIcon = ''.obs;
  final RxList<Map<String, dynamic>> participants =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final authToken = await AuthService().getToken();
      if (authToken == null) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng đăng nhập để tham gia sự kiện',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
      final response = await _service.joinEvent(authToken, token);
      final data = response['data'] as Map<String, dynamic>? ?? {};
      final event = data['event'] as Map<String, dynamic>? ?? {};
      eventTitle.value = event['title'] as String? ?? '';
      eventIcon.value = event['icon'] as String? ?? '🎉';
      participants.assignAll(
        (data['participants'] as List? ?? []).cast<Map<String, dynamic>>(),
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
      isLoading.value = false;
    }
  }

  Future<void> claim(int participantId, String displayName) async {
    if (isClaiming.value) return;
    isClaiming.value = true;
    try {
      final authToken = await AuthService().getToken();
      if (authToken == null) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng đăng nhập để tham gia sự kiện',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
      await _service.claimParticipant(
          authToken, token, participantId.toString());
      Get.snackbar(
        'Thành công',
        'Bạn đã tham gia sự kiện "$displayName"',
        backgroundColor: const Color(0xFF0C3D2B),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      Get.offAll(() => const EventPage());
    } on EventApiException catch (e) {
      Get.snackbar(
        'Lỗi',
        e.message,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      if (e.message.contains('chọn bởi người khác') ||
          e.message.contains('hết hạn') ||
          e.message.contains('không hợp lệ')) {
        load();
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
}
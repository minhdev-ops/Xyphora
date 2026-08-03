import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportFeedbackController extends GetxController {
  var rating = 0.obs;
  late TextEditingController feedbackController;

  final List<String> faqs = [
    'Làm sao để thêm thành viên vào nhóm?',
    'Tôi có thể xuất dữ liệu không?',
    'Làm sao để xoá chi tiêu đã thêm?',
    'Ứng dụng có hỗ trợ nhiều tiền tệ không?',
  ];

  @override
  void onInit() {
    super.onInit();
    feedbackController = TextEditingController();
  }

  void setRating(int val) => rating.value = val;

  void submitFeedback() {
    if (feedbackController.text.trim().isEmpty) {
      Get.snackbar(
        'Thiếu nội dung',
        'Vui lòng nhập phản hồi trước khi gửi',
        backgroundColor: const Color(0xFF0C3D2B).withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    Get.snackbar(
      'Đã gửi',
      'Cảm ơn bạn! Phản hồi đã được ghi nhận',
      backgroundColor: const Color(0xFF0C3D2B).withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
    feedbackController.clear();
    rating.value = 0;
  }

  void openFaq(String question) {
    Get.snackbar(
      question,
      'Nội dung FAQ đang được cập nhật',
      backgroundColor: const Color(0xFF0C3D2B).withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    feedbackController.dispose();
    super.onClose();
  }
}
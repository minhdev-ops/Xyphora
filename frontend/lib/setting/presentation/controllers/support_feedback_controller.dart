import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/models/faq_item_model.dart';

class SupportFeedbackController extends GetxController {
  var rating = 0.obs;
  late TextEditingController feedbackController;

  final List<FAQItem> faqs = [
    FAQItem(
      question: 'Làm sao để thêm thành viên vào nhóm?',
      answer: 'Vào chi tiết sự kiện → Chọn Thêm thành viên( nhấn icon Bạn bè) → Nhập email hoặc chia sẻ link mời.',
    ),
    FAQItem(
      question: 'Tôi có thể xuất dữ liệu không?',
      answer: 'Có! Vào Cài đặt → Xuất dữ liệu CSV để tải báo cáo chi tiêu.',
    ),
    FAQItem(
      question: 'Làm sao để xoá chi tiêu đã thêm?',
      answer: 'Nhấn giữ vào khoản chi tiêu trong danh sách và chọn Xóa để xác nhận(nhấn biểu tượng Thùng rác).',
    ),
    FAQItem(
      question: 'Ứng dụng có hỗ trợ nhiều tiền tệ không?',
      answer: 'Có! Vào phần Cài đặt -> Tiền tệ mặc định để chọn đơn vị phù hợp.',
    ),
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

  // void openFaq(String question) {
  //   Get.snackbar(
  //     question,
  //     'Nội dung FAQ đang được cập nhật',
  //     backgroundColor: const Color(0xFF0C3D2B).withValues(alpha: 0.9),
  //     colorText: Colors.white,
  //     snackPosition: SnackPosition.TOP,
  //     duration: const Duration(seconds: 2),
  //   );
  // }

  @override
  void onClose() {
    feedbackController.dispose();
    super.onClose();
  }
}
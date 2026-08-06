import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountSecurityController extends GetxController {
  late TextEditingController nameController;
  late TextEditingController emailController;
  var is2FA = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController(text: 'Nguyễn Văn A');
    emailController = TextEditingController(text: 'nguyenvana@gmail.com');
  }

  void toggle2FA(bool val) => is2FA.value = val;

  void saveChanges() {
    Get.snackbar(
      'Đã lưu',
      'Thông tin tài khoản đã được cập nhật',
      backgroundColor: const Color(0xFF0C3D2B).withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  void changePassword() {
    Get.snackbar(
      'Đổi mật khẩu',
      'Tính năng đang được phát triển',
      backgroundColor: const Color(0xFF0C3D2B).withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  void deleteAccount() {
    Get.snackbar(
      'Xoá tài khoản',
      'Tính năng đang được phát triển',
      backgroundColor: const Color(0xFF0C3D2B).withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
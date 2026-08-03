import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/auth_service.dart';
import '../../../home_dashboard/presentation/pages/home_dashboard_page.dart';
import '../pages/login_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final currentStep = 1.obs;

  // Login Controllers
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  // Register Controllers
  final registerNameController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();

  // Forgot Password Controllers
  final forgotEmailController = TextEditingController();
  final forgotOtpController = TextEditingController();
  final forgotPasswordController = TextEditingController();
  final forgotConfirmPasswordController = TextEditingController();

  void clearFields() {
    loginEmailController.clear();
    loginPasswordController.clear();
    registerNameController.clear();
    registerEmailController.clear();
    registerPasswordController.clear();
    forgotEmailController.clear();
    forgotOtpController.clear();
    forgotPasswordController.clear();
    forgotConfirmPasswordController.clear();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
    update();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
    update();
  }

  Future<void> handleLogin() async {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập Email và Mật khẩu',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    update();
    final result = await _authService.login(email, password);
    isLoading.value = false;
    update();

    if (result['success']) {
      clearFields();
      Get.offAll(
        () => const HomeDashboardPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 400),
      );
    } else {
      Get.snackbar(
        'Đăng nhập thất bại',
        result['message'] ?? 'Email hoặc mật khẩu không đúng.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> handleGoogleLogin() async {
    isLoading.value = true;
    update();
    final result = await _authService.googleLogin();
    isLoading.value = false;
    update();

    if (result['success']) {
      clearFields();
      Get.offAll(
        () => const HomeDashboardPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 400),
      );
    } else {
      Get.snackbar(
        'Đăng nhập Google thất bại',
        result['message'],
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> handleRegister() async {
    final name = registerNameController.text.trim();
    final email = registerEmailController.text.trim();
    final password = registerPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    update();
    final result = await _authService.register(name, email, password);
    isLoading.value = false;
    update();

    if (result['success']) {
      clearFields();
      Get.offAll(() => const LoginPages());
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.snackbar('Thành công', result['message'],
            backgroundColor: Colors.green, colorText: Colors.white);
      });
    } else {
      Get.snackbar(
        'Đăng ký thất bại',
        result['message'] ?? 'Không thể đăng ký tài khoản.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> handleSendOtp() async {
    final email = forgotEmailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập email',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    update();
    final result = await _authService.forgotPassword(email);
    isLoading.value = false;
    update();

    if (result['success']) {
      currentStep.value = 2;
      update();
      Get.snackbar('Thành công', result['message'],
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar(
        'Gửi OTP thất bại',
        result['message'] ?? 'Không thể gửi mã OTP.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> handleResetPassword() async {
    final email = forgotEmailController.text.trim();
    final otp = forgotOtpController.text.trim();
    final password = forgotPasswordController.text;
    final confirmPassword = forgotConfirmPasswordController.text;

    if (otp.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('Lỗi', 'Mật khẩu xác nhận không khớp',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (password.length < 8) {
      Get.snackbar('Lỗi', 'Mật khẩu phải có ít nhất 8 ký tự',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    update();
    final result = await _authService.resetPassword(email, otp, password, confirmPassword);
    isLoading.value = false;
    update();

    if (result['success']) {
      clearFields();
      Get.snackbar('Thành công', result['message'],
          backgroundColor: Colors.green, colorText: Colors.white);
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAll(() => const LoginPages());
      });
    } else {
      Get.snackbar(
        'Đặt lại mật khẩu thất bại',
        result['message'] ?? 'Không thể đặt lại mật khẩu.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    forgotEmailController.dispose();
    forgotOtpController.dispose();
    forgotPasswordController.dispose();
    forgotConfirmPasswordController.dispose();
    super.onClose();
  }
}

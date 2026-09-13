import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:xyphora_frontend/auth/data/repositories/auth_repository.dart';
import 'package:xyphora_frontend/core/exceptions.dart';
import 'package:xyphora_frontend/home_dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:xyphora_frontend/home_dashboard/presentation/pages/home_dashboard_page.dart';
import '../pages/login_pages.dart';

class AuthController extends GetxController {
  final AuthRepository _repository;

  AuthController(this._repository);

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

  // Google Sign In
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

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
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
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
    try {
      final response = await _repository.login(email, password);
      if (response['success'] == true) {
        clearFields();
        await Get.delete<DashboardController>(force: true);
        Get.offAll(
          () => const HomeDashboardPage(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 400),
        );
      } else {
        Get.snackbar(
          'Đăng nhập thất bại',
          response['message'] ?? 'Email hoặc mật khẩu không đúng.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      String message = 'Lỗi kết nối máy chủ';
      if (e is ExceptionWithMessage) {
        message = e.mess;
      }
      Get.snackbar(
        'Đăng nhập thất bại',
        message,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleGoogleLogin() async {
    isLoading.value = true;
    try {
      try {
        await _googleSignIn.disconnect();
      } catch (_) {
        await _googleSignIn.signOut();
      }
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        Get.snackbar(
          'Đăng nhập Google thất bại',
          'Không thể lấy ID token từ Google',
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      final response = await _repository.googleLogin(idToken);
      if (response['success'] == true) {
        clearFields();
        await Get.delete<DashboardController>(force: true);
        Get.offAll(
          () => const HomeDashboardPage(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 400),
        );
      } else {
        Get.snackbar(
          'Đăng nhập Google thất bại',
          response['message'] ?? 'Đăng nhập Google thất bại',
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      String message = 'Không thể kết nối đến máy chủ';
      if (e is ExceptionWithMessage) {
        message = e.mess;
      }
      Get.snackbar(
        'Đăng nhập Google thất bại',
        message,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
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
    try {
      final response = await _repository.register(name, email, password);
      if (response['success'] == true) {
        clearFields();
        Get.offAll(() => const LoginPages());
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.snackbar('Thành công', response['message'] ?? 'Đăng ký thành công',
              backgroundColor: Colors.green, colorText: Colors.white);
        });
      } else {
        Get.snackbar(
          'Đăng ký thất bại',
          response['message'] ?? 'Không thể đăng ký tài khoản.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      String message = 'Lỗi kết nối máy chủ';
      if (e is ExceptionWithMessage) {
        message = e.mess;
      }
      Get.snackbar(
        'Đăng ký thất bại',
        message,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
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
    try {
      final response = await _repository.forgotPassword(email);
      if (response['success'] == true) {
        currentStep.value = 2;
        Get.snackbar('Thành công', response['message'] ?? 'Mã OTP đã được gửi',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar(
          'Gửi OTP thất bại',
          response['message'] ?? 'Không thể gửi mã OTP.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      String message = 'Không thể kết nối đến máy chủ';
      if (e is ExceptionWithMessage) {
        message = e.mess;
      }
      Get.snackbar(
        'Gửi OTP thất bại',
        message,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
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
    try {
      final response = await _repository.resetPassword(email, otp, password, confirmPassword);
      if (response['success'] == true) {
        clearFields();
        Get.snackbar('Thành công', response['message'] ?? 'Đặt lại mật khẩu thành công',
            backgroundColor: Colors.green, colorText: Colors.white);
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAll(() => const LoginPages());
        });
      } else {
        Get.snackbar(
          'Đặt lại mật khẩu thất bại',
          response['message'] ?? 'Không thể đặt lại mật khẩu.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      String message = 'Không thể kết nối đến máy chủ';
      if (e is ExceptionWithMessage) {
        message = e.mess;
      }
      Get.snackbar(
        'Đặt lại mật khẩu thất bại',
        message,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/presentation/pages/login_pages.dart';
import 'default_currency_controller.dart';
import 'language_controller.dart';

class SettingsController extends GetxController {
  DefaultCurrencyController get _currencyController => Get.find<DefaultCurrencyController>();
  LanguageController get _languageController => Get.find<LanguageController>();

  String get currencySubtitle {
    final selected = _currencyController.currencies.firstWhere(
      (c) => c.code == _currencyController.selectedCode.value,
      orElse: () => _currencyController.currencies.first,
    );
    return '${selected.detail.split(' · ').first} — ${selected.name}';
  }

  String get languageSubtitle {
    final selected = _languageController.languages.firstWhere(
      (l) => l.code == _languageController.selectedCode.value,
      orElse: () => _languageController.languages.first,
    );
    return selected.name;
  }

  void showComingSoon(String feature) {
    Get.snackbar(
      feature,
      'Tính năng đang được phát triển',
      backgroundColor: const Color(0xFF0C3D2B).withValues(alpha: 0.9),
      colorText: const Color(0xFFFFFFFF),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF18231E),
        title: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Bạn có chắc muốn đăng xuất khỏi tài khoản?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Huỷ', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Đăng xuất', style: TextStyle(color: Color(0xFFFF5252))),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final authRepository = Get.find<AuthRepository>();
    await authRepository.logout();
    Get.offAll(
      () => const LoginPages(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 400),
    );
  }
}

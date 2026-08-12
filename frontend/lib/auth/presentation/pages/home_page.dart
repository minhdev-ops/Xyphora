import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'login_pages.dart';
import 'register_pages.dart';

class HomePage extends GetView<AuthController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4F5E5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Text(
                'Chào mừng bạn đến với\nXyphora',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0C3D2B),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tham gia ứng dụng quản lý tài chính cá\nnhân và nhóm.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5A7563),
                  height: 1.4,
                ),
              ),
              const Spacer(),
              // Mascot Image
              Image.asset(
                'assets/images/BeDauu.png',
                height: 280,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 280,
                    width: 280,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C3D2B).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pets,
                      size: 80,
                      color: Color(0xFF0C3D2B),
                    ),
                  );
                },
              ),
              const Spacer(),
              // Google Button
              ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.handleGoogleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Image.asset(
                              'assets/images/google_logo.png',
                              height: 22,
                              width: 22,
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Tiếp tục với Google',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              // Apple Button
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  elevation: 0,
                ),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 6.0),
                      child: FaIcon(
                        FontAwesomeIcons.apple,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Tiếp tục với Apple',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Register text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chưa có tài khoản? ',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      color: const Color(0xFF5A7563),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const RegisterPages()),
                    child: Text(
                      'Đăng ký',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0C3D2B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Login text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đã có tài khoản? ',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      color: const Color(0xFF5A7563),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const LoginPages()),
                    child: Text(
                      'Đăng nhập',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0C3D2B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

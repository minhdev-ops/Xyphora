import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'home_page.dart';
import 'register_pages.dart';
import 'forgot_password_page.dart';

class LoginPages extends GetView<AuthController> {
  const LoginPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4F5E5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0C3D2B)),
          onPressed: () => Get.offAll(() => const HomePage()),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Chào mừng trở lại',
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0C3D2B),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Đăng nhập để tiếp tục quản lý tài chính cùng Sprout.',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5A7563),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              // Email Field
              _buildTextField(
                label: 'Email',
                hint: 'Nhập địa chỉ email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textController: controller.loginEmailController,
              ),
              const SizedBox(height: 20),

              // Password Field
              _buildTextField(
                label: 'Mật khẩu',
                hint: 'Nhập mật khẩu',
                icon: Icons.lock_outline,
                isPassword: true,
                textController: controller.loginPasswordController,
              ),
              
              // Quên mật khẩu
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.to(() => ForgotPasswordPage()),
                  child: Text(
                    'Quên mật khẩu?',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0C3D2B),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Login Button
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C3D2B),
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
                    : Text(
                        'Đăng nhập',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              )),
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
                    onTap: () => Get.off(() => const RegisterPages()),
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? textController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0C3D2B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C3D2B).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Obx(() => TextField(
            controller: textController,
            obscureText: isPassword && !controller.isPasswordVisible.value,
            keyboardType: keyboardType,
            style: GoogleFonts.nunito(
              color: const Color(0xFF0C3D2B),
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.nunito(
                color: const Color(0xFF5A7563).withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(icon, color: const Color(0xFF5A7563), size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF5A7563),
                        size: 20,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          )),
        ),
      ],
    );
  }
}

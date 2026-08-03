import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordPage extends GetView<AuthController> {
  ForgotPasswordPage({super.key}) {
    controller.currentStep.value = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4F5E5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0C3D2B)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: GetBuilder<AuthController>(
            builder: (auth) =>
                auth.currentStep.value == 1 ? _buildStep1() : _buildStep2(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Quên mật khẩu',
          style: GoogleFonts.nunito(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0C3D2B),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Nhập email đã đăng ký để nhận mã OTP\nđặt lại mật khẩu.',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5A7563),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 40),

        _buildTextField(
          label: 'Email',
          hint: 'Nhập địa chỉ email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textController: controller.forgotEmailController,
        ),
        const SizedBox(height: 32),

        GetBuilder<AuthController>(
          builder: (auth) => ElevatedButton(
          onPressed: auth.isLoading.value ? null : auth.handleSendOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0C3D2B),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
            elevation: 0,
          ),
          child: auth.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Gửi mã OTP',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
        ),
        const SizedBox(height: 32),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nhớ mật khẩu? ',
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: const Color(0xFF5A7563),
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () => Get.back(),
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
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Đặt lại mật khẩu',
          style: GoogleFonts.nunito(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0C3D2B),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Nhập mã OTP đã gửi đến\n${controller.forgotEmailController.text} và mật khẩu mới.',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5A7563),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 40),

        _buildTextField(
          label: 'Mã OTP',
          hint: 'Nhập mã 6 chữ số',
          icon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          textController: controller.forgotOtpController,
          maxLength: 6,
        ),
        const SizedBox(height: 20),

        _buildTextField(
          label: 'Mật khẩu mới',
          hint: 'Nhập mật khẩu mới (ít nhất 8 ký tự)',
          icon: Icons.lock_outline,
          isPassword: true,
          isConfirmPassword: false,
          textController: controller.forgotPasswordController,
        ),
        const SizedBox(height: 20),

        _buildTextField(
          label: 'Xác nhận mật khẩu',
          hint: 'Nhập lại mật khẩu mới',
          icon: Icons.lock_outline,
          isPassword: true,
          isConfirmPassword: true,
          textController: controller.forgotConfirmPasswordController,
        ),
        const SizedBox(height: 32),

        GetBuilder<AuthController>(
          builder: (auth) => ElevatedButton(
          onPressed: auth.isLoading.value ? null : auth.handleResetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0C3D2B),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
            elevation: 0,
          ),
          child: auth.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Đặt lại mật khẩu',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
        ),
        const SizedBox(height: 16),

        Center(
          child: TextButton(
            onPressed: controller.isLoading.value ? null : () {
              controller.currentStep.value = 1;
              controller.update();
            },
            child: Text(
              'Gửi lại mã OTP',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0C3D2B),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? textController,
    int? maxLength,
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
          child: GetBuilder<AuthController>(
            builder: (auth) {
            bool isVisible = isConfirmPassword ? auth.isConfirmPasswordVisible.value : auth.isPasswordVisible.value;
            return TextField(
              controller: textController,
              obscureText: isPassword && !isVisible,
              keyboardType: keyboardType,
              maxLength: maxLength,
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
                          isVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF5A7563),
                          size: 20,
                        ),
                        onPressed: () {
                          if (isConfirmPassword) {
                            auth.toggleConfirmPasswordVisibility();
                          } else {
                            auth.togglePasswordVisibility();
                          }
                        },
                      )
                    : null,
                counterText: '',
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
            );
          }),
        ),
      ],
    );
  }
}

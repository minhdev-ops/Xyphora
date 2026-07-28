import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../data/auth_service.dart';
import 'login_pages.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _currentStep = 1;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _handleSendOtp() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập email',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);
    final result = await _authService.forgotPassword(email);
    setState(() => _isLoading = false);

    if (result['success']) {
      setState(() => _currentStep = 2);
      Get.snackbar('Thành công', result['message'],
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar('Lỗi', result['message'],
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  void _handleResetPassword() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

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

    setState(() => _isLoading = true);
    final result = await _authService.resetPassword(email, otp, password, confirmPassword);
    setState(() => _isLoading = false);

    if (result['success']) {
      Get.snackbar('Thành công', result['message'],
          backgroundColor: Colors.green, colorText: Colors.white);
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAll(() => const LoginPages());
      });
    } else {
      Get.snackbar('Lỗi', result['message'],
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
          child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
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
          controller: _emailController,
        ),
        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: _isLoading ? null : _handleSendOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0C3D2B),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
            elevation: 0,
          ),
          child: _isLoading
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
          'Nhập mã OTP đã gửi đến\n${_emailController.text} và mật khẩu mới.',
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
          controller: _otpController,
          maxLength: 6,
        ),
        const SizedBox(height: 20),

        _buildTextField(
          label: 'Mật khẩu mới',
          hint: 'Nhập mật khẩu mới (ít nhất 8 ký tự)',
          icon: Icons.lock_outline,
          isPassword: true,
          isConfirmPassword: false,
          controller: _passwordController,
        ),
        const SizedBox(height: 20),

        _buildTextField(
          label: 'Xác nhận mật khẩu',
          hint: 'Nhập lại mật khẩu mới',
          icon: Icons.lock_outline,
          isPassword: true,
          isConfirmPassword: true,
          controller: _confirmPasswordController,
        ),
        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: _isLoading ? null : _handleResetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0C3D2B),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
            elevation: 0,
          ),
          child: _isLoading
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
        const SizedBox(height: 16),

        Center(
          child: TextButton(
            onPressed: _isLoading ? null : () {
              setState(() => _currentStep = 1);
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
    TextEditingController? controller,
    int? maxLength,
  }) {
    bool isVisible = isConfirmPassword ? _isConfirmPasswordVisible : _isPasswordVisible;

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
          child: TextField(
            controller: controller,
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
                        setState(() {
                          if (isConfirmPassword) {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          } else {
                            _isPasswordVisible = !_isPasswordVisible;
                          }
                        });
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
          ),
        ),
      ],
    );
  }
}

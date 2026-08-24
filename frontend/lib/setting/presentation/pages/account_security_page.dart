import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/account_security_controller.dart';
import '../widgets/custom_header.dart';

class AccountSecurityPage extends GetView<AccountSecurityController> {
  const AccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: 'Tài khoản & Bảo mật'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: const BoxDecoration(color: Color(0xFF0C3D2B), shape: BoxShape.circle),
                              child: Center(
                                child: Text('NA', style: GoogleFonts.nunito(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  //color: const Color(0xFF1E5631),
                                  color: const Color(0xFF43D08A),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Nhấn để đổi ảnh đại diện', style: GoogleFonts.nunito(color: const Color(0xFF5A7563), fontSize: 13, fontWeight: FontWeight.w600)),
                        //const Text('Nhấn để đổi ảnh đại diện', style: TextStyle(color: Color(0xFF6B7E71), fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  //
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],),
                      // border: Border.all(color: Color(0xFFE0ECE4)),),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HỌ VÀ TÊN', style: GoogleFonts.nunito(color: const Color(0xFF5A7563), fontSize: 11, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        _buildInputField(controller.nameController),
                        const SizedBox(height: 16),
                        Text('EMAIL', style: GoogleFonts.nunito(color: const Color(0xFF5A7563), fontSize: 11, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        _buildInputField(controller.emailController),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  //
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                      // border: Border.all(color: Color(0xFFE0ECE4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BẢO MẬT', style: GoogleFonts.nunito(color: const Color(0xFF5A7563), fontSize: 11, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFE0ECE4), height: 1),
                        InkWell(
                          onTap: controller.changePassword,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: Color(0xFFE2F0E5), shape: BoxShape.circle),
                                child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF0C3D2B), size: 20),
                              ),
                              const SizedBox(width: 12),
                               Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Đổi mật khẩu', style: GoogleFonts.nunito(color: const Color(0xFF0C3D2B), fontWeight: FontWeight.w800, fontSize: 15)),
                                    Text('Cập nhật mật khẩu đăng nhập', style: GoogleFonts.nunito(color: const Color(0xFF5A7563), fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: Color(0xFF8A8A8A), size: 20),
                            ],
                          ),
                        ),
                        const Divider(color: Color(0xFFECEFF1), height: 24, thickness: 1),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Color(0xFF1C2C24), shape: BoxShape.circle),
                              child: const Icon(Icons.check_circle_outline, color: Color(0xFF0C3D2B), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Xác thực 2 bước', style: GoogleFonts.nunito(color: const Color(0xFF0C3D2B), fontWeight: FontWeight.w800, fontSize: 15)),
                                  Text('Tăng bảo mật tài khoản', style: GoogleFonts.nunito(color: const Color(0xFF5A7563), fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Obx(() => Switch(
                              value: controller.is2FA.value,
                              activeThumbColor: Colors.white,
                              activeTrackColor: const Color(0xFF0C3D2B), // Xanh đậm
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: const Color(0xFFD0D0D0),
                              // activeThumbColor: const Color(0xFF43D08A),
                              onChanged: controller.toggle2FA,
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: controller.deleteAccount,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFFF5252), width: 1),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Xoá tài khoản', style: GoogleFonts.nunito(color: const Color(0xFFFF5252), fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C3D2B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Lưu thay đổi', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController inputController) {
    return TextField(
      controller: inputController,
      style: GoogleFonts.nunito(color: const Color(0xFF0C3D2B), fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0C3D2B), width: 1.5)),
      ),
    );
  }
}
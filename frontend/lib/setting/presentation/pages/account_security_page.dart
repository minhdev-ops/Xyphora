import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/account_security_controller.dart';
import '../widgets/custom_header.dart';

class AccountSecurityPage extends GetView<AccountSecurityController> {
  const AccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4F5E5),
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
                              decoration: const BoxDecoration(color: Color(0xFF143B2A), shape: BoxShape.circle),
                              child: const Center(
                                child: Text('NA', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF43D08A),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF0F1714), width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, color: Color(0xFF0F1714), size: 16),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Nhấn để đổi ảnh đại diện', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF18231E), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('HỌ VÀ TÊN', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildInputField(controller.nameController),
                        const SizedBox(height: 16),
                        const Text('EMAIL', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildInputField(controller.emailController),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF18231E), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('BẢO MẬT', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: controller.changePassword,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: Color(0xFF1C2C24), shape: BoxShape.circle),
                                child: const Icon(Icons.lock_outline, color: Color(0xFF43D08A), size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Đổi mật khẩu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                    Text('Cập nhật mật khẩu đăng nhập', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
                            ],
                          ),
                        ),
                        const Divider(color: Colors.white10, height: 24),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Color(0xFF1C2C24), shape: BoxShape.circle),
                              child: const Icon(Icons.check_circle_outline, color: Color(0xFF43D08A), size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Xác thực 2 bước', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                  Text('Tăng bảo mật tài khoản', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                ],
                              ),
                            ),
                            Obx(() => Switch(
                              value: controller.is2FA.value,
                              activeThumbColor: const Color(0xFF43D08A),
                              activeTrackColor: const Color(0xFF1B3D2F),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Xoá tài khoản', style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43D08A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Lưu thay đổi', style: TextStyle(color: Color(0xFF0F1714), fontWeight: FontWeight.bold, fontSize: 15)),
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
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF111A16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF43D08A))),
      ),
    );
  }
}
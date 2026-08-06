import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/settings_controller.dart';
import '../widgets/custom_header.dart';
import '../widgets/setting_card.dart';
import '../../../home_dashboard/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'account_security_page.dart';
import 'push_notification_page.dart';
import 'default_currency_page.dart';
import 'language_page.dart';
import 'support_feedback_page.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: 'Cài đặt', showBack: false),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                children: [
                  SettingCard(
                    icon: Icons.lock_outline_rounded,
                    iconBg: const Color(0xFFE0E0E0),
                    iconColor: const Color(0xFF0C3D2B),
                    title: 'Tài khoản & Bảo mật',
                    subtitle: 'Mật khẩu, xác thực 2 bước',
                    onTap: () => Get.to(() => const AccountSecurityPage()),
                  ),
                  SettingCard(
                    icon: Icons.notifications_none_rounded,
                    iconBg: const Color(0xFFE0E0E0),
                    iconColor: const Color(0xFFFF5360 ),//0xFFFFB74D),
                    title: 'Thông báo đẩy',
                    subtitle: 'Nhắc nhở thanh toán, cập nhật',
                    onTap: () => Get.to(() => const PushNotificationPage()),
                  ),
                  Obx(() => SettingCard(
                        icon: Icons.currency_exchange_rounded,
                        iconBg: const Color(0xFFE0E0E0),
                        iconColor: const Color(0xFF0C3D2B),
                        title: 'Tiền tệ mặc định',
                        subtitle: controller.currencySubtitle,
                        onTap: () => Get.to(() => const DefaultCurrencyPage()),
                      )),
                  SettingCard(
                    icon: Icons.file_download_outlined,
                    iconBg: const Color(0xFFE0E0E0),
                    iconColor: const Color(0xFF0C3D2B),
                    title: 'Import từ Splitwise',
                    subtitle: 'Nhập nhóm & lịch sử chi tiêu',
                    badgeText: 'Mới',
                    isHighlighted: true,
                    onTap: () => controller.showComingSoon('Import Splitwise'),
                  ),
                  SettingCard(
                    icon: Icons.file_upload_outlined,
                    iconBg: const Color(0xFFE0E0E0),
                    iconColor: const Color(0xFF0C3D2B),
                    title: 'Xuất dữ liệu CSV',
                    subtitle: 'Tải báo cáo chi tiêu',
                    onTap: () => controller.showComingSoon('Xuất CSV'),
                  ),
                  Obx(() => SettingCard(
                        icon: Icons.language_rounded,
                        iconBg: const Color(0xFFE0E0E0),
                        iconColor: const Color(0xFF0C3D2B),
                        title: 'Ngôn ngữ',
                        subtitle: controller.languageSubtitle,
                        onTap: () => Get.to(() => const LanguagePage()),
                      )),

                  SettingCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconBg: const Color(0xFFE0E0E0),
                    iconColor: const Color(0xFF0C3D2B),
                    title: 'Hỗ trợ & Phản hồi',
                    subtitle: 'Liên hệ chúng tôi',
                    onTap: () => Get.to(() => const SupportFeedbackPage()),
                  ),
                  SettingCard(
                    icon: Icons.logout_rounded,
                    iconBg: const Color(0xFFE0E0E0),
                    iconColor: const Color(0xFFFF5252),
                    title: 'Đăng xuất',
                    titleColor: const Color(0xFFFF5252),
                    isLogout: true,
                    onTap: controller.logout,
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text('Xyphora v1.0.0', style: TextStyle(color: Colors.white38, fontSize: 13)),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 3),
    );
  }
  //
  // Widget _buildSectionHeader(String title) {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 8, bottom: 8),
  //     child: Text(
  //       title,
  //       style: GoogleFonts.nunito(
  //         color: const Color(0xFF5A7563), // Chữ rêu nhạt
  //         fontSize: 12,
  //         fontWeight: FontWeight.w900,
  //       ),
  //     ),
  //   );
  // }
}

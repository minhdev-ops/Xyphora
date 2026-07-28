import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../home_dashboard/presentation/pages/home_dashboard_page.dart';
import '../../../home_dashboard/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/presentation/pages/login_pages.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/theme_mode_card.dart';
import '../widgets/category_card.dart';
import '../widgets/mascot_style_card.dart';
import '../widgets/logout_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FAF6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1D1D1D), size: 20),
          onPressed: () => Get.offAll(() => const HomeDashboardPage()),
        ),
        centerTitle: true,
        title: Text(
          'Cài đặt & Hồ sơ',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D1D1D),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const ProfileAvatar(),
            const SizedBox(height: 12),
            _buildPlaceholderBar(width: 120),
            const SizedBox(height: 8),
            _buildPlaceholderBar(width: 180),
            const SizedBox(height: 28),
            const ThemeModeCard(),
            const SizedBox(height: 16),
            const CategoryCard(),
            const SizedBox(height: 16),
            const MascotStyleCard(),
            const SizedBox(height: 24),
            LogoutButton(
              onTap: () async {
                final authService = AuthService();
                await authService.logout();
                Get.offAll(() => const LoginPages());
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderBar({required double width}) {
    return Center(
      child: Container(
        width: width,
        height: 14,
        decoration: BoxDecoration(
          color: const Color(0xFFD9E8DF),
          borderRadius: BorderRadius.circular(7),
        ),
      ),
    );
  }
}

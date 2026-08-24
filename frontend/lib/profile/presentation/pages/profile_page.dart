import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_theme.dart';
import '../../../home_dashboard/presentation/pages/home_dashboard_page.dart';
import '../../../home_dashboard/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/presentation/pages/login_pages.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/theme_mode_card.dart';
import '../widgets/category_card.dart';
import '../widgets/mascot_style_card.dart';
import '../widgets/logout_button.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      bottomNavigationBar: const CustomBottomNavBar(initialIndex: 3),
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.offAll(
            () => const HomeDashboardPage(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 300),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Ca nhat & Ho so',
          style: AppTextStyles.amountMedium,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isLoading.value) {
                return Column(
                  children: [
                    const ProfileAvatar(),
                    const SizedBox(height: 12),
                    _buildPlaceholderBar(width: 120),
                    const SizedBox(height: 8),
                    _buildPlaceholderBar(width: 180),
                  ],
                );
              }

              final prof = controller.profile.value;
              final name = prof?.name ?? 'Nguyễn Văn Minh';
              final email = prof?.email ?? 'minh.nguyen@xyphora.com';

              return Column(
                children: [
                  ProfileAvatar(name: name),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              );
            }),
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
                Get.offAll(
                  () => const LoginPages(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 400),
                );
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
          color: AppColors.primarySubtle,
          borderRadius: BorderRadius.circular(7),
        ),
      ),
    );
  }
}

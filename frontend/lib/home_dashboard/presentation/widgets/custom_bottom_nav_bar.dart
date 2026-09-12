import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_theme.dart';
import '../pages/home_dashboard_page.dart';
import '../../../statistics/presentation/pages/statistics_page.dart';
import '../../../event_management/presentation/pages/event_page.dart';
import '../../../setting/presentation/bindings/settings_binding.dart';
import '../../../setting/presentation/pages/settings_page.dart';
import '../../../statistics/presentation/bindings/statistics_binding.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int initialIndex;

  const CustomBottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTap(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Get.offAll(
        () => const HomeDashboardPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    } else if (index == 1) {
      Get.offAll(
        () => const StatisticsPage(),
        binding: StatisticsBinding(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    } else if (index == 2) {
      Get.offAll(
        () => const EventPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    } else if (index == 3) {
      Get.offAll(
        () => const SettingsPage(),
        binding: SettingsBinding(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        height: 68,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(
                icon: _selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
                label: 'Trang chủ',
                index: 0,
              ),
              _buildNavItem(
                icon: _selectedIndex == 1 ? Icons.bar_chart_rounded : Icons.bar_chart_outlined,
                label: 'Thống kê',
                index: 1,
              ),
              _buildNavItem(
                icon: _selectedIndex == 2 ? Icons.group : Icons.group_outlined,
                label: 'Sự kiện',
                index: 2,
              ),
              _buildNavItem(
                icon: _selectedIndex == 3 ? Icons.settings_rounded : Icons.settings_outlined,
                label: 'Cài đặt',
                index: 3,
              ),
            ],
          ),
        ),
      );
    }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: isSelected ? AppTextStyles.navActive : AppTextStyles.navInactive,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../pages/home_dashboard_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../event_management/presentation/pages/event_page.dart';

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
    } else if (index == 2) {
      Get.offAll(
        () => const EventPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    } else if (index == 3) {
      Get.offAll(
        () => const ProfilePage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    } else {
      setState(() => _selectedIndex = index);
      Get.snackbar(
        'Chức năng',
        'Tính năng đang được phát triển',
        backgroundColor: const Color(0xFF0C3D2B).withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
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
        height: 56,
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
                icon: Icons.bar_chart_rounded,
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
    final activeColor = const Color(0xFF0C3D2B); // Premium Dark Green
    final inactiveColor = const Color(0xFF8A8A8A); // Slate Grey

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
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

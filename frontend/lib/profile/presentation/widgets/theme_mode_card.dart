import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/app_theme.dart';
import '../controllers/profile_controller.dart';

class ThemeModeCard extends StatelessWidget {
  const ThemeModeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    final List<Color> colors = const [
      AppColors.primary,
      Color(0xFF1976D2),
      Color(0xFF424242),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.rXl,
        boxShadow: AppShadow.cardSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Doi che do',
                style: AppTextStyles.title,
              ),
              Obx(() => Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: controller.isDarkMode.value,
                  onChanged: (value) {
                    controller.isDarkMode.value = value;
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFD0D0D0),
                ),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Xanh la - Sinh thai',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              ...List.generate(colors.length, (index) {
                final isSelected = controller.selectedColor.value == index;
                return GestureDetector(
                  onTap: () {
                    controller.selectedColor.value = index;
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1D1D1D)
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: colors[index].withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                );
              }),
            ],
          )),
        ],
      ),
    );
  }
}

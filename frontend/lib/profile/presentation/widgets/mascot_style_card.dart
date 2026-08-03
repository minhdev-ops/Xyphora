import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class MascotStyleCard extends StatelessWidget {
  const MascotStyleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              controller.isMascotExpanded.value = !controller.isMascotExpanded.value;
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phong cách Linh vật',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1D1D1D),
                  ),
                ),
                Obx(() => AnimatedRotation(
                  turns: controller.isMascotExpanded.value ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF8A8A8A),
                    size: 24,
                  ),
                )),
              ],
            ),
          ),
          Obx(() => AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMascotOption(controller, 0, const Color(0xFFFFCA28)),
                  const SizedBox(width: 16),
                  _buildMascotOption(controller, 1, const Color(0xFF0F5C43)),
                  const SizedBox(width: 16),
                  _buildMascotOption(controller, 2, const Color(0xFFE53935)),
                ],
              ),
            ),
            crossFadeState: controller.isMascotExpanded.value
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          )),
        ],
      ),
    );
  }

  Widget _buildMascotOption(ProfileController controller, int index, Color accentColor) {
    final isSelected = controller.selectedMascot.value == index;
    return GestureDetector(
      onTap: () {
        controller.selectedMascot.value = index;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F5C43) : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF0F5C43).withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            'assets/images/BeDauu.png',
            fit: BoxFit.cover,
            color: accentColor.withValues(alpha: 0.6),
            colorBlendMode: BlendMode.srcATop,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.pets,
                size: 36,
                color: accentColor,
              );
            },
          ),
        ),
      ),
    );
  }
}

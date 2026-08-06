import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final bool showBack;

  const CustomHeader({
    super.key,
    required this.title,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2F0E5), // Xanh nhạt
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0C3D2B)),
              ),
            ),
          if (showBack) const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0C3D2B) // Xanh đậm
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
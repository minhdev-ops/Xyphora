import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? trailingText;
  final String? subtitle;
  final String? badgeText;
  final Color? titleColor;
  final bool isHighlighted;
  final bool isLogout;
  final VoidCallback? onTap;

  const SettingCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.trailingText,
    this.subtitle,
    this.badgeText,
    this.titleColor,
    this.isHighlighted = false,
    this.isLogout = false,
    required this.onTap,
  });

  // @override
  // Widget build(BuildContext context) {
  //   Color cardBg = const Color(0xFF18231E);
  //   Color borderColor = Colors.transparent;
  //
  //   if (isHighlighted) {
  //     cardBg = const Color(0xFF142920);
  //     borderColor = const Color(0xFF43D08A).withValues(alpha: 0.3);
  //   } else if (isLogout) {
  //     cardBg = const Color(0xFF241616);
  //     borderColor = const Color(0xFFFF5252).withValues(alpha: 0.3);
  //   }
  //
  //   return InkWell(
  //     onTap: onTap,
  //     borderRadius: BorderRadius.circular(16),
  //     child: Container(
  //       margin: const EdgeInsets.only(bottom: 12.0),
  //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
  //       decoration: BoxDecoration(
  //         color: cardBg,
  //         borderRadius: BorderRadius.circular(16.0),
  //         border: Border.all(color: borderColor, width: (isHighlighted || isLogout) ? 1.0 : 0.0),
  //       ),
  //       child: Row(
  //         children: [
  //           Container(
  //             width: 42,
  //             height: 42,
  //             decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
  //             child: Icon(icon, color: iconColor, size: 22),
  //           ),
  //           const SizedBox(width: 14),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: titleColor ?? Colors.white)),
  //                 if (subtitle != null) ...[
  //                   const SizedBox(height: 3),
  //                   Text(subtitle!, style: const TextStyle(fontSize: 12, color: Colors.white54)),
  //                 ],
  //               ],
  //             ),
  //           ),
  //           if (badgeText != null)
  //             Container(
  //               margin: const EdgeInsets.only(right: 8),
  //               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFF0D3321),
  //                 borderRadius: BorderRadius.circular(12),
  //                 border: Border.all(color: const Color(0xFF43D08A), width: 1),
  //               ),
  //               child: Text(badgeText!, style: const TextStyle(color: Color(0xFF43D08A), fontSize: 11, fontWeight: FontWeight.bold)),
  //             ),
  //           Icon(Icons.chevron_right_rounded, color: isLogout ? const Color(0xFFFF5252) : Colors.white38, size: 20),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white, // Nền card trắng
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)), // Đổ bóng siêu nhẹ
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFE2F0E5), // Vòng tròn icon màu xanh nhạt
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF0C3D2B), size: 20), // Icon xanh đậm
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0C3D2B), // Chữ xanh đậm
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText!,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5A7563), // Chữ phụ màu xanh rêu nhạt
                ),
              ),
            if (trailingText != null) const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF8A8A8A),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

}
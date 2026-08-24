import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// AppColors - Centralized color palette
// =============================================================================
class AppColors {
  AppColors._();

  // --- Primary ---
  static const Color primary = Color(0xFF0C3D2B);
  static const Color primaryLight = Color(0xFFE2F0E5);
  static const Color primaryDark = Color(0xFF083C25);
  static const Color primarySubtle = Color(0xFFD9E8DF);

  // --- Background ---
  static const Color scaffoldBg = Color(0xFFF4FAF6);
  static const Color cardBg = Colors.white;
  static const Color inputBg = Color(0xFFE2F0E5);
  static const Color divider = Color(0xFFCBE0D1);
  static const Color borderLight = Color(0xFFE0E0E0);

  // --- Text ---
  static const Color textPrimary = Color(0xFF0C3D2B);
  static const Color textSecondary = Color(0xFF5A7563);
  static const Color textTertiary = Color(0xFF8A8A8A);
  static const Color textOnPrimary = Colors.white;

  // --- Status ---
  static const Color error = Color(0xFFD32F2F);
  static const Color errorDark = Color(0xFFC62828);
  static const Color errorBg = Color(0xFFFBEBEB);
  static const Color errorBorder = Color(0xFFEFD7D7);
  static const Color success = Color(0xFF1B9B5A);
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFE07B39);
  static const Color warningBg = Color(0xFFFFF3E0);

  // --- Google ---
  static const Color googleBlue = Color(0xFF4285F4);

  // --- Category Colors ---
  static const Color catRed = Color(0xFFEF4444);
  static const Color catOrange = Color(0xFFF97316);
  static const Color catYellow = Color(0xFFF59E0B);
  static const Color catGreen = Color(0xFF22C55E);
  static const Color catTeal = Color(0xFF10B981);
  static const Color catCyan = Color(0xFF06B6D4);
  static const Color catBlue = Color(0xFF3B82F6);
  static const Color catPurple = Color(0xFF8B5CF6);
  static const Color catPink = Color(0xFFEC4899);
  static const Color catGrey = Color(0xFF64748B);

  static const List<Color> categoryColors = [
    catRed,
    catOrange,
    catYellow,
    catGreen,
    catTeal,
    catCyan,
    catBlue,
    catPurple,
    catPink,
    catGrey,
  ];
}

// =============================================================================
// AppTextStyles - Centralized typography
// =============================================================================
class AppTextStyles {
  AppTextStyles._();

  // --- Headings ---
  static TextStyle heading1 = GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static TextStyle heading2 = GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static TextStyle heading3 = GoogleFonts.nunito(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  // --- Titles ---
  static TextStyle titleLarge = GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle title = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle titleMedium = GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // --- Body ---
  static TextStyle body = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySecondary = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  // --- Subtitles & Captions ---
  static TextStyle subtitle = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle caption = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
  );

  static TextStyle small = GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
  );

  // --- Badges ---
  static TextStyle badge = GoogleFonts.nunito(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle badgeSmall = GoogleFonts.nunito(
    fontSize: 9,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  // --- Amounts ---
  static TextStyle amountHero = GoogleFonts.nunito(
    fontSize: 34,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle amountLarge = GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static TextStyle amountMedium = GoogleFonts.nunito(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle amountSmall = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle amountTiny = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  // --- Button ---
  static TextStyle buttonPrimary = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.textOnPrimary,
  );

  static TextStyle buttonSecondary = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // --- Nav ---
  static TextStyle navActive = GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static TextStyle navInactive = GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
  );
}

// =============================================================================
// AppSpacing - Centralized spacing
// =============================================================================
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

// =============================================================================
// AppRadius - Centralized border radius
// =============================================================================
class AppRadius {
  AppRadius._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 25;
  static const double full = 50;

  static BorderRadius get rXs => BorderRadius.circular(xs);
  static BorderRadius get rSm => BorderRadius.circular(sm);
  static BorderRadius get rMd => BorderRadius.circular(md);
  static BorderRadius get rLg => BorderRadius.circular(lg);
  static BorderRadius get rXl => BorderRadius.circular(xl);
  static BorderRadius get rXxl => BorderRadius.circular(xxl);
  static BorderRadius get rPill => BorderRadius.circular(pill);
  static BorderRadius get rFull => BorderRadius.circular(full);
}

// =============================================================================
// AppShadow - Centralized shadows
// =============================================================================
class AppShadow {
  AppShadow._();

  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardSoft = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> fab = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
}

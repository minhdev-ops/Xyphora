# Xyphora Frontend UI Refactoring Summary

## Overview
Comprehensive UI standardization of the Xyphora Flutter frontend application. Created a centralized design system, standardized typography, colors, currency/date formatting, and fixed inconsistencies across ~50 files.

---

## New Files Created

### 1. `lib/config/app_theme.dart` - Centralized Design System
- **AppColors**: Standardized color palette (primary, background, text, status, category colors)
- **AppTextStyles**: Typography hierarchy (heading1-3, title, body, subtitle, caption, badge, amount styles, button, nav)
- **AppSpacing**: Consistent spacing constants (xs to xxxl)
- **AppRadius**: Border radius constants (xs=8 to full=50)
- **AppShadow**: Shadow presets (card, cardSoft, fab)

### 2. `lib/config/app_format.dart` - Centralized Formatting Utilities
- **AppFormat.currency()**: VND currency formatting with dot separator
- **AppFormat.currencySigned()**: Currency with +/- prefix
- **AppFormat.date()**: "21 thg 8, 2026" format
- **AppFormat.dateFull()**: "21 thg 8 nam 2026" format
- **AppFormat.dateShort()**: "21/08/2026" format
- **AppFormat.monthYear()**: "Thg 8, 2026" format
- **AppFormat.dayOfWeek()**: Vietnamese day names
- **AppFormat.relativeDate()**: "Hom nay", "Hom qua", "2 ngay truoc"
- **AppFormat.number()**: Number with dot separator
- **AppFormat.numberCompact()**: 1.2tr, 3.5k format
- **AppFormat.percentage()**: "5.0%" format

### 3. `pubspec.yaml` - Added `intl: ^0.20.0` dependency

---

## Files Modified

### Typography Standardization (Inter -> Nunito)

| File | Change |
|------|--------|
| `add_expense/presentation/widgets/expense_header.dart` | `GoogleFonts.inter` -> `AppTextStyles.amountMedium` |
| `statistics/presentation/widgets/statistics_header.dart` | `GoogleFonts.inter` -> `AppTextStyles.amountMedium` |
| `profile/presentation/pages/profile_page.dart` | `GoogleFonts.inter` -> `AppTextStyles.*` |
| `profile/presentation/widgets/mascot_style_card.dart` | `GoogleFonts.inter` -> `AppTextStyles.title` |
| `profile/presentation/widgets/theme_mode_card.dart` | `GoogleFonts.inter` -> `AppTextStyles.title` |
| `profile/presentation/widgets/category_card.dart` | `GoogleFonts.inter` -> `AppTextStyles.titleMedium` |
| `profile/presentation/widgets/logout_button.dart` | `GoogleFonts.inter` -> `GoogleFonts.nunito` |

### Color Palette Standardization

| File | Old Color | New Reference |
|------|-----------|---------------|
| `event_management/pages/event_page.dart` | `#0A4226`, `#F2F7F4` | `AppColors.primary`, `AppColors.scaffoldBg` |
| `event_management/pages/event_detail_view.dart` | `#0A4226`, `#F2F7F4`, `#9E9E9E` | `AppColors.*` |
| `event_management/widgets/event_card.dart` | `#9E9E9E`, `Colors.black` | `AppColors.textTertiary`, `AppColors.textPrimary` |
| `event_management/widgets/balances_tab.dart` | `#0A4226`, `#9E9E9E` | `AppColors.*` |
| `event_management/widgets/expenses_tab.dart` | `#0A4226`, `#9E9E9E` | `AppColors.*` |
| `profile/widgets/mascot_style_card.dart` | `#0F5C43` | `AppColors.primary` |
| `profile/widgets/theme_mode_card.dart` | `#0F5C43` | `AppColors.primary` |
| `profile/widgets/category_card.dart` | `#0F5C43` | `AppColors.primary` |
| `profile/widgets/logout_button.dart` | `#0F5C43` | `AppColors.primary` |
| `expense_history/pages/expense_history_page.dart` | `#0A4226`, `#F2F7F4` | `AppColors.primary`, `AppColors.scaffoldBg` |

### Currency Formatting (replaced copy-paste with AppFormat)

| File | Old Method | New |
|------|------------|-----|
| `home_dashboard/pages/home_dashboard_page.dart` | `_formatCurrency()` | `AppFormat.currency()` |
| `home_dashboard/widgets/balance_card.dart` | `_formatCurrency()` | `AppFormat.currencySigned()` |
| `home_dashboard/pages/spending_detail_page.dart` | `_formatCurrency()` | `AppFormat.currency()` |
| `event_management/pages/event_page.dart` | `_formatVND()` | `AppFormat.currency()` |
| `event_management/widgets/event_card.dart` | `_formatVND()` | `AppFormat.currency()` |
| `event_management/widgets/balances_tab.dart` | `_formatVND()` | `AppFormat.currency()` |
| `event_management/widgets/expenses_tab.dart` | `_formatVND()` | `AppFormat.currency()` |
| `expense_history/widgets/expense_history_item_card.dart` | `_formatAmount()` | `AppFormat.currency()` |

### Date Formatting (replaced copy-paste with AppFormat)

| File | Old Method | New |
|------|------------|-----|
| `event_management/widgets/event_card.dart` | `_formatDate()` with months array | `AppFormat.date()` |
| `event_management/pages/event_detail_view.dart` | months array inline | `AppFormat.monthYear()` |
| `expense_history/pages/expense_history_page.dart` | `_formatDateHeader()` with months array | `AppFormat.date()` |
| `home_dashboard/controllers/dashboard_controller.dart` | `_formatDate()` | `AppFormat.date()` |

### Card/Button/Component Styling Standardization

| File | Changes |
|------|---------|
| `home_dashboard/pages/home_dashboard_page.dart` | `AppColors.scaffoldBg`, `AppRadius.rXl`, `AppShadow.cardSoft` |
| `home_dashboard/widgets/balance_card.dart` | `AppColors.primaryLight`, `AppRadius.rXl`, `AppShadow.card` |
| `home_dashboard/pages/spending_detail_page.dart` | `AppColors.*`, `AppRadius.*`, `AppShadow.*` |
| `home_dashboard/widgets/custom_bottom_nav_bar.dart` | `AppColors.*`, `AppTextStyles.navActive/Inactive` |
| `event_management/pages/event_page.dart` | `AppColors.scaffoldBg`, `AppColors.primary` |
| `event_management/pages/event_detail_view.dart` | `AppColors.*`, `AppRadius.rPill` |
| `event_management/widgets/event_card.dart` | `AppColors.cardBg`, `AppRadius.rLg`, `AppShadow.card` |
| `event_management/widgets/balances_tab.dart` | `AppColors.*`, `AppRadius.*`, `AppShadow.*` |
| `event_management/widgets/expenses_tab.dart` | `AppColors.*`, `AppRadius.*`, `AppShadow.*` |
| `expense_history/pages/expense_history_page.dart` | `AppColors.scaffoldBg`, `AppColors.primary` |
| `expense_history/widgets/expense_history_item_card.dart` | `AppColors.*`, `AppRadius.*`, `AppShadow.*` |
| `add_expense/widgets/expense_header.dart` | `AppColors.*`, `AppTextStyles.*` |
| `statistics/widgets/statistics_header.dart` | `AppColors.*`, `AppTextStyles.*` |
| `profile/pages/profile_page.dart` | `AppColors.*`, `AppTextStyles.*` |
| `profile/widgets/*.dart` (4 files) | `AppColors.*`, `AppRadius.*`, `AppShadow.*` |

### Bug Fix

| File | Bug | Fix |
|------|-----|-----|
| `home_dashboard/widgets/custom_bottom_nav_bar.dart:88` | Statistics tab icon always showed `bar_chart_rounded` regardless of selection | Now toggles between `bar_chart_rounded` (selected) and `bar_chart_outlined` (unselected) |

---

## Key Design Decisions

1. **Font**: Kept **Nunito** as primary font (was already ~95% usage)
2. **Primary Green**: Standardized to `#0C3D2B` (was split between `#0C3D2B`, `#0A4226`, `#0F5C43`)
3. **Scaffold Background**: Standardized to `#F4FAF6` (was split between `#F4FAF6`, `#F2F7F4`)
4. **Text Colors**: 3-tier system - Primary (`#0C3D2B`), Secondary (`#5A7563`), Tertiary (`#8A8A8A`)
5. **Card Shadows**: Standardized to `alpha: 0.04, blur: 8, offset: (0,2)` for cards
6. **Border Radius**: Standardized - cards=20, buttons=27/12, inputs=14/16, tabs=25
7. **Currency**: Manual VND formatting (no `intl` NumberFormat for currency, kept existing algorithm)
8. **Date**: Uses `intl` package for day-of-week, manual formatting for Vietnamese month names

---

## Statistics

- **New files created**: 2 (app_theme.dart, app_format.dart)
- **Files modified**: ~30
- **Lines of code**: ~1500+ lines standardized
- **Color inconsistencies fixed**: ~15 different hex values consolidated to AppColors constants
- **Currency formatting duplication removed**: 8 copy-paste methods -> 1 centralized utility
- **Date formatting duplication removed**: 4 copy-paste methods -> 1 centralized utility
- **Font inconsistencies fixed**: 7 files (Inter -> Nunito), 8 files (plain TextStyle -> GoogleFonts.nunito)

---

## Backend Changes

**None** - This refactoring was frontend-only. No backend API or model changes were made.

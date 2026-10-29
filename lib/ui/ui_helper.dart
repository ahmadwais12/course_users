import 'package:flutter/material.dart';
import 'package:course_users/theme.dart';

// =============================================================================
// TEXT STYLE EXTENSIONS
// =============================================================================

extension UITextContext on BuildContext {
  TextTheme get tt => Theme.of(this).textTheme;
  ColorScheme get cs => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get primaryText => isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
  Color get secondaryText => isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
  Color get hintText => isDark ? AppColors.darkHint : AppColors.lightHint;
  Color get dividerClr => isDark ? AppColors.darkDivider : AppColors.lightDivider;
  Color get surfaceClr => isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get successClr => isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
  Color get errorClr => isDark ? AppColors.darkError : AppColors.lightError;

  Color accentClr(Color color) => color.withValues(alpha: 0.1);
  Color muted(Color color) => color.withValues(alpha: 0.6);
}

// =============================================================================
// TEXT STYLE SHORTCUTS
// =============================================================================

class AppText {
  static TextStyle h1({Color? color, BuildContext? ctx}) => TextStyle(
    fontSize: 32, fontWeight: FontWeight.w700, height: 1.2,
    color: color ?? ctx?.primaryText,
  );
  static TextStyle h2({Color? color, BuildContext? ctx}) => TextStyle(
    fontSize: 26, fontWeight: FontWeight.w600, height: 1.25,
    color: color ?? ctx?.primaryText,
  );
  static TextStyle h3({Color? color, BuildContext? ctx}) => TextStyle(
    fontSize: 20, fontWeight: FontWeight.w600, height: 1.3,
    color: color ?? ctx?.primaryText,
  );
  static TextStyle h4({Color? color, BuildContext? ctx}) => TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, height: 1.4,
    color: color ?? ctx?.secondaryText,
  );
  static TextStyle body({Color? color, BuildContext? ctx}) => TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.5,
    color: color ?? ctx?.secondaryText,
  );
  static TextStyle bodySm({Color? color, BuildContext? ctx}) => TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, height: 1.4,
    color: color ?? ctx?.hintText,
  );
  static TextStyle caption({Color? color, BuildContext? ctx}) => TextStyle(
    fontSize: 10, fontWeight: FontWeight.w500, height: 1.2,
    color: color ?? ctx?.hintText.withValues(alpha: 0.7),
  );
  static TextStyle label({Color? color, BuildContext? ctx}) => TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, height: 1.2,
    color: color ?? ctx?.secondaryText,
  );
}

// =============================================================================
// SHADOW HELPERS
// =============================================================================

class AppShadows {
  static BoxShadow soft(Color color) => BoxShadow(
    color: color.withValues(alpha: 0.05),
    blurRadius: 12, offset: const Offset(0, 4),
  );
  static BoxShadow medium(Color color) => BoxShadow(
    color: color.withValues(alpha: 0.1),
    blurRadius: 20, offset: const Offset(0, 8),
  );
  static BoxShadow strong(Color color) => BoxShadow(
    color: color.withValues(alpha: 0.15),
    blurRadius: 28, offset: const Offset(0, 12),
  );
}

// =============================================================================
// DECORATION HELPERS
// =============================================================================

class AppDecoration {
  static BoxDecoration card(BuildContext context) => BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
    boxShadow: [AppShadows.soft(Theme.of(context).shadowColor)],
  );

  static BoxDecoration elevated(BuildContext context) => BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(AppRadius.md),
    boxShadow: [AppShadows.medium(Theme.of(context).shadowColor)],
  );

  static BoxDecoration iconBadge(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(AppRadius.sm),
  );

  static BoxDecoration coloredIcon(Color color, {double size = 40}) => BoxDecoration(
    color: color.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(12),
  );

  static BoxDecoration gradientCard({
    required Color start,
    required Color end,
    bool vertical = false,
  }) => BoxDecoration(
    gradient: LinearGradient(
      begin: vertical ? Alignment.topCenter : Alignment.centerLeft,
      end: vertical ? Alignment.bottomCenter : Alignment.centerRight,
      colors: [start, end],
    ),
    borderRadius: BorderRadius.circular(AppRadius.md),
  );

  static BoxDecoration glass(BuildContext context) => BoxDecoration(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: Border.all(
      color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
    ),
  );
}

// =============================================================================
// PADDING HELPERS
// =============================================================================

class AppPad {
  static const EdgeInsets a4 = EdgeInsets.all(4);
  static const EdgeInsets a8 = EdgeInsets.all(8);
  static const EdgeInsets a12 = EdgeInsets.all(12);
  static const EdgeInsets a16 = EdgeInsets.all(16);
  static const EdgeInsets a20 = EdgeInsets.all(20);
  static const EdgeInsets a24 = EdgeInsets.all(24);

  static const EdgeInsets h8 = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets h12 = EdgeInsets.symmetric(horizontal: 12);
  static const EdgeInsets h16 = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets h20 = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets h24 = EdgeInsets.symmetric(horizontal: 24);

  static const EdgeInsets v4 = EdgeInsets.symmetric(vertical: 4);
  static const EdgeInsets v8 = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets v12 = EdgeInsets.symmetric(vertical: 12);
  static const EdgeInsets v16 = EdgeInsets.symmetric(vertical: 16);

  static const EdgeInsets sym8 = EdgeInsets.symmetric(horizontal: 8, vertical: 8);
  static const EdgeInsets sym12 = EdgeInsets.symmetric(horizontal: 12, vertical: 12);
  static const EdgeInsets sym16 = EdgeInsets.symmetric(horizontal: 16, vertical: 16);
}

// =============================================================================
// GAP HELPERS
// =============================================================================

class Gap {
  static const Widget w4 = SizedBox(width: 4);
  static const Widget w8 = SizedBox(width: 8);
  static const Widget w12 = SizedBox(width: 12);
  static const Widget w16 = SizedBox(width: 16);
  static const Widget h4 = SizedBox(height: 4);
  static const Widget h8 = SizedBox(height: 8);
  static const Widget h12 = SizedBox(height: 12);
  static const Widget h16 = SizedBox(height: 16);
  static const Widget h20 = SizedBox(height: 20);
  static const Widget h24 = SizedBox(height: 24);
  static const Widget h32 = SizedBox(height: 32);
}

import 'package:flutter/material.dart';

/// App color palette following agricultural theme
/// Colors evoke agriculture: greens for growth, yellows for sunlight, browns for soil
/// High contrast design ensures accessibility and readability
class AppColors {
  // === PRIMARY AGRICULTURAL PALETTE ===

  /// Deep green (#008000) - Primary brand color, evoking lush fields
  /// Used for: App bar background, primary buttons, main branding
  static const Color deepGreen = Color(0xFF008000);

  /// Olive green (#4A7043) - Secondary green, like mature leaves
  /// Used for: Welcome cards, secondary surfaces, accent elements
  static const Color oliveGreen = Color(0xFF4A7043);

  /// Lime green (#66B032) - Fresh growth color, like new sprouts
  /// Used for: Progress indicators, success states, plant icons
  static const Color limeGreen = Color(0xFF66B032);

  /// Bright yellow (#FFDE21) - Sunlight color
  /// Used for: FAB, CTA buttons, highlights, trailing icons
  static const Color brightYellow = Color(0xFFFFDE21);

  /// Golden yellow (#F5C107) - Warm sunlight variant
  /// Used for: Hover states, active elements, secondary highlights
  static const Color goldenYellow = Color(0xFFF5C107);

  /// Earthy brown (#8B5A2B) - Soil color
  /// Used for: Borders, dividers, earth-related elements
  static const Color earthyBrown = Color(0xFF8B5A2B);

  // === NEUTRAL PALETTE ===

  /// Soft white (#F8F9F2) - Morning mist color
  /// Used for: Main background, card backgrounds, primary text on dark
  static const Color softWhite = Color(0xFFF8F9F2);

  /// Slate gray (#4A4A4A) - Professional text color
  /// Used for: Primary text, titles, icons on light backgrounds
  static const Color slateGray = Color(0xFF4A4A4A);

  /// Light gray (#D3D3D3) - Subtle elements
  /// Used for: Subtitles, disabled text, progress bar backgrounds
  static const Color lightGray = Color(0xFFD3D3D3);

  /// Pure white (#FFFFFF) - Clean backgrounds
  /// Used for: Pure white surfaces, contrast elements
  static const Color pureWhite = Color(0xFFFFFFFF);

  // === SEMANTIC COLORS ===

  /// Success color - Uses lime green for positive states
  static const Color success = limeGreen;

  /// Warning color - Warm orange for caution
  static const Color warning = Color(0xFFFF9800);

  /// Error color - Red for errors and danger
  static const Color error = Color(0xFFD32F2F);

  /// Info color - Blue for information
  static const Color info = Color(0xFF2196F3);

  // === LIGHT THEME COLORS ===

  /// Primary color for light theme
  static const Color lightPrimary = deepGreen;

  /// Secondary color for light theme
  static const Color lightSecondary = oliveGreen;

  /// Tertiary color for light theme
  static const Color lightTertiary = brightYellow;

  /// Background color for light theme
  static const Color lightBackground = softWhite;

  /// Surface color for light theme
  static const Color lightSurface = pureWhite;

  /// Surface variant for light theme
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);

  /// Text color on light backgrounds
  static const Color lightOnBackground = slateGray;

  /// Text color on light surfaces
  static const Color lightOnSurface = slateGray;

  /// Text color on primary (light theme)
  static const Color lightOnPrimary = softWhite;

  /// Text color on secondary (light theme)
  static const Color lightOnSecondary = softWhite;

  /// Text color on tertiary (light theme)
  static const Color lightOnTertiary = slateGray;

  // === DARK THEME COLORS ===

  /// Primary color for dark theme
  static const Color darkPrimary = limeGreen;

  /// Secondary color for dark theme
  static const Color darkSecondary = Color(0xFF6B8E5A);

  /// Tertiary color for dark theme
  static const Color darkTertiary = goldenYellow;

  /// Background color for dark theme
  static const Color darkBackground = Color(0xFF121212);

  /// Surface color for dark theme
  static const Color darkSurface = Color(0xFF1E1E1E);

  /// Surface variant for dark theme
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);

  /// Text color on dark backgrounds
  static const Color darkOnBackground = softWhite;

  /// Text color on dark surfaces
  static const Color darkOnSurface = softWhite;

  /// Text color on primary (dark theme)
  static const Color darkOnPrimary = slateGray;

  /// Text color on secondary (dark theme)
  static const Color darkOnSecondary = softWhite;

  /// Text color on tertiary (dark theme)
  static const Color darkOnTertiary = slateGray;

  // === OUTLINE COLORS ===

  /// Outline color for light theme
  static const Color outlineLight = lightGray;

  /// Outline color for dark theme
  static const Color outlineDark = Color(0xFF404040);

  /// Outline variant for light theme
  static const Color outlineVariantLight = Color(0xFFF0F0F0);

  /// Outline variant for dark theme
  static const Color outlineVariantDark = Color(0xFF353535);

  // === SURFACE VARIANT COLORS ===

  /// Surface variant text color for light theme
  static const Color lightOnSurfaceVariant = Color(0xFF666666);

  /// Surface variant text color for dark theme
  static const Color darkOnSurfaceVariant = Color(0xFFB3B3B3);

  // === AGRICULTURAL SPECIFIC COLORS ===

  /// Crop health good - Uses lime green for healthy crops
  static const Color cropHealthGood = limeGreen;

  /// Crop health warning - Uses warning color for caution
  static const Color cropHealthWarning = warning;

  /// Crop health poor - Uses error color for poor health
  static const Color cropHealthPoor = error;

  /// Soil moisture indicator - Blue for water content
  static const Color soilMoisture = info;

  /// Temperature indicator - Orange for heat
  static const Color temperature = Color(0xFFFF6B35);

  /// Rainfall indicator - Blue for precipitation
  static const Color rainfall = Color(0xFF4A90E2);

  // === LEGACY COLOR MAPPINGS ===
  // These maintain compatibility with existing code

  /// Legacy primary green mapping
  static const Color primaryGreen = deepGreen;

  /// Legacy secondary green mapping
  static const Color secondaryGreen = limeGreen;

  /// Legacy accent green mapping
  static const Color accentGreen = oliveGreen;

  /// Legacy success green mapping
  static const Color successGreen = limeGreen;

  /// Legacy primary blue mapping
  static const Color primaryBlue = info;

  /// Legacy error light mapping
  static const Color errorLight = error;

  /// Legacy error dark mapping
  static const Color errorDark = Color(0xFFEF5350);

  // === GRADIENT DEFINITIONS ===

  /// Primary gradient using agricultural greens
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepGreen, oliveGreen],
  );

  /// Success gradient using growth colors
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [limeGreen, deepGreen],
  );

  /// Info gradient using blue tones
  static const LinearGradient infoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [info, Color(0xFF64B5F6)],
  );

  /// Sunlight gradient using yellow tones
  static const LinearGradient sunlightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brightYellow, goldenYellow],
  );

  /// Earth gradient using brown and green tones
  static const LinearGradient earthGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [earthyBrown, oliveGreen],
  );

  // === COMPONENT SPECIFIC COLORS ===

  /// App bar background color
  static const Color appBarBackground = deepGreen;

  /// App bar text color
  static const Color appBarText = softWhite;

  /// FAB background color
  static const Color fabBackground = brightYellow;

  /// FAB icon color
  static const Color fabIcon = slateGray;

  /// Card border color
  static const Color cardBorder = earthyBrown;

  /// Progress bar active color
  static const Color progressActive = limeGreen;

  /// Progress bar background color
  static const Color progressBackground = lightGray;

  /// CTA button outline color
  static const Color ctaOutline = brightYellow;

  /// CTA button text color
  static const Color ctaText = brightYellow;

  /// Plant icon color
  static const Color plantIcon = limeGreen;

  /// Trailing arrow color
  static const Color trailingArrow = brightYellow;
}

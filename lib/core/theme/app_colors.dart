import 'package:flutter/material.dart';

/// App color palette following agricultural theme
/// Colors are designed for both accessibility and visual appeal
class AppColors {
  // Primary Colors - Agricultural Green Palette
  static const Color primaryGreen = Color(0xFF00623A);      // Deep forest green - primary brand color
  static const Color secondaryGreen = Color(0xFF02B729);    // Vibrant green - secondary actions
  static const Color accentGreen = Color(0xFF4DAC85);       // Muted green - accents and highlights
  static const Color successGreen = Color(0xFF00D27D);      // Success states and positive actions
  
  // Supporting Colors
  static const Color primaryBlue = Color(0xFF37B7FF);       // Information and links
  static const Color pureWhite = Color(0xFFFFFFFF);         // Pure white for backgrounds
  static const Color richBlack = Color(0xFF181818);         // Rich black for text and dark themes
  
  // Light Theme Semantic Colors
  static const Color lightBackground = pureWhite;
  static const Color lightSurface = Color(0xFFFAFAFA);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  static const Color lightOnBackground = richBlack;
  static const Color lightOnSurface = Color(0xFF1C1C1C);
  static const Color lightOnSurfaceVariant = Color(0xFF666666);
  
  // Dark Theme Semantic Colors
  static const Color darkBackground = richBlack;
  static const Color darkSurface = Color(0xFF242424);
  static const Color darkSurfaceVariant = Color(0xFF2F2F2F);
  static const Color darkOnBackground = pureWhite;
  static const Color darkOnSurface = Color(0xFFE8E8E8);
  static const Color darkOnSurfaceVariant = Color(0xFFB3B3B3);
  
  // Error Colors
  static const Color errorLight = Color(0xFFD32F2F);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color onErrorLight = pureWhite;
  static const Color onErrorDark = richBlack;
  
  // Warning Colors
  static const Color warningLight = Color(0xFFF57C00);
  static const Color warningDark = Color(0xFFFFB74D);
  
  // Outline Colors
  static const Color outlineLight = Color(0xFFE0E0E0);
  static const Color outlineDark = Color(0xFF404040);
  static const Color outlineVariantLight = Color(0xFFF0F0F0);
  static const Color outlineVariantDark = Color(0xFF353535);
  
  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x40000000);
  
  // Scrim Colors
  static const Color scrimLight = Color(0x66000000);
  static const Color scrimDark = Color(0x80000000);
  
  // Inverse Colors
  static const Color inverseSurfaceLight = Color(0xFF2F2F2F);
  static const Color inverseSurfaceDark = Color(0xFFE8E8E8);
  static const Color inverseOnSurfaceLight = Color(0xFFE8E8E8);
  static const Color inverseOnSurfaceDark = Color(0xFF2F2F2F);
  
  // Surface Tint
  static const Color surfaceTintLight = primaryGreen;
  static const Color surfaceTintDark = accentGreen;
  
  // Disabled Colors
  static const Color disabledLight = Color(0x61000000);
  static const Color disabledDark = Color(0x61FFFFFF);
  
  // Agricultural specific colors for data visualization
  static const Color cropHealthGood = successGreen;
  static const Color cropHealthWarning = warningLight;
  static const Color cropHealthPoor = errorLight;
  static const Color soilMoisture = primaryBlue;
  static const Color temperature = Color(0xFFFF6B35);
  static const Color rainfall = Color(0xFF4A90E2);
  
  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, accentGreen],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successGreen, secondaryGreen],
  );
  
  static const LinearGradient infoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, Color(0xFF64B5F6)],
  );
}

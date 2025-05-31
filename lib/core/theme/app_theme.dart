import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'theme_extensions.dart';

/// App theme configuration using FlexColorScheme
/// Provides both light and dark themes with agricultural color palette
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      // Color scheme configuration
      scheme: FlexScheme.custom,
      colors: const FlexSchemeColor(
        primary: AppColors.primaryGreen,
        primaryContainer: Color(0xFFE8F5E8),
        secondary: AppColors.secondaryGreen,
        secondaryContainer: Color(0xFFE8F8E8),
        tertiary: AppColors.accentGreen,
        tertiaryContainer: Color(0xFFE8F4F0),
        appBarColor: AppColors.lightBackground,
        error: AppColors.errorLight,
        errorContainer: Color(0xFFFFEBEE),
      ),
      textTheme: AppTypography.lightTextTheme,
      // Surface and background colors
      surface: AppColors.lightSurface,
      scaffoldBackground: AppColors.lightBackground,

      // AppBar configuration
      appBarStyle: FlexAppBarStyle.surface,
      appBarOpacity: 1.0,
      appBarElevation: 0,

      // Tab bar configuration
      tabBarStyle: FlexTabBarStyle.forAppBar,

      // Surface mode for better color consistency
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,

      // Visual density for better touch targets
      visualDensity: FlexColorScheme.comfortablePlatformDensity,

      // Typography
      fontFamily: GoogleFonts.inter().fontFamily,

      // Component themes
      subThemesData: const FlexSubThemesData(
        // General
        useMaterial3Typography: true,
        useM2StyleDividerInM3: false,

        // AppBar
        appBarCenterTitle: true,
        appBarScrolledUnderElevation: 2,

        // Bottom Navigation
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor:
            SchemeColor.onSurfaceVariant,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedIconSchemeColor:
            SchemeColor.onSurfaceVariant,

        // Navigation Rail
        navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
        navigationRailUnselectedLabelSchemeColor: SchemeColor.onSurfaceVariant,
        navigationRailSelectedIconSchemeColor: SchemeColor.primary,
        navigationRailUnselectedIconSchemeColor: SchemeColor.onSurfaceVariant,

        // Button themes
        elevatedButtonRadius: 12,
        elevatedButtonElevation: 2,
        elevatedButtonSchemeColor: SchemeColor.primary,

        filledButtonRadius: 12,

        outlinedButtonRadius: 12,
        outlinedButtonOutlineSchemeColor: SchemeColor.primary,

        textButtonRadius: 12,

        // Card theme
        cardRadius: 16,
        cardElevation: 2,

        // Input decoration
        inputDecoratorRadius: 12,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorFocusedHasBorder: true,
        inputDecoratorUnfocusedHasBorder: true,

        // FAB
        fabRadius: 16,
        fabUseShape: true,
        fabSchemeColor: SchemeColor.primary,

        // Chip
        chipRadius: 8,
        chipSchemeColor: SchemeColor.primaryContainer,

        // Dialog
        dialogRadius: 20,
        dialogElevation: 6,

        // Bottom Sheet
        bottomSheetRadius: 20,
        bottomSheetElevation: 8,

        // Snack Bar
        snackBarRadius: 8,
        snackBarElevation: 6,

        // Switch
        switchSchemeColor: SchemeColor.primary,

        // Checkbox
        checkboxSchemeColor: SchemeColor.primary,

        // Radio
        radioSchemeColor: SchemeColor.primary,

        // Slider
        sliderBaseSchemeColor: SchemeColor.primary,

        // Progress Indicator
        // progressIndicatorSchemeColor: SchemeColor.primary, // Not available in current version
      ),

      // Use Material 3
      useMaterial3: true,

      // Custom theme extensions
      extensions: const <ThemeExtension<dynamic>>[
        AgriculturalColors.light,
        AppSpacing.standard,
      ],
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      // Color scheme configuration
      scheme: FlexScheme.custom,
      colors: const FlexSchemeColor(
        primary: AppColors.accentGreen,
        primaryContainer: Color(0xFF1A4A3A),
        secondary: AppColors.successGreen,
        secondaryContainer: Color(0xFF1A3A1A),
        tertiary: AppColors.primaryBlue,
        tertiaryContainer: Color(0xFF1A2A3A),
        appBarColor: AppColors.darkSurface,
        error: AppColors.errorDark,
        errorContainer: Color(0xFF4A1A1A),
      ),

      textTheme: AppTypography.darkTextTheme,

      // Surface and background colors
      surface: AppColors.darkSurface,
      scaffoldBackground: AppColors.darkBackground,

      // AppBar configuration
      appBarStyle: FlexAppBarStyle.surface,
      appBarOpacity: 1.0,
      appBarElevation: 0,

      // Tab bar configuration
      tabBarStyle: FlexTabBarStyle.forAppBar,

      // Surface mode for better color consistency
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,

      // Visual density for better touch targets
      visualDensity: FlexColorScheme.comfortablePlatformDensity,

      // Typography
      fontFamily: GoogleFonts.inter().fontFamily,

      // Component themes (same as light theme)
      subThemesData: const FlexSubThemesData(
        // General
        useMaterial3Typography: true,
        useM2StyleDividerInM3: false,

        // AppBar
        appBarCenterTitle: true,
        appBarScrolledUnderElevation: 2,

        // Bottom Navigation
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor:
            SchemeColor.onSurfaceVariant,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedIconSchemeColor:
            SchemeColor.onSurfaceVariant,

        // Navigation Rail
        navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
        navigationRailUnselectedLabelSchemeColor: SchemeColor.onSurfaceVariant,
        navigationRailSelectedIconSchemeColor: SchemeColor.primary,
        navigationRailUnselectedIconSchemeColor: SchemeColor.onSurfaceVariant,

        // Button themes
        elevatedButtonRadius: 12,
        elevatedButtonElevation: 2,
        elevatedButtonSchemeColor: SchemeColor.primary,

        filledButtonRadius: 12,

        outlinedButtonRadius: 12,
        outlinedButtonOutlineSchemeColor: SchemeColor.primary,

        textButtonRadius: 12,

        // Card theme
        cardRadius: 16,
        cardElevation: 2,

        // Input decoration
        inputDecoratorRadius: 12,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorFocusedHasBorder: true,
        inputDecoratorUnfocusedHasBorder: true,

        // FAB
        fabRadius: 16,
        fabUseShape: true,
        fabSchemeColor: SchemeColor.primary,

        // Chip
        chipRadius: 8,
        chipSchemeColor: SchemeColor.primaryContainer,

        // Dialog
        dialogRadius: 20,
        dialogElevation: 6,

        // Bottom Sheet
        bottomSheetRadius: 20,
        bottomSheetElevation: 8,

        // Snack Bar
        snackBarRadius: 8,
        snackBarElevation: 6,

        // Switch
        switchSchemeColor: SchemeColor.primary,

        // Checkbox
        checkboxSchemeColor: SchemeColor.primary,

        // Radio
        radioSchemeColor: SchemeColor.primary,

        // Slider
        sliderBaseSchemeColor: SchemeColor.primary,

        // Progress Indicator
        // progressIndicatorSchemeColor: SchemeColor.primary, // Not available in current version
      ),

      // Use Material 3
      useMaterial3: true,

      // Custom theme extensions
      extensions: const <ThemeExtension<dynamic>>[
        AgriculturalColors.dark,
        AppSpacing.standard,
      ],
    );
  }
}

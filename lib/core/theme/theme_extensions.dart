import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Custom theme extension for agricultural-specific colors
@immutable
class AgriculturalColors extends ThemeExtension<AgriculturalColors> {
  const AgriculturalColors({
    required this.cropHealthGood,
    required this.cropHealthWarning,
    required this.cropHealthPoor,
    required this.soilMoisture,
    required this.temperature,
    required this.rainfall,
    required this.primaryGradient,
    required this.successGradient,
    required this.infoGradient,
  });

  final Color cropHealthGood;
  final Color cropHealthWarning;
  final Color cropHealthPoor;
  final Color soilMoisture;
  final Color temperature;
  final Color rainfall;
  final LinearGradient primaryGradient;
  final LinearGradient successGradient;
  final LinearGradient infoGradient;

  @override
  AgriculturalColors copyWith({
    Color? cropHealthGood,
    Color? cropHealthWarning,
    Color? cropHealthPoor,
    Color? soilMoisture,
    Color? temperature,
    Color? rainfall,
    LinearGradient? primaryGradient,
    LinearGradient? successGradient,
    LinearGradient? infoGradient,
  }) {
    return AgriculturalColors(
      cropHealthGood: cropHealthGood ?? this.cropHealthGood,
      cropHealthWarning: cropHealthWarning ?? this.cropHealthWarning,
      cropHealthPoor: cropHealthPoor ?? this.cropHealthPoor,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      temperature: temperature ?? this.temperature,
      rainfall: rainfall ?? this.rainfall,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      successGradient: successGradient ?? this.successGradient,
      infoGradient: infoGradient ?? this.infoGradient,
    );
  }

  @override
  AgriculturalColors lerp(ThemeExtension<AgriculturalColors>? other, double t) {
    if (other is! AgriculturalColors) {
      return this;
    }
    return AgriculturalColors(
      cropHealthGood: Color.lerp(cropHealthGood, other.cropHealthGood, t)!,
      cropHealthWarning: Color.lerp(cropHealthWarning, other.cropHealthWarning, t)!,
      cropHealthPoor: Color.lerp(cropHealthPoor, other.cropHealthPoor, t)!,
      soilMoisture: Color.lerp(soilMoisture, other.soilMoisture, t)!,
      temperature: Color.lerp(temperature, other.temperature, t)!,
      rainfall: Color.lerp(rainfall, other.rainfall, t)!,
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      successGradient: LinearGradient.lerp(successGradient, other.successGradient, t)!,
      infoGradient: LinearGradient.lerp(infoGradient, other.infoGradient, t)!,
    );
  }

  /// Light theme agricultural colors
  static const light = AgriculturalColors(
    cropHealthGood: AppColors.cropHealthGood,
    cropHealthWarning: AppColors.cropHealthWarning,
    cropHealthPoor: AppColors.cropHealthPoor,
    soilMoisture: AppColors.soilMoisture,
    temperature: AppColors.temperature,
    rainfall: AppColors.rainfall,
    primaryGradient: AppColors.primaryGradient,
    successGradient: AppColors.successGradient,
    infoGradient: AppColors.infoGradient,
  );

  /// Dark theme agricultural colors
  static const dark = AgriculturalColors(
    cropHealthGood: AppColors.cropHealthGood,
    cropHealthWarning: AppColors.cropHealthWarning,
    cropHealthPoor: AppColors.cropHealthPoor,
    soilMoisture: AppColors.soilMoisture,
    temperature: AppColors.temperature,
    rainfall: AppColors.rainfall,
    primaryGradient: AppColors.primaryGradient,
    successGradient: AppColors.successGradient,
    infoGradient: AppColors.infoGradient,
  );
}

/// Custom theme extension for spacing and sizing
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.borderRadius,
    required this.cardRadius,
    required this.buttonRadius,
    required this.inputRadius,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double borderRadius;
  final double cardRadius;
  final double buttonRadius;
  final double inputRadius;

  @override
  AppSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? borderRadius,
    double? cardRadius,
    double? buttonRadius,
    double? inputRadius,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      borderRadius: borderRadius ?? this.borderRadius,
      cardRadius: cardRadius ?? this.cardRadius,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      inputRadius: inputRadius ?? this.inputRadius,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) {
      return this;
    }
    return AppSpacing(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t)!,
      buttonRadius: lerpDouble(buttonRadius, other.buttonRadius, t)!,
      inputRadius: lerpDouble(inputRadius, other.inputRadius, t)!,
    );
  }

  static const standard = AppSpacing(
    xs: 4.0,
    sm: 8.0,
    md: 16.0,
    lg: 24.0,
    xl: 32.0,
    xxl: 48.0,
    borderRadius: 8.0,
    cardRadius: 16.0,
    buttonRadius: 12.0,
    inputRadius: 12.0,
  );
}

/// Helper function to lerp doubles
double? lerpDouble(double? a, double? b, double t) {
  if (a == null && b == null) return null;
  a ??= 0.0;
  b ??= 0.0;
  return a + (b - a) * t;
}

/// Extension to easily access custom theme extensions
extension ThemeExtensions on ThemeData {
  AgriculturalColors get agriculturalColors =>
      extension<AgriculturalColors>() ?? AgriculturalColors.light;

  AppSpacing get spacing =>
      extension<AppSpacing>() ?? AppSpacing.standard;
}

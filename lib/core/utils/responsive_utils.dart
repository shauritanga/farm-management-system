import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive design utilities using flutter_screenutil
/// Provides consistent scaling across different screen sizes
class ResponsiveUtils {
  // Private constructor to prevent instantiation
  ResponsiveUtils._();

  /// Screen size categories
  static bool get isSmallScreen => 1.sw < 360;
  static bool get isMediumScreen => 1.sw >= 360 && 1.sw < 768;
  static bool get isLargeScreen => 1.sw >= 768 && 1.sw < 1024;
  static bool get isExtraLargeScreen => 1.sw >= 1024;

  /// Device type detection
  static bool get isTablet => 1.sw >= 600;
  static bool get isDesktop => 1.sw >= 1024;
  static bool get isMobile => 1.sw < 600;

  /// Responsive spacing values
  static double get spacing2 => 2.w;
  static double get spacing4 => 4.w;
  static double get spacing6 => 6.w;
  static double get spacing8 => 8.w;
  static double get spacing12 => 12.w;
  static double get spacing16 => 16.w;
  static double get spacing20 => 20.w;
  static double get spacing24 => 24.w;
  static double get spacing32 => 32.w;
  static double get spacing40 => 40.w;
  static double get spacing48 => 48.w;
  static double get spacing56 => 56.w;
  static double get spacing64 => 64.w;

  /// Responsive font sizes
  static double get fontSize10 => 10.sp;
  static double get fontSize11 => 11.sp;
  static double get fontSize12 => 12.sp;
  static double get fontSize13 => 13.sp;
  static double get fontSize14 => 14.sp;
  static double get fontSize16 => 16.sp;
  static double get fontSize18 => 18.sp;
  static double get fontSize20 => 20.sp;
  static double get fontSize22 => 22.sp;
  static double get fontSize24 => 24.sp;
  static double get fontSize28 => 28.sp;
  static double get fontSize32 => 32.sp;
  static double get fontSize36 => 36.sp;
  static double get fontSize40 => 40.sp;
  static double get fontSize48 => 48.sp;

  /// Responsive icon sizes
  static double get iconSize8 => 8.r;
  static double get iconSize12 => 12.r;
  static double get iconSize16 => 16.r;
  static double get iconSize20 => 20.r;
  static double get iconSize24 => 24.r;
  static double get iconSize28 => 28.r;
  static double get iconSize32 => 32.r;
  static double get iconSize40 => 40.r;
  static double get iconSize48 => 48.r;
  static double get iconSize56 => 56.r;
  static double get iconSize64 => 64.r;
  static double get iconSize80 => 80.r;
  static double get iconSize120 => 120.r;

  /// Responsive border radius
  static double get radius4 => 4.r;
  static double get radius6 => 6.r;
  static double get radius8 => 8.r;
  static double get radius12 => 12.r;
  static double get radius16 => 16.r;
  static double get radius20 => 20.r;
  static double get radius24 => 24.r;
  static double get radius32 => 32.r;

  /// Responsive heights
  static double get height4 => 4.h;
  static double get height6 => 6.h;
  static double get height8 => 8.h;
  static double get height12 => 12.h;
  static double get height16 => 16.h;
  static double get height20 => 20.h;
  static double get height24 => 24.h;
  static double get height32 => 32.h;
  static double get height40 => 40.h;
  static double get height48 => 48.h;
  static double get height56 => 56.h;
  static double get height64 => 64.h;
  static double get height80 => 80.h;
  static double get height100 => 100.h;
  static double get height120 => 120.h;
  static double get height200 => 200.h;

  /// Responsive widths
  static double get width4 => 4.w;
  static double get width8 => 8.w;
  static double get width12 => 12.w;
  static double get width16 => 16.w;
  static double get width20 => 20.w;
  static double get width24 => 24.w;
  static double get width32 => 32.w;
  static double get width40 => 40.w;
  static double get width48 => 48.w;
  static double get width56 => 56.w;
  static double get width64 => 64.w;
  static double get width80 => 80.w;
  static double get width100 => 100.w;
  static double get width120 => 120.w;

  /// Screen percentage widths
  static double get screenWidth => 1.sw;
  static double get screenHeight => 1.sh;
  static double get screenWidth10 => 0.1.sw;
  static double get screenWidth20 => 0.2.sw;
  static double get screenWidth25 => 0.25.sw;
  static double get screenWidth30 => 0.3.sw;
  static double get screenWidth40 => 0.4.sw;
  static double get screenWidth50 => 0.5.sw;
  static double get screenWidth60 => 0.6.sw;
  static double get screenWidth70 => 0.7.sw;
  static double get screenWidth75 => 0.75.sw;
  static double get screenWidth80 => 0.8.sw;
  static double get screenWidth85 => 0.85.sw;
  static double get screenWidth90 => 0.9.sw;

  /// Screen percentage heights
  static double get screenHeight10 => 0.1.sh;
  static double get screenHeight20 => 0.2.sh;
  static double get screenHeight25 => 0.25.sh;
  static double get screenHeight30 => 0.3.sh;
  static double get screenHeight40 => 0.4.sh;
  static double get screenHeight50 => 0.5.sh;
  static double get screenHeight60 => 0.6.sh;
  static double get screenHeight70 => 0.7.sh;
  static double get screenHeight80 => 0.8.sh;
  static double get screenHeight90 => 0.9.sh;

  /// Responsive button heights
  static double get buttonHeightSmall => 32.h;
  static double get buttonHeightMedium => 40.h;
  static double get buttonHeightLarge => 48.h;
  static double get buttonHeightExtraLarge => 56.h;

  /// Responsive card dimensions
  static double get cardPadding => 16.w;
  static double get cardRadius => 12.r;
  static double get cardElevation => 2.r;

  /// Responsive app bar height
  static double get appBarHeight => 56.h;

  /// Responsive bottom navigation height
  static double get bottomNavHeight => 60.h;

  /// Responsive FAB size
  static double get fabSize => 56.r;
  static double get fabSizeSmall => 40.r;
  static double get fabSizeLarge => 64.r;

  /// Agricultural specific responsive values
  static double get farmCardHeight => 200.h;
  static double get farmCardWidth => screenWidth85;
  static double get cropImageSize => 80.r;
  static double get weatherIconSize => 32.r;
  static double get dataCardPadding => 12.w;

  /// Responsive breakpoints for different layouts
  static Widget responsiveBuilder({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }

  /// Get responsive value based on screen size
  static T responsiveValue<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  /// Get responsive padding
  static EdgeInsets get paddingAll16 => EdgeInsets.all(16.w);
  static EdgeInsets get paddingAll20 => EdgeInsets.all(20.w);
  static EdgeInsets get paddingAll24 => EdgeInsets.all(24.w);
  static EdgeInsets get paddingAll32 => EdgeInsets.all(32.w);
  static EdgeInsets get paddingHorizontal16 =>
      EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get paddingHorizontal24 =>
      EdgeInsets.symmetric(horizontal: 24.w);
  static EdgeInsets get paddingVertical16 =>
      EdgeInsets.symmetric(vertical: 16.h);
  static EdgeInsets get paddingVertical24 =>
      EdgeInsets.symmetric(vertical: 24.h);

  /// Get responsive margin
  static EdgeInsets get marginAll16 => EdgeInsets.all(16.w);
  static EdgeInsets get marginAll24 => EdgeInsets.all(24.w);
  static EdgeInsets get marginHorizontal16 =>
      EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get marginHorizontal24 =>
      EdgeInsets.symmetric(horizontal: 24.w);
  static EdgeInsets get marginVertical16 =>
      EdgeInsets.symmetric(vertical: 16.h);
  static EdgeInsets get marginVertical24 =>
      EdgeInsets.symmetric(vertical: 24.h);

  /// Safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return EdgeInsets.only(
      top: padding.top,
      bottom: padding.bottom,
      left: padding.left,
      right: padding.right,
    );
  }
}

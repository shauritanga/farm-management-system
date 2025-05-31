import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode enumeration
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Theme state class
class ThemeState {
  final AppThemeMode themeMode;
  final bool isSystemDarkMode;

  const ThemeState({
    required this.themeMode,
    required this.isSystemDarkMode,
  });

  /// Get the effective theme mode
  ThemeMode get effectiveThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Check if dark mode is currently active
  bool get isDarkMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return isSystemDarkMode;
    }
  }

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isSystemDarkMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isSystemDarkMode: isSystemDarkMode ?? this.isSystemDarkMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState &&
        other.themeMode == themeMode &&
        other.isSystemDarkMode == isSystemDarkMode;
  }

  @override
  int get hashCode => themeMode.hashCode ^ isSystemDarkMode.hashCode;
}

/// Theme notifier for managing theme state
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'app_theme_mode';

  ThemeNotifier() : super(const ThemeState(
    themeMode: AppThemeMode.system,
    isSystemDarkMode: false,
  )) {
    _loadThemeFromPreferences();
  }

  /// Load theme preference from SharedPreferences
  Future<void> _loadThemeFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? AppThemeMode.system.index;
      final themeMode = AppThemeMode.values[themeIndex];
      
      state = state.copyWith(themeMode: themeMode);
    } catch (e) {
      // If loading fails, keep default system theme
      debugPrint('Failed to load theme preference: $e');
    }
  }

  /// Save theme preference to SharedPreferences
  Future<void> _saveThemeToPreferences(AppThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _saveThemeToPreferences(themeMode);
  }

  /// Update system dark mode status
  void updateSystemDarkMode(bool isSystemDarkMode) {
    state = state.copyWith(isSystemDarkMode: isSystemDarkMode);
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newThemeMode = state.themeMode == AppThemeMode.light
        ? AppThemeMode.dark
        : AppThemeMode.light;
    await setThemeMode(newThemeMode);
  }

  /// Set light theme
  Future<void> setLightTheme() async {
    await setThemeMode(AppThemeMode.light);
  }

  /// Set dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(AppThemeMode.dark);
  }

  /// Set system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(AppThemeMode.system);
  }
}

/// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

/// Convenience provider for current theme mode
final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  final themeState = ref.watch(themeProvider);
  return themeState.effectiveThemeMode;
});

/// Convenience provider for checking if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  final themeState = ref.watch(themeProvider);
  return themeState.isDarkMode;
});

/// Extension for theme mode display names
extension AppThemeModeExtension on AppThemeMode {
  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported locales in the app
class SupportedLocales {
  static const english = Locale('en');
  static const swahili = Locale('sw');

  static const List<Locale> all = [english, swahili];

  static Locale fromCode(String code) {
    switch (code) {
      case 'sw':
        return swahili;
      case 'en':
      default:
        return english;
    }
  }

  static String getDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'sw':
        return 'Kiswahili';
      case 'en':
      default:
        return 'English';
    }
  }

  static String getFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'sw':
        return '🇹🇿'; // Tanzania flag
      case 'en':
      default:
        return '🇺🇸'; // US flag
    }
  }
}

/// Localization service to manage app language
class LocalizationService {
  static const String _languageKey = 'selected_language';

  /// Get saved language from SharedPreferences
  static Future<Locale> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);

    if (languageCode != null) {
      return SupportedLocales.fromCode(languageCode);
    }

    // Default to system locale if supported, otherwise English
    final systemLocale = PlatformDispatcher.instance.locale;
    if (SupportedLocales.all.any(
      (locale) => locale.languageCode == systemLocale.languageCode,
    )) {
      return SupportedLocales.fromCode(systemLocale.languageCode);
    }

    return SupportedLocales.english;
  }

  /// Save language to SharedPreferences
  static Future<void> saveLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }
}

/// Riverpod provider for current locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Locale state notifier
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(SupportedLocales.english) {
    _loadSavedLanguage();
  }

  /// Load saved language on app start
  Future<void> _loadSavedLanguage() async {
    final savedLocale = await LocalizationService.getSavedLanguage();
    state = savedLocale;
  }

  /// Change app language
  Future<void> changeLanguage(Locale newLocale) async {
    if (SupportedLocales.all.contains(newLocale)) {
      state = newLocale;
      await LocalizationService.saveLanguage(newLocale);
    }
  }

  /// Toggle between English and Swahili
  Future<void> toggleLanguage() async {
    final newLocale =
        state.languageCode == 'en'
            ? SupportedLocales.swahili
            : SupportedLocales.english;
    await changeLanguage(newLocale);
  }
}

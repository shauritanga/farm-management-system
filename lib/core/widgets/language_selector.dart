import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/localization_service.dart';
import '../utils/responsive_utils.dart';

/// Language selector widget for changing app language
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Language / Lugha',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height12),

          // Language options
          ...SupportedLocales.all.map((locale) {
            final isSelected =
                currentLocale.languageCode == locale.languageCode;

            return Container(
              margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing8),
              child: InkWell(
                onTap:
                    () => ref
                        .read(localeProvider.notifier)
                        .changeLanguage(locale),
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
                child: Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                    border: Border.all(
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(
                                alpha: 0.2,
                              ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        SupportedLocales.getFlag(locale),
                        style: TextStyle(fontSize: ResponsiveUtils.fontSize24),
                      ),
                      SizedBox(width: ResponsiveUtils.spacing12),
                      Expanded(
                        child: Text(
                          SupportedLocales.getDisplayName(locale),
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize16,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                          size: ResponsiveUtils.iconSize20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Simple language toggle button
class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);

    return IconButton(
      onPressed: () => ref.read(localeProvider.notifier).toggleLanguage(),
      style: IconButton.styleFrom(
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
        ),
      ),
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            SupportedLocales.getFlag(currentLocale),
            style: TextStyle(fontSize: ResponsiveUtils.fontSize16),
          ),
          SizedBox(width: ResponsiveUtils.spacing4),
          Text(
            currentLocale.languageCode.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Language selection bottom sheet
class LanguageSelectionBottomSheet extends ConsumerWidget {
  const LanguageSelectionBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSelectionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLocale = ref.watch(localeProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUtils.radius20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: ResponsiveUtils.spacing8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            child: Text(
              'Select Language / Chagua Lugha',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Language options
          ...SupportedLocales.all.map((locale) {
            final isSelected =
                currentLocale.languageCode == locale.languageCode;

            return ListTile(
              leading: Text(
                SupportedLocales.getFlag(locale),
                style: TextStyle(fontSize: ResponsiveUtils.fontSize24),
              ),
              title: Text(
                SupportedLocales.getDisplayName(locale),
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                ),
              ),
              trailing:
                  isSelected
                      ? Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                      )
                      : null,
              onTap: () {
                ref.read(localeProvider.notifier).changeLanguage(locale);
                Navigator.pop(context);
              },
            );
          }),

          SizedBox(height: ResponsiveUtils.height16),
        ],
      ),
    );
  }
}

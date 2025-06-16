import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/language_selector.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Language settings screen
class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Language Settings',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your preferred language for the app interface.',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: ResponsiveUtils.height24),
            
            // Language selector widget
            const LanguageSelector(),
            
            SizedBox(height: ResponsiveUtils.height24),
            
            // Language toggle button example
            Row(
              children: [
                Text(
                  'Quick Toggle:',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing12),
                const LanguageToggleButton(),
              ],
            ),
            
            SizedBox(height: ResponsiveUtils.height24),
            
            // Bottom sheet example
            ElevatedButton(
              onPressed: () => LanguageSelectionBottomSheet.show(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.spacing24,
                  vertical: ResponsiveUtils.spacing12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
                ),
              ),
              child: Text(
                'Show Language Bottom Sheet',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

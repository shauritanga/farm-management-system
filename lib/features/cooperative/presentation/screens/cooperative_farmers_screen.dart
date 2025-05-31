import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';

/// Cooperative farmers management screen
class CooperativeFarmersScreen extends StatelessWidget {
  const CooperativeFarmersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Farmers',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups,
              size: ResponsiveUtils.iconSize80,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: ResponsiveUtils.height24),
            Text(
              'Farmer Management',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height12),
            Text(
              'Manage and support your cooperative farmers',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

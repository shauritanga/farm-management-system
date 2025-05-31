import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';

/// Cooperative sales management screen
class CooperativeSalesScreen extends StatelessWidget {
  const CooperativeSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sales',
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
              Icons.point_of_sale,
              size: ResponsiveUtils.iconSize80,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: ResponsiveUtils.height24),
            Text(
              'Sales Management',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height12),
            Text(
              'Track and manage cooperative sales activities',
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

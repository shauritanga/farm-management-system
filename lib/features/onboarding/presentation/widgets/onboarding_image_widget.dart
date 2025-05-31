import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/onboarding_page.dart';
import '../../../../core/utils/responsive_utils.dart';

/// Enhanced image widget for onboarding with better loading states
class OnboardingImageWidget extends StatelessWidget {
  final OnboardingPageEntity page;

  const OnboardingImageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: ResponsiveUtils.screenWidth80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: ResponsiveUtils.spacing20,
            offset: Offset(0, ResponsiveUtils.spacing8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius20),
        child: AspectRatio(
          aspectRatio: 4 / 3, // Consistent aspect ratio
          child: CachedNetworkImage(
            imageUrl: page.imagePath,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildLoadingPlaceholder(theme),
            errorWidget: (context, url, error) => _buildErrorWidget(theme),
            // Optimized cache settings
            memCacheWidth: 800,
            memCacheHeight: 600,
            maxWidthDiskCache: 800,
            maxHeightDiskCache: 600,
            // Fade in animation
            fadeInDuration: const Duration(milliseconds: 500),
            fadeOutDuration: const Duration(milliseconds: 200),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing animation container
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: ResponsiveUtils.iconSize80,
                    height: ResponsiveUtils.iconSize80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForPage(page.id),
                      size: ResponsiveUtils.iconSize40,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: ResponsiveUtils.height24),
            Text(
              'Loading illustration...',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height8),
            Text(
              'Preparing beautiful agricultural content',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.7,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon with background
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForPage(page.id),
              size: ResponsiveUtils.iconSize64,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height24),
          Text(
            'Illustration Preview',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height8),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing32,
            ),
            child: Text(
              'Beautiful agricultural illustrations will appear here when connected to the internet',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.8,
                ),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForPage(String pageId) {
    switch (pageId) {
      case '1':
        return Icons.agriculture;
      case '2':
        return Icons.groups;
      case '3':
        return Icons.rocket_launch;
      default:
        return Icons.agriculture;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../farm/presentation/providers/farm_provider.dart';

/// Widget to display farm statistics
class FarmStatisticsCard extends ConsumerWidget {
  final String farmerId;

  const FarmStatisticsCard({super.key, required this.farmerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statisticsAsync = ref.watch(farmStatisticsProvider(farmerId));

    return Container(
      margin: EdgeInsets.all(ResponsiveUtils.spacing16),
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: theme.colorScheme.primary,
                size: ResponsiveUtils.iconSize24,
              ),
              SizedBox(width: ResponsiveUtils.spacing8),
              Text(
                'Farm Overview',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.height16),

          statisticsAsync.when(
            data: (statistics) => _buildStatisticsContent(theme, statistics),
            loading: () => _buildLoadingState(theme),
            error: (error, stack) => _buildErrorState(theme, error.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsContent(
    ThemeData theme,
    Map<String, dynamic> statistics,
  ) {
    return Column(
      children: [
        // Main statistics row
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                theme,
                'Total Farms',
                statistics['totalFarms']?.toString() ?? '0',
                Icons.agriculture,
                theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: _buildStatItem(
                theme,
                'Total Size',
                '${statistics['totalSize']?.toStringAsFixed(1) ?? '0'} ha',
                Icons.straighten,
                theme.colorScheme.secondary,
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: _buildStatItem(
                theme,
                'Crop Types',
                statistics['uniqueCropTypes']?.toString() ?? '0',
                Icons.eco,
                Colors.green,
              ),
            ),
          ],
        ),

        SizedBox(height: ResponsiveUtils.height16),

        // Farm status breakdown
        Row(
          children: [
            Expanded(
              child: _buildStatusItem(
                theme,
                'Active',
                statistics['activeFarms']?.toString() ?? '0',
                Colors.green,
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing8),
            Expanded(
              child: _buildStatusItem(
                theme,
                'Planning',
                statistics['planningFarms']?.toString() ?? '0',
                Colors.orange,
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing8),
            Expanded(
              child: _buildStatusItem(
                theme,
                'Harvesting',
                statistics['harvestingFarms']?.toString() ?? '0',
                Colors.blue,
              ),
            ),
          ],
        ),

        // Crop types list
        if (statistics['cropTypes'] != null &&
            (statistics['cropTypes'] as List).isNotEmpty) ...[
          SizedBox(height: ResponsiveUtils.height16),
          _buildCropTypesList(theme, statistics['cropTypes'] as List<String>),
        ],
      ],
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: ResponsiveUtils.iconSize20),
          SizedBox(height: ResponsiveUtils.height4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize10,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    ThemeData theme,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing8,
        vertical: ResponsiveUtils.spacing6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize10,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropTypesList(ThemeData theme, List<String> cropTypes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crops Grown:',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize12,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: ResponsiveUtils.height8),
        Wrap(
          spacing: ResponsiveUtils.spacing6,
          runSpacing: ResponsiveUtils.spacing4,
          children:
              cropTypes.map((crop) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacing8,
                    vertical: ResponsiveUtils.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius6,
                    ),
                  ),
                  child: Text(
                    crop,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize10,
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: ResponsiveUtils.iconSize20,
              height: ResponsiveUtils.iconSize20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            SizedBox(height: ResponsiveUtils.height8),
            Text(
              'Loading statistics...',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: ResponsiveUtils.iconSize24,
            ),
            SizedBox(height: ResponsiveUtils.height8),
            Text(
              'Failed to load statistics',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              error,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize10,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

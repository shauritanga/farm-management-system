import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_utils.dart';
import '../services/location_service.dart';

/// Widget to handle location permission requests
class LocationPermissionWidget extends StatelessWidget {
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const LocationPermissionWidget({
    super.key,
    this.onPermissionGranted,
    this.onPermissionDenied,
  });

  @override
  Widget build(BuildContext context) {
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: ResponsiveUtils.iconSize48,
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: ResponsiveUtils.height16),
          
          Text(
            'Location Access Needed',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.height8),
          
          Text(
            'To provide accurate weather information for your location, we need access to your device\'s GPS.',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.height24),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    onPermissionDenied?.call();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUtils.spacing12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _requestLocationPermission(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUtils.spacing12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
                    ),
                  ),
                  child: Text(
                    'Allow Location',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _requestLocationPermission(BuildContext context) async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await LocationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog(context);
        return;
      }

      // Request permission
      final permission = await LocationService.requestLocationPermission();
      
      if (LocationService.hasLocationPermission(permission)) {
        onPermissionGranted?.call();
      } else {
        onPermissionDenied?.call();
        if (permission.toString().contains('deniedForever')) {
          _showSettingsDialog(context);
        }
      }
    } catch (e) {
      onPermissionDenied?.call();
    }
  }

  void _showLocationServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Please enable location services in your device settings to get accurate weather information.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              LocationService.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission has been permanently denied. Please enable it in app settings to get accurate weather information.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              LocationService.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

/// Simple location status indicator
class LocationStatusIndicator extends StatelessWidget {
  final bool hasPermission;
  final VoidCallback? onTap;

  const LocationStatusIndicator({
    super.key,
    required this.hasPermission,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.spacing8,
          vertical: ResponsiveUtils.spacing4,
        ),
        decoration: BoxDecoration(
          color: hasPermission 
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasPermission ? Icons.location_on : Icons.location_off,
              size: ResponsiveUtils.iconSize16,
              color: hasPermission 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
            SizedBox(width: ResponsiveUtils.spacing4),
            Text(
              hasPermission ? 'GPS' : 'No GPS',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                fontWeight: FontWeight.w600,
                color: hasPermission 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:geolocator/geolocator.dart';

/// Custom exceptions for location service
class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException([
    this.message = 'Location services are disabled',
  ]);
  @override
  String toString() => 'LocationServiceDisabledException: $message';
}

class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException([
    this.message = 'Location permission denied',
  ]);
  @override
  String toString() => 'LocationPermissionDeniedException: $message';
}

class LocationPermissionDeniedForeverException implements Exception {
  final String message;
  LocationPermissionDeniedForeverException([
    this.message = 'Location permission permanently denied',
  ]);
  @override
  String toString() => 'LocationPermissionDeniedForeverException: $message';
}

/// Location service for handling GPS location functionality
class LocationService {
  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  static Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  static Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current position with error handling
  static Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceDisabledException();
      }

      // Check permissions
      LocationPermission permission = await checkLocationPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
        if (permission == LocationPermission.denied) {
          throw LocationPermissionDeniedException();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationPermissionDeniedForeverException();
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      // Return null on any error - caller can handle fallback
      return null;
    }
  }

  /// Get current position with timeout and fallback
  static Future<Position?> getCurrentPositionSafe({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are disabled, return null
        return null;
      }

      // Check permissions
      LocationPermission permission = await checkLocationPermission();
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await requestLocationPermission();
        if (permission == LocationPermission.denied) {
          // Permission denied, return null
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission permanently denied, return null
        return null;
      }

      // Get current position with timeout
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(timeout);
    } catch (e) {
      // Return null on timeout or any error
      return null;
    }
  }

  /// Check if we need to request location permission
  static Future<bool> shouldRequestPermission() async {
    final permission = await checkLocationPermission();
    return permission == LocationPermission.denied;
  }

  /// Check if location permission is permanently denied
  static Future<bool> isPermissionPermanentlyDenied() async {
    final permission = await checkLocationPermission();
    return permission == LocationPermission.deniedForever;
  }

  /// Get current position with explicit permission handling
  static Future<Position?> getCurrentPositionWithPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceDisabledException();
      }

      // Check permissions
      LocationPermission permission = await checkLocationPermission();
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await requestLocationPermission();
        if (permission == LocationPermission.denied) {
          throw LocationPermissionDeniedException();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationPermissionDeniedForeverException();
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      rethrow; // Re-throw to let caller handle specific errors
    }
  }

  /// Open app settings for location permission
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Get location permission status as string for UI
  static String getPermissionStatusText(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return 'Location permission denied';
      case LocationPermission.deniedForever:
        return 'Location permission permanently denied';
      case LocationPermission.whileInUse:
        return 'Location permission granted';
      case LocationPermission.always:
        return 'Location permission granted';
      default:
        return 'Unknown permission status';
    }
  }

  /// Check if we have sufficient permission for location
  static bool hasLocationPermission(LocationPermission permission) {
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}

/// Location data model
class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
  });

  factory LocationData.fromPosition(Position position) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
    );
  }

  @override
  String toString() {
    return 'LocationData(lat: ${latitude.toStringAsFixed(4)}, '
        'lng: ${longitude.toStringAsFixed(4)}, '
        'accuracy: ${accuracy?.toStringAsFixed(1)}m)';
  }
}

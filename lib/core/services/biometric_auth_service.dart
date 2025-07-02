import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

/// Service for handling biometric authentication
class BiometricAuthService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricSetupKey = 'biometric_setup_completed';
  
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available on device
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Check if user has enabled biometric authentication
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Enable biometric authentication
  Future<void> enableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, true);
    await prefs.setBool(_biometricSetupKey, true);
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, false);
  }

  /// Check if biometric setup has been completed
  Future<bool> isBiometricSetupCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricSetupKey) ?? false;
  }

  /// Authenticate using biometrics
  Future<BiometricAuthResult> authenticateWithBiometrics({
    String reason = 'Please authenticate to access your farm data',
  }) async {
    try {
      // Check if biometric is available
      if (!await isBiometricAvailable()) {
        return BiometricAuthResult.notAvailable;
      }

      // Check if user has enabled biometric
      if (!await isBiometricEnabled()) {
        return BiometricAuthResult.notEnabled;
      }

      // Perform authentication
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return didAuthenticate 
          ? BiometricAuthResult.success 
          : BiometricAuthResult.failed;
          
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'NotAvailable':
          return BiometricAuthResult.notAvailable;
        case 'NotEnrolled':
          return BiometricAuthResult.notEnrolled;
        case 'LockedOut':
          return BiometricAuthResult.lockedOut;
        case 'PermanentlyLockedOut':
          return BiometricAuthResult.permanentlyLockedOut;
        default:
          return BiometricAuthResult.error;
      }
    } catch (e) {
      return BiometricAuthResult.error;
    }
  }

  /// Get user-friendly biometric type name
  String getBiometricTypeName(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else {
      return 'Biometric';
    }
  }

  /// Setup biometric authentication flow
  Future<BiometricSetupResult> setupBiometric() async {
    try {
      // Check availability
      if (!await isBiometricAvailable()) {
        return BiometricSetupResult.notAvailable;
      }

      // Check if biometrics are enrolled
      final availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return BiometricSetupResult.notEnrolled;
      }

      // Test authentication
      final authResult = await authenticateWithBiometrics(
        reason: 'Set up biometric authentication for quick access',
      );

      if (authResult == BiometricAuthResult.success) {
        await enableBiometric();
        return BiometricSetupResult.success;
      } else {
        return BiometricSetupResult.failed;
      }
    } catch (e) {
      return BiometricSetupResult.error;
    }
  }
}

/// Result of biometric authentication
enum BiometricAuthResult {
  success,
  failed,
  notAvailable,
  notEnabled,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut,
  error,
}

/// Result of biometric setup
enum BiometricSetupResult {
  success,
  failed,
  notAvailable,
  notEnrolled,
  error,
}

/// Extension for user-friendly messages
extension BiometricAuthResultExtension on BiometricAuthResult {
  String get message {
    switch (this) {
      case BiometricAuthResult.success:
        return 'Authentication successful';
      case BiometricAuthResult.failed:
        return 'Authentication failed';
      case BiometricAuthResult.notAvailable:
        return 'Biometric authentication not available';
      case BiometricAuthResult.notEnabled:
        return 'Biometric authentication not enabled';
      case BiometricAuthResult.notEnrolled:
        return 'No biometrics enrolled on device';
      case BiometricAuthResult.lockedOut:
        return 'Biometric authentication locked. Try again later';
      case BiometricAuthResult.permanentlyLockedOut:
        return 'Biometric authentication permanently locked';
      case BiometricAuthResult.error:
        return 'An error occurred during authentication';
    }
  }
}

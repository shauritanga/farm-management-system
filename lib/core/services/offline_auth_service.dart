import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../features/auth/domain/entities/user.dart';

/// Service for managing offline authentication state
class OfflineAuthService {
  static const String _cachedUserKey = 'cached_user_data';
  static const String _authTokenKey = 'auth_token';
  static const String _lastLoginKey = 'last_login_timestamp';
  static const String _offlineModeKey = 'offline_mode_enabled';
  
  /// Maximum offline session duration (7 days)
  static const Duration maxOfflineSession = Duration(days: 7);

  /// Save user data for offline access
  Future<void> cacheUserData(UserEntity user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'userType': user.userType.value,
        'status': user.status.value,
        'phoneNumber': user.phoneNumber,
        'profileImageUrl': user.profileImageUrl,
        'createdAt': user.createdAt.toIso8601String(),
        'lastLoginAt': user.lastLoginAt?.toIso8601String(),
        'farmName': user.farmName,
        'farmLocation': user.farmLocation,
        'farmSize': user.farmSize,
        'cropTypes': user.cropTypes,
        'cooperativeId': user.cooperativeId,
        'cooperativeName': user.cooperativeName,
        'role': user.role,
        'permissions': user.permissions,
        'subscriptionPackage': user.subscriptionPackage,
        'subscriptionStatus': user.subscriptionStatus,
        'subscriptionEndDate': user.subscriptionEndDate?.toIso8601String(),
        'trialEndDate': user.trialEndDate?.toIso8601String(),
      };
      
      await prefs.setString(_cachedUserKey, jsonEncode(userData));
      await prefs.setInt(_lastLoginKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Handle caching error silently
    }
  }

  /// Retrieve cached user data
  Future<UserEntity?> getCachedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_cachedUserKey);
      
      if (userDataString == null) return null;
      
      final userData = jsonDecode(userDataString) as Map<String, dynamic>;
      
      return UserEntity(
        id: userData['id'] as String,
        name: userData['name'] as String,
        email: userData['email'] as String,
        userType: UserType.fromString(userData['userType'] as String),
        status: UserStatus.fromString(userData['status'] as String),
        createdAt: DateTime.parse(userData['createdAt'] as String),
        phoneNumber: userData['phoneNumber'] as String?,
        profileImageUrl: userData['profileImageUrl'] as String?,
        lastLoginAt: userData['lastLoginAt'] != null 
            ? DateTime.parse(userData['lastLoginAt'] as String)
            : null,
        farmName: userData['farmName'] as String?,
        farmLocation: userData['farmLocation'] as String?,
        farmSize: userData['farmSize'] as double?,
        cropTypes: (userData['cropTypes'] as List<dynamic>?)?.cast<String>(),
        cooperativeId: userData['cooperativeId'] as String?,
        cooperativeName: userData['cooperativeName'] as String?,
        role: userData['role'] as String?,
        permissions: (userData['permissions'] as List<dynamic>?)?.cast<String>(),
        subscriptionPackage: userData['subscriptionPackage'] as String?,
        subscriptionStatus: userData['subscriptionStatus'] as String?,
        subscriptionEndDate: userData['subscriptionEndDate'] != null
            ? DateTime.parse(userData['subscriptionEndDate'] as String)
            : null,
        trialEndDate: userData['trialEndDate'] != null
            ? DateTime.parse(userData['trialEndDate'] as String)
            : null,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if offline session is still valid
  Future<bool> isOfflineSessionValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoginTimestamp = prefs.getInt(_lastLoginKey);
      
      if (lastLoginTimestamp == null) return false;
      
      final lastLogin = DateTime.fromMillisecondsSinceEpoch(lastLoginTimestamp);
      final now = DateTime.now();
      
      return now.difference(lastLogin) < maxOfflineSession;
    } catch (e) {
      return false;
    }
  }

  /// Clear cached authentication data
  Future<void> clearCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedUserKey);
      await prefs.remove(_authTokenKey);
      await prefs.remove(_lastLoginKey);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Check network connectivity
  Future<bool> isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  /// Enable offline mode
  Future<void> enableOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineModeKey, true);
  }

  /// Disable offline mode
  Future<void> disableOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineModeKey, false);
  }

  /// Check if offline mode is enabled
  Future<bool> isOfflineModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_offlineModeKey) ?? false;
  }

  /// Get offline authentication status
  Future<OfflineAuthStatus> getOfflineAuthStatus() async {
    final isConnected = await this.isConnected();
    final hasCachedUser = await getCachedUserData() != null;
    final isSessionValid = await isOfflineSessionValid();
    final isOfflineModeEnabled = await this.isOfflineModeEnabled();

    if (isConnected) {
      return OfflineAuthStatus.online;
    } else if (hasCachedUser && isSessionValid && isOfflineModeEnabled) {
      return OfflineAuthStatus.offlineAuthenticated;
    } else if (hasCachedUser && !isSessionValid) {
      return OfflineAuthStatus.offlineExpired;
    } else {
      return OfflineAuthStatus.offlineUnauthenticated;
    }
  }

  /// Update last activity timestamp
  Future<void> updateLastActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastLoginKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get time remaining for offline session
  Future<Duration?> getOfflineSessionTimeRemaining() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoginTimestamp = prefs.getInt(_lastLoginKey);
      
      if (lastLoginTimestamp == null) return null;
      
      final lastLogin = DateTime.fromMillisecondsSinceEpoch(lastLoginTimestamp);
      final expiryTime = lastLogin.add(maxOfflineSession);
      final now = DateTime.now();
      
      if (expiryTime.isAfter(now)) {
        return expiryTime.difference(now);
      } else {
        return Duration.zero;
      }
    } catch (e) {
      return null;
    }
  }
}

/// Offline authentication status
enum OfflineAuthStatus {
  online,
  offlineAuthenticated,
  offlineExpired,
  offlineUnauthenticated,
}

/// Extension for user-friendly messages
extension OfflineAuthStatusExtension on OfflineAuthStatus {
  String get message {
    switch (this) {
      case OfflineAuthStatus.online:
        return 'Connected';
      case OfflineAuthStatus.offlineAuthenticated:
        return 'Working offline';
      case OfflineAuthStatus.offlineExpired:
        return 'Offline session expired';
      case OfflineAuthStatus.offlineUnauthenticated:
        return 'No offline access';
    }
  }

  bool get isAuthenticated {
    return this == OfflineAuthStatus.online || 
           this == OfflineAuthStatus.offlineAuthenticated;
  }
}

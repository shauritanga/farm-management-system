import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/google_signin_usecase.dart';
import '../states/auth_state.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/services/offline_auth_service.dart';
import 'auth_provider.dart';

/// Enhanced authentication notifier with mobile-specific features
class MobileAuthNotifier extends StateNotifier<AuthState> {
  final GetCurrentUserUsecase _getCurrentUserUsecase;
  final IsAuthenticatedUsecase _isAuthenticatedUsecase;
  final LogoutUsecase _logoutUsecase;
  final BiometricAuthService _biometricService;
  final OfflineAuthService _offlineService;

  MobileAuthNotifier(
    this._getCurrentUserUsecase,
    this._isAuthenticatedUsecase,
    this._logoutUsecase,
    this._biometricService,
    this._offlineService,
  ) : super(AuthInitial());

  /// Initialize authentication state with mobile features
  Future<void> initializeAuth() async {
    state = AuthLoading();
    try {
      // Check offline authentication status first
      final offlineStatus = await _offlineService.getOfflineAuthStatus();

      switch (offlineStatus) {
        case OfflineAuthStatus.online:
          await _initializeOnlineAuth();
          break;
        case OfflineAuthStatus.offlineAuthenticated:
          await _initializeOfflineAuth();
          break;
        case OfflineAuthStatus.offlineExpired:
          await _handleOfflineExpired();
          break;
        case OfflineAuthStatus.offlineUnauthenticated:
          state = AuthUnauthenticated();
          break;
      }
    } catch (e) {
      // Fallback to offline if available
      final cachedUser = await _offlineService.getCachedUserData();
      if (cachedUser != null && await _offlineService.isOfflineSessionValid()) {
        state = AuthAuthenticated(cachedUser);
      } else {
        state = AuthUnauthenticated();
      }
    }
  }

  /// Initialize online authentication
  Future<void> _initializeOnlineAuth() async {
    final isAuthenticated = await _isAuthenticatedUsecase();
    if (isAuthenticated) {
      final user = await _getCurrentUserUsecase();
      if (user != null) {
        // Cache user data for offline access
        await _offlineService.cacheUserData(user);
        await _offlineService.enableOfflineMode();
        state = AuthAuthenticated(user);
      } else {
        state = AuthUnauthenticated();
      }
    } else {
      state = AuthUnauthenticated();
    }
  }

  /// Initialize offline authentication
  Future<void> _initializeOfflineAuth() async {
    final cachedUser = await _offlineService.getCachedUserData();
    if (cachedUser != null) {
      state = AuthAuthenticated(cachedUser);
    } else {
      state = AuthUnauthenticated();
    }
  }

  /// Handle expired offline session
  Future<void> _handleOfflineExpired() async {
    await _offlineService.clearCachedData();
    state = AuthUnauthenticated();
  }

  /// Authenticate with biometrics
  Future<void> authenticateWithBiometrics() async {
    state = AuthLoading();
    try {
      final result = await _biometricService.authenticateWithBiometrics(
        reason: 'Access your farm management data',
      );

      if (result == BiometricAuthResult.success) {
        // Get cached user or current user
        final cachedUser = await _offlineService.getCachedUserData();
        if (cachedUser != null) {
          await _offlineService.updateLastActivity();
          state = AuthAuthenticated(cachedUser);
        } else {
          // Try to get current user online
          final user = await _getCurrentUserUsecase();
          if (user != null) {
            await _offlineService.cacheUserData(user);
            state = AuthAuthenticated(user);
          } else {
            state = AuthError('Unable to authenticate');
          }
        }
      } else {
        state = AuthError(result.message);
      }
    } catch (e) {
      state = AuthError('Biometric authentication failed: $e');
    }
  }

  /// Set authenticated state with caching
  Future<void> setAuthenticated(UserEntity user) async {
    await _offlineService.cacheUserData(user);
    await _offlineService.enableOfflineMode();
    state = AuthAuthenticated(user);
  }

  /// Set unauthenticated state with cleanup
  Future<void> setUnauthenticated() async {
    await _offlineService.clearCachedData();
    await _biometricService.disableBiometric();
    state = AuthUnauthenticated();
  }

  /// Logout with cleanup
  Future<void> logout() async {
    try {
      await _logoutUsecase();
      await _offlineService.clearCachedData();
      await _biometricService.disableBiometric();
      state = AuthUnauthenticated();
    } catch (e) {
      // Even if logout fails, clear local data
      await _offlineService.clearCachedData();
      await _biometricService.disableBiometric();
      state = AuthError('Logout failed: $e');
    }
  }

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    return await _biometricService.isBiometricAvailable();
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    return await _biometricService.isBiometricEnabled();
  }

  /// Setup biometric authentication
  Future<BiometricSetupResult> setupBiometric() async {
    return await _biometricService.setupBiometric();
  }

  /// Get offline status
  Future<OfflineAuthStatus> getOfflineStatus() async {
    return await _offlineService.getOfflineAuthStatus();
  }

  /// Get offline session time remaining
  Future<Duration?> getOfflineTimeRemaining() async {
    return await _offlineService.getOfflineSessionTimeRemaining();
  }

  /// Update activity timestamp
  Future<void> updateActivity() async {
    await _offlineService.updateLastActivity();
  }
}

/// Enhanced login notifier with biometric support
class MobileLoginNotifier extends StateNotifier<LoginState> {
  final LoginUsecase _loginUsecase;
  final GoogleSignInUsecase _googleSignInUsecase;
  final BiometricAuthService _biometricService;
  final OfflineAuthService _offlineService;

  MobileLoginNotifier(
    this._loginUsecase,
    this._googleSignInUsecase,
    this._biometricService,
    this._offlineService,
  ) : super(LoginInitial());

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = LoginLoading();
    try {
      final user = await _loginUsecase(email, password);

      // Cache user data for offline access
      await _offlineService.cacheUserData(user);
      await _offlineService.enableOfflineMode();

      state = LoginSuccess(user);
    } catch (e) {
      state = LoginError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Quick biometric login
  Future<void> biometricLogin() async {
    state = LoginLoading();
    try {
      final result = await _biometricService.authenticateWithBiometrics(
        reason: 'Sign in to your farm management account',
      );

      if (result == BiometricAuthResult.success) {
        final cachedUser = await _offlineService.getCachedUserData();
        if (cachedUser != null &&
            await _offlineService.isOfflineSessionValid()) {
          await _offlineService.updateLastActivity();
          state = LoginSuccess(cachedUser);
        } else {
          state = LoginError('Session expired. Please login again.');
        }
      } else {
        state = LoginError(result.message);
      }
    } catch (e) {
      state = LoginError('Biometric login failed: $e');
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = LoginLoading();
    try {
      final user = await _googleSignInUsecase();

      // Cache user data for offline access
      await _offlineService.cacheUserData(user);
      await _offlineService.enableOfflineMode();

      state = LoginSuccess(user);
    } catch (e) {
      state = LoginError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Reset login state
  void resetState() {
    state = LoginInitial();
  }
}

// Enhanced mobile auth provider
final mobileAuthProvider = StateNotifierProvider<MobileAuthNotifier, AuthState>(
  (ref) {
    return MobileAuthNotifier(
      ref.read(getCurrentUserUsecaseProvider),
      ref.read(isAuthenticatedUsecaseProvider),
      ref.read(logoutUsecaseProvider),
      ref.read(biometricAuthServiceProvider),
      ref.read(offlineAuthServiceProvider),
    );
  },
);

// Enhanced mobile login provider
final mobileLoginProvider =
    StateNotifierProvider<MobileLoginNotifier, LoginState>((ref) {
      return MobileLoginNotifier(
        ref.read(loginUsecaseProvider),
        ref.read(googleSignInUsecaseProvider),
        ref.read(biometricAuthServiceProvider),
        ref.read(offlineAuthServiceProvider),
      );
    });

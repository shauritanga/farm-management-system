import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_farmer_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/google_signin_usecase.dart';
import '../states/auth_state.dart';

// Use case providers
final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(ref.read(authRepositoryProvider));
});

final registerFarmerUsecaseProvider = Provider<RegisterFarmerUsecase>((ref) {
  return RegisterFarmerUsecase(ref.read(authRepositoryProvider));
});

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  return GetCurrentUserUsecase(ref.read(authRepositoryProvider));
});

final isAuthenticatedUsecaseProvider = Provider<IsAuthenticatedUsecase>((ref) {
  return IsAuthenticatedUsecase(ref.read(authRepositoryProvider));
});

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  return LogoutUsecase(ref.read(authRepositoryProvider));
});

final resetPasswordUsecaseProvider = Provider<ResetPasswordUsecase>((ref) {
  return ResetPasswordUsecase(ref.read(authRepositoryProvider));
});

final googleSignInUsecaseProvider = Provider<GoogleSignInUsecase>((ref) {
  return GoogleSignInUsecase(ref.read(authRepositoryProvider));
});

// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final GetCurrentUserUsecase _getCurrentUserUsecase;
  final IsAuthenticatedUsecase _isAuthenticatedUsecase;
  final LogoutUsecase _logoutUsecase;

  AuthNotifier(
    this._getCurrentUserUsecase,
    this._isAuthenticatedUsecase,
    this._logoutUsecase,
  ) : super(AuthInitial());

  /// Initialize authentication state
  Future<void> initializeAuth() async {
    state = AuthLoading();
    try {
      final isAuthenticated = await _isAuthenticatedUsecase();
      if (isAuthenticated) {
        final user = await _getCurrentUserUsecase();
        if (user != null) {
          state = AuthAuthenticated(user);
        } else {
          state = AuthUnauthenticated();
        }
      } else {
        state = AuthUnauthenticated();
      }
    } catch (e) {
      state = AuthUnauthenticated();
    }
  }

  /// Set authenticated state
  void setAuthenticated(user) {
    state = AuthAuthenticated(user);
  }

  /// Set unauthenticated state
  void setUnauthenticated() {
    state = AuthUnauthenticated();
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _logoutUsecase();
      state = AuthUnauthenticated();
    } catch (e) {
      state = AuthError('Logout failed: $e');
    }
  }
}

// Login state notifier
class LoginNotifier extends StateNotifier<LoginState> {
  final LoginUsecase _loginUsecase;
  final GoogleSignInUsecase _googleSignInUsecase;

  LoginNotifier(this._loginUsecase, this._googleSignInUsecase)
    : super(LoginInitial());

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = LoginLoading();
    try {
      final user = await _loginUsecase(email, password);
      state = LoginSuccess(user);
    } catch (e) {
      state = LoginError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = LoginLoading();
    try {
      final user = await _googleSignInUsecase();
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

// Registration state notifier
class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final RegisterFarmerUsecase _registerFarmerUsecase;

  RegistrationNotifier(this._registerFarmerUsecase)
    : super(RegistrationInitial());

  /// Register farmer
  Future<void> registerFarmer({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? phoneNumber,
    String? farmName,
    String? farmLocation,
    double? farmSize,
    List<String>? cropTypes,
  }) async {
    state = RegistrationLoading();
    try {
      final user = await _registerFarmerUsecase(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        phoneNumber: phoneNumber,
        farmName: farmName,
        farmLocation: farmLocation,
        farmSize: farmSize,
        cropTypes: cropTypes,
      );
      state = RegistrationSuccess(user);
    } catch (e) {
      state = RegistrationError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Reset registration state
  void resetState() {
    state = RegistrationInitial();
  }
}

// Password reset state notifier
class PasswordResetNotifier extends StateNotifier<PasswordResetState> {
  final ResetPasswordUsecase _resetPasswordUsecase;

  PasswordResetNotifier(this._resetPasswordUsecase)
    : super(PasswordResetInitial());

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    state = PasswordResetLoading();
    try {
      await _resetPasswordUsecase(email);
      state = PasswordResetSuccess();
    } catch (e) {
      state = PasswordResetError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Reset state
  void resetState() {
    state = PasswordResetInitial();
  }
}

// State notifier providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(getCurrentUserUsecaseProvider),
    ref.read(isAuthenticatedUsecaseProvider),
    ref.read(logoutUsecaseProvider),
  );
});

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(
    ref.read(loginUsecaseProvider),
    ref.read(googleSignInUsecaseProvider),
  );
});

final registrationProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
      return RegistrationNotifier(ref.read(registerFarmerUsecaseProvider));
    });

final passwordResetProvider =
    StateNotifierProvider<PasswordResetNotifier, PasswordResetState>((ref) {
      return PasswordResetNotifier(ref.read(resetPasswordUsecaseProvider));
    });

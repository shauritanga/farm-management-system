import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use case for getting current authenticated user
class GetCurrentUserUsecase {
  final AuthRepository _authRepository;

  GetCurrentUserUsecase(this._authRepository);

  /// Get current authenticated user
  Future<UserEntity?> call() async {
    try {
      return await _authRepository.getCurrentUser();
    } catch (e) {
      return null;
    }
  }
}

/// Use case for checking authentication status
class IsAuthenticatedUsecase {
  final AuthRepository _authRepository;

  IsAuthenticatedUsecase(this._authRepository);

  /// Check if user is authenticated
  Future<bool> call() async {
    try {
      return await _authRepository.isAuthenticated();
    } catch (e) {
      return false;
    }
  }
}

/// Use case for logout
class LogoutUsecase {
  final AuthRepository _authRepository;

  LogoutUsecase(this._authRepository);

  /// Logout current user
  Future<void> call() async {
    try {
      await _authRepository.logout();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}

/// Use case for password reset
class ResetPasswordUsecase {
  final AuthRepository _authRepository;

  ResetPasswordUsecase(this._authRepository);

  /// Send password reset email
  Future<void> call(String email) async {
    try {
      // Validate email
      if (email.trim().isEmpty) {
        throw Exception('Email is required');
      }

      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      // Check if email exists
      final emailExists = await _authRepository.emailExists(email);
      if (!emailExists) {
        throw Exception('No account found with this email address');
      }

      await _authRepository.resetPassword(email.trim().toLowerCase());
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

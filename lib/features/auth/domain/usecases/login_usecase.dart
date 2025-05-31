import '../entities/user.dart';
import '../repositories/user_repository.dart';
import '../../data/models/user_model.dart';

/// Use case for user login
class LoginUsecase {
  final AuthRepository _authRepository;

  LoginUsecase(this._authRepository);

  /// Execute login with email and password
  Future<UserEntity> call(String email, String password) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Create login credentials
      final credentials = LoginCredentials(email: email, password: password);

      // Perform login
      final user = await _authRepository.login(credentials);

      // Validate user status
      if (!user.isActive) {
        throw Exception('Your account is not active. Please contact support.');
      }

      return user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

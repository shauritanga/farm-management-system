import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use case for Google Sign-In
class GoogleSignInUsecase {
  final AuthRepository _authRepository;

  GoogleSignInUsecase(this._authRepository);

  /// Execute Google Sign-In
  Future<UserEntity> call() async {
    try {
      final user = await _authRepository.signInWithGoogle();

      // Validate user status
      if (!user.isActive) {
        throw Exception('Your account is not active. Please contact support.');
      }

      return user;
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}

import 'package:agripoa/features/auth/domain/repositories/user_repository.dart';

class LoginUsecases {
  final UserRepository _userRepository;

  LoginUsecases(this._userRepository);

  Future<void> call(String email, String password) async {
    try {
      await _userRepository.login(email, password);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }
}

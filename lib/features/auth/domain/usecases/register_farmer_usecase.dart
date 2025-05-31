import '../entities/user.dart';
import '../repositories/user_repository.dart';
import '../../data/models/user_model.dart';

/// Use case for farmer registration
class RegisterFarmerUsecase {
  final AuthRepository _authRepository;

  RegisterFarmerUsecase(this._authRepository);

  /// Execute farmer registration
  Future<UserEntity> call({
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
    try {
      // Validate input
      _validateInput(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        phoneNumber: phoneNumber,
        farmSize: farmSize,
      );

      // Check if email already exists
      final emailExists = await _authRepository.emailExists(email);
      if (emailExists) {
        throw Exception('An account with this email already exists');
      }

      // Create registration data with default subscription
      final now = DateTime.now();
      final trialEndDate = now.add(const Duration(days: 14));

      final registrationData = FarmerRegistrationData(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
        phoneNumber: phoneNumber?.trim(),
        farmName: farmName?.trim(),
        farmLocation: farmLocation?.trim(),
        farmSize: farmSize,
        cropTypes: cropTypes,
        subscriptionPackage: 'free_tier',
        subscriptionStatus: 'trial',
        trialEndDate: trialEndDate,
      );

      // Perform registration
      final user = await _authRepository.registerFarmer(registrationData);

      return user;
    } catch (e) {
      throw Exception(
        'Registration failed: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  /// Validate registration input
  void _validateInput({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? phoneNumber,
    double? farmSize,
  }) {
    // Name validation
    if (name.trim().isEmpty) {
      throw Exception('Name is required');
    }
    if (name.trim().length < 2) {
      throw Exception('Name must be at least 2 characters');
    }

    // Email validation
    if (email.trim().isEmpty) {
      throw Exception('Email is required');
    }
    if (!_isValidEmail(email)) {
      throw Exception('Please enter a valid email address');
    }

    // Password validation
    if (password.isEmpty) {
      throw Exception('Password is required');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }
    if (!_isStrongPassword(password)) {
      throw Exception(
        'Password must contain at least one letter and one number',
      );
    }

    // Phone number validation (optional)
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      if (!_isValidPhoneNumber(phoneNumber)) {
        throw Exception('Please enter a valid phone number');
      }
    }

    // Farm size validation (optional)
    if (farmSize != null && farmSize <= 0) {
      throw Exception('Farm size must be greater than 0');
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Check if password is strong enough
  bool _isStrongPassword(String password) {
    // At least one letter and one number
    return RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password);
  }

  /// Validate phone number format (basic validation)
  bool _isValidPhoneNumber(String phoneNumber) {
    // Remove spaces and special characters
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    // Check if it's a valid length and contains only digits and +
    return RegExp(r'^\+?[0-9]{9,15}$').hasMatch(cleanNumber);
  }
}

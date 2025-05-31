import '../entities/user.dart';
import '../../data/models/user_model.dart';

/// Repository interface for user authentication and management
abstract class AuthRepository {
  /// Login with email and password
  Future<UserEntity> login(LoginCredentials credentials);

  /// Sign in with Google
  Future<UserEntity> signInWithGoogle();

  /// Register a new farmer
  Future<UserEntity> registerFarmer(FarmerRegistrationData data);

  /// Get current authenticated user
  Future<UserEntity?> getCurrentUser();

  /// Logout current user
  Future<void> logout();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get user by ID
  Future<UserEntity?> getUserById(String userId);

  /// Update user profile
  Future<UserEntity> updateUserProfile(UserEntity user);

  /// Update last login time
  Future<void> updateLastLogin(String userId);

  /// Check if email exists
  Future<bool> emailExists(String email);

  /// Reset password
  Future<void> resetPassword(String email);

  /// Delete user account
  Future<void> deleteAccount(String userId);
}

// Keep the old interface for backward compatibility
abstract class UserRepository {
  Future<void> login(String email, String password);
  Future<void> createUser(String userId, String name, String email);
}

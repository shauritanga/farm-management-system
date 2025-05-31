import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote.dart';
import '../models/user_model.dart';

/// Implementation of AuthRepository using Firebase
class AuthRepositoryImpl implements AuthRepository {
  final RemoteAuthDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserEntity> login(LoginCredentials credentials) async {
    try {
      final userModel = await _remoteDataSource.login(credentials);
      return userModel;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final userModel = await _remoteDataSource.signInWithGoogle();
      return userModel;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  @override
  Future<UserEntity> registerFarmer(FarmerRegistrationData data) async {
    try {
      final userModel = await _remoteDataSource.registerFarmer(data);
      return userModel;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUser();
      return userModel;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await _remoteDataSource.isAuthenticated();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserEntity?> getUserById(String userId) async {
    try {
      final userModel = await _remoteDataSource.getUserById(userId);
      return userModel;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserEntity> updateUserProfile(UserEntity user) async {
    try {
      final userModel = await _remoteDataSource.updateUserProfile(user);
      return userModel;
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  @override
  Future<void> updateLastLogin(String userId) async {
    try {
      await _remoteDataSource.updateLastLogin(userId);
    } catch (e) {
      // Don't throw error for last login update failure
    }
  }

  @override
  Future<bool> emailExists(String email) async {
    try {
      return await _remoteDataSource.emailExists(email);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _remoteDataSource.resetPassword(email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  @override
  Future<void> deleteAccount(String userId) async {
    try {
      await _remoteDataSource.deleteAccount(userId);
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }
}

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(remoteAuthDataSourceProvider));
});

/// Legacy UserRepositoryImpl for backward compatibility
class UserRepositoryImpl implements UserRepository {
  final RemoteAuthDataSource _remoteAuthDataSource;

  UserRepositoryImpl(this._remoteAuthDataSource);

  @override
  Future<void> login(String email, String password) {
    return _remoteAuthDataSource.legacyLogin(email, password);
  }

  @override
  Future<void> createUser(String userId, String name, String email) {
    return _remoteAuthDataSource.createUser(userId, name, email);
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.read(remoteAuthDataSourceProvider));
});

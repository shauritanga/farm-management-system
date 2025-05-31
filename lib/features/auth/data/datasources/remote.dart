import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';

/// Remote data source for authentication using Firebase
class RemoteAuthDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Collection reference for users
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Login with email and password
  Future<UserModel> login(LoginCredentials credentials) async {
    try {
      // Authenticate with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: credentials.email,
        password: credentials.password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Authentication failed');
      }

      // Get user data from Firestore
      final userDoc = await _usersCollection.doc(firebaseUser.uid).get();
      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      final userModel = UserModel.fromFirestore(userDoc);

      // Update last login time
      await updateLastLogin(firebaseUser.uid);

      return userModel.copyWith(lastLoginAt: DateTime.now());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Failed to sign in with Google');
      }

      // Check if user already exists in Firestore
      final userDoc = await _usersCollection.doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        // User exists, update last login and return
        await updateLastLogin(firebaseUser.uid);
        final userModel = UserModel.fromFirestore(userDoc);
        return userModel.copyWith(lastLoginAt: DateTime.now());
      } else {
        // New user, create profile in Firestore with default subscription
        final now = DateTime.now();
        final trialEndDate = now.add(const Duration(days: 14));

        final userModel = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Google User',
          email: firebaseUser.email ?? '',
          userType: UserType.farmer, // Default to farmer for Google sign-in
          status: UserStatus.active,
          profileImageUrl: firebaseUser.photoURL,
          subscriptionPackage: 'free_tier',
          subscriptionStatus: 'trial',
          trialEndDate: trialEndDate,
          createdAt: now,
          lastLoginAt: now,
        );

        await _usersCollection
            .doc(firebaseUser.uid)
            .set(userModel.toCreateMap());
        return userModel;
      }
    } catch (e) {
      if (e.toString().contains('cancelled')) {
        throw Exception('Google sign-in was cancelled');
      }
      throw Exception('Google sign-in failed: $e');
    }
  }

  /// Register a new farmer
  Future<UserModel> registerFarmer(FarmerRegistrationData data) async {
    try {
      // Check if email already exists
      if (await emailExists(data.email)) {
        throw Exception('Email already exists');
      }

      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: data.email,
        password: data.password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create user account');
      }

      // Create user profile in Firestore
      final userModel = UserModel(
        id: firebaseUser.uid,
        name: data.name,
        email: data.email,
        userType: UserType.farmer,
        status: UserStatus.active,
        phoneNumber: data.phoneNumber,
        farmName: data.farmName,
        farmLocation: data.farmLocation,
        farmSize: data.farmSize,
        cropTypes: data.cropTypes,
        subscriptionPackage: data.subscriptionPackage ?? 'free_tier',
        subscriptionStatus: data.subscriptionStatus ?? 'trial',
        trialEndDate: data.trialEndDate,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _usersCollection.doc(firebaseUser.uid).set(userModel.toCreateMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Get current authenticated user
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final userDoc = await _usersCollection.doc(firebaseUser.uid).get();
      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      return null;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return _auth.currentUser != null;
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<UserModel> updateUserProfile(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _usersCollection.doc(user.id).update(userModel.toMap());
      return userModel;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Update last login time
  Future<void> updateLastLogin(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      // Don't throw error for last login update failure
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final query =
          await _usersCollection
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  /// Delete user account
  Future<void> deleteAccount(String userId) async {
    try {
      // Delete user document from Firestore
      await _usersCollection.doc(userId).delete();

      // Delete Firebase Auth user
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null && firebaseUser.uid == userId) {
        await firebaseUser.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Handle Firebase Auth exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'email-already-in-use':
        return Exception('Email is already registered');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'user-disabled':
        return Exception('User account has been disabled');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }

  // Legacy methods for backward compatibility
  Future<void> createUser(String userId, String name, String email) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: 'password',
      );
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> legacyLogin(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }
}

final remoteAuthDataSourceProvider = Provider<RemoteAuthDataSource>((ref) {
  return RemoteAuthDataSource();
});

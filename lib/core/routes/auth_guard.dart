import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/mobile_auth_provider.dart';
import '../../features/auth/presentation/states/auth_state.dart';

/// Authentication guard for protecting routes
class AuthGuard {
  /// List of routes that require authentication
  static const List<String> _protectedRoutes = [
    '/farmer-home',
    '/farmer-farms',
    '/farmer-marketplace',
    '/farmer-profile',
    '/cooperative-home',
    '/cooperative-farmers',
    '/cooperative-sales',
    '/cooperative-reports',
    '/cooperative-profile',
  ];

  /// List of routes that should redirect authenticated users
  static const List<String> _guestOnlyRoutes = [
    '/login',
    '/register',
    '/onboarding',
  ];

  /// Check if route requires authentication
  static bool isProtectedRoute(String location) {
    return _protectedRoutes.any((route) => location.startsWith(route));
  }

  /// Check if route is for guests only
  static bool isGuestOnlyRoute(String location) {
    return _guestOnlyRoutes.any((route) => location.startsWith(route));
  }

  /// Redirect logic for GoRouter
  static String? redirect(BuildContext context, GoRouterState state) {
    final container = ProviderScope.containerOf(context);
    final authState = container.read(mobileAuthProvider);
    final location = state.uri.path;

    // If user is authenticated
    if (authState is AuthAuthenticated) {
      // Redirect from guest-only routes to appropriate home
      if (isGuestOnlyRoute(location)) {
        if (authState.user.isFarmer) {
          return '/farmer-home';
        } else if (authState.user.isCooperative) {
          return '/cooperative-home';
        } else {
          return '/home';
        }
      }

      // Check user type permissions for specific routes
      if (location.startsWith('/farmer-') && !authState.user.isFarmer) {
        return '/cooperative-home';
      }

      if (location.startsWith('/cooperative-') &&
          !authState.user.isCooperative) {
        return '/farmer-home';
      }

      return null; // Allow access
    }

    // If user is not authenticated
    if (authState is AuthUnauthenticated) {
      // Redirect from protected routes to login
      if (isProtectedRoute(location)) {
        return '/login';
      }
      return null; // Allow access to public routes
    }

    // If auth state is loading or error, allow current route
    // This prevents redirect loops during app initialization
    return null;
  }

  /// Initialize authentication state before routing
  static Future<void> initializeAuth(WidgetRef ref) async {
    final authNotifier = ref.read(mobileAuthProvider.notifier);
    await authNotifier.initializeAuth();
  }
}

/// Provider for auth guard
final authGuardProvider = Provider<AuthGuard>((ref) {
  return AuthGuard();
});

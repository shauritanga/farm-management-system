import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/states/auth_state.dart';
import '../theme/screens/theme_demo_screen.dart';

// Farmer screens
import '../../features/farmer/presentation/screens/farmer_home_shell.dart';
import '../../features/farmer/presentation/screens/farmer_dashboard_screen.dart';
import '../../features/farmer/presentation/screens/farmer_farms_screen.dart';
import '../../features/farmer/presentation/screens/farmer_marketplace_screen.dart';
import '../../features/farmer/presentation/screens/farmer_profile_screen.dart';

// Cooperative screens
import '../../features/cooperative/presentation/screens/cooperative_home_shell.dart';
import '../../features/cooperative/presentation/screens/cooperative_dashboard_screen.dart';
import '../../features/cooperative/presentation/screens/cooperative_farmers_screen.dart';
import '../../features/cooperative/presentation/screens/cooperative_sales_screen.dart';
import '../../features/cooperative/presentation/screens/cooperative_reports_screen.dart';
import '../../features/cooperative/presentation/screens/cooperative_profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash/Initial route
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

      // Onboarding route
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Login route
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // Register route
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Farmer home with StatefulShell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return FarmerHomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/farmer-home',
                builder: (context, state) => const FarmerDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/farmer-farms',
                builder: (context, state) => const FarmerFarmsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/farmer-marketplace',
                builder: (context, state) => const FarmerMarketplaceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/farmer-profile',
                builder: (context, state) => const FarmerProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Cooperative home with StatefulShell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CooperativeHomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cooperative-home',
                builder: (context, state) => const CooperativeDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cooperative-farmers',
                builder: (context, state) => const CooperativeFarmersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cooperative-sales',
                builder: (context, state) => const CooperativeSalesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cooperative-reports',
                builder: (context, state) => const CooperativeReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cooperative-profile',
                builder: (context, state) => const CooperativeProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Home route (fallback)
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

      // Theme demo route
      GoRoute(
        path: '/theme-demo',
        builder: (context, state) => const ThemeDemoScreen(),
      ),
    ],
  );
}

// Splash screen to determine initial route
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    // Add a small delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    final hasCompletedOnboarding =
        await ref.read(onboardingProvider.notifier).checkOnboardingStatus();

    if (mounted) {
      if (hasCompletedOnboarding) {
        // Check if user is already authenticated
        await ref.read(authProvider.notifier).initializeAuth();
        if (mounted) {
          final authState = ref.read(authProvider);
          if (authState is AuthAuthenticated) {
            // Navigate based on user type
            if (authState.user.isFarmer) {
              context.go('/farmer-home');
            } else if (authState.user.isCooperative) {
              context.go('/cooperative-home');
            } else {
              context.go('/home');
            }
          } else {
            context.go('/login');
          }
        }
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo/icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.agriculture,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 24),

            // App name
            Text(
              'Agripoa',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // Tagline
            Text(
              'Agricultural Platform for Tanzania',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),

            const SizedBox(height: 40),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder screens - replace with your actual screens
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Authentication Screen'),
            const Text('Replace this with your actual auth screen'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/theme-demo'),
              child: const Text('View Theme Demo'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Home Screen'),
            Text('Replace this with your actual home screen'),
          ],
        ),
      ),
    );
  }
}

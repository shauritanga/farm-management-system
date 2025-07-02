import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/mobile_auth_provider.dart';
import '../providers/auth_provider.dart';
import '../states/auth_state.dart' as auth_states;
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/services/offline_auth_service.dart';

class MobileLoginScreen extends ConsumerStatefulWidget {
  const MobileLoginScreen({super.key});

  @override
  ConsumerState<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends ConsumerState<MobileLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String _biometricType = 'Biometric';
  OfflineAuthStatus _offlineStatus = OfflineAuthStatus.online;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _checkOfflineStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final biometricService = ref.read(biometricAuthServiceProvider);
    final isAvailable = await biometricService.isBiometricAvailable();
    final isEnabled = await biometricService.isBiometricEnabled();

    if (isAvailable) {
      final types = await biometricService.getAvailableBiometrics();
      final typeName = biometricService.getBiometricTypeName(types);

      if (mounted) {
        setState(() {
          _biometricAvailable = isAvailable;
          _biometricEnabled = isEnabled;
          _biometricType = typeName;
        });
      }
    }
  }

  Future<void> _checkOfflineStatus() async {
    final offlineService = ref.read(offlineAuthServiceProvider);
    final status = await offlineService.getOfflineAuthStatus();

    if (mounted) {
      setState(() {
        _offlineStatus = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to login state changes
    ref.listen<auth_states.LoginState>(mobileLoginProvider, (previous, next) {
      if (next is auth_states.LoginSuccess) {
        // Update auth state and navigate
        ref.read(mobileAuthProvider.notifier).setAuthenticated(next.user);

        if (next.user.isFarmer) {
          context.go('/farmer-home');
        } else if (next.user.isCooperative) {
          context.go('/cooperative-home');
        } else {
          context.go('/home');
        }
      } else if (next is auth_states.LoginError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      }
    });

    final loginState = ref.watch(mobileLoginProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // App Logo/Title
              const Text(
                'Agripoa',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Farm Management System',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Offline Status Indicator
              if (_offlineStatus != OfflineAuthStatus.online)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color:
                        _offlineStatus == OfflineAuthStatus.offlineAuthenticated
                            ? Colors.orange[100]
                            : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          _offlineStatus ==
                                  OfflineAuthStatus.offlineAuthenticated
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _offlineStatus == OfflineAuthStatus.offlineAuthenticated
                            ? Icons.wifi_off
                            : Icons.error_outline,
                        color:
                            _offlineStatus ==
                                    OfflineAuthStatus.offlineAuthenticated
                                ? Colors.orange
                                : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _offlineStatus.message,
                        style: TextStyle(
                          color:
                              _offlineStatus ==
                                      OfflineAuthStatus.offlineAuthenticated
                                  ? Colors.orange[800]
                                  : Colors.red[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Biometric Login Button (if available and enabled)
              if (_biometricAvailable && _biometricEnabled)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton.icon(
                    onPressed:
                        loginState is auth_states.LoginLoading
                            ? null
                            : _handleBiometricLogin,
                    icon: Icon(_getBiometricIcon()),
                    label: Text('Sign in with $_biometricType'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

              // Divider
              if (_biometricAvailable && _biometricEnabled)
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

              const SizedBox(height: 20),

              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            loginState is auth_states.LoginLoading
                                ? null
                                : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            loginState is auth_states.LoginLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Register Link
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('Don\'t have an account? Register here'),
              ),

              // Setup Biometric Button (if available but not enabled)
              if (_biometricAvailable && !_biometricEnabled)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextButton.icon(
                    onPressed: _setupBiometric,
                    icon: Icon(_getBiometricIcon()),
                    label: Text('Set up $_biometricType login'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBiometricIcon() {
    if (_biometricType.contains('Face')) {
      return Icons.face;
    } else if (_biometricType.contains('Fingerprint')) {
      return Icons.fingerprint;
    } else {
      return Icons.security;
    }
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(mobileLoginProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);
    }
  }

  void _handleBiometricLogin() {
    ref.read(mobileLoginProvider.notifier).biometricLogin();
  }

  Future<void> _setupBiometric() async {
    final result =
        await ref.read(biometricAuthServiceProvider).setupBiometric();

    if (result == BiometricSetupResult.success) {
      setState(() {
        _biometricEnabled = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_biometricType authentication enabled!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to set up biometric authentication'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

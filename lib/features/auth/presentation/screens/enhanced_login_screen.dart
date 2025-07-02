import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/responsive_utils.dart';
import '../providers/auth_provider.dart';
import '../providers/mobile_auth_provider.dart';
import '../states/auth_state.dart' as auth_states;
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/services/offline_auth_service.dart';

class EnhancedLoginScreen extends ConsumerStatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  ConsumerState<EnhancedLoginScreen> createState() =>
      _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends ConsumerState<EnhancedLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Mobile-specific state
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String _biometricType = 'Biometric';
  OfflineAuthStatus _offlineStatus = OfflineAuthStatus.online;

  @override
  void initState() {
    super.initState();
    _initializeMobileFeatures();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _initializeMobileFeatures() async {
    await _checkBiometricAvailability();
    await _checkOfflineStatus();
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
    final theme = Theme.of(context);

    // Listen to mobile login state changes
    ref.listen<auth_states.LoginState>(mobileLoginProvider, (previous, next) {
      if (next is auth_states.LoginSuccess) {
        // Update mobile auth state and navigate
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
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: ResponsiveUtils.spacing12),
                Expanded(child: Text(next.message)),
              ],
            ),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
            ),
            margin: ResponsiveUtils.paddingAll16,
          ),
        );
      }
    });

    final loginState = ref.watch(mobileLoginProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.surface,
              theme.colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: Padding(
                padding: ResponsiveUtils.paddingHorizontal24,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: ResponsiveUtils.height20),

                      // Enhanced header
                      _buildEnhancedHeader(theme),

                      SizedBox(height: ResponsiveUtils.height24),

                      // Offline Status Indicator
                      if (_offlineStatus != OfflineAuthStatus.online)
                        _buildOfflineStatusIndicator(theme),

                      // Mobile login options (biometric)
                      if (_biometricAvailable && _biometricEnabled)
                        _buildBiometricLoginSection(theme, loginState),

                      // Login card
                      _buildLoginCard(theme, loginState),

                      SizedBox(height: ResponsiveUtils.height20),

                      // Footer section
                      _buildFooterSection(theme),

                      SizedBox(height: ResponsiveUtils.height16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Welcome text
        Text(
          'Welcome Back',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize28,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),

        SizedBox(height: ResponsiveUtils.height8),

        // Subtitle with better styling
        Container(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.spacing32),
          child: Text(
            'Sign in to continue managing your farm',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineStatusIndicator(ThemeData theme) {
    return Container(
      padding: ResponsiveUtils.paddingAll16,
      margin: EdgeInsets.only(bottom: ResponsiveUtils.height20),
      decoration: BoxDecoration(
        color:
            _offlineStatus == OfflineAuthStatus.offlineAuthenticated
                ? Colors.orange[100]
                : Colors.red[100],
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color:
              _offlineStatus == OfflineAuthStatus.offlineAuthenticated
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
                _offlineStatus == OfflineAuthStatus.offlineAuthenticated
                    ? Colors.orange
                    : Colors.red,
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            child: Text(
              _offlineStatus.message,
              style: GoogleFonts.inter(
                color:
                    _offlineStatus == OfflineAuthStatus.offlineAuthenticated
                        ? Colors.orange[800]
                        : Colors.red[800],
                fontWeight: FontWeight.w500,
                fontSize: ResponsiveUtils.fontSize14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricLoginSection(
    ThemeData theme,
    auth_states.LoginState loginState,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.height20),
      child: Column(
        children: [
          // Biometric Login Button
          Container(
            height: ResponsiveUtils.buttonHeightExtraLarge,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.2),
                  blurRadius: ResponsiveUtils.spacing12,
                  offset: Offset(0, ResponsiveUtils.spacing2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed:
                  loginState is auth_states.LoginLoading
                      ? null
                      : _handleBiometricLogin,
              icon: Icon(_getBiometricIcon(), color: Colors.white),
              label: Text(
                'Sign in with $_biometricType',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
                ),
              ),
            ),
          ),

          SizedBox(height: ResponsiveUtils.height16),

          // Divider
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        theme.colorScheme.outline.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.spacing16,
                ),
                child: Text(
                  'or',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.outline.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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

  Widget _buildLoginCard(ThemeData theme, auth_states.LoginState loginState) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: ResponsiveUtils.spacing24,
            offset: Offset(0, ResponsiveUtils.spacing4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: ResponsiveUtils.spacing8,
            offset: Offset(0, ResponsiveUtils.spacing2),
          ),
        ],
      ),
      child: Padding(
        padding: ResponsiveUtils.paddingAll24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Enhanced email field
            _buildEnhancedTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'Enter your email address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            SizedBox(height: ResponsiveUtils.height16),

            // Enhanced password field
            _buildEnhancedTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),

            SizedBox(height: ResponsiveUtils.height20),

            // Enhanced login button
            _buildEnhancedLoginButton(theme, loginState),

            // Forgot password link
            _buildForgotPasswordLink(theme),

            // Divider with OR
            _buildOrDivider(theme),

            // Google Sign-In button
            _buildGoogleSignInButton(theme, loginState),

            // Setup Biometric Button (if available but not enabled)
            if (_biometricAvailable && !_biometricEnabled)
              _buildSetupBiometricButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: GoogleFonts.inter(fontSize: ResponsiveUtils.fontSize16),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              prefixIcon,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing16,
              vertical: ResponsiveUtils.spacing16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedLoginButton(
    ThemeData theme,
    auth_states.LoginState loginState,
  ) {
    return Container(
      height: ResponsiveUtils.buttonHeightExtraLarge,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: ResponsiveUtils.spacing12,
            offset: Offset(0, ResponsiveUtils.spacing2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: loginState is auth_states.LoginLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          ),
        ),
        child:
            loginState is auth_states.LoginLoading
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: ResponsiveUtils.iconSize20,
                      height: ResponsiveUtils.iconSize20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing12),
                    Text(
                      'Signing in...',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.fontSize16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                : Text(
                  'Sign In',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
      ),
    );
  }

  Widget _buildForgotPasswordLink(ThemeData theme) {
    return Center(
      child: TextButton(
        onPressed: () {
          context.push('/forgot-password');
        },
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: Text(
          'Forgot Password?',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.colorScheme.outline.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.spacing16),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing12,
              vertical: ResponsiveUtils.spacing4,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Text(
              'OR',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.outline.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton(
    ThemeData theme,
    auth_states.LoginState loginState,
  ) {
    return Container(
      height: ResponsiveUtils.buttonHeightLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: ResponsiveUtils.spacing8,
            offset: Offset(0, ResponsiveUtils.spacing2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed:
            loginState is auth_states.LoginLoading ? null : _handleGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google_logo.png',
              height: ResponsiveUtils.iconSize20,
              width: ResponsiveUtils.iconSize20,
              errorBuilder:
                  (context, error, stackTrace) => Icon(
                    Icons.g_mobiledata,
                    size: ResponsiveUtils.iconSize20,
                    color: Colors.red,
                  ),
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Text(
              'Continue with Google',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupBiometricButton(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(top: ResponsiveUtils.height16),
      child: TextButton.icon(
        onPressed: _setupBiometric,
        icon: Icon(_getBiometricIcon()),
        label: Text('Set up $_biometricType login'),
        style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
      ),
    );
  }

  Widget _buildFooterSection(ThemeData theme) {
    return Column(
      children: [
        // Enhanced register link
        Container(
          padding: ResponsiveUtils.paddingAll20,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: ResponsiveUtils.spacing16,
                offset: Offset(0, ResponsiveUtils.spacing4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                "New to our platform?",
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: ResponsiveUtils.height6),
              Text(
                "Join thousands of farmers managing their agricultural activities",
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveUtils.height12),
              SizedBox(
                width: double.infinity,
                height: ResponsiveUtils.buttonHeightLarge,
                child: OutlinedButton(
                  onPressed: () => context.push('/register'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius12,
                      ),
                    ),
                  ),
                  child: Text(
                    'Create Farmer Account',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.fontSize16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleGoogleSignIn() {
    // Use the mobile login provider for Google sign-in as well
    ref.read(mobileLoginProvider.notifier).signInWithGoogle();
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

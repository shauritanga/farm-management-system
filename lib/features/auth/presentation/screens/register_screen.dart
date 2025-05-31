import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../providers/auth_provider.dart';
import '../states/auth_state.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _farmLocationController = TextEditingController();
  final _farmSizeController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final List<String> _selectedCrops = [];

  final List<String> _availableCrops = [
    'Maize',
    'Rice',
    'Beans',
    'Cassava',
    'Sweet Potato',
    'Irish Potato',
    'Banana',
    'Coffee',
    'Tea',
    'Cotton',
    'Sunflower',
    'Groundnuts',
    'Sorghum',
    'Millet',
    'Wheat',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _farmNameController.dispose();
    _farmLocationController.dispose();
    _farmSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Listen to registration state changes
    ref.listen<RegistrationState>(registrationProvider, (previous, next) {
      if (next is RegistrationSuccess) {
        // Update auth state and navigate
        ref.read(authProvider.notifier).setAuthenticated(next.user);
        context.go('/home');
      } else if (next is RegistrationError) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    final registrationState = ref.watch(registrationProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Register as Farmer',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveUtils.paddingAll24,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(theme),

                SizedBox(height: ResponsiveUtils.height32),

                // Personal Information
                _buildPersonalInfoSection(theme),

                SizedBox(height: ResponsiveUtils.height24),

                // Farm Information
                _buildFarmInfoSection(theme),

                SizedBox(height: ResponsiveUtils.height32),

                // Register button
                SizedBox(
                  width: double.infinity,
                  height: ResponsiveUtils.buttonHeightExtraLarge,
                  child: ElevatedButton(
                    onPressed:
                        registrationState is RegistrationLoading
                            ? null
                            : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.radius12,
                        ),
                      ),
                    ),
                    child:
                        registrationState is RegistrationLoading
                            ? SizedBox(
                              width: ResponsiveUtils.iconSize20,
                              height: ResponsiveUtils.iconSize20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary,
                                ),
                              ),
                            )
                            : Text(
                              'Create Account',
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveUtils.fontSize16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),

                SizedBox(height: ResponsiveUtils.height24),

                // Login link
                _buildLoginLink(theme),

                SizedBox(height: ResponsiveUtils.height32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Join Agripoa',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize28,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),

        SizedBox(height: ResponsiveUtils.height8),

        Text(
          'Create your farmer account and start managing your agricultural activities',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),

        SizedBox(height: ResponsiveUtils.height16),

        // Name field
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full Name *',
            hintText: 'Enter your full name',
            prefixIcon: const Icon(Icons.person_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Name is required';
            }
            if (value.trim().length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        ),

        SizedBox(height: ResponsiveUtils.height16),

        // Email field
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email Address *',
            hintText: 'Enter your email address',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),

        SizedBox(height: ResponsiveUtils.height16),

        // Phone field
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
            ),
          ),
          keyboardType: TextInputType.phone,
        ),

        SizedBox(height: ResponsiveUtils.height16),

        // Password field
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password *',
            hintText: 'Create a strong password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
            ),
          ),
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
              return 'Password must contain at least one letter and one number';
            }
            return null;
          },
        ),

        SizedBox(height: ResponsiveUtils.height16),

        // Confirm password field
        TextFormField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            labelText: 'Confirm Password *',
            hintText: 'Confirm your password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
            ),
          ),
          obscureText: _obscureConfirmPassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFarmInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farm Information (Optional)',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),

        SizedBox(height: ResponsiveUtils.height16),

        // Farm name field
        TextFormField(
          controller: _farmNameController,
          decoration: InputDecoration(
            labelText: 'Farm Name',
            hintText: 'Enter your farm name',
            prefixIcon: const Icon(Icons.agriculture_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
            ),
          ),
        ),

        SizedBox(height: ResponsiveUtils.height16),

        // Farm location field
        TextFormField(
          controller: _farmLocationController,
          decoration: InputDecoration(
            labelText: 'Farm Location',
            hintText: 'Enter your farm location',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
            ),
          ),
        ),

        SizedBox(height: ResponsiveUtils.height16),

        // Farm size field
        TextFormField(
          controller: _farmSizeController,
          decoration: InputDecoration(
            labelText: 'Farm Size (Hectares)',
            hintText: 'Enter farm size in hectares',
            prefixIcon: const Icon(Icons.straighten_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final size = double.tryParse(value);
              if (size == null || size <= 0) {
                return 'Please enter a valid farm size';
              }
            }
            return null;
          },
        ),

        SizedBox(height: ResponsiveUtils.height16),

        // Crop types selection
        Text(
          'Crop Types',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),

        SizedBox(height: ResponsiveUtils.height8),

        Wrap(
          spacing: ResponsiveUtils.spacing8,
          runSpacing: ResponsiveUtils.spacing8,
          children:
              _availableCrops.map((crop) {
                final isSelected = _selectedCrops.contains(crop);
                return FilterChip(
                  label: Text(
                    crop,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      color:
                          isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCrops.add(crop);
                      } else {
                        _selectedCrops.remove(crop);
                      }
                    });
                  },
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.primary,
                  checkmarkColor: theme.colorScheme.onPrimary,
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildLoginLink(ThemeData theme) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: Text(
              'Login',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      final farmSize =
          _farmSizeController.text.isNotEmpty
              ? double.tryParse(_farmSizeController.text)
              : null;

      ref
          .read(registrationProvider.notifier)
          .registerFarmer(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
            phoneNumber:
                _phoneController.text.trim().isNotEmpty
                    ? _phoneController.text.trim()
                    : null,
            farmName:
                _farmNameController.text.trim().isNotEmpty
                    ? _farmNameController.text.trim()
                    : null,
            farmLocation:
                _farmLocationController.text.trim().isNotEmpty
                    ? _farmLocationController.text.trim()
                    : null,
            farmSize: farmSize,
            cropTypes: _selectedCrops.isNotEmpty ? _selectedCrops : null,
          );
    }
  }
}

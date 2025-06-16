import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../subscription/domain/entities/subscription.dart';
import '../../../subscription/presentation/screens/subscription_screen.dart';
import '../../../farm/presentation/providers/farm_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';

/// Full-screen add farm screen
class AddFarmScreen extends ConsumerStatefulWidget {
  final SubscriptionPackage currentPackage;

  const AddFarmScreen({super.key, required this.currentPackage});

  @override
  ConsumerState<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends ConsumerState<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _sizeController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _selectedCrops = [];
  final List<String> _availableCrops = [
    'Maize',
    'Rice',
    'Beans',
    'Tomatoes',
    'Coffee',
    'Banana',
    'Sunflower',
    'Cassava',
    'Sweet Potato',
    'Onions',
    'Cabbage',
    'Carrots',
    'Spinach',
    'Sorghum',
    'Millet',
    'Coconut',
    'Avocado',
    'Mango',
  ];

  String? _selectedSoilType;
  String? _selectedIrrigationType;
  bool _isLoading = false;

  final List<String> _soilTypes = [
    'Loamy',
    'Clay',
    'Sandy',
    'Volcanic',
    'Alluvial',
    'Silty',
  ];

  final List<String> _irrigationTypes = [
    'Rain-fed',
    'Drip irrigation',
    'Flood irrigation',
    'Sprinkler irrigation',
    'Manual watering',
    'Center pivot',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _sizeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme),
      body: _buildBody(theme),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      title: Text(
        'Add New Farm',
        style: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.fontSize20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        if (widget.currentPackage == SubscriptionPackage.freeTier)
          IconButton(
            onPressed: _showSubscriptionInfo,
            icon: const Icon(Icons.info_outline),
          ),
      ],
    );
  }

  /// Build body
  Widget _buildBody(ThemeData theme) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscription warning for free tier
            if (widget.currentPackage == SubscriptionPackage.freeTier)
              _buildSubscriptionWarning(theme),

            // Farm basic information section
            _buildSectionHeader(theme, 'Basic Information', Icons.info_outline),
            SizedBox(height: ResponsiveUtils.height16),

            _buildTextField(
              controller: _nameController,
              label: 'Farm Name',
              hint: 'Enter your farm name',
              icon: Icons.agriculture,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Farm name is required';
                }
                if (value.trim().length < 2) {
                  return 'Farm name must be at least 2 characters';
                }
                if (value.trim().length > 100) {
                  return 'Farm name cannot exceed 100 characters';
                }
                return null;
              },
            ),

            SizedBox(height: ResponsiveUtils.height16),

            _buildTextField(
              controller: _locationController,
              label: 'Location',
              hint: 'Enter farm location (e.g., Morogoro, Tanzania)',
              icon: Icons.location_on,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Location is required';
                }
                if (value.trim().length < 2) {
                  return 'Location must be at least 2 characters';
                }
                return null;
              },
            ),

            SizedBox(height: ResponsiveUtils.height16),

            _buildTextField(
              controller: _sizeController,
              label: 'Size (hectares)',
              hint: 'Enter farm size in hectares',
              icon: Icons.straighten,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Size is required';
                }
                final size = double.tryParse(value);
                if (size == null || size <= 0) {
                  return 'Enter a valid size greater than 0';
                }
                if (size > 10000) {
                  return 'Size cannot exceed 10,000 hectares';
                }
                return null;
              },
            ),

            SizedBox(height: ResponsiveUtils.height24),

            // Crop selection section
            _buildSectionHeader(theme, 'Crop Types', Icons.eco),
            SizedBox(height: ResponsiveUtils.height16),
            _buildCropSelection(theme),

            SizedBox(height: ResponsiveUtils.height24),

            // Farm details section
            _buildSectionHeader(
              theme,
              'Farm Details (Optional)',
              Icons.settings,
            ),
            SizedBox(height: ResponsiveUtils.height16),

            _buildDropdown(
              label: 'Soil Type',
              value: _selectedSoilType,
              items: _soilTypes,
              icon: Icons.terrain,
              onChanged: (value) => setState(() => _selectedSoilType = value),
            ),

            SizedBox(height: ResponsiveUtils.height16),

            _buildDropdown(
              label: 'Irrigation Type',
              value: _selectedIrrigationType,
              items: _irrigationTypes,
              icon: Icons.water_drop,
              onChanged:
                  (value) => setState(() => _selectedIrrigationType = value),
            ),

            SizedBox(height: ResponsiveUtils.height16),

            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter farm description (optional)',
              icon: Icons.description,
              maxLines: 4,
            ),

            // Add some bottom padding for the bottom bar
            SizedBox(height: ResponsiveUtils.height100),
          ],
        ),
      ),
    );
  }

  /// Build bottom bar with action buttons
  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: ResponsiveUtils.spacing8,
            offset: Offset(0, -ResponsiveUtils.spacing2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    _isLoading ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUtils.spacing16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius12,
                    ),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createFarm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUtils.spacing16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius12,
                    ),
                  ),
                ),
                child:
                    _isLoading
                        ? SizedBox(
                          height: ResponsiveUtils.iconSize20,
                          width: ResponsiveUtils.iconSize20,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          'Create Farm',
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build subscription warning
  Widget _buildSubscriptionWarning(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.height20),
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange,
            size: ResponsiveUtils.iconSize20,
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free Tier Limitation',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.height4),
                Text(
                  'Free tier allows only 1 farm. Upgrade to Serengeti or Tanzanite for unlimited farms.',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: ResponsiveUtils.iconSize20,
        ),
        SizedBox(width: ResponsiveUtils.spacing8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// Build text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.spacing16,
          vertical: ResponsiveUtils.spacing16,
        ),
      ),
      style: GoogleFonts.inter(fontSize: ResponsiveUtils.fontSize16),
    );
  }

  /// Build dropdown
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.spacing16,
          vertical: ResponsiveUtils.spacing16,
        ),
      ),
      items:
          items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize16,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  /// Build crop selection
  Widget _buildCropSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedCrops.isNotEmpty) ...[
          Text(
            'Selected Crops:',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: ResponsiveUtils.height8),
          Wrap(
            spacing: ResponsiveUtils.spacing8,
            runSpacing: ResponsiveUtils.spacing8,
            children:
                _selectedCrops
                    .map(
                      (crop) => Chip(
                        label: Text(
                          crop,
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize12,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.secondary,
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedCrops.remove(crop);
                          });
                        },
                      ),
                    )
                    .toList(),
          ),
          SizedBox(height: ResponsiveUtils.height16),
        ],

        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ResponsiveUtils.radius12),
                    topRight: Radius.circular(ResponsiveUtils.radius12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.eco,
                      color: theme.colorScheme.primary,
                      size: ResponsiveUtils.iconSize16,
                    ),
                    SizedBox(width: ResponsiveUtils.spacing8),
                    Text(
                      'Select Crop Types (Required)',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing16),
                child: Wrap(
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
                              fontWeight: FontWeight.w500,
                              color:
                                  isSelected
                                      ? Colors.white
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
                          selectedColor: theme.colorScheme.secondary,
                          checkmarkColor: Colors.white,
                          side: BorderSide(
                            color:
                                isSelected
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.outline.withValues(
                                      alpha: 0.3,
                                    ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),

        if (_selectedCrops.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: ResponsiveUtils.height8),
            child: Text(
              'Please select at least one crop type',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  /// Show subscription info
  void _showSubscriptionInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Subscription Information',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free Tier: 1 farm limit',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.height8),
                Text(
                  'Upgrade to unlock unlimited farms:',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.height8),
                Text(
                  '• Serengeti Package: Unlimited farms\n• Tanzanite Package: Unlimited farms + user assignment',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  /// Create farm
  Future<void> _createFarm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCrops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one crop type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = ref.read(authProvider);
      if (authState is! AuthAuthenticated) {
        throw Exception('User not authenticated');
      }

      // Create farm
      final farmNotifier = ref.read(farmProvider.notifier);
      await farmNotifier.createFarm(
        farmerId: authState.user.id,
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        size: double.parse(_sizeController.text.trim()),
        cropTypes: _selectedCrops,
        userSubscription: widget.currentPackage,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        soilType: _selectedSoilType,
        irrigationType: _selectedIrrigationType,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Farm "${_nameController.text.trim()}" created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show error message with user-friendly text
  void _showErrorMessage(String error) {
    String title = 'Error Creating Farm';
    String message = error;
    Color backgroundColor = Colors.red;
    IconData icon = Icons.error;

    // Check for subscription-related errors
    if (error.contains('Free tier users can only create 1 farm') ||
        error.contains('Upgrade to Serengeti or Tanzanite')) {
      title = 'Subscription Limit Reached';
      message =
          'Free tier allows only 1 farm. Upgrade to create unlimited farms!';
      backgroundColor = Colors.orange;
      icon = Icons.workspace_premium;

      _showSubscriptionLimitDialog();
      return;
    }

    // Check for authentication errors
    if (error.contains('not authenticated')) {
      title = 'Authentication Error';
      message = 'Please log in again to continue.';
      icon = Icons.login;
    }

    // Check for network/connection errors
    if (error.contains('Failed to create farm') ||
        error.contains('network') ||
        error.contains('connection')) {
      title = 'Connection Error';
      message = 'Please check your internet connection and try again.';
      icon = Icons.wifi_off;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show subscription limit dialog with upgrade options
  void _showSubscriptionLimitDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: Icon(
              Icons.workspace_premium,
              color: Colors.orange,
              size: ResponsiveUtils.iconSize48,
            ),
            title: Text(
              'Subscription Limit Reached',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your Free Tier subscription allows only 1 farm.',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUtils.height16),
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius12,
                    ),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Upgrade to unlock unlimited farms:',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.height8),
                      Text(
                        '• Serengeti Package: Unlimited farms\n• Tanzanite Package: Unlimited farms + user assignment',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize11,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleMaybeLater();
                },
                child: Text(
                  'Maybe Later',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleUpgradeNow();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Upgrade Now',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  /// Handle "Maybe Later" action - reset farm state and go back
  void _handleMaybeLater() {
    final authState = ref.read(authProvider);
    if (authState is AuthAuthenticated) {
      // Reset the farm provider state and reload existing farms
      ref.read(farmProvider.notifier).loadFarms(authState.user.id);
    }

    // Navigate back to farms screen
    Navigator.of(
      context,
    ).pop(false); // Return false to indicate no farm was created
  }

  /// Handle "Upgrade Now" action - reset farm state and navigate to subscription
  void _handleUpgradeNow() {
    final authState = ref.read(authProvider);
    if (authState is AuthAuthenticated) {
      // Reset the farm provider state and reload existing farms
      ref.read(farmProvider.notifier).loadFarms(authState.user.id);
    }

    // Navigate back to farms screen first
    Navigator.of(
      context,
    ).pop(false); // Return false to indicate no farm was created

    // Then navigate to subscription screen
    _navigateToSubscription();
  }

  /// Navigate to subscription screen
  void _navigateToSubscription() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SubscriptionScreen()));
  }
}

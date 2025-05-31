import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../subscription/domain/entities/subscription.dart';
import '../../../farm/presentation/providers/farm_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';

/// Dialog for creating a new farm
class CreateFarmDialog extends ConsumerStatefulWidget {
  final SubscriptionPackage currentPackage;

  const CreateFarmDialog({
    super.key,
    required this.currentPackage,
  });

  @override
  ConsumerState<CreateFarmDialog> createState() => _CreateFarmDialogState();
}

class _CreateFarmDialogState extends ConsumerState<CreateFarmDialog> {
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
  ];

  final List<String> _irrigationTypes = [
    'Rain-fed',
    'Drip irrigation',
    'Flood irrigation',
    'Sprinkler irrigation',
    'Manual watering',
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

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 500,
        ),
        padding: EdgeInsets.all(ResponsiveUtils.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.agriculture,
                  color: theme.colorScheme.primary,
                  size: ResponsiveUtils.iconSize24,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Expanded(
                  child: Text(
                    'Create New Farm',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.fontSize20,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            SizedBox(height: ResponsiveUtils.height16),

            // Subscription limit warning for free tier
            if (widget.currentPackage == SubscriptionPackage.freeTier)
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: ResponsiveUtils.iconSize16,
                    ),
                    SizedBox(width: ResponsiveUtils.spacing8),
                    Expanded(
                      child: Text(
                        'Free tier allows 1 farm only. Upgrade to create unlimited farms.',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (widget.currentPackage == SubscriptionPackage.freeTier)
              SizedBox(height: ResponsiveUtils.height16),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Farm name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Farm Name',
                        hint: 'Enter farm name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Farm name is required';
                          }
                          if (value.trim().length < 2) {
                            return 'Farm name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: ResponsiveUtils.height16),

                      // Location
                      _buildTextField(
                        controller: _locationController,
                        label: 'Location',
                        hint: 'Enter farm location',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Location is required';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: ResponsiveUtils.height16),

                      // Size
                      _buildTextField(
                        controller: _sizeController,
                        label: 'Size (hectares)',
                        hint: 'Enter farm size',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Size is required';
                          }
                          final size = double.tryParse(value);
                          if (size == null || size <= 0) {
                            return 'Enter a valid size greater than 0';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: ResponsiveUtils.height16),

                      // Crop types
                      _buildCropSelection(theme),

                      SizedBox(height: ResponsiveUtils.height16),

                      // Soil type
                      _buildDropdown(
                        label: 'Soil Type (Optional)',
                        value: _selectedSoilType,
                        items: _soilTypes,
                        onChanged: (value) => setState(() => _selectedSoilType = value),
                      ),

                      SizedBox(height: ResponsiveUtils.height16),

                      // Irrigation type
                      _buildDropdown(
                        label: 'Irrigation Type (Optional)',
                        value: _selectedIrrigationType,
                        items: _irrigationTypes,
                        onChanged: (value) => setState(() => _selectedIrrigationType = value),
                      ),

                      SizedBox(height: ResponsiveUtils.height16),

                      // Description
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description (Optional)',
                        hint: 'Enter farm description',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: ResponsiveUtils.height24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createFarm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: ResponsiveUtils.iconSize16,
                            width: ResponsiveUtils.iconSize16,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Create Farm',
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveUtils.fontSize14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
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
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing12,
              vertical: ResponsiveUtils.spacing12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCropSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crop Types',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height8),
        Container(
          padding: EdgeInsets.all(ResponsiveUtils.spacing12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
          ),
          child: Column(
            children: [
              Wrap(
                spacing: ResponsiveUtils.spacing8,
                runSpacing: ResponsiveUtils.spacing8,
                children: _availableCrops.map((crop) {
                  final isSelected = _selectedCrops.contains(crop);
                  return FilterChip(
                    label: Text(
                      crop,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize12,
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
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
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              if (_selectedCrops.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: ResponsiveUtils.spacing8),
                  child: Text(
                    'Select at least one crop type',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
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
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing12,
              vertical: ResponsiveUtils.spacing12,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _createFarm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCrops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one crop type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authProvider);
      if (authState is! AuthAuthenticated) {
        throw Exception('User not authenticated');
      }

      await ref.read(farmProvider.notifier).createFarm(
        farmerId: authState.user.id,
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        size: double.parse(_sizeController.text.trim()),
        cropTypes: _selectedCrops,
        userSubscription: widget.currentPackage,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        soilType: _selectedSoilType,
        irrigationType: _selectedIrrigationType,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Farm created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating farm: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Show create farm dialog
Future<void> showCreateFarmDialog(
  BuildContext context,
  SubscriptionPackage currentPackage,
) {
  return showDialog(
    context: context,
    builder: (context) => CreateFarmDialog(currentPackage: currentPackage),
  );
}

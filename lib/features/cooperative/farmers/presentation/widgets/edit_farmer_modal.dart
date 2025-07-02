import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../auth/presentation/providers/mobile_auth_provider.dart';
import '../../../../auth/presentation/states/auth_state.dart';
import '../../domain/entities/farmer_entity.dart';
import '../../domain/services/farmer_service.dart';
import '../../../presentation/providers/recent_activities_provider.dart';

/// Comprehensive Edit Farmer Modal for updating existing farmers
class EditFarmerModal extends ConsumerStatefulWidget {
  final String cooperativeId;
  final FarmerEntity farmer;
  final VoidCallback? onFarmerUpdated;

  const EditFarmerModal({
    super.key,
    required this.cooperativeId,
    required this.farmer,
    this.onFarmerUpdated,
  });

  @override
  ConsumerState<EditFarmerModal> createState() => _EditFarmerModalState();
}

class _EditFarmerModalState extends ConsumerState<EditFarmerModal> {
  final _formKey = GlobalKey<FormState>();
  final _farmerService = FarmerService();

  // Form controllers
  final _nameController = TextEditingController();
  final _zoneController = TextEditingController();
  final _villageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _totalTreesController = TextEditingController();
  final _fruitingTreesController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankNumberController = TextEditingController();
  final _cropsController = TextEditingController();

  // Form data
  String _gender = 'Male';
  DateTime? _dateOfBirth;
  String _status = 'Pending';
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _populateFormFields();
  }

  /// Populate form fields with existing farmer data
  void _populateFormFields() {
    final farmer = widget.farmer;

    _nameController.text = farmer.name;
    _zoneController.text = farmer.zone;
    _villageController.text = farmer.village;
    _gender = farmer.gender;

    // Handle phone number (remove +255 prefix if present)
    if (farmer.phone != null && farmer.phone!.isNotEmpty) {
      String phone = farmer.phone!;
      if (phone.startsWith('+255')) {
        phone = phone.substring(4);
      }
      _phoneController.text = phone;
    }

    // Handle date of birth
    if (farmer.dateOfBirth != null && farmer.dateOfBirth!.isNotEmpty) {
      try {
        _dateOfBirth = DateTime.parse(farmer.dateOfBirth!);
      } catch (e) {
        // Handle invalid date format
        _dateOfBirth = null;
      }
    }

    _totalTreesController.text = farmer.totalTrees.toString();
    _fruitingTreesController.text = farmer.fruitingTrees.toString();
    _status = farmer.status;

    // Handle banking information
    if (farmer.bankName != null && farmer.bankName!.isNotEmpty) {
      _bankNameController.text = farmer.bankName!;
    }
    if (farmer.bankNumber != null && farmer.bankNumber!.isNotEmpty) {
      _bankNumberController.text = farmer.bankNumber!;
    }

    // Handle crops (join list with commas)
    if (farmer.crops.isNotEmpty) {
      _cropsController.text = farmer.crops.join(', ');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _zoneController.dispose();
    _villageController.dispose();
    _phoneController.dispose();
    _totalTreesController.dispose();
    _fruitingTreesController.dispose();
    _bankNameController.dispose();
    _bankNumberController.dispose();
    _cropsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUtils.radius20),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(theme),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveUtils.spacing20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information Section
                    _buildSectionHeader(
                      'Personal Information',
                      Icons.person,
                      theme,
                    ),
                    SizedBox(height: ResponsiveUtils.spacing16),

                    // Name and Gender Row
                    Row(
                      children: [
                        Expanded(flex: 2, child: _buildNameField(theme)),
                        SizedBox(width: ResponsiveUtils.spacing12),
                        Expanded(child: _buildGenderField(theme)),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.spacing16),

                    // Phone and Date of Birth Row
                    Row(
                      children: [
                        Expanded(child: _buildPhoneField(theme)),
                        SizedBox(width: ResponsiveUtils.spacing12),
                        Expanded(child: _buildDateOfBirthField(theme)),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.spacing24),

                    // Location Information Section
                    _buildSectionHeader(
                      'Location Information',
                      Icons.location_on,
                      theme,
                    ),
                    SizedBox(height: ResponsiveUtils.spacing16),

                    // Zone and Village Row
                    Row(
                      children: [
                        Expanded(child: _buildZoneField(theme)),
                        SizedBox(width: ResponsiveUtils.spacing12),
                        Expanded(child: _buildVillageField(theme)),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.spacing24),

                    // Farm Information Section
                    _buildSectionHeader(
                      'Farm Information',
                      Icons.agriculture,
                      theme,
                    ),
                    SizedBox(height: ResponsiveUtils.spacing16),

                    // Trees Row
                    Row(
                      children: [
                        Expanded(child: _buildTotalTreesField(theme)),
                        SizedBox(width: ResponsiveUtils.spacing12),
                        Expanded(child: _buildFruitingTreesField(theme)),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.spacing16),

                    // Crops Field
                    _buildCropsField(theme),
                    SizedBox(height: ResponsiveUtils.spacing24),

                    // Status Section
                    _buildSectionHeader('Status', Icons.info_outline, theme),
                    SizedBox(height: ResponsiveUtils.spacing16),
                    _buildStatusField(theme),
                    SizedBox(height: ResponsiveUtils.spacing24),

                    // Banking Information Section
                    _buildSectionHeader(
                      'Banking Information (Optional)',
                      Icons.account_balance,
                      theme,
                    ),
                    SizedBox(height: ResponsiveUtils.spacing16),

                    // Bank Information Row
                    Row(
                      children: [
                        Expanded(child: _buildBankNameField(theme)),
                        SizedBox(width: ResponsiveUtils.spacing12),
                        Expanded(child: _buildBankNumberField(theme)),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.spacing24),

                    // Error message
                    if (_error != null) ...[
                      Container(
                        padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.radius8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                              size: ResponsiveUtils.iconSize16,
                            ),
                            SizedBox(width: ResponsiveUtils.spacing8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: GoogleFonts.inter(
                                  fontSize: ResponsiveUtils.fontSize12,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.spacing16),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Footer
          _buildFooter(theme),
        ],
      ),
    );
  }

  /// Build header
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit,
            color: theme.colorScheme.primary,
            size: ResponsiveUtils.iconSize24,
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Farmer',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Update ${widget.farmer.name}\'s information',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
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
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// Build name field
  Widget _buildNameField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name *',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter farmer\'s full name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Name is required';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _error = null;
            });
          },
        ),
      ],
    );
  }

  /// Build gender field
  Widget _buildGenderField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender *',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        DropdownButtonFormField<String>(
          value: _gender,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
          ),
          items:
              ['Male', 'Female'].map((gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(
                    gender,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _gender = value;
                _error = null;
              });
            }
          },
        ),
      ],
    );
  }

  /// Build phone field
  Widget _buildPhoneField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Enter phone number',
            prefixText: '+255 ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length < 9) {
              return 'Phone number must be at least 9 digits';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _error = null;
            });
          },
        ),
      ],
    );
  }

  /// Build date of birth field
  Widget _buildDateOfBirthField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _dateOfBirth ?? DateTime(1980),
              firstDate: DateTime(1940),
              lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
            );
            if (date != null) {
              setState(() {
                _dateOfBirth = date;
                _error = null;
              });
            }
          },
          child: Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing12),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                  size: ResponsiveUtils.iconSize16,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Text(
                  _dateOfBirth != null
                      ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                      : 'Select date',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color:
                        _dateOfBirth != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build zone field
  Widget _buildZoneField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zone *',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        TextFormField(
          controller: _zoneController,
          decoration: InputDecoration(
            hintText: 'Enter zone',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Zone is required';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _error = null;
            });
          },
        ),
      ],
    );
  }

  /// Build village field
  Widget _buildVillageField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Village *',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        TextFormField(
          controller: _villageController,
          decoration: InputDecoration(
            hintText: 'Enter village',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Village is required';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _error = null;
            });
          },
        ),
      ],
    );
  }

  /// Build total trees field
  Widget _buildTotalTreesField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Number of Trees *',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        TextFormField(
          controller: _totalTreesController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter total trees',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Total trees is required';
            }
            final trees = int.tryParse(value);
            if (trees == null || trees < 0) {
              return 'Enter valid number of trees';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _error = null;
            });
          },
        ),
      ],
    );
  }

  /// Build fruiting trees field
  Widget _buildFruitingTreesField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trees with Fruit *',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        TextFormField(
          controller: _fruitingTreesController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter productive trees',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Productive trees is required';
            }
            final fruitingTrees = int.tryParse(value);
            if (fruitingTrees == null || fruitingTrees < 0) {
              return 'Enter valid number of trees';
            }
            final totalTrees = int.tryParse(_totalTreesController.text) ?? 0;
            if (fruitingTrees > totalTrees) {
              return 'Cannot exceed total trees';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _error = null;
            });
          },
        ),
      ],
    );
  }

  /// Build crops field
  Widget _buildCropsField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crops',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        TextFormField(
          controller: _cropsController,
          decoration: InputDecoration(
            hintText:
                'Enter crops separated by commas (e.g., avocado, maize, beans)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
          ),
          maxLines: 2,
          onChanged: (value) {
            setState(() {
              _error = null;
            });
          },
        ),
      ],
    );
  }

  /// Build status field
  Widget _buildStatusField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status *',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        DropdownButtonFormField<String>(
          value: _status,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
          ),
          items:
              ['Active', 'Pending', 'Suspended'].map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status, theme),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.spacing8),
                      Text(
                        status,
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize14,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _status = value;
                _error = null;
              });
            }
          },
        ),
      ],
    );
  }

  /// Get status color
  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  /// Build bank name field
  Widget _buildBankNameField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank Name',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        TextFormField(
          controller: _bankNameController,
          decoration: InputDecoration(
            hintText: 'Enter bank name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
          ),
          onChanged: (value) {
            setState(() {
              _error = null;
            });
          },
        ),
      ],
    );
  }

  /// Build bank number field
  Widget _buildBankNumberField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank Account Number',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        TextFormField(
          controller: _bankNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter account number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
          ),
          onChanged: (value) {
            setState(() {
              _error = null;
            });
          },
        ),
      ],
    );
  }

  /// Build footer
  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed:
                  _isSubmitting ? null : () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _updateFarmer,
              icon:
                  _isSubmitting
                      ? SizedBox(
                        width: ResponsiveUtils.iconSize16,
                        height: ResponsiveUtils.iconSize16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                      : Icon(Icons.save, size: ResponsiveUtils.iconSize16),
              label: Text(
                _isSubmitting ? 'Updating...' : 'Update Farmer',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Update farmer in database
  Future<void> _updateFarmer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get authenticated user
    final authState = ref.read(mobileAuthProvider);
    if (authState is! AuthAuthenticated) {
      setState(() {
        _error = 'Please log in to update farmers';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      // Parse crops
      final crops =
          _cropsController.text
              .split(',')
              .map((crop) => crop.trim())
              .where((crop) => crop.isNotEmpty)
              .toList();

      // Create form data
      final formData = FarmerFormData(
        name: _nameController.text.trim(),
        zone: _zoneController.text.trim(),
        village: _villageController.text.trim(),
        gender: _gender,
        dateOfBirth: _dateOfBirth?.toIso8601String().split('T')[0],
        phone:
            _phoneController.text.trim().isNotEmpty
                ? '+255${_phoneController.text.trim()}'
                : null,
        totalTrees: int.parse(_totalTreesController.text),
        fruitingTrees: int.parse(_fruitingTreesController.text),
        status: _status,
        bankNumber:
            _bankNumberController.text.trim().isNotEmpty
                ? _bankNumberController.text.trim()
                : null,
        bankName:
            _bankNameController.text.trim().isNotEmpty
                ? _bankNameController.text.trim()
                : null,
        crops: crops,
      );

      // Validate form data
      final validationErrors = formData.validate();
      if (validationErrors.isNotEmpty) {
        setState(() {
          _error = validationErrors.first;
          _isSubmitting = false;
        });
        return;
      }

      // Convert to entity with updated data
      final updatedFarmer = formData
          .toEntity(
            cooperativeId: widget.cooperativeId,
            createdBy: widget.farmer.createdBy ?? authState.user.id,
            id: widget.farmer.id,
          )
          .copyWith(
            createdAt: widget.farmer.createdAt,
            updatedBy: authState.user.id,
            updatedAt: DateTime.now(),
          );

      // Update in Firebase
      await _farmerService.updateFarmer(widget.farmer.id, updatedFarmer);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Farmer "${formData.name}" updated successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                // TODO: Navigate to farmer details
              },
            ),
          ),
        );

        // Refresh activities provider to show farmer update
        ref.invalidate(recentActivitiesProvider);

        // Close modal and refresh
        Navigator.of(context).pop();
        if (widget.onFarmerUpdated != null) {
          widget.onFarmerUpdated!();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to update farmer: $e';
          _isSubmitting = false;
        });
      }
    }
  }
}

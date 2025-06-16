import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/farm.dart';
import '../../domain/entities/activity.dart';
import '../providers/activity_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';

/// Screen for creating new farm activities
class CreateActivityScreen extends ConsumerStatefulWidget {
  final FarmEntity farm;

  const CreateActivityScreen({super.key, required this.farm});

  @override
  ConsumerState<CreateActivityScreen> createState() =>
      _CreateActivityScreenState();
}

class _CreateActivityScreenState extends ConsumerState<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cropTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  ActivityType _selectedType = ActivityType.planting;
  ActivityPriority _selectedPriority = ActivityPriority.medium;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cropTypeController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _costController.dispose();
    _notesController.dispose();
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
      title: Text(
        'Add Activity',
        style: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.fontSize20,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
    );
  }

  /// Build body
  Widget _buildBody(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farm info header
            _buildFarmInfoHeader(theme),
            SizedBox(height: ResponsiveUtils.height24),

            // Activity type selection
            _buildActivityTypeSection(theme),
            SizedBox(height: ResponsiveUtils.height24),

            // Basic information
            _buildBasicInfoSection(theme),
            SizedBox(height: ResponsiveUtils.height24),

            // Scheduling
            _buildSchedulingSection(theme),
            SizedBox(height: ResponsiveUtils.height24),

            // Optional details
            _buildOptionalDetailsSection(theme),
            SizedBox(height: ResponsiveUtils.height24),

            // Notes
            _buildNotesSection(theme),
            SizedBox(height: ResponsiveUtils.height100), // Space for bottom bar
          ],
        ),
      ),
    );
  }

  /// Build farm info header
  Widget _buildFarmInfoHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.agriculture,
            color: theme.colorScheme.primary,
            size: ResponsiveUtils.iconSize24,
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.farm.name,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${widget.farm.location} • ${widget.farm.formattedSize}',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build activity type section
  Widget _buildActivityTypeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Type',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height12),
        Wrap(
          spacing: ResponsiveUtils.spacing8,
          runSpacing: ResponsiveUtils.spacing8,
          children:
              ActivityType.values.map((type) {
                final isSelected = _selectedType == type;
                return FilterChip(
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                      // Auto-fill title based on type
                      if (_titleController.text.isEmpty) {
                        _titleController.text = type.displayName;
                      }
                    });
                  },
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.primary.withValues(
                    alpha: 0.2,
                  ),
                  checkmarkColor: theme.colorScheme.primary,
                  labelStyle: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// Build basic info section
  Widget _buildBasicInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height16),

        // Title field
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Activity Title *',
            hintText: 'e.g., Plant maize seeds',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            prefixIcon: const Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter activity title';
            }
            return null;
          },
        ),
        SizedBox(height: ResponsiveUtils.height16),

        // Description field
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Description *',
            hintText: 'Describe what needs to be done...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            prefixIcon: const Icon(Icons.description),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter activity description';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Build scheduling section
  Widget _buildSchedulingSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scheduling',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height16),

        // Date picker
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                SizedBox(width: ResponsiveUtils.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scheduled Date',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize12,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(_selectedDate),
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: ResponsiveUtils.height16),

        // Priority selection
        Text(
          'Priority',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height8),
        Row(
          children:
              ActivityPriority.values.map((priority) {
                final isSelected = _selectedPriority == priority;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right:
                          priority != ActivityPriority.values.last
                              ? ResponsiveUtils.spacing8
                              : 0,
                    ),
                    child: FilterChip(
                      label: Text(priority.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedPriority = priority;
                        });
                      },
                      backgroundColor: theme.colorScheme.surface,
                      selectedColor: _getPriorityColor(
                        priority,
                      ).withValues(alpha: 0.2),
                      checkmarkColor: _getPriorityColor(priority),
                      labelStyle: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize12,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected
                                ? _getPriorityColor(priority)
                                : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// Build optional details section
  Widget _buildOptionalDetailsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optional Details',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height16),

        // Crop type
        TextFormField(
          controller: _cropTypeController,
          decoration: InputDecoration(
            labelText: 'Crop Type',
            hintText: 'e.g., Maize, Tomatoes',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            prefixIcon: const Icon(Icons.eco),
          ),
        ),
        SizedBox(height: ResponsiveUtils.height16),

        // Quantity and unit
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.numbers),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: TextFormField(
                controller: _unitController,
                decoration: InputDecoration(
                  labelText: 'Unit',
                  hintText: 'kg, bags',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.height16),

        // Cost
        TextFormField(
          controller: _costController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Estimated Cost (TSh)',
            hintText: '0',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            prefixIcon: const Icon(Icons.attach_money),
          ),
        ),
      ],
    );
  }

  /// Build notes section
  Widget _buildNotesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height16),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Notes',
            hintText: 'Any additional information or reminders...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            prefixIcon: const Icon(Icons.note),
          ),
        ),
      ],
    );
  }

  /// Build bottom bar
  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    _isLoading ? null : () => Navigator.of(context).pop(),
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
                onPressed: _isLoading ? null : _createActivity,
                child:
                    _isLoading
                        ? SizedBox(
                          height: ResponsiveUtils.iconSize20,
                          width: ResponsiveUtils.iconSize20,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'Create Activity',
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

  /// Select date
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get priority color
  Color _getPriorityColor(ActivityPriority priority) {
    switch (priority) {
      case ActivityPriority.low:
        return Colors.green;
      case ActivityPriority.medium:
        return Colors.orange;
      case ActivityPriority.high:
        return Colors.red;
      case ActivityPriority.urgent:
        return Colors.red.shade900;
    }
  }

  /// Create activity
  Future<void> _createActivity() async {
    if (!_formKey.currentState!.validate()) {
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

      await ref
          .read(activityProvider.notifier)
          .createActivity(
            farmerId: authState.user.id,
            farmId: widget.farm.id,
            type: _selectedType,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            priority: _selectedPriority,
            scheduledDate: _selectedDate,
            cropType:
                _cropTypeController.text.trim().isEmpty
                    ? null
                    : _cropTypeController.text.trim(),
            quantity:
                _quantityController.text.trim().isEmpty
                    ? null
                    : double.tryParse(_quantityController.text.trim()),
            unit:
                _unitController.text.trim().isEmpty
                    ? null
                    : _unitController.text.trim(),
            cost:
                _costController.text.trim().isEmpty
                    ? null
                    : double.tryParse(_costController.text.trim()),
            currency: 'TSh',
            notes:
                _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create activity: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

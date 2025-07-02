import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../models/report_models.dart';
import '../../domain/services/report_scheduling_service.dart';
import '../providers/report_builder_provider.dart';

/// Widget for scheduling reports
class ReportSchedulingWidget extends ConsumerStatefulWidget {
  final String cooperativeId;
  final String userId;
  final VoidCallback? onScheduleCreated;

  const ReportSchedulingWidget({
    super.key,
    required this.cooperativeId,
    required this.userId,
    this.onScheduleCreated,
  });

  @override
  ConsumerState<ReportSchedulingWidget> createState() => _ReportSchedulingWidgetState();
}

class _ReportSchedulingWidgetState extends ConsumerState<ReportSchedulingWidget> {
  final ReportSchedulingService _schedulingService = ReportSchedulingService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  ReportTemplate? _selectedTemplate;
  ScheduleFrequency _selectedFrequency = ScheduleFrequency.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  List<String> _emailRecipients = [];
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportTemplates = ref.watch(reportTemplatesProvider);

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
                    // Basic Information
                    _buildBasicInfoSection(theme),
                    SizedBox(height: ResponsiveUtils.spacing24),
                    
                    // Template Selection
                    _buildTemplateSection(theme, reportTemplates),
                    SizedBox(height: ResponsiveUtils.spacing24),
                    
                    // Schedule Configuration
                    _buildScheduleSection(theme),
                    SizedBox(height: ResponsiveUtils.spacing24),
                    
                    // Email Recipients
                    _buildEmailSection(theme),
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
            Icons.schedule,
            color: theme.colorScheme.primary,
            size: ResponsiveUtils.iconSize24,
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule Report',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Set up automated report generation',
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
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing16),
        
        // Name field
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Schedule Name',
            hintText: 'Enter a name for this scheduled report',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a schedule name';
            }
            return null;
          },
        ),
        SizedBox(height: ResponsiveUtils.spacing16),
        
        // Description field
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Description (Optional)',
            hintText: 'Describe what this scheduled report is for',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
          ),
        ),
      ],
    );
  }

  /// Build template section
  Widget _buildTemplateSection(ThemeData theme, List<ReportTemplate> templates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Template',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing16),
        
        DropdownButtonFormField<ReportTemplate>(
          value: _selectedTemplate,
          decoration: InputDecoration(
            labelText: 'Select Template',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
          ),
          items: templates.map((template) {
            return DropdownMenuItem(
              value: template,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveUtils.spacing4),
                    decoration: BoxDecoration(
                      color: template.category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(ResponsiveUtils.radius4),
                    ),
                    child: Icon(
                      template.icon,
                      size: ResponsiveUtils.iconSize16,
                      color: template.category.color,
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          template.name,
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          template.category.displayName,
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
          }).toList(),
          onChanged: (template) {
            setState(() {
              _selectedTemplate = template;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a report template';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Build schedule section
  Widget _buildScheduleSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule Configuration',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing16),
        
        // Frequency selection
        DropdownButtonFormField<ScheduleFrequency>(
          value: _selectedFrequency,
          decoration: InputDecoration(
            labelText: 'Frequency',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
          ),
          items: ScheduleFrequency.values.map((frequency) {
            return DropdownMenuItem(
              value: frequency,
              child: Text(_schedulingService.getFrequencyDisplayName(frequency)),
            );
          }).toList(),
          onChanged: (frequency) {
            if (frequency != null) {
              setState(() {
                _selectedFrequency = frequency;
              });
            }
          },
        ),
        SizedBox(height: ResponsiveUtils.spacing16),
        
        // Start date
        ListTile(
          leading: Icon(
            Icons.event,
            color: theme.colorScheme.primary,
          ),
          title: Text(
            'Start Date',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '${_startDate.day}/${_startDate.month}/${_startDate.year}',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _startDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (date != null) {
              setState(() {
                _startDate = date;
              });
            }
          },
          contentPadding: EdgeInsets.zero,
        ),
        
        // End date (optional)
        ListTile(
          leading: Icon(
            Icons.event_busy,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          title: Text(
            'End Date (Optional)',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            _endDate != null 
                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                : 'No end date',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          trailing: _endDate != null
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _endDate = null;
                    });
                  },
                  icon: Icon(
                    Icons.clear,
                    size: ResponsiveUtils.iconSize16,
                  ),
                )
              : null,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
              firstDate: _startDate,
              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
            );
            if (date != null) {
              setState(() {
                _endDate = date;
              });
            }
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  /// Build email section
  Widget _buildEmailSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Recipients (Optional)',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        Text(
          'Reports will be automatically emailed to these recipients',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing16),
        
        // Email input
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter email address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
                  ),
                ),
                onFieldSubmitted: _addEmailRecipient,
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing8),
            IconButton(
              onPressed: () {
                // Add email logic here
              },
              icon: Icon(
                Icons.add,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        
        // Email list
        if (_emailRecipients.isNotEmpty) ...[
          SizedBox(height: ResponsiveUtils.spacing12),
          Wrap(
            spacing: ResponsiveUtils.spacing8,
            runSpacing: ResponsiveUtils.spacing8,
            children: _emailRecipients.map((email) {
              return Chip(
                label: Text(
                  email,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                  ),
                ),
                deleteIcon: Icon(
                  Icons.close,
                  size: ResponsiveUtils.iconSize16,
                ),
                onDeleted: () {
                  setState(() {
                    _emailRecipients.remove(email);
                  });
                },
              );
            }).toList(),
          ),
        ],
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
              onPressed: () => Navigator.of(context).pop(),
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
              onPressed: _isCreating ? null : _createSchedule,
              icon: _isCreating
                  ? SizedBox(
                      width: ResponsiveUtils.iconSize16,
                      height: ResponsiveUtils.iconSize16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Icon(Icons.schedule, size: ResponsiveUtils.iconSize16),
              label: Text(
                _isCreating ? 'Creating...' : 'Create Schedule',
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

  /// Add email recipient
  void _addEmailRecipient(String email) {
    if (email.isNotEmpty && email.contains('@') && !_emailRecipients.contains(email)) {
      setState(() {
        _emailRecipients.add(email);
      });
    }
  }

  /// Create schedule
  Future<void> _createSchedule() async {
    if (!_formKey.currentState!.validate() || _selectedTemplate == null) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      await _schedulingService.createScheduledReport(
        cooperativeId: widget.cooperativeId,
        userId: widget.userId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        template: _selectedTemplate!,
        frequency: _selectedFrequency,
        startDate: _startDate,
        endDate: _endDate,
        emailRecipients: _emailRecipients,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scheduled report created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        if (widget.onScheduleCreated != null) {
          widget.onScheduleCreated!();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create schedule: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}

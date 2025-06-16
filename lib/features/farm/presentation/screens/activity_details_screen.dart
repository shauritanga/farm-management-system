import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/activity.dart';
import '../providers/activity_provider.dart';

/// Screen for viewing and managing activity details
class ActivityDetailsScreen extends ConsumerStatefulWidget {
  final ActivityEntity activity;

  const ActivityDetailsScreen({super.key, required this.activity});

  @override
  ConsumerState<ActivityDetailsScreen> createState() =>
      _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends ConsumerState<ActivityDetailsScreen> {
  bool _isLoading = false;

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
        'Activity Details',
        style: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.fontSize20,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      actions: [
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit Activity'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (!widget.activity.isCompleted)
                  const PopupMenuItem(
                    value: 'complete',
                    child: ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('Mark as Complete'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      'Delete Activity',
                      style: TextStyle(color: Colors.red),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
        ),
      ],
    );
  }

  /// Build body
  Widget _buildBody(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          _buildHeader(theme),
          SizedBox(height: ResponsiveUtils.height24),

          // Basic information
          _buildBasicInfo(theme),
          SizedBox(height: ResponsiveUtils.height24),

          // Scheduling information
          _buildSchedulingInfo(theme),
          SizedBox(height: ResponsiveUtils.height24),

          // Optional details
          if (_hasOptionalDetails()) ...[
            _buildOptionalDetails(theme),
            SizedBox(height: ResponsiveUtils.height24),
          ],

          // Notes
          if (widget.activity.notes != null) ...[
            _buildNotes(theme),
            SizedBox(height: ResponsiveUtils.height24),
          ],

          // Completion info
          if (widget.activity.isCompleted) ...[
            _buildCompletionInfo(theme),
            SizedBox(height: ResponsiveUtils.height24),
          ],

          // Metadata
          _buildMetadata(theme),
          SizedBox(height: ResponsiveUtils.height100), // Space for bottom bar
        ],
      ),
    );
  }

  /// Build header
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.activity.title,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize20,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              _buildStatusChip(theme, widget.activity.status),
            ],
          ),
          SizedBox(height: ResponsiveUtils.height8),
          Row(
            children: [
              _buildTypeChip(theme, widget.activity.type),
              SizedBox(width: ResponsiveUtils.spacing8),
              _buildPriorityChip(theme, widget.activity.priority),
            ],
          ),
          SizedBox(height: ResponsiveUtils.height12),
          Text(
            widget.activity.description,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Build basic info
  Widget _buildBasicInfo(ThemeData theme) {
    return _buildSection(theme, 'Basic Information', [
      _buildInfoRow(
        theme,
        'Activity Type',
        widget.activity.type.displayName,
        Icons.category,
      ),
      _buildInfoRow(
        theme,
        'Priority',
        widget.activity.priority.displayName,
        Icons.flag,
      ),
      _buildInfoRow(
        theme,
        'Status',
        widget.activity.status.displayName,
        Icons.info,
      ),
    ]);
  }

  /// Build scheduling info
  Widget _buildSchedulingInfo(ThemeData theme) {
    return _buildSection(theme, 'Scheduling', [
      _buildInfoRow(
        theme,
        'Scheduled Date',
        widget.activity.formattedScheduledDate,
        Icons.schedule,
      ),
      if (widget.activity.completedDate != null)
        _buildInfoRow(
          theme,
          'Completed Date',
          widget.activity.formattedCompletedDate!,
          Icons.check_circle,
        ),
      _buildInfoRow(
        theme,
        'Created',
        widget.activity.formattedCreatedDate,
        Icons.add_circle,
      ),
    ]);
  }

  /// Build optional details
  Widget _buildOptionalDetails(ThemeData theme) {
    final details = <Widget>[];

    if (widget.activity.cropType != null) {
      details.add(
        _buildInfoRow(theme, 'Crop Type', widget.activity.cropType!, Icons.eco),
      );
    }

    if (widget.activity.quantity != null) {
      final quantityText =
          widget.activity.unit != null
              ? '${widget.activity.quantity} ${widget.activity.unit}'
              : widget.activity.quantity.toString();
      details.add(
        _buildInfoRow(theme, 'Quantity', quantityText, Icons.numbers),
      );
    }

    if (widget.activity.cost != null) {
      final costText =
          '${widget.activity.cost} ${widget.activity.currency ?? 'TSh'}';
      details.add(
        _buildInfoRow(theme, 'Estimated Cost', costText, Icons.attach_money),
      );
    }

    return _buildSection(theme, 'Details', details);
  }

  /// Build notes
  Widget _buildNotes(ThemeData theme) {
    return _buildSection(theme, 'Notes', [
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          widget.activity.notes!,
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
      ),
    ]);
  }

  /// Build completion info
  Widget _buildCompletionInfo(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: ResponsiveUtils.iconSize24,
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity Completed',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Completed on ${widget.activity.formattedCompletedDate}',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: Colors.green.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build metadata
  Widget _buildMetadata(ThemeData theme) {
    return _buildSection(theme, 'Metadata', [
      _buildInfoRow(
        theme,
        'Activity ID',
        widget.activity.id,
        Icons.fingerprint,
      ),
      _buildInfoRow(
        theme,
        'Farm ID',
        widget.activity.farmId,
        Icons.agriculture,
      ),
      if (widget.activity.updatedAt != null)
        _buildInfoRow(
          theme,
          'Last Updated',
          widget.activity.formattedUpdatedDate!,
          Icons.update,
        ),
    ]);
  }

  /// Build section
  Widget _buildSection(ThemeData theme, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height16),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.height12),
      child: Row(
        children: [
          Icon(
            icon,
            size: ResponsiveUtils.iconSize20,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build status chip
  Widget _buildStatusChip(ThemeData theme, ActivityStatus status) {
    Color color;
    switch (status) {
      case ActivityStatus.planned:
        color = Colors.orange;
        break;
      case ActivityStatus.inProgress:
        color = Colors.blue;
        break;
      case ActivityStatus.completed:
        color = Colors.green;
        break;
      case ActivityStatus.cancelled:
        color = Colors.red;
        break;
      case ActivityStatus.overdue:
        color = Colors.red.shade700;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing8,
        vertical: ResponsiveUtils.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
      ),
      child: Text(
        status.displayName,
        style: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Build type chip
  Widget _buildTypeChip(ThemeData theme, ActivityType type) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing8,
        vertical: ResponsiveUtils.spacing4,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
      ),
      child: Text(
        type.displayName,
        style: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize12,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.secondary,
        ),
      ),
    );
  }

  /// Build priority chip
  Widget _buildPriorityChip(ThemeData theme, ActivityPriority priority) {
    Color color;
    switch (priority) {
      case ActivityPriority.low:
        color = Colors.green;
        break;
      case ActivityPriority.medium:
        color = Colors.orange;
        break;
      case ActivityPriority.high:
        color = Colors.red;
        break;
      case ActivityPriority.urgent:
        color = Colors.red.shade900;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing8,
        vertical: ResponsiveUtils.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
      ),
      child: Text(
        priority.displayName,
        style: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  /// Build bottom bar
  Widget _buildBottomBar(ThemeData theme) {
    if (widget.activity.isCompleted) {
      return const SizedBox.shrink();
    }

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
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : () => _handleMenuAction('edit'),
                icon: const Icon(Icons.edit),
                label: Text(
                  'Edit',
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
              child: ElevatedButton.icon(
                onPressed:
                    _isLoading ? null : () => _handleMenuAction('complete'),
                icon:
                    _isLoading
                        ? SizedBox(
                          height: ResponsiveUtils.iconSize16,
                          width: ResponsiveUtils.iconSize16,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.check_circle),
                label: Text(
                  'Mark Complete',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Check if has optional details
  bool _hasOptionalDetails() {
    return widget.activity.cropType != null ||
        widget.activity.quantity != null ||
        widget.activity.cost != null;
  }

  /// Handle menu actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editActivity();
        break;
      case 'complete':
        _completeActivity();
        break;
      case 'delete':
        _deleteActivity();
        break;
    }
  }

  /// Edit activity
  void _editActivity() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Edit activity coming soon')));
  }

  /// Complete activity
  Future<void> _completeActivity() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(activityProvider.notifier)
          .completeActivity(widget.activity.id);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity marked as complete!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete activity: ${e.toString()}'),
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

  /// Delete activity
  void _deleteActivity() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Activity'),
            content: Text(
              'Are you sure you want to delete "${widget.activity.title}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Delete activity coming soon'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

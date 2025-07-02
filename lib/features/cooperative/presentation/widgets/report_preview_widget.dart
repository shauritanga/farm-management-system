import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../models/report_models.dart' as models;
import '../../domain/services/report_generation_service.dart';
import '../../../auth/presentation/providers/mobile_auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';

/// Widget for previewing report data before generation
class ReportPreviewWidget extends ConsumerStatefulWidget {
  final String cooperativeId;
  final models.CustomReportConfig config;
  final VoidCallback? onClose;

  const ReportPreviewWidget({
    super.key,
    required this.cooperativeId,
    required this.config,
    this.onClose,
  });

  @override
  ConsumerState<ReportPreviewWidget> createState() =>
      _ReportPreviewWidgetState();
}

class _ReportPreviewWidgetState extends ConsumerState<ReportPreviewWidget> {
  final ReportGenerationService _reportService = ReportGenerationService();
  models.ReportPreviewData? _previewData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final previewData = await _reportService.generatePreview(
        cooperativeId: widget.cooperativeId,
        config: widget.config,
        previewLimit: 10,
      );

      setState(() {
        _previewData = previewData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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

          // Content
          Expanded(
            child:
                _isLoading
                    ? _buildLoadingState(theme)
                    : _error != null
                    ? _buildErrorState(theme)
                    : _buildPreviewContent(theme),
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
            Icons.preview,
            color: theme.colorScheme.primary,
            size: ResponsiveUtils.iconSize24,
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Preview',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  widget.config.name,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          SizedBox(height: ResponsiveUtils.spacing16),
          Text(
            'Generating preview...',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: ResponsiveUtils.iconSize48,
            ),
            SizedBox(height: ResponsiveUtils.spacing16),
            Text(
              'Failed to generate preview',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.error,
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing8),
            Text(
              _error ?? 'Unknown error occurred',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.spacing20),
            ElevatedButton.icon(
              onPressed: _loadPreview,
              icon: Icon(Icons.refresh, size: ResponsiveUtils.iconSize16),
              label: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build preview content
  Widget _buildPreviewContent(ThemeData theme) {
    if (_previewData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          _buildSummary(theme),
          SizedBox(height: ResponsiveUtils.spacing20),

          // Data table
          _buildDataTable(theme),
        ],
      ),
    );
  }

  /// Build summary
  Widget _buildSummary(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview Summary',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing12),

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  theme,
                  'Total Records',
                  _previewData!.totalCount.toString(),
                  Icons.dataset,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  theme,
                  'Filtered Records',
                  _previewData!.filteredCount.toString(),
                  Icons.filter_list,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  theme,
                  'Preview Showing',
                  _previewData!.previewData.length.toString(),
                  Icons.visibility,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build summary item
  Widget _buildSummaryItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: ResponsiveUtils.iconSize20,
        ),
        SizedBox(height: ResponsiveUtils.spacing4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build data table
  Widget _buildDataTable(ThemeData theme) {
    if (_previewData!.previewData.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.spacing24),
          child: Column(
            children: [
              Icon(
                Icons.inbox,
                size: ResponsiveUtils.iconSize48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              SizedBox(height: ResponsiveUtils.spacing12),
              Text(
                'No data available',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Preview (First ${_previewData!.previewData.length} records)',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns:
                widget.config.columns.map((column) {
                  return DataColumn(
                    label: Text(
                      column,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
            rows:
                _previewData!.previewData.map((row) {
                  return DataRow(
                    cells:
                        widget.config.columns.map((column) {
                          final value = row[column];
                          return DataCell(
                            Text(
                              _formatCellValue(value),
                              style: GoogleFonts.inter(
                                fontSize: ResponsiveUtils.fontSize12,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                  );
                }).toList(),
          ),
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
              onPressed: widget.onClose,
              child: Text(
                'Close',
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
              onPressed: _previewData != null ? _generateFullReport : null,
              icon: Icon(Icons.download, size: ResponsiveUtils.iconSize16),
              label: Text(
                'Generate Full Report',
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

  /// Generate full report
  void _generateFullReport() {
    // Close preview and trigger full report generation
    if (widget.onClose != null) {
      widget.onClose!();
    }

    // Trigger report generation through the report service
    _generateReportFromPreview();
  }

  /// Generate report from preview
  void _generateReportFromPreview() async {
    // Get authenticated user
    final authState = ref.read(mobileAuthProvider);
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to generate reports')),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating full report...')),
      );

      final report = await _reportService.generateReport(
        cooperativeId: widget.cooperativeId,
        config: widget.config,
        userId: authState.user.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report "${report.name}" generated successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Download',
              onPressed: () async {
                try {
                  await _reportService.downloadReport(report);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report downloaded!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Download failed: $e')),
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Format cell value for display
  String _formatCellValue(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) return value.toString().substring(0, 19);
    if (value is double) return value.toStringAsFixed(2);
    return value.toString();
  }
}

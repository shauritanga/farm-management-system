import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../models/report_models.dart';
import '../providers/custom_report_provider.dart';
import '../providers/report_builder_provider.dart';
import 'report_preview_widget.dart';
import '../../domain/services/report_generation_service.dart';
import '../../../auth/presentation/providers/mobile_auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';

/// Custom Report Builder Modal
class CustomReportBuilder extends ConsumerStatefulWidget {
  final String cooperativeId;
  final VoidCallback? onReportGenerated;

  const CustomReportBuilder({
    super.key,
    required this.cooperativeId,
    this.onReportGenerated,
  });

  @override
  ConsumerState<CustomReportBuilder> createState() =>
      _CustomReportBuilderState();
}

class _CustomReportBuilderState extends ConsumerState<CustomReportBuilder>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize controllers with current state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ref.read(customReportProvider);
      _nameController.text = config.name;
      _descriptionController.text = config.description;
      _minAmountController.text = config.filters.minAmount?.toString() ?? '';
      _maxAmountController.text = config.filters.maxAmount?.toString() ?? '';
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = ref.watch(customReportProvider);
    final isGenerating = ref.watch(reportGenerationStateProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(theme),

          // Tab Bar
          _buildTabBar(theme),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicInfoTab(theme),
                _buildDataSourceTab(theme),
                _buildFiltersTab(theme),
                _buildColumnsTab(theme),
              ],
            ),
          ),

          // Footer Actions
          _buildFooterActions(theme, config, isGenerating),
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
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Icon(
              Icons.build,
              color: theme.colorScheme.primary,
              size: ResponsiveUtils.iconSize24,
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custom Report Builder',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize20,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Create customized reports with your data',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(customReportProvider.notifier).reset();
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Build tab bar
  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.6,
        ),
        indicatorColor: theme.colorScheme.primary,
        labelStyle: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize12,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(icon: Icon(Icons.info_outline, size: 20), text: 'Basic Info'),
          Tab(icon: Icon(Icons.storage, size: 20), text: 'Data Source'),
          Tab(icon: Icon(Icons.filter_alt, size: 20), text: 'Filters'),
          Tab(icon: Icon(Icons.view_column, size: 20), text: 'Columns'),
        ],
      ),
    );
  }

  /// Build basic info tab
  Widget _buildBasicInfoTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Information',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing16),

          // Report Name
          Text(
            'Report Name *',
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
              hintText: 'Enter report name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
              ),
              contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
            ),
            onChanged: (value) {
              ref.read(customReportProvider.notifier).updateName(value);
            },
          ),
          SizedBox(height: ResponsiveUtils.spacing16),

          // Report Description
          Text(
            'Description',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing8),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter report description (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
              ),
              contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
            ),
            onChanged: (value) {
              ref.read(customReportProvider.notifier).updateDescription(value);
            },
          ),
          SizedBox(height: ResponsiveUtils.spacing16),

          // Export Format
          Text(
            'Export Format',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing8),
          _buildFormatSelector(theme),
        ],
      ),
    );
  }

  /// Build format selector
  Widget _buildFormatSelector(ThemeData theme) {
    final config = ref.watch(customReportProvider);

    return Row(
      children:
          ReportFormat.values.map((format) {
            final isSelected = config.format == format;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: ResponsiveUtils.spacing8),
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(customReportProvider.notifier)
                        .updateFormat(format);
                  },
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : theme.colorScheme.surface,
                      border: Border.all(
                        color:
                            isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius8,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          format.icon,
                          color:
                              isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                          size: ResponsiveUtils.iconSize24,
                        ),
                        SizedBox(height: ResponsiveUtils.spacing4),
                        Text(
                          format.displayName,
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  /// Build data source tab
  Widget _buildDataSourceTab(ThemeData theme) {
    final config = ref.watch(customReportProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Data Source',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing8),
          Text(
            'Choose the primary data source for your report',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing20),

          // Data source options
          ...DataSource.values.map((dataSource) {
            final isSelected = config.dataSource == dataSource;
            return Padding(
              padding: EdgeInsets.only(bottom: ResponsiveUtils.spacing12),
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(customReportProvider.notifier)
                      .updateDataSource(dataSource);
                },
                child: Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing16),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surface,
                    border: Border.all(
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(
                                alpha: 0.3,
                              ),
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? theme.colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  )
                                  : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.radius8,
                          ),
                        ),
                        child: Text(
                          dataSource.emoji,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize24,
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.spacing16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dataSource.displayName,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveUtils.fontSize16,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              dataSource.description,
                              style: GoogleFonts.inter(
                                fontSize: ResponsiveUtils.fontSize14,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                          size: ResponsiveUtils.iconSize24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build filters tab
  Widget _buildFiltersTab(ThemeData theme) {
    final config = ref.watch(customReportProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Filters',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing8),
          Text(
            'Apply filters to narrow down your data',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing20),

          // Date Range Filter
          _buildDateRangeFilter(theme),
          SizedBox(height: ResponsiveUtils.spacing20),

          // Amount Range Filter
          _buildAmountRangeFilter(theme),
          SizedBox(height: ResponsiveUtils.spacing20),

          // Zone Filter
          _buildZoneFilter(theme),
          SizedBox(height: ResponsiveUtils.spacing20),

          // Fruit Type Filter
          _buildFruitTypeFilter(theme),
        ],
      ),
    );
  }

  /// Build date range filter
  Widget _buildDateRangeFilter(ThemeData theme) {
    final config = ref.watch(customReportProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectStartDate(context),
                child: Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: ResponsiveUtils.iconSize16,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.spacing8),
                      Text(
                        config.dateRange?.start != null
                            ? '${config.dateRange!.start.day}/${config.dateRange!.start.month}/${config.dateRange!.start.year}'
                            : 'Start Date',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize14,
                          color:
                              config.dateRange?.start != null
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectEndDate(context),
                child: Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: ResponsiveUtils.iconSize16,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.spacing8),
                      Text(
                        config.dateRange?.end != null
                            ? '${config.dateRange!.end.day}/${config.dateRange!.end.month}/${config.dateRange!.end.year}'
                            : 'End Date',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize14,
                          color:
                              config.dateRange?.end != null
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (config.dateRange != null)
          Padding(
            padding: EdgeInsets.only(top: ResponsiveUtils.spacing8),
            child: Row(
              children: [
                Text(
                  'Clear date range',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing4),
                GestureDetector(
                  onTap: () {
                    ref
                        .read(customReportProvider.notifier)
                        .updateDateRange(null);
                  },
                  child: Icon(
                    Icons.clear,
                    size: ResponsiveUtils.iconSize16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Select start date
  Future<void> _selectStartDate(BuildContext context) async {
    final config = ref.read(customReportProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: config.dateRange?.start ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final endDate =
          config.dateRange?.end ?? picked.add(const Duration(days: 30));
      ref
          .read(customReportProvider.notifier)
          .updateDateRange(DateRange(start: picked, end: endDate));
    }
  }

  /// Select end date
  Future<void> _selectEndDate(BuildContext context) async {
    final config = ref.read(customReportProvider);
    final startDate =
        config.dateRange?.start ??
        DateTime.now().subtract(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: config.dateRange?.end ?? DateTime.now(),
      firstDate: startDate,
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      ref
          .read(customReportProvider.notifier)
          .updateDateRange(DateRange(start: startDate, end: picked));
    }
  }

  /// Build amount range filter
  Widget _buildAmountRangeFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount Range (TSh)',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _minAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Min Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
                ),
                onChanged: (value) {
                  final minAmount = double.tryParse(value);
                  final config = ref.read(customReportProvider);
                  ref
                      .read(customReportProvider.notifier)
                      .updateAmountRange(minAmount, config.filters.maxAmount);
                },
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: TextFormField(
                controller: _maxAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Max Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
                ),
                onChanged: (value) {
                  final maxAmount = double.tryParse(value);
                  final config = ref.read(customReportProvider);
                  ref
                      .read(customReportProvider.notifier)
                      .updateAmountRange(config.filters.minAmount, maxAmount);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build zone filter
  Widget _buildZoneFilter(ThemeData theme) {
    final zonesAsync = ref.watch(availableZonesProvider(widget.cooperativeId));
    final config = ref.watch(customReportProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zones',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        zonesAsync.when(
          data: (zones) {
            if (zones.isEmpty) {
              return Text(
                'No zones available',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              );
            }

            return Wrap(
              spacing: ResponsiveUtils.spacing8,
              runSpacing: ResponsiveUtils.spacing8,
              children:
                  zones.map((zone) {
                    final isSelected = config.filters.zones.contains(zone);
                    return GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          ref
                              .read(customReportProvider.notifier)
                              .removeZoneFilter(zone);
                        } else {
                          ref
                              .read(customReportProvider.notifier)
                              .addZoneFilter(zone);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.spacing12,
                          vertical: ResponsiveUtils.spacing8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  )
                                  : theme.colorScheme.surface,
                          border: Border.all(
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline.withValues(
                                      alpha: 0.3,
                                    ),
                          ),
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.radius20,
                          ),
                        ),
                        child: Text(
                          zone,
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error:
              (_, __) => Text(
                'Failed to load zones',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  color: theme.colorScheme.error,
                ),
              ),
        ),
      ],
    );
  }

  /// Build fruit type filter
  Widget _buildFruitTypeFilter(ThemeData theme) {
    final fruitTypesAsync = ref.watch(
      availableFruitTypesProvider(widget.cooperativeId),
    );
    final config = ref.watch(customReportProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fruit Types',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        fruitTypesAsync.when(
          data: (fruitTypes) {
            if (fruitTypes.isEmpty) {
              return Text(
                'No fruit types available',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              );
            }

            return Wrap(
              spacing: ResponsiveUtils.spacing8,
              runSpacing: ResponsiveUtils.spacing8,
              children:
                  fruitTypes.map((fruitType) {
                    final isSelected = config.filters.fruitTypes.contains(
                      fruitType,
                    );
                    return GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          ref
                              .read(customReportProvider.notifier)
                              .removeFruitTypeFilter(fruitType);
                        } else {
                          ref
                              .read(customReportProvider.notifier)
                              .addFruitTypeFilter(fruitType);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.spacing12,
                          vertical: ResponsiveUtils.spacing8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  )
                                  : theme.colorScheme.surface,
                          border: Border.all(
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline.withValues(
                                      alpha: 0.3,
                                    ),
                          ),
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.radius20,
                          ),
                        ),
                        child: Text(
                          fruitType,
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error:
              (_, __) => Text(
                'Failed to load fruit types',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  color: theme.colorScheme.error,
                ),
              ),
        ),
      ],
    );
  }

  /// Build columns tab
  Widget _buildColumnsTab(ThemeData theme) {
    final config = ref.watch(customReportProvider);
    final availableColumns = ref.watch(
      availableColumnsProvider(config.dataSource),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Columns',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      ref
                          .read(customReportProvider.notifier)
                          .setColumns(availableColumns);
                    },
                    child: Text(
                      'Select All',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize12,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(customReportProvider.notifier).clearColumns();
                    },
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize12,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing8),
          Text(
            'Choose which columns to include in your report (${config.columns.length} selected)',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing20),

          // Column selection
          ...availableColumns.map((column) {
            final isSelected = config.columns.contains(column);
            final displayName = ref.read(columnDisplayNameProvider(column));

            return Padding(
              padding: EdgeInsets.only(bottom: ResponsiveUtils.spacing8),
              child: GestureDetector(
                onTap: () {
                  ref.read(customReportProvider.notifier).toggleColumn(column);
                },
                child: Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surface,
                    border: Border.all(
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(
                                alpha: 0.3,
                              ),
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          ref
                              .read(customReportProvider.notifier)
                              .toggleColumn(column);
                        },
                        activeColor: theme.colorScheme.primary,
                      ),
                      SizedBox(width: ResponsiveUtils.spacing8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: GoogleFonts.inter(
                                fontSize: ResponsiveUtils.fontSize14,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              column,
                              style: GoogleFonts.inter(
                                fontSize: ResponsiveUtils.fontSize12,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build footer actions
  Widget _buildFooterActions(
    ThemeData theme,
    CustomReportConfig config,
    bool isGenerating,
  ) {
    final isValid = ref.read(customReportProvider.notifier).isValid();
    final errors =
        ref.read(customReportProvider.notifier).getValidationErrors();

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Validation errors
          if (errors.isNotEmpty)
            Container(
              margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing12),
              padding: EdgeInsets.all(ResponsiveUtils.spacing12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: ResponsiveUtils.iconSize16,
                      ),
                      SizedBox(width: ResponsiveUtils.spacing8),
                      Text(
                        'Please fix the following issues:',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUtils.spacing8),
                  ...errors.map(
                    (error) => Padding(
                      padding: EdgeInsets.only(left: ResponsiveUtils.spacing24),
                      child: Text(
                        '• $error',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize12,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Action buttons
          Row(
            children: [
              // Preview button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isValid && !isGenerating ? _previewReport : null,
                  icon: Icon(Icons.preview, size: ResponsiveUtils.iconSize16),
                  label: Text(
                    'Preview',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius8,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing12),

              // Generate button
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: isValid && !isGenerating ? _generateReport : null,
                  icon:
                      isGenerating
                          ? SizedBox(
                            width: ResponsiveUtils.iconSize16,
                            height: ResponsiveUtils.iconSize16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                          : Icon(
                            Icons.download,
                            size: ResponsiveUtils.iconSize16,
                          ),
                  label: Text(
                    isGenerating ? 'Generating...' : 'Generate Report',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius8,
                      ),
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

  /// Preview report
  void _previewReport() {
    final config = ref.read(customReportProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ReportPreviewWidget(
            cooperativeId: widget.cooperativeId,
            config: config,
            onClose: () => Navigator.of(context).pop(),
          ),
    );
  }

  /// Generate report
  void _generateReport() async {
    // Get authenticated user
    final authState = ref.read(mobileAuthProvider);
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to generate reports')),
      );
      return;
    }

    final config = ref.read(customReportProvider);
    final reportService = ReportGenerationService();

    ref.read(reportGenerationStateProvider.notifier).state = true;

    try {
      // Generate the actual report
      final report = await reportService.generateReport(
        cooperativeId: widget.cooperativeId,
        config: config,
        userId: authState.user.id,
      );

      if (mounted) {
        ref.read(reportGenerationStateProvider.notifier).state = false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report "${report.name}" generated successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Download',
              onPressed: () async {
                try {
                  await reportService.downloadReport(report);
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

        // Reset and close
        ref.read(customReportProvider.notifier).reset();
        Navigator.of(context).pop();

        if (widget.onReportGenerated != null) {
          widget.onReportGenerated!();
        }
      }
    } catch (e) {
      if (mounted) {
        ref.read(reportGenerationStateProvider.notifier).state = false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

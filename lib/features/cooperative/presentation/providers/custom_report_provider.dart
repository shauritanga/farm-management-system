import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_models.dart';

/// Custom report configuration state notifier
class CustomReportNotifier extends StateNotifier<CustomReportConfig> {
  CustomReportNotifier() : super(CustomReportConfig.empty);

  /// Update report name
  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  /// Update report description
  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  /// Update data source
  void updateDataSource(DataSource dataSource) {
    state = state.copyWith(
      dataSource: dataSource,
      columns: [], // Reset columns when data source changes
    );
  }

  /// Update date range
  void updateDateRange(DateRange? dateRange) {
    state = state.copyWith(dateRange: dateRange);
  }

  /// Update filters
  void updateFilters(ReportFilters filters) {
    state = state.copyWith(filters: filters);
  }

  /// Add zone filter
  void addZoneFilter(String zone) {
    final currentZones = List<String>.from(state.filters.zones);
    if (!currentZones.contains(zone)) {
      currentZones.add(zone);
      final updatedFilters = state.filters.copyWith(zones: currentZones);
      state = state.copyWith(filters: updatedFilters);
    }
  }

  /// Remove zone filter
  void removeZoneFilter(String zone) {
    final currentZones = List<String>.from(state.filters.zones);
    currentZones.remove(zone);
    final updatedFilters = state.filters.copyWith(zones: currentZones);
    state = state.copyWith(filters: updatedFilters);
  }

  /// Add farmer filter
  void addFarmerFilter(String farmer) {
    final currentFarmers = List<String>.from(state.filters.farmers);
    if (!currentFarmers.contains(farmer)) {
      currentFarmers.add(farmer);
      final updatedFilters = state.filters.copyWith(farmers: currentFarmers);
      state = state.copyWith(filters: updatedFilters);
    }
  }

  /// Remove farmer filter
  void removeFarmerFilter(String farmer) {
    final currentFarmers = List<String>.from(state.filters.farmers);
    currentFarmers.remove(farmer);
    final updatedFilters = state.filters.copyWith(farmers: currentFarmers);
    state = state.copyWith(filters: updatedFilters);
  }

  /// Add product filter
  void addProductFilter(String product) {
    final currentProducts = List<String>.from(state.filters.products);
    if (!currentProducts.contains(product)) {
      currentProducts.add(product);
      final updatedFilters = state.filters.copyWith(products: currentProducts);
      state = state.copyWith(filters: updatedFilters);
    }
  }

  /// Remove product filter
  void removeProductFilter(String product) {
    final currentProducts = List<String>.from(state.filters.products);
    currentProducts.remove(product);
    final updatedFilters = state.filters.copyWith(products: currentProducts);
    state = state.copyWith(filters: updatedFilters);
  }

  /// Add fruit type filter
  void addFruitTypeFilter(String fruitType) {
    final currentFruitTypes = List<String>.from(state.filters.fruitTypes);
    if (!currentFruitTypes.contains(fruitType)) {
      currentFruitTypes.add(fruitType);
      final updatedFilters = state.filters.copyWith(fruitTypes: currentFruitTypes);
      state = state.copyWith(filters: updatedFilters);
    }
  }

  /// Remove fruit type filter
  void removeFruitTypeFilter(String fruitType) {
    final currentFruitTypes = List<String>.from(state.filters.fruitTypes);
    currentFruitTypes.remove(fruitType);
    final updatedFilters = state.filters.copyWith(fruitTypes: currentFruitTypes);
    state = state.copyWith(filters: updatedFilters);
  }

  /// Update amount range
  void updateAmountRange(double? minAmount, double? maxAmount) {
    final updatedFilters = state.filters.copyWith(
      minAmount: minAmount,
      maxAmount: maxAmount,
    );
    state = state.copyWith(filters: updatedFilters);
  }

  /// Add column
  void addColumn(String column) {
    final currentColumns = List<String>.from(state.columns);
    if (!currentColumns.contains(column)) {
      currentColumns.add(column);
      state = state.copyWith(columns: currentColumns);
    }
  }

  /// Remove column
  void removeColumn(String column) {
    final currentColumns = List<String>.from(state.columns);
    currentColumns.remove(column);
    state = state.copyWith(columns: currentColumns);
  }

  /// Toggle column selection
  void toggleColumn(String column) {
    if (state.columns.contains(column)) {
      removeColumn(column);
    } else {
      addColumn(column);
    }
  }

  /// Set all columns
  void setColumns(List<String> columns) {
    state = state.copyWith(columns: columns);
  }

  /// Clear all columns
  void clearColumns() {
    state = state.copyWith(columns: []);
  }

  /// Update group by
  void updateGroupBy(String? groupBy) {
    state = state.copyWith(groupBy: groupBy);
  }

  /// Update sort by
  void updateSortBy(String? sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  /// Update sort order
  void updateSortOrder(SortOrder sortOrder) {
    state = state.copyWith(sortOrder: sortOrder);
  }

  /// Update format
  void updateFormat(ReportFormat format) {
    state = state.copyWith(format: format);
  }

  /// Reset to empty configuration
  void reset() {
    state = CustomReportConfig.empty;
  }

  /// Validate configuration
  bool isValid() {
    return state.name.isNotEmpty && state.columns.isNotEmpty;
  }

  /// Get validation errors
  List<String> getValidationErrors() {
    final errors = <String>[];
    
    if (state.name.isEmpty) {
      errors.add('Report name is required');
    }
    
    if (state.columns.isEmpty) {
      errors.add('At least one column must be selected');
    }
    
    if (state.dateRange != null) {
      if (state.dateRange!.start.isAfter(state.dateRange!.end)) {
        errors.add('Start date must be before end date');
      }
    }
    
    if (state.filters.minAmount != null && state.filters.maxAmount != null) {
      if (state.filters.minAmount! > state.filters.maxAmount!) {
        errors.add('Minimum amount must be less than maximum amount');
      }
    }
    
    return errors;
  }
}

/// Generated reports state notifier
class GeneratedReportsNotifier extends StateNotifier<List<GeneratedReport>> {
  GeneratedReportsNotifier() : super([]);

  /// Add generated report
  void addReport(GeneratedReport report) {
    state = [report, ...state];
  }

  /// Update report status
  void updateReportStatus(String reportId, ReportGenerationStatus status) {
    state = state.map((report) {
      if (report.id == reportId) {
        return report.copyWith(status: status);
      }
      return report;
    }).toList();
  }

  /// Remove report
  void removeReport(String reportId) {
    state = state.where((report) => report.id != reportId).toList();
  }

  /// Clear all reports
  void clearReports() {
    state = [];
  }

  /// Get reports by category
  List<GeneratedReport> getReportsByCategory(ReportCategory category) {
    return state.where((report) => report.category == category).toList();
  }

  /// Get reports by status
  List<GeneratedReport> getReportsByStatus(ReportGenerationStatus status) {
    return state.where((report) => report.status == status).toList();
  }
}

/// Report preview data model
class ReportPreviewData {
  final List<Map<String, dynamic>> previewData;
  final int totalCount;
  final int filteredCount;

  const ReportPreviewData({
    required this.previewData,
    required this.totalCount,
    required this.filteredCount,
  });
}

/// Report preview state notifier
class ReportPreviewNotifier extends StateNotifier<ReportPreviewData?> {
  ReportPreviewNotifier() : super(null);

  /// Update preview data
  void updatePreview(ReportPreviewData data) {
    state = data;
  }

  /// Clear preview
  void clearPreview() {
    state = null;
  }
}

/// Providers for custom report system
final customReportProvider = StateNotifierProvider<CustomReportNotifier, CustomReportConfig>((ref) {
  return CustomReportNotifier();
});

final generatedReportsProvider = StateNotifierProvider<GeneratedReportsNotifier, List<GeneratedReport>>((ref) {
  return GeneratedReportsNotifier();
});

final reportPreviewProvider = StateNotifierProvider<ReportPreviewNotifier, ReportPreviewData?>((ref) {
  return ReportPreviewNotifier();
});

/// Report generation state provider
final reportGenerationStateProvider = StateProvider<bool>((ref) => false);

/// Selected report category filter provider
final selectedReportCategoryProvider = StateProvider<ReportCategory?>((ref) => null);

/// Report search query provider
final reportSearchQueryProvider = StateProvider<String>((ref) => '');

/// Show custom report builder provider
final showCustomReportBuilderProvider = StateProvider<bool>((ref) => false);

/// Show report preview provider
final showReportPreviewProvider = StateProvider<bool>((ref) => false);

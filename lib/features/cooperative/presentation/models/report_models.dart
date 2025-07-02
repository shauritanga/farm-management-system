import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Report template data model
class ReportTemplate {
  final String id;
  final String name;
  final String description;
  final ReportCategory category;
  final IconData icon;
  final ReportFrequency frequency;
  final DateTime? lastGenerated;
  final ReportStatus status;
  final String estimatedTime;
  final List<ReportFormat> formats;

  const ReportTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.frequency,
    this.lastGenerated,
    required this.status,
    required this.estimatedTime,
    required this.formats,
  });

  ReportTemplate copyWith({
    String? id,
    String? name,
    String? description,
    ReportCategory? category,
    IconData? icon,
    ReportFrequency? frequency,
    DateTime? lastGenerated,
    ReportStatus? status,
    String? estimatedTime,
    List<ReportFormat>? formats,
  }) {
    return ReportTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      frequency: frequency ?? this.frequency,
      lastGenerated: lastGenerated ?? this.lastGenerated,
      status: status ?? this.status,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      formats: formats ?? this.formats,
    );
  }
}

/// Generated report data model
class GeneratedReport {
  final String id;
  final String templateId;
  final String name;
  final ReportCategory category;
  final DateTime generatedAt;
  final String period;
  final ReportGenerationStatus status;
  final String fileSize;
  final String? downloadUrl;
  final List<String> sharedWith;

  const GeneratedReport({
    required this.id,
    required this.templateId,
    required this.name,
    required this.category,
    required this.generatedAt,
    required this.period,
    required this.status,
    required this.fileSize,
    this.downloadUrl,
    required this.sharedWith,
  });

  GeneratedReport copyWith({
    String? id,
    String? templateId,
    String? name,
    ReportCategory? category,
    DateTime? generatedAt,
    String? period,
    ReportGenerationStatus? status,
    String? fileSize,
    String? downloadUrl,
    List<String>? sharedWith,
  }) {
    return GeneratedReport(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      category: category ?? this.category,
      generatedAt: generatedAt ?? this.generatedAt,
      period: period ?? this.period,
      status: status ?? this.status,
      fileSize: fileSize ?? this.fileSize,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      sharedWith: sharedWith ?? this.sharedWith,
    );
  }
}

/// Custom report configuration model
class CustomReportConfig {
  final String name;
  final String description;
  final DataSource dataSource;
  final DateRange? dateRange;
  final ReportFilters filters;
  final List<String> columns;
  final String? groupBy;
  final String? sortBy;
  final SortOrder sortOrder;
  final ReportFormat format;

  const CustomReportConfig({
    required this.name,
    required this.description,
    required this.dataSource,
    this.dateRange,
    required this.filters,
    required this.columns,
    this.groupBy,
    this.sortBy,
    required this.sortOrder,
    required this.format,
  });

  CustomReportConfig copyWith({
    String? name,
    String? description,
    DataSource? dataSource,
    DateRange? dateRange,
    ReportFilters? filters,
    List<String>? columns,
    String? groupBy,
    String? sortBy,
    SortOrder? sortOrder,
    ReportFormat? format,
  }) {
    return CustomReportConfig(
      name: name ?? this.name,
      description: description ?? this.description,
      dataSource: dataSource ?? this.dataSource,
      dateRange: dateRange ?? this.dateRange,
      filters: filters ?? this.filters,
      columns: columns ?? this.columns,
      groupBy: groupBy ?? this.groupBy,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      format: format ?? this.format,
    );
  }

  static const empty = CustomReportConfig(
    name: '',
    description: '',
    dataSource: DataSource.sales,
    filters: ReportFilters.empty,
    columns: [],
    sortOrder: SortOrder.desc,
    format: ReportFormat.excel,
  );
}

/// Date range model
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  DateRange copyWith({DateTime? start, DateTime? end}) {
    return DateRange(start: start ?? this.start, end: end ?? this.end);
  }
}

/// Report filters model
class ReportFilters {
  final List<String> zones;
  final List<String> farmers;
  final List<String> products;
  final double? minAmount;
  final double? maxAmount;
  final List<String> fruitTypes;

  const ReportFilters({
    required this.zones,
    required this.farmers,
    required this.products,
    this.minAmount,
    this.maxAmount,
    required this.fruitTypes,
  });

  ReportFilters copyWith({
    List<String>? zones,
    List<String>? farmers,
    List<String>? products,
    double? minAmount,
    double? maxAmount,
    List<String>? fruitTypes,
  }) {
    return ReportFilters(
      zones: zones ?? this.zones,
      farmers: farmers ?? this.farmers,
      products: products ?? this.products,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      fruitTypes: fruitTypes ?? this.fruitTypes,
    );
  }

  static const empty = ReportFilters(
    zones: [],
    farmers: [],
    products: [],
    fruitTypes: [],
  );
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

  ReportPreviewData copyWith({
    List<Map<String, dynamic>>? previewData,
    int? totalCount,
    int? filteredCount,
  }) {
    return ReportPreviewData(
      previewData: previewData ?? this.previewData,
      totalCount: totalCount ?? this.totalCount,
      filteredCount: filteredCount ?? this.filteredCount,
    );
  }
}

/// Scheduled report model
class ScheduledReport {
  final String id;
  final String cooperativeId;
  final String name;
  final String description;
  final String templateId;
  final ScheduleFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? lastRun;
  final DateTime nextRun;
  final bool isActive;
  final Map<String, dynamic> customFilters;
  final List<String> emailRecipients;
  final String createdBy;
  final DateTime createdAt;

  const ScheduledReport({
    required this.id,
    required this.cooperativeId,
    required this.name,
    required this.description,
    required this.templateId,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.lastRun,
    required this.nextRun,
    required this.isActive,
    required this.customFilters,
    required this.emailRecipients,
    required this.createdBy,
    required this.createdAt,
  });

  ScheduledReport copyWith({
    String? id,
    String? cooperativeId,
    String? name,
    String? description,
    String? templateId,
    ScheduleFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastRun,
    DateTime? nextRun,
    bool? isActive,
    Map<String, dynamic>? customFilters,
    List<String>? emailRecipients,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return ScheduledReport(
      id: id ?? this.id,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      name: name ?? this.name,
      description: description ?? this.description,
      templateId: templateId ?? this.templateId,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastRun: lastRun ?? this.lastRun,
      nextRun: nextRun ?? this.nextRun,
      isActive: isActive ?? this.isActive,
      customFilters: customFilters ?? this.customFilters,
      emailRecipients: emailRecipients ?? this.emailRecipients,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cooperativeId': cooperativeId,
      'name': name,
      'description': description,
      'templateId': templateId,
      'frequency': frequency.name,
      'startDate': startDate,
      'endDate': endDate,
      'lastRun': lastRun,
      'nextRun': nextRun,
      'isActive': isActive,
      'customFilters': customFilters,
      'emailRecipients': emailRecipients,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  factory ScheduledReport.fromMap(Map<String, dynamic> map, String id) {
    return ScheduledReport(
      id: id,
      cooperativeId: map['cooperativeId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      templateId: map['templateId'] ?? '',
      frequency: ScheduleFrequency.values.firstWhere(
        (f) => f.name == map['frequency'],
        orElse: () => ScheduleFrequency.monthly,
      ),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate:
          map['endDate'] != null
              ? (map['endDate'] as Timestamp).toDate()
              : null,
      lastRun:
          map['lastRun'] != null
              ? (map['lastRun'] as Timestamp).toDate()
              : null,
      nextRun: (map['nextRun'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
      customFilters: Map<String, dynamic>.from(map['customFilters'] ?? {}),
      emailRecipients: List<String>.from(map['emailRecipients'] ?? []),
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

/// Enums for report system
enum ReportCategory { financial, operational, farmer, product, compliance }

enum ScheduleFrequency { daily, weekly, monthly, quarterly, yearly }

enum ReportFrequency { daily, weekly, monthly, quarterly, yearly, custom }

enum ReportStatus { active, draft, archived }

enum ReportGenerationStatus { generating, completed, failed }

enum ReportFormat { pdf, excel, csv }

enum DataSource { sales, farmers, products, combined }

enum SortOrder { asc, desc }

/// Extension methods for enums
extension ReportCategoryExtension on ReportCategory {
  String get displayName {
    switch (this) {
      case ReportCategory.financial:
        return 'Financial';
      case ReportCategory.operational:
        return 'Operational';
      case ReportCategory.farmer:
        return 'Farmer';
      case ReportCategory.product:
        return 'Product';
      case ReportCategory.compliance:
        return 'Compliance';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportCategory.financial:
        return Icons.attach_money;
      case ReportCategory.operational:
        return Icons.settings;
      case ReportCategory.farmer:
        return Icons.people;
      case ReportCategory.product:
        return Icons.inventory;
      case ReportCategory.compliance:
        return Icons.verified;
    }
  }

  Color get color {
    switch (this) {
      case ReportCategory.financial:
        return Colors.green;
      case ReportCategory.operational:
        return Colors.blue;
      case ReportCategory.farmer:
        return Colors.purple;
      case ReportCategory.product:
        return Colors.orange;
      case ReportCategory.compliance:
        return Colors.red;
    }
  }
}

extension DataSourceExtension on DataSource {
  String get displayName {
    switch (this) {
      case DataSource.sales:
        return 'Sales Data';
      case DataSource.farmers:
        return 'Farmers Data';
      case DataSource.products:
        return 'Products Data';
      case DataSource.combined:
        return 'Combined Data';
    }
  }

  String get description {
    switch (this) {
      case DataSource.sales:
        return 'Transaction records';
      case DataSource.farmers:
        return 'Farmer profiles';
      case DataSource.products:
        return 'Product catalog';
      case DataSource.combined:
        return 'All data sources';
    }
  }

  String get emoji {
    switch (this) {
      case DataSource.sales:
        return '💰';
      case DataSource.farmers:
        return '👥';
      case DataSource.products:
        return '📦';
      case DataSource.combined:
        return '🔗';
    }
  }
}

extension ReportFormatExtension on ReportFormat {
  String get displayName {
    switch (this) {
      case ReportFormat.pdf:
        return 'PDF';
      case ReportFormat.excel:
        return 'Excel';
      case ReportFormat.csv:
        return 'CSV';
    }
  }

  String get fileExtension {
    switch (this) {
      case ReportFormat.pdf:
        return '.pdf';
      case ReportFormat.excel:
        return '.xlsx';
      case ReportFormat.csv:
        return '.csv';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportFormat.pdf:
        return Icons.picture_as_pdf;
      case ReportFormat.excel:
        return Icons.table_chart;
      case ReportFormat.csv:
        return Icons.description;
    }
  }
}

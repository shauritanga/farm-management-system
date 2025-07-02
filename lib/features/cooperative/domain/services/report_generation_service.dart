import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../presentation/models/report_models.dart';
import 'package:path_provider/path_provider.dart';

/// Service for generating and managing reports
class ReportGenerationService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ReportGenerationService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  /// Generate report preview data
  Future<ReportPreviewData> generatePreview({
    required String cooperativeId,
    required CustomReportConfig config,
    int previewLimit = 5,
  }) async {
    try {
      // Fetch data based on configuration
      final rawData = await _fetchFilteredData(cooperativeId, config);

      // Apply column selection
      final processedData = _processDataColumns(rawData, config.columns);

      // Apply sorting
      final sortedData = _applySorting(
        processedData,
        config.sortBy,
        config.sortOrder,
      );

      // Get preview subset
      final previewData = sortedData.take(previewLimit).toList();

      return ReportPreviewData(
        previewData: previewData,
        totalCount: rawData.length,
        filteredCount: sortedData.length,
      );
    } catch (e) {
      throw Exception('Failed to generate preview: $e');
    }
  }

  /// Generate complete report file
  Future<GeneratedReport> generateReport({
    required String cooperativeId,
    required CustomReportConfig config,
    required String userId,
  }) async {
    try {
      // Generate unique report ID
      final reportId = _generateReportId();

      // Fetch and process data
      final rawData = await _fetchFilteredData(cooperativeId, config);
      final processedData = _processDataColumns(rawData, config.columns);
      final sortedData = _applySorting(
        processedData,
        config.sortBy,
        config.sortOrder,
      );

      // Generate file based on format
      final fileBytes = await _generateFileBytes(sortedData, config);

      // Upload to Firebase Storage
      final downloadUrl = await _uploadToStorage(
        reportId,
        fileBytes,
        config.format,
        cooperativeId,
      );

      // Create report record
      final report = GeneratedReport(
        id: reportId,
        templateId: 'custom',
        name: config.name,
        category: _getReportCategory(config.dataSource),
        generatedAt: DateTime.now(),
        period: _formatDateRange(config.dateRange),
        status: ReportGenerationStatus.completed,
        fileSize: _formatFileSize(fileBytes.length),
        downloadUrl: downloadUrl,
        sharedWith: [],
      );

      // Save to Firestore
      await _saveReportRecord(cooperativeId, report, userId);

      return report;
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }

  /// Generate template-based report
  Future<GeneratedReport> generateTemplateReport({
    required String cooperativeId,
    required ReportTemplate template,
    required String userId,
    Map<String, dynamic>? customFilters,
  }) async {
    try {
      final reportId = _generateReportId();

      // Get template configuration
      final config = _getTemplateConfig(template, customFilters);

      // Fetch and process data
      final rawData = await _fetchFilteredData(cooperativeId, config);
      final processedData = _processDataColumns(rawData, config.columns);
      final sortedData = _applySorting(
        processedData,
        config.sortBy,
        config.sortOrder,
      );

      // Generate file (default to PDF for templates)
      final fileBytes = await _generateTemplateFileBytes(sortedData, template);

      // Upload to storage
      final downloadUrl = await _uploadToStorage(
        reportId,
        fileBytes,
        ReportFormat.pdf,
        cooperativeId,
      );

      // Create report record
      final report = GeneratedReport(
        id: reportId,
        templateId: template.id,
        name: template.name,
        category: template.category,
        generatedAt: DateTime.now(),
        period: _formatDateRange(config.dateRange),
        status: ReportGenerationStatus.completed,
        fileSize: _formatFileSize(fileBytes.length),
        downloadUrl: downloadUrl,
        sharedWith: [],
      );

      // Save to Firestore
      await _saveReportRecord(cooperativeId, report, userId);

      return report;
    } catch (e) {
      throw Exception('Failed to generate template report: $e');
    }
  }

  /// Download report file
  Future<String> downloadReport(GeneratedReport report) async {
    try {
      if (report.downloadUrl == null) {
        throw Exception('Report download URL not available');
      }

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${report.name}_${report.id}${_getFileExtension(report)}';
      final filePath = '${directory.path}/$fileName';

      // Download file from Firebase Storage
      final ref = _storage.refFromURL(report.downloadUrl!);
      final file = File(filePath);
      await ref.writeToFile(file);

      return filePath;
    } catch (e) {
      throw Exception('Failed to download report: $e');
    }
  }

  /// Share report
  Future<void> shareReport(GeneratedReport report) async {
    try {
      final filePath = await downloadReport(report);
      // TODO: Implement proper sharing once share_plus is properly configured
      // For now, just show a message that the file is ready to share
      throw Exception(
        'Report downloaded to: $filePath. Sharing functionality will be implemented with proper share_plus configuration.',
      );
    } catch (e) {
      throw Exception('Failed to share report: $e');
    }
  }

  /// Get generated reports for cooperative
  Future<List<GeneratedReport>> getGeneratedReports(
    String cooperativeId,
  ) async {
    try {
      final query =
          await _firestore
              .collection('cooperatives')
              .doc(cooperativeId)
              .collection('reports')
              .orderBy('generatedAt', descending: true)
              .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return GeneratedReport(
          id: doc.id,
          templateId: data['templateId'] ?? '',
          name: data['name'] ?? '',
          category: ReportCategory.values.firstWhere(
            (c) => c.name == data['category'],
            orElse: () => ReportCategory.operational,
          ),
          generatedAt: (data['generatedAt'] as Timestamp).toDate(),
          period: data['period'] ?? '',
          status: ReportGenerationStatus.values.firstWhere(
            (s) => s.name == data['status'],
            orElse: () => ReportGenerationStatus.completed,
          ),
          fileSize: data['fileSize'] ?? '',
          downloadUrl: data['downloadUrl'],
          sharedWith: List<String>.from(data['sharedWith'] ?? []),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get generated reports: $e');
    }
  }

  /// Delete report
  Future<void> deleteReport(String cooperativeId, String reportId) async {
    try {
      // Delete from Firestore
      await _firestore
          .collection('cooperatives')
          .doc(cooperativeId)
          .collection('reports')
          .doc(reportId)
          .delete();

      // Delete from Storage
      try {
        final ref = _storage.ref().child('reports/$cooperativeId/$reportId');
        await ref.delete();
      } catch (e) {
        // File might not exist, continue
      }
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  // Private helper methods
  String _generateReportId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  ReportCategory _getReportCategory(DataSource dataSource) {
    switch (dataSource) {
      case DataSource.sales:
        return ReportCategory.financial;
      case DataSource.farmers:
        return ReportCategory.farmer;
      case DataSource.products:
        return ReportCategory.product;
      case DataSource.combined:
        return ReportCategory.operational;
    }
  }

  String _formatDateRange(DateRange? dateRange) {
    if (dateRange == null) return 'All time';
    return '${_formatDate(dateRange.start)} - ${_formatDate(dateRange.end)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String _getFileExtension(GeneratedReport report) {
    // Determine from template or default to .pdf
    if (report.templateId == 'custom') {
      return '.pdf'; // Default for custom reports
    }
    return '.pdf'; // Default for template reports
  }

  /// Fetch filtered data based on configuration
  Future<List<Map<String, dynamic>>> _fetchFilteredData(
    String cooperativeId,
    CustomReportConfig config,
  ) async {
    List<Map<String, dynamic>> data = [];

    switch (config.dataSource) {
      case DataSource.sales:
        data = await _fetchSalesData(cooperativeId, config);
        break;
      case DataSource.farmers:
        data = await _fetchFarmersData(cooperativeId, config);
        break;
      case DataSource.products:
        data = await _fetchProductsData(cooperativeId, config);
        break;
      case DataSource.combined:
        final sales = await _fetchSalesData(cooperativeId, config);
        final farmers = await _fetchFarmersData(cooperativeId, config);
        final products = await _fetchProductsData(cooperativeId, config);
        data = [...sales, ...farmers, ...products];
        break;
    }

    return data;
  }

  /// Fetch sales data with filters
  Future<List<Map<String, dynamic>>> _fetchSalesData(
    String cooperativeId,
    CustomReportConfig config,
  ) async {
    Query query = _firestore
        .collection('sales')
        .where('cooperativeId', isEqualTo: cooperativeId);

    // Apply date filter
    if (config.dateRange != null) {
      query = query
          .where('createdAt', isGreaterThanOrEqualTo: config.dateRange!.start)
          .where('createdAt', isLessThanOrEqualTo: config.dateRange!.end);
    }

    // Apply amount filter
    if (config.filters.minAmount != null) {
      query = query.where(
        'amount',
        isGreaterThanOrEqualTo: config.filters.minAmount,
      );
    }
    if (config.filters.maxAmount != null) {
      query = query.where(
        'amount',
        isLessThanOrEqualTo: config.filters.maxAmount,
      );
    }

    final querySnapshot = await query.get();
    final salesData = <Map<String, dynamic>>[];

    for (final doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Apply additional filters
      if (config.filters.fruitTypes.isNotEmpty) {
        final fruitType = data['fruitType'] as String?;
        if (fruitType == null ||
            !config.filters.fruitTypes.contains(fruitType)) {
          continue;
        }
      }

      // Resolve farmer name
      String farmerName = 'Unknown';
      if (data['farmerId'] != null) {
        try {
          final farmerDoc =
              await _firestore
                  .collection('farmers')
                  .doc(data['farmerId'])
                  .get();
          if (farmerDoc.exists) {
            farmerName = farmerDoc.data()?['name'] ?? 'Unknown';

            // Apply zone filter
            if (config.filters.zones.isNotEmpty) {
              final zone = farmerDoc.data()?['zone'] as String?;
              if (zone == null || !config.filters.zones.contains(zone)) {
                continue;
              }
            }
          }
        } catch (e) {
          // Continue with unknown farmer
        }
      }

      // Resolve product name
      String productName = 'Unknown';
      if (data['productId'] != null) {
        try {
          final productDoc =
              await _firestore
                  .collection('products')
                  .doc(data['productId'])
                  .get();
          if (productDoc.exists) {
            productName = productDoc.data()?['name'] ?? 'Unknown';

            // Apply product filter
            if (config.filters.products.isNotEmpty) {
              if (!config.filters.products.contains(productName)) {
                continue;
              }
            }
          }
        } catch (e) {
          // Continue with unknown product
        }
      }

      salesData.add({
        'id': doc.id,
        'farmerName': farmerName,
        'productName': productName,
        ...data,
      });
    }

    return salesData;
  }

  /// Fetch farmers data with filters
  Future<List<Map<String, dynamic>>> _fetchFarmersData(
    String cooperativeId,
    CustomReportConfig config,
  ) async {
    Query query = _firestore
        .collection('farmers')
        .where('cooperativeId', isEqualTo: cooperativeId);

    // Apply date filter on joinDate
    if (config.dateRange != null) {
      query = query
          .where('joinDate', isGreaterThanOrEqualTo: config.dateRange!.start)
          .where('joinDate', isLessThanOrEqualTo: config.dateRange!.end);
    }

    final querySnapshot = await query.get();
    final farmersData = <Map<String, dynamic>>[];

    for (final doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Apply zone filter
      if (config.filters.zones.isNotEmpty) {
        final zone = data['zone'] as String?;
        if (zone == null || !config.filters.zones.contains(zone)) {
          continue;
        }
      }

      farmersData.add({'id': doc.id, ...data});
    }

    return farmersData;
  }

  /// Fetch products data with filters
  Future<List<Map<String, dynamic>>> _fetchProductsData(
    String cooperativeId,
    CustomReportConfig config,
  ) async {
    Query query = _firestore
        .collection('products')
        .where('cooperativeId', isEqualTo: cooperativeId);

    final querySnapshot = await query.get();
    final productsData = <Map<String, dynamic>>[];

    for (final doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Apply product filter
      if (config.filters.products.isNotEmpty) {
        final productName = data['name'] as String?;
        if (productName == null ||
            !config.filters.products.contains(productName)) {
          continue;
        }
      }

      productsData.add({'id': doc.id, ...data});
    }

    return productsData;
  }

  /// Process data columns based on selection
  List<Map<String, dynamic>> _processDataColumns(
    List<Map<String, dynamic>> data,
    List<String> selectedColumns,
  ) {
    if (selectedColumns.isEmpty) return data;

    return data.map((row) {
      final processedRow = <String, dynamic>{};
      for (final column in selectedColumns) {
        processedRow[column] = row[column];
      }
      return processedRow;
    }).toList();
  }

  /// Apply sorting to data
  List<Map<String, dynamic>> _applySorting(
    List<Map<String, dynamic>> data,
    String? sortBy,
    SortOrder sortOrder,
  ) {
    if (sortBy == null || sortBy.isEmpty) return data;

    data.sort((a, b) {
      final aValue = a[sortBy];
      final bValue = b[sortBy];

      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return 1;
      if (bValue == null) return -1;

      int comparison;
      if (aValue is num && bValue is num) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is DateTime && bValue is DateTime) {
        comparison = aValue.compareTo(bValue);
      } else {
        comparison = aValue.toString().compareTo(bValue.toString());
      }

      return sortOrder == SortOrder.asc ? comparison : -comparison;
    });

    return data;
  }

  /// Generate file bytes based on format
  Future<Uint8List> _generateFileBytes(
    List<Map<String, dynamic>> data,
    CustomReportConfig config,
  ) async {
    switch (config.format) {
      case ReportFormat.pdf:
        return _generateTextBytes(data, config, 'PDF');
      case ReportFormat.excel:
        return _generateTextBytes(data, config, 'EXCEL');
      case ReportFormat.csv:
        return _generateCsvBytes(data, config);
    }
  }

  /// Generate text-based file bytes (simplified for now)
  Uint8List _generateTextBytes(
    List<Map<String, dynamic>> data,
    CustomReportConfig config,
    String format,
  ) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('=== ${config.name} ===');
    buffer.writeln('Format: $format');
    buffer.writeln('Generated: ${DateTime.now().toString().substring(0, 19)}');
    buffer.writeln('Data Source: ${config.dataSource.displayName}');
    buffer.writeln('Total Records: ${data.length}');
    buffer.writeln();

    if (config.description.isNotEmpty) {
      buffer.writeln('Description: ${config.description}');
      buffer.writeln();
    }

    if (data.isNotEmpty) {
      // Headers
      buffer.writeln(config.columns.join('\t'));
      buffer.writeln('=' * (config.columns.length * 15));

      // Data rows
      for (final row in data) {
        final values =
            config.columns.map((col) => _formatCellValue(row[col])).toList();
        buffer.writeln(values.join('\t'));
      }
    } else {
      buffer.writeln('No data available for the selected criteria.');
    }

    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  /// Generate CSV bytes
  Uint8List _generateCsvBytes(
    List<Map<String, dynamic>> data,
    CustomReportConfig config,
  ) {
    final buffer = StringBuffer();

    // Add headers
    buffer.writeln(config.columns.map((col) => '"$col"').join(','));

    // Add data
    for (final row in data) {
      final values =
          config.columns.map((col) {
            final value = _formatCellValue(row[col]);
            return '"${value.replaceAll('"', '""')}"'; // Escape quotes
          }).toList();
      buffer.writeln(values.join(','));
    }

    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  /// Format cell value for display
  String _formatCellValue(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) return value.toString().substring(0, 19);
    if (value is Timestamp) return value.toDate().toString().substring(0, 19);
    if (value is double) return value.toStringAsFixed(2);
    return value.toString();
  }

  /// Upload file to Firebase Storage
  Future<String> _uploadToStorage(
    String reportId,
    Uint8List fileBytes,
    ReportFormat format,
    String cooperativeId,
  ) async {
    final extension = _getFormatExtension(format);
    final fileName = '$reportId$extension';
    final ref = _storage.ref().child('reports/$cooperativeId/$fileName');

    await ref.putData(fileBytes);
    return await ref.getDownloadURL();
  }

  /// Get file extension for format
  String _getFormatExtension(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return '.txt'; // Simplified for now
      case ReportFormat.excel:
        return '.txt'; // Simplified for now
      case ReportFormat.csv:
        return '.csv';
    }
  }

  /// Save report record to Firestore
  Future<void> _saveReportRecord(
    String cooperativeId,
    GeneratedReport report,
    String userId,
  ) async {
    await _firestore
        .collection('cooperatives')
        .doc(cooperativeId)
        .collection('reports')
        .doc(report.id)
        .set({
          'templateId': report.templateId,
          'name': report.name,
          'category': report.category.name,
          'generatedAt': report.generatedAt,
          'period': report.period,
          'status': report.status.name,
          'fileSize': report.fileSize,
          'downloadUrl': report.downloadUrl,
          'sharedWith': report.sharedWith,
          'createdBy': userId,
        });
  }

  /// Get template configuration
  CustomReportConfig _getTemplateConfig(
    ReportTemplate template,
    Map<String, dynamic>? customFilters,
  ) {
    // Create a basic configuration for template reports
    return CustomReportConfig(
      name: template.name,
      description: template.description,
      dataSource: _getDataSourceFromTemplate(template),
      columns: _getDefaultColumnsForTemplate(template),
      format: ReportFormat.pdf, // Default format for templates
      filters: ReportFilters.empty,
      dateRange: customFilters?['dateRange'],
      sortBy: customFilters?['sortBy'],
      sortOrder: customFilters?['sortOrder'] ?? SortOrder.asc,
    );
  }

  /// Get data source from template
  DataSource _getDataSourceFromTemplate(ReportTemplate template) {
    switch (template.category) {
      case ReportCategory.financial:
        return DataSource.sales;
      case ReportCategory.farmer:
        return DataSource.farmers;
      case ReportCategory.product:
        return DataSource.products;
      case ReportCategory.operational:
      case ReportCategory.compliance:
        return DataSource.combined;
    }
  }

  /// Get default columns for template
  List<String> _getDefaultColumnsForTemplate(ReportTemplate template) {
    switch (template.category) {
      case ReportCategory.financial:
        return ['date', 'farmerName', 'productName', 'amount', 'commission'];
      case ReportCategory.farmer:
        return ['name', 'zone', 'phone', 'totalTrees', 'joinDate'];
      case ReportCategory.product:
        return ['name', 'category', 'pricePerKg', 'totalSales'];
      case ReportCategory.operational:
      case ReportCategory.compliance:
        return ['date', 'type', 'description', 'status'];
    }
  }

  /// Generate template file bytes (simplified)
  Future<Uint8List> _generateTemplateFileBytes(
    List<Map<String, dynamic>> data,
    ReportTemplate template,
  ) async {
    final buffer = StringBuffer();

    // Template header
    buffer.writeln('=== ${template.name} ===');
    buffer.writeln('Category: ${template.category.displayName}');
    buffer.writeln('Generated: ${DateTime.now().toString().substring(0, 19)}');
    buffer.writeln('Total Records: ${data.length}');
    buffer.writeln();

    buffer.writeln('Description: ${template.description}');
    buffer.writeln();

    if (data.isNotEmpty) {
      // Get columns from first row
      final columns = data.first.keys.toList();

      // Headers
      buffer.writeln(columns.join('\t'));
      buffer.writeln('=' * (columns.length * 15));

      // Data rows
      for (final row in data) {
        final values =
            columns.map((col) => _formatCellValue(row[col])).toList();
        buffer.writeln(values.join('\t'));
      }
    } else {
      buffer.writeln('No data available.');
    }

    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }
}

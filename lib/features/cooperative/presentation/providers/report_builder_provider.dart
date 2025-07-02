import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/report_models.dart';

/// Report builder repository
class ReportBuilderRepository {
  final FirebaseFirestore _firestore;

  ReportBuilderRepository(this._firestore);

  /// Get predefined report templates
  List<ReportTemplate> getReportTemplates() {
    return [
      const ReportTemplate(
        id: 'financial-summary',
        name: 'Financial Summary Report',
        description: 'Comprehensive overview of revenue, expenses, and profitability',
        category: ReportCategory.financial,
        icon: Icons.attach_money,
        frequency: ReportFrequency.monthly,
        status: ReportStatus.active,
        estimatedTime: '2-3 minutes',
        formats: [ReportFormat.pdf, ReportFormat.excel],
      ),
      const ReportTemplate(
        id: 'farmer-performance',
        name: 'Farmer Performance Analysis',
        description: 'Individual farmer sales, productivity, and growth metrics',
        category: ReportCategory.farmer,
        icon: Icons.people,
        frequency: ReportFrequency.weekly,
        status: ReportStatus.active,
        estimatedTime: '3-5 minutes',
        formats: [ReportFormat.pdf, ReportFormat.excel, ReportFormat.csv],
      ),
      const ReportTemplate(
        id: 'product-analysis',
        name: 'Product Sales & Inventory Report',
        description: 'Product performance, pricing trends, and inventory status',
        category: ReportCategory.product,
        icon: Icons.inventory,
        frequency: ReportFrequency.monthly,
        status: ReportStatus.active,
        estimatedTime: '2-4 minutes',
        formats: [ReportFormat.pdf, ReportFormat.excel],
      ),
      const ReportTemplate(
        id: 'geographic-distribution',
        name: 'Geographic Distribution Report',
        description: 'Zone-wise performance, farmer distribution, and regional insights',
        category: ReportCategory.operational,
        icon: Icons.map,
        frequency: ReportFrequency.quarterly,
        status: ReportStatus.active,
        estimatedTime: '4-6 minutes',
        formats: [ReportFormat.pdf, ReportFormat.excel],
      ),
      const ReportTemplate(
        id: 'bank-payment-list',
        name: 'Bank Payment List',
        description: 'Detailed payment records for bank processing',
        category: ReportCategory.financial,
        icon: Icons.account_balance,
        frequency: ReportFrequency.monthly,
        status: ReportStatus.active,
        estimatedTime: '1-2 minutes',
        formats: [ReportFormat.excel, ReportFormat.csv],
      ),
      const ReportTemplate(
        id: 'quality-analysis',
        name: 'Quality Analysis Report',
        description: 'Product quality grades and improvement recommendations',
        category: ReportCategory.product,
        icon: Icons.verified,
        frequency: ReportFrequency.weekly,
        status: ReportStatus.active,
        estimatedTime: '2-3 minutes',
        formats: [ReportFormat.pdf, ReportFormat.excel],
      ),
    ];
  }

  /// Get available columns for data source
  List<String> getAvailableColumns(DataSource dataSource) {
    switch (dataSource) {
      case DataSource.sales:
        return [
          'farmerId',
          'farmerName',
          'productId',
          'productName',
          'weight',
          'pricePerKg',
          'amount',
          'cooperativeCommission',
          'amountFarmerReceive',
          'fruitType',
          'qualityGrade',
          'saleDate',
          'createdAt',
          'updatedAt',
        ];
      case DataSource.farmers:
        return [
          'name',
          'email',
          'phone',
          'location',
          'farmSize',
          'crops',
          'joinDate',
          'status',
          'zone',
          'village',
          'gender',
          'dateOfBirth',
          'totalTrees',
          'fruitingTrees',
          'bankNumber',
          'bankName',
          'nationalId',
          'emergencyContact',
          'createdAt',
          'updatedAt',
        ];
      case DataSource.products:
        return [
          'name',
          'category',
          'description',
          'unit',
          'qualityGrades',
          'isActive',
          'createdDate',
          'updatedDate',
          'cooperativeId',
        ];
      case DataSource.combined:
        return [
          ...getAvailableColumns(DataSource.sales),
          ...getAvailableColumns(DataSource.farmers),
          ...getAvailableColumns(DataSource.products),
        ];
    }
  }

  /// Get column display name
  String getColumnDisplayName(String column) {
    final displayNames = {
      'farmerId': 'Farmer ID',
      'farmerName': 'Farmer Name',
      'productId': 'Product ID',
      'productName': 'Product Name',
      'pricePerKg': 'Price per Kg',
      'cooperativeCommission': 'Cooperative Commission',
      'amountFarmerReceive': 'Amount Farmer Receives',
      'fruitType': 'Fruit Type',
      'qualityGrade': 'Quality Grade',
      'saleDate': 'Sale Date',
      'createdAt': 'Created At',
      'updatedAt': 'Updated At',
      'farmSize': 'Farm Size',
      'joinDate': 'Join Date',
      'dateOfBirth': 'Date of Birth',
      'totalTrees': 'Total Trees',
      'fruitingTrees': 'Fruiting Trees',
      'bankNumber': 'Bank Number',
      'bankName': 'Bank Name',
      'nationalId': 'National ID',
      'emergencyContact': 'Emergency Contact',
      'qualityGrades': 'Quality Grades',
      'isActive': 'Is Active',
      'createdDate': 'Created Date',
      'updatedDate': 'Updated Date',
      'cooperativeId': 'Cooperative ID',
    };

    return displayNames[column] ?? 
           column.split('_').map((word) => 
             word[0].toUpperCase() + word.substring(1)
           ).join(' ');
  }

  /// Fetch data for report generation
  Future<List<Map<String, dynamic>>> fetchReportData(
    String cooperativeId,
    DataSource dataSource,
  ) async {
    try {
      switch (dataSource) {
        case DataSource.sales:
          return await _fetchSalesData(cooperativeId);
        case DataSource.farmers:
          return await _fetchFarmersData(cooperativeId);
        case DataSource.products:
          return await _fetchProductsData(cooperativeId);
        case DataSource.combined:
          final sales = await _fetchSalesData(cooperativeId);
          final farmers = await _fetchFarmersData(cooperativeId);
          final products = await _fetchProductsData(cooperativeId);
          return [...sales, ...farmers, ...products];
      }
    } catch (e) {
      throw Exception('Failed to fetch report data: $e');
    }
  }

  /// Fetch sales data
  Future<List<Map<String, dynamic>>> _fetchSalesData(String cooperativeId) async {
    final query = await _firestore
        .collection('sales')
        .where('cooperativeId', isEqualTo: cooperativeId)
        .orderBy('createdAt', descending: true)
        .get();

    final salesData = <Map<String, dynamic>>[];
    
    for (final doc in query.docs) {
      final data = doc.data();
      
      // Resolve farmer name
      String farmerName = 'Unknown';
      if (data['farmerId'] != null) {
        try {
          final farmerDoc = await _firestore
              .collection('farmers')
              .doc(data['farmerId'])
              .get();
          if (farmerDoc.exists) {
            farmerName = farmerDoc.data()?['name'] ?? 'Unknown';
          }
        } catch (e) {
          // Keep default name if error
        }
      }

      // Resolve product name
      String productName = 'Unknown';
      if (data['productId'] != null) {
        try {
          final productDoc = await _firestore
              .collection('products')
              .doc(data['productId'])
              .get();
          if (productDoc.exists) {
            productName = productDoc.data()?['name'] ?? 'Unknown';
          }
        } catch (e) {
          // Keep default name if error
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

  /// Fetch farmers data
  Future<List<Map<String, dynamic>>> _fetchFarmersData(String cooperativeId) async {
    final query = await _firestore
        .collection('farmers')
        .where('cooperativeId', isEqualTo: cooperativeId)
        .get();

    return query.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  /// Fetch products data
  Future<List<Map<String, dynamic>>> _fetchProductsData(String cooperativeId) async {
    final query = await _firestore
        .collection('products')
        .where('cooperativeId', isEqualTo: cooperativeId)
        .get();

    return query.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  /// Get available zones for filtering
  Future<List<String>> getAvailableZones(String cooperativeId) async {
    try {
      final query = await _firestore
          .collection('farmers')
          .where('cooperativeId', isEqualTo: cooperativeId)
          .get();

      final zones = <String>{};
      for (final doc in query.docs) {
        final zone = doc.data()['zone'] as String?;
        if (zone != null && zone.isNotEmpty) {
          zones.add(zone);
        }
      }

      return zones.toList()..sort();
    } catch (e) {
      return [];
    }
  }

  /// Get available fruit types for filtering
  Future<List<String>> getAvailableFruitTypes(String cooperativeId) async {
    try {
      final query = await _firestore
          .collection('sales')
          .where('cooperativeId', isEqualTo: cooperativeId)
          .get();

      final fruitTypes = <String>{};
      for (final doc in query.docs) {
        final fruitType = doc.data()['fruitType'] as String?;
        if (fruitType != null && fruitType.isNotEmpty) {
          fruitTypes.add(fruitType);
        }
      }

      return fruitTypes.toList()..sort();
    } catch (e) {
      return [];
    }
  }
}

/// Provider for report builder repository
final reportBuilderRepositoryProvider = Provider<ReportBuilderRepository>((ref) {
  return ReportBuilderRepository(FirebaseFirestore.instance);
});

/// Provider for report templates
final reportTemplatesProvider = Provider<List<ReportTemplate>>((ref) {
  final repository = ref.read(reportBuilderRepositoryProvider);
  return repository.getReportTemplates();
});

/// Provider for available columns
final availableColumnsProvider = Provider.family<List<String>, DataSource>((ref, dataSource) {
  final repository = ref.read(reportBuilderRepositoryProvider);
  return repository.getAvailableColumns(dataSource);
});

/// Provider for column display names
final columnDisplayNameProvider = Provider.family<String, String>((ref, column) {
  final repository = ref.read(reportBuilderRepositoryProvider);
  return repository.getColumnDisplayName(column);
});

/// Provider for report data
final reportDataProvider = FutureProvider.family<List<Map<String, dynamic>>, ({String cooperativeId, DataSource dataSource})>((ref, params) async {
  final repository = ref.read(reportBuilderRepositoryProvider);
  return await repository.fetchReportData(params.cooperativeId, params.dataSource);
});

/// Provider for available zones
final availableZonesProvider = FutureProvider.family<List<String>, String>((ref, cooperativeId) async {
  final repository = ref.read(reportBuilderRepositoryProvider);
  return await repository.getAvailableZones(cooperativeId);
});

/// Provider for available fruit types
final availableFruitTypesProvider = FutureProvider.family<List<String>, String>((ref, cooperativeId) async {
  final repository = ref.read(reportBuilderRepositoryProvider);
  return await repository.getAvailableFruitTypes(cooperativeId);
});

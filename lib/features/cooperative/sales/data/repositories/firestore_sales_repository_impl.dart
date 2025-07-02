import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/sale_core.dart';
import '../../domain/repositories/sales_repository.dart';
import '../models/sale_model.dart';

/// Firestore implementation of sales repository
class FirestoreSalesRepositoryImpl implements SalesRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'sales';

  FirestoreSalesRepositoryImpl(this._firestore);

  @override
  Future<List<SaleCoreEntity>> getAllSales({String? cooperativeId}) async {
    try {
      Query query = _firestore.collection(_collection);
      
      // Filter by cooperative ID if provided
      if (cooperativeId != null && cooperativeId.isNotEmpty) {
        query = query.where('cooperativeId', isEqualTo: cooperativeId);
      }
      
      final querySnapshot = await query
          .orderBy('saleDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SaleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sales: $e');
    }
  }

  @override
  Future<SaleCoreEntity?> getSaleById(String saleId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(saleId).get();

      if (!doc.exists) return null;

      return SaleModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get sale: $e');
    }
  }

  @override
  Future<List<SaleCoreEntity>> getSalesByFarmerId(String farmerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('farmerId', isEqualTo: farmerId)
          .orderBy('saleDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SaleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sales by farmer: $e');
    }
  }

  @override
  Future<List<SaleCoreEntity>> getSalesByProductId(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('productId', isEqualTo: productId)
          .orderBy('saleDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SaleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sales by product: $e');
    }
  }

  @override
  Future<List<SaleCoreEntity>> getSalesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? cooperativeId,
  }) async {
    try {
      Query query = _firestore.collection(_collection);
      
      // Filter by cooperative ID if provided
      if (cooperativeId != null && cooperativeId.isNotEmpty) {
        query = query.where('cooperativeId', isEqualTo: cooperativeId);
      }
      
      // Filter by date range
      query = query
          .where('saleDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('saleDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('saleDate', descending: true);

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => SaleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sales by date range: $e');
    }
  }

  @override
  Future<SaleCoreEntity> createSale(CreateSaleData data) async {
    try {
      final now = DateTime.now();
      final saleData = {
        'cooperativeId': data.cooperativeId,
        'farmerId': data.farmerId,
        'productId': data.productId,
        'weight': data.weight,
        'pricePerKg': data.pricePerKg,
        'amount': data.amount,
        'fruityType': data.fruityType,
        'qualityGrade': data.qualityGrade,
        'cooperativeCommission': data.cooperativeCommission,
        'amountFarmerReceives': data.amountFarmerReceives,
        'saleDate': Timestamp.fromDate(data.saleDate),
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'createdBy': data.createdBy,
        'updatedBy': data.createdBy,
      };

      final docRef = await _firestore.collection(_collection).add(saleData);
      final createdDoc = await docRef.get();
      
      return SaleModel.fromFirestore(createdDoc);
    } catch (e) {
      throw Exception('Failed to create sale: $e');
    }
  }

  @override
  Future<SaleCoreEntity> updateSale(String saleId, UpdateSaleData data) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      // Only update fields that are provided (non-null)
      if (data.farmerId != null) updateData['farmerId'] = data.farmerId;
      if (data.productId != null) updateData['productId'] = data.productId;
      if (data.weight != null) updateData['weight'] = data.weight;
      if (data.pricePerKg != null) updateData['pricePerKg'] = data.pricePerKg;
      if (data.amount != null) updateData['amount'] = data.amount;
      if (data.fruityType != null) updateData['fruityType'] = data.fruityType;
      if (data.qualityGrade != null) updateData['qualityGrade'] = data.qualityGrade;
      if (data.cooperativeCommission != null) updateData['cooperativeCommission'] = data.cooperativeCommission;
      if (data.amountFarmerReceives != null) updateData['amountFarmerReceives'] = data.amountFarmerReceives;
      if (data.saleDate != null) updateData['saleDate'] = Timestamp.fromDate(data.saleDate!);
      if (data.updatedBy != null) updateData['updatedBy'] = data.updatedBy;

      await _firestore.collection(_collection).doc(saleId).update(updateData);
      
      final updatedDoc = await _firestore.collection(_collection).doc(saleId).get();
      return SaleModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw Exception('Failed to update sale: $e');
    }
  }

  @override
  Future<void> deleteSale(String saleId) async {
    try {
      await _firestore.collection(_collection).doc(saleId).delete();
    } catch (e) {
      throw Exception('Failed to delete sale: $e');
    }
  }

  @override
  Future<List<SaleCoreEntity>> searchSales(SalesSearchCriteria criteria) async {
    try {
      Query query = _firestore.collection(_collection);

      // Apply filters
      if (criteria.farmerId != null && criteria.farmerId!.isNotEmpty) {
        query = query.where('farmerId', isEqualTo: criteria.farmerId);
      }

      if (criteria.productId != null && criteria.productId!.isNotEmpty) {
        query = query.where('productId', isEqualTo: criteria.productId);
      }

      if (criteria.fruityType != null && criteria.fruityType!.isNotEmpty) {
        query = query.where('fruityType', isEqualTo: criteria.fruityType);
      }

      if (criteria.qualityGrade != null && criteria.qualityGrade!.isNotEmpty) {
        query = query.where('qualityGrade', isEqualTo: criteria.qualityGrade);
      }

      // Date range filter
      if (criteria.startDate != null) {
        query = query.where('saleDate', isGreaterThanOrEqualTo: Timestamp.fromDate(criteria.startDate!));
      }

      if (criteria.endDate != null) {
        query = query.where('saleDate', isLessThanOrEqualTo: Timestamp.fromDate(criteria.endDate!));
      }

      final querySnapshot = await query.orderBy('saleDate', descending: true).get();
      List<SaleCoreEntity> sales = querySnapshot.docs
          .map((doc) => SaleModel.fromFirestore(doc))
          .toList();

      // Apply additional filters that can't be done in Firestore query
      if (criteria.query != null && criteria.query!.isNotEmpty) {
        final searchQuery = criteria.query!.toLowerCase();
        sales = sales.where((sale) {
          return sale.fruityType.toLowerCase().contains(searchQuery) ||
              sale.productId.toLowerCase().contains(searchQuery) ||
              (sale.qualityGrade?.toLowerCase().contains(searchQuery) ?? false);
        }).toList();
      }

      // Filter by amount range
      if (criteria.minAmount != null) {
        sales = sales.where((sale) => sale.amount >= criteria.minAmount!).toList();
      }

      if (criteria.maxAmount != null) {
        sales = sales.where((sale) => sale.amount <= criteria.maxAmount!).toList();
      }

      // Filter by weight range
      if (criteria.minWeight != null) {
        sales = sales.where((sale) => sale.weight >= criteria.minWeight!).toList();
      }

      if (criteria.maxWeight != null) {
        sales = sales.where((sale) => sale.weight <= criteria.maxWeight!).toList();
      }

      return sales;
    } catch (e) {
      throw Exception('Failed to search sales: $e');
    }
  }

  @override
  Future<int> getSalesCount({String? cooperativeId}) async {
    try {
      Query query = _firestore.collection(_collection);
      
      if (cooperativeId != null && cooperativeId.isNotEmpty) {
        query = query.where('cooperativeId', isEqualTo: cooperativeId);
      }
      
      final querySnapshot = await query.get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get sales count: $e');
    }
  }

  // Placeholder implementations for complex methods
  @override
  Future<SalesStatistics> getSalesStatistics({String? cooperativeId}) async {
    // TODO: Implement comprehensive statistics from Firestore
    throw UnimplementedError('Statistics not yet implemented for Firestore');
  }

  @override
  Future<SalesSummary> getSalesSummary({
    required DateTime startDate,
    required DateTime endDate,
    String? cooperativeId,
  }) async {
    // TODO: Implement sales summary
    throw UnimplementedError('Sales summary not yet implemented for Firestore');
  }

  @override
  Future<List<ProductSalesData>> getTopSellingProducts({
    String? cooperativeId,
    int limit = 10,
  }) async {
    // TODO: Implement top selling products
    throw UnimplementedError('Top selling products not yet implemented for Firestore');
  }

  @override
  Future<List<FarmerSalesData>> getFarmerSalesPerformance({
    String? cooperativeId,
    int limit = 10,
  }) async {
    // TODO: Implement farmer sales performance
    throw UnimplementedError('Farmer sales performance not yet implemented for Firestore');
  }

  @override
  Future<String> exportSalesData({
    String? cooperativeId,
    DateTime? startDate,
    DateTime? endDate,
    String? format,
  }) async {
    // TODO: Implement export functionality
    throw UnimplementedError('Export not yet implemented for Firestore');
  }

  @override
  Future<PaginatedSales> getSalesWithPagination({
    int page = 1,
    int limit = 20,
    String? cooperativeId,
    SalesSearchCriteria? criteria,
  }) async {
    // TODO: Implement pagination
    throw UnimplementedError('Pagination not yet implemented for Firestore');
  }
}

/// Provider for Firestore sales repository
final firestoreSalesRepositoryProvider = Provider<SalesRepository>((ref) {
  return FirestoreSalesRepositoryImpl(FirebaseFirestore.instance);
});

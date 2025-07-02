import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/farmer_entity.dart';

/// Service for farmer CRUD operations with Firebase
class FarmerService {
  static const String _collection = 'farmers';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all farmers for a cooperative
  Future<List<FarmerEntity>> getFarmers({required String cooperativeId}) async {
    try {
      final query =
          await _firestore
              .collection(_collection)
              .where('cooperativeId', isEqualTo: cooperativeId)
              .orderBy('name')
              .get();

      return query.docs.map((doc) => FarmerEntity.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load farmers: $e');
    }
  }

  /// Get farmers with real-time updates
  Stream<List<FarmerEntity>> getFarmersStream({required String cooperativeId}) {
    return _firestore
        .collection(_collection)
        .where('cooperativeId', isEqualTo: cooperativeId)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => FarmerEntity.fromFirestore(doc))
                  .toList(),
        );
  }

  /// Get a single farmer by ID
  Future<FarmerEntity?> getFarmer(String farmerId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(farmerId).get();

      if (!doc.exists) {
        return null;
      }

      return FarmerEntity.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to load farmer: $e');
    }
  }

  /// Add a new farmer
  Future<String> addFarmer(FarmerEntity farmer) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(farmer.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add farmer: $e');
    }
  }

  /// Update an existing farmer
  Future<void> updateFarmer(String farmerId, FarmerEntity farmer) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(farmerId)
          .update(
            farmer
                .copyWith(id: farmerId, updatedAt: DateTime.now())
                .toFirestore(),
          );
    } catch (e) {
      throw Exception('Failed to update farmer: $e');
    }
  }

  /// Delete a farmer
  Future<void> deleteFarmer(String farmerId) async {
    try {
      await _firestore.collection(_collection).doc(farmerId).delete();
    } catch (e) {
      throw Exception('Failed to delete farmer: $e');
    }
  }

  /// Batch delete multiple farmers
  Future<void> deleteFarmers(List<String> farmerIds) async {
    try {
      final batch = _firestore.batch();

      for (final farmerId in farmerIds) {
        final docRef = _firestore.collection(_collection).doc(farmerId);
        batch.delete(docRef);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete farmers: $e');
    }
  }

  /// Get farmers by zone
  Future<List<FarmerEntity>> getFarmersByZone({
    required String cooperativeId,
    required String zone,
  }) async {
    try {
      final query =
          await _firestore
              .collection(_collection)
              .where('cooperativeId', isEqualTo: cooperativeId)
              .where('zone', isEqualTo: zone)
              .orderBy('name')
              .get();

      return query.docs.map((doc) => FarmerEntity.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load farmers by zone: $e');
    }
  }

  /// Get farmers by village
  Future<List<FarmerEntity>> getFarmersByVillage({
    required String cooperativeId,
    required String village,
  }) async {
    try {
      final query =
          await _firestore
              .collection(_collection)
              .where('cooperativeId', isEqualTo: cooperativeId)
              .where('village', isEqualTo: village)
              .orderBy('name')
              .get();

      return query.docs.map((doc) => FarmerEntity.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load farmers by village: $e');
    }
  }

  /// Search farmers by name
  Future<List<FarmerEntity>> searchFarmers({
    required String cooperativeId,
    required String searchTerm,
  }) async {
    try {
      // Note: Firestore doesn't support case-insensitive search natively
      // This is a basic implementation - for production, consider using Algolia or similar
      final query =
          await _firestore
              .collection(_collection)
              .where('cooperativeId', isEqualTo: cooperativeId)
              .orderBy('name')
              .get();

      final farmers =
          query.docs
              .map((doc) => FarmerEntity.fromFirestore(doc))
              .where(
                (farmer) =>
                    farmer.name.toLowerCase().contains(
                      searchTerm.toLowerCase(),
                    ) ||
                    farmer.zone.toLowerCase().contains(
                      searchTerm.toLowerCase(),
                    ) ||
                    farmer.village.toLowerCase().contains(
                      searchTerm.toLowerCase(),
                    ) ||
                    (farmer.phone?.contains(searchTerm) ?? false),
              )
              .toList();

      return farmers;
    } catch (e) {
      throw Exception('Failed to search farmers: $e');
    }
  }

  /// Get farmer statistics for a cooperative
  Future<FarmerStatistics> getFarmerStatistics({
    required String cooperativeId,
  }) async {
    try {
      final farmers = await getFarmers(cooperativeId: cooperativeId);

      return FarmerStatistics.fromFarmers(farmers);
    } catch (e) {
      throw Exception('Failed to load farmer statistics: $e');
    }
  }

  /// Get unique zones for a cooperative
  Future<List<String>> getZones({required String cooperativeId}) async {
    try {
      final farmers = await getFarmers(cooperativeId: cooperativeId);
      final zones = farmers.map((f) => f.zone).toSet().toList();
      zones.sort();
      return zones;
    } catch (e) {
      throw Exception('Failed to load zones: $e');
    }
  }

  /// Get unique villages for a cooperative
  Future<List<String>> getVillages({required String cooperativeId}) async {
    try {
      final farmers = await getFarmers(cooperativeId: cooperativeId);
      final villages = farmers.map((f) => f.village).toSet().toList();
      villages.sort();
      return villages;
    } catch (e) {
      throw Exception('Failed to load villages: $e');
    }
  }

  /// Batch add multiple farmers
  Future<void> addFarmers(List<FarmerEntity> farmers) async {
    try {
      final batch = _firestore.batch();

      for (final farmer in farmers) {
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, farmer.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add farmers: $e');
    }
  }

  /// Check if farmer name exists in cooperative
  Future<bool> farmerNameExists({
    required String cooperativeId,
    required String name,
    String? excludeFarmerId,
  }) async {
    try {
      var query = _firestore
          .collection(_collection)
          .where('cooperativeId', isEqualTo: cooperativeId)
          .where('name', isEqualTo: name);

      final result = await query.get();

      if (excludeFarmerId != null) {
        return result.docs.any((doc) => doc.id != excludeFarmerId);
      }

      return result.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check farmer name: $e');
    }
  }
}

/// Statistics model for farmers
class FarmerStatistics {
  final int totalFarmers;
  final int activeFarmers;
  final int pendingFarmers;
  final int suspendedFarmers;
  final int totalZones;
  final int totalVillages;
  final int totalTrees;
  final int totalFruitingTrees;
  final double averageProductivity;
  final int maleFarmers;
  final int femaleFarmers;
  final Map<String, int> farmersByZone;
  final Map<String, int> farmersByStatus;

  const FarmerStatistics({
    required this.totalFarmers,
    required this.activeFarmers,
    required this.pendingFarmers,
    required this.suspendedFarmers,
    required this.totalZones,
    required this.totalVillages,
    required this.totalTrees,
    required this.totalFruitingTrees,
    required this.averageProductivity,
    required this.maleFarmers,
    required this.femaleFarmers,
    required this.farmersByZone,
    required this.farmersByStatus,
  });

  factory FarmerStatistics.fromFarmers(List<FarmerEntity> farmers) {
    final totalFarmers = farmers.length;
    final activeFarmers = farmers.where((f) => f.status == 'Active').length;
    final pendingFarmers = farmers.where((f) => f.status == 'Pending').length;
    final suspendedFarmers =
        farmers.where((f) => f.status == 'Suspended').length;

    final zones = farmers.map((f) => f.zone).toSet();
    final villages = farmers.map((f) => f.village).toSet();

    final totalTrees = farmers.fold<int>(0, (total, f) => total + f.totalTrees);
    final totalFruitingTrees = farmers.fold<int>(
      0,
      (total, f) => total + f.fruitingTrees,
    );

    final averageProductivity =
        totalTrees > 0 ? (totalFruitingTrees / totalTrees) * 100 : 0.0;

    final maleFarmers = farmers.where((f) => f.gender == 'Male').length;
    final femaleFarmers = farmers.where((f) => f.gender == 'Female').length;

    // Group by zone
    final farmersByZone = <String, int>{};
    for (final farmer in farmers) {
      farmersByZone[farmer.zone] = (farmersByZone[farmer.zone] ?? 0) + 1;
    }

    // Group by status
    final farmersByStatus = <String, int>{};
    for (final farmer in farmers) {
      farmersByStatus[farmer.status] =
          (farmersByStatus[farmer.status] ?? 0) + 1;
    }

    return FarmerStatistics(
      totalFarmers: totalFarmers,
      activeFarmers: activeFarmers,
      pendingFarmers: pendingFarmers,
      suspendedFarmers: suspendedFarmers,
      totalZones: zones.length,
      totalVillages: villages.length,
      totalTrees: totalTrees,
      totalFruitingTrees: totalFruitingTrees,
      averageProductivity: averageProductivity,
      maleFarmers: maleFarmers,
      femaleFarmers: femaleFarmers,
      farmersByZone: farmersByZone,
      farmersByStatus: farmersByStatus,
    );
  }
}

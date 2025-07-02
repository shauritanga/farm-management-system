import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/farmer.dart';
import '../../domain/repositories/farmer_repository.dart';
import '../models/farmer_model.dart';

/// Firestore implementation of farmer repository
class FirestoreFarmerRepositoryImpl implements FarmerRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'farmers';

  FirestoreFarmerRepositoryImpl(this._firestore);

  @override
  Future<List<FarmerEntity>> getAllFarmers({String? cooperativeId}) async {
    try {
      Query query = _firestore.collection(_collection);

      // Filter by cooperative ID if provided
      if (cooperativeId != null && cooperativeId.isNotEmpty) {
        query = query.where('cooperativeId', isEqualTo: cooperativeId);
      }

      final querySnapshot =
          await query.orderBy('createdAt', descending: true).get();

      return querySnapshot.docs
          .map((doc) => FarmerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get farmers: $e');
    }
  }

  @override
  Future<FarmerEntity?> getFarmerById(String farmerId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(farmerId).get();

      if (!doc.exists) return null;

      return FarmerModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get farmer: $e');
    }
  }

  @override
  Future<List<FarmerEntity>> searchFarmers(
    FarmerSearchCriteria criteria,
  ) async {
    try {
      Query query = _firestore.collection(_collection);

      // Filter by zone
      if (criteria.zone != null && criteria.zone!.isNotEmpty) {
        query = query.where('zone', isEqualTo: criteria.zone);
      }

      // Filter by village
      if (criteria.village != null && criteria.village!.isNotEmpty) {
        query = query.where('village', isEqualTo: criteria.village);
      }

      // Filter by gender
      if (criteria.gender != null) {
        query = query.where('gender', isEqualTo: criteria.gender!.value);
      }

      final querySnapshot = await query.get();
      List<FarmerEntity> farmers =
          querySnapshot.docs
              .map((doc) => FarmerModel.fromFirestore(doc))
              .toList();

      // Apply additional filters that can't be done in Firestore query
      if (criteria.query != null && criteria.query!.isNotEmpty) {
        final searchQuery = criteria.query!.toLowerCase();
        farmers =
            farmers.where((farmer) {
              return farmer.name.toLowerCase().contains(searchQuery) ||
                  farmer.phone.contains(searchQuery);
            }).toList();
      }

      // Filter by crops (array contains)
      if (criteria.crops != null && criteria.crops!.isNotEmpty) {
        farmers =
            farmers.where((farmer) {
              return criteria.crops!.any(
                (crop) => farmer.crops.any(
                  (farmerCrop) =>
                      farmerCrop.toLowerCase().contains(crop.toLowerCase()),
                ),
              );
            }).toList();
      }

      // Filter by tree count range
      if (criteria.minTrees != null) {
        farmers =
            farmers
                .where((farmer) => farmer.totalTrees >= criteria.minTrees!)
                .toList();
      }

      if (criteria.maxTrees != null) {
        farmers =
            farmers
                .where((farmer) => farmer.totalTrees <= criteria.maxTrees!)
                .toList();
      }

      return farmers;
    } catch (e) {
      throw Exception('Failed to search farmers: $e');
    }
  }

  @override
  Future<FarmerEntity> createFarmer(CreateFarmerData data) async {
    try {
      final now = DateTime.now();
      final farmerData = {
        'cooperativeId': data.cooperativeId,
        'name': data.name,
        'zone': data.zone,
        'village': data.village,
        'gender': data.gender.value,
        'dateOfBirth': Timestamp.fromDate(data.dateOfBirth),
        'phone': data.phone,
        'totalTrees': data.totalTrees,
        'fruitingTrees': data.fruitingTrees,
        'bankNumber': data.bankNumber,
        'bankName': data.bankName,
        'crops': data.crops,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _firestore.collection(_collection).add(farmerData);
      final createdDoc = await docRef.get();

      return FarmerModel.fromFirestore(createdDoc);
    } catch (e) {
      throw Exception('Failed to create farmer: $e');
    }
  }

  @override
  Future<FarmerEntity> updateFarmer(
    String farmerId,
    UpdateFarmerData data,
  ) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      // Only update fields that are provided (non-null)
      if (data.name != null) updateData['name'] = data.name;
      if (data.zone != null) updateData['zone'] = data.zone;
      if (data.village != null) updateData['village'] = data.village;
      if (data.gender != null) updateData['gender'] = data.gender!.value;
      if (data.dateOfBirth != null)
        updateData['dateOfBirth'] = Timestamp.fromDate(data.dateOfBirth!);
      if (data.phone != null) updateData['phone'] = data.phone;
      if (data.totalTrees != null) updateData['totalTrees'] = data.totalTrees;
      if (data.fruitingTrees != null)
        updateData['fruitingTrees'] = data.fruitingTrees;
      if (data.bankNumber != null) updateData['bankNumber'] = data.bankNumber;
      if (data.bankName != null) updateData['bankName'] = data.bankName;
      if (data.crops != null) updateData['crops'] = data.crops;

      await _firestore.collection(_collection).doc(farmerId).update(updateData);

      final updatedDoc =
          await _firestore.collection(_collection).doc(farmerId).get();
      return FarmerModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw Exception('Failed to update farmer: $e');
    }
  }

  @override
  Future<void> deleteFarmer(String farmerId) async {
    try {
      await _firestore.collection(_collection).doc(farmerId).delete();
    } catch (e) {
      throw Exception('Failed to delete farmer: $e');
    }
  }

  @override
  Future<List<FarmerEntity>> getFarmersByZone(String zone) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('zone', isEqualTo: zone)
              .get();

      return querySnapshot.docs
          .map((doc) => FarmerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get farmers by zone: $e');
    }
  }

  @override
  Future<List<FarmerEntity>> getFarmersByVillage(String village) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('village', isEqualTo: village)
              .get();

      return querySnapshot.docs
          .map((doc) => FarmerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get farmers by village: $e');
    }
  }

  @override
  Future<List<FarmerEntity>> getFarmersByCrop(String crop) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('crops', arrayContains: crop)
              .get();

      return querySnapshot.docs
          .map((doc) => FarmerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get farmers by crop: $e');
    }
  }

  @override
  Future<bool> farmerExistsByPhone(String phone) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('phone', isEqualTo: phone)
              .limit(1)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check farmer existence: $e');
    }
  }

  @override
  Future<int> getFarmersCount() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get farmers count: $e');
    }
  }

  // Placeholder implementations for methods that need more complex logic
  @override
  Future<FarmerStatistics> getFarmerStatistics() async {
    // TODO: Implement comprehensive statistics from Firestore
    throw UnimplementedError('Statistics not yet implemented for Firestore');
  }

  @override
  Future<String> exportFarmersData({String? format}) async {
    // TODO: Implement export functionality
    throw UnimplementedError('Export not yet implemented for Firestore');
  }

  @override
  Future<List<FarmerEntity>> importFarmersData(String data) async {
    // TODO: Implement import functionality
    throw UnimplementedError('Import not yet implemented for Firestore');
  }

  @override
  Future<PaginatedFarmers> getFarmersWithPagination({
    int page = 1,
    int limit = 20,
    FarmerSearchCriteria? criteria,
  }) async {
    // TODO: Implement pagination
    throw UnimplementedError('Pagination not yet implemented for Firestore');
  }
}

/// Provider for Firestore farmer repository
final firestoreFarmerRepositoryProvider = Provider<FarmerRepository>((ref) {
  return FirestoreFarmerRepositoryImpl(FirebaseFirestore.instance);
});

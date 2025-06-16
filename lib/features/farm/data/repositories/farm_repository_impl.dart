import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/farm.dart';
import '../../domain/repositories/farm_repository.dart';
import '../models/farm_model.dart';

/// Implementation of FarmRepository using Firestore
class FarmRepositoryImpl implements FarmRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'farms';

  FarmRepositoryImpl(this._firestore);

  @override
  Future<List<FarmEntity>> getFarmsByFarmerId(String farmerId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('farmerId', isEqualTo: farmerId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => FarmModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get farms: $e');
    }
  }

  @override
  Future<FarmEntity?> getFarmById(String farmId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(farmId).get();

      if (!doc.exists) return null;

      return FarmModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get farm: $e');
    }
  }

  @override
  Future<FarmEntity> createFarm(String farmerId, FarmCreationData data) async {
    try {
      final farmModel = FarmModel.fromCreationData(farmerId, data);
      final docRef = await _firestore
          .collection(_collection)
          .add(farmModel.toCreateMap());

      final createdDoc = await docRef.get();
      return FarmModel.fromFirestore(createdDoc);
    } catch (e) {
      throw Exception('Failed to create farm: $e');
    }
  }

  @override
  Future<FarmEntity> updateFarm(String farmId, FarmUpdateData data) async {
    try {
      final updateMap = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (data.name != null) updateMap['name'] = data.name;
      if (data.location != null) updateMap['location'] = data.location;
      if (data.size != null) updateMap['size'] = data.size;
      if (data.cropTypes != null) updateMap['cropTypes'] = data.cropTypes;
      if (data.status != null) updateMap['status'] = data.status!.value;
      if (data.description != null) updateMap['description'] = data.description;
      if (data.coordinates != null) updateMap['coordinates'] = data.coordinates;
      if (data.soilType != null) updateMap['soilType'] = data.soilType;
      if (data.irrigationType != null) {
        updateMap['irrigationType'] = data.irrigationType;
      }

      await _firestore.collection(_collection).doc(farmId).update(updateMap);

      final updatedDoc =
          await _firestore.collection(_collection).doc(farmId).get();
      return FarmModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw Exception('Failed to update farm: $e');
    }
  }

  @override
  Future<void> deleteFarm(String farmId) async {
    try {
      await _firestore.collection(_collection).doc(farmId).delete();
    } catch (e) {
      throw Exception('Failed to delete farm: $e');
    }
  }

  @override
  Future<List<FarmEntity>> searchFarms(String farmerId, String query) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('farmerId', isEqualTo: farmerId)
              .get();

      final farms =
          querySnapshot.docs
              .map((doc) => FarmModel.fromFirestore(doc))
              .toList();

      // Filter by query (name or location)
      final filteredFarms =
          farms.where((farm) {
            final searchQuery = query.toLowerCase();
            return farm.name.toLowerCase().contains(searchQuery) ||
                farm.location.toLowerCase().contains(searchQuery);
          }).toList();

      return filteredFarms;
    } catch (e) {
      throw Exception('Failed to search farms: $e');
    }
  }

  @override
  Future<List<FarmEntity>> getFarmsByStatus(
    String farmerId,
    FarmStatus status,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('farmerId', isEqualTo: farmerId)
              .where('status', isEqualTo: status.value)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => FarmModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get farms by status: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getFarmStatistics(String farmerId) async {
    try {
      final farms = await getFarmsByFarmerId(farmerId);

      final totalFarms = farms.length;
      final totalSize = farms.fold<double>(
        0,
        (total, farm) => total + farm.size,
      );
      final activeFarms =
          farms.where((farm) => farm.status == FarmStatus.active).length;
      final planningFarms =
          farms.where((farm) => farm.status == FarmStatus.planning).length;
      final harvestingFarms =
          farms.where((farm) => farm.status == FarmStatus.harvesting).length;

      // Get unique crop types
      final allCropTypes = <String>{};
      for (final farm in farms) {
        allCropTypes.addAll(farm.cropTypes);
      }

      return {
        'totalFarms': totalFarms,
        'totalSize': totalSize,
        'activeFarms': activeFarms,
        'planningFarms': planningFarms,
        'harvestingFarms': harvestingFarms,
        'uniqueCropTypes': allCropTypes.length,
        'cropTypes': allCropTypes.toList(),
      };
    } catch (e) {
      throw Exception('Failed to get farm statistics: $e');
    }
  }

  @override
  Future<void> updateFarmLastActivity(
    String farmId,
    DateTime lastActivity,
  ) async {
    try {
      await _firestore.collection(_collection).doc(farmId).update({
        'lastActivity': Timestamp.fromDate(lastActivity),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update farm last activity: $e');
    }
  }

  @override
  Future<bool> canCreateFarm(String farmerId) async {
    try {
      // Get user's subscription from users collection
      final userDoc = await _firestore.collection('users').doc(farmerId).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data()!;
      final subscriptionPackage =
          userData['subscriptionPackage'] ?? 'free_tier';

      // Free tier users can only have 1 farm
      if (subscriptionPackage == 'free_tier') {
        final farmCount = await getFarmCount(farmerId);
        return farmCount < 1;
      }

      // Serengeti and Tanzanite users have unlimited farms
      return true;
    } catch (e) {
      throw Exception('Failed to check farm creation limit: $e');
    }
  }

  @override
  Future<int> getFarmCount(String farmerId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('farmerId', isEqualTo: farmerId)
              .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get farm count: $e');
    }
  }
}

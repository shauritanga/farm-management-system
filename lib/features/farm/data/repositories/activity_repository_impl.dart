import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../models/activity_model.dart';

/// Implementation of ActivityRepository using Firestore
class ActivityRepositoryImpl implements ActivityRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'activities';

  ActivityRepositoryImpl(this._firestore);

  @override
  Future<List<ActivityEntity>> getActivitiesByFarmId(String farmId) async {
    try {
      print('Repository: Querying activities for farmId: $farmId'); // Debug
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('farmId', isEqualTo: farmId)
              .orderBy('scheduledDate', descending: false)
              .get();

      print(
        'Repository: Found ${querySnapshot.docs.length} documents',
      ); // Debug
      final activities =
          querySnapshot.docs
              .map((doc) => ActivityModel.fromFirestore(doc))
              .toList();

      print(
        'Repository: Converted to ${activities.length} activities',
      ); // Debug
      return activities;
    } catch (e) {
      print('Repository: Error getting farm activities: $e'); // Debug
      throw Exception('Failed to get farm activities: $e');
    }
  }

  @override
  Future<List<ActivityEntity>> getActivitiesByFarmerId(String farmerId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('farmerId', isEqualTo: farmerId)
              .orderBy('scheduledDate', descending: false)
              .get();

      return querySnapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get farmer activities: $e');
    }
  }

  @override
  Future<ActivityEntity?> getActivityById(String activityId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(activityId).get();

      if (!doc.exists) return null;

      return ActivityModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get activity: $e');
    }
  }

  @override
  Future<ActivityEntity> createActivity(
    String farmerId,
    ActivityCreationData data,
  ) async {
    try {
      final activityModel = ActivityModel.fromCreationData(farmerId, data);
      final docRef = await _firestore
          .collection(_collection)
          .add(activityModel.toCreateMap());

      final createdDoc = await docRef.get();
      return ActivityModel.fromFirestore(createdDoc);
    } catch (e) {
      throw Exception('Failed to create activity: $e');
    }
  }

  @override
  Future<ActivityEntity> updateActivity(
    String activityId,
    ActivityUpdateData data,
  ) async {
    try {
      final updateMap = <String, dynamic>{};

      if (data.type != null) updateMap['type'] = data.type!.value;
      if (data.title != null) updateMap['title'] = data.title!.trim();
      if (data.description != null) {
        updateMap['description'] = data.description!.trim();
      }
      if (data.status != null) updateMap['status'] = data.status!.value;
      if (data.priority != null) updateMap['priority'] = data.priority!.value;
      if (data.scheduledDate != null) {
        updateMap['scheduledDate'] = Timestamp.fromDate(data.scheduledDate!);
      }
      if (data.completedDate != null) {
        updateMap['completedDate'] = Timestamp.fromDate(data.completedDate!);
      }
      if (data.cropType != null) updateMap['cropType'] = data.cropType;
      if (data.quantity != null) updateMap['quantity'] = data.quantity;
      if (data.unit != null) updateMap['unit'] = data.unit;
      if (data.cost != null) updateMap['cost'] = data.cost;
      if (data.currency != null) updateMap['currency'] = data.currency;
      if (data.metadata != null) updateMap['metadata'] = data.metadata;
      if (data.images != null) updateMap['images'] = data.images;
      if (data.notes != null) updateMap['notes'] = data.notes?.trim();

      updateMap['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _firestore
          .collection(_collection)
          .doc(activityId)
          .update(updateMap);

      final updatedDoc =
          await _firestore.collection(_collection).doc(activityId).get();
      return ActivityModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw Exception('Failed to update activity: $e');
    }
  }

  @override
  Future<void> deleteActivity(String activityId) async {
    try {
      await _firestore.collection(_collection).doc(activityId).delete();
    } catch (e) {
      throw Exception('Failed to delete activity: $e');
    }
  }

  @override
  Future<List<ActivityEntity>> getActivitiesByStatus(
    String farmerId,
    ActivityStatus status,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('farmerId', isEqualTo: farmerId)
              .where('status', isEqualTo: status.value)
              .orderBy('scheduledDate', descending: false)
              .get();

      return querySnapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get activities by status: $e');
    }
  }

  @override
  Future<List<ActivityEntity>> getActivitiesByType(
    String farmerId,
    ActivityType type,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('farmerId', isEqualTo: farmerId)
              .where('type', isEqualTo: type.value)
              .orderBy('scheduledDate', descending: false)
              .get();

      return querySnapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get activities by type: $e');
    }
  }

  @override
  Future<List<ActivityEntity>> getUpcomingActivities(String farmerId) async {
    try {
      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));

      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('farmerId', isEqualTo: farmerId)
              .where('status', whereIn: ['planned', 'in_progress'])
              .where(
                'scheduledDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(now),
              )
              .where(
                'scheduledDate',
                isLessThanOrEqualTo: Timestamp.fromDate(nextWeek),
              )
              .orderBy('scheduledDate', descending: false)
              .get();

      return querySnapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get upcoming activities: $e');
    }
  }

  @override
  Future<List<ActivityEntity>> getOverdueActivities(String farmerId) async {
    try {
      final now = DateTime.now();

      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('farmerId', isEqualTo: farmerId)
              .where('status', whereIn: ['planned', 'in_progress'])
              .where('scheduledDate', isLessThan: Timestamp.fromDate(now))
              .orderBy('scheduledDate', descending: false)
              .get();

      return querySnapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get overdue activities: $e');
    }
  }

  @override
  Future<List<ActivityEntity>> getActivitiesByDateRange(
    String farmerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('farmerId', isEqualTo: farmerId)
              .where(
                'scheduledDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where(
                'scheduledDate',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate),
              )
              .orderBy('scheduledDate', descending: false)
              .get();

      return querySnapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get activities by date range: $e');
    }
  }

  @override
  Future<ActivityEntity> completeActivity(
    String activityId, {
    String? notes,
  }) async {
    try {
      final updateData = ActivityUpdateData(
        status: ActivityStatus.completed,
        completedDate: DateTime.now(),
        notes: notes,
      );

      return await updateActivity(activityId, updateData);
    } catch (e) {
      throw Exception('Failed to complete activity: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getActivityStatistics(String farmerId) async {
    try {
      final activities = await getActivitiesByFarmerId(farmerId);

      final total = activities.length;
      final completed = activities.where((a) => a.isCompleted).length;
      final pending =
          activities.where((a) => a.status == ActivityStatus.planned).length;
      final inProgress =
          activities.where((a) => a.status == ActivityStatus.inProgress).length;
      final overdue = activities.where((a) => a.isOverdue).length;

      return {
        'total': total,
        'completed': completed,
        'pending': pending,
        'inProgress': inProgress,
        'overdue': overdue,
        'completionRate': total > 0 ? (completed / total * 100).round() : 0,
      };
    } catch (e) {
      throw Exception('Failed to get activity statistics: $e');
    }
  }

  @override
  Future<List<ActivityEntity>> searchActivities(
    String farmerId,
    String query,
  ) async {
    try {
      final activities = await getActivitiesByFarmerId(farmerId);

      final searchQuery = query.toLowerCase();
      return activities.where((activity) {
        return activity.title.toLowerCase().contains(searchQuery) ||
            activity.description.toLowerCase().contains(searchQuery) ||
            activity.type.displayName.toLowerCase().contains(searchQuery) ||
            (activity.cropType?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search activities: $e');
    }
  }
}

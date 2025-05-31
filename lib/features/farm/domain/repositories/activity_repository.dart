import '../entities/activity.dart';

/// Repository interface for activity management
abstract class ActivityRepository {
  /// Get all activities for a farm
  Future<List<ActivityEntity>> getActivitiesByFarmId(String farmId);

  /// Get all activities for a farmer
  Future<List<ActivityEntity>> getActivitiesByFarmerId(String farmerId);

  /// Get a specific activity by ID
  Future<ActivityEntity?> getActivityById(String activityId);

  /// Create a new activity
  Future<ActivityEntity> createActivity(String farmerId, ActivityCreationData data);

  /// Update an existing activity
  Future<ActivityEntity> updateActivity(String activityId, ActivityUpdateData data);

  /// Delete an activity
  Future<void> deleteActivity(String activityId);

  /// Get activities by status
  Future<List<ActivityEntity>> getActivitiesByStatus(
    String farmerId,
    ActivityStatus status,
  );

  /// Get activities by type
  Future<List<ActivityEntity>> getActivitiesByType(
    String farmerId,
    ActivityType type,
  );

  /// Get upcoming activities (next 7 days)
  Future<List<ActivityEntity>> getUpcomingActivities(String farmerId);

  /// Get overdue activities
  Future<List<ActivityEntity>> getOverdueActivities(String farmerId);

  /// Get activities for a specific date range
  Future<List<ActivityEntity>> getActivitiesByDateRange(
    String farmerId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Mark activity as completed
  Future<ActivityEntity> completeActivity(String activityId, {String? notes});

  /// Get activity statistics
  Future<Map<String, dynamic>> getActivityStatistics(String farmerId);

  /// Search activities
  Future<List<ActivityEntity>> searchActivities(String farmerId, String query);
}

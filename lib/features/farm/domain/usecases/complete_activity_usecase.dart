import '../entities/activity.dart';
import '../repositories/activity_repository.dart';

/// Use case for completing farm activities
class CompleteActivityUsecase {
  final ActivityRepository _activityRepository;

  CompleteActivityUsecase(this._activityRepository);

  /// Mark an activity as completed
  Future<ActivityEntity> call(String activityId, {String? notes}) async {
    try {
      if (activityId.isEmpty) {
        throw Exception('Activity ID cannot be empty');
      }

      // Get the activity first to validate it exists and can be completed
      final activity = await _activityRepository.getActivityById(activityId);
      if (activity == null) {
        throw Exception('Activity not found');
      }

      if (activity.isCompleted) {
        throw Exception('Activity is already completed');
      }

      final completedActivity = await _activityRepository.completeActivity(
        activityId,
        notes: notes,
      );

      return completedActivity;
    } catch (e) {
      throw Exception('Failed to complete activity: ${e.toString()}');
    }
  }

  /// Mark multiple activities as completed
  Future<List<ActivityEntity>> completeMultiple(
    List<String> activityIds, {
    String? notes,
  }) async {
    try {
      if (activityIds.isEmpty) {
        throw Exception('No activities provided');
      }

      final completedActivities = <ActivityEntity>[];
      
      for (final activityId in activityIds) {
        try {
          final completed = await call(activityId, notes: notes);
          completedActivities.add(completed);
        } catch (e) {
          // Continue with other activities if one fails
          print('Failed to complete activity $activityId: $e');
        }
      }

      if (completedActivities.isEmpty) {
        throw Exception('Failed to complete any activities');
      }

      return completedActivities;
    } catch (e) {
      throw Exception('Failed to complete activities: ${e.toString()}');
    }
  }
}

import '../entities/activity.dart';
import '../repositories/activity_repository.dart';

/// Use case for updating farm activities
class UpdateActivityUsecase {
  final ActivityRepository _activityRepository;

  UpdateActivityUsecase(this._activityRepository);

  /// Update an existing activity
  Future<ActivityEntity> call(String activityId, ActivityUpdateData data) async {
    try {
      if (activityId.isEmpty) {
        throw Exception('Activity ID cannot be empty');
      }

      if (!data.hasChanges) {
        throw Exception('No changes provided for update');
      }

      // Validate title if provided
      if (data.title != null && data.title!.trim().isEmpty) {
        throw Exception('Activity title cannot be empty');
      }

      // Validate description if provided
      if (data.description != null && data.description!.trim().isEmpty) {
        throw Exception('Activity description cannot be empty');
      }

      // Validate scheduled date if provided
      if (data.scheduledDate != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final scheduledDay = DateTime(
          data.scheduledDate!.year,
          data.scheduledDate!.month,
          data.scheduledDate!.day,
        );

        if (scheduledDay.isBefore(today)) {
          throw Exception('Scheduled date cannot be in the past');
        }
      }

      // Validate cost if provided
      if (data.cost != null && data.cost! < 0) {
        throw Exception('Cost cannot be negative');
      }

      // Validate quantity if provided
      if (data.quantity != null && data.quantity! < 0) {
        throw Exception('Quantity cannot be negative');
      }

      final activity = await _activityRepository.updateActivity(activityId, data);
      return activity;
    } catch (e) {
      throw Exception('Failed to update activity: ${e.toString()}');
    }
  }
}

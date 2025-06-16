import '../entities/activity.dart';
import '../repositories/activity_repository.dart';

/// Use case for creating farm activities
class CreateActivityUsecase {
  final ActivityRepository _activityRepository;

  CreateActivityUsecase(this._activityRepository);

  /// Create a new activity
  Future<ActivityEntity> call(String farmerId, ActivityCreationData data) async {
    try {
      if (farmerId.isEmpty) {
        throw Exception('Farmer ID cannot be empty');
      }

      if (data.farmId.isEmpty) {
        throw Exception('Farm ID cannot be empty');
      }

      if (data.title.trim().isEmpty) {
        throw Exception('Activity title cannot be empty');
      }

      if (data.description.trim().isEmpty) {
        throw Exception('Activity description cannot be empty');
      }

      // Validate scheduled date is not in the past (allow today)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final scheduledDay = DateTime(
        data.scheduledDate.year,
        data.scheduledDate.month,
        data.scheduledDate.day,
      );

      if (scheduledDay.isBefore(today)) {
        throw Exception('Scheduled date cannot be in the past');
      }

      // Validate cost if provided
      if (data.cost != null && data.cost! < 0) {
        throw Exception('Cost cannot be negative');
      }

      // Validate quantity if provided
      if (data.quantity != null && data.quantity! < 0) {
        throw Exception('Quantity cannot be negative');
      }

      final activity = await _activityRepository.createActivity(farmerId, data);
      return activity;
    } catch (e) {
      throw Exception('Failed to create activity: ${e.toString()}');
    }
  }
}

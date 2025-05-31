import '../entities/activity.dart';
import '../repositories/activity_repository.dart';

/// Use case for getting farm activities
class GetActivitiesUsecase {
  final ActivityRepository _activityRepository;

  GetActivitiesUsecase(this._activityRepository);

  /// Get all activities for a farmer
  Future<List<ActivityEntity>> call(String farmerId) async {
    try {
      if (farmerId.isEmpty) {
        throw Exception('Farmer ID cannot be empty');
      }

      final activities = await _activityRepository.getActivitiesByFarmerId(farmerId);
      
      // Sort activities by scheduled date (most recent first)
      activities.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

      return activities;
    } catch (e) {
      throw Exception('Failed to get activities: ${e.toString()}');
    }
  }

  /// Get activities for a specific farm
  Future<List<ActivityEntity>> getByFarmId(String farmId) async {
    try {
      if (farmId.isEmpty) {
        throw Exception('Farm ID cannot be empty');
      }

      final activities = await _activityRepository.getActivitiesByFarmId(farmId);
      
      // Sort activities by scheduled date (most recent first)
      activities.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

      return activities;
    } catch (e) {
      throw Exception('Failed to get farm activities: ${e.toString()}');
    }
  }

  /// Get upcoming activities (next 7 days)
  Future<List<ActivityEntity>> getUpcoming(String farmerId) async {
    try {
      if (farmerId.isEmpty) {
        throw Exception('Farmer ID cannot be empty');
      }

      return await _activityRepository.getUpcomingActivities(farmerId);
    } catch (e) {
      throw Exception('Failed to get upcoming activities: ${e.toString()}');
    }
  }

  /// Get overdue activities
  Future<List<ActivityEntity>> getOverdue(String farmerId) async {
    try {
      if (farmerId.isEmpty) {
        throw Exception('Farmer ID cannot be empty');
      }

      return await _activityRepository.getOverdueActivities(farmerId);
    } catch (e) {
      throw Exception('Failed to get overdue activities: ${e.toString()}');
    }
  }

  /// Get activities by status
  Future<List<ActivityEntity>> getByStatus(String farmerId, ActivityStatus status) async {
    try {
      if (farmerId.isEmpty) {
        throw Exception('Farmer ID cannot be empty');
      }

      return await _activityRepository.getActivitiesByStatus(farmerId, status);
    } catch (e) {
      throw Exception('Failed to get activities by status: ${e.toString()}');
    }
  }

  /// Get activities by type
  Future<List<ActivityEntity>> getByType(String farmerId, ActivityType type) async {
    try {
      if (farmerId.isEmpty) {
        throw Exception('Farmer ID cannot be empty');
      }

      return await _activityRepository.getActivitiesByType(farmerId, type);
    } catch (e) {
      throw Exception('Failed to get activities by type: ${e.toString()}');
    }
  }

  /// Search activities
  Future<List<ActivityEntity>> search(String farmerId, String query) async {
    try {
      if (farmerId.isEmpty) {
        throw Exception('Farmer ID cannot be empty');
      }

      if (query.trim().isEmpty) {
        return await call(farmerId);
      }

      return await _activityRepository.searchActivities(farmerId, query.trim());
    } catch (e) {
      throw Exception('Failed to search activities: ${e.toString()}');
    }
  }

  /// Get activity statistics
  Future<Map<String, dynamic>> getStatistics(String farmerId) async {
    try {
      if (farmerId.isEmpty) {
        throw Exception('Farmer ID cannot be empty');
      }

      return await _activityRepository.getActivityStatistics(farmerId);
    } catch (e) {
      throw Exception('Failed to get activity statistics: ${e.toString()}');
    }
  }

  /// Get activities for date range
  Future<List<ActivityEntity>> getByDateRange(
    String farmerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (farmerId.isEmpty) {
        throw Exception('Farmer ID cannot be empty');
      }

      if (startDate.isAfter(endDate)) {
        throw Exception('Start date cannot be after end date');
      }

      return await _activityRepository.getActivitiesByDateRange(
        farmerId,
        startDate,
        endDate,
      );
    } catch (e) {
      throw Exception('Failed to get activities by date range: ${e.toString()}');
    }
  }
}

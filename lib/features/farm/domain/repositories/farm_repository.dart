import '../entities/farm.dart';

/// Repository interface for farm management
abstract class FarmRepository {
  /// Get all farms for a farmer
  Future<List<FarmEntity>> getFarmsByFarmerId(String farmerId);

  /// Get a specific farm by ID
  Future<FarmEntity?> getFarmById(String farmId);

  /// Create a new farm
  Future<FarmEntity> createFarm(String farmerId, FarmCreationData data);

  /// Update an existing farm
  Future<FarmEntity> updateFarm(String farmId, FarmUpdateData data);

  /// Delete a farm
  Future<void> deleteFarm(String farmId);

  /// Search farms by name or location
  Future<List<FarmEntity>> searchFarms(String farmerId, String query);

  /// Get farms by status
  Future<List<FarmEntity>> getFarmsByStatus(String farmerId, FarmStatus status);

  /// Get farm statistics
  Future<Map<String, dynamic>> getFarmStatistics(String farmerId);

  /// Update farm last activity
  Future<void> updateFarmLastActivity(String farmId, DateTime lastActivity);

  /// Check if farmer can create more farms (subscription limit)
  Future<bool> canCreateFarm(String farmerId);

  /// Get farm count for farmer
  Future<int> getFarmCount(String farmerId);
}

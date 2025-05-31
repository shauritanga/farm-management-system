import '../entities/farm.dart';
import '../repositories/farm_repository.dart';

/// Use case for getting farmer's farms
class GetFarmsUsecase {
  final FarmRepository _farmRepository;

  GetFarmsUsecase(this._farmRepository);

  /// Get all farms for a farmer
  Future<List<FarmEntity>> call(String farmerId) async {
    try {
      if (farmerId.isEmpty) {
        throw Exception('Farmer ID cannot be empty');
      }

      final farms = await _farmRepository.getFarmsByFarmerId(farmerId);
      
      // Sort farms by last activity (most recent first), then by creation date
      farms.sort((a, b) {
        if (a.lastActivity != null && b.lastActivity != null) {
          return b.lastActivity!.compareTo(a.lastActivity!);
        } else if (a.lastActivity != null) {
          return -1;
        } else if (b.lastActivity != null) {
          return 1;
        } else {
          return b.createdAt.compareTo(a.createdAt);
        }
      });

      return farms;
    } catch (e) {
      throw Exception('Failed to get farms: ${e.toString()}');
    }
  }

  /// Get farms by status
  Future<List<FarmEntity>> getByStatus(String farmerId, FarmStatus status) async {
    try {
      if (farmerId.isEmpty) {
        throw Exception('Farmer ID cannot be empty');
      }

      return await _farmRepository.getFarmsByStatus(farmerId, status);
    } catch (e) {
      throw Exception('Failed to get farms by status: ${e.toString()}');
    }
  }

  /// Search farms
  Future<List<FarmEntity>> search(String farmerId, String query) async {
    try {
      if (farmerId.isEmpty) {
        throw Exception('Farmer ID cannot be empty');
      }

      if (query.trim().isEmpty) {
        return await call(farmerId);
      }

      return await _farmRepository.searchFarms(farmerId, query.trim());
    } catch (e) {
      throw Exception('Failed to search farms: ${e.toString()}');
    }
  }

  /// Get farm statistics
  Future<Map<String, dynamic>> getStatistics(String farmerId) async {
    try {
      if (farmerId.isEmpty) {
        throw Exception('Farmer ID cannot be empty');
      }

      return await _farmRepository.getFarmStatistics(farmerId);
    } catch (e) {
      throw Exception('Failed to get farm statistics: ${e.toString()}');
    }
  }
}

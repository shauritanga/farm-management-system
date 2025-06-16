import '../entities/farmer.dart';

/// Repository interface for farmer management
abstract class FarmerRepository {
  /// Get all farmers for a cooperative
  Future<List<FarmerEntity>> getAllFarmers({String? cooperativeId});

  /// Get farmer by ID
  Future<FarmerEntity?> getFarmerById(String farmerId);

  /// Search farmers with criteria
  Future<List<FarmerEntity>> searchFarmers(FarmerSearchCriteria criteria);

  /// Create a new farmer
  Future<FarmerEntity> createFarmer(CreateFarmerData data);

  /// Update an existing farmer
  Future<FarmerEntity> updateFarmer(String farmerId, UpdateFarmerData data);

  /// Delete a farmer
  Future<void> deleteFarmer(String farmerId);

  /// Get farmers by zone
  Future<List<FarmerEntity>> getFarmersByZone(String zone);

  /// Get farmers by village
  Future<List<FarmerEntity>> getFarmersByVillage(String village);

  /// Get farmers by crop type
  Future<List<FarmerEntity>> getFarmersByCrop(String crop);

  /// Get farmer statistics
  Future<FarmerStatistics> getFarmerStatistics();

  /// Export farmers data
  Future<String> exportFarmersData({String? format});

  /// Import farmers data
  Future<List<FarmerEntity>> importFarmersData(String data);

  /// Check if farmer exists by phone
  Future<bool> farmerExistsByPhone(String phone);

  /// Get farmers count
  Future<int> getFarmersCount();

  /// Get farmers with pagination
  Future<PaginatedFarmers> getFarmersWithPagination({
    int page = 1,
    int limit = 20,
    FarmerSearchCriteria? criteria,
  });
}

/// Farmer statistics data
class FarmerStatistics {
  final int totalFarmers;
  final int maleCount;
  final int femaleCount;
  final int totalTrees;
  final int totalFruitingTrees;
  final double averageTreesPerFarmer;
  final double averageFruitingPercentage;
  final Map<String, int> farmersByZone;
  final Map<String, int> farmersByVillage;
  final Map<String, int> farmersByCrop;
  final Map<String, int> farmersByBank;

  const FarmerStatistics({
    required this.totalFarmers,
    required this.maleCount,
    required this.femaleCount,
    required this.totalTrees,
    required this.totalFruitingTrees,
    required this.averageTreesPerFarmer,
    required this.averageFruitingPercentage,
    required this.farmersByZone,
    required this.farmersByVillage,
    required this.farmersByCrop,
    required this.farmersByBank,
  });
}

/// Paginated farmers result
class PaginatedFarmers {
  final List<FarmerEntity> farmers;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedFarmers({
    required this.farmers,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}

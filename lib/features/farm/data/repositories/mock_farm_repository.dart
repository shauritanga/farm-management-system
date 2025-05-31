import '../../domain/entities/farm.dart';
import '../../domain/repositories/farm_repository.dart';

/// Mock implementation of FarmRepository for testing and development
class MockFarmRepository implements FarmRepository {
  // Generate sample farm data for any farmer ID
  List<FarmEntity> _generateSampleFarms(String farmerId) {
    return [
      FarmEntity(
        id: '1',
        farmerId: farmerId,
        name: 'Green Valley Farm',
        location: 'Morogoro, Tanzania',
        size: 5.2,
        cropTypes: ['Maize', 'Beans', 'Tomatoes'],
        status: FarmStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
        description:
            'A productive farm specializing in staple crops and vegetables',
        soilType: 'Loamy',
        irrigationType: 'Drip irrigation',
        assignedUsers: [], // No assigned users for this farm
      ),
      FarmEntity(
        id: '2',
        farmerId: farmerId,
        name: 'Sunrise Agricultural Plot',
        location: 'Arusha, Tanzania',
        size: 3.8,
        cropTypes: ['Rice', 'Sunflower'],
        status: FarmStatus.planning,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastActivity: DateTime.now().subtract(const Duration(days: 3)),
        description: 'New farm plot under development for grain production',
        soilType: 'Clay',
        irrigationType: 'Flood irrigation',
        assignedUsers: [
          'user_monitor_1',
        ], // One assigned monitor (Tanzanite feature demo)
      ),
      FarmEntity(
        id: '3',
        farmerId: farmerId,
        name: 'Highland Coffee Estate',
        location: 'Kilimanjaro, Tanzania',
        size: 12.5,
        cropTypes: ['Coffee', 'Banana'],
        status: FarmStatus.harvesting,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        lastActivity: DateTime.now().subtract(const Duration(hours: 6)),
        description: 'Premium coffee plantation with intercropped bananas',
        soilType: 'Volcanic',
        irrigationType: 'Rain-fed',
        assignedUsers: [
          'user_monitor_1',
          'user_monitor_2',
        ], // Multiple monitors (Tanzanite feature demo)
      ),
      FarmEntity(
        id: '4',
        farmerId: farmerId,
        name: 'Coastal Coconut Grove',
        location: 'Dar es Salaam, Tanzania',
        size: 8.0,
        cropTypes: ['Coconut', 'Cassava', 'Sweet Potato'],
        status: FarmStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        lastActivity: DateTime.now().subtract(const Duration(days: 1)),
        description:
            'Coastal farm focusing on coconut production and root crops',
        soilType: 'Sandy',
        irrigationType: 'Manual watering',
        assignedUsers: [], // No assigned users
      ),
      FarmEntity(
        id: '5',
        farmerId: farmerId,
        name: 'Organic Vegetable Garden',
        location: 'Mbeya, Tanzania',
        size: 2.1,
        cropTypes: ['Cabbage', 'Carrots', 'Onions', 'Spinach'],
        status: FarmStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        lastActivity: DateTime.now().subtract(const Duration(hours: 12)),
        description:
            'Small-scale organic vegetable production for local markets',
        soilType: 'Loamy',
        irrigationType: 'Sprinkler irrigation',
        assignedUsers: ['user_monitor_2'], // One assigned monitor
      ),
      FarmEntity(
        id: '6',
        farmerId: farmerId,
        name: 'Experimental Research Plot',
        location: 'Dodoma, Tanzania',
        size: 1.5,
        cropTypes: ['Sorghum', 'Millet'],
        status: FarmStatus.maintenance,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        lastActivity: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Testing drought-resistant crops for arid regions',
        soilType: 'Sandy',
        irrigationType: 'Rain-fed',
        assignedUsers: [], // No assigned users
      ),
    ];
  }

  // Cache for generated farms per farmer
  final Map<String, List<FarmEntity>> _farmsCache = {};

  // Helper method to get all farms across all farmers
  List<FarmEntity> _getAllFarms() {
    final allFarms = <FarmEntity>[];
    for (final farms in _farmsCache.values) {
      allFarms.addAll(farms);
    }
    return allFarms;
  }

  // Helper method to get farms for a specific farmer
  List<FarmEntity> _getFarmsForFarmer(String farmerId) {
    if (!_farmsCache.containsKey(farmerId)) {
      _farmsCache[farmerId] = _generateSampleFarms(farmerId);
    }
    return _farmsCache[farmerId]!;
  }

  @override
  Future<List<FarmEntity>> getFarmsByFarmerId(String farmerId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate or get cached farms for this farmer
    if (!_farmsCache.containsKey(farmerId)) {
      _farmsCache[farmerId] = _generateSampleFarms(farmerId);
    }

    return List.from(_farmsCache[farmerId]!);
  }

  @override
  Future<FarmEntity?> getFarmById(String farmId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _getAllFarms().firstWhere((farm) => farm.id == farmId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<FarmEntity> createFarm(String farmerId, FarmCreationData data) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final newFarm = FarmEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      farmerId: farmerId,
      name: data.name,
      location: data.location,
      size: data.size,
      cropTypes: data.cropTypes,
      status: FarmStatus.active,
      createdAt: DateTime.now(),
      description: data.description,
      coordinates: data.coordinates,
      soilType: data.soilType,
      irrigationType: data.irrigationType,
    );

    _getFarmsForFarmer(farmerId).add(newFarm);
    return newFarm;
  }

  @override
  Future<FarmEntity> updateFarm(String farmId, FarmUpdateData data) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Find the farm across all farmers
    for (final farms in _farmsCache.values) {
      final farmIndex = farms.indexWhere((farm) => farm.id == farmId);
      if (farmIndex != -1) {
        final existingFarm = farms[farmIndex];
        final updatedFarm = existingFarm.copyWith(
          name: data.name,
          location: data.location,
          size: data.size,
          cropTypes: data.cropTypes,
          status: data.status,
          description: data.description,
          coordinates: data.coordinates,
          soilType: data.soilType,
          irrigationType: data.irrigationType,
          updatedAt: DateTime.now(),
        );

        farms[farmIndex] = updatedFarm;
        return updatedFarm;
      }
    }

    throw Exception('Farm not found');
  }

  @override
  Future<void> deleteFarm(String farmId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Remove farm from all farmer caches
    for (final farms in _farmsCache.values) {
      farms.removeWhere((farm) => farm.id == farmId);
    }
  }

  @override
  Future<List<FarmEntity>> searchFarms(String farmerId, String query) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final farmerFarms = _getFarmsForFarmer(farmerId);
    final searchQuery = query.toLowerCase();

    return farmerFarms.where((farm) {
      return farm.name.toLowerCase().contains(searchQuery) ||
          farm.location.toLowerCase().contains(searchQuery) ||
          farm.cropTypes.any(
            (crop) => crop.toLowerCase().contains(searchQuery),
          );
    }).toList();
  }

  @override
  Future<List<FarmEntity>> getFarmsByStatus(
    String farmerId,
    FarmStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return _getFarmsForFarmer(
      farmerId,
    ).where((farm) => farm.status == status).toList();
  }

  @override
  Future<Map<String, dynamic>> getFarmStatistics(String farmerId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final farmerFarms = _getFarmsForFarmer(farmerId);

    final totalFarms = farmerFarms.length;
    final totalSize = farmerFarms.fold<double>(
      0,
      (sum, farm) => sum + farm.size,
    );
    final activeFarms =
        farmerFarms.where((farm) => farm.status == FarmStatus.active).length;
    final planningFarms =
        farmerFarms.where((farm) => farm.status == FarmStatus.planning).length;
    final harvestingFarms =
        farmerFarms
            .where((farm) => farm.status == FarmStatus.harvesting)
            .length;

    // Get unique crop types
    final allCropTypes = <String>{};
    for (final farm in farmerFarms) {
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
  }

  @override
  Future<void> updateFarmLastActivity(
    String farmId,
    DateTime lastActivity,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Find and update the farm across all farmer caches
    for (final farms in _farmsCache.values) {
      final farmIndex = farms.indexWhere((farm) => farm.id == farmId);
      if (farmIndex != -1) {
        farms[farmIndex] = farms[farmIndex].copyWith(
          lastActivity: lastActivity,
          updatedAt: DateTime.now(),
        );
        return;
      }
    }
  }

  @override
  Future<bool> canCreateFarm(String farmerId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // For mock purposes, assume free tier users can only have 1 farm
    // This would normally check the user's subscription from the database
    final farmCount = await getFarmCount(farmerId);
    return farmCount < 1; // Simulate free tier limit
  }

  @override
  Future<int> getFarmCount(String farmerId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _getFarmsForFarmer(farmerId).length;
  }
}

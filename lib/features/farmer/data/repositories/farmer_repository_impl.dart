import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/farmer.dart';
import '../../domain/repositories/farmer_repository.dart';
import '../models/farmer_model.dart';
import '../../../../core/utils/data.dart' as mock_data;

/// Implementation of farmer repository
class FarmerRepositoryImpl implements FarmerRepository {
  // Mock data storage - replace with actual API/database calls
  static List<FarmerModel> _farmers = [];
  static bool _isInitialized = false;

  /// Initialize with mock data from core/utils/data.dart
  void _initializeMockData() {
    if (_isInitialized) return;

    // Convert mock data from core/utils/data.dart and add cooperative_id
    // All farmers belong to the same cooperative
    _farmers =
        mock_data.farmers.map((farmerJson) {
          // Create a copy of the farmer data and add cooperative_id
          final Map<String, dynamic> farmerWithCoopId = Map.from(farmerJson);

          // All farmers belong to the same cooperative
          farmerWithCoopId['cooperative_id'] = 'coop_001';

          // Handle null values for phone and bank_number
          if (farmerWithCoopId['phone'] == null) {
            farmerWithCoopId['phone'] = '';
          }
          if (farmerWithCoopId['bank_number'] == null) {
            farmerWithCoopId['bank_number'] = '';
          }

          return FarmerModel.fromJson(farmerWithCoopId);
        }).toList();

    _isInitialized = true;
  }

  @override
  Future<List<FarmerEntity>> getAllFarmers({String? cooperativeId}) async {
    _initializeMockData();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    var filteredFarmers = _farmers;

    // Filter by cooperative ID if provided
    if (cooperativeId != null) {
      filteredFarmers =
          _farmers.where((f) => f.cooperativeId == cooperativeId).toList();
    }

    return filteredFarmers.map((model) => model.toEntity()).toList();
  }

  @override
  Future<FarmerEntity?> getFarmerById(String farmerId) async {
    _initializeMockData();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final farmer = _farmers.firstWhere((f) => f.id == farmerId);
      return farmer.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<FarmerEntity>> searchFarmers(
    FarmerSearchCriteria criteria,
  ) async {
    _initializeMockData();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    var filteredFarmers =
        _farmers.where((farmer) {
          // Search by query (name, zone, village, phone)
          if (criteria.query != null && criteria.query!.isNotEmpty) {
            final query = criteria.query!.toLowerCase();
            final matchesQuery =
                farmer.name.toLowerCase().contains(query) ||
                farmer.zone.toLowerCase().contains(query) ||
                farmer.village.toLowerCase().contains(query) ||
                farmer.phone.contains(query);
            if (!matchesQuery) return false;
          }

          // Filter by zone
          if (criteria.zone != null && criteria.zone!.isNotEmpty) {
            if (farmer.zone.toLowerCase() != criteria.zone!.toLowerCase()) {
              return false;
            }
          }

          // Filter by village
          if (criteria.village != null && criteria.village!.isNotEmpty) {
            if (farmer.village.toLowerCase() !=
                criteria.village!.toLowerCase()) {
              return false;
            }
          }

          // Filter by gender
          if (criteria.gender != null) {
            if (farmer.gender != criteria.gender) {
              return false;
            }
          }

          // Filter by crops
          if (criteria.crops != null && criteria.crops!.isNotEmpty) {
            final hasMatchingCrop = criteria.crops!.any(
              (crop) => farmer.crops.any(
                (farmerCrop) =>
                    farmerCrop.toLowerCase().contains(crop.toLowerCase()),
              ),
            );
            if (!hasMatchingCrop) return false;
          }

          // Filter by tree count range
          if (criteria.minTrees != null &&
              farmer.totalNumberOfTrees < criteria.minTrees!) {
            return false;
          }

          if (criteria.maxTrees != null &&
              farmer.totalNumberOfTrees > criteria.maxTrees!) {
            return false;
          }

          return true;
        }).toList();

    return filteredFarmers.map((model) => model.toEntity()).toList();
  }

  @override
  Future<FarmerEntity> createFarmer(CreateFarmerData data) async {
    _initializeMockData();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));

    final newId = (DateTime.now().millisecondsSinceEpoch).toString();
    final now = DateTime.now();

    final newFarmer = FarmerModel(
      id: newId,
      cooperativeId: data.cooperativeId,
      name: data.name,
      zone: data.zone,
      village: data.village,
      gender: data.gender,
      dateOfBirth: data.dateOfBirth,
      phone: data.phone,
      totalNumberOfTrees: data.totalNumberOfTrees,
      totalNumberOfTreesWithFruit: data.totalNumberOfTreesWithFruit,
      bankNumber: data.bankNumber,
      bankName: data.bankName,
      crops: data.crops,
      createdAt: now,
      updatedAt: now,
    );

    _farmers.add(newFarmer);
    return newFarmer.toEntity();
  }

  @override
  Future<FarmerEntity> updateFarmer(
    String farmerId,
    UpdateFarmerData data,
  ) async {
    _initializeMockData();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _farmers.indexWhere((f) => f.id == farmerId);
    if (index == -1) {
      throw Exception('Farmer not found');
    }

    final existingFarmer = _farmers[index];
    final updatedFarmer = existingFarmer.copyWith(
      name: data.name,
      zone: data.zone,
      village: data.village,
      gender: data.gender,
      dateOfBirth: data.dateOfBirth,
      phone: data.phone,
      totalNumberOfTrees: data.totalNumberOfTrees,
      totalNumberOfTreesWithFruit: data.totalNumberOfTreesWithFruit,
      bankNumber: data.bankNumber,
      bankName: data.bankName,
      crops: data.crops,
      updatedAt: DateTime.now(),
    );

    _farmers[index] = updatedFarmer;
    return updatedFarmer.toEntity();
  }

  @override
  Future<void> deleteFarmer(String farmerId) async {
    _initializeMockData();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    _farmers.removeWhere((f) => f.id == farmerId);
  }

  @override
  Future<List<FarmerEntity>> getFarmersByZone(String zone) async {
    _initializeMockData();
    await Future.delayed(const Duration(milliseconds: 400));

    final filteredFarmers =
        _farmers
            .where((f) => f.zone.toLowerCase() == zone.toLowerCase())
            .toList();

    return filteredFarmers.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<FarmerEntity>> getFarmersByVillage(String village) async {
    _initializeMockData();
    await Future.delayed(const Duration(milliseconds: 400));

    final filteredFarmers =
        _farmers
            .where((f) => f.village.toLowerCase() == village.toLowerCase())
            .toList();

    return filteredFarmers.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<FarmerEntity>> getFarmersByCrop(String crop) async {
    _initializeMockData();
    await Future.delayed(const Duration(milliseconds: 400));

    final filteredFarmers =
        _farmers
            .where(
              (f) => f.crops.any(
                (c) => c.toLowerCase().contains(crop.toLowerCase()),
              ),
            )
            .toList();

    return filteredFarmers.map((model) => model.toEntity()).toList();
  }

  @override
  Future<FarmerStatistics> getFarmerStatistics() async {
    _initializeMockData();
    await Future.delayed(const Duration(milliseconds: 600));

    final totalFarmers = _farmers.length;
    final maleCount = _farmers.where((f) => f.gender == Gender.male).length;
    final femaleCount = _farmers.where((f) => f.gender == Gender.female).length;
    final totalTrees = _farmers.fold<int>(
      0,
      (sum, f) => sum + f.totalNumberOfTrees,
    );
    final totalFruitingTrees = _farmers.fold<int>(
      0,
      (sum, f) => sum + f.totalNumberOfTreesWithFruit,
    );

    final averageTreesPerFarmer =
        totalFarmers > 0 ? totalTrees / totalFarmers : 0.0;
    final averageFruitingPercentage =
        totalTrees > 0 ? (totalFruitingTrees / totalTrees) * 100 : 0.0;

    // Group by zone
    final farmersByZone = <String, int>{};
    for (final farmer in _farmers) {
      farmersByZone[farmer.zone] = (farmersByZone[farmer.zone] ?? 0) + 1;
    }

    // Group by village
    final farmersByVillage = <String, int>{};
    for (final farmer in _farmers) {
      farmersByVillage[farmer.village] =
          (farmersByVillage[farmer.village] ?? 0) + 1;
    }

    // Group by crop
    final farmersByCrop = <String, int>{};
    for (final farmer in _farmers) {
      for (final crop in farmer.crops) {
        farmersByCrop[crop] = (farmersByCrop[crop] ?? 0) + 1;
      }
    }

    // Group by bank
    final farmersByBank = <String, int>{};
    for (final farmer in _farmers) {
      farmersByBank[farmer.bankName] =
          (farmersByBank[farmer.bankName] ?? 0) + 1;
    }

    return FarmerStatistics(
      totalFarmers: totalFarmers,
      maleCount: maleCount,
      femaleCount: femaleCount,
      totalTrees: totalTrees,
      totalFruitingTrees: totalFruitingTrees,
      averageTreesPerFarmer: averageTreesPerFarmer,
      averageFruitingPercentage: averageFruitingPercentage,
      farmersByZone: farmersByZone,
      farmersByVillage: farmersByVillage,
      farmersByCrop: farmersByCrop,
      farmersByBank: farmersByBank,
    );
  }

  @override
  Future<String> exportFarmersData({String? format}) async {
    _initializeMockData();
    await Future.delayed(const Duration(milliseconds: 1000));

    // Mock export - return CSV format
    final buffer = StringBuffer();
    buffer.writeln(
      'ID,Name,Zone,Village,Gender,Date of Birth,Phone,Total Trees,Fruiting Trees,Bank Number,Bank Name,Crops',
    );

    for (final farmer in _farmers) {
      buffer.writeln(
        '${farmer.id},${farmer.name},${farmer.zone},${farmer.village},${farmer.gender.value},${farmer.dateOfBirth.toIso8601String()},${farmer.phone},${farmer.totalNumberOfTrees},${farmer.totalNumberOfTreesWithFruit},${farmer.bankNumber},${farmer.bankName},"${farmer.crops.join(', ')}"',
      );
    }

    return buffer.toString();
  }

  @override
  Future<List<FarmerEntity>> importFarmersData(String data) async {
    // Mock import functionality
    await Future.delayed(const Duration(milliseconds: 1500));
    throw UnimplementedError('Import functionality not yet implemented');
  }

  @override
  Future<bool> farmerExistsByPhone(String phone) async {
    _initializeMockData();
    await Future.delayed(const Duration(milliseconds: 200));

    return _farmers.any((f) => f.phone == phone);
  }

  @override
  Future<int> getFarmersCount() async {
    _initializeMockData();
    await Future.delayed(const Duration(milliseconds: 100));

    return _farmers.length;
  }

  @override
  Future<PaginatedFarmers> getFarmersWithPagination({
    int page = 1,
    int limit = 20,
    FarmerSearchCriteria? criteria,
  }) async {
    _initializeMockData();
    await Future.delayed(const Duration(milliseconds: 600));

    List<FarmerModel> filteredFarmers = _farmers;

    // Apply search criteria if provided
    if (criteria != null) {
      filteredFarmers =
          _farmers.where((farmer) {
            // Apply same filtering logic as searchFarmers
            if (criteria.query != null && criteria.query!.isNotEmpty) {
              final query = criteria.query!.toLowerCase();
              final matchesQuery =
                  farmer.name.toLowerCase().contains(query) ||
                  farmer.zone.toLowerCase().contains(query) ||
                  farmer.village.toLowerCase().contains(query) ||
                  farmer.phone.contains(query);
              if (!matchesQuery) return false;
            }
            return true;
          }).toList();
    }

    final totalCount = filteredFarmers.length;
    final totalPages = (totalCount / limit).ceil();
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, totalCount);

    final paginatedFarmers = filteredFarmers.sublist(
      startIndex.clamp(0, totalCount),
      endIndex,
    );

    return PaginatedFarmers(
      farmers: paginatedFarmers.map((model) => model.toEntity()).toList(),
      currentPage: page,
      totalPages: totalPages,
      totalCount: totalCount,
      hasNextPage: page < totalPages,
      hasPreviousPage: page > 1,
    );
  }
}

// Provider for farmer repository
final farmerRepositoryProvider = Provider<FarmerRepository>((ref) {
  return FarmerRepositoryImpl();
});

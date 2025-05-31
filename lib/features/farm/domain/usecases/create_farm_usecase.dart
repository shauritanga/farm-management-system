import '../entities/farm.dart';
import '../repositories/farm_repository.dart';
import '../../../subscription/domain/entities/subscription.dart';

/// Use case for creating a new farm
class CreateFarmUsecase {
  final FarmRepository _farmRepository;

  CreateFarmUsecase(this._farmRepository);

  /// Create a new farm
  Future<FarmEntity> call({
    required String farmerId,
    required String name,
    required String location,
    required double size,
    required List<String> cropTypes,
    required SubscriptionPackage userSubscription,
    String? description,
    Map<String, dynamic>? coordinates,
    String? soilType,
    String? irrigationType,
  }) async {
    try {
      // Validate input
      _validateInput(
        farmerId: farmerId,
        name: name,
        location: location,
        size: size,
        cropTypes: cropTypes,
      );

      // Check subscription limits
      await _checkSubscriptionLimits(farmerId, userSubscription);

      // Create farm data
      final farmData = FarmCreationData(
        name: name.trim(),
        location: location.trim(),
        size: size,
        cropTypes: cropTypes.map((crop) => crop.trim()).toList(),
        description: description?.trim(),
        coordinates: coordinates,
        soilType: soilType?.trim(),
        irrigationType: irrigationType?.trim(),
      );

      // Create the farm
      final farm = await _farmRepository.createFarm(farmerId, farmData);

      return farm;
    } catch (e) {
      throw Exception('Failed to create farm: ${e.toString()}');
    }
  }

  /// Validate input data
  void _validateInput({
    required String farmerId,
    required String name,
    required String location,
    required double size,
    required List<String> cropTypes,
  }) {
    if (farmerId.isEmpty) {
      throw Exception('Farmer ID cannot be empty');
    }

    if (name.trim().isEmpty) {
      throw Exception('Farm name cannot be empty');
    }

    if (name.trim().length < 2) {
      throw Exception('Farm name must be at least 2 characters long');
    }

    if (name.trim().length > 100) {
      throw Exception('Farm name cannot exceed 100 characters');
    }

    if (location.trim().isEmpty) {
      throw Exception('Farm location cannot be empty');
    }

    if (location.trim().length < 2) {
      throw Exception('Farm location must be at least 2 characters long');
    }

    if (location.trim().length > 200) {
      throw Exception('Farm location cannot exceed 200 characters');
    }

    if (size <= 0) {
      throw Exception('Farm size must be greater than 0');
    }

    if (size > 10000) {
      throw Exception('Farm size cannot exceed 10,000 hectares');
    }

    if (cropTypes.isEmpty) {
      throw Exception('At least one crop type must be specified');
    }

    if (cropTypes.length > 20) {
      throw Exception('Cannot specify more than 20 crop types');
    }

    for (final crop in cropTypes) {
      if (crop.trim().isEmpty) {
        throw Exception('Crop type cannot be empty');
      }
      if (crop.trim().length > 50) {
        throw Exception('Crop type cannot exceed 50 characters');
      }
    }
  }

  /// Check subscription limits
  Future<void> _checkSubscriptionLimits(
    String farmerId,
    SubscriptionPackage subscription,
  ) async {
    // Free tier users can only have 1 farm
    if (subscription == SubscriptionPackage.freeTier) {
      final canCreate = await _farmRepository.canCreateFarm(farmerId);
      if (!canCreate) {
        throw Exception(
          'Free tier users can only create 1 farm. Upgrade to Serengeti or Tanzanite package to create unlimited farms.',
        );
      }
    }
    // Serengeti and Tanzanite users have unlimited farms
  }
}

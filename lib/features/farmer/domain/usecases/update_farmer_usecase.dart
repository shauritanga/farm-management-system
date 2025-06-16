import '../entities/farmer.dart';
import '../repositories/farmer_repository.dart';

/// Use case for updating an existing farmer
class UpdateFarmerUsecase {
  final FarmerRepository _repository;

  UpdateFarmerUsecase(this._repository);

  /// Execute the use case
  Future<FarmerEntity> call(String farmerId, UpdateFarmerData data) async {
    try {
      // Validate farmer exists
      final existingFarmer = await _repository.getFarmerById(farmerId);
      if (existingFarmer == null) {
        throw Exception('Farmer not found');
      }

      // Validate update data
      _validateUpdateData(data, existingFarmer);

      return await _repository.updateFarmer(farmerId, data);
    } catch (e) {
      throw Exception('Failed to update farmer: $e');
    }
  }

  /// Validate update data
  void _validateUpdateData(UpdateFarmerData data, FarmerEntity existingFarmer) {
    if (data.name != null && data.name!.trim().isEmpty) {
      throw Exception('Farmer name cannot be empty');
    }

    if (data.zone != null && data.zone!.trim().isEmpty) {
      throw Exception('Zone cannot be empty');
    }

    if (data.village != null && data.village!.trim().isEmpty) {
      throw Exception('Village cannot be empty');
    }

    if (data.phone != null) {
      if (data.phone!.trim().isEmpty) {
        throw Exception('Phone number cannot be empty');
      }
      
      // Validate phone number format
      if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(data.phone!)) {
        throw Exception('Invalid phone number format');
      }
    }

    if (data.totalNumberOfTrees != null && data.totalNumberOfTrees! < 0) {
      throw Exception('Total number of trees cannot be negative');
    }

    if (data.totalNumberOfTreesWithFruit != null && data.totalNumberOfTreesWithFruit! < 0) {
      throw Exception('Number of fruiting trees cannot be negative');
    }

    // Check fruiting trees vs total trees
    final totalTrees = data.totalNumberOfTrees ?? existingFarmer.totalNumberOfTrees;
    final fruitingTrees = data.totalNumberOfTreesWithFruit ?? existingFarmer.totalNumberOfTreesWithFruit;
    
    if (fruitingTrees > totalTrees) {
      throw Exception('Fruiting trees cannot exceed total trees');
    }

    if (data.crops != null && data.crops!.isEmpty) {
      throw Exception('At least one crop type is required');
    }

    // Validate date of birth if provided
    if (data.dateOfBirth != null) {
      final now = DateTime.now();
      final age = now.year - data.dateOfBirth!.year;
      if (age < 18 || age > 100) {
        throw Exception('Farmer age must be between 18 and 100 years');
      }
    }
  }
}

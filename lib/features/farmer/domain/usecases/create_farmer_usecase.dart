import '../entities/farmer.dart';
import '../repositories/farmer_repository.dart';

/// Use case for creating a new farmer
class CreateFarmerUsecase {
  final FarmerRepository _repository;

  CreateFarmerUsecase(this._repository);

  /// Execute the use case
  Future<FarmerEntity> call(CreateFarmerData data) async {
    try {
      // Validate data
      _validateFarmerData(data);
      
      // Check if farmer already exists by phone
      final exists = await _repository.farmerExistsByPhone(data.phone);
      if (exists) {
        throw Exception('A farmer with this phone number already exists');
      }

      return await _repository.createFarmer(data);
    } catch (e) {
      throw Exception('Failed to create farmer: $e');
    }
  }

  /// Validate farmer data
  void _validateFarmerData(CreateFarmerData data) {
    if (data.name.trim().isEmpty) {
      throw Exception('Farmer name is required');
    }

    if (data.zone.trim().isEmpty) {
      throw Exception('Zone is required');
    }

    if (data.village.trim().isEmpty) {
      throw Exception('Village is required');
    }

    if (data.phone.trim().isEmpty) {
      throw Exception('Phone number is required');
    }

    // Validate phone number format (basic validation)
    if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(data.phone)) {
      throw Exception('Invalid phone number format');
    }

    if (data.totalNumberOfTrees < 0) {
      throw Exception('Total number of trees cannot be negative');
    }

    if (data.totalNumberOfTreesWithFruit < 0) {
      throw Exception('Number of fruiting trees cannot be negative');
    }

    if (data.totalNumberOfTreesWithFruit > data.totalNumberOfTrees) {
      throw Exception('Fruiting trees cannot exceed total trees');
    }

    if (data.crops.isEmpty) {
      throw Exception('At least one crop type is required');
    }

    // Validate date of birth
    final now = DateTime.now();
    final age = now.year - data.dateOfBirth.year;
    if (age < 18 || age > 100) {
      throw Exception('Farmer age must be between 18 and 100 years');
    }
  }
}

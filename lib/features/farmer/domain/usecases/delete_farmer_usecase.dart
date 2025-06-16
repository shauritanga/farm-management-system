import '../repositories/farmer_repository.dart';

/// Use case for deleting a farmer
class DeleteFarmerUsecase {
  final FarmerRepository _repository;

  DeleteFarmerUsecase(this._repository);

  /// Execute the use case
  Future<void> call(String farmerId) async {
    try {
      // Validate farmer exists
      final existingFarmer = await _repository.getFarmerById(farmerId);
      if (existingFarmer == null) {
        throw Exception('Farmer not found');
      }

      await _repository.deleteFarmer(farmerId);
    } catch (e) {
      throw Exception('Failed to delete farmer: $e');
    }
  }
}

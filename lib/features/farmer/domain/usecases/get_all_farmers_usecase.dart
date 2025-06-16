import '../entities/farmer.dart';
import '../repositories/farmer_repository.dart';

/// Use case for getting all farmers
class GetAllFarmersUsecase {
  final FarmerRepository _repository;

  GetAllFarmersUsecase(this._repository);

  /// Execute the use case
  Future<List<FarmerEntity>> call({String? cooperativeId}) async {
    try {
      return await _repository.getAllFarmers(cooperativeId: cooperativeId);
    } catch (e) {
      throw Exception('Failed to get farmers: $e');
    }
  }
}

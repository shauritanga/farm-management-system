import '../entities/farmer.dart';
import '../repositories/farmer_repository.dart';

/// Use case for searching farmers
class SearchFarmersUsecase {
  final FarmerRepository _repository;

  SearchFarmersUsecase(this._repository);

  /// Execute the use case
  Future<List<FarmerEntity>> call(FarmerSearchCriteria criteria) async {
    try {
      return await _repository.searchFarmers(criteria);
    } catch (e) {
      throw Exception('Failed to search farmers: $e');
    }
  }
}

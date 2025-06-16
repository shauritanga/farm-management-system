import '../repositories/farmer_repository.dart';

/// Use case for getting farmer statistics
class GetFarmerStatisticsUsecase {
  final FarmerRepository _repository;

  GetFarmerStatisticsUsecase(this._repository);

  /// Execute the use case
  Future<FarmerStatistics> call() async {
    try {
      return await _repository.getFarmerStatistics();
    } catch (e) {
      throw Exception('Failed to get farmer statistics: $e');
    }
  }
}

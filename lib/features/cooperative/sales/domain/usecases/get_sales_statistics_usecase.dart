import '../repositories/sales_repository.dart';

/// Use case for getting sales statistics
class GetSalesStatisticsUsecase {
  final SalesRepository _salesRepository;

  GetSalesStatisticsUsecase(this._salesRepository);

  /// Get sales statistics for a cooperative
  Future<SalesStatistics> call({String? cooperativeId}) async {
    try {
      return await _salesRepository.getSalesStatistics(cooperativeId: cooperativeId);
    } catch (e) {
      throw Exception('Failed to get sales statistics: $e');
    }
  }
}

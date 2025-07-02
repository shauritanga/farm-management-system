import '../entities/sale_core.dart';
import '../repositories/sales_repository.dart';

/// Use case for getting all sales
class GetAllSalesUsecase {
  final SalesRepository _salesRepository;

  GetAllSalesUsecase(this._salesRepository);

  /// Get all sales for a cooperative
  Future<List<SaleCoreEntity>> call({String? cooperativeId}) async {
    try {
      return await _salesRepository.getAllSales(cooperativeId: cooperativeId);
    } catch (e) {
      throw Exception('Failed to get sales: $e');
    }
  }
}

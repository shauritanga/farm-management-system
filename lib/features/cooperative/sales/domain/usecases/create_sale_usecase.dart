import '../entities/sale_core.dart';
import '../repositories/sales_repository.dart';

/// Use case for creating a new sale
class CreateSaleUsecase {
  final SalesRepository _salesRepository;

  CreateSaleUsecase(this._salesRepository);

  /// Create a new sale with validation
  Future<SaleCoreEntity> call(CreateSaleData data) async {
    try {
      // Validate input data
      _validateSaleData(data);

      // Calculate amounts if needed
      final validatedData = _calculateAmounts(data);

      return await _salesRepository.createSale(validatedData);
    } catch (e) {
      throw Exception('Failed to create sale: $e');
    }
  }

  /// Validate sale data
  void _validateSaleData(CreateSaleData data) {
    if (data.cooperativeId.isEmpty) {
      throw Exception('Cooperative ID is required');
    }

    if (data.farmerId.isEmpty) {
      throw Exception('Farmer ID is required');
    }

    if (data.productId.isEmpty) {
      throw Exception('Product ID is required');
    }

    if (data.weight <= 0) {
      throw Exception('Weight must be greater than 0');
    }

    if (data.pricePerKg.isEmpty) {
      throw Exception('Price per kg is required');
    }

    if (data.amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    if (data.fruityType.isEmpty) {
      throw Exception('Fruit type is required');
    }

    if (data.cooperativeCommission < 0) {
      throw Exception('Cooperative commission cannot be negative');
    }

    if (data.amountFarmerReceives < 0) {
      throw Exception('Amount farmer receives cannot be negative');
    }

    // Validate that farmer amount + commission = total amount
    final expectedTotal = data.amountFarmerReceives + data.cooperativeCommission;
    if ((data.amount - expectedTotal).abs() > 0.01) {
      throw Exception('Amount calculation mismatch');
    }
  }

  /// Calculate amounts based on weight and price
  CreateSaleData _calculateAmounts(CreateSaleData data) {
    // Parse price per kg
    final pricePerKgValue = double.tryParse(data.pricePerKg) ?? 0.0;
    
    // Calculate total amount if not provided correctly
    final calculatedAmount = data.weight * pricePerKgValue;
    
    // Use provided amount or calculated amount
    final finalAmount = data.amount > 0 ? data.amount : calculatedAmount;
    
    // Calculate farmer receives amount (total - commission)
    final finalFarmerAmount = finalAmount - data.cooperativeCommission;

    return CreateSaleData(
      cooperativeId: data.cooperativeId,
      farmerId: data.farmerId,
      productId: data.productId,
      weight: data.weight,
      pricePerKg: data.pricePerKg,
      amount: finalAmount,
      fruityType: data.fruityType,
      qualityGrade: data.qualityGrade,
      cooperativeCommission: data.cooperativeCommission,
      amountFarmerReceives: finalFarmerAmount,
      saleDate: data.saleDate,
      createdBy: data.createdBy,
    );
  }
}

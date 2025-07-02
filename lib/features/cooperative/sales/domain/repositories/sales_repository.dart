import '../entities/sale_core.dart';

/// Repository interface for sales management
abstract class SalesRepository {
  /// Get all sales for a cooperative
  Future<List<SaleCoreEntity>> getAllSales({String? cooperativeId});

  /// Get sale by ID
  Future<SaleCoreEntity?> getSaleById(String saleId);

  /// Get sales by farmer ID
  Future<List<SaleCoreEntity>> getSalesByFarmerId(String farmerId);

  /// Get sales by product ID
  Future<List<SaleCoreEntity>> getSalesByProductId(String productId);

  /// Get sales by date range
  Future<List<SaleCoreEntity>> getSalesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? cooperativeId,
  });

  /// Create a new sale
  Future<SaleCoreEntity> createSale(CreateSaleData data);

  /// Update an existing sale
  Future<SaleCoreEntity> updateSale(String saleId, UpdateSaleData data);

  /// Delete a sale
  Future<void> deleteSale(String saleId);

  /// Search sales with criteria
  Future<List<SaleCoreEntity>> searchSales(SalesSearchCriteria criteria);

  /// Get sales statistics
  Future<SalesStatistics> getSalesStatistics({String? cooperativeId});

  /// Get sales summary by period
  Future<SalesSummary> getSalesSummary({
    required DateTime startDate,
    required DateTime endDate,
    String? cooperativeId,
  });

  /// Get top selling products
  Future<List<ProductSalesData>> getTopSellingProducts({
    String? cooperativeId,
    int limit = 10,
  });

  /// Get farmer sales performance
  Future<List<FarmerSalesData>> getFarmerSalesPerformance({
    String? cooperativeId,
    int limit = 10,
  });

  /// Export sales data
  Future<String> exportSalesData({
    String? cooperativeId,
    DateTime? startDate,
    DateTime? endDate,
    String? format,
  });

  /// Get sales count
  Future<int> getSalesCount({String? cooperativeId});

  /// Get sales with pagination
  Future<PaginatedSales> getSalesWithPagination({
    int page = 1,
    int limit = 20,
    String? cooperativeId,
    SalesSearchCriteria? criteria,
  });
}

/// Data class for creating a new sale
class CreateSaleData {
  final String cooperativeId;
  final String farmerId;
  final String productId;
  final double weight;
  final String pricePerKg;
  final double amount;
  final String fruityType;
  final String? qualityGrade;
  final double cooperativeCommission;
  final double amountFarmerReceives;
  final DateTime saleDate;
  final String? createdBy;

  const CreateSaleData({
    required this.cooperativeId,
    required this.farmerId,
    required this.productId,
    required this.weight,
    required this.pricePerKg,
    required this.amount,
    required this.fruityType,
    this.qualityGrade,
    required this.cooperativeCommission,
    required this.amountFarmerReceives,
    required this.saleDate,
    this.createdBy,
  });
}

/// Data class for updating a sale
class UpdateSaleData {
  final String? farmerId;
  final String? productId;
  final double? weight;
  final String? pricePerKg;
  final double? amount;
  final String? fruityType;
  final String? qualityGrade;
  final double? cooperativeCommission;
  final double? amountFarmerReceives;
  final DateTime? saleDate;
  final String? updatedBy;

  const UpdateSaleData({
    this.farmerId,
    this.productId,
    this.weight,
    this.pricePerKg,
    this.amount,
    this.fruityType,
    this.qualityGrade,
    this.cooperativeCommission,
    this.amountFarmerReceives,
    this.saleDate,
    this.updatedBy,
  });
}

/// Search criteria for sales
class SalesSearchCriteria {
  final String? query;
  final String? farmerId;
  final String? productId;
  final String? fruityType;
  final String? qualityGrade;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final double? minWeight;
  final double? maxWeight;

  const SalesSearchCriteria({
    this.query,
    this.farmerId,
    this.productId,
    this.fruityType,
    this.qualityGrade,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.minWeight,
    this.maxWeight,
  });
}

/// Sales statistics data
class SalesStatistics {
  final int totalSales;
  final double totalRevenue;
  final double totalWeight;
  final double averagePricePerKg;
  final double totalCommission;
  final double totalFarmerPayments;
  final Map<String, int> salesByProduct;
  final Map<String, double> revenueByProduct;
  final Map<String, int> salesByMonth;

  const SalesStatistics({
    required this.totalSales,
    required this.totalRevenue,
    required this.totalWeight,
    required this.averagePricePerKg,
    required this.totalCommission,
    required this.totalFarmerPayments,
    required this.salesByProduct,
    required this.revenueByProduct,
    required this.salesByMonth,
  });
}

/// Sales summary data
class SalesSummary {
  final int totalSales;
  final double totalRevenue;
  final double totalWeight;
  final double totalCommission;
  final double totalFarmerPayments;
  final DateTime startDate;
  final DateTime endDate;

  const SalesSummary({
    required this.totalSales,
    required this.totalRevenue,
    required this.totalWeight,
    required this.totalCommission,
    required this.totalFarmerPayments,
    required this.startDate,
    required this.endDate,
  });
}

/// Product sales data
class ProductSalesData {
  final String productId;
  final String productName;
  final int totalSales;
  final double totalRevenue;
  final double totalWeight;

  const ProductSalesData({
    required this.productId,
    required this.productName,
    required this.totalSales,
    required this.totalRevenue,
    required this.totalWeight,
  });
}

/// Farmer sales data
class FarmerSalesData {
  final String farmerId;
  final String farmerName;
  final int totalSales;
  final double totalRevenue;
  final double totalWeight;
  final double totalEarnings;

  const FarmerSalesData({
    required this.farmerId,
    required this.farmerName,
    required this.totalSales,
    required this.totalRevenue,
    required this.totalWeight,
    required this.totalEarnings,
  });
}

/// Paginated sales data
class PaginatedSales {
  final List<SaleCoreEntity> sales;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedSales({
    required this.sales,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}

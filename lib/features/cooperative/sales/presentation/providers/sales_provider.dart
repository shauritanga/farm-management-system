import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/firestore_sales_repository_impl.dart';
import '../../domain/entities/sale_core.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../domain/usecases/get_all_sales_usecase.dart';
import '../../domain/usecases/create_sale_usecase.dart';
import '../../domain/usecases/get_sales_statistics_usecase.dart';
import '../states/sales_state.dart';

/// Sales repository provider - using Firestore for production
final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return FirestoreSalesRepositoryImpl(FirebaseFirestore.instance);
});

/// Use case providers
final getAllSalesUsecaseProvider = Provider<GetAllSalesUsecase>((ref) {
  return GetAllSalesUsecase(ref.read(salesRepositoryProvider));
});

final createSaleUsecaseProvider = Provider<CreateSaleUsecase>((ref) {
  return CreateSaleUsecase(ref.read(salesRepositoryProvider));
});

final getSalesStatisticsUsecaseProvider = Provider<GetSalesStatisticsUsecase>((ref) {
  return GetSalesStatisticsUsecase(ref.read(salesRepositoryProvider));
});

/// Sales list notifier
class SalesListNotifier extends StateNotifier<SalesState> {
  final GetAllSalesUsecase _getAllSalesUsecase;
  String? _cooperativeId;

  SalesListNotifier(this._getAllSalesUsecase) : super(SalesInitial());

  /// Set cooperative ID
  void setCooperativeId(String cooperativeId) {
    _cooperativeId = cooperativeId;
  }

  /// Load all sales for the cooperative
  Future<void> loadSales({String? cooperativeId}) async {
    state = SalesLoading();
    try {
      final coopId = cooperativeId ?? _cooperativeId;
      final sales = await _getAllSalesUsecase(cooperativeId: coopId);
      state = SalesLoaded(sales);
    } catch (e) {
      state = SalesError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Refresh sales
  Future<void> refreshSales() async {
    await loadSales();
  }

  /// Clear sales
  void clearSales() {
    state = SalesInitial();
  }
}

/// Sale creation notifier
class SaleCreationNotifier extends StateNotifier<SaleCreationState> {
  final CreateSaleUsecase _createSaleUsecase;

  SaleCreationNotifier(this._createSaleUsecase) : super(SaleCreationInitial());

  /// Create a new sale
  Future<void> createSale(CreateSaleData data) async {
    state = SaleCreationLoading();
    try {
      final sale = await _createSaleUsecase(data);
      state = SaleCreationSuccess(sale);
    } catch (e) {
      state = SaleCreationError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Reset creation state
  void resetCreationState() {
    state = SaleCreationInitial();
  }
}

/// Sales statistics notifier
class SalesStatisticsNotifier extends StateNotifier<SalesStatisticsState> {
  final GetSalesStatisticsUsecase _getSalesStatisticsUsecase;

  SalesStatisticsNotifier(this._getSalesStatisticsUsecase) : super(SalesStatisticsInitial());

  /// Load sales statistics
  Future<void> loadStatistics({String? cooperativeId}) async {
    state = SalesStatisticsLoading();
    try {
      final statistics = await _getSalesStatisticsUsecase(cooperativeId: cooperativeId);
      state = SalesStatisticsLoaded(statistics);
    } catch (e) {
      state = SalesStatisticsError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Refresh statistics
  Future<void> refreshStatistics({String? cooperativeId}) async {
    await loadStatistics(cooperativeId: cooperativeId);
  }
}

/// State notifier providers
final salesListProvider = StateNotifierProvider<SalesListNotifier, SalesState>((ref) {
  return SalesListNotifier(ref.read(getAllSalesUsecaseProvider));
});

final saleCreationProvider = StateNotifierProvider<SaleCreationNotifier, SaleCreationState>((ref) {
  return SaleCreationNotifier(ref.read(createSaleUsecaseProvider));
});

final salesStatisticsProvider = StateNotifierProvider<SalesStatisticsNotifier, SalesStatisticsState>((ref) {
  return SalesStatisticsNotifier(ref.read(getSalesStatisticsUsecaseProvider));
});

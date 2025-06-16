import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/farm.dart';
import '../../domain/usecases/get_farms_usecase.dart';
import '../../domain/usecases/create_farm_usecase.dart';
import '../../data/repositories/farm_repository_impl.dart';
import '../../domain/repositories/farm_repository.dart';
import '../states/farm_state.dart';
import '../../../subscription/domain/entities/subscription.dart';

/// Farm repository provider - using Firestore for production
final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  // Use Firestore implementation for production
  return FarmRepositoryImpl(FirebaseFirestore.instance);
});

/// Get farms use case provider
final getFarmsUsecaseProvider = Provider<GetFarmsUsecase>((ref) {
  final repository = ref.read(farmRepositoryProvider);
  return GetFarmsUsecase(repository);
});

/// Create farm use case provider
final createFarmUsecaseProvider = Provider<CreateFarmUsecase>((ref) {
  final repository = ref.read(farmRepositoryProvider);
  return CreateFarmUsecase(repository);
});

/// Farm state notifier
class FarmNotifier extends StateNotifier<FarmState> {
  final GetFarmsUsecase _getFarmsUsecase;
  final CreateFarmUsecase _createFarmUsecase;

  FarmNotifier(this._getFarmsUsecase, this._createFarmUsecase)
    : super(const FarmState.initial());

  /// Load farms for a farmer
  Future<void> loadFarms(String farmerId) async {
    try {
      state = const FarmState.loading();
      final farms = await _getFarmsUsecase.call(farmerId);
      state = FarmState.loaded(farms);
    } catch (e) {
      state = FarmState.error(e.toString());
    }
  }

  /// Search farms
  Future<void> searchFarms(String farmerId, String query) async {
    try {
      state = const FarmState.loading();
      final farms = await _getFarmsUsecase.search(farmerId, query);
      state = FarmState.loaded(farms);
    } catch (e) {
      state = FarmState.error(e.toString());
    }
  }

  /// Filter farms by status
  Future<void> filterFarmsByStatus(String farmerId, FarmStatus status) async {
    try {
      state = const FarmState.loading();
      final farms = await _getFarmsUsecase.getByStatus(farmerId, status);
      state = FarmState.loaded(farms);
    } catch (e) {
      state = FarmState.error(e.toString());
    }
  }

  /// Create a new farm
  Future<void> createFarm({
    required String farmerId,
    required String name,
    required String location,
    required double size,
    required List<String> cropTypes,
    required SubscriptionPackage userSubscription,
    String? description,
    Map<String, dynamic>? coordinates,
    String? soilType,
    String? irrigationType,
  }) async {
    try {
      await _createFarmUsecase.call(
        farmerId: farmerId,
        name: name,
        location: location,
        size: size,
        cropTypes: cropTypes,
        userSubscription: userSubscription,
        description: description,
        coordinates: coordinates,
        soilType: soilType,
        irrigationType: irrigationType,
      );

      // Reload farms after creation
      await loadFarms(farmerId);
    } catch (e) {
      state = FarmState.error(e.toString());
      rethrow; // Rethrow the exception so the UI can handle it properly
    }
  }

  /// Get farm statistics
  Future<Map<String, dynamic>?> getFarmStatistics(String farmerId) async {
    try {
      return await _getFarmsUsecase.getStatistics(farmerId);
    } catch (e) {
      return null;
    }
  }

  /// Reset state
  void reset() {
    state = const FarmState.initial();
  }
}

/// Farm provider
final farmProvider = StateNotifierProvider<FarmNotifier, FarmState>((ref) {
  final getFarmsUsecase = ref.read(getFarmsUsecaseProvider);
  final createFarmUsecase = ref.read(createFarmUsecaseProvider);
  return FarmNotifier(getFarmsUsecase, createFarmUsecase);
});

/// Farm statistics provider
final farmStatisticsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, farmerId) async {
      final getFarmsUsecase = ref.read(getFarmsUsecaseProvider);
      return await getFarmsUsecase.getStatistics(farmerId);
    });

/// Farms list provider - gets actual farm entities
final farmsListProvider = FutureProvider.family<List<FarmEntity>, String>((
  ref,
  farmerId,
) async {
  final getFarmsUsecase = ref.read(getFarmsUsecaseProvider);
  return await getFarmsUsecase.call(farmerId);
});

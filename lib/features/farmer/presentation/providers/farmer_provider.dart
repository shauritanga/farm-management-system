import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/farmer_repository_impl.dart';
import '../../data/repositories/firestore_farmer_repository_impl.dart';
import '../../domain/entities/farmer.dart';
import '../../domain/usecases/get_all_farmers_usecase.dart';
import '../../domain/usecases/search_farmers_usecase.dart';
import '../../domain/usecases/create_farmer_usecase.dart';
import '../../domain/usecases/update_farmer_usecase.dart';
import '../../domain/usecases/delete_farmer_usecase.dart';
import '../../domain/usecases/get_farmer_statistics_usecase.dart';
import '../states/farmer_state.dart';

// Use case providers
final getAllFarmersUsecaseProvider = Provider<GetAllFarmersUsecase>((ref) {
  return GetAllFarmersUsecase(ref.read(farmerRepositoryProvider));
});

final searchFarmersUsecaseProvider = Provider<SearchFarmersUsecase>((ref) {
  return SearchFarmersUsecase(ref.read(farmerRepositoryProvider));
});

final createFarmerUsecaseProvider = Provider<CreateFarmerUsecase>((ref) {
  return CreateFarmerUsecase(ref.read(farmerRepositoryProvider));
});

final updateFarmerUsecaseProvider = Provider<UpdateFarmerUsecase>((ref) {
  return UpdateFarmerUsecase(ref.read(farmerRepositoryProvider));
});

final deleteFarmerUsecaseProvider = Provider<DeleteFarmerUsecase>((ref) {
  return DeleteFarmerUsecase(ref.read(farmerRepositoryProvider));
});

final getFarmerStatisticsUsecaseProvider = Provider<GetFarmerStatisticsUsecase>(
  (ref) {
    return GetFarmerStatisticsUsecase(ref.read(farmerRepositoryProvider));
  },
);

/// Farmer list notifier
class FarmerListNotifier extends StateNotifier<FarmerState> {
  final GetAllFarmersUsecase _getAllFarmersUsecase;
  String? _cooperativeId;

  FarmerListNotifier(this._getAllFarmersUsecase) : super(FarmerInitial());

  /// Set cooperative ID
  void setCooperativeId(String cooperativeId) {
    _cooperativeId = cooperativeId;
  }

  /// Load all farmers for the cooperative
  Future<void> loadFarmers({String? cooperativeId}) async {
    state = FarmerLoading();
    try {
      final coopId = cooperativeId ?? _cooperativeId;
      final farmers = await _getAllFarmersUsecase(cooperativeId: coopId);
      state = FarmersLoaded(farmers);
    } catch (e) {
      state = FarmerError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Refresh farmers list
  Future<void> refreshFarmers() async {
    await loadFarmers();
  }

  /// Reset state
  void resetState() {
    state = FarmerInitial();
  }
}

/// Farmer search notifier
class FarmerSearchNotifier extends StateNotifier<FarmerSearchState> {
  final SearchFarmersUsecase _searchFarmersUsecase;

  FarmerSearchNotifier(this._searchFarmersUsecase)
    : super(FarmerSearchInitial());

  /// Search farmers
  Future<void> searchFarmers(FarmerSearchCriteria criteria) async {
    state = FarmerSearchLoading();
    try {
      final farmers = await _searchFarmersUsecase(criteria);
      state = FarmerSearchLoaded(farmers, criteria);
    } catch (e) {
      state = FarmerSearchError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Clear search
  void clearSearch() {
    state = FarmerSearchInitial();
  }
}

/// Farmer operations notifier
class FarmerOperationsNotifier extends StateNotifier<FarmerOperationState> {
  final CreateFarmerUsecase _createFarmerUsecase;
  final UpdateFarmerUsecase _updateFarmerUsecase;
  final DeleteFarmerUsecase _deleteFarmerUsecase;

  FarmerOperationsNotifier(
    this._createFarmerUsecase,
    this._updateFarmerUsecase,
    this._deleteFarmerUsecase,
  ) : super(FarmerOperationInitial());

  /// Create new farmer
  Future<void> createFarmer(CreateFarmerData data) async {
    state = FarmerOperationLoading();
    try {
      final farmer = await _createFarmerUsecase(data);
      state = FarmerOperationSuccess(
        'Farmer created successfully',
        farmer: farmer,
      );
    } catch (e) {
      state = FarmerOperationError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Update farmer
  Future<void> updateFarmer(String farmerId, UpdateFarmerData data) async {
    state = FarmerOperationLoading();
    try {
      final farmer = await _updateFarmerUsecase(farmerId, data);
      state = FarmerOperationSuccess(
        'Farmer updated successfully',
        farmer: farmer,
      );
    } catch (e) {
      state = FarmerOperationError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Delete farmer
  Future<void> deleteFarmer(String farmerId) async {
    state = FarmerOperationLoading();
    try {
      await _deleteFarmerUsecase(farmerId);
      state = const FarmerOperationSuccess('Farmer deleted successfully');
    } catch (e) {
      state = FarmerOperationError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Reset state
  void resetState() {
    state = FarmerOperationInitial();
  }
}

/// Farmer statistics notifier
class FarmerStatisticsNotifier extends StateNotifier<FarmerState> {
  final GetFarmerStatisticsUsecase _getFarmerStatisticsUsecase;

  FarmerStatisticsNotifier(this._getFarmerStatisticsUsecase)
    : super(FarmerInitial());

  /// Load farmer statistics
  Future<void> loadStatistics() async {
    state = FarmerLoading();
    try {
      final statistics = await _getFarmerStatisticsUsecase();
      state = FarmerStatisticsLoaded(statistics);
    } catch (e) {
      state = FarmerError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Reset state
  void resetState() {
    state = FarmerInitial();
  }
}

// State notifier providers
final farmerListProvider =
    StateNotifierProvider<FarmerListNotifier, FarmerState>((ref) {
      return FarmerListNotifier(ref.read(getAllFarmersUsecaseProvider));
    });

final farmerSearchProvider =
    StateNotifierProvider<FarmerSearchNotifier, FarmerSearchState>((ref) {
      return FarmerSearchNotifier(ref.read(searchFarmersUsecaseProvider));
    });

final farmerOperationsProvider =
    StateNotifierProvider<FarmerOperationsNotifier, FarmerOperationState>((
      ref,
    ) {
      return FarmerOperationsNotifier(
        ref.read(createFarmerUsecaseProvider),
        ref.read(updateFarmerUsecaseProvider),
        ref.read(deleteFarmerUsecaseProvider),
      );
    });

final farmerStatisticsProvider =
    StateNotifierProvider<FarmerStatisticsNotifier, FarmerState>((ref) {
      return FarmerStatisticsNotifier(
        ref.read(getFarmerStatisticsUsecaseProvider),
      );
    });

// Computed providers
final farmersCountProvider = Provider<int>((ref) {
  final farmerState = ref.watch(farmerListProvider);
  if (farmerState is FarmersLoaded) {
    return farmerState.farmers.length;
  }
  return 0;
});

final farmersByZoneProvider = Provider<Map<String, List<FarmerEntity>>>((ref) {
  final farmerState = ref.watch(farmerListProvider);
  if (farmerState is FarmersLoaded) {
    final Map<String, List<FarmerEntity>> farmersByZone = {};
    for (final farmer in farmerState.farmers) {
      if (!farmersByZone.containsKey(farmer.zone)) {
        farmersByZone[farmer.zone] = [];
      }
      farmersByZone[farmer.zone]!.add(farmer);
    }
    return farmersByZone;
  }
  return {};
});

final farmersByVillageProvider = Provider<Map<String, List<FarmerEntity>>>((
  ref,
) {
  final farmerState = ref.watch(farmerListProvider);
  if (farmerState is FarmersLoaded) {
    final Map<String, List<FarmerEntity>> farmersByVillage = {};
    for (final farmer in farmerState.farmers) {
      if (!farmersByVillage.containsKey(farmer.village)) {
        farmersByVillage[farmer.village] = [];
      }
      farmersByVillage[farmer.village]!.add(farmer);
    }
    return farmersByVillage;
  }
  return {};
});

final farmersByCropProvider = Provider<Map<String, List<FarmerEntity>>>((ref) {
  final farmerState = ref.watch(farmerListProvider);
  if (farmerState is FarmersLoaded) {
    final Map<String, List<FarmerEntity>> farmersByCrop = {};
    for (final farmer in farmerState.farmers) {
      for (final crop in farmer.crops) {
        if (!farmersByCrop.containsKey(crop)) {
          farmersByCrop[crop] = [];
        }
        farmersByCrop[crop]!.add(farmer);
      }
    }
    return farmersByCrop;
  }
  return {};
});

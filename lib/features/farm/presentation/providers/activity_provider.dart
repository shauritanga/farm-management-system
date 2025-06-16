import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/activity.dart';
import '../../domain/usecases/get_activities_usecase.dart';
import '../../domain/usecases/create_activity_usecase.dart';
import '../../domain/usecases/update_activity_usecase.dart';
import '../../domain/usecases/complete_activity_usecase.dart';
import 'farm_provider.dart';
import '../../data/repositories/activity_repository_impl.dart';
import '../../domain/repositories/activity_repository.dart';
import '../states/activity_state.dart';

/// Activity repository provider - using Firestore for production
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepositoryImpl(FirebaseFirestore.instance);
});

/// Use case providers
final getActivitiesUsecaseProvider = Provider<GetActivitiesUsecase>((ref) {
  return GetActivitiesUsecase(ref.read(activityRepositoryProvider));
});

final createActivityUsecaseProvider = Provider<CreateActivityUsecase>((ref) {
  return CreateActivityUsecase(ref.read(activityRepositoryProvider));
});

final updateActivityUsecaseProvider = Provider<UpdateActivityUsecase>((ref) {
  return UpdateActivityUsecase(ref.read(activityRepositoryProvider));
});

final completeActivityUsecaseProvider = Provider<CompleteActivityUsecase>((
  ref,
) {
  return CompleteActivityUsecase(ref.read(activityRepositoryProvider));
});

/// Activity state notifier
class ActivityNotifier extends StateNotifier<ActivityState> {
  final GetActivitiesUsecase _getActivitiesUsecase;
  final CreateActivityUsecase _createActivityUsecase;
  final UpdateActivityUsecase _updateActivityUsecase;
  final CompleteActivityUsecase _completeActivityUsecase;

  ActivityNotifier(
    this._getActivitiesUsecase,
    this._createActivityUsecase,
    this._updateActivityUsecase,
    this._completeActivityUsecase,
  ) : super(const ActivityState.initial());

  /// Load activities for a farmer
  Future<void> loadActivities(String farmerId) async {
    state = const ActivityState.loading();
    try {
      final activities = await _getActivitiesUsecase.call(farmerId);
      state = ActivityState.loaded(activities);
    } catch (e) {
      state = ActivityState.error(e.toString());
    }
  }

  /// Load activities for a specific farm
  Future<void> loadFarmActivities(String farmId) async {
    print('ActivityProvider: Loading activities for farm ID: $farmId'); // Debug
    state = const ActivityState.loading();
    try {
      final activities = await _getActivitiesUsecase.getByFarmId(farmId);
      print(
        'ActivityProvider: Loaded ${activities.length} activities',
      ); // Debug
      state = ActivityState.loaded(activities);
    } catch (e) {
      print('ActivityProvider: Error loading activities: $e'); // Debug
      state = ActivityState.error(e.toString());
    }
  }

  /// Create a new activity
  Future<void> createActivity({
    required String farmerId,
    required String farmId,
    required ActivityType type,
    required String title,
    required String description,
    required ActivityPriority priority,
    required DateTime scheduledDate,
    String? cropType,
    double? quantity,
    String? unit,
    double? cost,
    String? currency,
    Map<String, dynamic>? metadata,
    String? notes,
  }) async {
    state = const ActivityState.creating();
    try {
      final data = ActivityCreationData(
        farmId: farmId,
        type: type,
        title: title,
        description: description,
        priority: priority,
        scheduledDate: scheduledDate,
        cropType: cropType,
        quantity: quantity,
        unit: unit,
        cost: cost,
        currency: currency,
        metadata: metadata,
        notes: notes,
      );

      final activity = await _createActivityUsecase.call(farmerId, data);
      state = ActivityState.created(activity);

      // Reload activities after creation
      await loadActivities(farmerId);
    } catch (e) {
      state = ActivityState.error(e.toString());
      rethrow; // Rethrow so UI can handle it
    }
  }

  /// Update an existing activity
  Future<void> updateActivity({
    required String activityId,
    ActivityType? type,
    String? title,
    String? description,
    ActivityStatus? status,
    ActivityPriority? priority,
    DateTime? scheduledDate,
    DateTime? completedDate,
    String? cropType,
    double? quantity,
    String? unit,
    double? cost,
    String? currency,
    Map<String, dynamic>? metadata,
    List<String>? images,
    String? notes,
  }) async {
    state = const ActivityState.updating();
    try {
      final data = ActivityUpdateData(
        type: type,
        title: title,
        description: description,
        status: status,
        priority: priority,
        scheduledDate: scheduledDate,
        completedDate: completedDate,
        cropType: cropType,
        quantity: quantity,
        unit: unit,
        cost: cost,
        currency: currency,
        metadata: metadata,
        images: images,
        notes: notes,
      );

      final activity = await _updateActivityUsecase.call(activityId, data);
      state = ActivityState.updated(activity);

      // Update the current state with the updated activity
      final currentState = state;
      if (currentState.toString().contains('ActivityState.loaded')) {
        try {
          final dynamic dynamicState = currentState;
          if (dynamicState.activities != null) {
            final activities = dynamicState.activities as List<ActivityEntity>;
            final updatedActivities =
                activities.map((a) {
                  return a.id == activityId ? activity : a;
                }).toList();
            state = ActivityState.loaded(updatedActivities);
          }
        } catch (e) {
          // If we can't update the state, just keep the updated state
        }
      }
    } catch (e) {
      state = ActivityState.error(e.toString());
      rethrow;
    }
  }

  /// Complete an activity
  Future<void> completeActivity(String activityId, {String? notes}) async {
    state = const ActivityState.completing();
    try {
      final activity = await _completeActivityUsecase.call(
        activityId,
        notes: notes,
      );
      state = ActivityState.completed(activity);

      // Update the current state with the completed activity
      final currentState = state;
      if (currentState.toString().contains('ActivityState.loaded')) {
        try {
          final dynamic dynamicState = currentState;
          if (dynamicState.activities != null) {
            final activities = dynamicState.activities as List<ActivityEntity>;
            final updatedActivities =
                activities.map((a) {
                  return a.id == activityId ? activity : a;
                }).toList();
            state = ActivityState.loaded(updatedActivities);
          }
        } catch (e) {
          // If we can't update the state, just keep the completed state
        }
      }
    } catch (e) {
      state = ActivityState.error(e.toString());
      rethrow;
    }
  }

  /// Get upcoming activities
  Future<void> loadUpcomingActivities(String farmerId) async {
    state = const ActivityState.loading();
    try {
      final activities = await _getActivitiesUsecase.getUpcoming(farmerId);
      state = ActivityState.loaded(activities);
    } catch (e) {
      state = ActivityState.error(e.toString());
    }
  }

  /// Get overdue activities
  Future<void> loadOverdueActivities(String farmerId) async {
    state = const ActivityState.loading();
    try {
      final activities = await _getActivitiesUsecase.getOverdue(farmerId);
      state = ActivityState.loaded(activities);
    } catch (e) {
      state = ActivityState.error(e.toString());
    }
  }

  /// Search activities
  Future<void> searchActivities(String farmerId, String query) async {
    state = const ActivityState.loading();
    try {
      final activities = await _getActivitiesUsecase.search(farmerId, query);
      state = ActivityState.loaded(activities);
    } catch (e) {
      state = ActivityState.error(e.toString());
    }
  }

  /// Reset state
  void reset() {
    state = const ActivityState.initial();
  }
}

/// Activity provider
final activityProvider = StateNotifierProvider<ActivityNotifier, ActivityState>(
  (ref) {
    return ActivityNotifier(
      ref.read(getActivitiesUsecaseProvider),
      ref.read(createActivityUsecaseProvider),
      ref.read(updateActivityUsecaseProvider),
      ref.read(completeActivityUsecaseProvider),
    );
  },
);

/// Provider for activity statistics
final activityStatisticsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, farmerId) async {
      final usecase = ref.read(getActivitiesUsecaseProvider);
      return await usecase.getStatistics(farmerId);
    });

/// Provider for upcoming activities
final upcomingActivitiesProvider =
    FutureProvider.family<List<ActivityEntity>, String>((ref, farmerId) async {
      final usecase = ref.read(getActivitiesUsecaseProvider);
      return await usecase.getUpcoming(farmerId);
    });

/// Provider for overdue activities
final overdueActivitiesProvider =
    FutureProvider.family<List<ActivityEntity>, String>((ref, farmerId) async {
      final usecase = ref.read(getActivitiesUsecaseProvider);
      return await usecase.getOverdue(farmerId);
    });

/// Farmer recent activities provider - gets activities from all farmer's farms
final farmerRecentActivitiesProvider =
    FutureProvider.family<List<ActivityEntity>, String>((ref, farmerId) async {
      // First get all farms for the farmer
      final getFarmsUsecase = ref.read(getFarmsUsecaseProvider);
      final farms = await getFarmsUsecase.call(farmerId);

      if (farms.isEmpty) {
        return [];
      }

      // Get recent activities from all farms
      final getActivitiesUsecase = ref.read(getActivitiesUsecaseProvider);
      final List<ActivityEntity> allActivities = [];

      for (final farm in farms) {
        try {
          final farmActivities = await getActivitiesUsecase.getByFarmId(
            farm.id,
          );
          allActivities.addAll(farmActivities);
        } catch (e) {
          // Continue with other farms if one fails
          continue;
        }
      }

      // Sort by creation date (most recent first) and take top 10
      allActivities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allActivities.take(10).toList();
    });

/// Provider for farm-specific activity statistics
final farmActivityStatisticsProvider = FutureProvider.family<
  Map<String, dynamic>,
  String
>((ref, farmId) async {
  final repository = ref.read(activityRepositoryProvider);

  try {
    // Get all activities for this farm
    final activities = await repository.getActivitiesByFarmId(farmId);

    final total = activities.length;
    final completed = activities.where((a) => a.isCompleted).length;
    final planned =
        activities.where((a) => a.status == ActivityStatus.planned).length;
    final inProgress =
        activities.where((a) => a.status == ActivityStatus.inProgress).length;
    final overdue =
        activities.where((a) => a.isOverdue && !a.isCompleted).length;
    final cancelled =
        activities.where((a) => a.status == ActivityStatus.cancelled).length;

    // Calculate completion rate
    final completionRate = total > 0 ? (completed / total * 100).round() : 0;

    // Get recent activities (last 5)
    final recentActivities =
        activities
            .where(
              (a) => a.createdAt.isAfter(
                DateTime.now().subtract(const Duration(days: 30)),
              ),
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Get upcoming activities (next 7 days)
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    final upcomingActivities =
        activities
            .where(
              (a) =>
                  !a.isCompleted &&
                  a.scheduledDate.isAfter(now) &&
                  a.scheduledDate.isBefore(nextWeek),
            )
            .toList()
          ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    return {
      'total': total,
      'completed': completed,
      'planned': planned,
      'inProgress': inProgress,
      'overdue': overdue,
      'cancelled': cancelled,
      'completionRate': completionRate,
      'recentActivities': recentActivities.take(5).toList(),
      'upcomingActivities': upcomingActivities.take(5).toList(),
    };
  } catch (e) {
    throw Exception('Failed to get farm activity statistics: $e');
  }
});

/// Provider for recent activities for a specific farm
final farmRecentActivitiesProvider =
    FutureProvider.family<List<ActivityEntity>, String>((ref, farmId) async {
      final repository = ref.read(activityRepositoryProvider);

      try {
        final activities = await repository.getActivitiesByFarmId(farmId);

        // Get activities from last 30 days, sorted by creation date
        final recentActivities =
            activities
                .where(
                  (a) => a.createdAt.isAfter(
                    DateTime.now().subtract(const Duration(days: 30)),
                  ),
                )
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return recentActivities.take(5).toList();
      } catch (e) {
        throw Exception('Failed to get recent activities: $e');
      }
    });

/// Provider for upcoming activities for a specific farm
final farmUpcomingActivitiesProvider =
    FutureProvider.family<List<ActivityEntity>, String>((ref, farmId) async {
      final repository = ref.read(activityRepositoryProvider);

      try {
        final activities = await repository.getActivitiesByFarmId(farmId);

        // Get upcoming activities (next 7 days)
        final now = DateTime.now();
        final nextWeek = now.add(const Duration(days: 7));
        final upcomingActivities =
            activities
                .where(
                  (a) =>
                      !a.isCompleted &&
                      a.scheduledDate.isAfter(now) &&
                      a.scheduledDate.isBefore(nextWeek),
                )
                .toList()
              ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

        return upcomingActivities.take(5).toList();
      } catch (e) {
        throw Exception('Failed to get upcoming activities: $e');
      }
    });

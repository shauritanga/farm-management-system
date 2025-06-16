import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/activity.dart';

part 'activity_state.freezed.dart';

/// State for activity management
@freezed
sealed class ActivityState with _$ActivityState {
  /// Initial state
  const factory ActivityState.initial() = _ActivityInitial;

  /// Loading state
  const factory ActivityState.loading() = _ActivityLoading;

  /// Loaded state with activities
  const factory ActivityState.loaded(List<ActivityEntity> activities) =
      _ActivityLoaded;

  /// Error state
  const factory ActivityState.error(String message) = _ActivityError;

  /// Creating activity state
  const factory ActivityState.creating() = _ActivityCreating;

  /// Activity created successfully
  const factory ActivityState.created(ActivityEntity activity) =
      _ActivityCreated;

  /// Updating activity state
  const factory ActivityState.updating() = _ActivityUpdating;

  /// Activity updated successfully
  const factory ActivityState.updated(ActivityEntity activity) =
      _ActivityUpdated;

  /// Completing activity state
  const factory ActivityState.completing() = _ActivityCompleting;

  /// Activity completed successfully
  const factory ActivityState.completed(ActivityEntity activity) =
      _ActivityCompleted;

  /// Deleting activity state
  const factory ActivityState.deleting() = _ActivityDeleting;

  /// Activity deleted successfully
  const factory ActivityState.deleted(String activityId) = _ActivityDeleted;
}

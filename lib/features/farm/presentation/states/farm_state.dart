import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/farm.dart';

part 'farm_state.freezed.dart';

/// Farm state for managing farm data
@freezed
sealed class FarmState with _$FarmState {
  /// Initial state
  const factory FarmState.initial() = _Initial;

  /// Loading state
  const factory FarmState.loading() = _Loading;

  /// Loaded state with farms data
  const factory FarmState.loaded(List<FarmEntity> farms) = _Loaded;

  /// Error state
  const factory FarmState.error(String message) = _Error;
}

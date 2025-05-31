import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/farm.dart';

part 'farm_state.freezed.dart';

/// Farm state for managing farm data
@freezed
class FarmState with _$FarmState {
  /// Initial state
  const factory FarmState.initial() = _Initial;

  /// Loading state
  const factory FarmState.loading() = _Loading;

  /// Loaded state with farms data
  const factory FarmState.loaded(List<FarmEntity> farms) = _Loaded;

  /// Error state
  const factory FarmState.error(String message) = _Error;
}

/// Extension methods for FarmState
extension FarmStateX on FarmState {
  /// Check if state is loading
  bool get isLoading => this is _Loading;

  /// Check if state has data
  bool get hasData => this is _Loaded;

  /// Check if state has error
  bool get hasError => this is _Error;

  /// Get farms data if available
  List<FarmEntity>? get farms => maybeWhen(
    loaded: (farms) => farms,
    orElse: () => null,
  );

  /// Get error message if available
  String? get errorMessage => maybeWhen(
    error: (message) => message,
    orElse: () => null,
  );
}

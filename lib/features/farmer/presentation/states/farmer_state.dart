import 'package:equatable/equatable.dart';
import '../../domain/entities/farmer.dart';
import '../../domain/repositories/farmer_repository.dart';

/// Base farmer state
abstract class FarmerState extends Equatable {
  const FarmerState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FarmerInitial extends FarmerState {}

/// Loading state
class FarmerLoading extends FarmerState {}

/// Farmers loaded successfully
class FarmersLoaded extends FarmerState {
  final List<FarmerEntity> farmers;

  const FarmersLoaded(this.farmers);

  @override
  List<Object?> get props => [farmers];
}

/// Farmer loaded successfully
class FarmerLoaded extends FarmerState {
  final FarmerEntity farmer;

  const FarmerLoaded(this.farmer);

  @override
  List<Object?> get props => [farmer];
}

/// Farmer statistics loaded
class FarmerStatisticsLoaded extends FarmerState {
  final FarmerStatistics statistics;

  const FarmerStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

/// Error state
class FarmerError extends FarmerState {
  final String message;

  const FarmerError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Farmer operation states
abstract class FarmerOperationState extends Equatable {
  const FarmerOperationState();

  @override
  List<Object?> get props => [];
}

/// Initial operation state
class FarmerOperationInitial extends FarmerOperationState {}

/// Operation in progress
class FarmerOperationLoading extends FarmerOperationState {}

/// Operation successful
class FarmerOperationSuccess extends FarmerOperationState {
  final String message;
  final FarmerEntity? farmer;

  const FarmerOperationSuccess(this.message, {this.farmer});

  @override
  List<Object?> get props => [message, farmer];
}

/// Operation failed
class FarmerOperationError extends FarmerOperationState {
  final String message;

  const FarmerOperationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Search state
abstract class FarmerSearchState extends Equatable {
  const FarmerSearchState();

  @override
  List<Object?> get props => [];
}

/// Initial search state
class FarmerSearchInitial extends FarmerSearchState {}

/// Search in progress
class FarmerSearchLoading extends FarmerSearchState {}

/// Search results loaded
class FarmerSearchLoaded extends FarmerSearchState {
  final List<FarmerEntity> farmers;
  final FarmerSearchCriteria criteria;

  const FarmerSearchLoaded(this.farmers, this.criteria);

  @override
  List<Object?> get props => [farmers, criteria];
}

/// Search error
class FarmerSearchError extends FarmerSearchState {
  final String message;

  const FarmerSearchError(this.message);

  @override
  List<Object?> get props => [message];
}

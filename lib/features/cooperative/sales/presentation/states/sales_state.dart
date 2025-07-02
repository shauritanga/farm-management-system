import 'package:equatable/equatable.dart';
import '../../domain/entities/sale_core.dart';
import '../../domain/repositories/sales_repository.dart';

/// Base sales state
abstract class SalesState extends Equatable {
  const SalesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SalesInitial extends SalesState {}

/// Loading state
class SalesLoading extends SalesState {}

/// Sales loaded successfully
class SalesLoaded extends SalesState {
  final List<SaleCoreEntity> sales;

  const SalesLoaded(this.sales);

  @override
  List<Object?> get props => [sales];
}

/// Sales error state
class SalesError extends SalesState {
  final String message;

  const SalesError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Sale creation states
abstract class SaleCreationState extends Equatable {
  const SaleCreationState();

  @override
  List<Object?> get props => [];
}

class SaleCreationInitial extends SaleCreationState {}

class SaleCreationLoading extends SaleCreationState {}

class SaleCreationSuccess extends SaleCreationState {
  final SaleCoreEntity sale;

  const SaleCreationSuccess(this.sale);

  @override
  List<Object?> get props => [sale];
}

class SaleCreationError extends SaleCreationState {
  final String message;

  const SaleCreationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Sales statistics states
abstract class SalesStatisticsState extends Equatable {
  const SalesStatisticsState();

  @override
  List<Object?> get props => [];
}

class SalesStatisticsInitial extends SalesStatisticsState {}

class SalesStatisticsLoading extends SalesStatisticsState {}

class SalesStatisticsLoaded extends SalesStatisticsState {
  final SalesStatistics statistics;

  const SalesStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class SalesStatisticsError extends SalesStatisticsState {
  final String message;

  const SalesStatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}

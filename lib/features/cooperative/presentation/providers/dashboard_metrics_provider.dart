import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dashboard metrics data model
class DashboardMetrics {
  final int totalFarmers;
  final int totalSalesCount;
  final double totalSalesAmount;
  final double totalAcres;
  final double totalCommissionAmount;

  const DashboardMetrics({
    required this.totalFarmers,
    required this.totalSalesCount,
    required this.totalSalesAmount,
    required this.totalAcres,
    required this.totalCommissionAmount,
  });

  DashboardMetrics copyWith({
    int? totalFarmers,
    int? totalSalesCount,
    double? totalSalesAmount,
    double? totalAcres,
    double? totalCommissionAmount,
  }) {
    return DashboardMetrics(
      totalFarmers: totalFarmers ?? this.totalFarmers,
      totalSalesCount: totalSalesCount ?? this.totalSalesCount,
      totalSalesAmount: totalSalesAmount ?? this.totalSalesAmount,
      totalAcres: totalAcres ?? this.totalAcres,
      totalCommissionAmount:
          totalCommissionAmount ?? this.totalCommissionAmount,
    );
  }

  static const empty = DashboardMetrics(
    totalFarmers: 0,
    totalSalesCount: 0,
    totalSalesAmount: 0.0,
    totalAcres: 0.0,
    totalCommissionAmount: 0.0,
  );
}

/// Repository for dashboard metrics
class DashboardMetricsRepository {
  final FirebaseFirestore _firestore;

  DashboardMetricsRepository(this._firestore);

  /// Get dashboard metrics for a cooperative
  Future<DashboardMetrics> getDashboardMetrics(String cooperativeId) async {
    try {
      // Get total farmers count
      final farmersQuery =
          await _firestore
              .collection('farmers')
              .where('cooperativeId', isEqualTo: cooperativeId)
              .get();

      final totalFarmers = farmersQuery.docs.length;

      // Calculate total acres from farmers' totalTrees (totalTrees / 100)
      double totalAcres = 0.0;
      for (final doc in farmersQuery.docs) {
        final data = doc.data();
        final totalTrees = (data['totalTrees'] ?? 0).toDouble();
        totalAcres += totalTrees / 100;
      }

      // Get sales data
      final salesQuery =
          await _firestore
              .collection('sales')
              .where('cooperativeId', isEqualTo: cooperativeId)
              .get();

      final totalSalesCount = salesQuery.docs.length;

      // Calculate total sales amount and commission amount
      double totalSalesAmount = 0.0;
      double totalCommissionAmount = 0.0;
      for (final doc in salesQuery.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0).toDouble();
        final commission = (data['cooperativeCommission'] ?? 0).toDouble();
        totalSalesAmount += amount;
        totalCommissionAmount += commission;
      }

      return DashboardMetrics(
        totalFarmers: totalFarmers,
        totalSalesCount: totalSalesCount,
        totalSalesAmount: totalSalesAmount,
        totalAcres: totalAcres,
        totalCommissionAmount: totalCommissionAmount,
      );
    } catch (e) {
      throw Exception('Failed to fetch dashboard metrics: $e');
    }
  }

  /// Stream dashboard metrics for real-time updates
  Stream<DashboardMetrics> watchDashboardMetrics(String cooperativeId) {
    return Stream.periodic(
      const Duration(minutes: 5),
      (index) => index,
    ).asyncMap((_) => getDashboardMetrics(cooperativeId)).handleError((error) {
      // Return empty metrics on error
      return DashboardMetrics.empty;
    });
  }
}

/// Provider for dashboard metrics repository
final dashboardMetricsRepositoryProvider = Provider<DashboardMetricsRepository>(
  (ref) {
    return DashboardMetricsRepository(FirebaseFirestore.instance);
  },
);

/// Provider for dashboard metrics
final dashboardMetricsProvider =
    FutureProvider.family<DashboardMetrics, String>((ref, cooperativeId) async {
      if (cooperativeId.isEmpty) return DashboardMetrics.empty;

      final repository = ref.read(dashboardMetricsRepositoryProvider);
      return await repository.getDashboardMetrics(cooperativeId);
    });

/// Provider for streaming dashboard metrics
final dashboardMetricsStreamProvider =
    StreamProvider.family<DashboardMetrics, String>((ref, cooperativeId) {
      if (cooperativeId.isEmpty) {
        return Stream.value(DashboardMetrics.empty);
      }

      final repository = ref.read(dashboardMetricsRepositoryProvider);
      return repository.watchDashboardMetrics(cooperativeId);
    });

/// Provider for individual metric counts (for more granular updates)
final farmersCountProvider = FutureProvider.family<int, String>((
  ref,
  cooperativeId,
) async {
  if (cooperativeId.isEmpty) return 0;

  try {
    final query =
        await FirebaseFirestore.instance
            .collection('farmers')
            .where('cooperativeId', isEqualTo: cooperativeId)
            .get();

    return query.docs.length;
  } catch (e) {
    return 0;
  }
});

final salesCountProvider = FutureProvider.family<int, String>((
  ref,
  cooperativeId,
) async {
  if (cooperativeId.isEmpty) return 0;

  try {
    final query =
        await FirebaseFirestore.instance
            .collection('sales')
            .where('cooperativeId', isEqualTo: cooperativeId)
            .get();

    return query.docs.length;
  } catch (e) {
    return 0;
  }
});

final totalSalesAmountProvider = FutureProvider.family<double, String>((
  ref,
  cooperativeId,
) async {
  if (cooperativeId.isEmpty) return 0.0;

  try {
    final query =
        await FirebaseFirestore.instance
            .collection('sales')
            .where('cooperativeId', isEqualTo: cooperativeId)
            .get();

    double total = 0.0;
    for (final doc in query.docs) {
      final data = doc.data();
      final amount = (data['amount'] ?? 0).toDouble();
      total += amount;
    }

    return total;
  } catch (e) {
    return 0.0;
  }
});

final totalAcresProvider = FutureProvider.family<double, String>((
  ref,
  cooperativeId,
) async {
  if (cooperativeId.isEmpty) return 0.0;

  try {
    final query =
        await FirebaseFirestore.instance
            .collection('farmers')
            .where('cooperativeId', isEqualTo: cooperativeId)
            .get();

    double totalAcres = 0.0;
    for (final doc in query.docs) {
      final data = doc.data();
      final totalTrees = (data['totalTrees'] ?? 0).toDouble();
      totalAcres += totalTrees / 100;
    }

    return totalAcres;
  } catch (e) {
    return 0.0;
  }
});

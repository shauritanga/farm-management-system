import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sales trend data model for monthly data
class SalesTrendData {
  final String month;
  final double salesAmount;
  final double commissionAmount;
  final int salesCount;
  final DateTime monthDate; // Add date for proper sorting

  const SalesTrendData({
    required this.month,
    required this.salesAmount,
    required this.commissionAmount,
    required this.salesCount,
    required this.monthDate,
  });

  SalesTrendData copyWith({
    String? month,
    double? salesAmount,
    double? commissionAmount,
    int? salesCount,
    DateTime? monthDate,
  }) {
    return SalesTrendData(
      month: month ?? this.month,
      salesAmount: salesAmount ?? this.salesAmount,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      salesCount: salesCount ?? this.salesCount,
      monthDate: monthDate ?? this.monthDate,
    );
  }
}

/// Repository for sales trend data
class SalesTrendRepository {
  final FirebaseFirestore _firestore;

  SalesTrendRepository(this._firestore);

  /// Get sales trend data for the last 6 months
  Future<List<SalesTrendData>> getSalesTrend(String cooperativeId) async {
    try {
      if (cooperativeId.isEmpty) {
        return [];
      }

      final now = DateTime.now();
      // Get sales from the last 12 months to capture your data (Sep, Oct, Nov, Dec, Jan)
      final twelveMonthsAgo = DateTime(now.year - 1, now.month, 1);

      // Get all sales data for the cooperative
      final salesQuery =
          await _firestore
              .collection('sales')
              .where('cooperativeId', isEqualTo: cooperativeId)
              .get();

      print(
        'DEBUG: Found ${salesQuery.docs.length} sales documents for cooperative $cooperativeId',
      );
      print('DEBUG: Date range from $twelveMonthsAgo to $now');

      // Group sales by month (only months with actual sales)
      Map<String, SalesTrendData> monthlyData = {};

      // Process sales data
      for (final doc in salesQuery.docs) {
        try {
          final data = doc.data();
          print('DEBUG: Processing document ${doc.id}');
          print('DEBUG: Document data: $data');

          // Parse sale date - handle both Timestamp and String formats
          if (data['saleDate'] == null) {
            print('DEBUG: Skipping ${doc.id} - no saleDate field');
            continue;
          }

          DateTime? saleDate;
          if (data['saleDate'] is Timestamp) {
            saleDate = (data['saleDate'] as Timestamp).toDate();
          } else if (data['saleDate'] is String) {
            try {
              saleDate = DateTime.parse(data['saleDate'] as String);
            } catch (e) {
              print(
                'DEBUG: Skipping ${doc.id} - invalid date string: ${data['saleDate']}',
              );
              continue;
            }
          } else {
            print(
              'DEBUG: Skipping ${doc.id} - saleDate is neither Timestamp nor String',
            );
            continue;
          }
          print('DEBUG: Sale date: $saleDate');

          // Skip if outside our 12-month range
          if (saleDate.isBefore(twelveMonthsAgo)) {
            print('DEBUG: Skipping ${doc.id} - outside date range');
            continue;
          }

          final monthKey = _getMonthKey(saleDate);
          final amount = (data['amount'] ?? 0).toDouble();
          final cooperativeCommission =
              (data['cooperativeCommission'] ?? 0).toDouble();

          print(
            'DEBUG: Month: $monthKey, Amount: $amount, Commission: $cooperativeCommission',
          );

          // Only create/update month data if there's actual sales data
          if (amount > 0 || cooperativeCommission > 0) {
            if (monthlyData.containsKey(monthKey)) {
              final existing = monthlyData[monthKey]!;
              monthlyData[monthKey] = existing.copyWith(
                salesAmount: existing.salesAmount + amount,
                commissionAmount:
                    existing.commissionAmount + cooperativeCommission,
                salesCount: existing.salesCount + 1,
              );
            } else {
              monthlyData[monthKey] = SalesTrendData(
                month: _getMonthName(saleDate),
                salesAmount: amount,
                commissionAmount: cooperativeCommission,
                salesCount: 1,
                monthDate: DateTime(saleDate.year, saleDate.month, 1),
              );
            }
            print('DEBUG: Added/updated data for month $monthKey');
          } else {
            print('DEBUG: Skipping ${doc.id} - no amount or commission');
          }
        } catch (docError) {
          print('DEBUG: Error processing document ${doc.id}: $docError');
          continue;
        }
      }

      print('DEBUG: Final monthly data: ${monthlyData.keys}');

      // Convert to list and sort chronologically
      final result = monthlyData.values.toList();

      // Sort by month date chronologically
      result.sort((a, b) => a.monthDate.compareTo(b.monthDate));

      print('DEBUG: Returning ${result.length} months of data');
      return result;
    } catch (e) {
      print('DEBUG: Error in getSalesTrend: $e');
      // Return empty data instead of throwing to prevent UI crashes
      return [];
    }
  }

  /// Get month key for grouping (YYYY-MM format)
  String _getMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// Get month name for display
  String _getMonthName(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[date.month - 1];
  }
}

/// Provider for sales trend repository
final salesTrendRepositoryProvider = Provider<SalesTrendRepository>((ref) {
  return SalesTrendRepository(FirebaseFirestore.instance);
});

/// Provider for sales trend data
final salesTrendProvider = FutureProvider.family<List<SalesTrendData>, String>((
  ref,
  cooperativeId,
) async {
  if (cooperativeId.isEmpty) return [];

  final repository = ref.read(salesTrendRepositoryProvider);
  return await repository.getSalesTrend(cooperativeId);
});

/// Provider for streaming sales trend data
final salesTrendStreamProvider =
    StreamProvider.family<List<SalesTrendData>, String>((ref, cooperativeId) {
      if (cooperativeId.isEmpty) {
        return Stream.value([]);
      }

      // Refresh every 10 minutes
      return Stream.periodic(const Duration(minutes: 10), (index) => index)
          .asyncMap((_) async {
            final repository = ref.read(salesTrendRepositoryProvider);
            return await repository.getSalesTrend(cooperativeId);
          })
          .handleError((error) {
            return <SalesTrendData>[];
          });
    });

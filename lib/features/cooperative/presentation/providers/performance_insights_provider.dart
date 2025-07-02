import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Performance insights data model
class PerformanceInsightsData {
  final double growthRate;
  final double efficiency;
  final String primaryInsight;
  final String recommendation;
  final int totalSalesThisMonth;
  final int totalSalesLastMonth;
  final double avgSaleAmount;

  PerformanceInsightsData({
    required this.growthRate,
    required this.efficiency,
    required this.primaryInsight,
    required this.recommendation,
    required this.totalSalesThisMonth,
    required this.totalSalesLastMonth,
    required this.avgSaleAmount,
  });
}

/// Provider for performance insights
final performanceInsightsProvider = FutureProvider.family<PerformanceInsightsData, String>((ref, cooperativeId) async {
  if (cooperativeId.isEmpty) {
    return PerformanceInsightsData(
      growthRate: 0.0,
      efficiency: 0.0,
      primaryInsight: 'No data available',
      recommendation: 'Start recording sales to see insights',
      totalSalesThisMonth: 0,
      totalSalesLastMonth: 0,
      avgSaleAmount: 0.0,
    );
  }
  
  try {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    
    // Calculate date ranges
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = thisMonthStart.subtract(const Duration(days: 1));
    
    // Get this month's sales
    final thisMonthSales = await firestore
        .collection('sales')
        .where('cooperativeId', isEqualTo: cooperativeId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(thisMonthStart))
        .get();
    
    // Get last month's sales
    final lastMonthSales = await firestore
        .collection('sales')
        .where('cooperativeId', isEqualTo: cooperativeId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(lastMonthStart))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(lastMonthEnd))
        .get();
    
    // Calculate metrics
    final thisMonthCount = thisMonthSales.docs.length;
    final lastMonthCount = lastMonthSales.docs.length;
    
    double thisMonthAmount = 0;
    for (final doc in thisMonthSales.docs) {
      thisMonthAmount += (doc.data()['amount'] ?? 0).toDouble();
    }
    
    double lastMonthAmount = 0;
    for (final doc in lastMonthSales.docs) {
      lastMonthAmount += (doc.data()['amount'] ?? 0).toDouble();
    }
    
    // Calculate growth rate
    double growthRate = 0.0;
    if (lastMonthAmount > 0) {
      growthRate = ((thisMonthAmount - lastMonthAmount) / lastMonthAmount) * 100;
    } else if (thisMonthAmount > 0) {
      growthRate = 100.0; // 100% growth from 0
    }
    
    // Calculate efficiency (sales count growth)
    double efficiency = 0.0;
    if (lastMonthCount > 0) {
      efficiency = ((thisMonthCount - lastMonthCount) / lastMonthCount) * 100;
      efficiency = 100 + efficiency; // Convert to percentage out of 100
      if (efficiency > 100) efficiency = 100;
      if (efficiency < 0) efficiency = 0;
    } else if (thisMonthCount > 0) {
      efficiency = 95.0; // High efficiency for new operations
    } else {
      efficiency = 0.0;
    }
    
    // Calculate average sale amount
    double avgSaleAmount = 0.0;
    if (thisMonthCount > 0) {
      avgSaleAmount = thisMonthAmount / thisMonthCount;
    }
    
    // Generate insights
    String primaryInsight;
    String recommendation;
    
    if (growthRate > 20) {
      primaryInsight = 'Excellent growth this month!';
      recommendation = 'Continue current strategies and consider expanding operations';
    } else if (growthRate > 0) {
      primaryInsight = 'Positive growth trend';
      recommendation = 'Focus on increasing farmer engagement and product quality';
    } else if (growthRate < -10) {
      primaryInsight = 'Sales declined this month';
      recommendation = 'Review pricing strategy and farmer support programs';
    } else {
      primaryInsight = 'Stable performance';
      recommendation = 'Implement growth strategies to increase sales volume';
    }
    
    if (thisMonthCount == 0 && lastMonthCount == 0) {
      primaryInsight = 'No sales recorded yet';
      recommendation = 'Start recording sales to track performance';
    }
    
    return PerformanceInsightsData(
      growthRate: growthRate,
      efficiency: efficiency,
      primaryInsight: primaryInsight,
      recommendation: recommendation,
      totalSalesThisMonth: thisMonthCount,
      totalSalesLastMonth: lastMonthCount,
      avgSaleAmount: avgSaleAmount,
    );
    
  } catch (e) {
    print('Error calculating performance insights: $e');
    return PerformanceInsightsData(
      growthRate: 0.0,
      efficiency: 0.0,
      primaryInsight: 'Unable to calculate insights',
      recommendation: 'Check your data and try again',
      totalSalesThisMonth: 0,
      totalSalesLastMonth: 0,
      avgSaleAmount: 0.0,
    );
  }
});

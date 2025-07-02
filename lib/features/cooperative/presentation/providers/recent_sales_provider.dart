import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Recent sales data model
class RecentSaleData {
  final String id;
  final String farmerName;
  final double amount;
  final double weight;
  final String productName;
  final DateTime saleDate;
  final String qualityGrade;

  RecentSaleData({
    required this.id,
    required this.farmerName,
    required this.amount,
    required this.weight,
    required this.productName,
    required this.saleDate,
    required this.qualityGrade,
  });
}

/// Provider for recent sales (last 5 sales)
final recentSalesProvider = FutureProvider.family<
  List<RecentSaleData>,
  String
>((ref, cooperativeId) async {
  if (cooperativeId.isEmpty) return [];

  try {
    final firestore = FirebaseFirestore.instance;

    print('DEBUG: Fetching recent sales for cooperative: $cooperativeId');

    // Get recent sales for the cooperative
    final salesQuery =
        await firestore
            .collection('sales')
            .where('cooperativeId', isEqualTo: cooperativeId)
            .orderBy('createdAt', descending: true)
            .limit(5)
            .get();

    print('DEBUG: Found ${salesQuery.docs.length} sales documents');

    List<RecentSaleData> recentSales = [];

    for (final saleDoc in salesQuery.docs) {
      final saleData = saleDoc.data();
      print('DEBUG: Processing sale ${saleDoc.id} with data: ${saleData.keys}');

      // Get farmer name
      String farmerName = 'Unknown Farmer';
      if (saleData['farmerId'] != null) {
        try {
          final farmerDoc =
              await firestore
                  .collection('farmers')
                  .doc(saleData['farmerId'])
                  .get();
          if (farmerDoc.exists) {
            final farmerData = farmerDoc.data()!;
            // Handle both old and new farmer entity formats
            farmerName = farmerData['name'] ?? '';
            if (farmerName.isEmpty) {
              farmerName =
                  '${farmerData['firstName'] ?? ''} ${farmerData['lastName'] ?? ''}'
                      .trim();
            }
            if (farmerName.isEmpty) {
              farmerName = 'Unknown Farmer';
            }
          }
        } catch (e) {
          // Keep default name if farmer fetch fails
        }
      }

      // Get product name
      String productName = 'Unknown Product';
      if (saleData['productId'] != null) {
        try {
          final productDoc =
              await firestore
                  .collection('products')
                  .doc(saleData['productId'])
                  .get();
          if (productDoc.exists) {
            final productData = productDoc.data()!;
            productName = productData['name'] ?? 'Unknown Product';
          }
        } catch (e) {
          // Keep default name if product fetch fails
        }
      }

      // Parse sale date
      DateTime saleDate = DateTime.now();
      if (saleData['saleDate'] != null) {
        if (saleData['saleDate'] is Timestamp) {
          saleDate = (saleData['saleDate'] as Timestamp).toDate();
        } else if (saleData['saleDate'] is String) {
          try {
            saleDate = DateTime.parse(saleData['saleDate']);
          } catch (e) {
            // Keep current date if parsing fails
          }
        }
      }

      recentSales.add(
        RecentSaleData(
          id: saleDoc.id,
          farmerName: farmerName,
          amount:
              (saleData['totalAmount'] ?? saleData['amount'] ?? 0).toDouble(),
          weight: (saleData['weight'] ?? 0).toDouble(),
          productName: productName,
          saleDate: saleDate,
          qualityGrade:
              saleData['qualityGrade'] ?? saleData['fruitType'] ?? 'Standard',
        ),
      );
    }

    return recentSales;
  } catch (e) {
    print('Error fetching recent sales: $e');
    return [];
  }
});

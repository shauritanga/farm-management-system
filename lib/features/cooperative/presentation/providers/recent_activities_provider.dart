import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Recent activity data model
class RecentActivityData {
  final String id;
  final String type;
  final String description;
  final String actorName;
  final DateTime timestamp;
  final String icon;

  RecentActivityData({
    required this.id,
    required this.type,
    required this.description,
    required this.actorName,
    required this.timestamp,
    required this.icon,
  });
}

/// Provider for recent activities
final recentActivitiesProvider = FutureProvider.family<
  List<RecentActivityData>,
  String
>((ref, cooperativeId) async {
  if (cooperativeId.isEmpty) return [];

  try {
    final firestore = FirebaseFirestore.instance;
    List<RecentActivityData> activities = [];

    // Get recent sales activities
    final recentSales =
        await firestore
            .collection('sales')
            .where('cooperativeId', isEqualTo: cooperativeId)
            .orderBy('createdAt', descending: true)
            .limit(3)
            .get();

    for (final saleDoc in recentSales.docs) {
      final saleData = saleDoc.data();

      // Get farmer name for the sale
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
            farmerName =
                '${farmerData['firstName'] ?? ''} ${farmerData['lastName'] ?? ''}'
                    .trim();
            if (farmerName.isEmpty) {
              farmerName = farmerData['name'] ?? 'Unknown Farmer';
            }
          }
        } catch (e) {
          // Keep default name
        }
      }

      final amount =
          (saleData['totalAmount'] ?? saleData['amount'] ?? 0).toDouble();
      final weight = (saleData['weight'] ?? 0).toDouble();

      activities.add(
        RecentActivityData(
          id: '${saleDoc.id}_sale',
          type: 'sale',
          description:
              'Sale recorded: ${weight}kg for TSH ${amount.toStringAsFixed(0)}',
          actorName: farmerName,
          timestamp:
              (saleData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          icon: 'sale',
        ),
      );
    }

    // Get recent farmer registrations and updates
    final recentFarmers =
        await firestore
            .collection('farmers')
            .where('cooperativeId', isEqualTo: cooperativeId)
            .orderBy('createdAt', descending: true)
            .limit(3)
            .get();

    for (final farmerDoc in recentFarmers.docs) {
      final farmerData = farmerDoc.data();

      // Handle both old and new farmer entity formats
      String farmerName = farmerData['name'] ?? '';
      if (farmerName.isEmpty) {
        farmerName =
            '${farmerData['firstName'] ?? ''} ${farmerData['lastName'] ?? ''}'
                .trim();
      }
      if (farmerName.isEmpty) {
        farmerName = 'New Farmer';
      }

      activities.add(
        RecentActivityData(
          id: '${farmerDoc.id}_registration',
          type: 'farmer_registration',
          description: 'New farmer registered',
          actorName: farmerName,
          timestamp:
              (farmerData['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.now(),
          icon: 'farmer',
        ),
      );
    }

    // Get recent farmer updates (where updatedAt is different from createdAt)
    final recentFarmerUpdates =
        await firestore
            .collection('farmers')
            .where('cooperativeId', isEqualTo: cooperativeId)
            .orderBy('updatedAt', descending: true)
            .limit(2)
            .get();

    for (final farmerDoc in recentFarmerUpdates.docs) {
      final farmerData = farmerDoc.data();

      // Only include if it's actually an update (updatedAt != createdAt)
      final createdAt = (farmerData['createdAt'] as Timestamp?)?.toDate();
      final updatedAt = (farmerData['updatedAt'] as Timestamp?)?.toDate();

      if (updatedAt != null &&
          createdAt != null &&
          updatedAt.isAfter(createdAt.add(const Duration(seconds: 5)))) {
        // Handle both old and new farmer entity formats
        String farmerName = farmerData['name'] ?? '';
        if (farmerName.isEmpty) {
          farmerName =
              '${farmerData['firstName'] ?? ''} ${farmerData['lastName'] ?? ''}'
                  .trim();
        }
        if (farmerName.isEmpty) {
          farmerName = 'Farmer';
        }

        activities.add(
          RecentActivityData(
            id: '${farmerDoc.id}_update',
            type: 'farmer_update',
            description: 'Farmer information updated',
            actorName: farmerName,
            timestamp: updatedAt,
            icon: 'edit',
          ),
        );
      }
    }

    // Sort all activities by timestamp (most recent first)
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Return top 5 activities
    return activities.take(5).toList();
  } catch (e) {
    print('Error fetching recent activities: $e');
    return [];
  }
});

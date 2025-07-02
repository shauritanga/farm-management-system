import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for notification count
final notificationCountProvider = FutureProvider.family<int, String>((ref, cooperativeId) async {
  if (cooperativeId.isEmpty) return 0;
  
  try {
    // Get unread notifications count for the cooperative
    final notificationsQuery = await FirebaseFirestore.instance
        .collection('notifications')
        .where('cooperativeId', isEqualTo: cooperativeId)
        .where('isRead', isEqualTo: false)
        .get();
    
    return notificationsQuery.docs.length;
  } catch (e) {
    // Return 0 if there's an error
    return 0;
  }
});

/// Notification model
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final String cooperativeId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
    required this.cooperativeId,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'info',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      cooperativeId: data['cooperativeId'] ?? '',
    );
  }
}

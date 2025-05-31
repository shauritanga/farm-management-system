import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/subscription.dart';

/// Data model for subscription with Firestore serialization
class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    required super.id,
    required super.userId,
    required super.package,
    required super.status,
    required super.startDate,
    super.endDate,
    super.trialEndDate,
    required super.autoRenew,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create SubscriptionModel from Firestore document
  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubscriptionModel.fromMap(data, doc.id);
  }

  /// Create SubscriptionModel from Map with optional ID
  factory SubscriptionModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return SubscriptionModel(
      id: id ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      package: SubscriptionPackage.fromString(map['package'] ?? 'free_tier'),
      status: SubscriptionStatus.fromString(map['status'] ?? 'trial'),
      startDate: _parseTimestamp(map['startDate']),
      endDate: _parseTimestamp(map['endDate']),
      trialEndDate: _parseTimestamp(map['trialEndDate']),
      autoRenew: map['autoRenew'] ?? false,
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'package': package.value,
      'status': status.value,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'trialEndDate': trialEndDate != null ? Timestamp.fromDate(trialEndDate!) : null,
      'autoRenew': autoRenew,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Convert to Map for creation (excludes computed fields)
  Map<String, dynamic> toCreateMap() {
    final map = toMap();
    map.remove('id'); // ID is set by Firestore
    return map;
  }

  /// Create SubscriptionModel from SubscriptionEntity
  factory SubscriptionModel.fromEntity(SubscriptionEntity entity) {
    return SubscriptionModel(
      id: entity.id,
      userId: entity.userId,
      package: entity.package,
      status: entity.status,
      startDate: entity.startDate,
      endDate: entity.endDate,
      trialEndDate: entity.trialEndDate,
      autoRenew: entity.autoRenew,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Create default free tier subscription for new users
  factory SubscriptionModel.createFreeTier(String userId) {
    final now = DateTime.now();
    final trialEnd = now.add(const Duration(days: 14));
    
    return SubscriptionModel(
      id: '', // Will be set by Firestore
      userId: userId,
      package: SubscriptionPackage.freeTier,
      status: SubscriptionStatus.trial,
      startDate: now,
      trialEndDate: trialEnd,
      autoRenew: false,
      createdAt: now,
    );
  }

  /// Helper method to parse Firestore Timestamp
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  @override
  SubscriptionModel copyWith({
    String? id,
    String? userId,
    SubscriptionPackage? package,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? trialEndDate,
    bool? autoRenew,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      package: package ?? this.package,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      autoRenew: autoRenew ?? this.autoRenew,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Helper method to parse Firestore Timestamp (moved outside class for reuse)
DateTime _parseTimestamp(dynamic timestamp) {
  if (timestamp == null) return DateTime.now();
  if (timestamp is Timestamp) return timestamp.toDate();
  if (timestamp is DateTime) return timestamp;
  if (timestamp is String) return DateTime.parse(timestamp);
  return DateTime.now();
}

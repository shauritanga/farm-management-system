import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/activity.dart';

/// Data model for Activity entity with Firestore integration
class ActivityModel extends ActivityEntity {
  const ActivityModel({
    required super.id,
    required super.farmId,
    required super.farmerId,
    required super.type,
    required super.title,
    required super.description,
    required super.status,
    required super.priority,
    required super.scheduledDate,
    required super.createdAt,
    super.completedDate,
    super.cropType,
    super.quantity,
    super.unit,
    super.cost,
    super.currency,
    super.metadata,
    super.images,
    super.notes,
    super.updatedAt,
  });

  /// Create ActivityModel from Firestore document
  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ActivityModel(
      id: doc.id,
      farmId: data['farmId'] ?? '',
      farmerId: data['farmerId'] ?? '',
      type: ActivityType.fromString(data['type'] ?? 'other'),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: ActivityStatus.fromString(data['status'] ?? 'pending'),
      priority: ActivityPriority.fromString(data['priority'] ?? 'medium'),
      scheduledDate: (data['scheduledDate'] as Timestamp).toDate(),
      completedDate:
          data['completedDate'] != null
              ? (data['completedDate'] as Timestamp).toDate()
              : null,
      cropType: data['cropType'],
      quantity: data['quantity']?.toDouble(),
      unit: data['unit'],
      cost: data['cost']?.toDouble(),
      currency: data['currency'],
      metadata:
          data['metadata'] != null
              ? Map<String, dynamic>.from(data['metadata'])
              : null,
      images: data['images'] != null ? List<String>.from(data['images']) : null,
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  /// Create ActivityModel from creation data
  factory ActivityModel.fromCreationData(
    String farmerId,
    ActivityCreationData data,
  ) {
    final now = DateTime.now();

    return ActivityModel(
      id: '', // Will be set by Firestore
      farmId: data.farmId,
      farmerId: farmerId,
      type: data.type,
      title: data.title.trim(),
      description: data.description.trim(),
      status: ActivityStatus.planned,
      priority: data.priority,
      scheduledDate: data.scheduledDate,
      cropType: data.cropType,
      quantity: data.quantity,
      unit: data.unit,
      cost: data.cost,
      currency: data.currency ?? 'TSh',
      metadata: data.metadata,
      notes: data.notes?.trim(),
      createdAt: now,
    );
  }

  /// Convert to map for Firestore creation
  Map<String, dynamic> toCreateMap() {
    return {
      'farmId': farmId,
      'farmerId': farmerId,
      'type': type.value,
      'title': title,
      'description': description,
      'status': status.value,
      'priority': priority.value,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'completedDate':
          completedDate != null ? Timestamp.fromDate(completedDate!) : null,
      'cropType': cropType,
      'quantity': quantity,
      'unit': unit,
      'cost': cost,
      'currency': currency,
      'metadata': metadata,
      'images': images,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': null,
    };
  }

  /// Convert to map for Firestore update
  Map<String, dynamic> toUpdateMap() {
    return {
      'type': type.value,
      'title': title,
      'description': description,
      'status': status.value,
      'priority': priority.value,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'completedDate':
          completedDate != null ? Timestamp.fromDate(completedDate!) : null,
      'cropType': cropType,
      'quantity': quantity,
      'unit': unit,
      'cost': cost,
      'currency': currency,
      'metadata': metadata,
      'images': images,
      'notes': notes,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  /// Create a copy with updated fields
  @override
  ActivityModel copyWith({
    String? id,
    String? farmId,
    String? farmerId,
    ActivityType? type,
    String? title,
    String? description,
    ActivityStatus? status,
    ActivityPriority? priority,
    DateTime? scheduledDate,
    DateTime? completedDate,
    String? cropType,
    double? quantity,
    String? unit,
    double? cost,
    String? currency,
    Map<String, dynamic>? metadata,
    List<String>? images,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      farmerId: farmerId ?? this.farmerId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      cropType: cropType ?? this.cropType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      metadata: metadata ?? this.metadata,
      images: images ?? this.images,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

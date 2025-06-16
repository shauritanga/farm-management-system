import 'package:equatable/equatable.dart';

/// Activity type enumeration
enum ActivityType {
  planting('planting', 'Planting'),
  watering('watering', 'Watering'),
  fertilizing('fertilizing', 'Fertilizing'),
  pestControl('pest_control', 'Pest Control'),
  harvesting('harvesting', 'Harvesting'),
  soilPreparation('soil_preparation', 'Soil Preparation'),
  weeding('weeding', 'Weeding'),
  pruning('pruning', 'Pruning'),
  monitoring('monitoring', 'Monitoring'),
  maintenance('maintenance', 'Maintenance'),
  other('other', 'Other');

  const ActivityType(this.value, this.displayName);
  final String value;
  final String displayName;

  static ActivityType fromString(String value) {
    return ActivityType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ActivityType.other,
    );
  }
}

/// Activity priority enumeration
enum ActivityPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  urgent('urgent', 'Urgent');

  const ActivityPriority(this.value, this.displayName);
  final String value;
  final String displayName;

  static ActivityPriority fromString(String value) {
    return ActivityPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => ActivityPriority.medium,
    );
  }
}

/// Activity status enumeration
enum ActivityStatus {
  planned('planned', 'Planned'),
  inProgress('in_progress', 'In Progress'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled'),
  overdue('overdue', 'Overdue');

  const ActivityStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static ActivityStatus fromString(String value) {
    return ActivityStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ActivityStatus.planned,
    );
  }
}

/// Farm activity entity
class ActivityEntity extends Equatable {
  final String id;
  final String farmId;
  final String farmerId;
  final ActivityType type;
  final String title;
  final String description;
  final ActivityStatus status;
  final ActivityPriority priority;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String? cropType;
  final double? quantity;
  final String? unit;
  final double? cost;
  final String? currency;
  final Map<String, dynamic>? metadata;
  final List<String>? images;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ActivityEntity({
    required this.id,
    required this.farmId,
    required this.farmerId,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.scheduledDate,
    required this.createdAt,
    this.completedDate,
    this.cropType,
    this.quantity,
    this.unit,
    this.cost,
    this.currency,
    this.metadata,
    this.images,
    this.notes,
    this.updatedAt,
  });

  /// Check if activity is completed
  bool get isCompleted => status == ActivityStatus.completed;

  /// Check if activity is overdue
  bool get isOverdue {
    if (isCompleted) return false;
    return DateTime.now().isAfter(scheduledDate);
  }

  /// Check if activity is due today
  bool get isDueToday {
    final now = DateTime.now();
    final scheduled = scheduledDate;
    return now.year == scheduled.year &&
        now.month == scheduled.month &&
        now.day == scheduled.day;
  }

  /// Get days until due (negative if overdue)
  int get daysUntilDue {
    return scheduledDate.difference(DateTime.now()).inDays;
  }

  /// Get formatted cost
  String? get formattedCost {
    if (cost == null) return null;
    final currencySymbol = currency ?? 'TSh';
    return '$currencySymbol ${cost!.toStringAsFixed(2)}';
  }

  /// Get formatted quantity
  String? get formattedQuantity {
    if (quantity == null) return null;
    final unitStr = unit ?? '';
    return '${quantity!.toStringAsFixed(1)} $unitStr'.trim();
  }

  /// Formatted scheduled date
  String get formattedScheduledDate {
    return '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}';
  }

  /// Formatted completed date
  String? get formattedCompletedDate {
    if (completedDate == null) return null;
    return '${completedDate!.day}/${completedDate!.month}/${completedDate!.year}';
  }

  /// Formatted created date
  String get formattedCreatedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Formatted updated date
  String? get formattedUpdatedDate {
    if (updatedAt == null) return null;
    return '${updatedAt!.day}/${updatedAt!.month}/${updatedAt!.year}';
  }

  @override
  List<Object?> get props => [
    id,
    farmId,
    farmerId,
    type,
    title,
    description,
    status,
    priority,
    scheduledDate,
    completedDate,
    cropType,
    quantity,
    unit,
    cost,
    currency,
    metadata,
    images,
    notes,
    createdAt,
    updatedAt,
  ];

  ActivityEntity copyWith({
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
    return ActivityEntity(
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

/// Activity creation data
class ActivityCreationData {
  final String farmId;
  final ActivityType type;
  final String title;
  final String description;
  final ActivityPriority priority;
  final DateTime scheduledDate;
  final String? cropType;
  final double? quantity;
  final String? unit;
  final double? cost;
  final String? currency;
  final Map<String, dynamic>? metadata;
  final String? notes;

  const ActivityCreationData({
    required this.farmId,
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.scheduledDate,
    this.cropType,
    this.quantity,
    this.unit,
    this.cost,
    this.currency,
    this.metadata,
    this.notes,
  });
}

/// Activity update data
class ActivityUpdateData {
  final ActivityType? type;
  final String? title;
  final String? description;
  final ActivityStatus? status;
  final ActivityPriority? priority;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final String? cropType;
  final double? quantity;
  final String? unit;
  final double? cost;
  final String? currency;
  final Map<String, dynamic>? metadata;
  final List<String>? images;
  final String? notes;

  const ActivityUpdateData({
    this.type,
    this.title,
    this.description,
    this.status,
    this.priority,
    this.scheduledDate,
    this.completedDate,
    this.cropType,
    this.quantity,
    this.unit,
    this.cost,
    this.currency,
    this.metadata,
    this.images,
    this.notes,
  });

  bool get hasChanges =>
      type != null ||
      title != null ||
      description != null ||
      status != null ||
      priority != null ||
      scheduledDate != null ||
      completedDate != null ||
      cropType != null ||
      quantity != null ||
      unit != null ||
      cost != null ||
      currency != null ||
      metadata != null ||
      images != null ||
      notes != null;
}

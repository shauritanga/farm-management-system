import 'package:equatable/equatable.dart';

/// Farm status enumeration
enum FarmStatus {
  active('active'),
  planning('planning'),
  harvesting('harvesting'),
  inactive('inactive'),
  maintenance('maintenance');

  const FarmStatus(this.value);
  final String value;

  static FarmStatus fromString(String value) {
    return FarmStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => FarmStatus.active,
    );
  }

  String get displayName {
    switch (this) {
      case FarmStatus.active:
        return 'Active';
      case FarmStatus.planning:
        return 'Planning';
      case FarmStatus.harvesting:
        return 'Harvesting';
      case FarmStatus.inactive:
        return 'Inactive';
      case FarmStatus.maintenance:
        return 'Maintenance';
    }
  }
}

/// Farm entity representing a farmer's agricultural land
class FarmEntity extends Equatable {
  final String id;
  final String farmerId;
  final String name;
  final String location;
  final double size; // in hectares
  final List<String> cropTypes;
  final FarmStatus status;
  final String? description;
  final Map<String, dynamic>? coordinates; // lat, lng
  final String? soilType;
  final String? irrigationType;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastActivity;
  final Map<String, dynamic>? weatherData;
  final List<String>? images;
  final List<String>?
  assignedUsers; // User IDs assigned to monitor this farm (Tanzanite feature)

  const FarmEntity({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.location,
    required this.size,
    required this.cropTypes,
    required this.status,
    required this.createdAt,
    this.description,
    this.coordinates,
    this.soilType,
    this.irrigationType,
    this.updatedAt,
    this.lastActivity,
    this.weatherData,
    this.images,
    this.assignedUsers,
  });

  /// Check if farm is active
  bool get isActive => status == FarmStatus.active;

  /// Check if farm is in planning phase
  bool get isPlanning => status == FarmStatus.planning;

  /// Check if farm is being harvested
  bool get isHarvesting => status == FarmStatus.harvesting;

  /// Get formatted size with unit
  String get formattedSize => '${size.toStringAsFixed(1)} hectares';

  /// Get primary crop type
  String? get primaryCrop => cropTypes.isNotEmpty ? cropTypes.first : null;

  /// Get days since last activity
  int? get daysSinceLastActivity {
    if (lastActivity == null) return null;
    return DateTime.now().difference(lastActivity!).inDays;
  }

  /// Check if user is assigned to monitor this farm
  bool isUserAssigned(String userId) {
    return assignedUsers?.contains(userId) ?? false;
  }

  /// Get number of assigned users
  int get assignedUsersCount => assignedUsers?.length ?? 0;

  /// Check if farm has assigned users (Tanzanite feature)
  bool get hasAssignedUsers => assignedUsersCount > 0;

  @override
  List<Object?> get props => [
    id,
    farmerId,
    name,
    location,
    size,
    cropTypes,
    status,
    description,
    coordinates,
    soilType,
    irrigationType,
    createdAt,
    updatedAt,
    lastActivity,
    weatherData,
    images,
    assignedUsers,
  ];

  FarmEntity copyWith({
    String? id,
    String? farmerId,
    String? name,
    String? location,
    double? size,
    List<String>? cropTypes,
    FarmStatus? status,
    String? description,
    Map<String, dynamic>? coordinates,
    String? soilType,
    String? irrigationType,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActivity,
    Map<String, dynamic>? weatherData,
    List<String>? images,
    List<String>? assignedUsers,
  }) {
    return FarmEntity(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      name: name ?? this.name,
      location: location ?? this.location,
      size: size ?? this.size,
      cropTypes: cropTypes ?? this.cropTypes,
      status: status ?? this.status,
      description: description ?? this.description,
      coordinates: coordinates ?? this.coordinates,
      soilType: soilType ?? this.soilType,
      irrigationType: irrigationType ?? this.irrigationType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActivity: lastActivity ?? this.lastActivity,
      weatherData: weatherData ?? this.weatherData,
      images: images ?? this.images,
      assignedUsers: assignedUsers ?? this.assignedUsers,
    );
  }
}

/// Farm creation data
class FarmCreationData {
  final String name;
  final String location;
  final double size;
  final List<String> cropTypes;
  final String? description;
  final Map<String, dynamic>? coordinates;
  final String? soilType;
  final String? irrigationType;

  const FarmCreationData({
    required this.name,
    required this.location,
    required this.size,
    required this.cropTypes,
    this.description,
    this.coordinates,
    this.soilType,
    this.irrigationType,
  });
}

/// Farm update data
class FarmUpdateData {
  final String? name;
  final String? location;
  final double? size;
  final List<String>? cropTypes;
  final FarmStatus? status;
  final String? description;
  final Map<String, dynamic>? coordinates;
  final String? soilType;
  final String? irrigationType;

  const FarmUpdateData({
    this.name,
    this.location,
    this.size,
    this.cropTypes,
    this.status,
    this.description,
    this.coordinates,
    this.soilType,
    this.irrigationType,
  });

  bool get hasChanges =>
      name != null ||
      location != null ||
      size != null ||
      cropTypes != null ||
      status != null ||
      description != null ||
      coordinates != null ||
      soilType != null ||
      irrigationType != null;
}

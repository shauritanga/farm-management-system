import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/farm.dart';

/// Data model for farm with Firestore serialization
class FarmModel extends FarmEntity {
  const FarmModel({
    required super.id,
    required super.farmerId,
    required super.name,
    required super.location,
    required super.size,
    required super.cropTypes,
    required super.status,
    required super.createdAt,
    super.description,
    super.coordinates,
    super.soilType,
    super.irrigationType,
    super.updatedAt,
    super.lastActivity,
    super.weatherData,
    super.images,
    super.assignedUsers,
  });

  /// Create FarmModel from Firestore document
  factory FarmModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FarmModel.fromMap(data, doc.id);
  }

  /// Create FarmModel from Map with optional ID
  factory FarmModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return FarmModel(
      id: id ?? map['id'] ?? '',
      farmerId: map['farmerId'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      size: (map['size'] ?? 0.0).toDouble(),
      cropTypes: _parseStringList(map['cropTypes']),
      status: FarmStatus.fromString(map['status'] ?? 'active'),
      description: map['description'],
      coordinates: map['coordinates'] as Map<String, dynamic>?,
      soilType: map['soilType'],
      irrigationType: map['irrigationType'],
      createdAt: _parseTimestamp(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseTimestamp(map['updatedAt']),
      lastActivity: _parseTimestamp(map['lastActivity']),
      weatherData: map['weatherData'] as Map<String, dynamic>?,
      images: _parseStringList(map['images']),
      assignedUsers: _parseStringList(map['assignedUsers']),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmerId': farmerId,
      'name': name,
      'location': location,
      'size': size,
      'cropTypes': cropTypes,
      'status': status.value,
      'description': description,
      'coordinates': coordinates,
      'soilType': soilType,
      'irrigationType': irrigationType,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'lastActivity':
          lastActivity != null ? Timestamp.fromDate(lastActivity!) : null,
      'weatherData': weatherData,
      'images': images,
      'assignedUsers': assignedUsers,
    };
  }

  /// Convert to Map for creation (excludes computed fields)
  Map<String, dynamic> toCreateMap() {
    final map = toMap();
    map.remove('id'); // ID is set by Firestore
    map['createdAt'] = FieldValue.serverTimestamp();
    return map;
  }

  /// Create FarmModel from FarmEntity
  factory FarmModel.fromEntity(FarmEntity entity) {
    return FarmModel(
      id: entity.id,
      farmerId: entity.farmerId,
      name: entity.name,
      location: entity.location,
      size: entity.size,
      cropTypes: entity.cropTypes,
      status: entity.status,
      description: entity.description,
      coordinates: entity.coordinates,
      soilType: entity.soilType,
      irrigationType: entity.irrigationType,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastActivity: entity.lastActivity,
      weatherData: entity.weatherData,
      images: entity.images,
      assignedUsers: entity.assignedUsers,
    );
  }

  /// Create FarmModel from creation data
  factory FarmModel.fromCreationData(String farmerId, FarmCreationData data) {
    final now = DateTime.now();
    return FarmModel(
      id: '', // Will be set by Firestore
      farmerId: farmerId,
      name: data.name,
      location: data.location,
      size: data.size,
      cropTypes: data.cropTypes,
      status: FarmStatus.active,
      description: data.description,
      coordinates: data.coordinates,
      soilType: data.soilType,
      irrigationType: data.irrigationType,
      createdAt: now,
    );
  }

  /// Helper method to parse string list
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return [];
  }

  /// Helper method to parse Firestore Timestamp
  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    if (timestamp is String) return DateTime.tryParse(timestamp);
    return null;
  }

  @override
  FarmModel copyWith({
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
    return FarmModel(
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

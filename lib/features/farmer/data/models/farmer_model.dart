import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/farmer.dart';

/// Farmer model for data layer
class FarmerModel extends FarmerEntity {
  const FarmerModel({
    required super.id,
    required super.cooperativeId,
    required super.name,
    required super.zone,
    required super.village,
    required super.gender,
    required super.dateOfBirth,
    required super.phone,
    required super.totalTrees,
    required super.fruitingTrees,
    required super.bankNumber,
    required super.bankName,
    required super.crops,
    super.createdAt,
    super.updatedAt,
  });

  /// Create from JSON
  factory FarmerModel.fromJson(Map<String, dynamic> json) {
    return FarmerModel(
      id: json['id']?.toString() ?? '',
      cooperativeId: json['cooperativeId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      zone: json['zone']?.toString() ?? '',
      village: json['village']?.toString() ?? '',
      gender: Gender.fromString(json['gender']?.toString() ?? 'Male'),
      dateOfBirth: DateTime.parse(
        json['dateOfBirth']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      phone: json['phone']?.toString() ?? '',
      totalTrees: int.tryParse(json['totalTrees']?.toString() ?? '0') ?? 0,
      fruitingTrees:
          int.tryParse(json['fruitingTrees']?.toString() ?? '0') ?? 0,
      bankNumber: json['bankNumber']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      crops: _parseCrops(json['crops']),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cooperativeId': cooperativeId,
      'name': name,
      'zone': zone,
      'village': village,
      'gender': gender.value,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'phone': phone,
      'totalTrees': totalTrees,
      'fruitingTrees': fruitingTrees,
      'bankNumber': bankNumber,
      'bankName': bankName,
      'crops': crops,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from entity
  factory FarmerModel.fromEntity(FarmerEntity entity) {
    return FarmerModel(
      id: entity.id,
      cooperativeId: entity.cooperativeId,
      name: entity.name,
      zone: entity.zone,
      village: entity.village,
      gender: entity.gender,
      dateOfBirth: entity.dateOfBirth,
      phone: entity.phone,
      totalTrees: entity.totalTrees,
      fruitingTrees: entity.fruitingTrees,
      bankNumber: entity.bankNumber,
      bankName: entity.bankName,
      crops: entity.crops,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to entity
  FarmerEntity toEntity() {
    return FarmerEntity(
      id: id,
      cooperativeId: cooperativeId,
      name: name,
      zone: zone,
      village: village,
      gender: gender,
      dateOfBirth: dateOfBirth,
      phone: phone,
      totalTrees: totalTrees,
      fruitingTrees: fruitingTrees,
      bankNumber: bankNumber,
      bankName: bankName,
      crops: crops,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create FarmerModel from Firestore document
  factory FarmerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FarmerModel.fromFirestoreMap(data, doc.id);
  }

  /// Create FarmerModel from Firestore map with document ID
  factory FarmerModel.fromFirestoreMap(
    Map<String, dynamic> data,
    String docId,
  ) {
    return FarmerModel(
      id: docId,
      cooperativeId: data['cooperativeId']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      zone: data['zone']?.toString() ?? '',
      village: data['village']?.toString() ?? '',
      gender: Gender.fromString(data['gender']?.toString() ?? 'Male'),
      dateOfBirth: _parseDateTime(data['dateOfBirth']) ?? DateTime.now(),
      phone: data['phone']?.toString() ?? '',
      totalTrees: data['totalTrees'] ?? 0,
      fruitingTrees: data['fruitingTrees'] ?? 0,
      bankNumber: data['bankNumber']?.toString() ?? '',
      bankName: data['bankName']?.toString() ?? '',
      crops: _parseCrops(data['crops']),
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  /// Parse crops from JSON
  static List<String> _parseCrops(dynamic cropsData) {
    if (cropsData == null) return [];

    if (cropsData is List) {
      return cropsData.map((crop) => crop.toString()).toList();
    }

    if (cropsData is String) {
      // Handle comma-separated string
      return cropsData
          .split(',')
          .map((crop) => crop.trim())
          .where((crop) => crop.isNotEmpty)
          .toList();
    }

    return [];
  }

  /// Parse DateTime from various formats (Timestamp, String, etc.)
  static DateTime? _parseDateTime(dynamic dateData) {
    if (dateData == null) return null;

    // Handle Firestore Timestamp
    if (dateData is Timestamp) {
      return dateData.toDate();
    }

    // Handle ISO string
    if (dateData is String) {
      try {
        return DateTime.parse(dateData);
      } catch (e) {
        return null;
      }
    }

    // Handle milliseconds since epoch
    if (dateData is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(dateData);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Create copy with updated fields
  @override
  FarmerModel copyWith({
    String? id,
    String? cooperativeId,
    String? name,
    String? zone,
    String? village,
    Gender? gender,
    DateTime? dateOfBirth,
    String? phone,
    int? totalTrees,
    int? fruitingTrees,
    String? bankNumber,
    String? bankName,
    List<String>? crops,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FarmerModel(
      id: id ?? this.id,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      name: name ?? this.name,
      zone: zone ?? this.zone,
      village: village ?? this.village,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      totalTrees: totalTrees ?? this.totalTrees,
      fruitingTrees: fruitingTrees ?? this.fruitingTrees,
      bankNumber: bankNumber ?? this.bankNumber,
      bankName: bankName ?? this.bankName,
      crops: crops ?? this.crops,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

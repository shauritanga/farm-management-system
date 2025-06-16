import '../../domain/entities/farmer.dart';

/// Farmer model for data layer
class FarmerModel extends FarmerEntity {
  const FarmerModel({
    required String id,
    required String cooperativeId,
    required String name,
    required String zone,
    required String village,
    required Gender gender,
    required DateTime dateOfBirth,
    required String phone,
    required int totalNumberOfTrees,
    required int totalNumberOfTreesWithFruit,
    required String bankNumber,
    required String bankName,
    required List<String> crops,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
         id: id,
         cooperativeId: cooperativeId,
         name: name,
         zone: zone,
         village: village,
         gender: gender,
         dateOfBirth: dateOfBirth,
         phone: phone,
         totalNumberOfTrees: totalNumberOfTrees,
         totalNumberOfTreesWithFruit: totalNumberOfTreesWithFruit,
         bankNumber: bankNumber,
         bankName: bankName,
         crops: crops,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Create from JSON
  factory FarmerModel.fromJson(Map<String, dynamic> json) {
    return FarmerModel(
      id: json['id']?.toString() ?? '',
      cooperativeId: json['cooperative_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      zone: json['zone']?.toString() ?? '',
      village: json['village']?.toString() ?? '',
      gender: Gender.fromString(json['gender']?.toString() ?? 'Male'),
      dateOfBirth: DateTime.parse(
        json['date_of_birth']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      phone: json['phone']?.toString() ?? '',
      totalNumberOfTrees:
          int.tryParse(json['total_number_of_trees']?.toString() ?? '0') ?? 0,
      totalNumberOfTreesWithFruit:
          int.tryParse(
            json['total_number_of_trees_with_fruit']?.toString() ?? '0',
          ) ??
          0,
      bankNumber: json['bank_number']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? '',
      crops: _parseCrops(json['crops']),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cooperative_id': cooperativeId,
      'name': name,
      'zone': zone,
      'village': village,
      'gender': gender.value,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'phone': phone,
      'total_number_of_trees': totalNumberOfTrees,
      'total_number_of_trees_with_fruit': totalNumberOfTreesWithFruit,
      'bank_number': bankNumber,
      'bank_name': bankName,
      'crops': crops,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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
      totalNumberOfTrees: entity.totalNumberOfTrees,
      totalNumberOfTreesWithFruit: entity.totalNumberOfTreesWithFruit,
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
      totalNumberOfTrees: totalNumberOfTrees,
      totalNumberOfTreesWithFruit: totalNumberOfTreesWithFruit,
      bankNumber: bankNumber,
      bankName: bankName,
      crops: crops,
      createdAt: createdAt,
      updatedAt: updatedAt,
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
    int? totalNumberOfTrees,
    int? totalNumberOfTreesWithFruit,
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
      totalNumberOfTrees: totalNumberOfTrees ?? this.totalNumberOfTrees,
      totalNumberOfTreesWithFruit:
          totalNumberOfTreesWithFruit ?? this.totalNumberOfTreesWithFruit,
      bankNumber: bankNumber ?? this.bankNumber,
      bankName: bankName ?? this.bankName,
      crops: crops ?? this.crops,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

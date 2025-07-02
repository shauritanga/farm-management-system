import 'package:equatable/equatable.dart';

/// Gender enum for farmer
enum Gender {
  male('Male'),
  female('Female'),
  other('Other');

  const Gender(this.value);
  final String value;

  static Gender fromString(String value) {
    return Gender.values.firstWhere(
      (gender) => gender.value.toLowerCase() == value.toLowerCase(),
      orElse: () => Gender.male,
    );
  }
}

/// Farmer entity representing a farmer in the cooperative
class FarmerEntity extends Equatable {
  final String id;
  final String cooperativeId;
  final String name;
  final String zone;
  final String village;
  final Gender gender;
  final DateTime dateOfBirth;
  final String phone;
  final int totalTrees;
  final int fruitingTrees;
  final String bankNumber;
  final String bankName;
  final List<String> crops;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FarmerEntity({
    required this.id,
    required this.cooperativeId,
    required this.name,
    required this.zone,
    required this.village,
    required this.gender,
    required this.dateOfBirth,
    required this.phone,
    required this.totalTrees,
    required this.fruitingTrees,
    required this.bankNumber,
    required this.bankName,
    required this.crops,
    this.createdAt,
    this.updatedAt,
  });

  /// Calculate age from date of birth
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Calculate percentage of trees with fruit
  double get fruitingTreesPercentage {
    if (totalTrees == 0) return 0.0;
    return (fruitingTrees / totalTrees) * 100;
  }

  /// Check if farmer has valid bank details
  bool get hasValidBankDetails {
    return bankNumber.isNotEmpty &&
        bankName.isNotEmpty &&
        bankName.toLowerCase() != 'unknown';
  }

  /// Get primary crop (first in the list)
  String get primaryCrop {
    return crops.isNotEmpty ? crops.first : 'Unknown';
  }

  /// Get formatted location
  String get location {
    return '$village, $zone';
  }

  @override
  List<Object?> get props => [
    id,
    cooperativeId,
    name,
    zone,
    village,
    gender,
    dateOfBirth,
    phone,
    totalTrees,
    fruitingTrees,
    bankNumber,
    bankName,
    crops,
    createdAt,
    updatedAt,
  ];

  FarmerEntity copyWith({
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
    return FarmerEntity(
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

/// Farmer creation data for new farmer registration
class CreateFarmerData {
  final String cooperativeId;
  final String name;
  final String zone;
  final String village;
  final Gender gender;
  final DateTime dateOfBirth;
  final String phone;
  final int totalTrees;
  final int fruitingTrees;
  final String bankNumber;
  final String bankName;
  final List<String> crops;

  const CreateFarmerData({
    required this.cooperativeId,
    required this.name,
    required this.zone,
    required this.village,
    required this.gender,
    required this.dateOfBirth,
    required this.phone,
    required this.totalTrees,
    required this.fruitingTrees,
    required this.bankNumber,
    required this.bankName,
    required this.crops,
  });
}

/// Farmer update data for updating existing farmer
class UpdateFarmerData {
  final String? name;
  final String? zone;
  final String? village;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final String? phone;
  final int? totalTrees;
  final int? fruitingTrees;
  final String? bankNumber;
  final String? bankName;
  final List<String>? crops;

  const UpdateFarmerData({
    this.name,
    this.zone,
    this.village,
    this.gender,
    this.dateOfBirth,
    this.phone,
    this.totalTrees,
    this.fruitingTrees,
    this.bankNumber,
    this.bankName,
    this.crops,
  });
}

/// Farmer search criteria
class FarmerSearchCriteria {
  final String? query;
  final String? zone;
  final String? village;
  final Gender? gender;
  final List<String>? crops;
  final int? minTrees;
  final int? maxTrees;

  const FarmerSearchCriteria({
    this.query,
    this.zone,
    this.village,
    this.gender,
    this.crops,
    this.minTrees,
    this.maxTrees,
  });
}

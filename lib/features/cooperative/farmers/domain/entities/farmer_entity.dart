import 'package:cloud_firestore/cloud_firestore.dart';

/// Comprehensive farmer entity matching web portal structure
class FarmerEntity {
  final String id;
  final String cooperativeId;
  final String name;
  final String zone;
  final String village;
  final String gender; // 'Male' or 'Female'
  final String? dateOfBirth;
  final String? phone;
  final int totalTrees;
  final int fruitingTrees;
  final String status; // 'Active', 'Pending', 'Suspended'
  final String? bankNumber;
  final String? bankName;
  final List<String> crops;
  final String? email;
  final String location;
  final double farmSize;
  final String joinDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const FarmerEntity({
    required this.id,
    required this.cooperativeId,
    required this.name,
    required this.zone,
    required this.village,
    required this.gender,
    this.dateOfBirth,
    this.phone,
    required this.totalTrees,
    required this.fruitingTrees,
    required this.status,
    this.bankNumber,
    this.bankName,
    required this.crops,
    this.email,
    required this.location,
    required this.farmSize,
    required this.joinDate,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// Calculate productivity percentage
  double get productivityPercentage {
    if (totalTrees == 0) return 0.0;
    return (fruitingTrees / totalTrees) * 100;
  }

  /// Get formatted location
  String get formattedLocation => '$village, $zone';

  /// Check if farmer has banking information
  bool get hasBankingInfo => 
      bankName != null && bankName!.isNotEmpty && 
      bankNumber != null && bankNumber!.isNotEmpty;

  /// Get farmer initials for avatar
  String get initials {
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
  }

  /// Create from Firestore document
  factory FarmerEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return FarmerEntity(
      id: doc.id,
      cooperativeId: data['cooperativeId'] ?? '',
      name: data['name'] ?? '',
      zone: data['zone'] ?? '',
      village: data['village'] ?? '',
      gender: data['gender'] ?? 'Male',
      dateOfBirth: data['dateOfBirth'],
      phone: data['phone'],
      totalTrees: data['totalTrees'] ?? 0,
      fruitingTrees: data['fruitingTrees'] ?? 0,
      status: data['status'] ?? 'Pending',
      bankNumber: data['bankNumber'],
      bankName: data['bankName'],
      crops: List<String>.from(data['crops'] ?? []),
      email: data['email'],
      location: data['location'] ?? '',
      farmSize: (data['farmSize'] ?? 0).toDouble(),
      joinDate: data['joinDate'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'],
      updatedBy: data['updatedBy'],
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'cooperativeId': cooperativeId,
      'name': name,
      'zone': zone,
      'village': village,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'phone': phone,
      'totalTrees': totalTrees,
      'fruitingTrees': fruitingTrees,
      'status': status,
      'bankNumber': bankNumber,
      'bankName': bankName,
      'crops': crops,
      'email': email ?? '',
      'location': location,
      'farmSize': farmSize,
      'joinDate': joinDate,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Create copy with updated fields
  FarmerEntity copyWith({
    String? id,
    String? cooperativeId,
    String? name,
    String? zone,
    String? village,
    String? gender,
    String? dateOfBirth,
    String? phone,
    int? totalTrees,
    int? fruitingTrees,
    String? status,
    String? bankNumber,
    String? bankName,
    List<String>? crops,
    String? email,
    String? location,
    double? farmSize,
    String? joinDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
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
      status: status ?? this.status,
      bankNumber: bankNumber ?? this.bankNumber,
      bankName: bankName ?? this.bankName,
      crops: crops ?? this.crops,
      email: email ?? this.email,
      location: location ?? this.location,
      farmSize: farmSize ?? this.farmSize,
      joinDate: joinDate ?? this.joinDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FarmerEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FarmerEntity(id: $id, name: $name, zone: $zone, village: $village)';
  }
}

/// Form data model for farmer creation/editing
class FarmerFormData {
  final String name;
  final String zone;
  final String village;
  final String gender;
  final String? dateOfBirth;
  final String? phone;
  final int totalTrees;
  final int fruitingTrees;
  final String status;
  final String? bankNumber;
  final String? bankName;
  final List<String> crops;

  const FarmerFormData({
    required this.name,
    required this.zone,
    required this.village,
    required this.gender,
    this.dateOfBirth,
    this.phone,
    required this.totalTrees,
    required this.fruitingTrees,
    required this.status,
    this.bankNumber,
    this.bankName,
    required this.crops,
  });

  /// Create empty form data
  factory FarmerFormData.empty() {
    return const FarmerFormData(
      name: '',
      zone: '',
      village: '',
      gender: 'Male',
      totalTrees: 0,
      fruitingTrees: 0,
      status: 'Pending',
      crops: [],
    );
  }

  /// Create from farmer entity
  factory FarmerFormData.fromEntity(FarmerEntity farmer) {
    return FarmerFormData(
      name: farmer.name,
      zone: farmer.zone,
      village: farmer.village,
      gender: farmer.gender,
      dateOfBirth: farmer.dateOfBirth,
      phone: farmer.phone,
      totalTrees: farmer.totalTrees,
      fruitingTrees: farmer.fruitingTrees,
      status: farmer.status,
      bankNumber: farmer.bankNumber,
      bankName: farmer.bankName,
      crops: farmer.crops,
    );
  }

  /// Convert to farmer entity for creation
  FarmerEntity toEntity({
    required String cooperativeId,
    required String createdBy,
    String? id,
  }) {
    final now = DateTime.now();
    return FarmerEntity(
      id: id ?? '',
      cooperativeId: cooperativeId,
      name: name,
      zone: zone,
      village: village,
      gender: gender,
      dateOfBirth: dateOfBirth,
      phone: phone,
      totalTrees: totalTrees,
      fruitingTrees: fruitingTrees,
      status: status,
      bankNumber: bankNumber,
      bankName: bankName,
      crops: crops,
      email: '',
      location: '$village, $zone',
      farmSize: 0.0,
      joinDate: DateTime.now().toIso8601String().split('T')[0],
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
      updatedBy: createdBy,
    );
  }

  /// Create copy with updated fields
  FarmerFormData copyWith({
    String? name,
    String? zone,
    String? village,
    String? gender,
    String? dateOfBirth,
    String? phone,
    int? totalTrees,
    int? fruitingTrees,
    String? status,
    String? bankNumber,
    String? bankName,
    List<String>? crops,
  }) {
    return FarmerFormData(
      name: name ?? this.name,
      zone: zone ?? this.zone,
      village: village ?? this.village,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      totalTrees: totalTrees ?? this.totalTrees,
      fruitingTrees: fruitingTrees ?? this.fruitingTrees,
      status: status ?? this.status,
      bankNumber: bankNumber ?? this.bankNumber,
      bankName: bankName ?? this.bankName,
      crops: crops ?? this.crops,
    );
  }

  /// Validate form data
  List<String> validate() {
    final errors = <String>[];

    if (name.trim().isEmpty) {
      errors.add('Name is required');
    }

    if (zone.trim().isEmpty) {
      errors.add('Zone is required');
    }

    if (village.trim().isEmpty) {
      errors.add('Village is required');
    }

    if (!['Male', 'Female'].contains(gender)) {
      errors.add('Gender must be Male or Female');
    }

    if (totalTrees < 0) {
      errors.add('Total trees cannot be negative');
    }

    if (fruitingTrees < 0) {
      errors.add('Fruiting trees cannot be negative');
    }

    if (fruitingTrees > totalTrees) {
      errors.add('Fruiting trees cannot exceed total trees');
    }

    if (phone != null && phone!.isNotEmpty && phone!.length < 10) {
      errors.add('Phone number must be at least 10 digits');
    }

    return errors;
  }

  /// Check if form is valid
  bool get isValid => validate().isEmpty;
}

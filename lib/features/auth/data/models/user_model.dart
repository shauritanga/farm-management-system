import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

/// Data model for user with Firestore serialization
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.userType,
    required super.status,
    required super.createdAt,
    super.phoneNumber,
    super.profileImageUrl,
    super.lastLoginAt,
    super.farmName,
    super.farmLocation,
    super.farmSize,
    super.cropTypes,
    super.cooperativeId,
    super.cooperativeName,
    super.role,
    super.permissions,
    super.subscriptionPackage,
    super.subscriptionStatus,
    super.subscriptionEndDate,
    super.trialEndDate,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data, doc.id);
  }

  /// Create UserModel from Map with optional ID
  factory UserModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return UserModel(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      userType: UserType.fromString(map['userType'] ?? 'farmer'),
      status: UserStatus.fromString(map['status'] ?? 'active'),
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: _parseTimestamp(map['createdAt']),
      lastLoginAt: _parseTimestamp(map['lastLoginAt']),
      farmName: map['farmName'],
      farmLocation: map['farmLocation'],
      farmSize: map['farmSize']?.toDouble(),
      cropTypes: _parseStringList(map['cropTypes']),
      cooperativeId: map['cooperativeId'],
      cooperativeName: map['cooperativeName'],
      role: map['role'],
      permissions: _parseStringList(map['permissions']),
      subscriptionPackage: map['subscriptionPackage'] ?? 'free_tier',
      subscriptionStatus: map['subscriptionStatus'] ?? 'trial',
      subscriptionEndDate: _parseTimestamp(map['subscriptionEndDate']),
      trialEndDate: _parseTimestamp(map['trialEndDate']),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'userType': userType.value,
      'status': status.value,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'farmName': farmName,
      'farmLocation': farmLocation,
      'farmSize': farmSize,
      'cropTypes': cropTypes,
      'cooperativeId': cooperativeId,
      'cooperativeName': cooperativeName,
      'role': role,
      'permissions': permissions,
      'subscriptionPackage': subscriptionPackage,
      'subscriptionStatus': subscriptionStatus,
      'subscriptionEndDate':
          subscriptionEndDate != null
              ? Timestamp.fromDate(subscriptionEndDate!)
              : null,
      'trialEndDate':
          trialEndDate != null ? Timestamp.fromDate(trialEndDate!) : null,
    };
  }

  /// Convert to Map for creation (excludes computed fields)
  Map<String, dynamic> toCreateMap() {
    final map = toMap();
    map.remove('id'); // ID is set by Firestore
    return map;
  }

  /// Create UserModel from UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      userType: entity.userType,
      status: entity.status,
      phoneNumber: entity.phoneNumber,
      profileImageUrl: entity.profileImageUrl,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      farmName: entity.farmName,
      farmLocation: entity.farmLocation,
      farmSize: entity.farmSize,
      cropTypes: entity.cropTypes,
      cooperativeId: entity.cooperativeId,
      cooperativeName: entity.cooperativeName,
      role: entity.role,
      permissions: entity.permissions,
      subscriptionPackage: entity.subscriptionPackage,
      subscriptionStatus: entity.subscriptionStatus,
      subscriptionEndDate: entity.subscriptionEndDate,
      trialEndDate: entity.trialEndDate,
    );
  }

  /// Helper method to parse Firestore Timestamp
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    return DateTime.now();
  }

  /// Helper method to parse string lists
  static List<String>? _parseStringList(dynamic list) {
    if (list == null) return null;
    if (list is List) {
      return list.map((item) => item.toString()).toList();
    }
    return null;
  }

  @override
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserType? userType,
    UserStatus? status,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? farmName,
    String? farmLocation,
    double? farmSize,
    List<String>? cropTypes,
    String? cooperativeId,
    String? cooperativeName,
    String? role,
    List<String>? permissions,
    String? subscriptionPackage,
    String? subscriptionStatus,
    DateTime? subscriptionEndDate,
    DateTime? trialEndDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      farmName: farmName ?? this.farmName,
      farmLocation: farmLocation ?? this.farmLocation,
      farmSize: farmSize ?? this.farmSize,
      cropTypes: cropTypes ?? this.cropTypes,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      cooperativeName: cooperativeName ?? this.cooperativeName,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      subscriptionPackage: subscriptionPackage ?? this.subscriptionPackage,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
    );
  }
}

/// Registration data for farmers
class FarmerRegistrationData {
  final String name;
  final String email;
  final String password;
  final String? phoneNumber;
  final String? farmName;
  final String? farmLocation;
  final double? farmSize;
  final List<String>? cropTypes;
  final String? subscriptionPackage;
  final String? subscriptionStatus;
  final DateTime? trialEndDate;

  const FarmerRegistrationData({
    required this.name,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.farmName,
    this.farmLocation,
    this.farmSize,
    this.cropTypes,
    this.subscriptionPackage,
    this.subscriptionStatus,
    this.trialEndDate,
  });
}

/// Login credentials
class LoginCredentials {
  final String email;
  final String password;

  const LoginCredentials({required this.email, required this.password});
}

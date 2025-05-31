import 'package:equatable/equatable.dart';

/// User types in the agricultural platform
enum UserType {
  farmer('farmer'),
  cooperative('cooperative');

  const UserType(this.value);
  final String value;

  static UserType fromString(String value) {
    return UserType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => UserType.farmer,
    );
  }
}

/// User status for account management
enum UserStatus {
  active('active'),
  inactive('inactive'),
  suspended('suspended'),
  pending('pending');

  const UserStatus(this.value);
  final String value;

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => UserStatus.active,
    );
  }
}

/// Core user entity for the agricultural platform
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserType userType;
  final UserStatus status;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  // Farmer-specific fields
  final String? farmName;
  final String? farmLocation;
  final double? farmSize; // in hectares
  final List<String>? cropTypes;

  // Cooperative-specific fields
  final String? cooperativeId;
  final String? cooperativeName;
  final String? role; // e.g., 'admin', 'manager', 'field_officer'
  final List<String>? permissions;

  // Subscription fields
  final String? subscriptionPackage; // 'free_tier', 'serengeti', 'tanzanite'
  final String? subscriptionStatus; // 'active', 'expired', 'cancelled', 'trial'
  final DateTime? subscriptionEndDate;
  final DateTime? trialEndDate;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    required this.status,
    required this.createdAt,
    this.phoneNumber,
    this.profileImageUrl,
    this.lastLoginAt,
    this.farmName,
    this.farmLocation,
    this.farmSize,
    this.cropTypes,
    this.cooperativeId,
    this.cooperativeName,
    this.role,
    this.permissions,
    this.subscriptionPackage,
    this.subscriptionStatus,
    this.subscriptionEndDate,
    this.trialEndDate,
  });

  /// Check if user is a farmer
  bool get isFarmer => userType == UserType.farmer;

  /// Check if user is a cooperative user
  bool get isCooperative => userType == UserType.cooperative;

  /// Check if user account is active
  bool get isActive => status == UserStatus.active;

  /// Check if user has specific permission (for cooperative users)
  bool hasPermission(String permission) {
    return permissions?.contains(permission) ?? false;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    userType,
    status,
    phoneNumber,
    profileImageUrl,
    createdAt,
    lastLoginAt,
    farmName,
    farmLocation,
    farmSize,
    cropTypes,
    cooperativeId,
    cooperativeName,
    role,
    permissions,
    subscriptionPackage,
    subscriptionStatus,
    subscriptionEndDate,
    trialEndDate,
  ];

  UserEntity copyWith({
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
    return UserEntity(
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

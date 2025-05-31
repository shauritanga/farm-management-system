import 'package:equatable/equatable.dart';

/// Subscription package types for farmers
enum SubscriptionPackage {
  freeTier('free_tier', 'Free Tier', 0.0),
  serengeti('serengeti', 'Serengeti Package', 0.99),
  tanzanite('tanzanite', 'Tanzanite Package', 3.99);

  const SubscriptionPackage(this.value, this.displayName, this.monthlyPrice);

  final String value;
  final String displayName;
  final double monthlyPrice;

  static SubscriptionPackage fromString(String value) {
    return SubscriptionPackage.values.firstWhere(
      (package) => package.value == value,
      orElse: () => SubscriptionPackage.freeTier,
    );
  }

  /// Get package description
  String get description {
    switch (this) {
      case SubscriptionPackage.freeTier:
        return 'Perfect for getting started with basic farm management';
      case SubscriptionPackage.serengeti:
        return 'Ideal for farmers managing multiple farms';
      case SubscriptionPackage.tanzanite:
        return 'Complete solution with team collaboration features';
    }
  }

  /// Get package features
  List<String> get features {
    switch (this) {
      case SubscriptionPackage.freeTier:
        return [
          'Manage 1 farm',
          '14-day trial period',
          'Basic crop tracking',
          'Weather updates',
          'Community support',
        ];
      case SubscriptionPackage.serengeti:
        return [
          'Unlimited farms',
          'Advanced analytics',
          'Market price alerts',
          'Crop planning tools',
          'Priority support',
          'Export reports',
        ];
      case SubscriptionPackage.tanzanite:
        return [
          'Everything in Serengeti',
          'Team collaboration',
          'User management',
          'Role-based permissions',
          'Advanced reporting',
          'API access',
          'Dedicated support',
        ];
    }
  }

  /// Get maximum farms allowed
  int? get maxFarms {
    switch (this) {
      case SubscriptionPackage.freeTier:
        return 1;
      case SubscriptionPackage.serengeti:
        return null; // Unlimited
      case SubscriptionPackage.tanzanite:
        return null; // Unlimited
    }
  }

  /// Check if package allows team management
  bool get allowsTeamManagement {
    return this == SubscriptionPackage.tanzanite;
  }

  /// Check if package is premium
  bool get isPremium {
    return this != SubscriptionPackage.freeTier;
  }
}

/// Subscription status
enum SubscriptionStatus {
  active('active'),
  expired('expired'),
  cancelled('cancelled'),
  trial('trial');

  const SubscriptionStatus(this.value);
  final String value;

  static SubscriptionStatus fromString(String value) {
    return SubscriptionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SubscriptionStatus.trial,
    );
  }
}

/// Subscription entity
class SubscriptionEntity extends Equatable {
  final String id;
  final String userId;
  final SubscriptionPackage package;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? trialEndDate;
  final bool autoRenew;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SubscriptionEntity({
    required this.id,
    required this.userId,
    required this.package,
    required this.status,
    required this.startDate,
    this.endDate,
    this.trialEndDate,
    required this.autoRenew,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if subscription is active
  bool get isActive {
    if (status != SubscriptionStatus.active &&
        status != SubscriptionStatus.trial) {
      return false;
    }

    final now = DateTime.now();

    // Check trial period for free tier
    if (package == SubscriptionPackage.freeTier && trialEndDate != null) {
      return now.isBefore(trialEndDate!);
    }

    // Check subscription end date for premium packages
    if (endDate != null) {
      return now.isBefore(endDate!);
    }

    return true;
  }

  /// Get days remaining in subscription
  int? get daysRemaining {
    final now = DateTime.now();

    if (package == SubscriptionPackage.freeTier && trialEndDate != null) {
      final difference = trialEndDate!.difference(now).inDays;
      return difference > 0 ? difference : 0;
    }

    if (endDate != null) {
      final difference = endDate!.difference(now).inDays;
      return difference > 0 ? difference : 0;
    }

    return null;
  }

  /// Check if subscription is in trial period
  bool get isInTrial {
    return status == SubscriptionStatus.trial ||
        (package == SubscriptionPackage.freeTier && trialEndDate != null);
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    package,
    status,
    startDate,
    endDate,
    trialEndDate,
    autoRenew,
    createdAt,
    updatedAt,
  ];

  SubscriptionEntity copyWith({
    String? id,
    String? userId,
    SubscriptionPackage? package,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? trialEndDate,
    bool? autoRenew,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      package: package ?? this.package,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      autoRenew: autoRenew ?? this.autoRenew,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

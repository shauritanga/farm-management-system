import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/cooperative_settings.dart';
import '../../domain/entities/cooperative_settings_extended.dart';
import '../../domain/entities/cooperative_settings_final.dart';

/// Data model for cooperative settings with Firestore serialization
class CooperativeSettingsModel extends CooperativeSettings {
  const CooperativeSettingsModel({
    required super.basicInfo,
    required super.contactDetails,
    required super.businessSettings,
    required super.operationalSettings,
    required super.notificationSettings,
    required super.securitySettings,
    required super.integrationSettings,
  });

  /// Create CooperativeSettingsModel from Firestore document
  factory CooperativeSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CooperativeSettingsModel.fromMap(data);
  }

  /// Create CooperativeSettingsModel from Map
  factory CooperativeSettingsModel.fromMap(Map<String, dynamic> map) {
    return CooperativeSettingsModel(
      basicInfo: BasicInfo.fromMap(map['basicInfo'] ?? {}),
      contactDetails: ContactDetails.fromMap(map['contactDetails'] ?? {}),
      businessSettings: BusinessSettings.fromMap(map['businessSettings'] ?? {}),
      operationalSettings: OperationalSettings.fromMap(
        map['operationalSettings'] ?? {},
      ),
      notificationSettings: NotificationSettings.fromMap(
        map['notificationSettings'] ?? {},
      ),
      securitySettings: SecuritySettings.fromMap(map['securitySettings'] ?? {}),
      integrationSettings: IntegrationSettings.fromMap(
        map['integrationSettings'] ?? {},
      ),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'basicInfo': basicInfo.toMap(),
      'contactDetails': contactDetails.toMap(),
      'businessSettings': businessSettings.toMap(),
      'operationalSettings': operationalSettings.toMap(),
      'notificationSettings': notificationSettings.toMap(),
      'securitySettings': securitySettings.toMap(),
      'integrationSettings': integrationSettings.toMap(),
    };
  }

  /// Create default settings for new cooperative
  factory CooperativeSettingsModel.defaultSettings() {
    return CooperativeSettingsModel(
      basicInfo: BasicInfo.defaultInfo(),
      contactDetails: ContactDetails.defaultDetails(),
      businessSettings: BusinessSettings.defaultSettings(),
      operationalSettings: OperationalSettings.defaultSettings(),
      notificationSettings: NotificationSettings.defaultSettings(),
      securitySettings: SecuritySettings.defaultSettings(),
      integrationSettings: IntegrationSettings.defaultSettings(),
    );
  }

  /// Create CooperativeSettingsModel from entity
  factory CooperativeSettingsModel.fromEntity(CooperativeSettings entity) {
    return CooperativeSettingsModel(
      basicInfo: entity.basicInfo,
      contactDetails: entity.contactDetails,
      businessSettings: entity.businessSettings,
      operationalSettings: entity.operationalSettings,
      notificationSettings: entity.notificationSettings,
      securitySettings: entity.securitySettings,
      integrationSettings: entity.integrationSettings,
    );
  }

  @override
  CooperativeSettingsModel copyWith({
    BasicInfo? basicInfo,
    ContactDetails? contactDetails,
    BusinessSettings? businessSettings,
    OperationalSettings? operationalSettings,
    NotificationSettings? notificationSettings,
    SecuritySettings? securitySettings,
    IntegrationSettings? integrationSettings,
  }) {
    return CooperativeSettingsModel(
      basicInfo: basicInfo ?? this.basicInfo,
      contactDetails: contactDetails ?? this.contactDetails,
      businessSettings: businessSettings ?? this.businessSettings,
      operationalSettings: operationalSettings ?? this.operationalSettings,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      securitySettings: securitySettings ?? this.securitySettings,
      integrationSettings: integrationSettings ?? this.integrationSettings,
    );
  }
}

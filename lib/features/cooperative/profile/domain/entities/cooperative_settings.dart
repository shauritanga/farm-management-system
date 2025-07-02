import 'package:equatable/equatable.dart';
import 'cooperative_settings_extended.dart';
import 'cooperative_settings_final.dart';

/// Core cooperative settings entity
class CooperativeSettings extends Equatable {
  final BasicInfo basicInfo;
  final ContactDetails contactDetails;
  final BusinessSettings businessSettings;
  final OperationalSettings operationalSettings;
  final NotificationSettings notificationSettings;
  final SecuritySettings securitySettings;
  final IntegrationSettings integrationSettings;

  const CooperativeSettings({
    required this.basicInfo,
    required this.contactDetails,
    required this.businessSettings,
    required this.operationalSettings,
    required this.notificationSettings,
    required this.securitySettings,
    required this.integrationSettings,
  });

  @override
  List<Object?> get props => [
    basicInfo,
    contactDetails,
    businessSettings,
    operationalSettings,
    notificationSettings,
    securitySettings,
    integrationSettings,
  ];

  CooperativeSettings copyWith({
    BasicInfo? basicInfo,
    ContactDetails? contactDetails,
    BusinessSettings? businessSettings,
    OperationalSettings? operationalSettings,
    NotificationSettings? notificationSettings,
    SecuritySettings? securitySettings,
    IntegrationSettings? integrationSettings,
  }) {
    return CooperativeSettings(
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

/// Basic information about the cooperative
class BasicInfo extends Equatable {
  final String name;
  final String registrationNumber;
  final String establishedDate;
  final String legalStatus;
  final String website;
  final String description;
  final String logoUrl;

  const BasicInfo({
    required this.name,
    required this.registrationNumber,
    required this.establishedDate,
    required this.legalStatus,
    required this.website,
    required this.description,
    required this.logoUrl,
  });

  factory BasicInfo.fromMap(Map<String, dynamic> map) {
    return BasicInfo(
      name: map['name'] ?? '',
      registrationNumber: map['registrationNumber'] ?? '',
      establishedDate: map['establishedDate'] ?? '',
      legalStatus: map['legalStatus'] ?? '',
      website: map['website'] ?? '',
      description: map['description'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'registrationNumber': registrationNumber,
      'establishedDate': establishedDate,
      'legalStatus': legalStatus,
      'website': website,
      'description': description,
      'logoUrl': logoUrl,
    };
  }

  factory BasicInfo.defaultInfo() {
    return const BasicInfo(
      name: '',
      registrationNumber: '',
      establishedDate: '',
      legalStatus: 'Cooperative Society',
      website: '',
      description: '',
      logoUrl: '',
    );
  }

  @override
  List<Object?> get props => [
    name,
    registrationNumber,
    establishedDate,
    legalStatus,
    website,
    description,
    logoUrl,
  ];

  BasicInfo copyWith({
    String? name,
    String? registrationNumber,
    String? establishedDate,
    String? legalStatus,
    String? website,
    String? description,
    String? logoUrl,
  }) {
    return BasicInfo(
      name: name ?? this.name,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      establishedDate: establishedDate ?? this.establishedDate,
      legalStatus: legalStatus ?? this.legalStatus,
      website: website ?? this.website,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}

/// Contact details for the cooperative
class ContactDetails extends Equatable {
  final String primaryEmail;
  final String secondaryEmail;
  final String primaryPhone;
  final String secondaryPhone;
  final Address address;

  const ContactDetails({
    required this.primaryEmail,
    required this.secondaryEmail,
    required this.primaryPhone,
    required this.secondaryPhone,
    required this.address,
  });

  factory ContactDetails.fromMap(Map<String, dynamic> map) {
    return ContactDetails(
      primaryEmail: map['primaryEmail'] ?? '',
      secondaryEmail: map['secondaryEmail'] ?? '',
      primaryPhone: map['primaryPhone'] ?? '',
      secondaryPhone: map['secondaryPhone'] ?? '',
      address: Address.fromMap(map['address'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryEmail': primaryEmail,
      'secondaryEmail': secondaryEmail,
      'primaryPhone': primaryPhone,
      'secondaryPhone': secondaryPhone,
      'address': address.toMap(),
    };
  }

  factory ContactDetails.defaultDetails() {
    return ContactDetails(
      primaryEmail: '',
      secondaryEmail: '',
      primaryPhone: '',
      secondaryPhone: '',
      address: Address.defaultAddress(),
    );
  }

  @override
  List<Object?> get props => [
    primaryEmail,
    secondaryEmail,
    primaryPhone,
    secondaryPhone,
    address,
  ];

  ContactDetails copyWith({
    String? primaryEmail,
    String? secondaryEmail,
    String? primaryPhone,
    String? secondaryPhone,
    Address? address,
  }) {
    return ContactDetails(
      primaryEmail: primaryEmail ?? this.primaryEmail,
      secondaryEmail: secondaryEmail ?? this.secondaryEmail,
      primaryPhone: primaryPhone ?? this.primaryPhone,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      address: address ?? this.address,
    );
  }
}

/// Address information
class Address extends Equatable {
  final String street;
  final String city;
  final String region;
  final String postalCode;
  final String country;

  const Address({
    required this.street,
    required this.city,
    required this.region,
    required this.postalCode,
    required this.country,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      region: map['region'] ?? '',
      postalCode: map['postalCode'] ?? '',
      country: map['country'] ?? 'Tanzania',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'region': region,
      'postalCode': postalCode,
      'country': country,
    };
  }

  factory Address.defaultAddress() {
    return const Address(
      street: '',
      city: '',
      region: '',
      postalCode: '',
      country: 'Tanzania',
    );
  }

  @override
  List<Object?> get props => [street, city, region, postalCode, country];

  Address copyWith({
    String? street,
    String? city,
    String? region,
    String? postalCode,
    String? country,
  }) {
    return Address(
      street: street ?? this.street,
      city: city ?? this.city,
      region: region ?? this.region,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
    );
  }
}

/// Business settings for the cooperative
class BusinessSettings extends Equatable {
  final String currency;
  final String timezone;
  final String language;
  final int fiscalYearStart;
  final double commissionRate;
  final double minimumSaleAmount;
  final double maxCreditLimit;
  final int paymentTerms;

  const BusinessSettings({
    required this.currency,
    required this.timezone,
    required this.language,
    required this.fiscalYearStart,
    required this.commissionRate,
    required this.minimumSaleAmount,
    required this.maxCreditLimit,
    required this.paymentTerms,
  });

  factory BusinessSettings.fromMap(Map<String, dynamic> map) {
    return BusinessSettings(
      currency: map['currency'] ?? 'TZS',
      timezone: map['timezone'] ?? 'Africa/Dar_es_Salaam',
      language: map['language'] ?? 'en',
      fiscalYearStart: map['fiscalYearStart'] ?? 1,
      commissionRate: (map['commissionRate'] ?? 5.0).toDouble(),
      minimumSaleAmount: (map['minimumSaleAmount'] ?? 1000.0).toDouble(),
      maxCreditLimit: (map['maxCreditLimit'] ?? 100000.0).toDouble(),
      paymentTerms: map['paymentTerms'] ?? 30,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'timezone': timezone,
      'language': language,
      'fiscalYearStart': fiscalYearStart,
      'commissionRate': commissionRate,
      'minimumSaleAmount': minimumSaleAmount,
      'maxCreditLimit': maxCreditLimit,
      'paymentTerms': paymentTerms,
    };
  }

  factory BusinessSettings.defaultSettings() {
    return const BusinessSettings(
      currency: 'TZS',
      timezone: 'Africa/Dar_es_Salaam',
      language: 'en',
      fiscalYearStart: 1,
      commissionRate: 5.0,
      minimumSaleAmount: 1000.0,
      maxCreditLimit: 100000.0,
      paymentTerms: 30,
    );
  }

  @override
  List<Object?> get props => [
    currency,
    timezone,
    language,
    fiscalYearStart,
    commissionRate,
    minimumSaleAmount,
    maxCreditLimit,
    paymentTerms,
  ];

  BusinessSettings copyWith({
    String? currency,
    String? timezone,
    String? language,
    int? fiscalYearStart,
    double? commissionRate,
    double? minimumSaleAmount,
    double? maxCreditLimit,
    int? paymentTerms,
  }) {
    return BusinessSettings(
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      fiscalYearStart: fiscalYearStart ?? this.fiscalYearStart,
      commissionRate: commissionRate ?? this.commissionRate,
      minimumSaleAmount: minimumSaleAmount ?? this.minimumSaleAmount,
      maxCreditLimit: maxCreditLimit ?? this.maxCreditLimit,
      paymentTerms: paymentTerms ?? this.paymentTerms,
    );
  }
}

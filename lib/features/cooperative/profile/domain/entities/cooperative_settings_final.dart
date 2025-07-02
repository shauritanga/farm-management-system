import 'package:equatable/equatable.dart';

/// Security settings for the cooperative
class SecuritySettings extends Equatable {
  final bool twoFactorAuth;
  final int sessionTimeout;
  final PasswordPolicy passwordPolicy;
  final List<String> ipWhitelist;
  final bool auditLogging;

  const SecuritySettings({
    required this.twoFactorAuth,
    required this.sessionTimeout,
    required this.passwordPolicy,
    required this.ipWhitelist,
    required this.auditLogging,
  });

  factory SecuritySettings.fromMap(Map<String, dynamic> map) {
    return SecuritySettings(
      twoFactorAuth: map['twoFactorAuth'] ?? false,
      sessionTimeout: map['sessionTimeout'] ?? 3600,
      passwordPolicy: PasswordPolicy.fromMap(map['passwordPolicy'] ?? {}),
      ipWhitelist: List<String>.from(map['ipWhitelist'] ?? []),
      auditLogging: map['auditLogging'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'twoFactorAuth': twoFactorAuth,
      'sessionTimeout': sessionTimeout,
      'passwordPolicy': passwordPolicy.toMap(),
      'ipWhitelist': ipWhitelist,
      'auditLogging': auditLogging,
    };
  }

  factory SecuritySettings.defaultSettings() {
    return SecuritySettings(
      twoFactorAuth: false,
      sessionTimeout: 3600,
      passwordPolicy: PasswordPolicy.defaultPolicy(),
      ipWhitelist: const [],
      auditLogging: true,
    );
  }

  @override
  List<Object?> get props => [
    twoFactorAuth,
    sessionTimeout,
    passwordPolicy,
    ipWhitelist,
    auditLogging,
  ];

  SecuritySettings copyWith({
    bool? twoFactorAuth,
    int? sessionTimeout,
    PasswordPolicy? passwordPolicy,
    List<String>? ipWhitelist,
    bool? auditLogging,
  }) {
    return SecuritySettings(
      twoFactorAuth: twoFactorAuth ?? this.twoFactorAuth,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      passwordPolicy: passwordPolicy ?? this.passwordPolicy,
      ipWhitelist: ipWhitelist ?? this.ipWhitelist,
      auditLogging: auditLogging ?? this.auditLogging,
    );
  }
}

/// Password policy settings
class PasswordPolicy extends Equatable {
  final int minLength;
  final bool requireUppercase;
  final bool requireNumbers;
  final bool requireSpecialChars;

  const PasswordPolicy({
    required this.minLength,
    required this.requireUppercase,
    required this.requireNumbers,
    required this.requireSpecialChars,
  });

  factory PasswordPolicy.fromMap(Map<String, dynamic> map) {
    return PasswordPolicy(
      minLength: map['minLength'] ?? 8,
      requireUppercase: map['requireUppercase'] ?? true,
      requireNumbers: map['requireNumbers'] ?? true,
      requireSpecialChars: map['requireSpecialChars'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'minLength': minLength,
      'requireUppercase': requireUppercase,
      'requireNumbers': requireNumbers,
      'requireSpecialChars': requireSpecialChars,
    };
  }

  factory PasswordPolicy.defaultPolicy() {
    return const PasswordPolicy(
      minLength: 8,
      requireUppercase: true,
      requireNumbers: true,
      requireSpecialChars: false,
    );
  }

  @override
  List<Object?> get props => [
    minLength,
    requireUppercase,
    requireNumbers,
    requireSpecialChars,
  ];

  PasswordPolicy copyWith({
    int? minLength,
    bool? requireUppercase,
    bool? requireNumbers,
    bool? requireSpecialChars,
  }) {
    return PasswordPolicy(
      minLength: minLength ?? this.minLength,
      requireUppercase: requireUppercase ?? this.requireUppercase,
      requireNumbers: requireNumbers ?? this.requireNumbers,
      requireSpecialChars: requireSpecialChars ?? this.requireSpecialChars,
    );
  }
}

/// Integration settings for the cooperative
class IntegrationSettings extends Equatable {
  final BankingApi bankingApi;
  final SmsProvider smsProvider;
  final EmailProvider emailProvider;

  const IntegrationSettings({
    required this.bankingApi,
    required this.smsProvider,
    required this.emailProvider,
  });

  factory IntegrationSettings.fromMap(Map<String, dynamic> map) {
    return IntegrationSettings(
      bankingApi: BankingApi.fromMap(map['bankingApi'] ?? {}),
      smsProvider: SmsProvider.fromMap(map['smsProvider'] ?? {}),
      emailProvider: EmailProvider.fromMap(map['emailProvider'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bankingApi': bankingApi.toMap(),
      'smsProvider': smsProvider.toMap(),
      'emailProvider': emailProvider.toMap(),
    };
  }

  factory IntegrationSettings.defaultSettings() {
    return IntegrationSettings(
      bankingApi: BankingApi.defaultSettings(),
      smsProvider: SmsProvider.defaultSettings(),
      emailProvider: EmailProvider.defaultSettings(),
    );
  }

  @override
  List<Object?> get props => [bankingApi, smsProvider, emailProvider];

  IntegrationSettings copyWith({
    BankingApi? bankingApi,
    SmsProvider? smsProvider,
    EmailProvider? emailProvider,
  }) {
    return IntegrationSettings(
      bankingApi: bankingApi ?? this.bankingApi,
      smsProvider: smsProvider ?? this.smsProvider,
      emailProvider: emailProvider ?? this.emailProvider,
    );
  }
}

/// Banking API integration settings
class BankingApi extends Equatable {
  final bool enabled;
  final String provider;
  final String apiKey;

  const BankingApi({
    required this.enabled,
    required this.provider,
    required this.apiKey,
  });

  factory BankingApi.fromMap(Map<String, dynamic> map) {
    return BankingApi(
      enabled: map['enabled'] ?? false,
      provider: map['provider'] ?? '',
      apiKey: map['apiKey'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'enabled': enabled, 'provider': provider, 'apiKey': apiKey};
  }

  factory BankingApi.defaultSettings() {
    return const BankingApi(enabled: false, provider: '', apiKey: '');
  }

  @override
  List<Object?> get props => [enabled, provider, apiKey];

  BankingApi copyWith({bool? enabled, String? provider, String? apiKey}) {
    return BankingApi(
      enabled: enabled ?? this.enabled,
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
    );
  }
}

/// SMS provider integration settings
class SmsProvider extends Equatable {
  final bool enabled;
  final String provider;
  final String apiKey;

  const SmsProvider({
    required this.enabled,
    required this.provider,
    required this.apiKey,
  });

  factory SmsProvider.fromMap(Map<String, dynamic> map) {
    return SmsProvider(
      enabled: map['enabled'] ?? false,
      provider: map['provider'] ?? '',
      apiKey: map['apiKey'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'enabled': enabled, 'provider': provider, 'apiKey': apiKey};
  }

  factory SmsProvider.defaultSettings() {
    return const SmsProvider(enabled: false, provider: '', apiKey: '');
  }

  @override
  List<Object?> get props => [enabled, provider, apiKey];

  SmsProvider copyWith({bool? enabled, String? provider, String? apiKey}) {
    return SmsProvider(
      enabled: enabled ?? this.enabled,
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
    );
  }
}

/// Email provider integration settings
class EmailProvider extends Equatable {
  final bool enabled;
  final String provider;
  final SmtpSettings smtpSettings;

  const EmailProvider({
    required this.enabled,
    required this.provider,
    required this.smtpSettings,
  });

  factory EmailProvider.fromMap(Map<String, dynamic> map) {
    return EmailProvider(
      enabled: map['enabled'] ?? false,
      provider: map['provider'] ?? '',
      smtpSettings: SmtpSettings.fromMap(map['smtpSettings'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'provider': provider,
      'smtpSettings': smtpSettings.toMap(),
    };
  }

  factory EmailProvider.defaultSettings() {
    return EmailProvider(
      enabled: false,
      provider: '',
      smtpSettings: SmtpSettings.defaultSettings(),
    );
  }

  @override
  List<Object?> get props => [enabled, provider, smtpSettings];

  EmailProvider copyWith({
    bool? enabled,
    String? provider,
    SmtpSettings? smtpSettings,
  }) {
    return EmailProvider(
      enabled: enabled ?? this.enabled,
      provider: provider ?? this.provider,
      smtpSettings: smtpSettings ?? this.smtpSettings,
    );
  }
}

/// SMTP settings for email provider
class SmtpSettings extends Equatable {
  final String host;
  final int port;
  final String username;
  final String password;

  const SmtpSettings({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
  });

  factory SmtpSettings.fromMap(Map<String, dynamic> map) {
    return SmtpSettings(
      host: map['host'] ?? '',
      port: map['port'] ?? 587,
      username: map['username'] ?? '',
      password: map['password'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'host': host,
      'port': port,
      'username': username,
      'password': password,
    };
  }

  factory SmtpSettings.defaultSettings() {
    return const SmtpSettings(host: '', port: 587, username: '', password: '');
  }

  @override
  List<Object?> get props => [host, port, username, password];

  SmtpSettings copyWith({
    String? host,
    int? port,
    String? username,
    String? password,
  }) {
    return SmtpSettings(
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}

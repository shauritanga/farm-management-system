/// Farm settings entity
class FarmSettingsEntity {
  final String id;
  final String farmId;
  final GeneralSettings general;
  final NotificationSettings notifications;
  final ActivitySettings activities;
  final WeatherSettings weather;
  final SecuritySettings security;
  final BackupSettings backup;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FarmSettingsEntity({
    required this.id,
    required this.farmId,
    required this.general,
    required this.notifications,
    required this.activities,
    required this.weather,
    required this.security,
    required this.backup,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// General farm settings
class GeneralSettings {
  final String units; // metric, imperial
  final String language;
  final String timezone;
  final String currency;
  final bool autoSave;
  final int autoSaveInterval; // minutes
  final bool showTips;
  final String theme; // light, dark, auto

  const GeneralSettings({
    this.units = 'metric',
    this.language = 'en',
    this.timezone = 'UTC',
    this.currency = 'USD',
    this.autoSave = true,
    this.autoSaveInterval = 30,
    this.showTips = true,
    this.theme = 'light',
  });

  factory GeneralSettings.fromJson(Map<String, dynamic> json) {
    return GeneralSettings(
      units: json['units'] as String? ?? 'metric',
      language: json['language'] as String? ?? 'en',
      timezone: json['timezone'] as String? ?? 'UTC',
      currency: json['currency'] as String? ?? 'USD',
      autoSave: json['autoSave'] as bool? ?? true,
      autoSaveInterval: json['autoSaveInterval'] as int? ?? 30,
      showTips: json['showTips'] as bool? ?? true,
      theme: json['theme'] as String? ?? 'light',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'units': units,
      'language': language,
      'timezone': timezone,
      'currency': currency,
      'autoSave': autoSave,
      'autoSaveInterval': autoSaveInterval,
      'showTips': showTips,
      'theme': theme,
    };
  }
}

/// Notification settings
class NotificationSettings {
  final bool enabled;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool activityReminders;
  final bool weatherAlerts;
  final bool deadlineAlerts;
  final bool harvestReminders;
  final int reminderHours; // hours before activity
  final String quietHoursStart;
  final String quietHoursEnd;
  final bool weekendNotifications;

  const NotificationSettings({
    this.enabled = true,
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsNotifications = true,
    this.activityReminders = true,
    this.weatherAlerts = true,
    this.deadlineAlerts = true,
    this.harvestReminders = true,
    this.reminderHours = 24,
    this.quietHoursStart = '08:00',
    this.quietHoursEnd = '22:00',
    this.weekendNotifications = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      smsNotifications: json['smsNotifications'] as bool? ?? true,
      activityReminders: json['activityReminders'] as bool? ?? true,
      weatherAlerts: json['weatherAlerts'] as bool? ?? true,
      deadlineAlerts: json['deadlineAlerts'] as bool? ?? true,
      harvestReminders: json['harvestReminders'] as bool? ?? true,
      reminderHours: json['reminderHours'] as int? ?? 24,
      quietHoursStart: json['quietHoursStart'] as String? ?? '08:00',
      quietHoursEnd: json['quietHoursEnd'] as String? ?? '22:00',
      weekendNotifications: json['weekendNotifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'activityReminders': activityReminders,
      'weatherAlerts': weatherAlerts,
      'deadlineAlerts': deadlineAlerts,
      'harvestReminders': harvestReminders,
      'reminderHours': reminderHours,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'weekendNotifications': weekendNotifications,
    };
  }
}

/// Activity settings
class ActivitySettings {
  final int defaultDuration; // days
  final String defaultPriority;
  final bool autoComplete;
  final bool requirePhotos;
  final bool trackCosts;
  final bool trackTime;
  final int archiveAfterDays;
  final bool showWeather;
  final bool enableTemplates;
  final bool bulkOperations;

  const ActivitySettings({
    this.defaultDuration = 7,
    this.defaultPriority = 'medium',
    this.autoComplete = true,
    this.requirePhotos = true,
    this.trackCosts = true,
    this.trackTime = true,
    this.archiveAfterDays = 30,
    this.showWeather = true,
    this.enableTemplates = true,
    this.bulkOperations = true,
  });

  factory ActivitySettings.fromJson(Map<String, dynamic> json) {
    return ActivitySettings(
      defaultDuration: json['defaultDuration'] as int? ?? 7,
      defaultPriority: json['defaultPriority'] as String? ?? 'medium',
      autoComplete: json['autoComplete'] as bool? ?? true,
      requirePhotos: json['requirePhotos'] as bool? ?? true,
      trackCosts: json['trackCosts'] as bool? ?? true,
      trackTime: json['trackTime'] as bool? ?? true,
      archiveAfterDays: json['archiveAfterDays'] as int? ?? 30,
      showWeather: json['showWeather'] as bool? ?? true,
      enableTemplates: json['enableTemplates'] as bool? ?? true,
      bulkOperations: json['bulkOperations'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultDuration': defaultDuration,
      'defaultPriority': defaultPriority,
      'autoComplete': autoComplete,
      'requirePhotos': requirePhotos,
      'trackCosts': trackCosts,
      'trackTime': trackTime,
      'archiveAfterDays': archiveAfterDays,
      'showWeather': showWeather,
      'enableTemplates': enableTemplates,
      'bulkOperations': bulkOperations,
    };
  }
}

/// Weather settings
class WeatherSettings {
  final bool enabled;
  final String temperatureUnit;
  final String windSpeedUnit;
  final String precipitationUnit;
  final bool showForecast;
  final int forecastDays;
  final bool weatherAlerts;
  final bool rainAlerts;
  final bool temperatureAlerts;
  final bool windAlerts;
  final double highTempThreshold;
  final double lowTempThreshold;
  final double windSpeedThreshold;

  const WeatherSettings({
    this.enabled = true,
    this.temperatureUnit = 'celsius',
    this.windSpeedUnit = 'kmh',
    this.precipitationUnit = 'mm',
    this.showForecast = true,
    this.forecastDays = 7,
    this.weatherAlerts = true,
    this.rainAlerts = true,
    this.temperatureAlerts = true,
    this.windAlerts = true,
    this.highTempThreshold = 35.0,
    this.lowTempThreshold = 5.0,
    this.windSpeedThreshold = 50.0,
  });

  factory WeatherSettings.fromJson(Map<String, dynamic> json) {
    return WeatherSettings(
      enabled: json['enabled'] as bool? ?? true,
      temperatureUnit: json['temperatureUnit'] as String? ?? 'celsius',
      windSpeedUnit: json['windSpeedUnit'] as String? ?? 'kmh',
      precipitationUnit: json['precipitationUnit'] as String? ?? 'mm',
      showForecast: json['showForecast'] as bool? ?? true,
      forecastDays: json['forecastDays'] as int? ?? 7,
      weatherAlerts: json['weatherAlerts'] as bool? ?? true,
      rainAlerts: json['rainAlerts'] as bool? ?? true,
      temperatureAlerts: json['temperatureAlerts'] as bool? ?? true,
      windAlerts: json['windAlerts'] as bool? ?? true,
      highTempThreshold:
          (json['highTempThreshold'] as num?)?.toDouble() ?? 35.0,
      lowTempThreshold: (json['lowTempThreshold'] as num?)?.toDouble() ?? 5.0,
      windSpeedThreshold:
          (json['windSpeedThreshold'] as num?)?.toDouble() ?? 50.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'temperatureUnit': temperatureUnit,
      'windSpeedUnit': windSpeedUnit,
      'precipitationUnit': precipitationUnit,
      'showForecast': showForecast,
      'forecastDays': forecastDays,
      'weatherAlerts': weatherAlerts,
      'rainAlerts': rainAlerts,
      'temperatureAlerts': temperatureAlerts,
      'windAlerts': windAlerts,
      'highTempThreshold': highTempThreshold,
      'lowTempThreshold': lowTempThreshold,
      'windSpeedThreshold': windSpeedThreshold,
    };
  }
}

/// Security settings
class SecuritySettings {
  final bool biometricAuth;
  final bool requirePinForActions;
  final bool autoLock;
  final int autoLockMinutes;
  final bool dataEncryption;
  final bool allowOfflineAccess;
  final bool auditLog;
  final int sessionTimeout; // minutes

  const SecuritySettings({
    this.biometricAuth = true,
    this.requirePinForActions = false,
    this.autoLock = true,
    this.autoLockMinutes = 5,
    this.dataEncryption = true,
    this.allowOfflineAccess = false,
    this.auditLog = true,
    this.sessionTimeout = 90,
  });

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      biometricAuth: json['biometricAuth'] as bool? ?? true,
      requirePinForActions: json['requirePinForActions'] as bool? ?? false,
      autoLock: json['autoLock'] as bool? ?? true,
      autoLockMinutes: json['autoLockMinutes'] as int? ?? 5,
      dataEncryption: json['dataEncryption'] as bool? ?? true,
      allowOfflineAccess: json['allowOfflineAccess'] as bool? ?? false,
      auditLog: json['auditLog'] as bool? ?? true,
      sessionTimeout: json['sessionTimeout'] as int? ?? 90,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'biometricAuth': biometricAuth,
      'requirePinForActions': requirePinForActions,
      'autoLock': autoLock,
      'autoLockMinutes': autoLockMinutes,
      'dataEncryption': dataEncryption,
      'allowOfflineAccess': allowOfflineAccess,
      'auditLog': auditLog,
      'sessionTimeout': sessionTimeout,
    };
  }
}

/// Backup settings
class BackupSettings {
  final bool enabled;
  final String frequency; // daily, weekly, monthly
  final bool autoBackup;
  final String backupLocation; // cloud, local
  final int retentionDays;
  final bool includePhotos;
  final bool includeDocuments;
  final bool compressBackups;
  final DateTime? lastBackup;

  const BackupSettings({
    this.enabled = true,
    this.frequency = 'daily',
    this.autoBackup = true,
    this.backupLocation = 'cloud',
    this.retentionDays = 30,
    this.includePhotos = true,
    this.includeDocuments = true,
    this.compressBackups = true,
    this.lastBackup,
  });

  factory BackupSettings.fromJson(Map<String, dynamic> json) {
    return BackupSettings(
      enabled: json['enabled'] as bool? ?? true,
      frequency: json['frequency'] as String? ?? 'daily',
      autoBackup: json['autoBackup'] as bool? ?? true,
      backupLocation: json['backupLocation'] as String? ?? 'cloud',
      retentionDays: json['retentionDays'] as int? ?? 30,
      includePhotos: json['includePhotos'] as bool? ?? true,
      includeDocuments: json['includeDocuments'] as bool? ?? true,
      compressBackups: json['compressBackups'] as bool? ?? true,
      lastBackup:
          json['lastBackup'] != null
              ? DateTime.parse(json['lastBackup'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'frequency': frequency,
      'autoBackup': autoBackup,
      'backupLocation': backupLocation,
      'retentionDays': retentionDays,
      'includePhotos': includePhotos,
      'includeDocuments': includeDocuments,
      'compressBackups': compressBackups,
      'lastBackup': lastBackup?.toIso8601String(),
    };
  }
}

/// Settings categories for UI organization
enum SettingsCategory {
  general,
  notifications,
  activities,
  weather,
  security,
  backup,
  about,
}

extension SettingsCategoryExtension on SettingsCategory {
  String get displayName {
    switch (this) {
      case SettingsCategory.general:
        return 'General';
      case SettingsCategory.notifications:
        return 'Notifications';
      case SettingsCategory.activities:
        return 'Activities';
      case SettingsCategory.weather:
        return 'Weather';
      case SettingsCategory.security:
        return 'Security';
      case SettingsCategory.backup:
        return 'Backup & Sync';
      case SettingsCategory.about:
        return 'About';
    }
  }

  String get description {
    switch (this) {
      case SettingsCategory.general:
        return 'Language, units, and display preferences';
      case SettingsCategory.notifications:
        return 'Alerts, reminders, and notification preferences';
      case SettingsCategory.activities:
        return 'Default settings for farm activities';
      case SettingsCategory.weather:
        return 'Weather data and alert preferences';
      case SettingsCategory.security:
        return 'Privacy, security, and access controls';
      case SettingsCategory.backup:
        return 'Data backup and synchronization';
      case SettingsCategory.about:
        return 'App information and support';
    }
  }
}

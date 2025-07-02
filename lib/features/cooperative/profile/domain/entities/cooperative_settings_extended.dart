import 'package:equatable/equatable.dart';

/// Working hours for the cooperative
class WorkingHours extends Equatable {
  final String start;
  final String end;

  const WorkingHours({required this.start, required this.end});

  factory WorkingHours.fromMap(Map<String, dynamic> map) {
    return WorkingHours(
      start: map['start'] ?? '08:00',
      end: map['end'] ?? '17:00',
    );
  }

  Map<String, dynamic> toMap() {
    return {'start': start, 'end': end};
  }

  factory WorkingHours.defaultHours() {
    return const WorkingHours(start: '08:00', end: '17:00');
  }

  @override
  List<Object?> get props => [start, end];

  WorkingHours copyWith({String? start, String? end}) {
    return WorkingHours(start: start ?? this.start, end: end ?? this.end);
  }
}

/// Operational settings for the cooperative
class OperationalSettings extends Equatable {
  final List<String> workingDays;
  final WorkingHours workingHours;
  final List<String> geographicZones;
  final List<String> qualityGrades;

  const OperationalSettings({
    required this.workingDays,
    required this.workingHours,
    required this.geographicZones,
    required this.qualityGrades,
  });

  factory OperationalSettings.fromMap(Map<String, dynamic> map) {
    return OperationalSettings(
      workingDays: List<String>.from(
        map['workingDays'] ??
            ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      ),
      workingHours: WorkingHours.fromMap(map['workingHours'] ?? {}),
      geographicZones: List<String>.from(map['geographicZones'] ?? []),
      qualityGrades: List<String>.from(
        map['qualityGrades'] ?? ['Premium', 'Standard', 'Basic'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workingDays': workingDays,
      'workingHours': workingHours.toMap(),
      'geographicZones': geographicZones,
      'qualityGrades': qualityGrades,
    };
  }

  factory OperationalSettings.defaultSettings() {
    return OperationalSettings(
      workingDays: const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
      ],
      workingHours: WorkingHours.defaultHours(),
      geographicZones: const [
        'Central',
        'Northern',
        'Southern',
        'Eastern',
        'Western',
      ],
      qualityGrades: const ['Premium', 'Standard', 'Basic'],
    );
  }

  @override
  List<Object?> get props => [
    workingDays,
    workingHours,
    geographicZones,
    qualityGrades,
  ];

  OperationalSettings copyWith({
    List<String>? workingDays,
    WorkingHours? workingHours,
    List<String>? geographicZones,
    List<String>? qualityGrades,
  }) {
    return OperationalSettings(
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      geographicZones: geographicZones ?? this.geographicZones,
      qualityGrades: qualityGrades ?? this.qualityGrades,
    );
  }
}

/// Notification settings for the cooperative
class NotificationSettings extends Equatable {
  final EmailNotifications emailNotifications;
  final SmsNotifications smsNotifications;
  final PushNotifications pushNotifications;

  const NotificationSettings({
    required this.emailNotifications,
    required this.smsNotifications,
    required this.pushNotifications,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      emailNotifications: EmailNotifications.fromMap(
        map['emailNotifications'] ?? {},
      ),
      smsNotifications: SmsNotifications.fromMap(map['smsNotifications'] ?? {}),
      pushNotifications: PushNotifications.fromMap(
        map['pushNotifications'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emailNotifications': emailNotifications.toMap(),
      'smsNotifications': smsNotifications.toMap(),
      'pushNotifications': pushNotifications.toMap(),
    };
  }

  factory NotificationSettings.defaultSettings() {
    return NotificationSettings(
      emailNotifications: EmailNotifications.defaultSettings(),
      smsNotifications: SmsNotifications.defaultSettings(),
      pushNotifications: PushNotifications.defaultSettings(),
    );
  }

  @override
  List<Object?> get props => [
    emailNotifications,
    smsNotifications,
    pushNotifications,
  ];

  NotificationSettings copyWith({
    EmailNotifications? emailNotifications,
    SmsNotifications? smsNotifications,
    PushNotifications? pushNotifications,
  }) {
    return NotificationSettings(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }
}

/// Email notification settings
class EmailNotifications extends Equatable {
  final bool newFarmerRegistration;
  final bool salesTransactions;
  final bool paymentReminders;
  final bool systemUpdates;
  final bool reportGeneration;

  const EmailNotifications({
    required this.newFarmerRegistration,
    required this.salesTransactions,
    required this.paymentReminders,
    required this.systemUpdates,
    required this.reportGeneration,
  });

  factory EmailNotifications.fromMap(Map<String, dynamic> map) {
    return EmailNotifications(
      newFarmerRegistration: map['newFarmerRegistration'] ?? true,
      salesTransactions: map['salesTransactions'] ?? true,
      paymentReminders: map['paymentReminders'] ?? true,
      systemUpdates: map['systemUpdates'] ?? false,
      reportGeneration: map['reportGeneration'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'newFarmerRegistration': newFarmerRegistration,
      'salesTransactions': salesTransactions,
      'paymentReminders': paymentReminders,
      'systemUpdates': systemUpdates,
      'reportGeneration': reportGeneration,
    };
  }

  factory EmailNotifications.defaultSettings() {
    return const EmailNotifications(
      newFarmerRegistration: true,
      salesTransactions: true,
      paymentReminders: true,
      systemUpdates: false,
      reportGeneration: true,
    );
  }

  @override
  List<Object?> get props => [
    newFarmerRegistration,
    salesTransactions,
    paymentReminders,
    systemUpdates,
    reportGeneration,
  ];

  EmailNotifications copyWith({
    bool? newFarmerRegistration,
    bool? salesTransactions,
    bool? paymentReminders,
    bool? systemUpdates,
    bool? reportGeneration,
  }) {
    return EmailNotifications(
      newFarmerRegistration:
          newFarmerRegistration ?? this.newFarmerRegistration,
      salesTransactions: salesTransactions ?? this.salesTransactions,
      paymentReminders: paymentReminders ?? this.paymentReminders,
      systemUpdates: systemUpdates ?? this.systemUpdates,
      reportGeneration: reportGeneration ?? this.reportGeneration,
    );
  }
}

/// SMS notification settings
class SmsNotifications extends Equatable {
  final bool paymentConfirmations;
  final bool importantAnnouncements;
  final bool emergencyAlerts;

  const SmsNotifications({
    required this.paymentConfirmations,
    required this.importantAnnouncements,
    required this.emergencyAlerts,
  });

  factory SmsNotifications.fromMap(Map<String, dynamic> map) {
    return SmsNotifications(
      paymentConfirmations: map['paymentConfirmations'] ?? true,
      importantAnnouncements: map['importantAnnouncements'] ?? true,
      emergencyAlerts: map['emergencyAlerts'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentConfirmations': paymentConfirmations,
      'importantAnnouncements': importantAnnouncements,
      'emergencyAlerts': emergencyAlerts,
    };
  }

  factory SmsNotifications.defaultSettings() {
    return const SmsNotifications(
      paymentConfirmations: true,
      importantAnnouncements: true,
      emergencyAlerts: true,
    );
  }

  @override
  List<Object?> get props => [
    paymentConfirmations,
    importantAnnouncements,
    emergencyAlerts,
  ];

  SmsNotifications copyWith({
    bool? paymentConfirmations,
    bool? importantAnnouncements,
    bool? emergencyAlerts,
  }) {
    return SmsNotifications(
      paymentConfirmations: paymentConfirmations ?? this.paymentConfirmations,
      importantAnnouncements:
          importantAnnouncements ?? this.importantAnnouncements,
      emergencyAlerts: emergencyAlerts ?? this.emergencyAlerts,
    );
  }
}

/// Push notification settings
class PushNotifications extends Equatable {
  final bool realTimeUpdates;
  final bool dailySummary;
  final bool weeklyReports;

  const PushNotifications({
    required this.realTimeUpdates,
    required this.dailySummary,
    required this.weeklyReports,
  });

  factory PushNotifications.fromMap(Map<String, dynamic> map) {
    return PushNotifications(
      realTimeUpdates: map['realTimeUpdates'] ?? true,
      dailySummary: map['dailySummary'] ?? false,
      weeklyReports: map['weeklyReports'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'realTimeUpdates': realTimeUpdates,
      'dailySummary': dailySummary,
      'weeklyReports': weeklyReports,
    };
  }

  factory PushNotifications.defaultSettings() {
    return const PushNotifications(
      realTimeUpdates: true,
      dailySummary: false,
      weeklyReports: true,
    );
  }

  @override
  List<Object?> get props => [realTimeUpdates, dailySummary, weeklyReports];

  PushNotifications copyWith({
    bool? realTimeUpdates,
    bool? dailySummary,
    bool? weeklyReports,
  }) {
    return PushNotifications(
      realTimeUpdates: realTimeUpdates ?? this.realTimeUpdates,
      dailySummary: dailySummary ?? this.dailySummary,
      weeklyReports: weeklyReports ?? this.weeklyReports,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../presentation/models/report_models.dart';

/// Service for managing scheduled reports
class ReportSchedulingService {
  final FirebaseFirestore _firestore;

  ReportSchedulingService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create a scheduled report
  Future<ScheduledReport> createScheduledReport({
    required String cooperativeId,
    required String userId,
    required String name,
    required String description,
    required ReportTemplate template,
    required ScheduleFrequency frequency,
    required DateTime startDate,
    DateTime? endDate,
    Map<String, dynamic>? customFilters,
    List<String>? emailRecipients,
  }) async {
    try {
      final scheduleId = _generateScheduleId();
      
      final scheduledReport = ScheduledReport(
        id: scheduleId,
        cooperativeId: cooperativeId,
        name: name,
        description: description,
        templateId: template.id,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        lastRun: null,
        nextRun: _calculateNextRun(startDate, frequency),
        isActive: true,
        customFilters: customFilters ?? {},
        emailRecipients: emailRecipients ?? [],
        createdBy: userId,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
          .collection('cooperatives')
          .doc(cooperativeId)
          .collection('scheduledReports')
          .doc(scheduleId)
          .set(scheduledReport.toMap());

      return scheduledReport;
    } catch (e) {
      throw Exception('Failed to create scheduled report: $e');
    }
  }

  /// Get scheduled reports for cooperative
  Future<List<ScheduledReport>> getScheduledReports(String cooperativeId) async {
    try {
      final query = await _firestore
          .collection('cooperatives')
          .doc(cooperativeId)
          .collection('scheduledReports')
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) {
        return ScheduledReport.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get scheduled reports: $e');
    }
  }

  /// Update scheduled report
  Future<void> updateScheduledReport(
    String cooperativeId,
    ScheduledReport scheduledReport,
  ) async {
    try {
      await _firestore
          .collection('cooperatives')
          .doc(cooperativeId)
          .collection('scheduledReports')
          .doc(scheduledReport.id)
          .update(scheduledReport.toMap());
    } catch (e) {
      throw Exception('Failed to update scheduled report: $e');
    }
  }

  /// Delete scheduled report
  Future<void> deleteScheduledReport(
    String cooperativeId,
    String scheduleId,
  ) async {
    try {
      await _firestore
          .collection('cooperatives')
          .doc(cooperativeId)
          .collection('scheduledReports')
          .doc(scheduleId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete scheduled report: $e');
    }
  }

  /// Toggle scheduled report active status
  Future<void> toggleScheduledReport(
    String cooperativeId,
    String scheduleId,
    bool isActive,
  ) async {
    try {
      await _firestore
          .collection('cooperatives')
          .doc(cooperativeId)
          .collection('scheduledReports')
          .doc(scheduleId)
          .update({
        'isActive': isActive,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to toggle scheduled report: $e');
    }
  }

  /// Get reports due for execution
  Future<List<ScheduledReport>> getReportsDue() async {
    try {
      final now = DateTime.now();
      
      final query = await _firestore
          .collectionGroup('scheduledReports')
          .where('isActive', isEqualTo: true)
          .where('nextRun', isLessThanOrEqualTo: now)
          .get();

      return query.docs.map((doc) {
        return ScheduledReport.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get reports due: $e');
    }
  }

  /// Update report after execution
  Future<void> updateAfterExecution(
    String cooperativeId,
    String scheduleId,
    DateTime executionTime,
  ) async {
    try {
      final scheduledReportDoc = await _firestore
          .collection('cooperatives')
          .doc(cooperativeId)
          .collection('scheduledReports')
          .doc(scheduleId)
          .get();

      if (!scheduledReportDoc.exists) return;

      final scheduledReport = ScheduledReport.fromMap(
        scheduledReportDoc.data()!,
        scheduleId,
      );

      final nextRun = _calculateNextRun(executionTime, scheduledReport.frequency);

      await _firestore
          .collection('cooperatives')
          .doc(cooperativeId)
          .collection('scheduledReports')
          .doc(scheduleId)
          .update({
        'lastRun': executionTime,
        'nextRun': nextRun,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to update after execution: $e');
    }
  }

  /// Calculate next run time based on frequency
  DateTime _calculateNextRun(DateTime baseDate, ScheduleFrequency frequency) {
    switch (frequency) {
      case ScheduleFrequency.daily:
        return baseDate.add(const Duration(days: 1));
      case ScheduleFrequency.weekly:
        return baseDate.add(const Duration(days: 7));
      case ScheduleFrequency.monthly:
        return DateTime(
          baseDate.year,
          baseDate.month + 1,
          baseDate.day,
          baseDate.hour,
          baseDate.minute,
        );
      case ScheduleFrequency.quarterly:
        return DateTime(
          baseDate.year,
          baseDate.month + 3,
          baseDate.day,
          baseDate.hour,
          baseDate.minute,
        );
      case ScheduleFrequency.yearly:
        return DateTime(
          baseDate.year + 1,
          baseDate.month,
          baseDate.day,
          baseDate.hour,
          baseDate.minute,
        );
    }
  }

  /// Generate unique schedule ID
  String _generateScheduleId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Get schedule frequency display name
  String getFrequencyDisplayName(ScheduleFrequency frequency) {
    switch (frequency) {
      case ScheduleFrequency.daily:
        return 'Daily';
      case ScheduleFrequency.weekly:
        return 'Weekly';
      case ScheduleFrequency.monthly:
        return 'Monthly';
      case ScheduleFrequency.quarterly:
        return 'Quarterly';
      case ScheduleFrequency.yearly:
        return 'Yearly';
    }
  }

  /// Get next run description
  String getNextRunDescription(ScheduledReport scheduledReport) {
    if (!scheduledReport.isActive) return 'Inactive';
    
    final now = DateTime.now();
    final nextRun = scheduledReport.nextRun;
    
    if (nextRun.isBefore(now)) {
      return 'Overdue';
    }
    
    final difference = nextRun.difference(now);
    
    if (difference.inDays > 0) {
      return 'In ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'Due now';
    }
  }
}

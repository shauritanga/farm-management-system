import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/activity.dart';
import 'activity_provider.dart';

/// Analytics data model for farm insights
class FarmAnalytics {
  final int totalActivities;
  final int completedActivities;
  final int pendingActivities;
  final int overdueActivities;
  final double completionRate;
  final double productivityScore;
  final Map<ActivityType, int> activitiesByType;
  final Map<ActivityPriority, int> activitiesByPriority;
  final Map<ActivityStatus, int> activitiesByStatus;
  final List<MonthlyActivityData> monthlyData;
  final List<WeeklyProductivityData> weeklyProductivity;
  final List<ActivityTypePerformance> typePerformance;
  final List<UpcomingDeadline> upcomingDeadlines;
  final CostAnalysis costAnalysis;
  final SeasonalInsights seasonalInsights;

  const FarmAnalytics({
    required this.totalActivities,
    required this.completedActivities,
    required this.pendingActivities,
    required this.overdueActivities,
    required this.completionRate,
    required this.productivityScore,
    required this.activitiesByType,
    required this.activitiesByPriority,
    required this.activitiesByStatus,
    required this.monthlyData,
    required this.weeklyProductivity,
    required this.typePerformance,
    required this.upcomingDeadlines,
    required this.costAnalysis,
    required this.seasonalInsights,
  });
}

/// Monthly activity data for trends
class MonthlyActivityData {
  final String month;
  final int year;
  final int totalActivities;
  final int completedActivities;
  final double completionRate;
  final double totalCost;

  const MonthlyActivityData({
    required this.month,
    required this.year,
    required this.totalActivities,
    required this.completedActivities,
    required this.completionRate,
    required this.totalCost,
  });
}

/// Weekly productivity data
class WeeklyProductivityData {
  final String week;
  final int activitiesCompleted;
  final double productivityScore;
  final int daysActive;

  const WeeklyProductivityData({
    required this.week,
    required this.activitiesCompleted,
    required this.productivityScore,
    required this.daysActive,
  });
}

/// Activity type performance analysis
class ActivityTypePerformance {
  final ActivityType type;
  final int totalCount;
  final int completedCount;
  final double averageCompletionTime;
  final double successRate;
  final double averageCost;

  const ActivityTypePerformance({
    required this.type,
    required this.totalCount,
    required this.completedCount,
    required this.averageCompletionTime,
    required this.successRate,
    required this.averageCost,
  });
}

/// Upcoming deadline information
class UpcomingDeadline {
  final ActivityEntity activity;
  final int daysUntilDue;
  final String urgencyLevel;

  const UpcomingDeadline({
    required this.activity,
    required this.daysUntilDue,
    required this.urgencyLevel,
  });
}

/// Cost analysis data
class CostAnalysis {
  final double totalCost;
  final double averageCostPerActivity;
  final double monthlySpending;
  final Map<ActivityType, double> costByType;
  final List<MonthlyCostData> monthlyCosts;

  const CostAnalysis({
    required this.totalCost,
    required this.averageCostPerActivity,
    required this.monthlySpending,
    required this.costByType,
    required this.monthlyCosts,
  });
}

/// Monthly cost data
class MonthlyCostData {
  final String month;
  final double cost;

  const MonthlyCostData({required this.month, required this.cost});
}

/// Seasonal insights
class SeasonalInsights {
  final String currentSeason;
  final List<String> recommendedActivities;
  final List<String> seasonalTips;
  final double seasonalProductivity;

  const SeasonalInsights({
    required this.currentSeason,
    required this.recommendedActivities,
    required this.seasonalTips,
    required this.seasonalProductivity,
  });
}

/// Provider for comprehensive farm analytics
final farmAnalyticsProvider = FutureProvider.family<FarmAnalytics, String>((
  ref,
  farmId,
) async {
  final repository = ref.read(activityRepositoryProvider);

  try {
    // Get all activities for this farm
    final activities = await repository.getActivitiesByFarmId(farmId);

    // Calculate basic metrics
    final totalActivities = activities.length;
    final completedActivities = activities.where((a) => a.isCompleted).length;
    final pendingActivities =
        activities
            .where(
              (a) =>
                  a.status == ActivityStatus.planned ||
                  a.status == ActivityStatus.inProgress,
            )
            .length;
    final overdueActivities =
        activities.where((a) => a.isOverdue && !a.isCompleted).length;

    final completionRate =
        totalActivities > 0
            ? (completedActivities / totalActivities * 100)
            : 0.0;

    // Calculate productivity score (0-100)
    final productivityScore = _calculateProductivityScore(activities);

    // Group activities by type
    final activitiesByType = <ActivityType, int>{};
    for (final type in ActivityType.values) {
      activitiesByType[type] = activities.where((a) => a.type == type).length;
    }

    // Group activities by priority
    final activitiesByPriority = <ActivityPriority, int>{};
    for (final priority in ActivityPriority.values) {
      activitiesByPriority[priority] =
          activities.where((a) => a.priority == priority).length;
    }

    // Group activities by status
    final activitiesByStatus = <ActivityStatus, int>{};
    for (final status in ActivityStatus.values) {
      activitiesByStatus[status] =
          activities.where((a) => a.status == status).length;
    }

    // Generate monthly data (last 6 months)
    final monthlyData = _generateMonthlyData(activities);

    // Generate weekly productivity data (last 8 weeks)
    final weeklyProductivity = _generateWeeklyProductivity(activities);

    // Calculate activity type performance
    final typePerformance = _calculateTypePerformance(activities);

    // Get upcoming deadlines (next 14 days)
    final upcomingDeadlines = _getUpcomingDeadlines(activities);

    // Calculate cost analysis
    final costAnalysis = _calculateCostAnalysis(activities);

    // Generate seasonal insights
    final seasonalInsights = _generateSeasonalInsights(activities);

    return FarmAnalytics(
      totalActivities: totalActivities,
      completedActivities: completedActivities,
      pendingActivities: pendingActivities,
      overdueActivities: overdueActivities,
      completionRate: completionRate,
      productivityScore: productivityScore,
      activitiesByType: activitiesByType,
      activitiesByPriority: activitiesByPriority,
      activitiesByStatus: activitiesByStatus,
      monthlyData: monthlyData,
      weeklyProductivity: weeklyProductivity,
      typePerformance: typePerformance,
      upcomingDeadlines: upcomingDeadlines,
      costAnalysis: costAnalysis,
      seasonalInsights: seasonalInsights,
    );
  } catch (e) {
    throw Exception('Failed to generate farm analytics: $e');
  }
});

/// Calculate productivity score based on completion rate, timeliness, and activity frequency
double _calculateProductivityScore(List<ActivityEntity> activities) {
  if (activities.isEmpty) return 0.0;

  final completed = activities.where((a) => a.isCompleted).length;
  final completionRate = completed / activities.length;

  // Calculate timeliness (activities completed on or before scheduled date)
  final onTimeActivities =
      activities
          .where(
            (a) =>
                a.isCompleted &&
                a.completedDate != null &&
                !a.completedDate!.isAfter(
                  a.scheduledDate.add(const Duration(days: 1)),
                ),
          )
          .length;

  final timelinessRate = completed > 0 ? onTimeActivities / completed : 0.0;

  // Calculate activity frequency (activities per week)
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  final recentActivities =
      activities.where((a) => a.createdAt.isAfter(thirtyDaysAgo)).length;
  final frequencyScore = (recentActivities / 30 * 7).clamp(
    0.0,
    1.0,
  ); // Normalize to 0-1

  // Weighted score: 50% completion, 30% timeliness, 20% frequency
  final score =
      (completionRate * 0.5 + timelinessRate * 0.3 + frequencyScore * 0.2) *
      100;

  return score.clamp(0.0, 100.0);
}

/// Generate monthly activity data for the last 6 months
List<MonthlyActivityData> _generateMonthlyData(
  List<ActivityEntity> activities,
) {
  final monthlyData = <MonthlyActivityData>[];
  final now = DateTime.now();

  for (int i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);

    final monthActivities =
        activities
            .where(
              (a) =>
                  a.createdAt.isAfter(
                    month.subtract(const Duration(days: 1)),
                  ) &&
                  a.createdAt.isBefore(nextMonth),
            )
            .toList();

    final completed = monthActivities.where((a) => a.isCompleted).length;
    final total = monthActivities.length;
    final completionRate = total > 0 ? (completed / total * 100) : 0.0;

    final totalCost = monthActivities
        .where((a) => a.cost != null)
        .fold(0.0, (sum, a) => sum + a.cost!);

    monthlyData.add(
      MonthlyActivityData(
        month: _getMonthName(month.month),
        year: month.year,
        totalActivities: total,
        completedActivities: completed,
        completionRate: completionRate,
        totalCost: totalCost,
      ),
    );
  }

  return monthlyData;
}

/// Generate weekly productivity data for the last 8 weeks
List<WeeklyProductivityData> _generateWeeklyProductivity(
  List<ActivityEntity> activities,
) {
  final weeklyData = <WeeklyProductivityData>[];
  final now = DateTime.now();

  for (int i = 7; i >= 0; i--) {
    final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final weekActivities =
        activities
            .where(
              (a) =>
                  a.completedDate != null &&
                  a.completedDate!.isAfter(
                    weekStart.subtract(const Duration(days: 1)),
                  ) &&
                  a.completedDate!.isBefore(
                    weekEnd.add(const Duration(days: 1)),
                  ),
            )
            .toList();

    final activitiesCompleted = weekActivities.length;

    // Calculate unique days with activity
    final activeDays =
        weekActivities
            .map(
              (a) => DateTime(
                a.completedDate!.year,
                a.completedDate!.month,
                a.completedDate!.day,
              ),
            )
            .toSet()
            .length;

    // Simple productivity score based on activities completed and consistency
    final productivityScore = activitiesCompleted * 10 + activeDays * 5;

    weeklyData.add(
      WeeklyProductivityData(
        week: 'Week ${i + 1}',
        activitiesCompleted: activitiesCompleted,
        productivityScore: productivityScore.toDouble(),
        daysActive: activeDays,
      ),
    );
  }

  return weeklyData.reversed.toList();
}

/// Calculate performance metrics for each activity type
List<ActivityTypePerformance> _calculateTypePerformance(
  List<ActivityEntity> activities,
) {
  final performance = <ActivityTypePerformance>[];

  for (final type in ActivityType.values) {
    final typeActivities = activities.where((a) => a.type == type).toList();
    if (typeActivities.isEmpty) continue;

    final completed = typeActivities.where((a) => a.isCompleted).length;
    final successRate = completed / typeActivities.length * 100;

    // Calculate average completion time for completed activities
    final completedActivities =
        typeActivities
            .where((a) => a.isCompleted && a.completedDate != null)
            .toList();

    double averageCompletionTime = 0.0;
    if (completedActivities.isNotEmpty) {
      final totalDays = completedActivities.fold(
        0.0,
        (sum, a) => sum + a.completedDate!.difference(a.createdAt).inDays,
      );
      averageCompletionTime = totalDays / completedActivities.length;
    }

    // Calculate average cost
    final activitiesWithCost =
        typeActivities.where((a) => a.cost != null).toList();
    double averageCost = 0.0;
    if (activitiesWithCost.isNotEmpty) {
      averageCost =
          activitiesWithCost.fold(0.0, (sum, a) => sum + a.cost!) /
          activitiesWithCost.length;
    }

    performance.add(
      ActivityTypePerformance(
        type: type,
        totalCount: typeActivities.length,
        completedCount: completed,
        averageCompletionTime: averageCompletionTime,
        successRate: successRate,
        averageCost: averageCost,
      ),
    );
  }

  return performance;
}

/// Get upcoming deadlines for the next 14 days
List<UpcomingDeadline> _getUpcomingDeadlines(List<ActivityEntity> activities) {
  final now = DateTime.now();
  final twoWeeksFromNow = now.add(const Duration(days: 14));

  final upcomingActivities =
      activities
          .where(
            (a) =>
                !a.isCompleted &&
                a.scheduledDate.isAfter(now) &&
                a.scheduledDate.isBefore(twoWeeksFromNow),
          )
          .toList();

  upcomingActivities.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

  return upcomingActivities.map((activity) {
    final daysUntil = activity.scheduledDate.difference(now).inDays;
    String urgencyLevel;

    if (daysUntil <= 1) {
      urgencyLevel = 'Critical';
    } else if (daysUntil <= 3) {
      urgencyLevel = 'High';
    } else if (daysUntil <= 7) {
      urgencyLevel = 'Medium';
    } else {
      urgencyLevel = 'Low';
    }

    return UpcomingDeadline(
      activity: activity,
      daysUntilDue: daysUntil,
      urgencyLevel: urgencyLevel,
    );
  }).toList();
}

/// Calculate comprehensive cost analysis
CostAnalysis _calculateCostAnalysis(List<ActivityEntity> activities) {
  final activitiesWithCost = activities.where((a) => a.cost != null).toList();

  final totalCost = activitiesWithCost.fold(0.0, (sum, a) => sum + a.cost!);
  final averageCostPerActivity =
      activitiesWithCost.isNotEmpty
          ? totalCost / activitiesWithCost.length
          : 0.0;

  // Calculate monthly spending (last 30 days)
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  final recentActivities =
      activitiesWithCost
          .where((a) => a.createdAt.isAfter(thirtyDaysAgo))
          .toList();
  final monthlySpending = recentActivities.fold(0.0, (sum, a) => sum + a.cost!);

  // Cost by activity type
  final costByType = <ActivityType, double>{};
  for (final type in ActivityType.values) {
    final typeCost = activitiesWithCost
        .where((a) => a.type == type)
        .fold(0.0, (sum, a) => sum + a.cost!);
    if (typeCost > 0) {
      costByType[type] = typeCost;
    }
  }

  // Monthly costs for the last 6 months
  final monthlyCosts = <MonthlyCostData>[];
  for (int i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);

    final monthCost = activitiesWithCost
        .where(
          (a) =>
              a.createdAt.isAfter(month.subtract(const Duration(days: 1))) &&
              a.createdAt.isBefore(nextMonth),
        )
        .fold(0.0, (sum, a) => sum + a.cost!);

    monthlyCosts.add(
      MonthlyCostData(month: _getMonthName(month.month), cost: monthCost),
    );
  }

  return CostAnalysis(
    totalCost: totalCost,
    averageCostPerActivity: averageCostPerActivity,
    monthlySpending: monthlySpending,
    costByType: costByType,
    monthlyCosts: monthlyCosts,
  );
}

/// Generate seasonal insights and recommendations
SeasonalInsights _generateSeasonalInsights(List<ActivityEntity> activities) {
  final now = DateTime.now();
  final currentSeason = _getCurrentSeason(now.month);

  // Seasonal recommendations based on current season
  final recommendations = _getSeasonalRecommendations(currentSeason);
  final tips = _getSeasonalTips(currentSeason);

  // Calculate seasonal productivity (activities completed this season vs last season)
  final seasonStart = _getSeasonStart(now);
  final seasonActivities =
      activities
          .where(
            (a) =>
                a.completedDate != null &&
                a.completedDate!.isAfter(seasonStart),
          )
          .length;

  // Simple productivity metric
  final seasonalProductivity = seasonActivities * 10.0;

  return SeasonalInsights(
    currentSeason: currentSeason,
    recommendedActivities: recommendations,
    seasonalTips: tips,
    seasonalProductivity: seasonalProductivity,
  );
}

/// Helper functions
String _getMonthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}

String _getCurrentSeason(int month) {
  if (month >= 3 && month <= 5) return 'Spring';
  if (month >= 6 && month <= 8) return 'Summer';
  if (month >= 9 && month <= 11) return 'Autumn';
  return 'Winter';
}

DateTime _getSeasonStart(DateTime date) {
  final month = date.month;
  if (month >= 3 && month <= 5) return DateTime(date.year, 3, 1); // Spring
  if (month >= 6 && month <= 8) return DateTime(date.year, 6, 1); // Summer
  if (month >= 9 && month <= 11) return DateTime(date.year, 9, 1); // Autumn
  return DateTime(date.year, 12, 1); // Winter
}

List<String> _getSeasonalRecommendations(String season) {
  switch (season) {
    case 'Spring':
      return [
        'Soil Preparation',
        'Planting',
        'Fertilizing',
        'Pest Control Setup',
      ];
    case 'Summer':
      return ['Watering', 'Weeding', 'Monitoring', 'Pest Control'];
    case 'Autumn':
      return ['Harvesting', 'Soil Preparation', 'Equipment Maintenance'];
    case 'Winter':
      return [
        'Planning',
        'Equipment Maintenance',
        'Soil Testing',
        'Crop Planning',
      ];
    default:
      return ['General Maintenance', 'Monitoring'];
  }
}

List<String> _getSeasonalTips(String season) {
  switch (season) {
    case 'Spring':
      return [
        'Test soil pH before planting',
        'Start seedlings indoors if needed',
        'Check irrigation systems',
        'Plan crop rotation',
      ];
    case 'Summer':
      return [
        'Water early morning or evening',
        'Monitor for heat stress',
        'Maintain consistent watering',
        'Watch for pest outbreaks',
      ];
    case 'Autumn':
      return [
        'Harvest at optimal ripeness',
        'Prepare soil for winter',
        'Clean and store equipment',
        'Plan next season crops',
      ];
    case 'Winter':
      return [
        'Review this year\'s performance',
        'Order seeds for next season',
        'Maintain equipment',
        'Plan improvements',
      ];
    default:
      return ['Stay consistent with monitoring', 'Keep detailed records'];
  }
}

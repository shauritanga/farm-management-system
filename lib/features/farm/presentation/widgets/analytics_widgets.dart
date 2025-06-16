import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../providers/analytics_provider.dart';
import '../../domain/entities/activity.dart';

/// Analytics overview cards widget
class AnalyticsOverviewCards extends StatelessWidget {
  final FarmAnalytics analytics;

  const AnalyticsOverviewCards({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Top row - Key metrics
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                theme,
                'Total Activities',
                analytics.totalActivities.toString(),
                Icons.task_alt,
                Colors.blue,
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: _buildMetricCard(
                theme,
                'Completion Rate',
                '${analytics.completionRate.toStringAsFixed(1)}%',
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.height12),

        // Bottom row - Performance metrics
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                theme,
                'Productivity Score',
                analytics.productivityScore.toStringAsFixed(0),
                Icons.trending_up,
                Colors.orange,
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: _buildMetricCard(
                theme,
                'Overdue Tasks',
                analytics.overdueActivities.toString(),
                Icons.warning,
                analytics.overdueActivities > 0 ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: ResponsiveUtils.iconSize20),
                SizedBox(width: ResponsiveUtils.spacing8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.height8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Activity status pie chart widget
class ActivityStatusPieChart extends StatelessWidget {
  final Map<ActivityStatus, int> activitiesByStatus;

  const ActivityStatusPieChart({super.key, required this.activitiesByStatus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter out zero values
    final filteredData = Map<ActivityStatus, int>.from(activitiesByStatus)
      ..removeWhere((key, value) => value == 0);

    if (filteredData.isEmpty) {
      return _buildEmptyChart(theme);
    }

    final total = filteredData.values.fold(0, (sum, value) => sum + value);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Status Distribution',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 400;

                if (isNarrow) {
                  // Stack layout for narrow screens
                  return Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: _buildPieChartSections(
                              filteredData,
                              total,
                            ),
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.height16),
                      _buildLegend(theme, filteredData, total),
                    ],
                  );
                } else {
                  // Side-by-side layout for wider screens
                  return SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: PieChart(
                            PieChartData(
                              sections: _buildPieChartSections(
                                filteredData,
                                total,
                              ),
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.spacing16),
                        Expanded(
                          child: _buildLegend(theme, filteredData, total),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          children: [
            Text(
              'Activity Status Distribution',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height32),
            Icon(
              Icons.pie_chart_outline,
              size: ResponsiveUtils.iconSize64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: ResponsiveUtils.height16),
            Text(
              'No activity data available',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<ActivityStatus, int> data,
    int total,
  ) {
    final colors = {
      ActivityStatus.planned: Colors.orange,
      ActivityStatus.inProgress: Colors.blue,
      ActivityStatus.completed: Colors.green,
      ActivityStatus.cancelled: Colors.red,
      ActivityStatus.overdue: Colors.red.shade700,
    };

    return data.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      return PieChartSectionData(
        color: colors[entry.key] ?? Colors.grey,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(
    ThemeData theme,
    Map<ActivityStatus, int> data,
    int total,
  ) {
    final colors = {
      ActivityStatus.planned: Colors.orange,
      ActivityStatus.inProgress: Colors.blue,
      ActivityStatus.completed: Colors.green,
      ActivityStatus.cancelled: Colors.red,
      ActivityStatus.overdue: Colors.red.shade700,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          data.entries.map((entry) {
            final percentage = (entry.value / total * 100);
            return Padding(
              padding: EdgeInsets.only(bottom: ResponsiveUtils.height8),
              child: Row(
                children: [
                  Container(
                    width: ResponsiveUtils.iconSize12,
                    height: ResponsiveUtils.iconSize12,
                    decoration: BoxDecoration(
                      color: colors[entry.key],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key.displayName,
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize10,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

/// Monthly activity trend line chart
class MonthlyTrendChart extends StatelessWidget {
  final List<MonthlyActivityData> monthlyData;

  const MonthlyTrendChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (monthlyData.isEmpty) {
      return _buildEmptyChart(theme);
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Activity Trends',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveUtils.fontSize10,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < monthlyData.length) {
                            return Text(
                              monthlyData[index].month,
                              style: GoogleFonts.inter(
                                fontSize: ResponsiveUtils.fontSize10,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Total activities line
                    LineChartBarData(
                      spots:
                          monthlyData.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.totalActivities.toDouble(),
                            );
                          }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                    ),
                    // Completed activities line
                    LineChartBarData(
                      spots:
                          monthlyData.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.completedActivities.toDouble(),
                            );
                          }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: ResponsiveUtils.height16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Total Activities', Colors.blue),
                SizedBox(width: ResponsiveUtils.spacing24),
                _buildLegendItem('Completed', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          children: [
            Text(
              'Monthly Activity Trends',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height32),
            Icon(
              Icons.trending_up,
              size: ResponsiveUtils.iconSize64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: ResponsiveUtils.height16),
            Text(
              'No trend data available',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ResponsiveUtils.iconSize12,
          height: ResponsiveUtils.iconSize12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: ResponsiveUtils.spacing4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Activity type performance bar chart
class ActivityTypePerformanceChart extends StatelessWidget {
  final List<ActivityTypePerformance> typePerformance;

  const ActivityTypePerformanceChart({
    super.key,
    required this.typePerformance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (typePerformance.isEmpty) {
      return _buildEmptyChart(theme);
    }

    // Sort by success rate descending
    final sortedData = List<ActivityTypePerformance>.from(typePerformance)
      ..sort((a, b) => b.successRate.compareTo(a.successRate));

    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Type Performance',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 500;

                return SizedBox(
                  height:
                      isNarrow ? 300 : 250, // More height for narrow screens
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final type = sortedData[group.x.toInt()];
                            return BarTooltipItem(
                              '${type.type.displayName}\n${type.successRate.toStringAsFixed(1)}%\n${type.completedCount}/${type.totalCount} completed',
                              GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: ResponsiveUtils.fontSize12,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: GoogleFonts.inter(
                                  fontSize: ResponsiveUtils.fontSize10,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < sortedData.length) {
                                final type = sortedData[index].type;
                                return Padding(
                                  padding: EdgeInsets.only(
                                    top: ResponsiveUtils.spacing8,
                                  ),
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    child: Text(
                                      type.displayName,
                                      style: GoogleFonts.inter(
                                        fontSize: ResponsiveUtils.fontSize10,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups:
                          sortedData.asMap().entries.map((entry) {
                            final index = entry.key;
                            final performance = entry.value;

                            Color barColor;
                            if (performance.successRate >= 80) {
                              barColor = Colors.green;
                            } else if (performance.successRate >= 60) {
                              barColor = Colors.orange;
                            } else {
                              barColor = Colors.red;
                            }

                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: performance.successRate,
                                  color: barColor,
                                  width: 20,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          children: [
            Text(
              'Activity Type Performance',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height32),
            Icon(
              Icons.bar_chart,
              size: ResponsiveUtils.iconSize64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: ResponsiveUtils.height16),
            Text(
              'No performance data available',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Upcoming deadlines widget
class UpcomingDeadlinesWidget extends StatelessWidget {
  final List<UpcomingDeadline> upcomingDeadlines;

  const UpcomingDeadlinesWidget({super.key, required this.upcomingDeadlines});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: theme.colorScheme.primary,
                  size: ResponsiveUtils.iconSize20,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Text(
                  'Upcoming Deadlines',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.height16),

            if (upcomingDeadlines.isEmpty)
              _buildEmptyDeadlines(theme)
            else
              ...upcomingDeadlines
                  .take(5)
                  .map((deadline) => _buildDeadlineItem(theme, deadline)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDeadlines(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: ResponsiveUtils.iconSize48,
            color: Colors.green,
          ),
          SizedBox(height: ResponsiveUtils.height12),
          Text(
            'No upcoming deadlines',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            'You\'re all caught up!',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize12,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineItem(ThemeData theme, UpcomingDeadline deadline) {
    Color urgencyColor;
    IconData urgencyIcon;

    switch (deadline.urgencyLevel) {
      case 'Critical':
        urgencyColor = Colors.red;
        urgencyIcon = Icons.error;
        break;
      case 'High':
        urgencyColor = Colors.orange;
        urgencyIcon = Icons.warning;
        break;
      case 'Medium':
        urgencyColor = Colors.blue;
        urgencyIcon = Icons.info;
        break;
      default:
        urgencyColor = Colors.green;
        urgencyIcon = Icons.schedule;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.height12),
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.spacing12),
        decoration: BoxDecoration(
          color: urgencyColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
          border: Border.all(color: urgencyColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              urgencyIcon,
              color: urgencyColor,
              size: ResponsiveUtils.iconSize20,
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deadline.activity.title,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    deadline.activity.type.displayName,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${deadline.daysUntilDue} day${deadline.daysUntilDue != 1 ? 's' : ''}',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    fontWeight: FontWeight.w600,
                    color: urgencyColor,
                  ),
                ),
                Text(
                  deadline.urgencyLevel,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize10,
                    color: urgencyColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Cost analysis widget
class CostAnalysisWidget extends StatelessWidget {
  final CostAnalysis costAnalysis;

  const CostAnalysisWidget({super.key, required this.costAnalysis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: theme.colorScheme.primary,
                  size: ResponsiveUtils.iconSize20,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Text(
                  'Cost Analysis',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.height16),

            // Cost metrics - responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 300;

                if (isNarrow) {
                  // Single column for very narrow screens
                  return Column(
                    children: [
                      _buildCostMetric(
                        theme,
                        'Total Cost',
                        'TSh ${costAnalysis.totalCost.toStringAsFixed(0)}',
                        Colors.blue,
                      ),
                      SizedBox(height: ResponsiveUtils.height12),
                      _buildCostMetric(
                        theme,
                        'Monthly Spending',
                        'TSh ${costAnalysis.monthlySpending.toStringAsFixed(0)}',
                        Colors.green,
                      ),
                      SizedBox(height: ResponsiveUtils.height12),
                      _buildCostMetric(
                        theme,
                        'Average per Activity',
                        'TSh ${costAnalysis.averageCostPerActivity.toStringAsFixed(0)}',
                        Colors.orange,
                      ),
                    ],
                  );
                } else {
                  // Two rows layout for wider screens
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildCostMetric(
                              theme,
                              'Total Cost',
                              'TSh ${costAnalysis.totalCost.toStringAsFixed(0)}',
                              Colors.blue,
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.spacing12),
                          Expanded(
                            child: _buildCostMetric(
                              theme,
                              'Monthly Spending',
                              'TSh ${costAnalysis.monthlySpending.toStringAsFixed(0)}',
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveUtils.height12),
                      _buildCostMetric(
                        theme,
                        'Average per Activity',
                        'TSh ${costAnalysis.averageCostPerActivity.toStringAsFixed(0)}',
                        Colors.orange,
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostMetric(
    ThemeData theme,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: ResponsiveUtils.height4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Seasonal insights widget
class SeasonalInsightsWidget extends StatelessWidget {
  final SeasonalInsights seasonalInsights;

  const SeasonalInsightsWidget({super.key, required this.seasonalInsights});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getSeasonIcon(seasonalInsights.currentSeason),
                  color: _getSeasonColor(seasonalInsights.currentSeason),
                  size: ResponsiveUtils.iconSize20,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Text(
                  '${seasonalInsights.currentSeason} Insights',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.height16),

            // Recommended activities
            Text(
              'Recommended Activities',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height8),
            Wrap(
              spacing: ResponsiveUtils.spacing8,
              runSpacing: ResponsiveUtils.spacing4,
              children:
                  seasonalInsights.recommendedActivities.map((activity) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.spacing8,
                        vertical: ResponsiveUtils.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.radius8,
                        ),
                      ),
                      child: Text(
                        activity,
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize12,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    );
                  }).toList(),
            ),

            SizedBox(height: ResponsiveUtils.height16),

            // Seasonal tips
            Text(
              'Seasonal Tips',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.secondary,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height8),
            ...seasonalInsights.seasonalTips.take(3).map((tip) {
              return Padding(
                padding: EdgeInsets.only(bottom: ResponsiveUtils.height4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: ResponsiveUtils.iconSize16,
                      color: theme.colorScheme.secondary,
                    ),
                    SizedBox(width: ResponsiveUtils.spacing8),
                    Expanded(
                      child: Text(
                        tip,
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize12,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _getSeasonIcon(String season) {
    switch (season) {
      case 'Spring':
        return Icons.local_florist;
      case 'Summer':
        return Icons.wb_sunny;
      case 'Autumn':
        return Icons.eco;
      case 'Winter':
        return Icons.ac_unit;
      default:
        return Icons.calendar_today;
    }
  }

  Color _getSeasonColor(String season) {
    switch (season) {
      case 'Spring':
        return Colors.green;
      case 'Summer':
        return Colors.orange;
      case 'Autumn':
        return Colors.brown;
      case 'Winter':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

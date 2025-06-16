import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/farm.dart';
import '../../domain/entities/activity.dart';
import '../providers/activity_provider.dart';
import '../providers/analytics_provider.dart';
import '../states/activity_state.dart';
import 'create_activity_screen.dart';
import 'activity_details_screen.dart';
import '../widgets/analytics_widgets.dart';
import '../widgets/settings_widgets.dart';
import '../../domain/entities/farm_settings.dart';

/// Farm details screen with integrated activity management
class FarmDetailsScreen extends ConsumerStatefulWidget {
  final FarmEntity farm;

  const FarmDetailsScreen({super.key, required this.farm});

  @override
  ConsumerState<FarmDetailsScreen> createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState extends ConsumerState<FarmDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load farm activities when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFarmActivities();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadFarmActivities() {
    print('Loading activities for farm: ${widget.farm.id}'); // Debug log
    ref.read(activityProvider.notifier).loadFarmActivities(widget.farm.id);
  }

  /// Refresh all farm data
  void _refreshAllFarmData() {
    print('Refreshing all farm data for: ${widget.farm.id}'); // Debug log

    // Refresh main activity list
    _loadFarmActivities();

    // Invalidate all farm-related providers to force refresh
    ref.invalidate(farmActivityStatisticsProvider(widget.farm.id));
    ref.invalidate(farmRecentActivitiesProvider(widget.farm.id));
    ref.invalidate(farmUpcomingActivitiesProvider(widget.farm.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Listen to activity state changes and refresh statistics when activities are loaded
    ref.listen<ActivityState>(activityProvider, (previous, next) {
      final nextString = next.toString();
      final previousString = previous?.toString() ?? '';

      // If we just loaded activities successfully, refresh the statistics
      if (nextString.contains('ActivityState.loaded') &&
          !previousString.contains('ActivityState.loaded')) {
        print(
          'Activity state changed to loaded, refreshing statistics',
        ); // Debug

        // Invalidate statistics providers to refresh them
        ref.invalidate(farmActivityStatisticsProvider(widget.farm.id));
        ref.invalidate(farmRecentActivitiesProvider(widget.farm.id));
        ref.invalidate(farmUpcomingActivitiesProvider(widget.farm.id));
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          // Farm header info
          _buildFarmHeader(theme),

          // Tab bar
          _buildTabBar(theme),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(theme),
                _buildActivitiesTab(theme),
                _buildAnalyticsTab(theme),
                _buildSettingsTab(theme),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text(
        widget.farm.name,
        style: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.fontSize20,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () => _showFarmMenu(),
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  /// Build farm header with key information
  Widget _buildFarmHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: ResponsiveUtils.iconSize16,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: ResponsiveUtils.spacing4),
                        Expanded(
                          child: Text(
                            widget.farm.location,
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveUtils.fontSize14,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.height4),
                    Row(
                      children: [
                        Icon(
                          Icons.straighten,
                          size: ResponsiveUtils.iconSize16,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: ResponsiveUtils.spacing4),
                        Text(
                          widget.farm.formattedSize,
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize14,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusChip(theme, widget.farm.status),
            ],
          ),

          if (widget.farm.cropTypes.isNotEmpty) ...[
            SizedBox(height: ResponsiveUtils.height12),
            Wrap(
              spacing: ResponsiveUtils.spacing8,
              runSpacing: ResponsiveUtils.spacing4,
              children:
                  widget.farm.cropTypes.map((crop) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.spacing8,
                        vertical: ResponsiveUtils.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.radius8,
                        ),
                      ),
                      child: Text(
                        crop,
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize12,
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// Build status chip
  Widget _buildStatusChip(ThemeData theme, FarmStatus status) {
    Color color;
    switch (status) {
      case FarmStatus.active:
        color = Colors.green;
        break;
      case FarmStatus.planning:
        color = Colors.orange;
        break;
      case FarmStatus.harvesting:
        color = Colors.blue;
        break;
      case FarmStatus.inactive:
        color = Colors.grey;
        break;
      case FarmStatus.maintenance:
        color = Colors.red;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing8,
        vertical: ResponsiveUtils.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
      ),
      child: Text(
        status.displayName,
        style: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Build tab bar
  Widget _buildTabBar(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.6,
        ),
        indicatorColor: theme.colorScheme.primary,
        labelStyle: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Activities'),
          Tab(text: 'Analytics'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }

  /// Build overview tab
  Widget _buildOverviewTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(theme),
          SizedBox(height: ResponsiveUtils.height24),
          _buildRecentActivities(theme),
          SizedBox(height: ResponsiveUtils.height24),
          _buildUpcomingTasks(theme),
        ],
      ),
    );
  }

  /// Build activities tab
  Widget _buildActivitiesTab(ThemeData theme) {
    final activityState = ref.watch(activityProvider);

    return RefreshIndicator(
      onRefresh: () async {
        _refreshAllFarmData();
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: _buildActivitiesList(theme, activityState),
    );
  }

  /// Build analytics tab
  Widget _buildAnalyticsTab(ThemeData theme) {
    final analyticsAsync = ref.watch(farmAnalyticsProvider(widget.farm.id));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(farmAnalyticsProvider(widget.farm.id));
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: analyticsAsync.when(
        data: (analytics) => _buildAnalyticsContent(theme, analytics),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildAnalyticsError(theme, error),
      ),
    );
  }

  /// Build analytics content
  Widget _buildAnalyticsContent(ThemeData theme, FarmAnalytics analytics) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview cards
          AnalyticsOverviewCards(analytics: analytics),
          SizedBox(height: ResponsiveUtils.height20),

          // Activity status distribution
          ActivityStatusPieChart(
            activitiesByStatus: analytics.activitiesByStatus,
          ),
          SizedBox(height: ResponsiveUtils.height20),

          // Monthly trends
          MonthlyTrendChart(monthlyData: analytics.monthlyData),
          SizedBox(height: ResponsiveUtils.height20),

          // Activity type performance
          ActivityTypePerformanceChart(
            typePerformance: analytics.typePerformance,
          ),
          SizedBox(height: ResponsiveUtils.height20),

          // Responsive layout for smaller widgets
          _buildResponsiveWidgetLayout(analytics, theme),

          SizedBox(height: ResponsiveUtils.height20),

          // Action recommendations
          _buildActionRecommendations(theme, analytics),

          SizedBox(height: ResponsiveUtils.height100), // Bottom padding
        ],
      ),
    );
  }

  /// Build analytics error state
  Widget _buildAnalyticsError(ThemeData theme, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            size: ResponsiveUtils.iconSize64,
            color: theme.colorScheme.error,
          ),
          SizedBox(height: ResponsiveUtils.height16),
          Text(
            'Error loading analytics',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.error,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height8),
          Text(
            'Please try again later',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: ResponsiveUtils.height16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(farmAnalyticsProvider(widget.farm.id));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build responsive widget layout
  Widget _buildResponsiveWidgetLayout(
    FarmAnalytics analytics,
    ThemeData theme,
  ) {
    // Check screen width to determine layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800; // Tablet/Desktop breakpoint

    if (isWideScreen) {
      // Two-column layout for wide screens
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                // Upcoming deadlines
                UpcomingDeadlinesWidget(
                  upcomingDeadlines: analytics.upcomingDeadlines,
                ),
                SizedBox(height: ResponsiveUtils.height20),

                // Cost analysis
                CostAnalysisWidget(costAnalysis: analytics.costAnalysis),
              ],
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing16),
          Expanded(
            child: Column(
              children: [
                // Seasonal insights
                SeasonalInsightsWidget(
                  seasonalInsights: analytics.seasonalInsights,
                ),
                SizedBox(height: ResponsiveUtils.height20),

                // Performance summary
                _buildPerformanceSummary(theme, analytics),
              ],
            ),
          ),
        ],
      );
    } else {
      // Single-column layout for mobile screens
      return Column(
        children: [
          // Upcoming deadlines
          UpcomingDeadlinesWidget(
            upcomingDeadlines: analytics.upcomingDeadlines,
          ),
          SizedBox(height: ResponsiveUtils.height20),

          // Performance summary
          _buildPerformanceSummary(theme, analytics),
          SizedBox(height: ResponsiveUtils.height20),

          // Cost analysis
          CostAnalysisWidget(costAnalysis: analytics.costAnalysis),
          SizedBox(height: ResponsiveUtils.height20),

          // Seasonal insights
          SeasonalInsightsWidget(seasonalInsights: analytics.seasonalInsights),
        ],
      );
    }
  }

  /// Build performance summary widget
  Widget _buildPerformanceSummary(ThemeData theme, FarmAnalytics analytics) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: theme.colorScheme.primary,
                  size: ResponsiveUtils.iconSize20,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Text(
                  'Performance Summary',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.height16),

            // Productivity score
            _buildPerformanceMetric(
              theme,
              'Productivity Score',
              analytics.productivityScore.toStringAsFixed(0),
              _getProductivityColor(analytics.productivityScore),
              Icons.speed,
            ),
            SizedBox(height: ResponsiveUtils.height12),

            // Completion rate
            _buildPerformanceMetric(
              theme,
              'Completion Rate',
              '${analytics.completionRate.toStringAsFixed(1)}%',
              _getCompletionColor(analytics.completionRate),
              Icons.check_circle,
            ),
            SizedBox(height: ResponsiveUtils.height12),

            // Activity frequency
            _buildPerformanceMetric(
              theme,
              'Weekly Activity Rate',
              '${_calculateActivityFrequency(analytics)} activities/week',
              Colors.blue,
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  /// Build performance metric item
  Widget _buildPerformanceMetric(
    ThemeData theme,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: ResponsiveUtils.iconSize16, color: color),
        SizedBox(width: ResponsiveUtils.spacing8),
        Expanded(
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
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build action recommendations widget
  Widget _buildActionRecommendations(ThemeData theme, FarmAnalytics analytics) {
    final recommendations = _generateRecommendations(analytics);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: theme.colorScheme.secondary,
                  size: ResponsiveUtils.iconSize20,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Text(
                  'Action Recommendations',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.height16),

            if (recommendations.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.thumb_up,
                      size: ResponsiveUtils.iconSize48,
                      color: Colors.green,
                    ),
                    SizedBox(height: ResponsiveUtils.height12),
                    Text(
                      'Great job! No immediate actions needed.',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize14,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...recommendations.map(
                (recommendation) =>
                    _buildRecommendationItem(theme, recommendation),
              ),
          ],
        ),
      ),
    );
  }

  /// Build recommendation item
  Widget _buildRecommendationItem(
    ThemeData theme,
    Map<String, dynamic> recommendation,
  ) {
    final priority = recommendation['priority'] as String;
    final title = recommendation['title'] as String;
    final description = recommendation['description'] as String;
    final action = recommendation['action'] as String;

    Color priorityColor;
    IconData priorityIcon;

    switch (priority) {
      case 'high':
        priorityColor = Colors.red;
        priorityIcon = Icons.priority_high;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        priorityIcon = Icons.warning;
        break;
      default:
        priorityColor = Colors.blue;
        priorityIcon = Icons.info;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.height12),
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.spacing12),
        decoration: BoxDecoration(
          color: priorityColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
          border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  priorityIcon,
                  color: priorityColor,
                  size: ResponsiveUtils.iconSize16,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.height8),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: ResponsiveUtils.height8),
            Text(
              'Action: $action',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                fontWeight: FontWeight.w500,
                color: priorityColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build settings tab
  Widget _buildSettingsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farm info header
          _buildFarmInfoHeader(theme),
          SizedBox(height: ResponsiveUtils.height24),

          // Settings categories
          Text(
            'Settings',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height16),

          // Settings categories grid
          _buildSettingsCategories(theme),
          SizedBox(height: ResponsiveUtils.height24),

          // Quick actions
          _buildQuickActions(theme),
          SizedBox(height: ResponsiveUtils.height24),

          // Farm statistics
          _buildFarmStatistics(theme),
          SizedBox(height: ResponsiveUtils.height100), // Bottom padding
        ],
      ),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToCreateActivity(),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: Text(
        'Add Activity',
        style: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Navigate to create activity screen
  void _navigateToCreateActivity() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CreateActivityScreen(farm: widget.farm),
      ),
    );

    if (result == true) {
      // Refresh all farm-related data
      _refreshAllFarmData();
    }
  }

  /// Show farm menu
  void _showFarmMenu() {
    // TODO: Implement farm menu (edit, delete, etc.)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Farm menu coming soon')));
  }

  /// Build quick stats section
  Widget _buildQuickStats(ThemeData theme) {
    final statisticsAsync = ref.watch(
      farmActivityStatisticsProvider(widget.farm.id),
    );

    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height16),
            statisticsAsync.when(
              data:
                  (stats) => Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          theme,
                          'Total Activities',
                          stats['total'].toString(),
                          Icons.task,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          theme,
                          'Completed',
                          stats['completed'].toString(),
                          Icons.check_circle,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          theme,
                          'Pending',
                          (stats['planned'] + stats['inProgress']).toString(),
                          Icons.pending,
                        ),
                      ),
                    ],
                  ),
              loading:
                  () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              error:
                  (error, stack) => Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          theme,
                          'Total Activities',
                          '0',
                          Icons.task,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          theme,
                          'Completed',
                          '0',
                          Icons.check_circle,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          theme,
                          'Pending',
                          '0',
                          Icons.pending,
                        ),
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build stat item
  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: ResponsiveUtils.iconSize24,
          color: theme.colorScheme.primary,
        ),
        SizedBox(height: ResponsiveUtils.height8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build recent activities section
  Widget _buildRecentActivities(ThemeData theme) {
    final recentActivitiesAsync = ref.watch(
      farmRecentActivitiesProvider(widget.farm.id),
    );

    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activities',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.height12),
            recentActivitiesAsync.when(
              data: (activities) {
                if (activities.isEmpty) {
                  return Text(
                    'No recent activities',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  );
                }

                return Column(
                  children:
                      activities
                          .map(
                            (activity) => Padding(
                              padding: EdgeInsets.only(
                                bottom: ResponsiveUtils.height8,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getActivityIcon(activity.type),
                                    size: ResponsiveUtils.iconSize16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  SizedBox(width: ResponsiveUtils.spacing8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activity.title,
                                          style: GoogleFonts.inter(
                                            fontSize:
                                                ResponsiveUtils.fontSize14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          activity.formattedCreatedDate,
                                          style: GoogleFonts.inter(
                                            fontSize:
                                                ResponsiveUtils.fontSize12,
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildActivityStatusChip(
                                    theme,
                                    activity.status,
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                );
              },
              loading:
                  () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              error:
                  (error, stack) => Text(
                    'Error loading recent activities',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      color: theme.colorScheme.error,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build upcoming tasks section
  Widget _buildUpcomingTasks(ThemeData theme) {
    final upcomingActivitiesAsync = ref.watch(
      farmUpcomingActivitiesProvider(widget.farm.id),
    );

    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Tasks',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height12),
            upcomingActivitiesAsync.when(
              data: (activities) {
                if (activities.isEmpty) {
                  return Text(
                    'No upcoming tasks',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  );
                }

                return Column(
                  children:
                      activities
                          .map(
                            (activity) => Padding(
                              padding: EdgeInsets.only(
                                bottom: ResponsiveUtils.height8,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getActivityIcon(activity.type),
                                    size: ResponsiveUtils.iconSize16,
                                    color: theme.colorScheme.secondary,
                                  ),
                                  SizedBox(width: ResponsiveUtils.spacing8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activity.title,
                                          style: GoogleFonts.inter(
                                            fontSize:
                                                ResponsiveUtils.fontSize14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Due: ${activity.formattedScheduledDate}',
                                          style: GoogleFonts.inter(
                                            fontSize:
                                                ResponsiveUtils.fontSize12,
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildActivityPriorityChip(
                                    theme,
                                    activity.priority,
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                );
              },
              loading:
                  () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              error:
                  (error, stack) => Text(
                    'Error loading upcoming tasks',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      color: theme.colorScheme.error,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build activities list
  Widget _buildActivitiesList(ThemeData theme, ActivityState activityState) {
    final stateString = activityState.toString();

    if (stateString.contains('ActivityState.loading')) {
      return const Center(child: CircularProgressIndicator());
    } else if (stateString.contains('ActivityState.error')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveUtils.iconSize64,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: ResponsiveUtils.height16),
            Text(
              'Error loading activities',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.error,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height16),
            ElevatedButton(
              onPressed: _loadFarmActivities,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (stateString.contains('ActivityState.loaded')) {
      // Extract activities from state
      List<ActivityEntity> activities = [];
      try {
        final dynamic dynamicState = activityState;
        if (dynamicState.activities != null) {
          activities = dynamicState.activities as List<ActivityEntity>;
        }
      } catch (e) {
        // Fallback to empty list
      }

      if (activities.isEmpty) {
        return _buildEmptyActivitiesState(theme);
      }

      return ListView.builder(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _buildActivityCard(theme, activity);
        },
      );
    } else {
      return _buildEmptyActivitiesState(theme);
    }
  }

  /// Build empty activities state
  Widget _buildEmptyActivitiesState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.agriculture,
            size: ResponsiveUtils.iconSize64,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          SizedBox(height: ResponsiveUtils.height16),
          Text(
            'No Activities Yet',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height8),
          Text(
            'Start managing your farm by adding activities',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.height24),
          ElevatedButton.icon(
            onPressed: _navigateToCreateActivity,
            icon: const Icon(Icons.add),
            label: const Text('Add First Activity'),
          ),
        ],
      ),
    );
  }

  /// Build activity card
  Widget _buildActivityCard(ThemeData theme, ActivityEntity activity) {
    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.height12),
      child: InkWell(
        onTap: () => _navigateToActivityDetails(activity),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      activity.title,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.fontSize16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildActivityStatusChip(theme, activity.status),
                ],
              ),
              SizedBox(height: ResponsiveUtils.height8),
              Text(
                activity.description,
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: ResponsiveUtils.height12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: ResponsiveUtils.iconSize16,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: ResponsiveUtils.spacing4),
                  Text(
                    activity.formattedScheduledDate,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  _buildActivityPriorityChip(theme, activity.priority),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build activity status chip
  Widget _buildActivityStatusChip(ThemeData theme, ActivityStatus status) {
    Color color;
    switch (status) {
      case ActivityStatus.planned:
        color = Colors.orange;
        break;
      case ActivityStatus.inProgress:
        color = Colors.blue;
        break;
      case ActivityStatus.completed:
        color = Colors.green;
        break;
      case ActivityStatus.cancelled:
        color = Colors.red;
        break;
      case ActivityStatus.overdue:
        color = Colors.red.shade700;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing8,
        vertical: ResponsiveUtils.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
      ),
      child: Text(
        status.displayName,
        style: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Build activity priority chip
  Widget _buildActivityPriorityChip(
    ThemeData theme,
    ActivityPriority priority,
  ) {
    Color color;
    switch (priority) {
      case ActivityPriority.low:
        color = Colors.green;
        break;
      case ActivityPriority.medium:
        color = Colors.orange;
        break;
      case ActivityPriority.high:
        color = Colors.red;
        break;
      case ActivityPriority.urgent:
        color = Colors.red.shade900;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing6,
        vertical: ResponsiveUtils.spacing2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius6),
      ),
      child: Text(
        priority.displayName,
        style: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  /// Navigate to activity details
  void _navigateToActivityDetails(ActivityEntity activity) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ActivityDetailsScreen(activity: activity),
      ),
    );

    if (result == true) {
      // Refresh all farm-related data
      _refreshAllFarmData();
    }
  }

  /// Get icon for activity type
  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.planting:
        return Icons.eco;
      case ActivityType.watering:
        return Icons.water_drop;
      case ActivityType.fertilizing:
        return Icons.grass;
      case ActivityType.pestControl:
        return Icons.bug_report;
      case ActivityType.weeding:
        return Icons.cleaning_services;
      case ActivityType.harvesting:
        return Icons.agriculture;
      case ActivityType.soilPreparation:
        return Icons.landscape;
      case ActivityType.pruning:
        return Icons.content_cut;
      case ActivityType.monitoring:
        return Icons.visibility;
      case ActivityType.maintenance:
        return Icons.build;
      case ActivityType.other:
        return Icons.more_horiz;
    }
  }

  /// Get productivity color based on score
  Color _getProductivityColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.yellow.shade700;
    return Colors.red;
  }

  /// Get completion color based on rate
  Color _getCompletionColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 70) return Colors.orange;
    if (rate >= 50) return Colors.yellow.shade700;
    return Colors.red;
  }

  /// Calculate activity frequency
  String _calculateActivityFrequency(FarmAnalytics analytics) {
    if (analytics.totalActivities == 0) return '0.0';
    return (analytics.totalActivities / 30.0 * 7).toStringAsFixed(1);
  }

  /// Generate recommendations based on analytics
  List<Map<String, dynamic>> _generateRecommendations(FarmAnalytics analytics) {
    final recommendations = <Map<String, dynamic>>[];

    // Check for overdue activities
    if (analytics.overdueActivities > 0) {
      recommendations.add({
        'priority': 'high',
        'title': 'Overdue Activities',
        'description':
            'You have ${analytics.overdueActivities} overdue activities that need immediate attention.',
        'action': 'Review and complete overdue tasks in the Activities tab',
      });
    }

    // Check completion rate
    if (analytics.completionRate < 70) {
      recommendations.add({
        'priority': 'medium',
        'title': 'Low Completion Rate',
        'description':
            'Your completion rate is ${analytics.completionRate.toStringAsFixed(1)}%. Consider reviewing your planning process.',
        'action':
            'Focus on completing existing activities before adding new ones',
      });
    }

    // Check productivity score
    if (analytics.productivityScore < 60) {
      recommendations.add({
        'priority': 'medium',
        'title': 'Productivity Improvement',
        'description':
            'Your productivity score is ${analytics.productivityScore.toStringAsFixed(0)}. There\'s room for improvement.',
        'action':
            'Set realistic deadlines and maintain consistent activity scheduling',
      });
    }

    // Check for upcoming deadlines
    final criticalDeadlines =
        analytics.upcomingDeadlines
            .where((d) => d.urgencyLevel == 'Critical')
            .length;
    if (criticalDeadlines > 0) {
      recommendations.add({
        'priority': 'high',
        'title': 'Critical Deadlines',
        'description':
            'You have $criticalDeadlines activities due within 24 hours.',
        'action': 'Prioritize critical activities to avoid delays',
      });
    }

    // Check activity frequency
    if (analytics.totalActivities > 0) {
      final weeklyRate = analytics.totalActivities / 30.0 * 7;
      if (weeklyRate < 2) {
        recommendations.add({
          'priority': 'low',
          'title': 'Low Activity Frequency',
          'description':
              'You\'re averaging ${weeklyRate.toStringAsFixed(1)} activities per week.',
          'action':
              'Consider increasing farm activity frequency for better productivity',
        });
      }
    }

    // Seasonal recommendations
    final season = analytics.seasonalInsights.currentSeason;
    if (analytics.seasonalInsights.recommendedActivities.isNotEmpty) {
      recommendations.add({
        'priority': 'low',
        'title': '$season Activities',
        'description': 'Consider seasonal activities appropriate for $season.',
        'action': 'Check seasonal insights for recommended activities',
      });
    }

    return recommendations;
  }

  /// Build farm info header for settings
  Widget _buildFarmInfoHeader(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Row(
          children: [
            Container(
              width: ResponsiveUtils.iconSize64,
              height: ResponsiveUtils.iconSize64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
              ),
              child: Icon(
                Icons.agriculture,
                color: theme.colorScheme.primary,
                size: ResponsiveUtils.iconSize32,
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.farm.name,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.fontSize18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.height4),
                  Text(
                    widget.farm.location,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.height4),
                  Text(
                    '${widget.farm.size} hectares',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _showFarmMenu,
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build settings categories
  Widget _buildSettingsCategories(ThemeData theme) {
    final categories = [
      SettingsCategory.general,
      SettingsCategory.notifications,
      SettingsCategory.activities,
      SettingsCategory.weather,
      SettingsCategory.security,
      SettingsCategory.backup,
    ];

    return Column(
      children:
          categories.map((category) {
            return Padding(
              padding: EdgeInsets.only(bottom: ResponsiveUtils.height12),
              child: SettingsCategoryCard(
                category: category,
                onTap: () => _navigateToSettingsCategory(category),
              ),
            );
          }).toList(),
    );
  }

  /// Build quick actions
  Widget _buildQuickActions(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height16),

            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    theme,
                    'Export Data',
                    Icons.download,
                    Colors.blue,
                    _exportFarmData,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing12),
                Expanded(
                  child: _buildQuickActionButton(
                    theme,
                    'Backup Now',
                    Icons.backup,
                    Colors.green,
                    _backupFarmData,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.height12),

            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    theme,
                    'Share Farm',
                    Icons.share,
                    Colors.orange,
                    _shareFarm,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing12),
                Expanded(
                  child: _buildQuickActionButton(
                    theme,
                    'Help & Support',
                    Icons.help,
                    Colors.purple,
                    _showHelp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build quick action button
  Widget _buildQuickActionButton(
    ThemeData theme,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.spacing12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: ResponsiveUtils.iconSize24),
            SizedBox(height: ResponsiveUtils.height8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build farm statistics
  Widget _buildFarmStatistics(ThemeData theme) {
    // Get real-time analytics data from Firestore
    final analyticsAsync = ref.watch(farmAnalyticsProvider(widget.farm.id));

    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farm Statistics',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height16),

            Row(
              children: [
                Expanded(
                  child: _buildFarmStatItem(
                    theme,
                    'Total Area',
                    '${widget.farm.size} ha',
                    Icons.landscape,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildFarmStatItem(
                    theme,
                    'Established',
                    _getEstablishedYear(),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.height12),

            Row(
              children: [
                Expanded(
                  child: analyticsAsync.when(
                    data:
                        (analytics) => _buildFarmStatItem(
                          theme,
                          'Activity Types',
                          _getActivityTypesCount(analytics).toString(),
                          Icons.eco,
                          Colors.orange,
                        ),
                    loading:
                        () => _buildFarmStatItem(
                          theme,
                          'Activity Types',
                          '...',
                          Icons.eco,
                          Colors.orange,
                        ),
                    error:
                        (_, _) => _buildFarmStatItem(
                          theme,
                          'Activity Types',
                          '0',
                          Icons.eco,
                          Colors.orange,
                        ),
                  ),
                ),
                Expanded(
                  child: _buildFarmStatItem(
                    theme,
                    'Last Updated',
                    _getLastUpdated(),
                    Icons.update,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build farm stat item
  Widget _buildFarmStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing12),
      margin: EdgeInsets.symmetric(horizontal: ResponsiveUtils.spacing4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: ResponsiveUtils.iconSize20),
          SizedBox(height: ResponsiveUtils.height8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize10,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Navigate to settings category
  void _navigateToSettingsCategory(SettingsCategory category) {
    // TODO: Navigate to specific settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${category.displayName} settings coming soon'),
        backgroundColor: _getCategoryColor(category),
      ),
    );
  }

  /// Get category color
  Color _getCategoryColor(SettingsCategory category) {
    switch (category) {
      case SettingsCategory.general:
        return Colors.blue;
      case SettingsCategory.notifications:
        return Colors.orange;
      case SettingsCategory.activities:
        return Colors.green;
      case SettingsCategory.weather:
        return Colors.amber;
      case SettingsCategory.security:
        return Colors.red;
      case SettingsCategory.backup:
        return Colors.purple;
      case SettingsCategory.about:
        return Colors.grey;
    }
  }

  /// Export farm data
  void _exportFarmData() {
    // TODO: Implement data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting farm data...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Backup farm data
  void _backupFarmData() {
    // TODO: Implement backup functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creating backup...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Share farm
  void _shareFarm() {
    // TODO: Implement farm sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing farm details...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  /// Show help
  void _showHelp() {
    // TODO: Navigate to help screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening help & support...'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  /// Get farm establishment year from Firestore data
  String _getEstablishedYear() {
    return widget.farm.createdAt.year.toString();
  }

  /// Get count of unique activity types from analytics data
  int _getActivityTypesCount(FarmAnalytics analytics) {
    return analytics.activitiesByType.keys.length;
  }

  /// Get last updated time from Firestore data
  String _getLastUpdated() {
    final lastUpdate = widget.farm.updatedAt ?? widget.farm.lastActivity;
    if (lastUpdate == null) {
      return 'Never';
    }

    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

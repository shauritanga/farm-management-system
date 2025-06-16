import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';
import '../../../subscription/domain/entities/subscription.dart';
import '../../../weather/presentation/providers/weather_provider.dart';
import '../../../weather/domain/entities/weather.dart';
import '../../../weather/presentation/screens/detailed_weather_screen.dart';
import '../../../farm/presentation/providers/farm_provider.dart';
import '../../../farm/presentation/providers/activity_provider.dart';
import '../../../farm/domain/entities/activity.dart';
import '../../../farm/domain/entities/farm.dart';

class FarmerDashboardScreen extends ConsumerStatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  ConsumerState<FarmerDashboardScreen> createState() =>
      _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends ConsumerState<FarmerDashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme, user),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(ResponsiveUtils.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats Overview
              _buildQuickStatsSection(theme, user),

              SizedBox(height: ResponsiveUtils.height24),

              // Weather Section
              _buildWeatherSection(theme),

              SizedBox(height: ResponsiveUtils.height24),

              // Farm Overview
              _buildFarmOverviewSection(theme, user),

              SizedBox(height: ResponsiveUtils.height24),

              // Recent Activities
              _buildRecentActivitiesSection(theme),

              SizedBox(height: ResponsiveUtils.height24),

              // Quick Actions
              _buildQuickActionsSection(theme),

              SizedBox(height: ResponsiveUtils.height24),

              // Market Insights
              _buildMarketInsightsSection(theme),

              SizedBox(height: ResponsiveUtils.height24),

              // Subscription Status
              _buildSubscriptionStatusSection(theme, user),

              SizedBox(height: ResponsiveUtils.height32),
            ],
          ),
        ),
      ),
    );
  }

  /// Build app bar with avatar and greeting
  PreferredSizeWidget _buildAppBar(ThemeData theme, dynamic user) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Avatar
          Container(
            width: ResponsiveUtils.iconSize40,
            height: ResponsiveUtils.iconSize40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child:
                  user.profileImageUrl != null
                      ? Image.network(
                        user.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                _buildDefaultAvatar(),
                      )
                      : _buildDefaultAvatar(),
            ),
          ),

          SizedBox(width: ResponsiveUtils.spacing12),

          // Greeting and name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  user.name.split(' ').first, // First name only
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Notifications icon
        IconButton(
          onPressed: () => _showNotifications(),
          icon: Stack(
            children: [
              Icon(
                HugeIcons.strokeRoundedNotification03,
                size: ResponsiveUtils.iconSize24,
                color: Colors.white,
              ),
              // Notification badge
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: ResponsiveUtils.iconSize8,
                  height: ResponsiveUtils.iconSize8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing8),
      ],
    );
  }

  /// Build default avatar
  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Icon(
        Icons.person,
        size: ResponsiveUtils.iconSize20,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Handle refresh
  Future<void> _handleRefresh() async {
    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated) return;

    final userId = authState.user.id;

    // Refresh weather data
    ref.invalidate(gpsWeatherProvider);

    // Refresh farm data
    ref.invalidate(farmStatisticsProvider(userId));

    // Refresh activity data for all user's farms
    ref.invalidate(activityStatisticsProvider(userId));
    ref.invalidate(upcomingActivitiesProvider(userId));
    ref.invalidate(farmerRecentActivitiesProvider(userId));

    // Wait a bit for the refresh to complete
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Show notifications
  void _showNotifications() {
    // For now, show a snackbar since notifications screen might not be implemented yet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications feature coming soon')),
    );
  }

  /// Build quick stats section
  Widget _buildQuickStatsSection(ThemeData theme, dynamic user) {
    // First get the user's farms
    final farmStatsAsync = ref.watch(farmStatisticsProvider(user.id));

    return farmStatsAsync.when(
      data: (farmStats) => _buildQuickStatsWithFarmData(theme, user, farmStats),
      loading: () => _buildQuickStatsLoading(theme),
      error: (error, stack) => _buildQuickStatsError(theme),
    );
  }

  /// Build quick stats with farm data
  Widget _buildQuickStatsWithFarmData(
    ThemeData theme,
    dynamic user,
    Map<String, dynamic> farmStats,
  ) {
    // Check if user has any farms using the totalFarms count
    final totalFarms = farmStats['totalFarms'] ?? 0;

    if (totalFarms == 0) {
      return _buildQuickStatsEmpty(theme);
    }

    // Get activity statistics for the farmer (across all farms)
    final activityStatsAsync = ref.watch(activityStatisticsProvider(user.id));

    return activityStatsAsync.when(
      data:
          (activityStats) =>
              _buildQuickStatsContent(theme, farmStats, activityStats),
      loading: () => _buildQuickStatsLoading(theme),
      error:
          (error, stack) => _buildQuickStatsContent(
            theme,
            farmStats,
            <String, dynamic>{}, // Empty activity stats on error
          ),
    );
  }

  /// Build quick stats content with real data
  Widget _buildQuickStatsContent(
    ThemeData theme,
    Map<String, dynamic> farmStats,
    Map<String, dynamic> activityStats,
  ) {
    final totalFarms = farmStats['totalFarms'] ?? 0;
    final activeCrops = farmStats['uniqueCropTypes'] ?? 0;
    final monthlyRevenue = _calculateMonthlyRevenue(activityStats);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            'Total Farms',
            totalFarms.toString(),
            Icons.agriculture,
            theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing12),
        Expanded(
          child: _buildStatCard(
            theme,
            'Active Crops',
            activeCrops.toString(),
            Icons.eco,
            theme.colorScheme.secondary,
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing12),
        Expanded(
          child: _buildStatCard(
            theme,
            'This Month',
            monthlyRevenue,
            Icons.trending_up,
            Colors.green,
          ),
        ),
      ],
    );
  }

  /// Build quick stats loading state
  Widget _buildQuickStatsLoading(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            'Total Farms',
            '...',
            Icons.agriculture,
            theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing12),
        Expanded(
          child: _buildStatCard(
            theme,
            'Active Crops',
            '...',
            Icons.eco,
            theme.colorScheme.secondary,
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing12),
        Expanded(
          child: _buildStatCard(
            theme,
            'This Month',
            '...',
            Icons.trending_up,
            Colors.green,
          ),
        ),
      ],
    );
  }

  /// Build quick stats error state
  Widget _buildQuickStatsError(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            'Total Farms',
            '--',
            Icons.agriculture,
            theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing12),
        Expanded(
          child: _buildStatCard(
            theme,
            'Active Crops',
            '--',
            Icons.eco,
            theme.colorScheme.secondary,
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing12),
        Expanded(
          child: _buildStatCard(
            theme,
            'This Month',
            '--',
            Icons.trending_up,
            Colors.green,
          ),
        ),
      ],
    );
  }

  /// Build quick stats empty state (no farms)
  Widget _buildQuickStatsEmpty(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            'Total Farms',
            '0',
            Icons.agriculture,
            theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing12),
        Expanded(
          child: _buildStatCard(
            theme,
            'Active Crops',
            '0',
            Icons.eco,
            theme.colorScheme.secondary,
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing12),
        Expanded(
          child: _buildStatCard(
            theme,
            'This Month',
            '\$0',
            Icons.trending_up,
            Colors.green,
          ),
        ),
      ],
    );
  }

  /// Calculate monthly revenue from activity statistics
  String _calculateMonthlyRevenue(Map<String, dynamic> activityStats) {
    // For now, we'll calculate based on completed activities
    // In a real app, this would come from harvest/sales data
    final completed = activityStats['completed'] ?? 0;
    final estimatedRevenue = completed * 150; // Rough estimate per activity

    if (estimatedRevenue >= 1000) {
      return '\$${(estimatedRevenue / 1000).toStringAsFixed(1)}k';
    } else {
      return '\$$estimatedRevenue';
    }
  }

  /// Build stat card
  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: ResponsiveUtils.spacing4,
            offset: Offset(0, ResponsiveUtils.spacing2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: ResponsiveUtils.iconSize20, color: color),
          SizedBox(height: ResponsiveUtils.height8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize10,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Build weather section
  Widget _buildWeatherSection(ThemeData theme) {
    final weatherAsync = ref.watch(gpsWeatherProvider);

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: ResponsiveUtils.spacing8,
            offset: Offset(0, ResponsiveUtils.spacing4),
          ),
        ],
      ),
      child: weatherAsync.when(
        data: (weatherData) => _buildWeatherContent(theme, weatherData),
        loading: () => _buildWeatherLoading(theme),
        error: (error, stack) => _buildWeatherError(theme, error),
      ),
    );
  }

  /// Build weather content with real data
  Widget _buildWeatherContent(ThemeData theme, WeatherData weatherData) {
    final current = weatherData.current;
    final forecast = weatherData.fiveDayForecast;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getWeatherIcon(current.condition.main),
              color: Colors.white,
              size: ResponsiveUtils.iconSize24,
            ),
            SizedBox(width: ResponsiveUtils.spacing8),
            Text(
              'Weather Today',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              '${current.location}, ${current.country}',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),

        SizedBox(height: ResponsiveUtils.height16),

        Row(
          children: [
            // Temperature
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current.temperatureCelsius,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  current.condition.description.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Weather details
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildWeatherDetail(
                  'Humidity',
                  current.humidityPercent,
                  Icons.water_drop,
                ),
                SizedBox(height: ResponsiveUtils.height4),
                _buildWeatherDetail('Wind', current.windSpeedKmh, Icons.air),
                SizedBox(height: ResponsiveUtils.height4),
                _buildWeatherDetail(
                  'Feels like',
                  current.feelsLikeCelsius,
                  Icons.thermostat,
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: ResponsiveUtils.height16),

        // Weather forecast
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              forecast.take(4).map((forecastDay) {
                return _buildForecastItem(
                  forecastDay.dayName,
                  forecastDay.temperatureRange,
                  _getWeatherIcon(forecastDay.condition.main),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// Build weather loading state
  Widget _buildWeatherLoading(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.wb_sunny,
              color: Colors.white,
              size: ResponsiveUtils.iconSize24,
            ),
            SizedBox(width: ResponsiveUtils.spacing8),
            Text(
              'Loading Weather...',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.height16),
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }

  /// Build weather error state
  Widget _buildWeatherError(ThemeData theme, Object error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: ResponsiveUtils.iconSize24,
            ),
            SizedBox(width: ResponsiveUtils.spacing8),
            Text(
              'Weather Unavailable',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.height8),
        Text(
          'Unable to load weather data',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  /// Build weather detail item
  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: ResponsiveUtils.iconSize12,
          color: Colors.white.withValues(alpha: 0.8),
        ),
        SizedBox(width: ResponsiveUtils.spacing4),
        Text(
          '$label: $value',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize10,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  /// Build forecast item
  Widget _buildForecastItem(String day, String temp, IconData icon) {
    return Column(
      children: [
        Text(
          day,
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize10,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: ResponsiveUtils.height4),
        Icon(icon, size: ResponsiveUtils.iconSize16, color: Colors.white),
        SizedBox(height: ResponsiveUtils.height4),
        Text(
          temp,
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize10,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Build farm overview section
  Widget _buildFarmOverviewSection(ThemeData theme, dynamic user) {
    // Use a FutureProvider to get farms directly
    final farmsAsync = ref.watch(farmsListProvider(user.id));

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: ResponsiveUtils.spacing8,
            offset: Offset(0, ResponsiveUtils.spacing2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.agriculture,
                color: theme.colorScheme.primary,
                size: ResponsiveUtils.iconSize24,
              ),
              SizedBox(width: ResponsiveUtils.spacing8),
              Text(
                'Farm Overview',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _navigateToFarms(),
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.height16),

          // Farm data from Firestore
          farmsAsync.when(
            data: (farms) => _buildFarmOverviewWithFarms(theme, farms),
            loading: () => _buildFarmOverviewLoading(theme),
            error: (error, stack) => _buildFarmOverviewError(theme),
          ),
        ],
      ),
    );
  }

  /// Build farm overview with farms list
  Widget _buildFarmOverviewWithFarms(ThemeData theme, List<FarmEntity> farms) {
    if (farms.isEmpty) {
      return _buildNoFarmsMessage(theme);
    }

    // Display the first farm (most recent)
    final firstFarm = farms.first;
    final farmName = firstFarm.name;
    final farmLocation = firstFarm.location;
    final farmSize = firstFarm.size;
    final cropTypes = firstFarm.cropTypes;
    final farmStatus = firstFarm.status.value;

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  farmName,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.spacing8,
                  vertical: ResponsiveUtils.spacing4,
                ),
                decoration: BoxDecoration(
                  color: _getFarmStatusColor(farmStatus, theme),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
                ),
                child: Text(
                  _getFarmStatusText(farmStatus),
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.height8),

          Row(
            children: [
              Icon(
                Icons.location_on,
                size: ResponsiveUtils.iconSize12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              SizedBox(width: ResponsiveUtils.spacing4),
              Expanded(
                child: Text(
                  farmLocation,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing16),
              Icon(
                Icons.straighten,
                size: ResponsiveUtils.iconSize12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              SizedBox(width: ResponsiveUtils.spacing4),
              Text(
                '${farmSize.toStringAsFixed(1)} hectares',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          if (cropTypes.isNotEmpty) ...[
            SizedBox(height: ResponsiveUtils.height12),
            Wrap(
              spacing: ResponsiveUtils.spacing8,
              runSpacing: ResponsiveUtils.spacing4,
              children:
                  cropTypes.take(3).map<Widget>((crop) {
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
                          fontSize: ResponsiveUtils.fontSize10,
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],

          // Show farm count if multiple farms
          if (farms.length > 1) ...[
            SizedBox(height: ResponsiveUtils.height12),
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.spacing8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: ResponsiveUtils.iconSize16,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: ResponsiveUtils.spacing8),
                  Text(
                    'You have ${farms.length} farms total',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Navigate to farms screen
  void _navigateToFarms() {
    context.go('/farmer-farms');
  }

  /// Build recent activities section
  Widget _buildRecentActivitiesSection(ThemeData theme) {
    final authState = ref.watch(authProvider);
    if (authState is! AuthAuthenticated) {
      return const SizedBox.shrink();
    }

    // Get recent activities from all farmer's farms
    final recentActivitiesAsync = ref.watch(
      farmerRecentActivitiesProvider(authState.user.id),
    );

    return _buildRecentActivitiesContainer(
      theme,
      recentActivitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return _buildNoActivitiesMessage(theme);
          }
          return Column(
            children:
                activities.take(4).map((activity) {
                  return _buildActivityItemWithFarm(theme, activity);
                }).toList(),
          );
        },
        loading: () => _buildActivitiesLoading(theme),
        error: (error, stack) => _buildActivitiesError(theme),
      ),
    );
  }

  /// Build recent activities container
  Widget _buildRecentActivitiesContainer(ThemeData theme, Widget content) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: ResponsiveUtils.spacing8,
            offset: Offset(0, ResponsiveUtils.spacing2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: theme.colorScheme.primary,
                size: ResponsiveUtils.iconSize24,
              ),
              SizedBox(width: ResponsiveUtils.spacing8),
              Text(
                'Recent Activities',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.height16),

          // Activity items content
          content,
        ],
      ),
    );
  }

  /// Build activity item with farm information
  Widget _buildActivityItemWithFarm(ThemeData theme, ActivityEntity activity) {
    final timeAgo = _getTimeAgo(activity.createdAt);
    final icon = _getActivityIcon(activity.type);
    final color = _getActivityColor(activity.type, theme);

    // Get farm name using the farmId
    final farmAsync = ref.watch(farmsListProvider(activity.farmerId));

    return farmAsync.when(
      data: (farms) {
        // Find the farm that matches the activity's farmId
        FarmEntity? farm;
        try {
          farm = farms.firstWhere((f) => f.id == activity.farmId);
        } catch (e) {
          farm = farms.isNotEmpty ? farms.first : null;
        }

        final farmName = farm?.name ?? 'Unknown Farm';

        return _buildActivityItemWithFarmName(
          theme,
          activity.title,
          farmName,
          timeAgo,
          icon,
          color,
        );
      },
      loading:
          () => _buildActivityItemWithFarmName(
            theme,
            activity.title,
            'Loading...',
            timeAgo,
            icon,
            color,
          ),
      error:
          (error, stack) => _buildActivityItemWithFarmName(
            theme,
            activity.title,
            'Unknown Farm',
            timeAgo,
            icon,
            color,
          ),
    );
  }

  /// Build no activities message
  Widget _buildNoActivitiesMessage(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      child: Column(
        children: [
          Icon(
            Icons.agriculture,
            size: ResponsiveUtils.iconSize48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: ResponsiveUtils.height8),
          Text(
            'No recent activities',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            'Start by adding your first farm activity',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Build activities loading state
  Widget _buildActivitiesLoading(ThemeData theme) {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: ResponsiveUtils.height12),
          child: Row(
            children: [
              Container(
                width: ResponsiveUtils.iconSize32,
                height: ResponsiveUtils.iconSize32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.height4),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Build activities error state
  Widget _buildActivitiesError(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: ResponsiveUtils.iconSize32,
            color: theme.colorScheme.error,
          ),
          SizedBox(height: ResponsiveUtils.height8),
          Text(
            'Failed to load activities',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  /// Build activity item with farm name
  Widget _buildActivityItemWithFarmName(
    ThemeData theme,
    String title,
    String farmName,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.height12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Icon(icon, size: ResponsiveUtils.iconSize16, color: color),
          ),

          SizedBox(width: ResponsiveUtils.spacing12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.agriculture,
                      size: ResponsiveUtils.iconSize12,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: ResponsiveUtils.spacing4),
                    Text(
                      farmName,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing8),
                    Text(
                      '• $time',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build quick actions section
  Widget _buildQuickActionsSection(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: ResponsiveUtils.spacing8,
            offset: Offset(0, ResponsiveUtils.spacing2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: theme.colorScheme.primary,
                size: ResponsiveUtils.iconSize24,
              ),
              SizedBox(width: ResponsiveUtils.spacing8),
              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.height16),

          // Action buttons grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: ResponsiveUtils.spacing12,
            mainAxisSpacing: ResponsiveUtils.spacing12,
            childAspectRatio: 2.5,
            children: [
              _buildActionButton(
                theme,
                'Add Activity',
                Icons.add_task,
                theme.colorScheme.primary,
                () => _addActivity(),
              ),
              _buildActionButton(
                theme,
                'Record Harvest',
                Icons.agriculture,
                theme.colorScheme.secondary,
                () => _recordHarvest(),
              ),
              _buildActionButton(
                theme,
                'Check Weather',
                Icons.wb_sunny,
                Colors.orange,
                () => _checkWeather(),
              ),
              _buildActionButton(
                theme,
                'Market Prices',
                Icons.trending_up,
                Colors.green,
                () => _checkMarketPrices(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build action button
  Widget _buildActionButton(
    ThemeData theme,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        child: Container(
          padding: EdgeInsets.all(ResponsiveUtils.spacing12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, size: ResponsiveUtils.iconSize20, color: color),
              SizedBox(width: ResponsiveUtils.spacing8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Add activity action
  void _addActivity() {
    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated) return;

    // For now, show a snackbar since add activity screen might not be implemented yet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add activity feature coming soon')),
    );
  }

  /// Record harvest action
  void _recordHarvest() {
    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated) return;

    // For now, show a snackbar since record harvest screen might not be implemented yet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record harvest feature coming soon')),
    );
  }

  /// Check weather action
  void _checkWeather() {
    // Navigate to detailed weather screen
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DetailedWeatherScreen()),
    );
  }

  /// Check market prices action
  void _checkMarketPrices() {
    // Scroll to market insights section
    _scrollController.animateTo(
      1000, // Approximate position of market section
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  /// Build market insights section
  Widget _buildMarketInsightsSection(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: ResponsiveUtils.spacing8,
            offset: Offset(0, ResponsiveUtils.spacing2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: theme.colorScheme.primary,
                size: ResponsiveUtils.iconSize24,
              ),
              SizedBox(width: ResponsiveUtils.spacing8),
              Text(
                'Market Insights',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _viewMarketDetails(),
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.height16),

          // Market price items
          _buildMarketItem(
            theme,
            'Maize',
            'TSh 1,200/kg',
            '+5.2%',
            Colors.green,
            Icons.trending_up,
          ),
          _buildMarketItem(
            theme,
            'Rice',
            'TSh 2,800/kg',
            '-2.1%',
            Colors.red,
            Icons.trending_down,
          ),
          _buildMarketItem(
            theme,
            'Beans',
            'TSh 3,500/kg',
            '+1.8%',
            Colors.green,
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  /// Build market item
  Widget _buildMarketItem(
    ThemeData theme,
    String crop,
    String price,
    String change,
    Color changeColor,
    IconData trendIcon,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.height12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Icon(
              Icons.eco,
              size: ResponsiveUtils.iconSize16,
              color: theme.colorScheme.primary,
            ),
          ),

          SizedBox(width: ResponsiveUtils.spacing12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  price,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              Icon(
                trendIcon,
                size: ResponsiveUtils.iconSize12,
                color: changeColor,
              ),
              SizedBox(width: ResponsiveUtils.spacing4),
              Text(
                change,
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize12,
                  fontWeight: FontWeight.w600,
                  color: changeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// View market details
  void _viewMarketDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Market details feature coming soon')),
    );
  }

  /// Build subscription status section
  Widget _buildSubscriptionStatusSection(ThemeData theme, dynamic user) {
    final currentPackage = SubscriptionPackage.fromString(
      user.subscriptionPackage ?? 'free_tier',
    );
    final daysRemaining = _calculateDaysRemaining(user);

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.secondary.withValues(alpha: 0.1),
            theme.colorScheme.primary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: theme.colorScheme.primary,
                size: ResponsiveUtils.iconSize24,
              ),
              SizedBox(width: ResponsiveUtils.spacing8),
              Text(
                'Subscription Status',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.height16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentPackage.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.fontSize20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.height4),
                    Text(
                      _getSubscriptionStatusText(user, daysRemaining),
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize12,
                        color: _getSubscriptionStatusColor(
                          theme,
                          daysRemaining,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (currentPackage.isPremium && daysRemaining == null) ...[
                      SizedBox(height: ResponsiveUtils.height4),
                      Text(
                        '\$${currentPackage.monthlyPrice.toStringAsFixed(0)}/month',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize10,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: () => _navigateToSubscription(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getUpgradeButtonColor(
                    theme,
                    currentPackage,
                    daysRemaining,
                  ),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacing16,
                    vertical: ResponsiveUtils.spacing8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                ),
                child: Text(
                  _getUpgradeButtonText(currentPackage, daysRemaining),
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.height12),
          _buildSubscriptionMessage(theme, currentPackage, daysRemaining),
        ],
      ),
    );
  }

  /// Calculate days remaining in subscription
  int? _calculateDaysRemaining(dynamic user) {
    final now = DateTime.now();

    // Check trial end date first (for free tier users)
    if (user.trialEndDate != null) {
      final trialEnd = user.trialEndDate as DateTime;
      final difference = trialEnd.difference(now).inDays;
      return difference > 0 ? difference : 0;
    }

    // Check subscription end date (for premium users)
    if (user.subscriptionEndDate != null) {
      final subscriptionEnd = user.subscriptionEndDate as DateTime;
      final difference = subscriptionEnd.difference(now).inDays;
      return difference > 0 ? difference : 0;
    }

    return null;
  }

  /// Get subscription status text
  String _getSubscriptionStatusText(dynamic user, int? daysRemaining) {
    final currentPackage = SubscriptionPackage.fromString(
      user.subscriptionPackage ?? 'free_tier',
    );

    if (daysRemaining != null) {
      if (user.trialEndDate != null) {
        // Trial period
        if (daysRemaining == 0) {
          return 'Trial expired today';
        } else if (daysRemaining == 1) {
          return '1 day remaining in trial';
        } else {
          return '$daysRemaining days remaining in trial';
        }
      } else if (user.subscriptionEndDate != null) {
        // Paid subscription
        if (daysRemaining == 0) {
          return 'Subscription expires today';
        } else if (daysRemaining == 1) {
          return '1 day remaining';
        } else {
          return '$daysRemaining days remaining';
        }
      }
    }

    // No end date (permanent subscription or free tier without trial)
    if (currentPackage.isPremium) {
      return 'Active subscription';
    } else {
      return 'Free tier';
    }
  }

  /// Get subscription status color
  Color _getSubscriptionStatusColor(ThemeData theme, int? daysRemaining) {
    if (daysRemaining != null) {
      if (daysRemaining == 0) {
        return theme.colorScheme.error;
      } else if (daysRemaining <= 3) {
        return Colors.orange;
      } else if (daysRemaining <= 7) {
        return Colors.amber;
      }
    }
    return theme.colorScheme.onSurface.withValues(alpha: 0.7);
  }

  /// Get upgrade button text
  String _getUpgradeButtonText(
    SubscriptionPackage currentPackage,
    int? daysRemaining,
  ) {
    if (currentPackage == SubscriptionPackage.freeTier) {
      if (daysRemaining != null && daysRemaining <= 3) {
        return 'Upgrade Now';
      }
      return 'Upgrade';
    } else {
      if (daysRemaining != null && daysRemaining <= 7) {
        return 'Renew';
      }
      return 'Manage';
    }
  }

  /// Get upgrade button color
  Color _getUpgradeButtonColor(
    ThemeData theme,
    SubscriptionPackage currentPackage,
    int? daysRemaining,
  ) {
    if (daysRemaining != null && daysRemaining <= 3) {
      return theme.colorScheme.error;
    } else if (daysRemaining != null && daysRemaining <= 7) {
      return Colors.orange;
    }
    return theme.colorScheme.primary;
  }

  /// Build subscription message
  Widget _buildSubscriptionMessage(
    ThemeData theme,
    SubscriptionPackage currentPackage,
    int? daysRemaining,
  ) {
    String message;
    Color? backgroundColor;
    Color? textColor;
    IconData? icon;

    if (daysRemaining != null && daysRemaining == 0) {
      // Expired
      message =
          currentPackage == SubscriptionPackage.freeTier
              ? 'Your trial has expired. Upgrade now to continue using premium features.'
              : 'Your subscription has expired. Renew now to continue using premium features.';
      backgroundColor = theme.colorScheme.error.withValues(alpha: 0.1);
      textColor = theme.colorScheme.error;
      icon = Icons.warning;
    } else if (daysRemaining != null && daysRemaining <= 3) {
      // Critical - expires soon
      message =
          currentPackage == SubscriptionPackage.freeTier
              ? 'Your trial expires in $daysRemaining ${daysRemaining == 1 ? 'day' : 'days'}. Upgrade now to avoid interruption.'
              : 'Your subscription expires in $daysRemaining ${daysRemaining == 1 ? 'day' : 'days'}. Renew now to avoid interruption.';
      backgroundColor = theme.colorScheme.error.withValues(alpha: 0.1);
      textColor = theme.colorScheme.error;
      icon = Icons.warning;
    } else if (daysRemaining != null && daysRemaining <= 7) {
      // Warning - expires soon
      message =
          currentPackage == SubscriptionPackage.freeTier
              ? 'Your trial expires in $daysRemaining days. Consider upgrading to premium.'
              : 'Your subscription expires in $daysRemaining days. Consider renewing.';
      backgroundColor = Colors.orange.withValues(alpha: 0.1);
      textColor = Colors.orange;
      icon = Icons.info;
    } else if (currentPackage == SubscriptionPackage.freeTier) {
      // Free tier promotion
      message = 'Upgrade to unlock unlimited farms and premium features';
      backgroundColor = null;
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
      icon = Icons.star;
    } else {
      // Premium active
      message = 'Enjoying premium features? Thank you for your subscription!';
      backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.1);
      textColor = theme.colorScheme.primary;
      icon = Icons.check_circle;
    }

    return Container(
      padding:
          backgroundColor != null
              ? EdgeInsets.all(ResponsiveUtils.spacing12)
              : EdgeInsets.zero,
      decoration:
          backgroundColor != null
              ? BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
              )
              : null,
      child: Row(
        children: [
          ...[
            Icon(icon, size: ResponsiveUtils.iconSize16, color: textColor),
            SizedBox(width: ResponsiveUtils.spacing8),
          ],
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: textColor,
                fontWeight:
                    backgroundColor != null
                        ? FontWeight.w500
                        : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to subscription screen
  void _navigateToSubscription() {
    context.push('/farmer-home/subscription');
  }

  /// Get appropriate icon for weather condition
  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.grain;
      case 'drizzle':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
        return Icons.cloud;
      default:
        return Icons.wb_cloudy;
    }
  }

  /// Get time ago string from DateTime
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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

  /// Get activity icon based on activity type
  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.planting:
        return Icons.grass;
      case ActivityType.watering:
        return Icons.water_drop;
      case ActivityType.fertilizing:
        return Icons.eco;
      case ActivityType.harvesting:
        return Icons.agriculture;
      case ActivityType.pestControl:
        return Icons.bug_report;
      case ActivityType.soilPreparation:
        return Icons.landscape;
      case ActivityType.weeding:
        return Icons.cleaning_services;
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

  /// Get activity color based on activity type
  Color _getActivityColor(ActivityType type, ThemeData theme) {
    switch (type) {
      case ActivityType.planting:
        return theme.colorScheme.primary;
      case ActivityType.watering:
        return Colors.blue;
      case ActivityType.fertilizing:
        return Colors.green;
      case ActivityType.harvesting:
        return Colors.orange;
      case ActivityType.pestControl:
        return Colors.red;
      case ActivityType.soilPreparation:
        return Colors.brown;
      case ActivityType.weeding:
        return theme.colorScheme.secondary;
      case ActivityType.pruning:
        return Colors.purple;
      case ActivityType.monitoring:
        return Colors.teal;
      case ActivityType.maintenance:
        return Colors.grey;
      case ActivityType.other:
        return theme.colorScheme.tertiary;
    }
  }

  /// Get farm status color
  Color _getFarmStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'active':
        return theme.colorScheme.secondary;
      case 'inactive':
        return Colors.grey;
      case 'maintenance':
        return Colors.orange;
      case 'harvesting':
        return Colors.green;
      default:
        return theme.colorScheme.secondary;
    }
  }

  /// Get farm status text
  String _getFarmStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'maintenance':
        return 'Maintenance';
      case 'harvesting':
        return 'Harvesting';
      default:
        return 'Active';
    }
  }

  /// Build farm overview loading state
  Widget _buildFarmOverviewLoading(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farm name loading
          Container(
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: ResponsiveUtils.height8),
          // Location and size loading
          Row(
            children: [
              Container(
                height: 12,
                width: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing16),
              Container(
                height: 12,
                width: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build farm overview error state
  Widget _buildFarmOverviewError(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: ResponsiveUtils.iconSize32,
            color: theme.colorScheme.error,
          ),
          SizedBox(height: ResponsiveUtils.height8),
          Text(
            'Failed to load farm data',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  /// Build no farms message
  Widget _buildNoFarmsMessage(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.agriculture,
            size: ResponsiveUtils.iconSize48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: ResponsiveUtils.height8),
          Text(
            'No farms yet',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: ResponsiveUtils.height4),
          Text(
            'Create your first farm to get started',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

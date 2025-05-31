import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';
import '../../../subscription/domain/entities/subscription.dart';

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
    // TODO: Implement refresh logic
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Show notifications
  void _showNotifications() {
    // TODO: Navigate to notifications screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications feature coming soon')),
    );
  }

  /// Build quick stats section
  Widget _buildQuickStatsSection(ThemeData theme, dynamic user) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            'Total Farms',
            '1', // TODO: Get from actual data
            Icons.agriculture,
            theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing12),
        Expanded(
          child: _buildStatCard(
            theme,
            'Active Crops',
            '3', // TODO: Get from actual data
            Icons.eco,
            theme.colorScheme.secondary,
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing12),
        Expanded(
          child: _buildStatCard(
            theme,
            'This Month',
            '\$2,450', // TODO: Get from actual data
            Icons.trending_up,
            Colors.green,
          ),
        ),
      ],
    );
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
      child: Column(
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
                'Weather Today',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                'Dar es Salaam', // TODO: Get from user location
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
                    '28°C', // TODO: Get from weather API
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.fontSize32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Partly Cloudy', // TODO: Get from weather API
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
                  _buildWeatherDetail('Humidity', '65%', Icons.water_drop),
                  SizedBox(height: ResponsiveUtils.height4),
                  _buildWeatherDetail('Wind', '12 km/h', Icons.air),
                  SizedBox(height: ResponsiveUtils.height4),
                  _buildWeatherDetail('Rain', '20%', Icons.umbrella),
                ],
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.height16),

          // Weather forecast
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildForecastItem('Today', '28°/22°', Icons.wb_sunny),
              _buildForecastItem('Tomorrow', '30°/24°', Icons.cloud),
              _buildForecastItem('Wed', '26°/20°', Icons.grain),
              _buildForecastItem('Thu', '29°/23°', Icons.wb_sunny),
            ],
          ),
        ],
      ),
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

          // Farm card
          Container(
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
                        user.farmName ?? 'My Farm',
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
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.radius8,
                        ),
                      ),
                      child: Text(
                        'Active',
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
                    Text(
                      user.farmLocation ?? 'Location not set',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
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
                      user.farmSize != null
                          ? '${user.farmSize!.toStringAsFixed(1)} hectares'
                          : 'Size not set',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),

                if (user.cropTypes != null && user.cropTypes!.isNotEmpty) ...[
                  SizedBox(height: ResponsiveUtils.height12),
                  Wrap(
                    spacing: ResponsiveUtils.spacing8,
                    runSpacing: ResponsiveUtils.spacing4,
                    children:
                        user.cropTypes!.take(3).map<Widget>((crop) {
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to farms screen
  void _navigateToFarms() {
    // TODO: Navigate to farms screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Farms screen coming soon')));
  }

  /// Build recent activities section
  Widget _buildRecentActivitiesSection(ThemeData theme) {
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

          // Activity items
          _buildActivityItem(
            theme,
            'Watered tomato crops',
            '2 hours ago',
            Icons.water_drop,
            theme.colorScheme.secondary,
          ),
          _buildActivityItem(
            theme,
            'Applied fertilizer to maize',
            '1 day ago',
            Icons.eco,
            Colors.green,
          ),
          _buildActivityItem(
            theme,
            'Harvested 50kg of beans',
            '3 days ago',
            Icons.agriculture,
            Colors.orange,
          ),
          _buildActivityItem(
            theme,
            'Planted new seedlings',
            '1 week ago',
            Icons.grass,
            theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  /// Build activity item
  Widget _buildActivityItem(
    ThemeData theme,
    String title,
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
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add activity feature coming soon')),
    );
  }

  /// Record harvest action
  void _recordHarvest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record harvest feature coming soon')),
    );
  }

  /// Check weather action
  void _checkWeather() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Weather details feature coming soon')),
    );
  }

  /// Check market prices action
  void _checkMarketPrices() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Market prices feature coming soon')),
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
    final isTrialActive =
        user.subscriptionStatus == 'trial' ||
        (currentPackage == SubscriptionPackage.freeTier &&
            daysRemaining != null);

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
                    if (isTrialActive && daysRemaining != null) ...[
                      Text(
                        '$daysRemaining days remaining in trial',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize12,
                          color:
                              daysRemaining <= 3
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else if (currentPackage.isPremium) ...[
                      Text(
                        '\$${currentPackage.monthlyPrice.toStringAsFixed(0)}/month',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize12,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
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
                  backgroundColor: theme.colorScheme.primary,
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
                  currentPackage == SubscriptionPackage.freeTier
                      ? 'Upgrade'
                      : 'Manage',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          if (currentPackage == SubscriptionPackage.freeTier) ...[
            SizedBox(height: ResponsiveUtils.height12),
            Text(
              'Upgrade to unlock unlimited farms and premium features',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Calculate days remaining in subscription
  int? _calculateDaysRemaining(dynamic user) {
    if (user.trialEndDate != null) {
      final now = DateTime.now();
      final trialEnd = user.trialEndDate as DateTime;
      final difference = trialEnd.difference(now).inDays;
      return difference > 0 ? difference : 0;
    }
    return null;
  }

  /// Navigate to subscription screen
  void _navigateToSubscription() {
    // TODO: Navigate to subscription screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subscription management coming soon')),
    );
  }
}

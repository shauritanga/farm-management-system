import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../auth/presentation/providers/mobile_auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';
import '../../../auth/domain/entities/user.dart';
import '../../profile/data/repositories/cooperative_settings_repository_impl.dart';
import '../providers/dashboard_metrics_provider.dart';
import '../providers/sales_trend_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/recent_sales_provider.dart';
import '../providers/recent_activities_provider.dart';
import '../providers/performance_insights_provider.dart';
import 'package:fl_chart/fl_chart.dart';

/// Professional cooperative dashboard screen
class CooperativeDashboardScreen extends ConsumerStatefulWidget {
  const CooperativeDashboardScreen({super.key});

  @override
  ConsumerState<CooperativeDashboardScreen> createState() =>
      _CooperativeDashboardScreenState();
}

class _CooperativeDashboardScreenState
    extends ConsumerState<CooperativeDashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(mobileAuthProvider);

    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Please log in to access the dashboard')),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh will be handled by Riverpod providers automatically
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // Professional top header section
              _buildTopHeader(theme, authState.user),

              // Main content with padding
              Padding(
                padding: EdgeInsets.all(ResponsiveUtils.spacing16),
                child: Column(
                  children: [
                    // Add spacing between header and content
                    SizedBox(height: ResponsiveUtils.height24),

                    // Key metrics overview
                    _buildKeyMetrics(theme),
                    SizedBox(height: ResponsiveUtils.height24),

                    // Sales & Commission Trend
                    _buildSalesTrend(theme),
                    SizedBox(height: ResponsiveUtils.height24),

                    // Cooperative earnings
                    _buildCooperativeEarnings(theme),
                    SizedBox(height: ResponsiveUtils.height24),

                    // Sales overview
                    _buildSalesOverview(theme),
                    SizedBox(height: ResponsiveUtils.height24),

                    // Recent activities
                    _buildRecentActivities(theme),
                    SizedBox(height: ResponsiveUtils.height24),

                    // Performance insights
                    _buildPerformanceInsights(theme),
                    SizedBox(
                      height: ResponsiveUtils.height100,
                    ), // Bottom padding
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build professional top header section with app brand colors
  Widget _buildTopHeader(ThemeData theme, UserEntity user) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF008000), // Deep green
            const Color(0xFF4A7043), // Olive green
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF008000).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.spacing20),
          child: Column(
            children: [
              // Top row with cooperative name and notifications
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCooperativeName(user),
                        SizedBox(height: ResponsiveUtils.height4),
                        Text(
                          _getGreeting(),
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize14,
                            color: const Color(0xFFF8F9F2), // Soft white
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Notifications bell
                  Container(
                    margin: EdgeInsets.only(left: ResponsiveUtils.spacing12),
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.radius12,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF008000,
                                ).withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: ResponsiveUtils.iconSize24,
                          ),
                        ),
                        // Notification badge with real data
                        Consumer(
                          builder: (context, ref, child) {
                            final authState = ref.watch(mobileAuthProvider);
                            if (authState is! AuthAuthenticated ||
                                authState.user.cooperativeId == null) {
                              return const SizedBox.shrink();
                            }

                            final notificationCountAsync = ref.watch(
                              notificationCountProvider(
                                authState.user.cooperativeId!,
                              ),
                            );

                            return notificationCountAsync.when(
                              data: (count) {
                                if (count == 0) return const SizedBox.shrink();

                                return Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFFDE21,
                                      ), // Bright yellow
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        count > 9 ? '9+' : '$count',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(
                                            0xFF4A4A4A,
                                          ), // Slate gray
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveUtils.height20),

              // User profile section
              GestureDetector(
                onTap: () => _navigateToProfile(context),
                child: Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius16,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF008000).withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // User avatar
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF66B032), // Lime green
                              Color(0xFF4A7043), // Olive green
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.radius16,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF66B032,
                              ).withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : 'U',
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtils.fontSize24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: ResponsiveUtils.spacing16),

                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name.isNotEmpty ? user.name : 'User',
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveUtils.fontSize18,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: ResponsiveUtils.height4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtils.spacing8,
                                vertical: ResponsiveUtils.spacing4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF66B032,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  ResponsiveUtils.radius8,
                                ),
                              ),
                              child: Text(
                                user.role ?? 'Manager', // Default role
                                style: GoogleFonts.inter(
                                  fontSize: ResponsiveUtils.fontSize12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4A7043), // Olive green
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Profile action button
                      Container(
                        padding: EdgeInsets.all(ResponsiveUtils.spacing8),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF66B032,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.radius8,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: const Color(0xFF4A7043), // Olive green
                          size: ResponsiveUtils.iconSize16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to profile screen and update bottom navigation
  void _navigateToProfile(BuildContext context) {
    // Navigate to profile tab (index 4 in cooperative navigation)
    context.go('/cooperative-profile');
  }

  /// Build cooperative name widget with settings integration
  Widget _buildCooperativeName(UserEntity user) {
    // If no cooperative ID, show fallback
    if (user.cooperativeId == null || user.cooperativeId!.isEmpty) {
      return Text(
        'Agricultural Cooperative',
        style: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.fontSize20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Watch cooperative settings for real-time name updates
    final settingsAsync = ref.watch(
      cooperativeSettingsStreamProvider(user.cooperativeId!),
    );

    return settingsAsync.when(
      data: (settings) {
        String cooperativeName;

        if (settings?.basicInfo.name != null &&
            settings!.basicInfo.name.isNotEmpty) {
          // Use name from cooperative settings
          cooperativeName = settings.basicInfo.name;
        } else if (user.cooperativeName != null &&
            user.cooperativeName!.isNotEmpty) {
          // Fallback to user entity cooperative name
          cooperativeName = user.cooperativeName!;
        } else {
          // Use formatted cooperative ID as fallback
          cooperativeName = 'Cooperative ${user.cooperativeId!.toUpperCase()}';
        }

        return Text(
          cooperativeName,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
      loading:
          () => Text(
            user.cooperativeName ?? 'Loading...',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      error:
          (error, stack) => Text(
            user.cooperativeName ?? 'Agricultural Cooperative',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
    );
  }

  /// Get time-based greeting
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning! Ready to manage your cooperative?';
    } else if (hour < 17) {
      return 'Good Afternoon! How\'s your cooperative doing?';
    } else {
      return 'Good Evening! Time to review today\'s progress.';
    }
  }

  /// Build key metrics overview with real data
  Widget _buildKeyMetrics(ThemeData theme) {
    final authState = ref.watch(mobileAuthProvider);

    if (authState is! AuthAuthenticated ||
        authState.user.cooperativeId == null ||
        authState.user.cooperativeId!.isEmpty) {
      return _buildDefaultMetrics(theme);
    }

    final metricsAsync = ref.watch(
      dashboardMetricsProvider(authState.user.cooperativeId!),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height12),

        metricsAsync.when(
          data:
              (metrics) => GridView.count(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: ResponsiveUtils.spacing12,
                mainAxisSpacing: ResponsiveUtils.spacing12,
                children: [
                  _buildMetricCard(
                    theme,
                    'Total Farmers',
                    '${metrics.totalFarmers}',
                    Icons.groups,
                    Colors.blue,
                    'Registered farmers',
                  ),
                  _buildMetricCard(
                    theme,
                    'Sales Count',
                    '${metrics.totalSalesCount}',
                    Icons.receipt_long,
                    Colors.green,
                    'Total transactions',
                  ),
                  _buildMetricCard(
                    theme,
                    'Sales Amount',
                    _formatCurrency(metrics.totalSalesAmount),
                    Icons.trending_up,
                    Colors.orange,
                    'Total revenue',
                  ),
                  _buildMetricCard(
                    theme,
                    'Total Acres',
                    metrics.totalAcres.toStringAsFixed(1),
                    Icons.landscape,
                    Colors.purple,
                    'Farming area',
                  ),
                ],
              ),
          loading: () => _buildLoadingMetrics(theme),
          error: (error, stack) => _buildErrorMetrics(theme, error.toString()),
        ),
      ],
    );
  }

  /// Build metric card with beautiful design inspired by the image
  Widget _buildMetricCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: ResponsiveUtils.iconSize20,
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.height16),

          // Main value
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize24,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: ResponsiveUtils.height4),

          // Growth indicator
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.spacing6,
                  vertical: ResponsiveUtils.spacing2,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: Colors.green, size: 12),
                    SizedBox(width: 2),
                    Text(
                      '+15%',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.height8),

          // Update timestamp
          Text(
            'Update: ${_getCurrentDate()}',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Get current date formatted
  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
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
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  /// Build cooperative earnings section with real data
  Widget _buildCooperativeEarnings(ThemeData theme) {
    final authState = ref.watch(mobileAuthProvider);

    if (authState is! AuthAuthenticated ||
        authState.user.cooperativeId == null ||
        authState.user.cooperativeId!.isEmpty) {
      return _buildEmptyEarnings(theme);
    }

    final metricsAsync = ref.watch(
      dashboardMetricsProvider(authState.user.cooperativeId!),
    );

    final settingsAsync = ref.watch(
      cooperativeSettingsStreamProvider(authState.user.cooperativeId!),
    );

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.primary.withValues(alpha: 0.05),
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
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: theme.colorScheme.primary,
                  size: ResponsiveUtils.iconSize20,
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cooperative Earnings',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.fontSize18,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Commission from farmer sales',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize12,
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

          SizedBox(height: ResponsiveUtils.height20),

          // Real earnings metrics grid
          metricsAsync.when(
            data:
                (metrics) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildEarningsCard(
                            theme,
                            'Total Commission',
                            _formatCurrency(metrics.totalCommissionAmount),
                            'All time',
                            Icons.monetization_on,
                            Colors.green,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.spacing12),
                        Expanded(
                          child: settingsAsync.when(
                            data:
                                (settings) => _buildEarningsCard(
                                  theme,
                                  'Commission Rate',
                                  '${settings?.businessSettings.commissionRate ?? 5.0}%',
                                  'Per sale',
                                  Icons.percent,
                                  Colors.blue,
                                ),
                            loading:
                                () => _buildEarningsCard(
                                  theme,
                                  'Commission Rate',
                                  '...',
                                  'Loading',
                                  Icons.percent,
                                  Colors.blue,
                                ),
                            error:
                                (_, __) => _buildEarningsCard(
                                  theme,
                                  'Commission Rate',
                                  '5%',
                                  'Default',
                                  Icons.percent,
                                  Colors.blue,
                                ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: ResponsiveUtils.height12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildEarningsCard(
                            theme,
                            'Sales Volume',
                            _formatCurrency(metrics.totalSalesAmount),
                            'Total farmer sales',
                            Icons.trending_up,
                            Colors.orange,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.spacing12),
                        Expanded(
                          child: _buildEarningsCard(
                            theme,
                            'Net Profit',
                            _formatCurrency(
                              metrics.totalCommissionAmount * 0.75,
                            ), // Assuming 75% net after expenses
                            'After expenses',
                            Icons.account_balance,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            loading:
                () => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildEarningsCard(
                            theme,
                            'Total Commission',
                            '...',
                            'Loading',
                            Icons.monetization_on,
                            Colors.green,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.spacing12),
                        Expanded(
                          child: _buildEarningsCard(
                            theme,
                            'Commission Rate',
                            '...',
                            'Loading',
                            Icons.percent,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.height12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildEarningsCard(
                            theme,
                            'Sales Volume',
                            '...',
                            'Loading',
                            Icons.trending_up,
                            Colors.orange,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.spacing12),
                        Expanded(
                          child: _buildEarningsCard(
                            theme,
                            'Net Profit',
                            '...',
                            'Loading',
                            Icons.account_balance,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            error:
                (error, stack) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildEarningsCard(
                            theme,
                            'Total Commission',
                            'Error',
                            'Failed to load',
                            Icons.error_outline,
                            Colors.red,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.spacing12),
                        Expanded(
                          child: _buildEarningsCard(
                            theme,
                            'Commission Rate',
                            'Error',
                            'Failed to load',
                            Icons.error_outline,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.height12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildEarningsCard(
                            theme,
                            'Sales Volume',
                            'Error',
                            'Failed to load',
                            Icons.error_outline,
                            Colors.red,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.spacing12),
                        Expanded(
                          child: _buildEarningsCard(
                            theme,
                            'Net Profit',
                            'Error',
                            'Failed to load',
                            Icons.error_outline,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          ),

          SizedBox(height: ResponsiveUtils.height16),

          // Commission breakdown with settings data
          _buildCommissionBreakdown(theme),
        ],
      ),
    );
  }

  /// Build empty earnings fallback
  Widget _buildEmptyEarnings(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.primary.withValues(alpha: 0.05),
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
          Text(
            'Cooperative Earnings',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height24),
          Center(
            child: Text(
              'No cooperative data available',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build earnings card
  Widget _buildEarningsCard(
    ThemeData theme,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius6),
            ),
            child: Icon(icon, color: color, size: ResponsiveUtils.iconSize16),
          ),

          SizedBox(height: ResponsiveUtils.height8),

          // Value
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: ResponsiveUtils.height4),

          // Title
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize11,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Subtitle
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize10,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build sales overview section
  Widget _buildSalesOverview(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Sales',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Refresh recent sales
                      final authState = ref.read(mobileAuthProvider);
                      if (authState is AuthAuthenticated &&
                          authState.user.cooperativeId != null) {
                        ref.invalidate(
                          recentSalesProvider(authState.user.cooperativeId!),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.refresh,
                      size: ResponsiveUtils.iconSize20,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: 'Refresh Sales',
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to sales screen
                    },
                    child: Text(
                      'View All',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.height12),

          // Real sales data
          _buildRecentSalesData(theme),
        ],
      ),
    );
  }

  /// Build recent sales data widget
  Widget _buildRecentSalesData(ThemeData theme) {
    final authState = ref.watch(mobileAuthProvider);

    if (authState is! AuthAuthenticated ||
        authState.user.cooperativeId == null ||
        authState.user.cooperativeId!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.spacing24),
          child: Text(
            'No cooperative data available',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    final recentSalesAsync = ref.watch(
      recentSalesProvider(authState.user.cooperativeId!),
    );

    return recentSalesAsync.when(
      data: (sales) {
        if (sales.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing24),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: ResponsiveUtils.iconSize48,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  SizedBox(height: ResponsiveUtils.height12),
                  Text(
                    'No recent sales',
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

        return Column(
          children:
              sales
                  .map(
                    (sale) => Padding(
                      padding: EdgeInsets.only(
                        bottom: ResponsiveUtils.spacing8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(ResponsiveUtils.spacing8),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.radius8,
                              ),
                            ),
                            child: Icon(
                              Icons.shopping_cart,
                              size: ResponsiveUtils.iconSize16,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.spacing12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sale.productName,
                                  style: GoogleFonts.inter(
                                    fontSize: ResponsiveUtils.fontSize14,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  'by ${sale.farmerName} • ${sale.weight.toStringAsFixed(1)}kg',
                                  style: GoogleFonts.inter(
                                    fontSize: ResponsiveUtils.fontSize12,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatCurrency(sale.amount),
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtils.fontSize14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        );
      },
      loading:
          () => Center(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing24),
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      error:
          (error, stack) => Center(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing24),
              child: Text(
                'Failed to load recent sales',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
    );
  }

  /// Build recent activities section with real data
  Widget _buildRecentActivities(ThemeData theme) {
    final authState = ref.watch(mobileAuthProvider);

    if (authState is! AuthAuthenticated ||
        authState.user.cooperativeId == null ||
        authState.user.cooperativeId!.isEmpty) {
      return _buildEmptyActivities(theme);
    }

    final activitiesAsync = ref.watch(
      recentActivitiesProvider(authState.user.cooperativeId!),
    );

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activities',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height12),

          // Real activity data
          activitiesAsync.when(
            data: (activities) {
              if (activities.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveUtils.spacing24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: ResponsiveUtils.iconSize48,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.height12),
                        Text(
                          'No recent activities',
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize14,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children:
                    activities
                        .map(
                          (activity) => Padding(
                            padding: EdgeInsets.only(
                              bottom: ResponsiveUtils.spacing12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(
                                    ResponsiveUtils.spacing8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getActivityColor(
                                      activity.type,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveUtils.radius8,
                                    ),
                                  ),
                                  child: Icon(
                                    _getActivityIcon(activity.icon),
                                    size: ResponsiveUtils.iconSize16,
                                    color: _getActivityColor(activity.type),
                                  ),
                                ),
                                SizedBox(width: ResponsiveUtils.spacing12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activity.description,
                                        style: GoogleFonts.inter(
                                          fontSize: ResponsiveUtils.fontSize14,
                                          fontWeight: FontWeight.w500,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        'by ${activity.actorName} • ${_formatTimeAgo(activity.timestamp)}',
                                        style: GoogleFonts.inter(
                                          fontSize: ResponsiveUtils.fontSize12,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              );
            },
            loading:
                () => Center(
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveUtils.spacing24),
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            error:
                (error, stack) => Center(
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveUtils.spacing24),
                    child: Text(
                      'Failed to load activities',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize14,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  /// Build empty activities fallback
  Widget _buildEmptyActivities(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activities',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height24),
          Center(
            child: Text(
              'No cooperative data available',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get activity icon based on type
  IconData _getActivityIcon(String iconType) {
    switch (iconType) {
      case 'sale':
        return Icons.shopping_cart;
      case 'farmer':
        return Icons.person_add;
      case 'edit':
        return Icons.edit;
      case 'payment':
        return Icons.payment;
      case 'report':
        return Icons.analytics;
      default:
        return Icons.info;
    }
  }

  /// Get activity color based on type
  Color _getActivityColor(String type) {
    switch (type) {
      case 'sale':
        return Colors.green;
      case 'farmer_registration':
        return Colors.blue;
      case 'farmer_update':
        return Colors.teal;
      case 'payment':
        return Colors.orange;
      case 'report':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Build performance insights section with real data
  Widget _buildPerformanceInsights(ThemeData theme) {
    final authState = ref.watch(mobileAuthProvider);

    if (authState is! AuthAuthenticated ||
        authState.user.cooperativeId == null ||
        authState.user.cooperativeId!.isEmpty) {
      return _buildEmptyPerformanceInsights(theme);
    }

    final insightsAsync = ref.watch(
      performanceInsightsProvider(authState.user.cooperativeId!),
    );

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Insights',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height16),

          // Real performance metrics
          insightsAsync.when(
            data:
                (insights) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInsightCard(
                            theme,
                            'Growth Rate',
                            '${insights.growthRate >= 0 ? '+' : ''}${insights.growthRate.toStringAsFixed(1)}%',
                            'vs last month',
                            insights.growthRate >= 0
                                ? Colors.green
                                : Colors.red,
                            insights.growthRate >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.spacing12),
                        Expanded(
                          child: _buildInsightCard(
                            theme,
                            'Efficiency',
                            '${insights.efficiency.toStringAsFixed(0)}%',
                            'operational',
                            insights.efficiency >= 80
                                ? Colors.blue
                                : Colors.orange,
                            Icons.speed,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.height12),

                    // Real recommendations
                    Container(
                      padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.radius8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: theme.colorScheme.primary,
                            size: ResponsiveUtils.iconSize20,
                          ),
                          SizedBox(width: ResponsiveUtils.spacing8),
                          Expanded(
                            child: Text(
                              insights.recommendation,
                              style: GoogleFonts.inter(
                                fontSize: ResponsiveUtils.fontSize13,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Additional insights
                    if (insights.totalSalesThisMonth > 0 ||
                        insights.totalSalesLastMonth > 0)
                      Padding(
                        padding: EdgeInsets.only(top: ResponsiveUtils.spacing8),
                        child: Container(
                          padding: EdgeInsets.all(ResponsiveUtils.spacing8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.radius6,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '${insights.totalSalesThisMonth}',
                                    style: GoogleFonts.poppins(
                                      fontSize: ResponsiveUtils.fontSize16,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    'This Month',
                                    style: GoogleFonts.inter(
                                      fontSize: ResponsiveUtils.fontSize11,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${insights.totalSalesLastMonth}',
                                    style: GoogleFonts.poppins(
                                      fontSize: ResponsiveUtils.fontSize16,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  Text(
                                    'Last Month',
                                    style: GoogleFonts.inter(
                                      fontSize: ResponsiveUtils.fontSize11,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                              if (insights.avgSaleAmount > 0)
                                Column(
                                  children: [
                                    Text(
                                      _formatCurrency(insights.avgSaleAmount),
                                      style: GoogleFonts.poppins(
                                        fontSize: ResponsiveUtils.fontSize14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      'Avg Sale',
                                      style: GoogleFonts.inter(
                                        fontSize: ResponsiveUtils.fontSize11,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
            loading:
                () => Center(
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveUtils.spacing24),
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            error:
                (error, stack) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInsightCard(
                            theme,
                            'Growth Rate',
                            'N/A',
                            'data unavailable',
                            Colors.grey,
                            Icons.error_outline,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.spacing12),
                        Expanded(
                          child: _buildInsightCard(
                            theme,
                            'Efficiency',
                            'N/A',
                            'data unavailable',
                            Colors.grey,
                            Icons.error_outline,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.height12),
                    Container(
                      padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.radius8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                            size: ResponsiveUtils.iconSize20,
                          ),
                          SizedBox(width: ResponsiveUtils.spacing8),
                          Expanded(
                            child: Text(
                              'Unable to calculate performance insights. Please check your data.',
                              style: GoogleFonts.inter(
                                fontSize: ResponsiveUtils.fontSize13,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  /// Build empty performance insights fallback
  Widget _buildEmptyPerformanceInsights(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Insights',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height24),
          Center(
            child: Text(
              'No cooperative data available',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build insight card
  Widget _buildInsightCard(
    ThemeData theme,
    String title,
    String value,
    String subtitle,
    Color color,
    IconData icon,
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
          Row(
            children: [
              Icon(icon, color: color, size: ResponsiveUtils.iconSize16),
              SizedBox(width: ResponsiveUtils.spacing4),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.height4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Build commission breakdown with settings data
  Widget _buildCommissionBreakdown(ThemeData theme) {
    final authState = ref.watch(mobileAuthProvider);

    if (authState is! AuthAuthenticated ||
        authState.user.cooperativeId == null ||
        authState.user.cooperativeId!.isEmpty) {
      return Container(
        padding: EdgeInsets.all(ResponsiveUtils.spacing12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.primary,
              size: ResponsiveUtils.iconSize16,
            ),
            SizedBox(width: ResponsiveUtils.spacing8),
            Expanded(
              child: Text(
                'Commission: 5% on all sales • Operating costs: 25% • Net margin: 75%',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final settingsAsync = ref.watch(
      cooperativeSettingsStreamProvider(authState.user.cooperativeId!),
    );

    return settingsAsync.when(
      data: (settings) {
        final commissionRate = settings?.businessSettings.commissionRate ?? 5.0;
        final currency = settings?.businessSettings.currency ?? 'TSh';

        return Container(
          padding: EdgeInsets.all(ResponsiveUtils.spacing12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: ResponsiveUtils.iconSize16,
              ),
              SizedBox(width: ResponsiveUtils.spacing8),
              Expanded(
                child: Text(
                  'Commission: $commissionRate% on all sales • Currency: $currency • Operating costs: 25% • Net margin: 75%',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading:
          () => Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: ResponsiveUtils.iconSize16,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Expanded(
                  child: Text(
                    'Loading commission details...',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
      error:
          (error, stack) => Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: ResponsiveUtils.iconSize16,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Expanded(
                  child: Text(
                    'Commission: 5% on all sales • Operating costs: 25% • Net margin: 75%',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  /// Build default metrics when no cooperative data
  Widget _buildDefaultMetrics(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height12),
        GridView.count(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: ResponsiveUtils.spacing12,
          mainAxisSpacing: ResponsiveUtils.spacing12,
          children: [
            _buildMetricCard(
              theme,
              'Total Farmers',
              '0',
              Icons.groups,
              Colors.blue,
              'No data',
            ),
            _buildMetricCard(
              theme,
              'Sales Count',
              '0',
              Icons.receipt_long,
              Colors.green,
              'No data',
            ),
            _buildMetricCard(
              theme,
              'Sales Amount',
              'TSh 0',
              Icons.trending_up,
              Colors.orange,
              'No data',
            ),
            _buildMetricCard(
              theme,
              'Total Acres',
              '0.0',
              Icons.landscape,
              Colors.purple,
              'No data',
            ),
          ],
        ),
      ],
    );
  }

  /// Build loading state for metrics
  Widget _buildLoadingMetrics(ThemeData theme) {
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.0,
      crossAxisSpacing: ResponsiveUtils.spacing12,
      mainAxisSpacing: ResponsiveUtils.spacing12,
      children: [
        _buildMetricCard(
          theme,
          'Total Farmers',
          '...',
          Icons.groups,
          Colors.blue,
          'Loading...',
        ),
        _buildMetricCard(
          theme,
          'Sales Count',
          '...',
          Icons.receipt_long,
          Colors.green,
          'Loading...',
        ),
        _buildMetricCard(
          theme,
          'Sales Amount',
          '...',
          Icons.trending_up,
          Colors.orange,
          'Loading...',
        ),
        _buildMetricCard(
          theme,
          'Total Acres',
          '...',
          Icons.landscape,
          Colors.purple,
          'Loading...',
        ),
      ],
    );
  }

  /// Build error state for metrics
  Widget _buildErrorMetrics(ThemeData theme, String error) {
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.0,
      crossAxisSpacing: ResponsiveUtils.spacing12,
      mainAxisSpacing: ResponsiveUtils.spacing12,
      children: [
        _buildMetricCard(
          theme,
          'Total Farmers',
          'Error',
          Icons.groups,
          Colors.red,
          'Failed to load',
        ),
        _buildMetricCard(
          theme,
          'Sales Count',
          'Error',
          Icons.receipt_long,
          Colors.red,
          'Failed to load',
        ),
        _buildMetricCard(
          theme,
          'Sales Amount',
          'Error',
          Icons.trending_up,
          Colors.red,
          'Failed to load',
        ),
        _buildMetricCard(
          theme,
          'Total Acres',
          'Error',
          Icons.landscape,
          Colors.red,
          'Failed to load',
        ),
      ],
    );
  }

  /// Format currency amount
  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'TSh ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'TSh ${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return 'TSh ${amount.toStringAsFixed(0)}';
    }
  }

  /// Format time ago from date
  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Build sales & commission trend section
  Widget _buildSalesTrend(ThemeData theme) {
    final authState = ref.watch(mobileAuthProvider);

    if (authState is! AuthAuthenticated ||
        authState.user.cooperativeId == null ||
        authState.user.cooperativeId!.isEmpty) {
      return _buildEmptyTrendSection(theme);
    }

    final cooperativeId = authState.user.cooperativeId!;
    print('DEBUG: Dashboard using cooperative ID: $cooperativeId');
    print('DEBUG: User data: ${authState.user}');

    final trendAsync = ref.watch(salesTrendProvider(cooperativeId));

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ResponsiveUtils.spacing8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.radius8,
                        ),
                      ),
                      child: Icon(
                        Icons.trending_up,
                        color: theme.colorScheme.primary,
                        size: ResponsiveUtils.iconSize20,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sales & Commission Trend',
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtils.fontSize16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Last 6 months performance',
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveUtils.fontSize11,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.spacing8,
                  vertical: ResponsiveUtils.spacing4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
                ),
                child: Text(
                  '6M',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing20),

          // Chart content
          trendAsync.when(
            data: (trendData) => _buildTrendChart(theme, trendData),
            loading: () => _buildTrendLoading(theme),
            error: (error, stack) => _buildTrendError(theme, error.toString()),
          ),
        ],
      ),
    );
  }

  /// Build empty trend section
  Widget _buildEmptyTrendSection(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.trending_up,
            size: ResponsiveUtils.iconSize40,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          SizedBox(height: ResponsiveUtils.spacing8),
          Text(
            'Sales & Commission Trend',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            'No data available',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Build trend chart with data
  Widget _buildTrendChart(ThemeData theme, List<SalesTrendData> trendData) {
    if (trendData.isEmpty) {
      return _buildEmptyChart(theme);
    }

    return Column(
      children: [
        // Legend
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacing16,
            vertical: ResponsiveUtils.spacing8,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLegendItem(
                theme,
                'Sales Amount',
                theme.colorScheme.primary,
              ),
              SizedBox(width: ResponsiveUtils.spacing20),
              _buildLegendItem(
                theme,
                'Commission',
                theme.colorScheme.secondary,
              ),
            ],
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing16),

        // Chart - Horizontally scrollable
        SizedBox(
          height: 300, // Maximum height to ensure 120M label is fully visible
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width:
                  (MediaQuery.of(context).size.width - 64) >
                          (trendData.length * 80.0 + 120)
                      ? MediaQuery.of(context).size.width -
                          64 // Minimum width (card padding)
                      : trendData.length * 80.0 +
                          120, // Dynamic width: 80px per month + 120px for Y-axis labels
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getChartInterval(trendData),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outline.withValues(
                          alpha: 0.15,
                        ),
                        strokeWidth: 0.8,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();

                          if (index >= 0 && index < trendData.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                trendData[index].month,
                                style: GoogleFonts.inter(
                                  fontSize: ResponsiveUtils.fontSize10,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _getChartInterval(trendData),
                        reservedSize: 75, // Reduced space for tighter layout
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value == 130000000) {
                            return const SizedBox.shrink(); // Skip 14M label
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Container(
                              width: 65, // Reduced width for tighter spacing
                              padding: EdgeInsets.only(
                                right: ResponsiveUtils.spacing4,
                              ),
                              child: Text(
                                _formatChartValue(value),
                                style: GoogleFonts.inter(
                                  fontSize:
                                      ResponsiveUtils
                                          .fontSize11, // Slightly smaller
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      left: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  maxY:
                      130000000, // Extended to 140M to provide space above 120M label
                  barGroups:
                      trendData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            // Sales amount bar
                            BarChartRodData(
                              toY: data.salesAmount,
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withValues(
                                    alpha: 0.8,
                                  ),
                                  theme.colorScheme.primary,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              width: 14, // Slightly narrower bars
                              borderRadius: BorderRadius.circular(4),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 120000000, // Fixed background at 120M
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                            // Commission bar
                            BarChartRodData(
                              toY: data.commissionAmount,
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.secondary.withValues(
                                    alpha: 0.8,
                                  ),
                                  theme.colorScheme.secondary,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              width: 14, // Slightly narrower bars
                              borderRadius: BorderRadius.circular(4),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 120000000, // Fixed background at 120M
                                color: theme.colorScheme.secondary.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                          ],
                          barsSpace:
                              2, // Reduced space between sales and commission bars
                        );
                      }).toList(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor:
                          (group) => theme.colorScheme.inverseSurface,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (groupIndex >= 0 && groupIndex < trendData.length) {
                          // final data = trendData[groupIndex];
                          // final isCommission = rodIndex == 1;
                          return BarTooltipItem(
                            _formatCurrency(rod.toY),
                            GoogleFonts.inter(
                              color: theme.colorScheme.onInverseSurface,
                              fontSize: ResponsiveUtils.fontSize12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build empty chart placeholder
  Widget _buildEmptyChart(ThemeData theme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: ResponsiveUtils.iconSize40,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            SizedBox(height: ResponsiveUtils.spacing8),
            Text(
              'No sales data yet',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing4),
            Text(
              'Sales trends will appear here',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build legend item
  Widget _buildLegendItem(ThemeData theme, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.8), color],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize13,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  /// Get chart interval for grid lines - Fixed 20M intervals
  double _getChartInterval(List<SalesTrendData> trendData) {
    // Use fixed 20M intervals: 0M, 20M, 40M, 60M, 80M, 100M, 120M
    return 20000000; // 20 million interval
  }

  /// Get maximum value from trend data
  double _getMaxValue(List<SalesTrendData> trendData) {
    double max = 0;
    for (final data in trendData) {
      if (data.salesAmount > max) max = data.salesAmount;
      if (data.commissionAmount > max) max = data.commissionAmount;
    }
    return max;
  }

  /// Format chart value for Y-axis
  String _formatChartValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 100000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else if (value >= 100) {
      return value.toStringAsFixed(0);
    } else {
      return value.toStringAsFixed(1);
    }
  }

  /// Build loading state for trend chart
  Widget _buildTrendLoading(ThemeData theme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            SizedBox(height: ResponsiveUtils.spacing12),
            Text(
              'Loading trend data...',
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

  /// Build error state for trend chart
  Widget _buildTrendError(ThemeData theme, String error) {
    final authState = ref.watch(mobileAuthProvider);

    return GestureDetector(
      onTap: () {
        // Refresh the data by invalidating the provider
        if (authState is AuthAuthenticated &&
            authState.user.cooperativeId != null &&
            authState.user.cooperativeId!.isNotEmpty) {
          ref.invalidate(salesTrendProvider(authState.user.cooperativeId!));
        }
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.refresh,
                size: ResponsiveUtils.iconSize40,
                color: theme.colorScheme.primary,
              ),
              SizedBox(height: ResponsiveUtils.spacing8),
              Text(
                'Unable to load trend data',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: ResponsiveUtils.spacing4),
              Text(
                'Tap to retry',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize12,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';
import '../../../auth/domain/entities/user.dart';

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
  String? _cooperativeName;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDashboardData() {
    final authState = ref.read(authProvider);
    if (authState is AuthAuthenticated) {
      // Load cooperative data - for now we'll use mock data
      // TODO: Implement cooperative provider
      _loadCooperativeName(authState.user);
    }
  }

  /// Load cooperative name from Firestore if needed
  Future<void> _loadCooperativeName(UserEntity user) async {
    // If we already have the name in user entity, use it
    if (user.cooperativeName != null && user.cooperativeName!.isNotEmpty) {
      setState(() {
        _cooperativeName = user.cooperativeName;
      });
      return;
    }

    // If we have cooperativeId, try to fetch from Firestore
    if (user.cooperativeId != null && user.cooperativeId!.isNotEmpty) {
      try {
        final doc =
            await FirebaseFirestore.instance
                .collection('cooperatives')
                .doc(user.cooperativeId)
                .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          setState(() {
            _cooperativeName =
                data['name'] ??
                'Cooperative ${user.cooperativeId!.toUpperCase()}';
          });
        } else {
          // Document doesn't exist, use formatted default
          setState(() {
            _cooperativeName =
                'Cooperative ${user.cooperativeId!.toUpperCase()}';
          });
        }
      } catch (e) {
        // Error fetching, use formatted default
        setState(() {
          _cooperativeName = 'Cooperative ${user.cooperativeId!.toUpperCase()}';
        });
      }
    } else {
      // No cooperative ID, use generic name
      setState(() {
        _cooperativeName = 'Agricultural Cooperative';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Please log in to access the dashboard')),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          _loadDashboardData();
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

                    // Quick actions
                    _buildQuickActions(theme),
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
                        Text(
                          _getCooperativeName(user),
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveUtils.fontSize20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                        // Notification badge
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDE21), // Bright yellow
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '3',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4A4A4A), // Slate gray
                                ),
                              ),
                            ),
                          ),
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

  /// Get cooperative name from state or user data
  String _getCooperativeName(UserEntity user) {
    // Use cached name if available
    if (_cooperativeName != null && _cooperativeName!.isNotEmpty) {
      return _cooperativeName!;
    }

    // Fallback to user entity cooperative name
    if (user.cooperativeName != null && user.cooperativeName!.isNotEmpty) {
      return user.cooperativeName!;
    }

    // If cooperativeId exists but name is missing, use a default format
    if (user.cooperativeId != null && user.cooperativeId!.isNotEmpty) {
      return 'Cooperative ${user.cooperativeId!.toUpperCase()}';
    }

    // Fallback to generic name
    return 'Agricultural Cooperative';
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

  /// Build key metrics overview
  Widget _buildKeyMetrics(ThemeData theme) {
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
          childAspectRatio: 1.0, // Increased to 2.0 to give even more height
          crossAxisSpacing: ResponsiveUtils.spacing12,
          mainAxisSpacing: ResponsiveUtils.spacing12,
          children: [
            _buildMetricCard(
              theme,
              'Farmers',
              '247',
              Icons.groups,
              Colors.blue,
              '+12 this month',
            ),
            _buildMetricCard(
              theme,
              'Active Farms',
              '189',
              Icons.agriculture,
              Colors.green,
              '76% active',
            ),
            _buildMetricCard(
              theme,
              'Sales',
              'TSh 45.2M',
              Icons.trending_up,
              Colors.orange,
              '+18% vs last month',
            ),
            _buildMetricCard(
              theme,
              'Pending Orders',
              '23',
              Icons.pending_actions,
              Colors.red,
              '5 urgent',
            ),
          ],
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

  /// Build quick actions section
  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height16),

        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                theme,
                'Add Farmer',
                Icons.person_add,
                Colors.blue,
                () {
                  // TODO: Navigate to add farmer
                },
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: _buildActionCard(
                theme,
                'New Sale',
                Icons.add_shopping_cart,
                Colors.green,
                () {
                  // TODO: Navigate to new sale
                },
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: _buildActionCard(
                theme,
                'Reports',
                Icons.analytics,
                Colors.orange,
                () {
                  // TODO: Navigate to reports
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build action card
  Widget _buildActionCard(
    ThemeData theme,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.spacing12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
              ),
              child: Icon(icon, color: color, size: ResponsiveUtils.iconSize24),
            ),
            SizedBox(height: ResponsiveUtils.height8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build cooperative earnings section
  Widget _buildCooperativeEarnings(ThemeData theme) {
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

          // Earnings metrics grid
          Row(
            children: [
              Expanded(
                child: _buildEarningsCard(
                  theme,
                  'Total Commission',
                  'TSh 2.8M',
                  'This month',
                  Icons.monetization_on,
                  Colors.green,
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing12),
              Expanded(
                child: _buildEarningsCard(
                  theme,
                  'Commission Rate',
                  '5%',
                  'Per sale',
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
                  'TSh 56M',
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
                  'TSh 2.1M',
                  'After expenses',
                  Icons.account_balance,
                  Colors.purple,
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.height16),

          // Commission breakdown
          Container(
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
          SizedBox(height: ResponsiveUtils.height12),

          // Mock sales data
          ...List.generate(3, (index) {
            final sales = [
              {
                'product': 'Maize',
                'amount': 'TSh 2.5M',
                'farmer': 'John Mwangi',
              },
              {
                'product': 'Coffee',
                'amount': 'TSh 1.8M',
                'farmer': 'Mary Kimani',
              },
              {
                'product': 'Rice',
                'amount': 'TSh 3.2M',
                'farmer': 'Peter Mbeki',
              },
            ];
            final sale = sales[index];

            return Padding(
              padding: EdgeInsets.only(bottom: ResponsiveUtils.spacing8),
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
                          sale['product']!,
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'by ${sale['farmer']!}',
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
                  Text(
                    sale['amount']!,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build recent activities section
  Widget _buildRecentActivities(ThemeData theme) {
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

          // Mock activity data
          ...List.generate(4, (index) {
            final activities = [
              {
                'action': 'New farmer registered',
                'time': '2 hours ago',
                'icon': Icons.person_add,
              },
              {
                'action': 'Sale completed',
                'time': '4 hours ago',
                'icon': Icons.shopping_cart,
              },
              {
                'action': 'Report generated',
                'time': '1 day ago',
                'icon': Icons.analytics,
              },
              {
                'action': 'Payment processed',
                'time': '2 days ago',
                'icon': Icons.payment,
              },
            ];
            final activity = activities[index];

            return Padding(
              padding: EdgeInsets.only(bottom: ResponsiveUtils.spacing12),
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
                      activity['icon'] as IconData,
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
                          activity['action']! as String,
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          activity['time']! as String,
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
            );
          }),
        ],
      ),
    );
  }

  /// Build performance insights section
  Widget _buildPerformanceInsights(ThemeData theme) {
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

          // Performance metrics
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  theme,
                  'Growth Rate',
                  '+18%',
                  'vs last month',
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing12),
              Expanded(
                child: _buildInsightCard(
                  theme,
                  'Efficiency',
                  '94%',
                  'operational',
                  Colors.blue,
                  Icons.speed,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.height12),

          // Recommendations
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
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
                    'Consider expanding to 3 more regions based on current growth trends',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize13,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
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
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../auth/presentation/providers/mobile_auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';
import '../../../auth/domain/entities/user.dart';
import '../../profile/domain/entities/cooperative_settings.dart';
import '../../profile/data/repositories/cooperative_settings_repository_impl.dart';

/// Professional cooperative profile screen with role-based features
class CooperativeProfileScreen extends ConsumerStatefulWidget {
  const CooperativeProfileScreen({super.key});

  @override
  ConsumerState<CooperativeProfileScreen> createState() =>
      _CooperativeProfileScreenState();
}

class _CooperativeProfileScreenState
    extends ConsumerState<CooperativeProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(mobileAuthProvider);

    if (authState is! AuthAuthenticated) {
      return _buildNotAuthenticatedState(theme);
    }

    final user = authState.user;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme, user),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileHeader(theme, user),
                _buildTabBar(theme),
                _buildTabContent(theme, user),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build not authenticated state
  Widget _buildNotAuthenticatedState(ThemeData theme) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: ResponsiveUtils.iconSize80,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: ResponsiveUtils.spacing24),
            Text(
              'Authentication Required',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing8),
            Text(
              'Please log in to view your profile',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build sliver app bar with gradient background
  Widget _buildSliverAppBar(ThemeData theme, UserEntity user) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
      title: Text(
        'Profile',
        style: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.fontSize20,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isEditing ? Icons.save : Icons.edit,
            color: theme.colorScheme.onPrimary,
          ),
          onPressed: () => _toggleEditMode(),
          tooltip: _isEditing ? 'Save Changes' : 'Edit Profile',
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: theme.colorScheme.onPrimary),
          onSelected: (value) => _handleMenuAction(value),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'help',
                  child: ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text('Help & Support'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Logout', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
        ),
      ],
    );
  }




  /// Build profile header with user info and avatar
  Widget _buildProfileHeader(ThemeData theme, UserEntity user) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing24),
      child: Column(
        children: [
          // Profile Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: ResponsiveUtils.iconSize40,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                backgroundImage:
                    user.profileImageUrl != null
                        ? NetworkImage(user.profileImageUrl!)
                        : null,
                child:
                    user.profileImageUrl == null
                        ? Icon(
                          Icons.person,
                          size: ResponsiveUtils.iconSize40,
                          color: theme.colorScheme.primary,
                        )
                        : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(user.status),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getStatusIcon(user.status),
                    size: ResponsiveUtils.iconSize12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing16),

          // User Name and Role
          Text(
            user.name,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.spacing4),

          // Role Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing12,
              vertical: ResponsiveUtils.spacing4,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
            ),
            child: Text(
              _formatRole(user.role),
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing8),

          // Cooperative Name
          if (user.cooperativeName != null)
            Text(
              user.cooperativeName!,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: ResponsiveUtils.spacing16),

          // Quick Stats Row
          _buildQuickStats(theme, user),
        ],
      ),
    );
  }

  /// Build tab bar
  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.6,
        ),
        indicator: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.fontSize14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.fontSize14,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(icon: Icon(Icons.person_outline), text: 'Personal'),
          Tab(icon: Icon(Icons.business_outlined), text: 'Cooperative'),
          Tab(icon: Icon(Icons.security_outlined), text: 'Security'),
          Tab(icon: Icon(Icons.settings_outlined), text: 'Settings'),
        ],
      ),
    );
  }

  /// Build tab content
  Widget _buildTabContent(ThemeData theme, UserEntity user) {
    return Container(
      height: 600, // Fixed height for tab content
      margin: EdgeInsets.all(ResponsiveUtils.spacing16),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalTab(theme, user),
          _buildCooperativeTab(theme, user),
          _buildSecurityTab(theme, user),
          _buildSettingsTab(theme),
        ],
      ),
    );
  }

  /// Build personal information tab
  Widget _buildPersonalTab(ThemeData theme, UserEntity user) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Personal Information',
            Icons.person_outline,
            theme,
          ),
          SizedBox(height: ResponsiveUtils.spacing16),

          _buildInfoCard('Full Name', user.name, Icons.badge_outlined, theme),
          SizedBox(height: ResponsiveUtils.spacing12),

          _buildInfoCard(
            'Email Address',
            user.email,
            Icons.email_outlined,
            theme,
          ),
          SizedBox(height: ResponsiveUtils.spacing12),

          _buildInfoCard(
            'Phone Number',
            user.phoneNumber ?? 'Not provided',
            Icons.phone_outlined,
            theme,
          ),
          SizedBox(height: ResponsiveUtils.spacing12),

          _buildInfoCard(
            'Account Status',
            _formatStatus(user.status),
            Icons.verified_user_outlined,
            theme,
            statusColor: _getStatusColor(user.status),
          ),
          SizedBox(height: ResponsiveUtils.spacing12),

          _buildInfoCard(
            'Member Since',
            DateFormat('MMMM dd, yyyy').format(user.createdAt),
            Icons.calendar_today_outlined,
            theme,
          ),

          if (user.lastLoginAt != null) ...[
            SizedBox(height: ResponsiveUtils.spacing12),
            _buildInfoCard(
              'Last Login',
              DateFormat('MMM dd, yyyy - HH:mm').format(user.lastLoginAt!),
              Icons.login_outlined,
              theme,
            ),
          ],
        ],
      ),
    );
  }

  /// Build cooperative information tab
  Widget _buildCooperativeTab(ThemeData theme, UserEntity user) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Cooperative Details',
            Icons.business_outlined,
            theme,
          ),
          SizedBox(height: ResponsiveUtils.spacing16),

          _buildInfoCard(
            'Cooperative Name',
            user.cooperativeName ?? 'Not assigned',
            Icons.business_center_outlined,
            theme,
          ),
          SizedBox(height: ResponsiveUtils.spacing12),

          _buildInfoCard(
            'Role',
            _formatRole(user.role),
            Icons.work_outline,
            theme,
          ),
          SizedBox(height: ResponsiveUtils.spacing12),

          _buildInfoCard(
            'User Type',
            user.userType.value.toUpperCase(),
            Icons.category_outlined,
            theme,
          ),

          if (user.permissions != null && user.permissions!.isNotEmpty) ...[
            SizedBox(height: ResponsiveUtils.spacing24),
            _buildSectionHeader('Permissions', Icons.security_outlined, theme),
            SizedBox(height: ResponsiveUtils.spacing16),
            _buildPermissionsGrid(theme, user.permissions!),
          ],

          SizedBox(height: ResponsiveUtils.spacing24),
          _buildSectionHeader(
            'Subscription',
            Icons.card_membership_outlined,
            theme,
          ),
          SizedBox(height: ResponsiveUtils.spacing16),

          _buildInfoCard(
            'Package',
            _formatSubscriptionPackage(user.subscriptionPackage),
            Icons.card_membership_outlined,
            theme,
          ),
          SizedBox(height: ResponsiveUtils.spacing12),

          _buildInfoCard(
            'Status',
            _formatSubscriptionStatus(user.subscriptionStatus),
            Icons.verified_outlined,
            theme,
            statusColor: _getSubscriptionStatusColor(user.subscriptionStatus),
          ),

          if (user.subscriptionEndDate != null) ...[
            SizedBox(height: ResponsiveUtils.spacing12),
            _buildInfoCard(
              'Expires On',
              DateFormat('MMMM dd, yyyy').format(user.subscriptionEndDate!),
              Icons.schedule_outlined,
              theme,
            ),
          ],
        ],
      ),
    );
  }

  /// Build security tab
  Widget _buildSecurityTab(ThemeData theme, UserEntity user) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Security Settings',
            Icons.security_outlined,
            theme,
          ),
          SizedBox(height: ResponsiveUtils.spacing16),

          _buildActionCard(
            'Change Password',
            'Update your account password',
            Icons.lock_outline,
            theme,
            onTap: () => _showChangePasswordDialog(),
          ),
          SizedBox(height: ResponsiveUtils.spacing12),

          _buildActionCard(
            'Two-Factor Authentication',
            'Add an extra layer of security',
            Icons.security,
            theme,
            onTap: () => _showTwoFactorDialog(),
          ),
          SizedBox(height: ResponsiveUtils.spacing12),

          _buildActionCard(
            'Login History',
            'View recent login activity',
            Icons.history,
            theme,
            onTap: () => _showLoginHistory(),
          ),
          SizedBox(height: ResponsiveUtils.spacing12),

          _buildActionCard(
            'Privacy Settings',
            'Manage your privacy preferences',
            Icons.privacy_tip_outlined,
            theme,
            onTap: () => _showPrivacySettings(),
          ),

          SizedBox(height: ResponsiveUtils.spacing24),
          _buildSectionHeader(
            'Account Actions',
            Icons.admin_panel_settings_outlined,
            theme,
          ),
          SizedBox(height: ResponsiveUtils.spacing16),

          _buildActionCard(
            'Export Data',
            'Download your account data',
            Icons.download_outlined,
            theme,
            onTap: () => _exportUserData(),
          ),
          SizedBox(height: ResponsiveUtils.spacing12),

          _buildActionCard(
            'Delete Account',
            'Permanently delete your account',
            Icons.delete_forever_outlined,
            theme,
            isDestructive: true,
            onTap: () => _showDeleteAccountDialog(),
          ),
        ],
      ),
    );
  }

  /// Build quick stats row
  Widget _buildQuickStats(ThemeData theme, UserEntity user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          'Status',
          _formatStatus(user.status),
          _getStatusColor(user.status),
          theme,
        ),
        Container(
          height: 40,
          width: 1,
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        _buildStatItem(
          'Role',
          _formatRole(user.role),
          theme.colorScheme.primary,
          theme,
        ),
        Container(
          height: 40,
          width: 1,
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        _buildStatItem(
          'Package',
          _formatSubscriptionPackage(user.subscriptionPackage),
          _getSubscriptionStatusColor(user.subscriptionStatus),
          theme,
        ),
      ],
    );
  }

  /// Build individual stat item
  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          size: ResponsiveUtils.iconSize20,
          color: theme.colorScheme.primary,
        ),
        SizedBox(width: ResponsiveUtils.spacing8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// Build info card
  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    ThemeData theme, {
    Color? statusColor,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.spacing8),
              decoration: BoxDecoration(
                color: (statusColor ?? theme.colorScheme.primary).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
              ),
              child: Icon(
                icon,
                size: ResponsiveUtils.iconSize20,
                color: statusColor ?? theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.fontSize16,
                      fontWeight: FontWeight.w500,
                      color: statusColor ?? theme.colorScheme.onSurface,
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

  /// Build action card
  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    ThemeData theme, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final color =
        isDestructive ? theme.colorScheme.error : theme.colorScheme.primary;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(ResponsiveUtils.spacing8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
          ),
          child: Icon(icon, size: ResponsiveUtils.iconSize20, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: isDestructive ? color : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: ResponsiveUtils.iconSize16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        onTap: onTap,
      ),
    );
  }

  /// Build permissions grid
  Widget _buildPermissionsGrid(ThemeData theme, List<String> permissions) {
    return Wrap(
      spacing: ResponsiveUtils.spacing8,
      runSpacing: ResponsiveUtils.spacing8,
      children:
          permissions.map((permission) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.spacing12,
                vertical: ResponsiveUtils.spacing6,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
                border: Border.all(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _formatPermission(permission),
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.secondary,
                ),
              ),
            );
          }).toList(),
    );
  }

  // Utility methods for formatting and colors
  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.inactive:
        return Colors.orange;
      case UserStatus.suspended:
        return Colors.red;
      case UserStatus.pending:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return Icons.check_circle;
      case UserStatus.inactive:
        return Icons.pause_circle;
      case UserStatus.suspended:
        return Icons.block;
      case UserStatus.pending:
        return Icons.hourglass_empty;
    }
  }

  String _formatRole(String? role) {
    if (role == null || role.isEmpty) return 'Member';
    return role
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatStatus(UserStatus status) {
    return status.value[0].toUpperCase() + status.value.substring(1);
  }

  String _formatSubscriptionPackage(String? package) {
    if (package == null || package.isEmpty) return 'Free Tier';
    return package
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatSubscriptionStatus(String? status) {
    if (status == null || status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1);
  }

  Color _getSubscriptionStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'trial':
        return Colors.blue;
      case 'expired':
        return Colors.red;
      case 'cancelled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatPermission(String permission) {
    return permission
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // Action handlers
  void _toggleEditMode() {
    setState(() {
      // _isEditing = !_isEditing;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Edit mode enabled' : 'Changes saved'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'settings':
        _showSettings();
        break;
      case 'help':
        _showHelp();
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings feature coming soon')),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support feature coming soon')),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(mobileAuthProvider.notifier).logout();
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _showChangePasswordDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password feature coming soon')),
    );
  }

  void _showTwoFactorDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Two-factor authentication coming soon')),
    );
  }

  void _showLoginHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login history feature coming soon')),
    );
  }

  void _showPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy settings feature coming soon')),
    );
  }

  void _exportUserData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export feature coming soon')),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'This action cannot be undone. All your data will be permanently deleted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deletion feature coming soon'),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  /// Build cooperative settings tab
  Widget _buildSettingsTab(ThemeData theme) {
    final authState = ref.watch(mobileAuthProvider);

    if (authState is AuthAuthenticated) {
      final user = authState.user;

      if (user.cooperativeId == null || user.cooperativeId!.isEmpty) {
        return _buildNoCooperativeMessage(theme);
      }

      // Watch cooperative settings in real-time
      final settingsAsync = ref.watch(
        cooperativeSettingsStreamProvider(user.cooperativeId!),
      );

      return settingsAsync.when(
        data: (settings) {
          if (settings == null) {
            return _buildCreateSettingsPrompt(
              theme,
              user.cooperativeId!,
              user.cooperativeName ?? 'Unknown Cooperative',
            );
          }
          return _buildSettingsContent(theme, settings);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorMessage(theme, error.toString()),
      );
    } else if (authState is AuthLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return _buildNotAuthenticatedMessage(theme);
    }
  }

  /// Build not authenticated message
  Widget _buildNotAuthenticatedMessage(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: ResponsiveUtils.iconSize80,
            color: theme.colorScheme.error,
          ),
          SizedBox(height: ResponsiveUtils.spacing16),
          Text(
            'Authentication Required',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing8),
          Text(
            'Please log in to view cooperative settings.',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build message when user has no cooperative
  Widget _buildNoCooperativeMessage(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: ResponsiveUtils.iconSize80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          SizedBox(height: ResponsiveUtils.spacing16),
          Text(
            'No Cooperative Assigned',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing8),
          Text(
            'You are not currently assigned to any cooperative.',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build prompt to create settings
  Widget _buildCreateSettingsPrompt(
    ThemeData theme,
    String cooperativeId,
    String cooperativeName,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings_outlined,
            size: ResponsiveUtils.iconSize80,
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: ResponsiveUtils.spacing16),
          Text(
            'Setup Required',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing8),
          Text(
            'Cooperative settings have not been configured yet.',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.spacing24),
          ElevatedButton.icon(
            onPressed:
                () => _createDefaultSettings(cooperativeId, cooperativeName),
            icon: const Icon(Icons.add),
            label: const Text('Create Default Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error message
  Widget _buildErrorMessage(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ResponsiveUtils.iconSize80,
            color: theme.colorScheme.error,
          ),
          SizedBox(height: ResponsiveUtils.spacing16),
          Text(
            'Error Loading Settings',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing8),
          Text(
            error,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Create default settings for cooperative
  Future<void> _createDefaultSettings(
    String cooperativeId,
    String cooperativeName,
  ) async {
    try {
      final repository = ref.read(cooperativeSettingsRepositoryProvider);
      await repository.createDefaultSettings(cooperativeId, cooperativeName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Default settings created successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create settings: $e')),
        );
      }
    }
  }

  /// Build settings content with actual data
  Widget _buildSettingsContent(ThemeData theme, CooperativeSettings settings) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Cooperative Settings',
            Icons.settings_outlined,
            theme,
          ),
          SizedBox(height: ResponsiveUtils.spacing16),

          // Basic Information Section
          _buildSettingsSection(
            'Basic Information',
            Icons.info_outline,
            theme,
            [
              _buildSettingsItem('Name', settings.basicInfo.name, theme),
              _buildSettingsItem(
                'Registration Number',
                settings.basicInfo.registrationNumber,
                theme,
              ),
              _buildSettingsItem(
                'Legal Status',
                settings.basicInfo.legalStatus,
                theme,
              ),
              _buildSettingsItem('Website', settings.basicInfo.website, theme),
            ],
          ),

          SizedBox(height: ResponsiveUtils.spacing24),

          // Business Settings Section
          _buildSettingsSection(
            'Business Settings',
            Icons.business_center_outlined,
            theme,
            [
              _buildSettingsItem(
                'Currency',
                settings.businessSettings.currency,
                theme,
              ),
              _buildSettingsItem(
                'Commission Rate',
                '${settings.businessSettings.commissionRate}%',
                theme,
              ),
              _buildSettingsItem(
                'Minimum Sale Amount',
                'TSh ${settings.businessSettings.minimumSaleAmount}',
                theme,
              ),
              _buildSettingsItem(
                'Payment Terms',
                '${settings.businessSettings.paymentTerms} days',
                theme,
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.spacing24),

          // Operational Settings Section
          _buildSettingsSection(
            'Operational Settings',
            Icons.schedule_outlined,
            theme,
            [
              _buildSettingsItem(
                'Working Hours',
                '${settings.operationalSettings.workingHours.start} - ${settings.operationalSettings.workingHours.end}',
                theme,
              ),
              _buildSettingsItem(
                'Working Days',
                settings.operationalSettings.workingDays.join(', '),
                theme,
              ),
              _buildSettingsItem(
                'Geographic Zones',
                settings.operationalSettings.geographicZones.join(', '),
                theme,
              ),
              _buildSettingsItem(
                'Quality Grades',
                settings.operationalSettings.qualityGrades.join(', '),
                theme,
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.spacing24),

          // Notification Settings Section
          _buildNotificationSettings(theme, settings),

          SizedBox(height: ResponsiveUtils.spacing24),

          // Security Settings Section
          _buildSecuritySettingsSection(theme, settings),
        ],
      ),
    );
  }

  /// Build settings section
  Widget _buildSettingsSection(
    String title,
    IconData icon,
    ThemeData theme,
    List<Widget> items,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: ResponsiveUtils.iconSize20,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.spacing16),
            ...items,
          ],
        ),
      ),
    );
  }

  /// Build individual settings item
  Widget _buildSettingsItem(String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.spacing12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? 'Not set' : value,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize14,
                fontWeight: FontWeight.w500,
                color:
                    value.isEmpty
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                        : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build notification settings section
  Widget _buildNotificationSettings(
    ThemeData theme,
    CooperativeSettings settings,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: ResponsiveUtils.iconSize20,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Text(
                  'Notification Settings',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.spacing16),

            _buildNotificationToggle(
              'Email Notifications',
              settings
                  .notificationSettings
                  .emailNotifications
                  .salesTransactions,
              theme,
            ),
            _buildNotificationToggle(
              'SMS Notifications',
              settings
                  .notificationSettings
                  .smsNotifications
                  .paymentConfirmations,
              theme,
            ),
            _buildNotificationToggle(
              'Push Notifications',
              settings.notificationSettings.pushNotifications.realTimeUpdates,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  /// Build notification toggle
  Widget _buildNotificationToggle(String label, bool value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.spacing8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              // TODO: Implement toggle functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label ${newValue ? 'enabled' : 'disabled'}'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build security settings section
  Widget _buildSecuritySettingsSection(
    ThemeData theme,
    CooperativeSettings settings,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security_outlined,
                  size: ResponsiveUtils.iconSize20,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Text(
                  'Security Settings',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.spacing16),

            _buildSettingsItem(
              'Two-Factor Authentication',
              settings.securitySettings.twoFactorAuth ? 'Enabled' : 'Disabled',
              theme,
            ),
            _buildSettingsItem(
              'Session Timeout',
              '${settings.securitySettings.sessionTimeout ~/ 60} minutes',
              theme,
            ),
            _buildSettingsItem(
              'Audit Logging',
              settings.securitySettings.auditLogging ? 'Enabled' : 'Disabled',
              theme,
            ),
            _buildSettingsItem(
              'Password Min Length',
              '${settings.securitySettings.passwordPolicy.minLength} characters',
              theme,
            ),
          ],
        ),
      ),
    );
  }
}

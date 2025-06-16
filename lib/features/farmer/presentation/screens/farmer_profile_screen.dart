import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import '../../../subscription/presentation/screens/subscription_screen.dart';
import '../../../subscription/domain/entities/subscription.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/language_selector.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';

/// Farmer profile screen with comprehensive functionality
class FarmerProfileScreen extends ConsumerStatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  ConsumerState<FarmerProfileScreen> createState() =>
      _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends ConsumerState<FarmerProfileScreen> {
  bool _isCollapsed = false;
  bool _isUploadingImage = false;
  final ImagePicker _imagePicker = ImagePicker();

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
      body: CustomScrollView(
        slivers: [
          // Custom app bar with profile header
          _buildProfileAppBar(theme, user),

          // Profile content
          SliverToBoxAdapter(
            child: Padding(
              padding: ResponsiveUtils.paddingHorizontal16,
              child: Column(
                children: [
                  SizedBox(height: ResponsiveUtils.height24),

                  // Profile information card
                  _buildProfileInfoCard(theme, user),

                  SizedBox(height: ResponsiveUtils.height24),

                  // Farm information card
                  _buildFarmInfoCard(theme, user),

                  SizedBox(height: ResponsiveUtils.height24),

                  // Subscription section
                  _buildSubscriptionSection(theme, user),

                  SizedBox(height: ResponsiveUtils.height24),

                  // Settings section
                  _buildSettingsSection(theme),

                  SizedBox(height: ResponsiveUtils.height24),

                  // Delete account section
                  _buildDeleteAccountSection(theme),

                  SizedBox(height: ResponsiveUtils.height32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build profile app bar with cover and profile picture
  Widget _buildProfileAppBar(ThemeData theme, dynamic user) {
    return SliverAppBar(
      expandedHeight: ResponsiveUtils.screenHeight25,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      actions:
          _isCollapsed
              ? [
                IconButton(
                  onPressed: () => _showEditProfileDialog(),
                  icon: Icon(
                    HugeIcons.strokeRoundedPencilEdit02,
                    color: Colors.white,
                    size: ResponsiveUtils.iconSize24,
                  ),
                ),
              ]
              : null, // Hide actions when expanded
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate if the app bar is collapsed
          final isCollapsed =
              constraints.biggest.height <=
              kToolbarHeight + MediaQuery.of(context).padding.top;

          // Update collapsed state if it changed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_isCollapsed != isCollapsed) {
              setState(() {
                _isCollapsed = isCollapsed;
              });
            }
          });

          return FlexibleSpaceBar(
            title: isCollapsed ? _buildCollapsedTitle(user) : null,
            titlePadding:
                isCollapsed
                    ? EdgeInsets.only(
                      left: ResponsiveUtils.spacing16,
                      bottom: ResponsiveUtils.spacing8,
                      right:
                          ResponsiveUtils
                              .spacing56, // Account for actions width
                    )
                    : null,
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/farm_pattern.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Profile content - Centered Column Layout
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Profile picture
                          _buildProfilePicture(user),

                          SizedBox(height: ResponsiveUtils.height16),

                          // User name
                          Text(
                            user.name,
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtils.fontSize24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: ResponsiveUtils.height8),

                          // User email
                          Text(
                            user.email,
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveUtils.fontSize14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: ResponsiveUtils.height12),

                          // Edit Profile button (only visible when expanded)
                          GestureDetector(
                            onTap: () => _showEditProfileDialog(),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtils.spacing16,
                                vertical: ResponsiveUtils.spacing8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                  ResponsiveUtils.radius20,
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: ResponsiveUtils.iconSize16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: ResponsiveUtils.spacing8),
                                  Text(
                                    'Edit Profile',
                                    style: GoogleFonts.inter(
                                      fontSize: ResponsiveUtils.fontSize12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Farm name (if available)
                          if (user.farmName != null) ...[
                            SizedBox(height: ResponsiveUtils.height8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.agriculture,
                                  size: ResponsiveUtils.iconSize16,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                SizedBox(width: ResponsiveUtils.spacing4),
                                Text(
                                  user.farmName!,
                                  style: GoogleFonts.inter(
                                    fontSize: ResponsiveUtils.fontSize12,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build collapsed title widget for app bar
  Widget _buildCollapsedTitle(dynamic user) {
    return SizedBox(
      height:
          kToolbarHeight - ResponsiveUtils.spacing16, // Ensure proper height
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Small avatar
          Container(
            width: ResponsiveUtils.iconSize32,
            height: ResponsiveUtils.iconSize32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: ClipOval(
              child:
                  user.profileImageUrl != null
                      ? Image.network(
                        user.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                _buildSmallDefaultAvatar(),
                      )
                      : _buildSmallDefaultAvatar(),
            ),
          ),

          SizedBox(width: ResponsiveUtils.spacing12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveUtils.height4),
                Text(
                  user.email,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize10,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDefaultAvatar() {
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

  /// Build profile picture with edit functionality
  Widget _buildProfilePicture(dynamic user) {
    return GestureDetector(
      onTap: _isUploadingImage ? null : () => _showProfilePictureOptions(),
      child: Stack(
        children: [
          // Main profile picture
          Container(
            width: ResponsiveUtils.iconSize80,
            height: ResponsiveUtils.iconSize80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: ResponsiveUtils.spacing8,
                  offset: Offset(0, ResponsiveUtils.spacing2),
                ),
              ],
            ),
            child: ClipOval(
              child:
                  _isUploadingImage
                      ? Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      )
                      : user.profileImageUrl != null
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

          // Edit icon overlay
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: ResponsiveUtils.iconSize24,
              height: ResponsiveUtils.iconSize24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: ResponsiveUtils.spacing4,
                    offset: Offset(0, ResponsiveUtils.spacing2),
                  ),
                ],
              ),
              child: Icon(
                Icons.edit,
                size: ResponsiveUtils.iconSize12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        size: ResponsiveUtils.iconSize40,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Build profile information card
  Widget _buildProfileInfoCard(ThemeData theme, dynamic user) {
    return Container(
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
      child: Padding(
        padding: ResponsiveUtils.paddingAll20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                  size: ResponsiveUtils.iconSize24,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Text(
                  'Personal Information',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveUtils.height16),

            _buildInfoRow(theme, 'Full Name', user.name, Icons.person),

            _buildInfoRow(theme, 'Email', user.email, Icons.email),

            if (user.phoneNumber != null)
              _buildInfoRow(theme, 'Phone', user.phoneNumber!, Icons.phone),

            _buildInfoRow(theme, 'Account Type', 'Farmer', Icons.agriculture),

            _buildInfoRow(
              theme,
              'Member Since',
              _formatDate(user.createdAt),
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  /// Build information row
  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.height12),
      child: Row(
        children: [
          Icon(
            icon,
            size: ResponsiveUtils.iconSize20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.height4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build farm information card
  Widget _buildFarmInfoCard(ThemeData theme, dynamic user) {
    return Container(
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
      child: Padding(
        padding: ResponsiveUtils.paddingAll20,
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
                  'Farm Information',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveUtils.height16),

            if (user.farmName != null) ...[
              _buildInfoRow(
                theme,
                'Farm Name',
                user.farmName!,
                Icons.landscape,
              ),
            ] else ...[
              Container(
                padding: ResponsiveUtils.paddingAll16,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: ResponsiveUtils.iconSize20,
                    ),
                    SizedBox(width: ResponsiveUtils.spacing12),
                    Expanded(
                      child: Text(
                        'Complete your farm profile to get personalized recommendations',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize14,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build subscription section
  Widget _buildSubscriptionSection(ThemeData theme, dynamic user) {
    final currentPackage = SubscriptionPackage.fromString(
      user.subscriptionPackage ?? 'free_tier',
    );
    final daysRemaining = _calculateDaysRemaining(user);
    final isTrialActive =
        user.subscriptionStatus == 'trial' ||
        (currentPackage == SubscriptionPackage.freeTier &&
            daysRemaining != null);

    return Container(
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
      child: Padding(
        padding: ResponsiveUtils.paddingAll20,
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
                  'Subscription',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveUtils.height16),

            // Current package info
            Container(
              padding: ResponsiveUtils.paddingAll16,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentPackage.displayName,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveUtils.fontSize16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: ResponsiveUtils.height4),
                            Text(
                              currentPackage.description,
                              style: GoogleFonts.inter(
                                fontSize: ResponsiveUtils.fontSize12,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (currentPackage.isPremium)
                        Text(
                          '\$${currentPackage.monthlyPrice.toStringAsFixed(0)}/mo',
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveUtils.fontSize14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      else
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
                            'FREE',
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveUtils.fontSize10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),

                  if (isTrialActive && daysRemaining != null) ...[
                    SizedBox(height: ResponsiveUtils.height12),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.spacing12,
                        vertical: ResponsiveUtils.spacing8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            daysRemaining <= 3
                                ? theme.colorScheme.error.withValues(alpha: 0.1)
                                : theme.colorScheme.secondary.withValues(
                                  alpha: 0.1,
                                ),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.radius8,
                        ),
                        border: Border.all(
                          color:
                              daysRemaining <= 3
                                  ? theme.colorScheme.error.withValues(
                                    alpha: 0.3,
                                  )
                                  : theme.colorScheme.secondary.withValues(
                                    alpha: 0.3,
                                  ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            daysRemaining <= 3 ? Icons.warning : Icons.schedule,
                            size: ResponsiveUtils.iconSize16,
                            color:
                                daysRemaining <= 3
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.secondary,
                          ),
                          SizedBox(width: ResponsiveUtils.spacing8),
                          Text(
                            '$daysRemaining days remaining in trial',
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveUtils.fontSize12,
                              fontWeight: FontWeight.w500,
                              color:
                                  daysRemaining <= 3
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: ResponsiveUtils.height16),

            // Upgrade button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToSubscriptionScreen(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUtils.spacing12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius12,
                    ),
                  ),
                ),
                icon: Icon(Icons.upgrade, size: ResponsiveUtils.iconSize20),
                label: Text(
                  currentPackage == SubscriptionPackage.freeTier
                      ? 'Upgrade Plan'
                      : 'Manage Subscription',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build settings section
  Widget _buildSettingsSection(ThemeData theme) {
    return Container(
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
      child: Padding(
        padding: ResponsiveUtils.paddingAll20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: theme.colorScheme.primary,
                  size: ResponsiveUtils.iconSize24,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Text(
                  'Settings',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveUtils.height16),

            _buildSettingsTile(
              theme,
              'Edit Profile',
              'Update your personal information',
              Icons.edit,
              () => _showEditProfileDialog(),
            ),

            _buildSettingsTile(
              theme,
              'Notifications',
              'Manage your notification preferences',
              Icons.notifications,
              () => _showNotificationSettings(),
            ),

            _buildSettingsTile(
              theme,
              'Privacy & Security',
              'Manage your privacy settings',
              Icons.security,
              () => _showPrivacySettings(),
            ),

            _buildSettingsTile(
              theme,
              'Language / Lugha',
              'Change app language / Badili lugha ya programu',
              Icons.language,
              () => _showLanguageSettings(),
            ),

            _buildSettingsTile(
              theme,
              'Help & Support',
              'Get help and contact support',
              Icons.help,
              () => _showHelpSupport(),
            ),

            _buildSettingsTile(
              theme,
              'Sign Out',
              'Sign out of your account',
              Icons.logout,
              () => _handleLogout(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build settings tile
  Widget _buildSettingsTile(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.height12,
          horizontal: ResponsiveUtils.spacing8,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.spacing8),
              decoration: BoxDecoration(
                color:
                    isDestructive
                        ? theme.colorScheme.error.withValues(alpha: 0.1)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
              ),
              child: Icon(
                icon,
                size: ResponsiveUtils.iconSize20,
                color:
                    isDestructive
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
              ),
            ),

            SizedBox(width: ResponsiveUtils.spacing16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      fontWeight: FontWeight.w600,
                      color:
                          isDestructive
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.height4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              size: ResponsiveUtils.iconSize20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  /// Build delete account section
  Widget _buildDeleteAccountSection(ThemeData theme) {
    return Container(
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
      child: Padding(
        padding: ResponsiveUtils.paddingAll20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveUtils.height16),

            // Delete account button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showDeleteAccountDialog(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUtils.height16,
                    horizontal: ResponsiveUtils.spacing24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius12,
                    ),
                  ),
                ),
                icon: Icon(
                  Icons.delete_forever,
                  size: ResponsiveUtils.iconSize20,
                ),
                label: Text(
                  'Delete Account',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Show profile picture options
  void _showProfilePictureOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUtils.radius20),
        ),
      ),
      builder:
          (context) => Container(
            padding: ResponsiveUtils.paddingAll24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Change Profile Picture',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.height24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPhotoOption(
                      'Camera',
                      Icons.camera_alt,
                      () => _pickImage(true),
                    ),
                    _buildPhotoOption(
                      'Gallery',
                      Icons.photo_library,
                      () => _pickImage(false),
                    ),
                    _buildPhotoOption(
                      'Remove',
                      Icons.delete,
                      () => _removeProfilePicture(),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildPhotoOption(String label, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: ResponsiveUtils.iconSize24,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Pick image from camera or gallery
  Future<void> _pickImage(bool fromCamera) async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      XFile? pickedFile;

      // Try to pick image with better error handling
      try {
        pickedFile = await _imagePicker.pickImage(
          source: fromCamera ? ImageSource.camera : ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
          requestFullMetadata: false, // This can help with some Android issues
        );
      } on PlatformException catch (e) {
        // Handle specific platform exceptions
        String errorMessage = 'Failed to pick image';

        if (e.code == 'camera_access_denied') {
          errorMessage =
              'Camera access denied. Please enable camera permission in settings.';
        } else if (e.code == 'photo_access_denied') {
          errorMessage =
              'Photo access denied. Please enable photo permission in settings.';
        } else if (e.code == 'invalid_image') {
          errorMessage = 'Invalid image selected. Please try another image.';
        } else if (e.message?.contains('channel error') == true) {
          errorMessage =
              'Image picker service unavailable. Please restart the app and try again.';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      if (pickedFile != null) {
        // Verify file exists and is readable
        final file = File(pickedFile.path);
        if (!await file.exists()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Selected image file not found. Please try again.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Upload image to Firebase Storage
        final imageUrl = await _uploadImageToFirebase(file);

        if (imageUrl != null) {
          // Update user profile with new image URL
          await _updateUserProfileImage(imageUrl);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload image. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  /// Upload image to Firebase Storage
  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      final authState = ref.read(authProvider);
      if (authState is! AuthAuthenticated) return null;
      final user = authState.user;

      // Create a unique filename
      final fileName =
          'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Create reference to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName);

      // Upload the file
      final uploadTask = storageRef.putFile(imageFile);

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Update user profile image URL
  Future<void> _updateUserProfileImage(String imageUrl) async {
    try {
      final authState = ref.read(authProvider);
      if (authState is! AuthAuthenticated) return;
      final user = authState.user;

      // Update user profile in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.id).update({
        'profileImageUrl': imageUrl,
      });

      // Refresh auth state to reflect changes
      await ref.read(authProvider.notifier).initializeAuth();
    } catch (e) {
      print('Error updating profile image: $e');
      rethrow;
    }
  }

  /// Remove profile picture
  Future<void> _removeProfilePicture() async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      final authState = ref.read(authProvider);
      if (authState is! AuthAuthenticated) return;
      final user = authState.user;

      // Remove profile image URL from Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.id).update({
        'profileImageUrl': null,
      });

      // Refresh auth state to reflect changes
      await ref.read(authProvider.notifier).initializeAuth();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture removed successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing profile picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  /// Show edit profile dialog
  void _showEditProfileDialog() {
    // TODO: Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile functionality coming soon')),
    );
  }

  /// Show notification settings
  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings coming soon')),
    );
  }

  /// Show privacy settings
  void _showPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy settings coming soon')),
    );
  }

  /// Show language settings
  void _showLanguageSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(ResponsiveUtils.radius20),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.height16),

                  // Title
                  Text(
                    'Language Settings',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.fontSize20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.height8),

                  // Subtitle
                  Text(
                    'Choose your preferred language for the app interface.',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.height24),

                  // Language selector
                  const LanguageSelector(),

                  SizedBox(height: ResponsiveUtils.height16),

                  // Quick toggle section
                  Container(
                    padding: EdgeInsets.all(ResponsiveUtils.spacing16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius12,
                      ),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.flash_on,
                          color: Theme.of(context).colorScheme.primary,
                          size: ResponsiveUtils.iconSize20,
                        ),
                        SizedBox(width: ResponsiveUtils.spacing12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Toggle',
                                style: GoogleFonts.inter(
                                  fontSize: ResponsiveUtils.fontSize14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Tap to switch between languages',
                                style: GoogleFonts.inter(
                                  fontSize: ResponsiveUtils.fontSize12,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const LanguageToggleButton(),
                      ],
                    ),
                  ),

                  SizedBox(height: ResponsiveUtils.height24),
                ],
              ),
            ),
          ),
    );
  }

  /// Show help and support
  void _showHelpSupport() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Help & support coming soon')));
  }

  /// Handle logout
  void _handleLogout() async {
    final confirmed = await _showLogoutConfirmation();
    if (confirmed == true) {
      try {
        await ref.read(authProvider.notifier).logout();
        if (mounted) {
          // Navigation will be handled by the auth state listener
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
        }
      }
    }
  }

  /// Show logout confirmation dialog
  Future<bool?> _showLogoutConfirmation() {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
            ),
            title: Text(
              'Sign Out',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Are you sure you want to sign out of your account?',
              style: GoogleFonts.inter(fontSize: ResponsiveUtils.fontSize14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                ),
                child: Text(
                  'Sign Out',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  /// Show delete account confirmation dialog
  void _showDeleteAccountDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: theme.colorScheme.error,
                  size: ResponsiveUtils.iconSize24,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Text(
                  'Delete Account',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This action cannot be undone. Deleting your account will:',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.height12),
                ...[
                  'Remove all your farm data',
                  'Delete your profile information',
                  'Cancel any active subscriptions',
                ].map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: ResponsiveUtils.height4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: ResponsiveUtils.iconSize8,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.spacing8),
                        Expanded(
                          child: Text(
                            item,
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
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleDeleteAccount();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                ),
                child: Text(
                  'Delete Account',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  /// Handle delete account
  void _handleDeleteAccount() {
    // TODO: Implement account deletion functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account deletion functionality coming soon'),
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
  void _navigateToSubscriptionScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SubscriptionScreen()));
  }
}

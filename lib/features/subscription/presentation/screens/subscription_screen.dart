import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/subscription.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  SubscriptionPackage? _selectedPackage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view subscriptions')),
      );
    }

    final user = authState.user;
    final currentPackage = SubscriptionPackage.fromString(
      user.subscriptionPackage ?? 'free_tier',
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Subscription Plans',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current subscription status
            _buildCurrentSubscriptionCard(theme, user, currentPackage),

            SizedBox(height: ResponsiveUtils.height24),

            // Available packages
            Text(
              'Choose Your Plan',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            SizedBox(height: ResponsiveUtils.height16),

            // Package cards
            ...SubscriptionPackage.values.map(
              (package) => _buildPackageCard(theme, package, currentPackage),
            ),

            SizedBox(height: ResponsiveUtils.height32),

            // Upgrade button
            if (_selectedPackage != null && _selectedPackage != currentPackage)
              _buildUpgradeButton(theme),
          ],
        ),
      ),
    );
  }

  /// Build current subscription status card
  Widget _buildCurrentSubscriptionCard(
    ThemeData theme,
    dynamic user,
    SubscriptionPackage currentPackage,
  ) {
    final daysRemaining = _calculateDaysRemaining(user);
    final isTrialActive =
        user.subscriptionStatus == 'trial' ||
        (currentPackage == SubscriptionPackage.freeTier &&
            daysRemaining != null);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
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
                Icons.star,
                color: Colors.white,
                size: ResponsiveUtils.iconSize24,
              ),
              SizedBox(width: ResponsiveUtils.spacing8),
              Text(
                'Current Plan',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.height8),

          Text(
            currentPackage.displayName,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          if (isTrialActive && daysRemaining != null) ...[
            SizedBox(height: ResponsiveUtils.height4),
            Text(
              '$daysRemaining days remaining in trial',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],

          if (currentPackage.isPremium) ...[
            SizedBox(height: ResponsiveUtils.height4),
            Text(
              '\$${currentPackage.monthlyPrice.toStringAsFixed(2)}/month',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build package card
  Widget _buildPackageCard(
    ThemeData theme,
    SubscriptionPackage package,
    SubscriptionPackage currentPackage,
  ) {
    final isSelected = _selectedPackage == package;
    final isCurrent = package == currentPackage;

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.height16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPackage = package;
            });
          },
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          child: Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : isCurrent
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected || isCurrent ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: ResponsiveUtils.spacing4,
                  offset: Offset(0, ResponsiveUtils.spacing2),
                ),
              ],
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
                              Text(
                                package.displayName,
                                style: GoogleFonts.poppins(
                                  fontSize: ResponsiveUtils.fontSize18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              if (isCurrent) ...[
                                SizedBox(width: ResponsiveUtils.spacing8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveUtils.spacing8,
                                    vertical: ResponsiveUtils.spacing2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveUtils.radius8,
                                    ),
                                  ),
                                  child: Text(
                                    'Current',
                                    style: GoogleFonts.inter(
                                      fontSize: ResponsiveUtils.fontSize10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: ResponsiveUtils.height4),
                          Text(
                            package.description,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (package.isPremium) ...[
                          Text(
                            '\$${package.monthlyPrice.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtils.fontSize24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            'per month',
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveUtils.fontSize10,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ] else ...[
                          Text(
                            'FREE',
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtils.fontSize18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          Text(
                            '14 days',
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
                  ],
                ),

                SizedBox(height: ResponsiveUtils.height16),

                // Features list
                ...package.features.map(
                  (feature) => Padding(
                    padding: EdgeInsets.only(bottom: ResponsiveUtils.height4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: ResponsiveUtils.iconSize16,
                          color: theme.colorScheme.secondary,
                        ),
                        SizedBox(width: ResponsiveUtils.spacing8),
                        Expanded(
                          child: Text(
                            feature,
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
          ),
        ),
      ),
    );
  }

  /// Build upgrade button
  Widget _buildUpgradeButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handleUpgrade(),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.spacing16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          ),
        ),
        child: Text(
          'Upgrade to ${_selectedPackage!.displayName}',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
          ),
        ),
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

  /// Handle upgrade action
  void _handleUpgrade() {
    final theme = Theme.of(context);
    // TODO: Implement payment integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment integration coming soon for ${_selectedPackage!.displayName}',
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }
}

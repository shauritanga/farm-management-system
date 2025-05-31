import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../farm/domain/entities/farm.dart';
import '../../../subscription/domain/entities/subscription.dart';

/// Screen for managing user assignments to farms (Tanzanite feature)
class FarmUserAssignmentScreen extends ConsumerStatefulWidget {
  final FarmEntity farm;
  final SubscriptionPackage userSubscription;

  const FarmUserAssignmentScreen({
    super.key,
    required this.farm,
    required this.userSubscription,
  });

  @override
  ConsumerState<FarmUserAssignmentScreen> createState() =>
      _FarmUserAssignmentScreenState();
}

class _FarmUserAssignmentScreenState
    extends ConsumerState<FarmUserAssignmentScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final bool _isLoading = false;

  // Mock available users for demonstration
  final List<Map<String, String>> _availableUsers = [
    {
      'id': 'user_monitor_1',
      'name': 'John Mwangi',
      'email': 'john.mwangi@example.com',
      'role': 'Farm Monitor',
    },
    {
      'id': 'user_monitor_2',
      'name': 'Sarah Kimani',
      'email': 'sarah.kimani@example.com',
      'role': 'Agricultural Specialist',
    },
    {
      'id': 'user_monitor_3',
      'name': 'David Ochieng',
      'email': 'david.ochieng@example.com',
      'role': 'Farm Supervisor',
    },
    {
      'id': 'user_monitor_4',
      'name': 'Grace Wanjiku',
      'email': 'grace.wanjiku@example.com',
      'role': 'Crop Specialist',
    },
  ];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Check if user has Tanzanite subscription
    if (widget.userSubscription != SubscriptionPackage.tanzanite) {
      return _buildUpgradeScreen(theme);
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme),
      body: _buildBody(theme),
      floatingActionButton: _buildAddUserFAB(theme),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Assignment',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            widget.farm.name,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: ResponsiveUtils.spacing16),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacing8,
            vertical: ResponsiveUtils.spacing4,
          ),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          ),
          child: Text(
            'TANZANITE',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize10,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  /// Build body
  Widget _buildBody(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farm info card
          _buildFarmInfoCard(theme),

          SizedBox(height: ResponsiveUtils.height24),

          // Feature description
          _buildFeatureDescription(theme),

          SizedBox(height: ResponsiveUtils.height24),

          // Assigned users section
          _buildAssignedUsersSection(theme),

          SizedBox(height: ResponsiveUtils.height24),

          // Available users section
          _buildAvailableUsersSection(theme),
        ],
      ),
    );
  }

  /// Build farm info card
  Widget _buildFarmInfoCard(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
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
                Icons.agriculture,
                color: theme.colorScheme.primary,
                size: ResponsiveUtils.iconSize24,
              ),
              SizedBox(width: ResponsiveUtils.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.farm.name,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.fontSize18,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${widget.farm.location} • ${widget.farm.formattedSize}',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
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
                  color: _getStatusColor(widget.farm.status),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
                ),
                child: Text(
                  widget.farm.status.displayName,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.height12),

          // Crop types
          Wrap(
            spacing: ResponsiveUtils.spacing8,
            runSpacing: ResponsiveUtils.spacing4,
            children:
                widget.farm.cropTypes
                    .map(
                      (crop) => Chip(
                        label: Text(
                          crop,
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize12,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.secondary,
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  /// Build feature description
  Widget _buildFeatureDescription(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber.shade700,
                size: ResponsiveUtils.iconSize20,
              ),
              SizedBox(width: ResponsiveUtils.spacing8),
              Text(
                'Tanzanite Feature: User Assignment',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize16,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.height8),
          Text(
            'Assign users to monitor and manage this farm. Assigned users can view farm details, activities, and analytics. This premium feature is exclusive to Tanzanite package subscribers.',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Build assigned users section
  Widget _buildAssignedUsersSection(ThemeData theme) {
    final assignedUsers = widget.farm.assignedUsers ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people,
              color: theme.colorScheme.primary,
              size: ResponsiveUtils.iconSize20,
            ),
            SizedBox(width: ResponsiveUtils.spacing8),
            Text(
              'Assigned Users (${assignedUsers.length})',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),

        SizedBox(height: ResponsiveUtils.height16),

        if (assignedUsers.isEmpty)
          _buildEmptyAssignedUsers(theme)
        else
          ...assignedUsers.map((userId) {
            final user = _availableUsers.firstWhere(
              (u) => u['id'] == userId,
              orElse:
                  () => {
                    'id': userId,
                    'name': 'Unknown User',
                    'email': 'unknown@example.com',
                    'role': 'User',
                  },
            );
            return _buildAssignedUserCard(theme, user);
          }),
      ],
    );
  }

  /// Build empty assigned users state
  Widget _buildEmptyAssignedUsers(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_add_outlined,
            size: ResponsiveUtils.iconSize48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          SizedBox(height: ResponsiveUtils.height16),
          Text(
            'No Users Assigned',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: ResponsiveUtils.height8),
          Text(
            'Assign users to monitor and manage this farm',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build assigned user card
  Widget _buildAssignedUserCard(ThemeData theme, Map<String, String> user) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.height12),
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              user['name']!.split(' ').map((n) => n[0]).take(2).join(),
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name']!,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  user['email']!,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  user['role']!,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeUser(user['id']!),
            icon: Icon(
              Icons.remove_circle_outline,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  /// Build available users section
  Widget _buildAvailableUsersSection(ThemeData theme) {
    final assignedUserIds = widget.farm.assignedUsers ?? [];
    final availableUsers =
        _availableUsers
            .where((user) => !assignedUserIds.contains(user['id']))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person_search,
              color: theme.colorScheme.secondary,
              size: ResponsiveUtils.iconSize20,
            ),
            SizedBox(width: ResponsiveUtils.spacing8),
            Text(
              'Available Users',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),

        SizedBox(height: ResponsiveUtils.height16),

        if (availableUsers.isEmpty)
          _buildNoAvailableUsers(theme)
        else
          ...availableUsers.map((user) => _buildAvailableUserCard(theme, user)),
      ],
    );
  }

  /// Build no available users state
  Widget _buildNoAvailableUsers(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: ResponsiveUtils.iconSize48,
            color: Colors.green,
          ),
          SizedBox(height: ResponsiveUtils.height16),
          Text(
            'All Users Assigned',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: ResponsiveUtils.height8),
          Text(
            'All available users have been assigned to this farm',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build available user card
  Widget _buildAvailableUserCard(ThemeData theme, Map<String, String> user) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.height12),
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.secondary,
            child: Text(
              user['name']!.split(' ').map((n) => n[0]).take(2).join(),
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name']!,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  user['email']!,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  user['role']!,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _assignUser(user['id']!),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.spacing16,
                vertical: ResponsiveUtils.spacing8,
              ),
            ),
            child: Text(
              'Assign',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build upgrade screen for non-Tanzanite users
  Widget _buildUpgradeScreen(ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('User Assignment'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: ResponsiveUtils.iconSize64,
                color: theme.colorScheme.primary,
              ),
              SizedBox(height: ResponsiveUtils.height24),
              Text(
                'Tanzanite Feature',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: ResponsiveUtils.height16),
              Text(
                'User assignment is an exclusive feature for Tanzanite package subscribers. Upgrade to assign users to monitor and manage your farms.',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveUtils.height32),
              ElevatedButton(
                onPressed: () {
                  // Navigate to subscription upgrade
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacing32,
                    vertical: ResponsiveUtils.spacing16,
                  ),
                ),
                child: Text(
                  'Upgrade to Tanzanite',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build add user FAB
  Widget _buildAddUserFAB(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: _showAddUserDialog,
      backgroundColor: theme.colorScheme.secondary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.person_add),
      label: Text(
        'Add User',
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Get status color
  Color _getStatusColor(FarmStatus status) {
    switch (status) {
      case FarmStatus.active:
        return Colors.green;
      case FarmStatus.planning:
        return Colors.orange;
      case FarmStatus.harvesting:
        return Colors.blue;
      case FarmStatus.inactive:
        return Colors.grey;
      case FarmStatus.maintenance:
        return Colors.red;
    }
  }

  /// Show add user dialog
  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Add User by Email',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter user email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _emailController.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // In a real app, this would send an invitation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Invitation sent to ${_emailController.text}',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _emailController.clear();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Send Invitation'),
              ),
            ],
          ),
    );
  }

  /// Assign user to farm
  void _assignUser(String userId) {
    setState(() {
      final currentAssigned = widget.farm.assignedUsers ?? [];
      if (!currentAssigned.contains(userId)) {
        // In a real app, this would update the farm in the database
        // For now, we'll just show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User assigned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  /// Remove user from farm
  void _removeUser(String userId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove User'),
            content: const Text(
              'Are you sure you want to remove this user from the farm?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // In a real app, this would update the farm in the database
                    // For now, we'll just show a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User removed successfully!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }
}

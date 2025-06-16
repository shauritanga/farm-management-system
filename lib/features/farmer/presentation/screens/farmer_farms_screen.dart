import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';
import '../../../subscription/domain/entities/subscription.dart';
import '../../../farm/presentation/providers/farm_provider.dart';
import '../../../farm/domain/entities/farm.dart';
import '../../../farm/presentation/screens/farm_details_screen.dart';
import 'add_farm_screen.dart';
import 'farm_user_assignment_screen.dart';

/// Farmer farms management screen
class FarmerFarmsScreen extends ConsumerStatefulWidget {
  const FarmerFarmsScreen({super.key});

  @override
  ConsumerState<FarmerFarmsScreen> createState() => _FarmerFarmsScreenState();
}

class _FarmerFarmsScreenState extends ConsumerState<FarmerFarmsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFarms();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadFarms() {
    final authState = ref.read(authProvider);
    if (authState is AuthAuthenticated) {
      ref.read(farmProvider.notifier).loadFarms(authState.user.id);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      _loadFarms();
    } else {
      final authState = ref.read(authProvider);
      if (authState is AuthAuthenticated) {
        ref.read(farmProvider.notifier).searchFarms(authState.user.id, query);
      }
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    final authState = ref.read(authProvider);
    if (authState is AuthAuthenticated) {
      if (filter == 'All') {
        ref.read(farmProvider.notifier).loadFarms(authState.user.id);
      } else {
        final status = FarmStatus.values.firstWhere(
          (s) => s.displayName == filter,
          orElse: () => FarmStatus.active,
        );
        ref
            .read(farmProvider.notifier)
            .filterFarmsByStatus(authState.user.id, status);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user;
    final currentPackage = SubscriptionPackage.fromString(
      user.subscriptionPackage ?? 'free_tier',
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme, currentPackage),
      body: Column(
        children: [
          // Search and filter section (compact)
          _buildCompactSearchAndFilter(theme),

          // Tab bar
          _buildTabBar(theme),

          // Content with statistics integrated
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: () async => _loadFarms(),
                  child: _buildFarmsTabWithStats(
                    theme,
                    currentPackage,
                    user.id,
                  ),
                ),
                _buildActivitiesTab(theme),
                _buildAnalyticsTab(theme),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(theme, currentPackage),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(
    ThemeData theme,
    SubscriptionPackage currentPackage,
  ) {
    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'My Farms',
        style: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.fontSize20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        // View toggle
        IconButton(
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
          icon: Icon(
            _isGridView ? Icons.list : Icons.grid_view,
            color: Colors.white,
          ),
        ),

        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) => _handleMenuAction(value),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text('Export Data'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Farm Settings'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'help',
                  child: Row(
                    children: [
                      Icon(Icons.help),
                      SizedBox(width: 8),
                      Text('Help & Support'),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  /// Build compact search and filter section
  Widget _buildCompactSearchAndFilter(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing16,
        vertical: ResponsiveUtils.spacing8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: ResponsiveUtils.spacing4,
            offset: Offset(0, ResponsiveUtils.spacing2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search field (compact)
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search farms...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            icon: const Icon(Icons.clear, size: 18),
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacing8,
                    vertical: ResponsiveUtils.spacing4,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: ResponsiveUtils.spacing8),

          // Filter dropdown (compact)
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 40,
              child: DropdownButtonFormField<String>(
                value: _selectedFilter,
                onChanged: (value) => _onFilterChanged(value ?? 'All'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacing8,
                    vertical: ResponsiveUtils.spacing4,
                  ),
                ),
                items:
                    ['All', 'Active', 'Planning', 'Harvesting', 'Inactive']
                        .map(
                          (filter) => DropdownMenuItem(
                            value: filter,
                            child: Text(
                              filter,
                              style: GoogleFonts.inter(
                                fontSize: ResponsiveUtils.fontSize12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ],
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
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Farms'),
          Tab(text: 'Activities'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  /// Build farms tab with integrated statistics
  Widget _buildFarmsTabWithStats(
    ThemeData theme,
    SubscriptionPackage currentPackage,
    String farmerId,
  ) {
    final farmState = ref.watch(farmProvider);

    final stateString = farmState.toString();

    if (stateString.contains('FarmState.loading')) {
      return const Center(child: CircularProgressIndicator());
    } else if (stateString.contains('FarmState.error')) {
      // Extract error message from the state
      String errorMessage = 'Unknown error';
      try {
        final match = RegExp(r'message: (.+)\)').firstMatch(stateString);
        if (match != null) {
          errorMessage = match.group(1) ?? 'Unknown error';
        }
      } catch (e) {
        // Fallback to default message
      }

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
              'Error loading farms',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.error,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height8),
            Text(
              errorMessage,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.height16),
            ElevatedButton(
              onPressed: () {
                final authState = ref.read(authProvider);
                if (authState is AuthAuthenticated) {
                  ref.read(farmProvider.notifier).loadFarms(authState.user.id);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (stateString.contains('FarmState.loaded')) {
      // Extract farms from the state using reflection-like approach
      List<FarmEntity> farms = [];
      try {
        // Use the extension method from FarmState if available
        if (farmState.toString().contains('farms: [')) {
          // For now, we'll use a workaround to get farms
          final dynamic dynamicState = farmState;
          if (dynamicState.farms != null) {
            farms = dynamicState.farms as List<FarmEntity>;
          }
        }
      } catch (e) {
        // Fallback - this shouldn't happen in normal operation
        return const Center(child: Text('Error accessing farm data'));
      }

      if (farms.isEmpty) {
        return _buildEmptyState(theme, currentPackage);
      }

      final filteredFarms = _filterFarms(farms);

      if (filteredFarms.isEmpty) {
        return _buildNoResultsState(theme);
      }

      // Build content with integrated compact statistics
      return CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Compact statistics header
          SliverToBoxAdapter(child: _buildCompactStatistics(theme, farmerId)),

          // Farms content
          _isGridView
              ? _buildFarmsGridSliver(theme, filteredFarms)
              : _buildFarmsListSliver(theme, filteredFarms),
        ],
      );
    } else {
      return const Center(child: Text('No farms loaded'));
    }
  }

  /// Build compact statistics section
  Widget _buildCompactStatistics(ThemeData theme, String farmerId) {
    final statisticsAsync = ref.watch(farmStatisticsProvider(farmerId));

    return statisticsAsync.when(
      data:
          (statistics) => Container(
            margin: EdgeInsets.all(ResponsiveUtils.spacing12),
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
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildCompactStatItem(
                    theme,
                    'Farms',
                    statistics['totalFarms']?.toString() ?? '0',
                    Icons.agriculture,
                    theme.colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildCompactStatItem(
                    theme,
                    'Size',
                    '${statistics['totalSize']?.toStringAsFixed(1) ?? '0'} ha',
                    Icons.straighten,
                    theme.colorScheme.secondary,
                  ),
                ),
                Expanded(
                  child: _buildCompactStatItem(
                    theme,
                    'Active',
                    statistics['activeFarms']?.toString() ?? '0',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildCompactStatItem(
                    theme,
                    'Crops',
                    statistics['uniqueCropTypes']?.toString() ?? '0',
                    Icons.eco,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),
      loading:
          () => Container(
            margin: EdgeInsets.all(ResponsiveUtils.spacing12),
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stack) => Container(
            margin: EdgeInsets.all(ResponsiveUtils.spacing12),
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
            ),
            child: Center(
              child: Text(
                'Stats unavailable',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize12,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
    );
  }

  /// Build compact stat item
  Widget _buildCompactStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: ResponsiveUtils.iconSize16),
        SizedBox(height: ResponsiveUtils.height4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize14,
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
        ),
      ],
    );
  }

  /// Build farms grid sliver
  Widget _buildFarmsGridSliver(ThemeData theme, List<FarmEntity> farms) {
    return SliverPadding(
      padding: EdgeInsets.all(ResponsiveUtils.spacing12),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: ResponsiveUtils.spacing12,
          mainAxisSpacing: ResponsiveUtils.spacing12,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final farm = farms[index];
          return _buildFarmGridCard(theme, farm);
        }, childCount: farms.length),
      ),
    );
  }

  /// Build farms list sliver
  Widget _buildFarmsListSliver(ThemeData theme, List<FarmEntity> farms) {
    return SliverPadding(
      padding: EdgeInsets.all(ResponsiveUtils.spacing12),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final farm = farms[index];
          return Padding(
            padding: EdgeInsets.only(bottom: ResponsiveUtils.height12),
            child: _buildFarmListCard(theme, farm),
          );
        }, childCount: farms.length),
      ),
    );
  }

  /// Build activities tab
  Widget _buildActivitiesTab(ThemeData theme) {
    return const Center(child: Text('Activities feature coming soon'));
  }

  /// Build analytics tab
  Widget _buildAnalyticsTab(ThemeData theme) {
    return const Center(child: Text('Analytics feature coming soon'));
  }

  /// Handle menu actions
  void _handleMenuAction(String value) {
    switch (value) {
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export feature coming soon')),
        );
        break;
      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings feature coming soon')),
        );
        break;
      case 'help':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Help feature coming soon')),
        );
        break;
    }
  }

  /// Build floating action button
  Widget? _buildFloatingActionButton(
    ThemeData theme,
    SubscriptionPackage currentPackage,
  ) {
    final farmState = ref.watch(farmProvider);
    final stateString = farmState.toString();

    // Don't show FAB when there are no farms (empty state has its own button)
    if (stateString.contains('FarmState.loaded')) {
      // Extract farms from the state
      try {
        final dynamic dynamicState = farmState;
        if (dynamicState.farms != null) {
          final farms = dynamicState.farms as List<FarmEntity>;
          if (farms.isEmpty) {
            return null; // Hide FAB when no farms exist
          }
        }
      } catch (e) {
        // If we can't access farms, show the FAB anyway
      }

      return FloatingActionButton.extended(
        onPressed: () => _showCreateFarmDialog(currentPackage),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          'Add Farm',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return null; // Hide FAB in loading, error, or initial states
  }

  /// Filter farms based on selected filter and search query
  List<FarmEntity> _filterFarms(List<FarmEntity> farms) {
    var filteredFarms = farms;

    // Filter by status
    if (_selectedFilter != 'All') {
      final status = FarmStatus.values.firstWhere(
        (s) => s.displayName == _selectedFilter,
        orElse: () => FarmStatus.active,
      );
      filteredFarms =
          filteredFarms.where((farm) => farm.status == status).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredFarms =
          filteredFarms.where((farm) {
            return farm.name.toLowerCase().contains(query) ||
                farm.location.toLowerCase().contains(query) ||
                farm.cropTypes.any(
                  (crop) => crop.toLowerCase().contains(query),
                );
          }).toList();
    }

    return filteredFarms;
  }

  /// Build empty state
  Widget _buildEmptyState(ThemeData theme, SubscriptionPackage currentPackage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              size: ResponsiveUtils.iconSize80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            SizedBox(height: ResponsiveUtils.height24),
            Text(
              'No Farms Yet',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height12),
            Text(
              'Start your agricultural journey by creating your first farm',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.height32),
            ElevatedButton.icon(
              onPressed: () => _showCreateFarmDialog(currentPackage),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.spacing24,
                  vertical: ResponsiveUtils.spacing16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: Text(
                'Create Your First Farm',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build no results state
  Widget _buildNoResultsState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: ResponsiveUtils.iconSize64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            SizedBox(height: ResponsiveUtils.height16),
            Text(
              'No Results Found',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height8),
            Text(
              'Try adjusting your search or filter criteria',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to add farm screen
  void _showCreateFarmDialog(SubscriptionPackage currentPackage) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddFarmScreen(currentPackage: currentPackage),
      ),
    );

    // If farm was created successfully, reload farms
    if (result == true) {
      final authState = ref.read(authProvider);
      if (authState is AuthAuthenticated) {
        ref.read(farmProvider.notifier).loadFarms(authState.user.id);
      }
    }
  }

  /// Build farm grid card
  Widget _buildFarmGridCard(ThemeData theme, FarmEntity farm) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
      ),
      child: InkWell(
        onTap: () => _navigateToFarmDetails(farm),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.spacing12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      farm.name,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.fontSize14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(theme, farm.status),
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
                      farm.location,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize10,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.height4),
              Row(
                children: [
                  Icon(
                    Icons.straighten,
                    size: ResponsiveUtils.iconSize12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing4),
                  Text(
                    farm.formattedSize,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize10,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (farm.cropTypes.isNotEmpty) ...[
                Wrap(
                  spacing: ResponsiveUtils.spacing4,
                  runSpacing: ResponsiveUtils.spacing4,
                  children:
                      farm.cropTypes.take(2).map((crop) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.spacing6,
                            vertical: ResponsiveUtils.spacing2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.radius6,
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
      ),
    );
  }

  /// Build farm list card
  Widget _buildFarmListCard(ThemeData theme, FarmEntity farm) {
    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.height12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
      ),
      child: InkWell(
        onTap: () => _navigateToFarmDetails(farm),
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
                      farm.name,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.fontSize16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  _buildStatusChip(theme, farm.status),
                  SizedBox(width: ResponsiveUtils.spacing8),
                  _buildFarmMenuButton(theme, farm),
                ],
              ),
              SizedBox(height: ResponsiveUtils.height8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: ResponsiveUtils.iconSize16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing4),
                  Expanded(
                    child: Text(
                      farm.location,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing16),
                  Icon(
                    Icons.straighten,
                    size: ResponsiveUtils.iconSize16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing4),
                  Text(
                    farm.formattedSize,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              if (farm.cropTypes.isNotEmpty) ...[
                SizedBox(height: ResponsiveUtils.height12),
                Wrap(
                  spacing: ResponsiveUtils.spacing8,
                  runSpacing: ResponsiveUtils.spacing4,
                  children:
                      farm.cropTypes.map((crop) {
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
              if (farm.lastActivity != null) ...[
                SizedBox(height: ResponsiveUtils.height8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: ResponsiveUtils.iconSize12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing4),
                    Text(
                      'Last activity: ${farm.daysSinceLastActivity} days ago',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize10,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
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
          fontSize: ResponsiveUtils.fontSize10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Build farm menu button
  Widget _buildFarmMenuButton(ThemeData theme, FarmEntity farm) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        size: ResponsiveUtils.iconSize20,
      ),
      onSelected: (value) => _handleFarmMenuAction(value, farm),
      itemBuilder: (context) {
        final authState = ref.read(authProvider);
        final currentPackage =
            authState is AuthAuthenticated
                ? _getSubscriptionPackage(authState.user.subscriptionPackage)
                : SubscriptionPackage.freeTier;

        return [
          const PopupMenuItem(
            value: 'view',
            child: ListTile(
              leading: Icon(Icons.visibility),
              title: Text('View Details'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Farm'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (currentPackage == SubscriptionPackage.tanzanite)
            PopupMenuItem(
              value: 'assign_users',
              child: ListTile(
                leading: Icon(Icons.people, color: Colors.amber.shade700),
                title: Row(
                  children: [
                    const Text('Assign Users'),
                    SizedBox(width: ResponsiveUtils.spacing8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.spacing4,
                        vertical: ResponsiveUtils.spacing2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.radius4,
                        ),
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
                ),
                subtitle:
                    farm.hasAssignedUsers
                        ? Text('${farm.assignedUsersCount} users assigned')
                        : const Text('No users assigned'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Farm', style: TextStyle(color: Colors.red)),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ];
      },
    );
  }

  /// Handle farm menu actions
  void _handleFarmMenuAction(String action, FarmEntity farm) {
    switch (action) {
      case 'view':
        _navigateToFarmDetails(farm);
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Edit ${farm.name} - Coming soon!')),
        );
        break;
      case 'assign_users':
        _navigateToUserAssignment(farm);
        break;
      case 'delete':
        _showDeleteConfirmation(farm);
        break;
    }
  }

  /// Navigate to user assignment screen
  void _navigateToUserAssignment(FarmEntity farm) {
    final authState = ref.read(authProvider);
    if (authState is AuthAuthenticated) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => FarmUserAssignmentScreen(
                farm: farm,
                userSubscription: _getSubscriptionPackage(
                  authState.user.subscriptionPackage,
                ),
              ),
        ),
      );
    }
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(FarmEntity farm) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Farm'),
            content: Text(
              'Are you sure you want to delete "${farm.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${farm.name} deleted - Coming soon!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  /// Get subscription package from string
  SubscriptionPackage _getSubscriptionPackage(String? subscriptionPackage) {
    switch (subscriptionPackage) {
      case 'serengeti':
        return SubscriptionPackage.serengeti;
      case 'tanzanite':
        return SubscriptionPackage.tanzanite;
      case 'free_tier':
      default:
        return SubscriptionPackage.freeTier;
    }
  }

  /// Navigate to farm details
  void _navigateToFarmDetails(FarmEntity farm) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => FarmDetailsScreen(farm: farm)),
    );
  }
}

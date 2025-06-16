import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../farmer/domain/entities/farmer.dart';
import '../../../farmer/presentation/providers/farmer_provider.dart';
import '../../../farmer/presentation/screens/farmer_details_screen.dart';
import '../../../farmer/presentation/states/farmer_state.dart';

/// Professional cooperative farmers management screen following clean architecture
class CooperativeFarmersScreen extends ConsumerStatefulWidget {
  final String cooperativeId;

  const CooperativeFarmersScreen({super.key, required this.cooperativeId});

  @override
  ConsumerState<CooperativeFarmersScreen> createState() =>
      _CooperativeFarmersScreenState();
}

class _CooperativeFarmersScreenState
    extends ConsumerState<CooperativeFarmersScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load farmers using clean architecture with cooperative ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(farmerListProvider.notifier)
          .setCooperativeId(widget.cooperativeId);
      ref
          .read(farmerListProvider.notifier)
          .loadFarmers(cooperativeId: widget.cooperativeId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showSearchDelegate() async {
    final farmerState = ref.read(farmerListProvider);
    List<FarmerEntity> farmers = [];

    if (farmerState is FarmersLoaded) {
      farmers = farmerState.farmers;
    }

    final selectedFarmer = await showSearch<FarmerEntity?>(
      context: context,
      delegate: _FarmerSearchDelegate(farmers: farmers),
    );

    // Navigate to farmer details if a farmer was selected
    if (selectedFarmer != null) {
      _viewFarmerDetails(selectedFarmer);
    }
  }

  void _addNewFarmer() {
    // TODO: Navigate to add farmer screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Add farmer functionality coming soon',
          style: GoogleFonts.inter(fontSize: ResponsiveUtils.fontSize14),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewFarmerDetails(FarmerEntity farmer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FarmerDetailsScreen(
              farmerId: farmer.id,
              cooperativeId: widget.cooperativeId,
            ),
      ),
    ).then((result) {
      // Refresh the list if farmer was deleted
      if (result == true) {
        ref
            .read(farmerListProvider.notifier)
            .loadFarmers(cooperativeId: widget.cooperativeId);
      }
    });
  }

  void _deleteFarmer(FarmerEntity farmer) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Farmer',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Are you sure you want to delete ${farmer.name}? This action cannot be undone.',
              style: GoogleFonts.inter(fontSize: ResponsiveUtils.fontSize14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _performDelete(farmer);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Delete',
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

  void _performDelete(FarmerEntity farmer) {
    // Use clean architecture to delete farmer
    ref.read(farmerOperationsProvider.notifier).deleteFarmer(farmer.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${farmer.name} has been deleted',
          style: GoogleFonts.inter(fontSize: ResponsiveUtils.fontSize14),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Refresh the farmers list
    ref
        .read(farmerListProvider.notifier)
        .loadFarmers(cooperativeId: widget.cooperativeId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
              .read(farmerListProvider.notifier)
              .loadFarmers(cooperativeId: widget.cooperativeId);
        },
        child: _buildContent(theme),
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  /// Build shimmer effect for skeleton loading
  Widget _buildShimmerEffect(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                theme.colorScheme.onSurface.withValues(alpha: 0.05),
                theme.colorScheme.onSurface.withValues(alpha: 0.15),
                theme.colorScheme.onSurface.withValues(alpha: 0.05),
              ],
              stops: [0.0, value, 1.0],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }

  /// Build app bar with skeleton loading for dynamic content
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    // Watch farmer state to show dynamic count
    final farmerState = ref.watch(farmerListProvider);

    Widget titleWidget;

    // Show skeleton or actual content based on state
    if (farmerState is FarmerLoading) {
      // Skeleton loading for the title
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 16,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildShimmerEffect(theme),
          ),
          SizedBox(width: ResponsiveUtils.spacing8),
          Container(
            width: 80,
            height: 16,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildShimmerEffect(theme),
          ),
        ],
      );
    } else if (farmerState is FarmersLoaded) {
      titleWidget = Text(
        '${farmerState.farmers.length} Members',
        style: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.fontSize18,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      titleWidget = Text(
        'Cooperative Members',
        style: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.fontSize18,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return AppBar(
      title: titleWidget,
      centerTitle: false,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      actions: [
        IconButton(
          onPressed: _showSearchDelegate,
          icon: const Icon(Icons.search),
          tooltip: 'Search Farmers',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'refresh':
                ref
                    .read(farmerListProvider.notifier)
                    .loadFarmers(cooperativeId: widget.cooperativeId);
                break;
              case 'export':
                // TODO: Implement export functionality
                break;
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh,
                        size: ResponsiveUtils.iconSize20,
                        color: theme.colorScheme.onSurface,
                      ),
                      SizedBox(width: ResponsiveUtils.spacing12),
                      Text(
                        'Refresh',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize14,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(
                        Icons.download,
                        size: ResponsiveUtils.iconSize20,
                        color: theme.colorScheme.onSurface,
                      ),
                      SizedBox(width: ResponsiveUtils.spacing12),
                      Text(
                        'Export Data',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
          icon: const Icon(Icons.more_vert),
        ),
        SizedBox(width: ResponsiveUtils.spacing8),
      ],
    );
  }

  /// Build main content using clean architecture
  Widget _buildContent(ThemeData theme) {
    // Watch farmer state from provider
    final farmerState = ref.watch(farmerListProvider);

    // Only show main farmer content (no search bar functionality)
    return _buildFarmerContent(theme, farmerState);
  }

  /// Build farmer content based on state
  Widget _buildFarmerContent(ThemeData theme, FarmerState state) {
    if (state is FarmerLoading) {
      return _buildSkeletonLoader();
    } else if (state is FarmersLoaded) {
      if (state.farmers.isEmpty) {
        return _buildEmptyState(theme);
      }
      return _buildFarmersListFromEntities(theme, state.farmers);
    } else if (state is FarmerError) {
      return _buildErrorState(theme, state.message);
    }
    return _buildEmptyState(theme);
  }

  /// Build skeleton loader with shimmer effects
  Widget _buildSkeletonLoader() {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing12),
          padding: EdgeInsets.all(ResponsiveUtils.spacing16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar skeleton
                  Container(
                    width: ResponsiveUtils.iconSize48,
                    height: ResponsiveUtils.iconSize48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: _buildShimmerEffect(theme),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name skeleton
                        Container(
                          width: double.infinity,
                          height: ResponsiveUtils.height16,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.radius4,
                            ),
                          ),
                          child: _buildShimmerEffect(theme),
                        ),
                        SizedBox(height: ResponsiveUtils.height8),
                        // Location skeleton
                        Container(
                          width: ResponsiveUtils.screenWidth * 0.6,
                          height: ResponsiveUtils.height12,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.radius4,
                            ),
                          ),
                          child: _buildShimmerEffect(theme),
                        ),
                      ],
                    ),
                  ),
                  // Menu skeleton
                  Container(
                    width: ResponsiveUtils.iconSize20,
                    height: ResponsiveUtils.iconSize20,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius4,
                      ),
                    ),
                    child: _buildShimmerEffect(theme),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.height12),
              // Stats row skeleton
              Row(
                children: [
                  Container(
                    width: 80,
                    height: ResponsiveUtils.height12,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius4,
                      ),
                    ),
                    child: _buildShimmerEffect(theme),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing16),
                  Container(
                    width: 60,
                    height: ResponsiveUtils.height12,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius4,
                      ),
                    ),
                    child: _buildShimmerEffect(theme),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.height8),
              // Crops skeleton
              Row(
                children: [
                  Container(
                    width: 50,
                    height: ResponsiveUtils.height12,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius8,
                      ),
                    ),
                    child: _buildShimmerEffect(theme),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing8),
                  Container(
                    width: 40,
                    height: ResponsiveUtils.height12,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius8,
                      ),
                    ),
                    child: _buildShimmerEffect(theme),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build empty state
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.spacing24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.groups_outlined,
                size: ResponsiveUtils.iconSize64,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height24),
            Text(
              'No farmers yet',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height8),
            Text(
              'Start by adding your first farmer to the cooperative',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.height24),
            ElevatedButton.icon(
              onPressed: _addNewFarmer,
              icon: const Icon(Icons.add),
              label: Text(
                'Add First Farmer',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.spacing24,
                  vertical: ResponsiveUtils.spacing12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build farmers list from entities
  Widget _buildFarmersListFromEntities(
    ThemeData theme,
    List<FarmerEntity> farmers,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      itemCount: farmers.length,
      itemBuilder: (context, index) {
        final farmer = farmers[index];
        return _buildFarmerCardFromEntity(farmer, theme);
      },
    );
  }

  /// Build error state
  Widget _buildErrorState(ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.spacing24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: ResponsiveUtils.iconSize64,
                color: Colors.red,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height24),
            Text(
              'Error',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height8),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.height24),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(farmerListProvider.notifier)
                    .loadFarmers(cooperativeId: widget.cooperativeId);
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.spacing24,
                  vertical: ResponsiveUtils.spacing12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build farmer card from entity
  Widget _buildFarmerCardFromEntity(FarmerEntity farmer, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewFarmerDetails(farmer),
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: ResponsiveUtils.iconSize24,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      child: Text(
                        farmer.name.isNotEmpty
                            ? farmer.name[0].toUpperCase()
                            : 'F',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtils.fontSize16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing12),

                    // Name and details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farmer.name,
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtils.fontSize16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: ResponsiveUtils.height4),
                          Text(
                            '${farmer.zone} • ${farmer.village}',
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveUtils.fontSize13,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Actions menu
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'view':
                            _viewFarmerDetails(farmer);
                            break;
                          case 'delete':
                            _deleteFarmer(farmer);
                            break;
                        }
                      },
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    size: ResponsiveUtils.iconSize16,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  SizedBox(width: ResponsiveUtils.spacing8),
                                  Text(
                                    'View Details',
                                    style: GoogleFonts.inter(
                                      fontSize: ResponsiveUtils.fontSize14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: ResponsiveUtils.iconSize16,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: ResponsiveUtils.spacing8),
                                  Text(
                                    'Delete',
                                    style: GoogleFonts.inter(
                                      fontSize: ResponsiveUtils.fontSize14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                      icon: Icon(
                        Icons.more_vert,
                        size: ResponsiveUtils.iconSize20,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: ResponsiveUtils.height12),

                // Stats row
                Row(
                  children: [
                    _buildStatChip(
                      icon: Icons.phone,
                      label: farmer.phone,
                      theme: theme,
                    ),
                    SizedBox(width: ResponsiveUtils.spacing8),
                    _buildStatChip(
                      icon: Icons.park,
                      label: '${farmer.totalNumberOfTrees} trees',
                      theme: theme,
                    ),
                  ],
                ),

                SizedBox(height: ResponsiveUtils.height8),

                // Crops
                if (farmer.crops.isNotEmpty)
                  Wrap(
                    spacing: ResponsiveUtils.spacing4,
                    children:
                        farmer.crops.map<Widget>((crop) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.spacing8,
                              vertical: ResponsiveUtils.spacing4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
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
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build stat chip
  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing8,
        vertical: ResponsiveUtils.spacing4,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: ResponsiveUtils.iconSize12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          SizedBox(width: ResponsiveUtils.spacing4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Build floating action button - only show when farmers exist
  Widget? _buildFloatingActionButton(ThemeData theme) {
    // Watch farmer state to determine if FAB should be shown
    final farmerState = ref.watch(farmerListProvider);

    // Check if we have farmers to show FAB
    bool hasFarmers = false;

    // Check main farmer list
    if (farmerState is FarmersLoaded) {
      hasFarmers = farmerState.farmers.isNotEmpty;
    }

    // Only show FAB when farmers exist (empty state has its own add button)
    if (!hasFarmers) {
      return null;
    }

    return FloatingActionButton.extended(
      onPressed: _addNewFarmer,
      icon: const Icon(Icons.add),
      label: Text(
        'Add Farmer',
        style: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize14,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
    );
  }
}

/// Search delegate for farmers
class _FarmerSearchDelegate extends SearchDelegate<FarmerEntity?> {
  final List<FarmerEntity> farmers;

  _FarmerSearchDelegate({required this.farmers});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredFarmers =
        farmers.where((farmer) {
          return farmer.name.toLowerCase().contains(query.toLowerCase()) ||
              farmer.zone.toLowerCase().contains(query.toLowerCase()) ||
              farmer.village.toLowerCase().contains(query.toLowerCase()) ||
              farmer.phone.contains(query);
        }).toList();

    if (filteredFarmers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: ResponsiveUtils.iconSize64,
              color: Colors.grey,
            ),
            SizedBox(height: ResponsiveUtils.height16),
            Text(
              'No farmers found',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      itemCount: filteredFarmers.length,
      itemBuilder: (context, index) {
        final farmer = filteredFarmers[index];
        return Container(
          margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing16),
            leading: Container(
              width: ResponsiveUtils.iconSize48,
              height: ResponsiveUtils.iconSize48,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  farmer.name.isNotEmpty ? farmer.name[0].toUpperCase() : 'F',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            title: Text(
              farmer.name,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ResponsiveUtils.height4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: ResponsiveUtils.iconSize16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing4),
                    Text(
                      '${farmer.zone} • ${farmer.village}',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                if (farmer.phone.isNotEmpty) ...[
                  SizedBox(height: ResponsiveUtils.height4),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: ResponsiveUtils.iconSize16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      SizedBox(width: ResponsiveUtils.spacing4),
                      Text(
                        farmer.phone,
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: ResponsiveUtils.iconSize16,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            onTap: () {
              close(context, farmer);
            },
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/farmer.dart';
import '../../data/repositories/farmer_repository_impl.dart';

/// Professional farmer details screen with beautiful animations and modern design
class FarmerDetailsScreen extends ConsumerStatefulWidget {
  final String farmerId;
  final String cooperativeId;

  const FarmerDetailsScreen({
    super.key,
    required this.farmerId,
    required this.cooperativeId,
  });

  @override
  ConsumerState<FarmerDetailsScreen> createState() =>
      _FarmerDetailsScreenState();
}

class _FarmerDetailsScreenState extends ConsumerState<FarmerDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isLoading = true;
  FarmerEntity? _farmer;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _loadFarmerDetails();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  /// Load farmer details
  Future<void> _loadFarmerDetails() async {
    try {
      setState(() => _isLoading = true);

      // Get farmer by ID using the repository
      final repository = ref.read(farmerRepositoryProvider);
      final farmer = await repository.getFarmerById(widget.farmerId);

      setState(() {
        _farmer = farmer;
        _isLoading = false;
      });

      // Start animations when data is loaded
      if (_farmer != null) {
        _fadeController.forward();
        await Future.delayed(const Duration(milliseconds: 200));
        _slideController.forward();
        await Future.delayed(const Duration(milliseconds: 100));
        _scaleController.forward();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading farmer details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Edit farmer
  void _editFarmer() {
    // TODO: Navigate to edit farmer screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit farmer functionality coming soon',
          style: GoogleFonts.inter(fontSize: ResponsiveUtils.fontSize14),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Delete farmer
  void _deleteFarmer() {
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
              'Are you sure you want to delete ${_farmer?.name}? This action cannot be undone.',
              style: GoogleFonts.inter(fontSize: ResponsiveUtils.fontSize14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performDelete();
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

  /// Perform delete operation
  Future<void> _performDelete() async {
    try {
      final repository = ref.read(farmerRepositoryProvider);
      await repository.deleteFarmer(widget.farmerId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_farmer?.name} has been deleted',
              style: GoogleFonts.inter(fontSize: ResponsiveUtils.fontSize14),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate deletion
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting farmer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body:
          _isLoading
              ? _buildLoadingState(theme)
              : _farmer == null
              ? _buildErrorState(theme)
              : _buildContent(theme),
    );
  }

  /// Build loading state with skeleton and shimmer effects
  Widget _buildLoadingState(ThemeData theme) {
    return CustomScrollView(
      slivers: [
        _buildSkeletonAppBar(theme),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            child: Column(
              children: [
                _buildSkeletonHeroCard(theme),
                SizedBox(height: ResponsiveUtils.height24),
                _buildSkeletonStatsGrid(theme),
                SizedBox(height: ResponsiveUtils.height24),
                _buildSkeletonInfoSections(theme),
              ],
            ),
          ),
        ),
      ],
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

  /// Build skeleton app bar
  Widget _buildSkeletonAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 0,
      title: Container(
        width: 120,
        height: 16,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _buildShimmerEffect(theme),
      ),
    );
  }

  /// Build skeleton hero card
  Widget _buildSkeletonHeroCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.spacing32),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar skeleton
          Container(
            width: ResponsiveUtils.iconSize120,
            height: ResponsiveUtils.iconSize120,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: _buildShimmerEffect(theme),
          ),
          SizedBox(height: ResponsiveUtils.height20),
          // Name skeleton
          Container(
            width: 200,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildShimmerEffect(theme),
          ),
          SizedBox(height: ResponsiveUtils.height8),
          // Location skeleton
          Container(
            width: 150,
            height: 16,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildShimmerEffect(theme),
          ),
          SizedBox(height: ResponsiveUtils.height16),
          // Status badge skeleton
          Container(
            width: 120,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius20),
            ),
            child: _buildShimmerEffect(theme),
          ),
        ],
      ),
    );
  }

  /// Build skeleton stats grid
  Widget _buildSkeletonStatsGrid(ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: ResponsiveUtils.spacing16,
      crossAxisSpacing: ResponsiveUtils.spacing16,
      childAspectRatio: 1.0,
      children: List.generate(4, (index) => _buildSkeletonStatCard(theme)),
    );
  }

  /// Build skeleton stat card
  Widget _buildSkeletonStatCard(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon skeleton
          Container(
            width: ResponsiveUtils.iconSize56,
            height: ResponsiveUtils.iconSize56,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: _buildShimmerEffect(theme),
          ),
          SizedBox(height: ResponsiveUtils.height12),
          // Value skeleton
          Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildShimmerEffect(theme),
          ),
          SizedBox(height: ResponsiveUtils.height4),
          // Title skeleton
          Container(
            width: 80,
            height: 14,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildShimmerEffect(theme),
          ),
        ],
      ),
    );
  }

  /// Build skeleton info sections
  Widget _buildSkeletonInfoSections(ThemeData theme) {
    return Column(
      children: [
        _buildSkeletonInfoCard(theme, 'Personal Information'),
        SizedBox(height: ResponsiveUtils.height20),
        _buildSkeletonInfoCard(theme, 'Location & Contact'),
        SizedBox(height: ResponsiveUtils.height20),
        _buildSkeletonInfoCard(theme, 'Farming Details'),
        SizedBox(height: ResponsiveUtils.height20),
        _buildSkeletonInfoCard(theme, 'Banking Information'),
      ],
    );
  }

  /// Build skeleton info card
  Widget _buildSkeletonInfoCard(ThemeData theme, String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title skeleton
          Row(
            children: [
              Container(
                width: ResponsiveUtils.iconSize24,
                height: ResponsiveUtils.iconSize24,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _buildShimmerEffect(theme),
              ),
              SizedBox(width: ResponsiveUtils.spacing12),
              Container(
                width: 150,
                height: 18,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildShimmerEffect(theme),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.height16),
          // Info rows skeleton
          ...List.generate(3, (index) => _buildSkeletonInfoRow(theme)),
        ],
      ),
    );
  }

  /// Build skeleton info row
  Widget _buildSkeletonInfoRow(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.spacing12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label skeleton
          Container(
            width: 100,
            height: 14,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildShimmerEffect(theme),
          ),
          SizedBox(width: ResponsiveUtils.spacing16),
          // Value skeleton
          Expanded(
            child: Container(
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildShimmerEffect(theme),
            ),
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(ThemeData theme) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(theme),
        SliverFillRemaining(
          child: Center(
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
                  'Farmer Not Found',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize20,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.height8),
                Text(
                  'The farmer you are looking for could not be found.',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUtils.height24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(
                    'Go Back',
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
        ),
      ],
    );
  }

  /// Build main content
  Widget _buildContent(ThemeData theme) {
    return CustomScrollView(
      slivers: [_buildAppBar(theme), _buildAnimatedContent(theme)],
    );
  }

  /// Build animated content
  Widget _buildAnimatedContent(ThemeData theme) {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing16),
              child: Column(
                children: [
                  _buildHeroCard(theme),
                  SizedBox(height: ResponsiveUtils.height24),
                  _buildStatsGrid(theme),
                  SizedBox(height: ResponsiveUtils.height24),
                  _buildInfoSections(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build app bar
  Widget _buildAppBar(ThemeData theme, {bool isLoading = false}) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 0,
      title: Text(
        isLoading ? 'Loading...' : _getFirstNameWithDetails(_farmer?.name),
        style: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.fontSize18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions:
          isLoading || _farmer == null
              ? null
              : [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editFarmer();
                        break;
                      case 'delete':
                        _deleteFarmer();
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.primary,
                                size: ResponsiveUtils.iconSize20,
                              ),
                              SizedBox(width: ResponsiveUtils.spacing8),
                              Text(
                                'Edit Farmer',
                                style: GoogleFonts.inter(
                                  fontSize: ResponsiveUtils.fontSize14,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
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
                                color: Colors.red,
                                size: ResponsiveUtils.iconSize20,
                              ),
                              SizedBox(width: ResponsiveUtils.spacing8),
                              Text(
                                'Delete Farmer',
                                style: GoogleFonts.inter(
                                  fontSize: ResponsiveUtils.fontSize14,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
    );
  }

  /// Build hero card with farmer profile
  Widget _buildHeroCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.spacing32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Large avatar with glow effect
          Container(
            width: ResponsiveUtils.iconSize120,
            height: ResponsiveUtils.iconSize120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _farmer!.name.isNotEmpty ? _farmer!.name[0].toUpperCase() : 'F',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize48,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveUtils.height20),
          // Farmer name
          Text(
            _farmer!.name,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.height8),
          // Location with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white.withValues(alpha: 0.9),
                size: ResponsiveUtils.iconSize20,
              ),
              SizedBox(width: ResponsiveUtils.spacing8),
              Text(
                '${_farmer!.zone} • ${_farmer!.village}',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.height16),
          // Status badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing16,
              vertical: ResponsiveUtils.spacing8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Text(
                  'Active Member',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build stats grid
  Widget _buildStatsGrid(ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: ResponsiveUtils.spacing16,
      crossAxisSpacing: ResponsiveUtils.spacing16,
      childAspectRatio: 1.0,
      children: [
        _buildAnimatedStatCard(
          theme,
          icon: Icons.park,
          title: 'Total Trees',
          value: _farmer!.totalNumberOfTrees.toString(),
          color: const Color(0xFF4CAF50),
          delay: 0,
        ),
        _buildAnimatedStatCard(
          theme,
          icon: Icons.eco,
          title: 'Fruiting Trees',
          value: _farmer!.totalNumberOfTreesWithFruit.toString(),
          color: const Color(0xFFFF9800),
          delay: 100,
        ),
        _buildAnimatedStatCard(
          theme,
          icon: Icons.agriculture,
          title: 'Crops',
          value: _farmer!.crops.length.toString(),
          color: const Color(0xFF2196F3),
          delay: 200,
        ),
        _buildAnimatedStatCard(
          theme,
          icon: Icons.trending_up,
          title: 'Productivity',
          value:
              '${((_farmer!.totalNumberOfTreesWithFruit / _farmer!.totalNumberOfTrees) * 100).toStringAsFixed(0)}%',
          color: const Color(0xFF9C27B0),
          delay: 300,
        ),
      ],
    );
  }

  /// Build animated stat card
  Widget _buildAnimatedStatCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius20),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: ResponsiveUtils.iconSize32,
                    color: color,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.height12),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize24,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.height4),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build info sections
  Widget _buildInfoSections(ThemeData theme) {
    return Column(
      children: [
        _buildInfoCard(
          theme,
          title: 'Personal Information',
          icon: Icons.person,
          children: [
            _buildInfoRow(theme, 'Full Name', _farmer!.name),
            _buildInfoRow(theme, 'Gender', _farmer!.gender.value),
            _buildInfoRow(
              theme,
              'Date of Birth',
              _formatDate(_farmer!.dateOfBirth),
            ),
            _buildInfoRow(
              theme,
              'Age',
              _calculateAge(_farmer!.dateOfBirth).toString(),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.height20),
        _buildInfoCard(
          theme,
          title: 'Location & Contact',
          icon: Icons.location_on,
          children: [
            _buildInfoRow(theme, 'Zone', _farmer!.zone),
            _buildInfoRow(theme, 'Village', _farmer!.village),
            _buildInfoRow(
              theme,
              'Phone',
              _farmer!.phone.isNotEmpty ? _farmer!.phone : 'Not provided',
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.height20),
        _buildInfoCard(
          theme,
          title: 'Farming Details',
          icon: Icons.agriculture,
          children: [
            _buildInfoRow(
              theme,
              'Total Trees',
              _farmer!.totalNumberOfTrees.toString(),
            ),
            _buildInfoRow(
              theme,
              'Fruiting Trees',
              _farmer!.totalNumberOfTreesWithFruit.toString(),
            ),
            _buildInfoRow(
              theme,
              'Non-Fruiting Trees',
              (_farmer!.totalNumberOfTrees -
                      _farmer!.totalNumberOfTreesWithFruit)
                  .toString(),
            ),
            _buildCropsSection(theme),
          ],
        ),
        SizedBox(height: ResponsiveUtils.height20),
        _buildInfoCard(
          theme,
          title: 'Banking Information',
          icon: Icons.account_balance,
          children: [
            _buildInfoRow(
              theme,
              'Bank Name',
              _farmer!.bankName.isNotEmpty ? _farmer!.bankName : 'Not provided',
            ),
            _buildInfoRow(
              theme,
              'Account Number',
              _farmer!.bankNumber.isNotEmpty
                  ? _farmer!.bankNumber
                  : 'Not provided',
            ),
          ],
        ),
      ],
    );
  }

  /// Build info card
  Widget _buildInfoCard(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.spacing24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
                ),
                child: Icon(
                  icon,
                  size: ResponsiveUtils.iconSize24,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize20,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.height20),
          ...children,
        ],
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.spacing16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build crops section
  Widget _buildCropsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crops Grown',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: ResponsiveUtils.height8),
        Wrap(
          spacing: ResponsiveUtils.spacing8,
          runSpacing: ResponsiveUtils.spacing8,
          children:
              _farmer!.crops.map((crop) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacing12,
                    vertical: ResponsiveUtils.spacing6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                        theme.colorScheme.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius16,
                    ),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    crop,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// Get first name with "Details" appended
  String _getFirstNameWithDetails(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Farmer Details';
    final firstName = fullName.split(' ').first;
    return '$firstName Details';
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Calculate age from date of birth
  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}

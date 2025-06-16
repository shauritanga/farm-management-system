import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../l10n/generated/app_localizations.dart';

class FarmerMarketplaceScreen extends ConsumerStatefulWidget {
  const FarmerMarketplaceScreen({super.key});

  @override
  ConsumerState<FarmerMarketplaceScreen> createState() =>
      _FarmerMarketplaceScreenState();
}

class _FarmerMarketplaceScreenState
    extends ConsumerState<FarmerMarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mode state - true for Buy, false for Sell
  bool _isBuyMode = true;

  // Filter state variables (only for buy mode)
  String _selectedCategory = 'All';
  String _selectedLocation = 'All Locations';
  String _sortBy = 'Recent';
  RangeValues _priceRange = const RangeValues(0, 1000000);
  double _maxDistance = 50.0;
  double _minRating = 0.0;
  bool _showOnlyInStock = false;

  // Sell mode state
  final List<Map<String, dynamic>> _myListings = [];

  final List<String> _categories = [
    'All',
    'Products',
    'Seeds & Inputs',
    'Equipment',
    'Livestock',
    'Services',
  ];

  final List<String> _locations = [
    'All Locations',
    'Dar es Salaam',
    'Arusha',
    'Mwanza',
    'Dodoma',
    'Mbeya',
    'Morogoro',
  ];

  final List<String> _sortOptions = [
    'Recent',
    'Price: Low to High',
    'Price: High to Low',
    'Distance',
    'Rating',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          // Search and filters section (only in buy mode)
          if (_isBuyMode) _buildSearchAndFilters(theme),

          // Main content
          Expanded(
            child: _isBuyMode ? _buildBuyTab(theme) : _buildSellTab(theme),
          ),
        ],
      ),
      floatingActionButton:
          _shouldShowFloatingActionButton()
              ? _buildFloatingActionButton(theme)
              : null,
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        _isBuyMode
            ? AppLocalizations.of(context).browseProducts
            : AppLocalizations.of(context).myStore,
        style: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.fontSize20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showNotifications(),
          icon: Stack(
            children: [
              Icon(
                HugeIcons.strokeRoundedNotification03,
                size: ResponsiveUtils.iconSize24,
                color: Colors.white,
              ),
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
        // Cart icon only visible in buy mode
        if (_isBuyMode)
          IconButton(
            onPressed: () => _showCart(),
            icon: Stack(
              children: [
                Icon(
                  HugeIcons.strokeRoundedShoppingCart01,
                  size: ResponsiveUtils.iconSize24,
                  color: Colors.white,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveUtils.spacing2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '3',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Popup menu to switch between Buy/Sell
        PopupMenuButton<String>(
          onSelected: (value) => _onViewSelected(value),
          icon: Icon(
            Icons.more_vert,
            color: Colors.white,
            size: ResponsiveUtils.iconSize24,
          ),
          itemBuilder:
              (context) => [
                PopupMenuItem<String>(
                  value: 'buy',
                  child: Row(
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedShoppingBag01,
                        size: ResponsiveUtils.iconSize20,
                        color:
                            _isBuyMode
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                      ),
                      SizedBox(width: ResponsiveUtils.spacing12),
                      Text(
                        AppLocalizations.of(context).buy,
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize16,
                          fontWeight:
                              _isBuyMode ? FontWeight.w600 : FontWeight.w500,
                          color:
                              _isBuyMode
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (_isBuyMode) ...[
                        const Spacer(),
                        Icon(
                          Icons.check,
                          size: ResponsiveUtils.iconSize16,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'sell',
                  child: Row(
                    children: [
                      Icon(
                        Icons.sell,
                        size: ResponsiveUtils.iconSize20,
                        color:
                            !_isBuyMode
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                      ),
                      SizedBox(width: ResponsiveUtils.spacing12),
                      Text(
                        AppLocalizations.of(context).sell,
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize16,
                          fontWeight:
                              !_isBuyMode ? FontWeight.w600 : FontWeight.w500,
                          color:
                              !_isBuyMode
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (!_isBuyMode) ...[
                        const Spacer(),
                        Icon(
                          Icons.check,
                          size: ResponsiveUtils.iconSize16,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
        ),
        SizedBox(width: ResponsiveUtils.spacing8),
      ],
    );
  }

  /// Build search and filters section
  Widget _buildSearchAndFilters(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
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
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products, equipment, services...',
                hintStyle: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  HugeIcons.strokeRoundedSearch01,
                  size: ResponsiveUtils.iconSize20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                suffixIcon: IconButton(
                  onPressed: () => _showAdvancedFilters(),
                  icon: Icon(
                    HugeIcons.strokeRoundedFilterHorizontal,
                    size: ResponsiveUtils.iconSize20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.spacing16,
                  vertical: ResponsiveUtils.spacing12,
                ),
              ),
              onChanged: (value) => _onSearchChanged(value),
            ),
          ),

          // SizedBox(height: ResponsiveUtils.height),
        ],
      ),
    );
  }

  /// Build buy tab content
  Widget _buildBuyTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        slivers: [
          // Featured products section
          SliverToBoxAdapter(child: _buildFeaturedSection(theme)),

          // Categories grid
          SliverToBoxAdapter(child: _buildCategoriesGrid(theme)),

          // Products list
          SliverPadding(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildProductCard(theme, _getSampleProducts()[index]),
                childCount: _getSampleProducts().length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build sell tab content
  Widget _buildSellTab(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      child: _buildMyListings(theme),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => _createNewListing(),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      icon: Icon(Icons.add, size: ResponsiveUtils.iconSize20),
      label: Text(
        AppLocalizations.of(context).sellItem,
        style: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Handle refresh
  Future<void> _handleRefresh() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Show notifications
  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications feature coming soon')),
    );
  }

  /// Show cart
  void _showCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shopping cart feature coming soon')),
    );
  }

  /// Clear all filters
  void _clearAllFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedLocation = 'All Locations';
      _sortBy = 'Recent';
      _priceRange = const RangeValues(0, 1000000);
      _maxDistance = 50.0;
      _minRating = 0.0;
      _showOnlyInStock = false;
    });
  }

  /// Show advanced filters
  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAdvancedFiltersBottomSheet(),
    );
  }

  /// Build advanced filters bottom sheet
  Widget _buildAdvancedFiltersBottomSheet() {
    final theme = Theme.of(context);

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveUtils.radius20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: ResponsiveUtils.spacing8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(ResponsiveUtils.spacing16),
                child: Row(
                  children: [
                    Text(
                      'Advanced Filters',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.fontSize20,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _clearAllFilters();
                        setModalState(() {});
                      },
                      child: Text(
                        'Clear All',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize14,
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filters content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacing16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryFilter(theme, setModalState),
                      SizedBox(height: ResponsiveUtils.height24),
                      _buildLocationFilter(theme, setModalState),
                      SizedBox(height: ResponsiveUtils.height24),
                      _buildPriceRangeFilter(theme, setModalState),
                      SizedBox(height: ResponsiveUtils.height24),
                      _buildDistanceFilter(theme, setModalState),
                      SizedBox(height: ResponsiveUtils.height24),
                      _buildRatingFilter(theme, setModalState),
                      SizedBox(height: ResponsiveUtils.height24),
                      _buildStockFilter(theme, setModalState),
                      SizedBox(height: ResponsiveUtils.height24),
                      _buildSortFilter(theme, setModalState),
                      SizedBox(height: ResponsiveUtils.height32),
                    ],
                  ),
                ),
              ),

              // Apply button
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.spacing16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.radius12,
                        ),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Handle search change
  void _onSearchChanged(String value) {
    // Implement search logic
    // TODO: Add search functionality
  }

  /// Create new listing
  void _createNewListing() {
    // For demo purposes, add a sample listing
    setState(() {
      _myListings.add({
        'name': 'Sample Product ${_myListings.length + 1}',
        'price': 'TSh ${(10000 + _myListings.length * 5000)}',
        'image': ['🌱', '🧪', '💧', '🍅', '🚜'][_myListings.length % 5],
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listing added successfully!')),
    );
  }

  /// Build featured section
  Widget _buildFeaturedSection(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple header
          Row(
            children: [
              Text(
                'Featured',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.fontSize18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _viewAllFeatured(),
                child: Text(
                  AppLocalizations.of(context).viewAll,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.height12),

          // Simple products carousel
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _getFeaturedProducts().length,
              itemBuilder: (context, index) => _buildFeaturedCard(theme, index),
            ),
          ),
        ],
      ),
    );
  }

  /// Build featured card
  Widget _buildFeaturedCard(ThemeData theme, int index) {
    final products = _getFeaturedProducts();
    final product = products[index];

    return Container(
      width: 130,
      margin: EdgeInsets.only(right: ResponsiveUtils.spacing16),
      child: Column(
        children: [
          // Attractive product image with gradient
          Container(
            height: 110,
            width: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  product['color'].withValues(alpha: 0.8),
                  product['color'].withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
              boxShadow: [
                BoxShadow(
                  color: product['color'].withValues(alpha: 0.3),
                  blurRadius: ResponsiveUtils.spacing8,
                  offset: Offset(0, ResponsiveUtils.spacing4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Subtle pattern overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius16,
                      ),
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                        center: Alignment.topRight,
                        radius: 1.2,
                      ),
                    ),
                  ),
                ),

                // Product emoji
                Center(
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      product['image']!,
                      style: TextStyle(fontSize: ResponsiveUtils.fontSize28),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveUtils.height12),

          // Product name
          Text(
            product['name']!,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: ResponsiveUtils.height4),

          // Price with attractive styling
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing8,
              vertical: ResponsiveUtils.spacing4,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Text(
              product['price']!,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize12,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build categories grid
  Widget _buildCategoriesGrid(ThemeData theme) {
    final categories = [
      {'name': 'Seeds & Inputs', 'icon': '🌱', 'count': '120+'},
      {'name': 'Equipment', 'icon': '🚜', 'count': '85+'},
      {'name': 'Fresh Produce', 'icon': '🍅', 'count': '200+'},
      {'name': 'Livestock', 'icon': '🐄', 'count': '45+'},
    ];

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: ResponsiveUtils.spacing12,
              mainAxisSpacing: ResponsiveUtils.spacing12,
              childAspectRatio: 2.5,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                  child: Row(
                    children: [
                      Text(
                        category['icon']!,
                        style: TextStyle(fontSize: ResponsiveUtils.fontSize24),
                      ),
                      SizedBox(width: ResponsiveUtils.spacing8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category['name']!,
                              style: GoogleFonts.inter(
                                fontSize: ResponsiveUtils.fontSize12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${category['count']} items',
                              style: GoogleFonts.inter(
                                fontSize: ResponsiveUtils.fontSize10,
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Get sample products
  List<Map<String, dynamic>> _getSampleProducts() {
    return [
      {
        'name': 'Premium Maize Seeds',
        'price': 'TSh 25,000',
        'seller': 'AgriSeeds Ltd',
        'location': 'Arusha',
        'rating': 4.8,
        'image': '🌽',
        'category': 'Seeds',
      },
      {
        'name': 'Organic Fertilizer',
        'price': 'TSh 45,000',
        'seller': 'GreenGrow Co.',
        'location': 'Dar es Salaam',
        'rating': 4.6,
        'image': '🧪',
        'category': 'Inputs',
      },
      {
        'name': 'Tractor Rental Service',
        'price': 'TSh 80,000/day',
        'seller': 'FarmTech Services',
        'location': 'Mwanza',
        'rating': 4.9,
        'image': '🚜',
        'category': 'Equipment',
      },
    ];
  }

  /// Build product card
  Widget _buildProductCard(ThemeData theme, Map<String, dynamic> product) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: ResponsiveUtils.spacing8,
            offset: Offset(0, ResponsiveUtils.spacing2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
              ),
              child: Center(
                child: Text(
                  product['image'],
                  style: TextStyle(fontSize: ResponsiveUtils.fontSize32),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.height4),
                  Text(
                    product['price'],
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.height4),
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        size: ResponsiveUtils.iconSize12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.spacing4),
                      Text(
                        product['seller'],
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize12,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build my listings
  Widget _buildMyListings(ThemeData theme) {
    if (_myListings.isEmpty) {
      // Empty state with prominent Add Listing button
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: ResponsiveUtils.iconSize64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: ResponsiveUtils.height16),
            Text(
              AppLocalizations.of(context).noListingsYet,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: ResponsiveUtils.height8),
            Text(
              AppLocalizations.of(context).startSelling,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.height24),
            ElevatedButton.icon(
              onPressed: () => _createNewListing(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.spacing24,
                  vertical: ResponsiveUtils.spacing12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
                ),
              ),
              icon: Icon(Icons.add, size: ResponsiveUtils.iconSize20),
              label: Text(
                AppLocalizations.of(context).addListing,
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show actual listings when available
    return ListView.builder(
      itemCount: _myListings.length,
      itemBuilder: (context, index) {
        final listing = _myListings[index];
        return Container(
          margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing12),
          padding: EdgeInsets.all(ResponsiveUtils.spacing16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
                ),
                child: Center(
                  child: Text(
                    listing['image'],
                    style: TextStyle(fontSize: ResponsiveUtils.fontSize24),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing['name'],
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      listing['price'],
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _editListing(index),
                icon: Icon(
                  Icons.edit,
                  size: ResponsiveUtils.iconSize20,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build category filter
  Widget _buildCategoryFilter(ThemeData theme, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height8),
        Wrap(
          spacing: ResponsiveUtils.spacing8,
          runSpacing: ResponsiveUtils.spacing8,
          children:
              _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setModalState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.spacing12,
                      vertical: ResponsiveUtils.spacing8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius20,
                      ),
                      border: Border.all(
                        color:
                            isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                      ),
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize14,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// Build location filter
  Widget _buildLocationFilter(ThemeData theme, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.spacing12),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLocation,
              isExpanded: true,
              items:
                  _locations.map((location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(
                        location,
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize14,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setModalState(() {
                    _selectedLocation = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Build price range filter
  Widget _buildPriceRangeFilter(ThemeData theme, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range (TSh)',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height8),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 1000000,
          divisions: 20,
          labels: RangeLabels(
            'TSh ${_priceRange.start.round()}',
            'TSh ${_priceRange.end.round()}',
          ),
          onChanged: (values) {
            setModalState(() {
              _priceRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TSh ${_priceRange.start.round()}',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              'TSh ${_priceRange.end.round()}',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build distance filter
  Widget _buildDistanceFilter(ThemeData theme, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum Distance (km)',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height8),
        Slider(
          value: _maxDistance,
          min: 1,
          max: 100,
          divisions: 99,
          label: '${_maxDistance.round()} km',
          onChanged: (value) {
            setModalState(() {
              _maxDistance = value;
            });
          },
        ),
        Text(
          '${_maxDistance.round()} km',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  /// Build rating filter
  Widget _buildRatingFilter(ThemeData theme, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Rating',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height8),
        Row(
          children: List.generate(5, (index) {
            final rating = index + 1;
            final isSelected = _minRating >= rating;
            return GestureDetector(
              onTap: () {
                setModalState(() {
                  _minRating = rating.toDouble();
                });
              },
              child: Padding(
                padding: EdgeInsets.only(right: ResponsiveUtils.spacing4),
                child: Icon(
                  isSelected ? Icons.star : Icons.star_border,
                  color:
                      isSelected
                          ? Colors.amber
                          : theme.colorScheme.outline.withValues(alpha: 0.5),
                  size: ResponsiveUtils.iconSize24,
                ),
              ),
            );
          }),
        ),
        SizedBox(height: ResponsiveUtils.height4),
        Text(
          _minRating > 0
              ? '${_minRating.round()} stars and above'
              : 'Any rating',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  /// Build stock filter
  Widget _buildStockFilter(ThemeData theme, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height8),
        Row(
          children: [
            Checkbox(
              value: _showOnlyInStock,
              onChanged: (value) {
                setModalState(() {
                  _showOnlyInStock = value ?? false;
                });
              },
            ),
            Text(
              'Show only items in stock',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build sort filter
  Widget _buildSortFilter(ThemeData theme, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.spacing12),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sortBy,
              isExpanded: true,
              items:
                  _sortOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(
                        option,
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize14,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setModalState(() {
                    _sortBy = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Get featured products data
  List<Map<String, dynamic>> _getFeaturedProducts() {
    return [
      {
        'name': 'Premium Seeds',
        'price': 'TSh 25,000',
        'image': '🌱',
        'color': const Color(0xFF4CAF50),
      },
      {
        'name': 'Fertilizer',
        'price': 'TSh 45,000',
        'image': '🧪',
        'color': const Color(0xFF2196F3),
      },
      {
        'name': 'Irrigation Kit',
        'price': 'TSh 120,000',
        'image': '💧',
        'color': const Color(0xFF00BCD4),
      },
      {
        'name': 'Fresh Tomatoes',
        'price': 'TSh 3,500/kg',
        'image': '🍅',
        'color': const Color(0xFFFF5722),
      },
      {
        'name': 'Tractor Rental',
        'price': 'TSh 80,000/day',
        'image': '🚜',
        'color': const Color(0xFFFF9800),
      },
    ];
  }

  /// View all featured products
  void _viewAllFeatured() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('View all featured products coming soon')),
    );
  }

  /// Check if floating action button should be shown
  bool _shouldShowFloatingActionButton() {
    return !_isBuyMode && _myListings.isNotEmpty;
  }

  /// Handle view selection from popup menu
  void _onViewSelected(String value) {
    setState(() {
      _isBuyMode = value == 'buy';
    });
  }

  /// Edit listing
  void _editListing(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit listing feature coming soon')),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../auth/presentation/providers/mobile_auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';
import '../../sales/domain/entities/sale_core.dart';
import '../../sales/presentation/providers/sales_provider.dart';
import '../../sales/presentation/states/sales_state.dart';
import '../widgets/add_sale_modal.dart';
import '../widgets/edit_sale_modal.dart';
import '../providers/recent_activities_provider.dart';
import '../providers/recent_sales_provider.dart';

/// Professional cooperative sales management screen
class CooperativeSalesScreen extends ConsumerStatefulWidget {
  const CooperativeSalesScreen({super.key});

  @override
  ConsumerState<CooperativeSalesScreen> createState() =>
      _CooperativeSalesScreenState();
}

class _CooperativeSalesScreenState
    extends ConsumerState<CooperativeSalesScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _cooperativeId;

  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  DateTimeRange? _dateRange;
  double? _minAmount;
  double? _maxAmount;
  String? _selectedFarmer;
  String? _selectedProduct;
  List<SaleCoreEntity> _filteredSales = [];
  Timer? _searchDebounceTimer;

  // Cache for farmer names to avoid repeated Firestore queries
  final Map<String, String> _farmerNameCache = {};

  // Cache for product names to avoid repeated Firestore queries
  final Map<String, String> _productNameCache = {};

  @override
  void initState() {
    super.initState();
    // No tabs needed anymore - just sales list

    // Load sales data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSalesForCurrentUser();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _loadSalesForCurrentUser() {
    final authState = ref.read(mobileAuthProvider);
    if (authState is AuthAuthenticated) {
      print('DEBUG: User data: ${authState.user}');
      print('DEBUG: Cooperative ID: ${authState.user.cooperativeId}');
      final cooperativeId = authState.user.cooperativeId;
      if (cooperativeId != null && cooperativeId.isNotEmpty) {
        setState(() {
          _cooperativeId = cooperativeId;
        });
        ref.read(salesListProvider.notifier).setCooperativeId(cooperativeId);
        ref
            .read(salesListProvider.notifier)
            .loadSales(cooperativeId: cooperativeId);
        // Clear caches when loading new data
        _farmerNameCache.clear();
        _productNameCache.clear();
      } else {
        setState(() {
          _cooperativeId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(mobileAuthProvider);

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          _buildSearchAndFilters(theme),
          Expanded(child: _buildSalesListTab(theme)),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text(
        'Sales Management',
        style: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.fontSize20,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
          onPressed: () {
            if (_cooperativeId != null) {
              // Clear caches before refreshing
              _farmerNameCache.clear();
              _productNameCache.clear();
              ref.read(salesListProvider.notifier).refreshSales();
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
          onPressed: () => _showMoreOptions(theme),
        ),
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search sales...',
              prefixIcon: Icon(
                Icons.search,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            onChanged: _onSearchChanged,
          ),
          SizedBox(height: ResponsiveUtils.spacing12),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', theme),
                SizedBox(width: ResponsiveUtils.spacing8),
                _buildFilterChip('Today', theme),
                SizedBox(width: ResponsiveUtils.spacing8),
                _buildFilterChip('This Week', theme),
                SizedBox(width: ResponsiveUtils.spacing8),
                _buildFilterChip('This Month', theme),
                SizedBox(width: ResponsiveUtils.spacing8),
                _buildFilterChip('High Value', theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter chip
  Widget _buildFilterChip(String label, ThemeData theme) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color:
              isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        _onFilterSelected(selected ? label : 'All');
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: theme.colorScheme.onPrimary,
      side: BorderSide(
        color:
            isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
      ),
    );
  }

  /// Build sales list tab
  Widget _buildSalesListTab(ThemeData theme) {
    final salesState = ref.watch(salesListProvider);

    return RefreshIndicator(
      onRefresh: () async {
        if (_cooperativeId != null) {
          // Clear caches before refreshing
          _farmerNameCache.clear();
          _productNameCache.clear();
          ref.read(salesListProvider.notifier).refreshSales();
        }
      },
      child: _buildSalesStateWidget(salesState, theme),
    );
  }

  /// Build sales state widget
  Widget _buildSalesStateWidget(SalesState salesState, ThemeData theme) {
    if (salesState is SalesInitial) {
      return _buildEmptyState(theme, 'No sales data available');
    } else if (salesState is SalesLoading) {
      return _buildLoadingState(theme);
    } else if (salesState is SalesLoaded) {
      // Populate caches in background (don't block UI)
      _populateCaches(salesState.sales);

      // Use filtered sales if filters are applied, otherwise use all sales
      final salesToShow =
          _hasActiveFilters() ? _filteredSales : salesState.sales;

      return _buildSalesList(salesToShow, theme);
    } else if (salesState is SalesError) {
      return _buildErrorState(theme, salesState.message);
    } else {
      return _buildEmptyState(theme, 'No sales data available');
    }
  }

  /// Check if there are active filters
  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty ||
        _selectedFilter != 'All' ||
        _dateRange != null ||
        _minAmount != null ||
        _maxAmount != null ||
        _selectedFarmer != null ||
        _selectedProduct != null;
  }

  /// Populate farmer and product name caches efficiently
  Future<void> _populateCaches(List<SaleCoreEntity> sales) async {
    // Get unique farmer and product IDs that aren't already cached
    final uncachedFarmerIds =
        sales
            .map((sale) => sale.farmerId)
            .where((id) => !_farmerNameCache.containsKey(id))
            .toSet()
            .toList();

    final uncachedProductIds =
        sales
            .map((sale) => sale.productId)
            .where((id) => !_productNameCache.containsKey(id))
            .toSet()
            .toList();

    // Batch load farmers if needed
    if (uncachedFarmerIds.isNotEmpty) {
      await _batchLoadFarmers(uncachedFarmerIds);
    }

    // Batch load products if needed
    if (uncachedProductIds.isNotEmpty) {
      await _batchLoadProducts(uncachedProductIds);
    }
  }

  /// Batch load farmer names to avoid individual queries
  Future<void> _batchLoadFarmers(List<String> farmerIds) async {
    try {
      // Firestore 'in' queries are limited to 10 items, so batch them
      const batchSize = 10;
      for (int i = 0; i < farmerIds.length; i += batchSize) {
        final batch = farmerIds.skip(i).take(batchSize).toList();

        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('farmers')
                .where(FieldPath.documentId, whereIn: batch)
                .get();

        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          final name =
              data['name'] ??
              '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();

          _farmerNameCache[doc.id] = name.isNotEmpty ? name : 'Unknown Farmer';
        }

        // Mark missing farmers as unknown
        for (final farmerId in batch) {
          if (!_farmerNameCache.containsKey(farmerId)) {
            _farmerNameCache[farmerId] = 'Unknown Farmer';
          }
        }
      }

      // Update UI after batch loading
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Mark all as unknown on error
      for (final farmerId in farmerIds) {
        _farmerNameCache[farmerId] = 'Unknown Farmer';
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Batch load product names to avoid individual queries
  Future<void> _batchLoadProducts(List<String> productIds) async {
    try {
      // Firestore 'in' queries are limited to 10 items, so batch them
      const batchSize = 10;
      for (int i = 0; i < productIds.length; i += batchSize) {
        final batch = productIds.skip(i).take(batchSize).toList();

        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('products')
                .where(FieldPath.documentId, whereIn: batch)
                .get();

        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          final name = data['name'] ?? 'Unknown Product';

          _productNameCache[doc.id] = name;
        }

        // Mark missing products as unknown
        for (final productId in batch) {
          if (!_productNameCache.containsKey(productId)) {
            _productNameCache[productId] = 'Unknown Product';
          }
        }
      }

      // Update UI after batch loading
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Mark all as unknown on error
      for (final productId in productIds) {
        _productNameCache[productId] = 'Unknown Product';
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Build loading state
  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          SizedBox(height: ResponsiveUtils.spacing16),
          Text(
            'Loading sales data...',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(ThemeData theme, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.point_of_sale_outlined,
            size: ResponsiveUtils.iconSize80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: ResponsiveUtils.spacing24),
          Text(
            'No Sales Yet',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing8),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.spacing24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateSale(),
            icon: const Icon(Icons.add),
            label: const Text('Record First Sale'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.spacing24,
                vertical: ResponsiveUtils.spacing12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(ThemeData theme, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ResponsiveUtils.iconSize80,
            color: theme.colorScheme.error,
          ),
          SizedBox(height: ResponsiveUtils.spacing24),
          Text(
            'Error Loading Sales',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing8),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.spacing24),
          ElevatedButton.icon(
            onPressed: () {
              if (_cooperativeId != null) {
                ref.read(salesListProvider.notifier).refreshSales();
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build sales list
  Widget _buildSalesList(List<SaleCoreEntity> sales, ThemeData theme) {
    if (sales.isEmpty) {
      return _buildEmptyState(theme, 'No sales found for your cooperative');
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final sale = sales[index];
        return _buildSaleCard(sale, theme);
      },
    );
  }

  /// Build individual sale card with comprehensive information
  Widget _buildSaleCard(SaleCoreEntity sale, ThemeData theme) {
    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
        onTap: () => _showSaleDetails(sale, theme),
        child: Container(
          padding: EdgeInsets.all(ResponsiveUtils.spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surface.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with sale ID and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${sale.id.substring(0, 8).toUpperCase()}',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.fontSize16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(sale.saleDate),
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveUtils.spacing2),

              // Product name and farmer name
              FutureBuilder<String>(
                future: _getProductName(sale.productId),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'Loading product...',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.fontSize18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  );
                },
              ),

              SizedBox(height: ResponsiveUtils.spacing2),

              FutureBuilder<String>(
                future: _getFarmerName(sale.farmerId),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'Loading farmer...',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),

              SizedBox(height: ResponsiveUtils.spacing12),

              // Weight and Price section
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            sale.weight.toStringAsFixed(0),
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtils.fontSize20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'kg',
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
                    Container(
                      width: 1,
                      height: 35,
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            sale.pricePerKg,
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtils.fontSize20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'TSH/kg',
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
                  ],
                ),
              ),

              SizedBox(height: ResponsiveUtils.spacing12),

              // Financial breakdown
              _buildFinancialRow(
                'Total',
                '${_formatAmount(sale.amount)} TSH',
                theme,
                isTotal: true,
              ),
              SizedBox(height: ResponsiveUtils.spacing6),
              _buildFinancialRow(
                'Commission',
                '-${_formatAmount(sale.cooperativeCommission)} TSH',
                theme,
                isNegative: true,
              ),
              SizedBox(height: ResponsiveUtils.spacing6),
              _buildFinancialRow(
                'Farmer gets',
                '${_formatAmount(sale.amountFarmerReceive)} TSH',
                theme,
                isPositive: true,
              ),

              SizedBox(height: ResponsiveUtils.spacing12),

              // Divider line
              Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                thickness: 1,
                height: 1,
              ),

              SizedBox(height: ResponsiveUtils.spacing12),

              // Quality grade with checkbox and action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Quality grade with checkbox
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.9,
                        child: Checkbox(
                          value:
                              sale.qualityGrade != null &&
                              sale.qualityGrade!.isNotEmpty,
                          onChanged: null, // Read-only
                          activeColor: _getQualityGradeCheckboxColor(
                            sale.qualityGrade ?? '',
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.spacing6),
                      Text(
                        'Quality',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize13,
                          fontWeight: FontWeight.w600,
                          color: _getQualityGradeCheckboxColor(
                            sale.qualityGrade ?? '',
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Action buttons
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _editSale(sale),
                        icon: Icon(
                          Icons.edit_outlined,
                          size: ResponsiveUtils.iconSize16,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        tooltip: 'Edit Sale',
                        padding: EdgeInsets.all(ResponsiveUtils.spacing6),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _shareSale(sale),
                        icon: Icon(
                          Icons.share_outlined,
                          size: ResponsiveUtils.iconSize16,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        tooltip: 'Share Sale',
                        padding: EdgeInsets.all(ResponsiveUtils.spacing6),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _deleteSale(sale),
                        icon: Icon(
                          Icons.delete_outline,
                          size: ResponsiveUtils.iconSize16,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        tooltip: 'Delete Sale',
                        padding: EdgeInsets.all(ResponsiveUtils.spacing6),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToCreateSale(),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      icon: const Icon(Icons.add),
      label: Text(
        'New Sale',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Apply search and filters to sales list
  void _applyFilters() {
    final salesState = ref.read(salesListProvider);
    if (salesState is! SalesLoaded) return;

    List<SaleCoreEntity> filtered = List.from(salesState.sales);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((sale) {
            final farmerName =
                _farmerNameCache[sale.farmerId]?.toLowerCase() ?? '';
            final productName =
                _productNameCache[sale.productId]?.toLowerCase() ?? '';
            final searchLower = _searchQuery.toLowerCase();

            return farmerName.contains(searchLower) ||
                productName.contains(searchLower) ||
                sale.id.toLowerCase().contains(searchLower) ||
                sale.amount.toString().contains(searchLower);
          }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered =
          filtered.where((sale) {
            switch (_selectedFilter) {
              case 'Today':
                return _isSameDay(sale.saleDate, DateTime.now());
              case 'This Week':
                return _isThisWeek(sale.saleDate);
              case 'This Month':
                return _isThisMonth(sale.saleDate);
              case 'High Value':
                return sale.amount >= 100000; // TSH 100,000+
              default:
                return true;
            }
          }).toList();
    }

    // Apply date range filter
    if (_dateRange != null) {
      filtered =
          filtered.where((sale) {
            return sale.saleDate.isAfter(
                  _dateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                sale.saleDate.isBefore(
                  _dateRange!.end.add(const Duration(days: 1)),
                );
          }).toList();
    }

    // Apply amount range filter
    if (_minAmount != null) {
      filtered = filtered.where((sale) => sale.amount >= _minAmount!).toList();
    }
    if (_maxAmount != null) {
      filtered = filtered.where((sale) => sale.amount <= _maxAmount!).toList();
    }

    // Apply farmer filter
    if (_selectedFarmer != null) {
      filtered =
          filtered.where((sale) => sale.farmerId == _selectedFarmer).toList();
    }

    // Apply product filter
    if (_selectedProduct != null) {
      filtered =
          filtered.where((sale) => sale.productId == _selectedProduct).toList();
    }

    setState(() {
      _filteredSales = filtered;
    });
  }

  /// Check if date is same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if date is in this week
  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is in this month
  bool _isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Handle search input with debouncing
  void _onSearchChanged(String value) {
    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    // Update search query immediately for UI
    setState(() {
      _searchQuery = value;
    });

    // Debounce the actual filtering to avoid excessive calls
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  /// Handle filter selection
  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilters();
  }

  /// Show advanced filters dialog
  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAdvancedFiltersModal(),
    );
  }

  /// Build advanced filters modal
  Widget _buildAdvancedFiltersModal() {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: theme.colorScheme.primary,
                  size: ResponsiveUtils.iconSize24,
                ),
                SizedBox(width: ResponsiveUtils.spacing12),
                Expanded(
                  child: Text(
                    'Advanced Filters',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.fontSize18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveUtils.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRangeFilter(theme),
                  SizedBox(height: ResponsiveUtils.spacing24),
                  _buildAmountRangeFilter(theme),
                  SizedBox(height: ResponsiveUtils.spacing24),
                  _buildFarmerFilter(theme),
                  SizedBox(height: ResponsiveUtils.spacing24),
                  _buildProductFilter(theme),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear All'),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _applyFilters();
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Clear all filters
  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedFilter = 'All';
      _dateRange = null;
      _minAmount = null;
      _maxAmount = null;
      _selectedFarmer = null;
      _selectedProduct = null;
      _searchController.clear();
    });
    _applyFilters();
  }

  /// Build date range filter
  Widget _buildDateRangeFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing12),
        InkWell(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDateRange: _dateRange,
            );
            if (picked != null) {
              setState(() {
                _dateRange = picked;
              });
            }
          },
          child: Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing12),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.date_range,
                  color: theme.colorScheme.primary,
                  size: ResponsiveUtils.iconSize20,
                ),
                SizedBox(width: ResponsiveUtils.spacing12),
                Expanded(
                  child: Text(
                    _dateRange == null
                        ? 'Select date range'
                        : '${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year} - ${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      color:
                          _dateRange == null
                              ? theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              )
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (_dateRange != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _dateRange = null;
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      size: ResponsiveUtils.iconSize16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build amount range filter
  Widget _buildAmountRangeFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount Range (TSH)',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _minAmount?.toString() ?? '',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Min Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                  prefixText: 'TSH ',
                ),
                onChanged: (value) {
                  setState(() {
                    _minAmount = double.tryParse(value);
                  });
                },
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: TextFormField(
                initialValue: _maxAmount?.toString() ?? '',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Max Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                  prefixText: 'TSH ',
                ),
                onChanged: (value) {
                  setState(() {
                    _maxAmount = double.tryParse(value);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build farmer filter
  Widget _buildFarmerFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farmer',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.spacing12),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFarmer,
              hint: const Text('Select farmer'),
              isExpanded: true,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All farmers'),
                ),
                ..._farmerNameCache.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFarmer = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Build product filter
  Widget _buildProductFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.spacing12),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedProduct,
              hint: const Text('Select product'),
              isExpanded: true,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All products'),
                ),
                ..._productNameCache.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedProduct = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  // Utility methods
  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  Color _getQualityGradeCheckboxColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'premium':
      case 'a':
        return Colors.green;
      case 'standard':
      case 'b':
        return Colors.orange;
      case 'low':
      case 'c':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get farmer name from farmer ID by querying Firestore farmers collection
  /// Uses caching to avoid repeated queries for the same farmer
  Future<String> _getFarmerName(String farmerId) async {
    try {
      if (farmerId.isEmpty) {
        return 'Unknown Farmer';
      }

      // Check cache first
      if (_farmerNameCache.containsKey(farmerId)) {
        return _farmerNameCache[farmerId]!;
      }

      // Query the farmers collection to get farmer details
      final DocumentSnapshot farmerDoc =
          await FirebaseFirestore.instance
              .collection('farmers')
              .doc(farmerId)
              .get();

      String farmerName = 'Farmer ${farmerId.substring(0, 6)}';

      if (farmerDoc.exists) {
        final data = farmerDoc.data() as Map<String, dynamic>?;

        if (data != null) {
          // Try different possible field names for farmer name
          String? name =
              data['name'] ??
              data['fullName'] ??
              data['firstName'] ??
              data['farmerName'];

          // If firstName and lastName exist separately, combine them
          if (name == null && data['firstName'] != null) {
            final firstName = data['firstName'] ?? '';
            final lastName = data['lastName'] ?? '';
            name = '$firstName $lastName'.trim();
          }

          if (name?.isNotEmpty == true) {
            farmerName = name!;
          }
        }
      }

      // Cache the result for future use
      _farmerNameCache[farmerId] = farmerName;
      return farmerName;
    } catch (e) {
      // Log error for debugging
      debugPrint('Error fetching farmer name for ID $farmerId: $e');
      final fallbackName = 'Farmer ${farmerId.substring(0, 6)}';

      // Cache the fallback name to avoid repeated failed queries
      _farmerNameCache[farmerId] = fallbackName;
      return fallbackName;
    }
  }

  /// Get product name from product ID by querying Firestore products collection
  /// Uses caching to avoid repeated queries for the same product
  Future<String> _getProductName(String productId) async {
    try {
      if (productId.isEmpty) {
        return 'Unknown Product';
      }

      // Check cache first
      if (_productNameCache.containsKey(productId)) {
        return _productNameCache[productId]!;
      }

      // Query the products collection to get product details
      final DocumentSnapshot productDoc =
          await FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .get();

      String productName = 'Product ${productId.substring(0, 6)}';

      if (productDoc.exists) {
        final data = productDoc.data() as Map<String, dynamic>?;

        if (data != null) {
          // Try different possible field names for product name
          String? name =
              data['name'] ??
              data['productName'] ??
              data['title'] ??
              data['displayName'];

          if (name?.isNotEmpty == true) {
            productName = name!;
          }
        }
      }

      // Cache the result for future use
      _productNameCache[productId] = productName;
      return productName;
    } catch (e) {
      // Log error for debugging
      debugPrint('Error fetching product name for ID $productId: $e');
      final fallbackName = 'Product ${productId.substring(0, 6)}';

      // Cache the fallback name to avoid repeated failed queries
      _productNameCache[productId] = fallbackName;
      return fallbackName;
    }
  }

  /// Build financial row for the card
  Widget _buildFinancialRow(
    String label,
    String value,
    ThemeData theme, {
    bool isTotal = false,
    bool isPositive = false,
    bool isNegative = false,
  }) {
    Color textColor = theme.colorScheme.onSurface;
    FontWeight fontWeight = FontWeight.w500;

    if (isTotal) {
      textColor = theme.colorScheme.onSurface;
      fontWeight = FontWeight.bold;
    } else if (isPositive) {
      textColor = Colors.green;
      fontWeight = FontWeight.w600;
    } else if (isNegative) {
      textColor = Colors.orange;
      fontWeight = FontWeight.w600;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
      ],
    );
  }

  // Navigation and action methods
  void _navigateToCreateSale() {
    _showAddSaleModal();
  }

  /// Show add sale modal with comprehensive form
  void _showAddSaleModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AddSaleModal(
            cooperativeId: _cooperativeId!,
            onSaleCreated: () {
              // Refresh sales list after creation
              if (_cooperativeId != null) {
                ref
                    .read(salesListProvider.notifier)
                    .loadSales(cooperativeId: _cooperativeId!);
                // Refresh activities and recent sales to show new sale
                ref.invalidate(recentActivitiesProvider);
                ref.invalidate(recentSalesProvider);
              }
            },
          ),
    );
  }

  void _showSaleDetails(SaleCoreEntity sale, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSaleDetailsBottomSheet(sale, theme),
    );
  }

  void _showMoreOptions(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildMoreOptionsBottomSheet(theme),
    );
  }

  void _editSale(SaleCoreEntity sale) {
    if (_cooperativeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cooperative ID not available')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => EditSaleModal(
            cooperativeId: _cooperativeId!,
            sale: sale,
            onSaleUpdated: () {
              // Refresh sales list after update
              if (_cooperativeId != null) {
                ref
                    .read(salesListProvider.notifier)
                    .loadSales(cooperativeId: _cooperativeId!);
                // Refresh activities and recent sales to show updated sale
                ref.invalidate(recentActivitiesProvider);
                ref.invalidate(recentSalesProvider);
              }
            },
          ),
    );
  }

  void _shareSale(SaleCoreEntity sale) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share sale #${sale.id.substring(0, 6)}')),
    );
  }

  void _deleteSale(SaleCoreEntity sale) {
    // TODO: Implement delete functionality with confirmation
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Sale'),
            content: Text(
              'Are you sure you want to delete sale #${sale.id.substring(0, 6)}?',
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
                    const SnackBar(content: Text('Sale deleted successfully')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  /// Build sale details bottom sheet
  Widget _buildSaleDetailsBottomSheet(SaleCoreEntity sale, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveUtils.radius20),
          topRight: Radius.circular(ResponsiveUtils.radius20),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.all(ResponsiveUtils.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.spacing20),
                // Title
                Text(
                  'Sale Details',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.spacing20),
                // Sale details
                _buildDetailRow('Product', sale.fruityType, theme),
                _buildDetailRow('Weight', '${sale.weight} kg', theme),
                _buildDetailRow(
                  'Price per kg',
                  'TSh ${sale.pricePerKg}',
                  theme,
                ),
                _buildDetailRow(
                  'Total Amount',
                  'TSh ${_formatAmount(sale.amount)}',
                  theme,
                ),
                _buildDetailRow(
                  'Commission',
                  'TSh ${_formatAmount(sale.cooperativeCommission)}',
                  theme,
                ),
                _buildDetailRow(
                  'Farmer Receives',
                  'TSh ${_formatAmount(sale.amountFarmerReceive)}',
                  theme,
                ),
                _buildDetailRow(
                  'Sale Date',
                  DateFormat('MMM dd, yyyy').format(sale.saleDate),
                  theme,
                ),
                if (sale.qualityGrade != null && sale.qualityGrade!.isNotEmpty)
                  _buildDetailRow('Quality Grade', sale.qualityGrade!, theme),
                SizedBox(height: ResponsiveUtils.spacing24),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _editSale(sale);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.spacing12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _shareSale(sale);
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.spacing12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Build more options bottom sheet
  Widget _buildMoreOptionsBottomSheet(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveUtils.radius20),
          topRight: Radius.circular(ResponsiveUtils.radius20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: ResponsiveUtils.spacing12),
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing20),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Data'),
            onTap: () {
              Navigator.pop(context);
              if (_cooperativeId != null) {
                ref.read(salesListProvider.notifier).refreshSales();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.filter_list),
            title: const Text('Advanced Filters'),
            onTap: () {
              Navigator.pop(context);
              _showAdvancedFilters();
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export Data'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement export functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export functionality coming soon'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Show settings
            },
          ),
          SizedBox(height: ResponsiveUtils.spacing20),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../auth/presentation/providers/mobile_auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';
import '../models/report_models.dart';
import '../providers/report_builder_provider.dart';
import '../providers/custom_report_provider.dart';
import '../widgets/custom_report_builder.dart';
import '../widgets/report_scheduling_widget.dart';
import '../../domain/services/report_generation_service.dart';
import '../../domain/services/report_scheduling_service.dart';

/// Professional cooperative reports and analytics screen
class CooperativeReportsScreen extends ConsumerStatefulWidget {
  const CooperativeReportsScreen({super.key});

  @override
  ConsumerState<CooperativeReportsScreen> createState() =>
      _CooperativeReportsScreenState();
}

class _CooperativeReportsScreenState
    extends ConsumerState<CooperativeReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _cooperativeId;

  // Analytics data
  Map<String, dynamic> _analyticsData = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalyticsData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAnalyticsData() async {
    final authState = ref.read(mobileAuthProvider);
    if (authState is AuthAuthenticated) {
      final cooperativeId = authState.user.cooperativeId;
      if (cooperativeId != null && cooperativeId.isNotEmpty) {
        setState(() {
          _cooperativeId = cooperativeId;
          _isLoading = true;
          _error = null;
        });

        try {
          final data = await _fetchAnalyticsData(cooperativeId);
          setState(() {
            _analyticsData = data;
            _isLoading = false;
          });
        } catch (e) {
          setState(() {
            _error = e.toString();
            _isLoading = false;
          });
        }
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
          _buildTabBar(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildAnalyticsTab(theme), _buildReportsTab(theme)],
            ),
          ),
        ],
      ),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text(
        'Reports & Analytics',
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
          onPressed: () => _loadAnalyticsData(),
          tooltip: 'Refresh Data',
        ),
      ],
    );
  }

  /// Build tab bar
  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.6,
        ),
        indicatorColor: theme.colorScheme.primary,
        labelStyle: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.fontSize16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.fontSize16,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          Tab(icon: Icon(Icons.description), text: 'Reports'),
        ],
      ),
    );
  }

  /// Fetch analytics data from Firestore
  Future<Map<String, dynamic>> _fetchAnalyticsData(String cooperativeId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfYear = DateTime(now.year, 1, 1);
      final last30Days = now.subtract(const Duration(days: 30));

      // Fetch sales data
      final salesQuery =
          await FirebaseFirestore.instance
              .collection('sales')
              .where('cooperativeId', isEqualTo: cooperativeId)
              .get();

      // Fetch farmers data
      final farmersQuery =
          await FirebaseFirestore.instance
              .collection('farmers')
              .where('cooperativeId', isEqualTo: cooperativeId)
              .get();

      // Fetch products data
      final productsQuery =
          await FirebaseFirestore.instance
              .collection('products')
              .where('cooperativeId', isEqualTo: cooperativeId)
              .get();

      // Process sales data
      final salesData =
          salesQuery.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add document ID
            return data;
          }).toList();

      final farmersData =
          farmersQuery.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add document ID
            return data;
          }).toList();

      final productsData =
          productsQuery.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add document ID
            return data;
          }).toList();

      // Debug: Print sample data
      debugPrint('Fetched ${salesData.length} sales');
      debugPrint('Fetched ${farmersData.length} farmers');
      debugPrint('Fetched ${productsData.length} products');

      if (salesData.isNotEmpty) {
        debugPrint('Sample sale: ${salesData.first}');
        debugPrint('Sale keys: ${salesData.first.keys.toList()}');
      }
      if (farmersData.isNotEmpty) {
        debugPrint('Sample farmer: ${farmersData.first}');
        debugPrint('Farmer keys: ${farmersData.first.keys.toList()}');
      }

      // Calculate analytics
      return _calculateAnalytics(salesData, farmersData, productsData, {
        'now': now,
        'startOfMonth': startOfMonth,
        'startOfYear': startOfYear,
        'last30Days': last30Days,
      });
    } catch (e) {
      throw Exception('Failed to fetch analytics data: $e');
    }
  }

  /// Calculate analytics from raw data
  Map<String, dynamic> _calculateAnalytics(
    List<Map<String, dynamic>> salesData,
    List<Map<String, dynamic>> farmersData,
    List<Map<String, dynamic>> productsData,
    Map<String, DateTime> dateRanges,
  ) {
    final now = dateRanges['now']!;
    final startOfMonth = dateRanges['startOfMonth']!;
    final startOfYear = dateRanges['startOfYear']!;
    final last30Days = dateRanges['last30Days']!;

    // Total metrics
    double totalRevenue = 0;
    double totalCommission = 0;
    double totalWeight = 0;
    int totalSales = salesData.length;

    // Monthly metrics
    double monthlyRevenue = 0;
    double monthlyCommission = 0;
    int monthlySales = 0;

    // Recent metrics (last 30 days)
    double recentRevenue = 0;
    int recentSales = 0;

    // Product performance
    Map<String, double> productRevenue = {};
    Map<String, int> productSales = {};

    // Process each sale
    for (final sale in salesData) {
      // Try different possible field names for amount
      final amount =
          (sale['amount'] ??
                  sale['totalAmount'] ??
                  sale['saleAmount'] ??
                  sale['price'] ??
                  0.0)
              .toDouble();

      // Try different possible field names for commission
      final commission =
          (sale['cooperativeCommission'] ??
                  sale['commission'] ??
                  sale['cooperativeShare'] ??
                  sale['commissionAmount'] ??
                  0.0)
              .toDouble();

      final weight = (sale['weight'] ?? 0.0).toDouble();
      final productId = sale['productId'] ?? '';

      // Debug: Print individual sale data
      debugPrint('Processing sale ${sale['id']}:');
      debugPrint(
        '  Raw amount: ${sale['amount']} (${sale['amount'].runtimeType})',
      );
      debugPrint(
        '  Raw commission: ${sale['cooperativeCommission']} (${sale['cooperativeCommission'].runtimeType})',
      );
      debugPrint('  Parsed amount: $amount');
      debugPrint('  Parsed commission: $commission');

      if (amount > 0 || commission > 0) {
        debugPrint('✅ Sale found - Amount: $amount, Commission: $commission');
      } else {
        debugPrint('❌ Sale has zero amount and commission');
      }

      // Parse sale date
      DateTime saleDate;
      if (sale['saleDate'] is Timestamp) {
        saleDate = (sale['saleDate'] as Timestamp).toDate();
      } else if (sale['createdAt'] is Timestamp) {
        saleDate = (sale['createdAt'] as Timestamp).toDate();
      } else if (sale['date'] is Timestamp) {
        saleDate = (sale['date'] as Timestamp).toDate();
      } else {
        // If no valid date, use current date but log it
        debugPrint('No valid date found for sale: ${sale['id']}');
        saleDate = DateTime.now();
      }

      // Total metrics
      totalRevenue += amount;
      totalCommission += commission;
      totalWeight += weight;

      // Monthly metrics
      if (saleDate.isAfter(startOfMonth)) {
        monthlyRevenue += amount;
        monthlyCommission += commission;
        monthlySales++;
      }

      // Recent metrics (last 30 days)
      if (saleDate.isAfter(last30Days)) {
        recentRevenue += amount;
        recentSales++;
      }

      // Product performance
      productRevenue[productId] = (productRevenue[productId] ?? 0) + amount;
      productSales[productId] = (productSales[productId] ?? 0) + 1;
    }

    // Calculate averages
    final avgSaleValue = totalSales > 0 ? totalRevenue / totalSales : 0.0;
    final avgCommissionRate =
        totalRevenue > 0 ? (totalCommission / totalRevenue) * 100 : 0.0;

    // Growth calculations - comparing current month to previous month
    DateTime previousMonthStart;
    DateTime previousMonthEnd;

    if (now.month == 1) {
      // Handle January - previous month is December of previous year
      previousMonthStart = DateTime(now.year - 1, 12, 1);
      previousMonthEnd = DateTime(
        now.year,
        1,
        1,
      ).subtract(const Duration(days: 1));
    } else {
      // Normal case
      previousMonthStart = DateTime(now.year, now.month - 1, 1);
      previousMonthEnd = DateTime(
        now.year,
        now.month,
        1,
      ).subtract(const Duration(days: 1));
    }

    double previousMonthRevenue = 0;
    int previousMonthSales = 0;

    debugPrint('Growth calculation dates:');
    debugPrint('Current month start: $startOfMonth');
    debugPrint('Previous month: $previousMonthStart to $previousMonthEnd');
    debugPrint(
      'Current monthly revenue: $monthlyRevenue, sales: $monthlySales',
    );

    for (final sale in salesData) {
      // Use the same enhanced date parsing logic
      DateTime? saleDate;
      if (sale['saleDate'] is Timestamp) {
        saleDate = (sale['saleDate'] as Timestamp).toDate();
      } else if (sale['createdAt'] is Timestamp) {
        saleDate = (sale['createdAt'] as Timestamp).toDate();
      } else if (sale['date'] is Timestamp) {
        saleDate = (sale['date'] as Timestamp).toDate();
      }

      if (saleDate != null) {
        // Check if sale is in previous month
        if (saleDate.isAfter(previousMonthStart) &&
            saleDate.isBefore(previousMonthEnd.add(const Duration(days: 1)))) {
          // Use enhanced amount extraction
          final amount =
              (sale['amount'] ??
                      sale['totalAmount'] ??
                      sale['saleAmount'] ??
                      sale['price'] ??
                      0.0)
                  .toDouble();

          previousMonthRevenue += amount;
          previousMonthSales++;

          debugPrint(
            'Previous month sale: ${sale['id']} - $amount on ${saleDate.toString().substring(0, 10)}',
          );
        }
      }
    }

    debugPrint(
      'Previous month totals: Revenue: $previousMonthRevenue, Sales: $previousMonthSales',
    );

    // Calculate growth percentages
    final revenueGrowth =
        previousMonthRevenue > 0
            ? ((monthlyRevenue - previousMonthRevenue) / previousMonthRevenue) *
                100
            : (monthlyRevenue > 0
                ? 100.0
                : 0.0); // If no previous data but current data exists, show 100% growth

    final salesGrowth =
        previousMonthSales > 0
            ? ((monthlySales - previousMonthSales) / previousMonthSales) * 100
            : (monthlySales > 0
                ? 100.0
                : 0.0); // If no previous data but current data exists, show 100% growth

    debugPrint(
      'Calculated growth: Revenue: $revenueGrowth%, Sales: $salesGrowth%',
    );

    // Calculate farmers involved in sales and their performance
    Set<String> farmersInvolved = {};
    Map<String, double> farmerSales = {};
    Map<String, String> farmerNames = {};
    Map<String, double> zonePerformance = {};

    // Track farmers involved in sales
    for (final sale in salesData) {
      final farmerId =
          sale['farmerId'] ?? sale['farmer'] ?? sale['farmerUid'] ?? '';
      if (farmerId.isNotEmpty) {
        farmersInvolved.add(farmerId);

        // Use the same enhanced amount extraction
        final amount =
            (sale['amount'] ??
                    sale['totalAmount'] ??
                    sale['saleAmount'] ??
                    sale['price'] ??
                    0.0)
                .toDouble();

        farmerSales[farmerId] = (farmerSales[farmerId] ?? 0) + amount;

        // Debug farmer sales
        if (amount > 0) {
          debugPrint('Farmer $farmerId sale: $amount');
        }
      }
    }

    // Process farmers data for names and zones
    for (final farmer in farmersData) {
      // Try different possible ID fields
      final farmerId =
          farmer['id'] ?? farmer['farmerId'] ?? farmer['uid'] ?? '';
      final farmerName =
          farmer['name'] ??
          farmer['fullName'] ??
          farmer['firstName'] ??
          farmer['farmerName'] ??
          'Unknown Farmer';
      final zone =
          farmer['zone'] ??
          farmer['location'] ??
          farmer['district'] ??
          farmer['region'] ??
          'Unknown Zone';

      if (farmerId.isNotEmpty) {
        farmerNames[farmerId] = farmerName;

        // Add farmer's sales to zone performance
        final farmerSalesAmount = farmerSales[farmerId] ?? 0.0;
        if (farmerSalesAmount > 0) {
          zonePerformance[zone] =
              (zonePerformance[zone] ?? 0) + farmerSalesAmount;
        }
      }
    }

    // Debug: Print some information
    debugPrint('Analytics Debug:');
    debugPrint('Total Sales Data: ${salesData.length}');
    debugPrint('Total Farmers Data: ${farmersData.length}');
    debugPrint('Total Revenue: $totalRevenue');
    debugPrint('Total Commission: $totalCommission');
    debugPrint('Farmers Involved: ${farmersInvolved.length}');
    debugPrint('Farmer Sales: ${farmerSales.length}');
    debugPrint('Farmer Names: ${farmerNames.length}');
    debugPrint('Zone Performance: ${zonePerformance.length}');

    // Debug: Print top farmer sales
    if (farmerSales.isNotEmpty) {
      debugPrint('Top farmer sales:');
      final sortedFarmerSales =
          farmerSales.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sortedFarmerSales.take(3)) {
        debugPrint('  ${entry.key}: ${entry.value}');
      }
    }

    // Get top 5 performing farmers
    final topFarmers = farmerSales.entries.toList();
    topFarmers.sort(
      (MapEntry<String, double> a, MapEntry<String, double> b) =>
          b.value.compareTo(a.value),
    );

    final topFarmersData = <Map<String, dynamic>>[];

    for (final entry in topFarmers.take(5)) {
      final farmerId = entry.key;
      final salesAmount = entry.value;

      // Try to get farmer name from our mapping first
      String farmerName = farmerNames[farmerId] ?? '';

      // If not found, try to fetch from farmers collection using document ID
      if (farmerName.isEmpty || farmerName == 'Unknown Farmer') {
        // Look for farmer by document ID
        final farmerDoc = farmersData.firstWhere(
          (farmer) =>
              farmer['id'] == farmerId ||
              farmer['farmerId'] == farmerId ||
              farmer['uid'] == farmerId,
          orElse: () => <String, dynamic>{},
        );

        if (farmerDoc.isNotEmpty) {
          farmerName =
              farmerDoc['name'] ??
              farmerDoc['fullName'] ??
              farmerDoc['firstName'] ??
              farmerDoc['farmerName'] ??
              'Farmer ${farmerId.substring(0, 6)}';
        } else {
          farmerName = 'Farmer ${farmerId.substring(0, 6)}';
        }
      }

      topFarmersData.add({
        'farmerId': farmerId,
        'farmerName': farmerName,
        'salesAmount': salesAmount,
      });
    }

    return {
      'keyMetrics': {
        'totalSalesAmount': totalRevenue,
        'totalSalesCount': totalSales,
        'totalFarmersInvolved': farmersInvolved.length,
        'totalCommission': totalCommission,
      },
      'growth': {'revenueGrowth': revenueGrowth, 'salesGrowth': salesGrowth},
      'topFarmers': topFarmersData,
      'performanceBreakdown': {
        'avgSaleValue': avgSaleValue,
        'avgCommissionRate': avgCommissionRate,
        'monthlyRevenue': monthlyRevenue,
        'monthlySales': monthlySales,
      },
      'zonePerformance': zonePerformance,
    };
  }

  /// Build analytics tab
  Widget _buildAnalyticsTab(ThemeData theme) {
    if (_isLoading) {
      return _buildLoadingState(theme);
    }

    if (_error != null) {
      return _buildErrorState(theme, _error!);
    }

    if (_analyticsData.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: () async => _loadAnalyticsData(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Analytics Overview',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Comprehensive insights into your cooperative performance',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing24),

            // Key Metrics Cards
            _buildKeyMetricsSection(theme),
            SizedBox(height: ResponsiveUtils.spacing24),

            // Growth Indicators
            _buildGrowthSection(theme),
            SizedBox(height: ResponsiveUtils.spacing24),

            // Performance Breakdown
            _buildPerformanceSection(theme),
            SizedBox(height: ResponsiveUtils.spacing24),

            // Top Performing Farmers
            _buildTopFarmersSection(theme),
            SizedBox(height: ResponsiveUtils.spacing24),

            // Zone Performance
            _buildZonePerformanceSection(theme),
          ],
        ),
      ),
    );
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
            'Loading analytics data...',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(ThemeData theme, String error) {
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
            'Error Loading Analytics',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing8),
          Text(
            error,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.spacing24),
          ElevatedButton.icon(
            onPressed: () => _loadAnalyticsData(),
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

  /// Build empty state
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: ResponsiveUtils.iconSize80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: ResponsiveUtils.spacing24),
          Text(
            'No Analytics Data',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing8),
          Text(
            'Start recording sales to see analytics',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build key metrics section
  Widget _buildKeyMetricsSection(ThemeData theme) {
    final keyMetrics = _analyticsData['keyMetrics'] ?? {};

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
        SizedBox(height: ResponsiveUtils.spacing16),

        // First row of metrics
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Sales Amount',
                'TSh ${_formatAmount(keyMetrics['totalSalesAmount'] ?? 0.0)}',
                Icons.attach_money,
                Colors.green,
                theme,
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: _buildMetricCard(
                'Total Sales Count',
                '${keyMetrics['totalSalesCount'] ?? 0}',
                Icons.point_of_sale,
                Colors.blue,
                theme,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.spacing12),

        // Second row of metrics
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Farmers Involved',
                '${keyMetrics['totalFarmersInvolved'] ?? 0}',
                Icons.people,
                Colors.purple,
                theme,
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: _buildMetricCard(
                'Total Commission',
                'TSh ${_formatAmount(keyMetrics['totalCommission'] ?? 0.0)}',
                Icons.account_balance,
                Colors.orange,
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual metric card
  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: ResponsiveUtils.iconSize20,
                  ),
                ),
                Icon(
                  Icons.trending_up,
                  color: Colors.green,
                  size: ResponsiveUtils.iconSize16,
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.spacing12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing4),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build growth section
  Widget _buildGrowthSection(ThemeData theme) {
    final growth = _analyticsData['growth'] ?? {};
    final revenueGrowth = growth['revenueGrowth'] ?? 0.0;
    final salesGrowth = growth['salesGrowth'] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Growth Indicators',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing16),

        Row(
          children: [
            Expanded(
              child: _buildGrowthCard(
                'Revenue Growth',
                revenueGrowth,
                'vs last month',
                theme,
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: _buildGrowthCard(
                'Sales Growth',
                salesGrowth,
                'vs last month',
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build growth card
  Widget _buildGrowthCard(
    String title,
    double growth,
    String subtitle,
    ThemeData theme,
  ) {
    final isPositive = growth >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Icon(icon, color: color, size: ResponsiveUtils.iconSize20),
              ],
            ),
            SizedBox(height: ResponsiveUtils.spacing8),
            Text(
              '${isPositive ? '+' : ''}${growth.toStringAsFixed(1)}%',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing4),
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
    );
  }

  /// Build performance section
  Widget _buildPerformanceSection(ThemeData theme) {
    final performanceBreakdown = _analyticsData['performanceBreakdown'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Breakdown',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing16),

        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          ),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            child: Column(
              children: [
                _buildPerformanceRow(
                  'Average Sale Value',
                  'TSh ${_formatAmount(performanceBreakdown['avgSaleValue'] ?? 0.0)}',
                  Icons.trending_up,
                  theme,
                ),
                Divider(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                _buildPerformanceRow(
                  'Commission Rate',
                  '${(performanceBreakdown['avgCommissionRate'] ?? 0.0).toStringAsFixed(1)}%',
                  Icons.percent,
                  theme,
                ),
                Divider(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                _buildPerformanceRow(
                  'Monthly Revenue',
                  'TSh ${_formatAmount(performanceBreakdown['monthlyRevenue'] ?? 0.0)}',
                  Icons.calendar_month,
                  theme,
                ),
                Divider(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                _buildPerformanceRow(
                  'Monthly Sales',
                  '${performanceBreakdown['monthlySales'] ?? 0} transactions',
                  Icons.receipt,
                  theme,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build performance row
  Widget _buildPerformanceRow(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.spacing8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: ResponsiveUtils.iconSize16,
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Build product analytics section
  Widget _buildProductAnalyticsSection(ThemeData theme) {
    final productPerformance = _analyticsData['productPerformance'] ?? {};
    final productRevenue =
        productPerformance['productRevenue'] ?? <String, double>{};
    final productSales = productPerformance['productSales'] ?? <String, int>{};

    if (productRevenue.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort products by revenue
    final sortedProducts =
        productRevenue.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Performing Products',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing16),

        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          ),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            child: Column(
              children:
                  sortedProducts.take(5).map((entry) {
                    final productId = entry.key;
                    final revenue = entry.value;
                    final sales = productSales[productId] ?? 0;

                    return Column(
                      children: [
                        _buildProductRow(productId, revenue, sales, theme),
                        if (entry != sortedProducts.take(5).last)
                          Divider(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.2,
                            ),
                          ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Build product row
  Widget _buildProductRow(
    String productId,
    double revenue,
    int sales,
    ThemeData theme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.spacing8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Icon(
              Icons.inventory_2,
              color: Colors.green,
              size: ResponsiveUtils.iconSize16,
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product ${productId.substring(0, 6)}',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$sales sales',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'TSh ${_formatAmount(revenue)}',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize14,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  /// Build reports tab with comprehensive report system
  Widget _buildReportsTab(ThemeData theme) {
    final reportTemplates = ref.watch(reportTemplatesProvider);
    final generatedReports = ref.watch(generatedReportsProvider);
    final selectedCategory = ref.watch(selectedReportCategoryProvider);
    final searchQuery = ref.watch(reportSearchQueryProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Custom Report Builder button
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
                ),
                child: Icon(
                  Icons.description,
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
                      'Generate and manage your reports',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCustomReportBuilder(context),
                icon: Icon(
                  Icons.build,
                  size: ResponsiveUtils.iconSize16,
                  color: theme.colorScheme.onPrimary,
                ),
                label: Text(
                  'Custom',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacing12,
                    vertical: ResponsiveUtils.spacing8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing24),

          // Search and Filter Bar
          _buildSearchAndFilterBar(theme),
          SizedBox(height: ResponsiveUtils.spacing20),

          // Report Templates Section
          _buildReportTemplatesSection(
            theme,
            reportTemplates,
            selectedCategory,
            searchQuery,
          ),
          SizedBox(height: ResponsiveUtils.spacing24),

          // Generated Reports Section
          if (generatedReports.isNotEmpty) ...[
            _buildGeneratedReportsSection(theme, generatedReports),
            SizedBox(height: ResponsiveUtils.spacing24),
          ],

          // Quick Actions
          _buildQuickActionsSection(theme),
        ],
      ),
    );
  }

  /// Build report option
  Widget _buildReportOption(
    String title,
    String subtitle,
    IconData icon,
    ThemeData theme,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(ResponsiveUtils.spacing8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: ResponsiveUtils.iconSize20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
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
          Icons.download,
          size: ResponsiveUtils.iconSize20,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        onTap: onTap,
      ),
    );
  }

  /// Build top farmers section
  Widget _buildTopFarmersSection(ThemeData theme) {
    final topFarmers = _analyticsData['topFarmers'] ?? [];

    if (topFarmers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top 5 Performing Farmers',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing16),

        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          ),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            child: Column(
              children:
                  topFarmers.asMap().entries.map<Widget>((entry) {
                    final index = entry.key;
                    final farmer = entry.value;
                    final farmerName = farmer['farmerName'] ?? 'Unknown Farmer';
                    final salesAmount = farmer['salesAmount'] ?? 0.0;

                    return Column(
                      children: [
                        _buildFarmerRow(
                          index + 1,
                          farmerName,
                          salesAmount,
                          theme,
                        ),
                        if (index < topFarmers.length - 1)
                          Divider(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.2,
                            ),
                          ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Build farmer row
  Widget _buildFarmerRow(
    int rank,
    String farmerName,
    double salesAmount,
    ThemeData theme,
  ) {
    Color rankColor = Colors.grey;
    IconData rankIcon = Icons.person;

    if (rank == 1) {
      rankColor = Colors.amber;
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = Colors.grey.shade400;
      rankIcon = Icons.emoji_events;
    } else if (rank == 3) {
      rankColor = Colors.brown;
      rankIcon = Icons.emoji_events;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.spacing8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Center(
              child:
                  rank <= 3
                      ? Icon(
                        rankIcon,
                        color: rankColor,
                        size: ResponsiveUtils.iconSize16,
                      )
                      : Text(
                        '$rank',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtils.fontSize12,
                          fontWeight: FontWeight.bold,
                          color: rankColor,
                        ),
                      ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            child: Text(
              farmerName,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            'TSh ${_formatAmount(salesAmount)}',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize14,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  /// Build zone performance section
  Widget _buildZonePerformanceSection(ThemeData theme) {
    final zonePerformance =
        _analyticsData['zonePerformance'] ?? <String, double>{};

    if (zonePerformance.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort zones by performance
    final sortedZones = zonePerformance.entries.toList();
    sortedZones.sort(
      (MapEntry<String, double> a, MapEntry<String, double> b) =>
          b.value.compareTo(a.value),
    );

    // Calculate max value for bar chart scaling
    final maxValue = sortedZones.isNotEmpty ? sortedZones.first.value : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zone Performance',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing16),

        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
          ),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            child: Column(
              children:
                  sortedZones.map<Widget>((entry) {
                    final zoneName = entry.key;
                    final zoneValue = entry.value;
                    final percentage =
                        maxValue > 0 ? (zoneValue / maxValue) : 0.0;

                    return Column(
                      children: [
                        _buildZoneBar(zoneName, zoneValue, percentage, theme),
                        if (entry != sortedZones.last)
                          SizedBox(height: ResponsiveUtils.spacing12),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Build zone bar
  Widget _buildZoneBar(
    String zoneName,
    double value,
    double percentage,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              zoneName,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'TSh ${_formatAmount(value)}',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.spacing4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius4),
              ),
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

  String _formatWeight(double weight) {
    if (weight >= 1000) {
      return '${(weight / 1000).toStringAsFixed(1)}K';
    } else {
      return weight.toStringAsFixed(1);
    }
  }

  void _generateReport(String reportType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating $reportType report...'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // TODO: Implement report viewing
          },
        ),
      ),
    );
  }

  /// Show custom report builder modal
  void _showCustomReportBuilder(BuildContext context) {
    final authState = ref.read(mobileAuthProvider);
    if (authState is! AuthAuthenticated ||
        authState.user.cooperativeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to create custom reports')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CustomReportBuilder(
            cooperativeId: authState.user.cooperativeId!,
            onReportGenerated: () {
              // Refresh the reports list
              setState(() {});
            },
          ),
    );
  }

  /// Build search and filter bar
  Widget _buildSearchAndFilterBar(ThemeData theme) {
    final selectedCategory = ref.watch(selectedReportCategoryProvider);
    final searchQuery = ref.watch(reportSearchQueryProvider);

    return Column(
      children: [
        // Search bar
        TextField(
          decoration: InputDecoration(
            hintText: 'Search reports...',
            prefixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
          ),
          onChanged: (value) {
            ref.read(reportSearchQueryProvider.notifier).state = value;
          },
        ),
        SizedBox(height: ResponsiveUtils.spacing12),

        // Category filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // All categories chip
              Padding(
                padding: EdgeInsets.only(right: ResponsiveUtils.spacing8),
                child: FilterChip(
                  label: Text(
                    'All',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      fontWeight:
                          selectedCategory == null
                              ? FontWeight.w600
                              : FontWeight.w400,
                    ),
                  ),
                  selected: selectedCategory == null,
                  onSelected: (selected) {
                    ref.read(selectedReportCategoryProvider.notifier).state =
                        null;
                  },
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  checkmarkColor: theme.colorScheme.primary,
                ),
              ),

              // Category chips
              ...ReportCategory.values.map((category) {
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: EdgeInsets.only(right: ResponsiveUtils.spacing8),
                  child: FilterChip(
                    label: Text(
                      category.displayName,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(selectedReportCategoryProvider.notifier).state =
                          selected ? category : null;
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: category.color.withValues(alpha: 0.1),
                    checkmarkColor: category.color,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// Build report templates section
  Widget _buildReportTemplatesSection(
    ThemeData theme,
    List<ReportTemplate> templates,
    ReportCategory? selectedCategory,
    String searchQuery,
  ) {
    // Filter templates
    var filteredTemplates =
        templates.where((template) {
          final matchesCategory =
              selectedCategory == null || template.category == selectedCategory;
          final matchesSearch =
              searchQuery.isEmpty ||
              template.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              template.description.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
          return matchesCategory && matchesSearch;
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Report Templates',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              '${filteredTemplates.length} templates',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.spacing16),

        if (filteredTemplates.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing24),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: ResponsiveUtils.iconSize48,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing12),
                  Text(
                    'No templates found',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...filteredTemplates.map(
            (template) => Padding(
              padding: EdgeInsets.only(bottom: ResponsiveUtils.spacing12),
              child: _buildReportTemplateCard(theme, template),
            ),
          ),
      ],
    );
  }

  /// Build report template card
  Widget _buildReportTemplateCard(ThemeData theme, ReportTemplate template) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
      ),
      child: InkWell(
        onTap: () => _generateTemplateReport(template),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveUtils.spacing8),
                    decoration: BoxDecoration(
                      color: template.category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius8,
                      ),
                    ),
                    child: Icon(
                      template.icon,
                      color: template.category.color,
                      size: ResponsiveUtils.iconSize20,
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveUtils.fontSize16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          template.description,
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
                      color: template.category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius12,
                      ),
                    ),
                    child: Text(
                      template.category.displayName,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize10,
                        fontWeight: FontWeight.w500,
                        color: template.category.color,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.spacing12),

              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: ResponsiveUtils.iconSize16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing4),
                  Text(
                    template.estimatedTime,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing16),
                  Icon(
                    Icons.file_download,
                    size: ResponsiveUtils.iconSize16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing4),
                  Text(
                    '${template.formats.length} formats',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: ResponsiveUtils.iconSize16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build generated reports section
  Widget _buildGeneratedReportsSection(
    ThemeData theme,
    List<GeneratedReport> reports,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Reports',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => _showAllGeneratedReports(),
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize12,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.spacing16),

        ...reports
            .take(3)
            .map(
              (report) => Padding(
                padding: EdgeInsets.only(bottom: ResponsiveUtils.spacing8),
                child: _buildGeneratedReportCard(theme, report),
              ),
            ),
      ],
    );
  }

  /// Build generated report card
  Widget _buildGeneratedReportCard(ThemeData theme, GeneratedReport report) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(ResponsiveUtils.spacing6),
          decoration: BoxDecoration(
            color: report.category.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ResponsiveUtils.radius6),
          ),
          child: Icon(
            report.category.icon,
            color: report.category.color,
            size: ResponsiveUtils.iconSize16,
          ),
        ),
        title: Text(
          report.name,
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${report.period} • ${report.fileSize}',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (report.status == ReportGenerationStatus.completed)
              IconButton(
                onPressed: () => _downloadReport(report),
                icon: Icon(
                  Icons.download,
                  size: ResponsiveUtils.iconSize16,
                  color: theme.colorScheme.primary,
                ),
              ),
            IconButton(
              onPressed: () => _shareReport(report),
              icon: Icon(
                Icons.share,
                size: ResponsiveUtils.iconSize16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build quick actions section
  Widget _buildQuickActionsSection(ThemeData theme) {
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
        SizedBox(height: ResponsiveUtils.spacing16),

        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                theme,
                'Export All Data',
                'Download complete dataset',
                Icons.cloud_download,
                Colors.blue,
                _exportAllData,
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: _buildQuickActionCard(
                theme,
                'Schedule Report',
                'Set up automated reports',
                Icons.schedule,
                Colors.orange,
                _scheduleReport,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build quick action card
  Widget _buildQuickActionCard(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.spacing12),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: ResponsiveUtils.iconSize20,
                ),
              ),
              SizedBox(height: ResponsiveUtils.spacing8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize10,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Generate template report
  void _generateTemplateReport(ReportTemplate template) async {
    final authState = ref.read(mobileAuthProvider);
    if (authState is! AuthAuthenticated ||
        authState.user.cooperativeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to generate reports')),
      );
      return;
    }

    final reportService = ReportGenerationService();

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generating ${template.name}...'),
          duration: const Duration(seconds: 2),
        ),
      );

      final report = await reportService.generateTemplateReport(
        cooperativeId: authState.user.cooperativeId!,
        template: template,
        userId: authState.user.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report "${report.name}" generated successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Download',
              onPressed: () => _downloadReport(report),
            ),
          ),
        );

        // Refresh the reports list
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show all generated reports
  void _showAllGeneratedReports() {
    final authState = ref.read(mobileAuthProvider);
    if (authState is! AuthAuthenticated ||
        authState.user.cooperativeId == null) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAllReportsModal(),
    );
  }

  /// Build all reports modal
  Widget _buildAllReportsModal() {
    final theme = Theme.of(context);
    final authState = ref.read(mobileAuthProvider);

    if (authState is! AuthAuthenticated ||
        authState.user.cooperativeId == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUtils.radius20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing20),
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
                  Icons.history,
                  color: theme.colorScheme.primary,
                  size: ResponsiveUtils.iconSize24,
                ),
                SizedBox(width: ResponsiveUtils.spacing12),
                Expanded(
                  child: Text(
                    'All Generated Reports',
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

          // Reports list
          Expanded(
            child: FutureBuilder<List<GeneratedReport>>(
              future: ReportGenerationService().getGeneratedReports(
                authState.user.cooperativeId!,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading reports: ${snapshot.error}',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize14,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  );
                }

                final reports = snapshot.data ?? [];

                if (reports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: ResponsiveUtils.iconSize48,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.spacing12),
                        Text(
                          'No reports generated yet',
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize14,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing16),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: ResponsiveUtils.spacing8,
                      ),
                      child: _buildGeneratedReportCard(theme, report),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Download report
  void _downloadReport(GeneratedReport report) async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Downloading report...')));

      final reportService = ReportGenerationService();
      final filePath = await reportService.downloadReport(report);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Report downloaded successfully!\nSaved to: $filePath',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Open Folder',
              onPressed: () {
                // Show dialog with file location details
                _showFileLocationDialog(filePath);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show file location dialog
  void _showFileLocationDialog(String filePath) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'File Location',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your report has been saved to:',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.spacing12),
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: SelectableText(
                    filePath,
                    style: GoogleFonts.robotoMono(
                      fontSize: ResponsiveUtils.fontSize12,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.spacing16),
                Text(
                  'Note: On Android, files are saved to the app\'s documents directory. You can access them through a file manager app.',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  /// Share report
  void _shareReport(GeneratedReport report) async {
    try {
      final reportService = ReportGenerationService();
      await reportService.shareReport(report);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Export all data
  void _exportAllData() {
    final authState = ref.read(mobileAuthProvider);
    if (authState is! AuthAuthenticated ||
        authState.user.cooperativeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to export data')),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Export All Data',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize16,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'This will export all your cooperative data including sales, farmers, and products. This may take a few minutes.',
              style: GoogleFonts.inter(fontSize: ResponsiveUtils.fontSize14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _performFullDataExport();
                },
                child: const Text('Export'),
              ),
            ],
          ),
    );
  }

  /// Perform full data export
  void _performFullDataExport() async {
    final authState = ref.read(mobileAuthProvider);
    if (authState is! AuthAuthenticated ||
        authState.user.cooperativeId == null) {
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exporting all data... This may take a while.'),
          duration: Duration(seconds: 3),
        ),
      );

      final reportService = ReportGenerationService();

      // Create a comprehensive export configuration
      final exportConfig = CustomReportConfig(
        name: 'Complete Data Export',
        description: 'Full export of all cooperative data',
        dataSource: DataSource.combined,
        columns: [
          'date',
          'type',
          'farmerName',
          'productName',
          'amount',
          'weight',
          'quality',
          'zone',
          'commission',
        ],
        format: ReportFormat.csv,
        filters: ReportFilters.empty,
        dateRange: null, // All time
        sortBy: 'date',
        sortOrder: SortOrder.desc,
      );

      final report = await reportService.generateReport(
        cooperativeId: authState.user.cooperativeId!,
        config: exportConfig,
        userId: authState.user.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data export completed!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Download',
              onPressed: () => _downloadReport(report),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Schedule report
  void _scheduleReport() {
    final authState = ref.read(mobileAuthProvider);
    if (authState is! AuthAuthenticated ||
        authState.user.cooperativeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to schedule reports')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ReportSchedulingWidget(
            cooperativeId: authState.user.cooperativeId!,
            userId: authState.user.id,
            onScheduleCreated: () {
              // Refresh the screen or show success message
              setState(() {});
            },
          ),
    );
  }
}

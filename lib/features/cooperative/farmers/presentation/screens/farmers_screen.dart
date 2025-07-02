import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/farmer_entity.dart';
import '../../domain/services/farmer_service.dart';
import '../widgets/add_farmer_modal.dart';
import '../widgets/edit_farmer_modal.dart';

/// Farmers management screen for cooperative
class FarmersScreen extends ConsumerStatefulWidget {
  final String cooperativeId;

  const FarmersScreen({super.key, required this.cooperativeId});

  @override
  ConsumerState<FarmersScreen> createState() => _FarmersScreenState();
}

class _FarmersScreenState extends ConsumerState<FarmersScreen> {
  final _farmerService = FarmerService();
  List<FarmerEntity> _farmers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFarmers();
  }

  /// Load farmers from Firebase
  Future<void> _loadFarmers() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final farmers = await _farmerService.getFarmers(
        cooperativeId: widget.cooperativeId,
      );

      setState(() {
        _farmers = farmers;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load farmers: $e';
        _loading = false;
      });
    }
  }

  /// Show add farmer modal
  void _showAddFarmerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AddFarmerModal(
            cooperativeId: widget.cooperativeId,
            onFarmerCreated: () {
              // Refresh farmers list after creation
              _loadFarmers();
            },
          ),
    );
  }

  /// Show edit farmer modal
  void _showEditFarmerModal(FarmerEntity farmer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => EditFarmerModal(
            cooperativeId: widget.cooperativeId,
            farmer: farmer,
            onFarmerUpdated: () {
              // Refresh farmers list after update
              _loadFarmers();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Farmers',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(onPressed: _loadFarmers, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _buildBody(theme),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFarmerModal,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  /// Build main body
  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveUtils.iconSize48,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: ResponsiveUtils.spacing16),
            Text(
              _error!,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize16,
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.spacing16),
            ElevatedButton(onPressed: _loadFarmers, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_farmers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: ResponsiveUtils.iconSize64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            SizedBox(height: ResponsiveUtils.spacing16),
            Text(
              'No Farmers Yet',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing8),
            Text(
              'Add your first farmer to get started',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing24),
            ElevatedButton.icon(
              onPressed: _showAddFarmerModal,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Farmer'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFarmers,
      child: ListView.builder(
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        itemCount: _farmers.length,
        itemBuilder: (context, index) {
          final farmer = _farmers[index];
          return _buildFarmerCard(farmer, theme);
        },
      ),
    );
  }

  /// Build farmer card
  Widget _buildFarmerCard(FarmerEntity farmer, ThemeData theme) {
    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing12),
      child: InkWell(
        onTap: () => _showFarmerDetails(farmer),
        onLongPress: () => _showFarmerContextMenu(farmer),
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
                    radius: ResponsiveUtils.radius24,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(
                      farmer.initials,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.spacing12),

                  // Name and location
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
                        ),
                        Text(
                          farmer.formattedLocation,
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

                  // Status badge and edit button
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.spacing8,
                          vertical: ResponsiveUtils.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            farmer.status,
                            theme,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.radius12,
                          ),
                        ),
                        child: Text(
                          farmer.status,
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize12,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(farmer.status, theme),
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.spacing8),
                      IconButton(
                        onPressed: () => _showEditFarmerModal(farmer),
                        icon: Icon(
                          Icons.edit,
                          size: ResponsiveUtils.iconSize20,
                          color: theme.colorScheme.primary,
                        ),
                        tooltip: 'Edit Farmer',
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.spacing12),

              // Farm info
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Total Trees',
                      farmer.totalTrees.toString(),
                      Icons.park,
                      theme,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Productive',
                      farmer.fruitingTrees.toString(),
                      Icons.eco,
                      theme,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Productivity',
                      '${farmer.productivityPercentage.toStringAsFixed(1)}%',
                      Icons.trending_up,
                      theme,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build info item
  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: ResponsiveUtils.iconSize20,
          color: theme.colorScheme.primary,
        ),
        SizedBox(height: ResponsiveUtils.spacing4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
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

  /// Get status color
  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  /// Show farmer details (placeholder for future implementation)
  void _showFarmerDetails(FarmerEntity farmer) {
    // TODO: Implement farmer details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Farmer details for ${farmer.name}'),
        action: SnackBarAction(
          label: 'Edit',
          onPressed: () => _showEditFarmerModal(farmer),
        ),
      ),
    );
  }

  /// Show farmer context menu
  void _showFarmerContextMenu(FarmerEntity farmer) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  farmer.name,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.spacing16),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Farmer'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditFarmerModal(farmer);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('View Details'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFarmerDetails(farmer);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Delete Farmer',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteFarmer(farmer);
                  },
                ),
              ],
            ),
          ),
    );
  }

  /// Confirm farmer deletion
  void _confirmDeleteFarmer(FarmerEntity farmer) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Farmer'),
            content: Text(
              'Are you sure you want to delete ${farmer.name}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteFarmer(farmer);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  /// Delete farmer from database
  Future<void> _deleteFarmer(FarmerEntity farmer) async {
    try {
      await _farmerService.deleteFarmer(farmer.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Farmer "${farmer.name}" deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh farmers list
        _loadFarmers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete farmer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

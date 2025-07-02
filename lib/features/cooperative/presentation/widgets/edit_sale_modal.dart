import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../auth/presentation/providers/mobile_auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';
import '../../sales/domain/entities/sale_core.dart';
import '../providers/recent_activities_provider.dart';
import '../providers/recent_sales_provider.dart';
import 'package:hugeicons/hugeicons.dart';

/// Comprehensive Edit Sale Modal matching web portal functionality
class EditSaleModal extends ConsumerStatefulWidget {
  final String cooperativeId;
  final SaleCoreEntity sale;
  final VoidCallback? onSaleUpdated;

  const EditSaleModal({
    super.key,
    required this.cooperativeId,
    required this.sale,
    this.onSaleUpdated,
  });

  @override
  ConsumerState<EditSaleModal> createState() => _EditSaleModalState();
}

class _EditSaleModalState extends ConsumerState<EditSaleModal> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  // Form data
  String? _selectedFarmerId;
  String? _selectedProductId;
  String _fruitType = 'quality';
  DateTime _saleDate = DateTime.now();
  bool _isSubmitting = false;
  String? _error;

  // Data lists
  List<Map<String, dynamic>> _farmers = [];
  List<Map<String, dynamic>> _products = [];
  bool _loadingFarmers = true;
  bool _loadingProducts = true;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    _loadFarmers();
    _loadProducts();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Initialize form with existing sale data
  void _initializeFormData() {
    _selectedFarmerId = widget.sale.farmerId;
    _selectedProductId = widget.sale.productId;
    _weightController.text = widget.sale.weight.toString();
    _priceController.text = widget.sale.pricePerKg;
    _fruitType =
        widget.sale.fruityType.toLowerCase() == 'quality'
            ? 'quality'
            : 'reject';
    _saleDate = widget.sale.saleDate;
    _notesController.text = ''; // Notes not available in current entity
  }

  /// Load farmers from Firestore
  Future<void> _loadFarmers() async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('farmers')
              .where('cooperativeId', isEqualTo: widget.cooperativeId)
              .orderBy('name')
              .get();

      setState(() {
        _farmers =
            query.docs
                .map(
                  (doc) => {
                    'id': doc.id,
                    'name': doc.data()['name'] ?? 'Unknown',
                    'zone': doc.data()['zone'] ?? '',
                  },
                )
                .toList();
        _loadingFarmers = false;
      });
    } catch (e) {
      setState(() {
        _loadingFarmers = false;
      });
    }
  }

  /// Load products from Firestore
  Future<void> _loadProducts() async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('products')
              .where('cooperativeId', isEqualTo: widget.cooperativeId)
              .orderBy('name')
              .get();

      setState(() {
        _products =
            query.docs
                .map(
                  (doc) => {
                    'id': doc.id,
                    'name': doc.data()['name'] ?? 'Unknown',
                    'category': doc.data()['category'] ?? '',
                  },
                )
                .toList();
        _loadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _loadingProducts = false;
      });
    }
  }

  /// Calculate total amount
  double get _totalAmount {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    return weight * price;
  }

  /// Calculate commission (70 TSH per kg)
  double get _commission {
    final weight = double.tryParse(_weightController.text) ?? 0;
    return weight * 70;
  }

  /// Calculate farmer payment
  double get _farmerPayment {
    return _totalAmount - _commission;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        // borderRadius: BorderRadius.vertical(
        //   top: Radius.circular(ResponsiveUtils.radius20),
        // ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(theme),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveUtils.spacing20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sale ID Display
                    _buildSaleIdDisplay(theme),
                    SizedBox(height: ResponsiveUtils.spacing20),

                    // Farmer Selection
                    _buildFarmerSelection(theme),
                    SizedBox(height: ResponsiveUtils.spacing20),

                    // Product Selection
                    _buildProductSelection(theme),
                    SizedBox(height: ResponsiveUtils.spacing20),

                    // Weight and Price Row
                    Row(
                      children: [
                        Expanded(child: _buildWeightField(theme)),
                        SizedBox(width: ResponsiveUtils.spacing12),
                        Expanded(child: _buildPriceField(theme)),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.spacing20),

                    // Fruit Type Selection
                    _buildFruitTypeSelection(theme),
                    SizedBox(height: ResponsiveUtils.spacing20),

                    // Sale Date
                    _buildDateSelection(theme),
                    SizedBox(height: ResponsiveUtils.spacing20),

                    // Calculation Summary
                    _buildCalculationSummary(theme),
                    SizedBox(height: ResponsiveUtils.spacing20),

                    // Notes
                    _buildNotesField(theme),
                    SizedBox(height: ResponsiveUtils.spacing20),

                    // Error message
                    if (_error != null) ...[
                      Container(
                        padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.radius8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                              size: ResponsiveUtils.iconSize16,
                            ),
                            SizedBox(width: ResponsiveUtils.spacing8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: GoogleFonts.inter(
                                  fontSize: ResponsiveUtils.fontSize12,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.spacing16),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Footer
          _buildFooter(theme),
        ],
      ),
    );
  }

  /// Build header
  Widget _buildHeader(ThemeData theme) {
    return Container(
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
            HugeIcons.strokeRoundedPencilEdit01,
            color: theme.colorScheme.primary,
            size: ResponsiveUtils.iconSize24,
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Sale',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Update sale transaction details',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
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
    );
  }

  /// Build sale ID display
  Widget _buildSaleIdDisplay(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.receipt_long,
            color: theme.colorScheme.primary,
            size: ResponsiveUtils.iconSize16,
          ),
          SizedBox(width: ResponsiveUtils.spacing8),
          Text(
            'Sale ID: ${widget.sale.id.substring(0, 8)}...',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Text(
            'Created: ${widget.sale.createdAt.day}/${widget.sale.createdAt.month}/${widget.sale.createdAt.year}',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Build farmer selection
  Widget _buildFarmerSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farmer *',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),

        if (_loadingFarmers)
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: ResponsiveUtils.iconSize16,
                  height: ResponsiveUtils.iconSize16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Text(
                  'Loading farmers...',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          )
        else if (_farmers.isEmpty)
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Text(
              'No farmers found.',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.error,
              ),
            ),
          )
        else
          DropdownButtonFormField<String>(
            value: _selectedFarmerId,
            decoration: InputDecoration(
              hintText: 'Select a farmer',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
              ),
              contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
            ),
            items:
                _farmers.map((farmer) {
                  return DropdownMenuItem<String>(
                    value: farmer['id'],
                    child: Text(
                      farmer['zone'].isNotEmpty
                          ? '${farmer['name']} (${farmer['zone']})'
                          : farmer['name'],
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFarmerId = value;
                _error = null;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a farmer';
              }
              return null;
            },
          ),
      ],
    );
  }

  /// Build product selection
  Widget _buildProductSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product *',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),

        if (_loadingProducts)
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: ResponsiveUtils.iconSize16,
                  height: ResponsiveUtils.iconSize16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Text(
                  'Loading products...',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          )
        else if (_products.isEmpty)
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Text(
              'No products found.',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.error,
              ),
            ),
          )
        else
          DropdownButtonFormField<String>(
            value: _selectedProductId,
            decoration: InputDecoration(
              hintText: 'Select a product',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
              ),
              contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
            ),
            items:
                _products.map((product) {
                  return DropdownMenuItem<String>(
                    value: product['id'],
                    child: Text(
                      product['category'].isNotEmpty
                          ? '${product['name']} (${product['category']})'
                          : product['name'],
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProductId = value;
                _error = null;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a product';
              }
              return null;
            },
          ),
      ],
    );
  }

  /// Build weight field
  Widget _buildWeightField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight (kg) *',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        TextFormField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '0.0',
            suffixText: 'kg',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
          ),
          onChanged: (value) {
            setState(() {
              _error = null;
            });
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Weight is required';
            }
            final weight = double.tryParse(value);
            if (weight == null || weight <= 0) {
              return 'Enter valid weight';
            }
            if (weight > 1000) {
              return 'Weight seems too high';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Build price field
  Widget _buildPriceField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price per kg (TSH) *',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        TextFormField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '0',
            suffixText: 'TSH',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
          ),
          onChanged: (value) {
            setState(() {
              _error = null;
            });
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Price is required';
            }
            final price = double.tryParse(value);
            if (price == null || price <= 0) {
              return 'Enter valid price';
            }
            if (price < 100 || price > 5000) {
              return 'Price should be 100-5000 TSH';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Build fruit type selection
  Widget _buildFruitTypeSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fruit Type *',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),

        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _fruitType = 'quality';
                    _error = null;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                  decoration: BoxDecoration(
                    color:
                        _fruitType == 'quality'
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surface,
                    border: Border.all(
                      color:
                          _fruitType == 'quality'
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(
                                alpha: 0.3,
                              ),
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.star,
                        color:
                            _fruitType == 'quality'
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                        size: ResponsiveUtils.iconSize20,
                      ),
                      SizedBox(height: ResponsiveUtils.spacing4),
                      Text(
                        'Quality',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize14,
                          fontWeight:
                              _fruitType == 'quality'
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                          color:
                              _fruitType == 'quality'
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.spacing12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _fruitType = 'reject';
                    _error = null;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                  decoration: BoxDecoration(
                    color:
                        _fruitType == 'reject'
                            ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                            : theme.colorScheme.surface,
                    border: Border.all(
                      color:
                          _fruitType == 'reject'
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.outline.withValues(
                                alpha: 0.3,
                              ),
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.remove_circle_outline,
                        color:
                            _fruitType == 'reject'
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                        size: ResponsiveUtils.iconSize20,
                      ),
                      SizedBox(height: ResponsiveUtils.spacing4),
                      Text(
                        'Reject',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize14,
                          fontWeight:
                              _fruitType == 'reject'
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                          color:
                              _fruitType == 'reject'
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build date selection
  Widget _buildDateSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sale Date *',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),

        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _saleDate,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _saleDate = date;
                _error = null;
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
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                  size: ResponsiveUtils.iconSize16,
                ),
                SizedBox(width: ResponsiveUtils.spacing8),
                Text(
                  '${_saleDate.day}/${_saleDate.month}/${_saleDate.year}',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build calculation summary
  Widget _buildCalculationSummary(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Updated Calculation',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount:',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${_totalAmount.toStringAsFixed(0)} TSH',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commission (70 TSH/kg):',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${_commission.toStringAsFixed(0)} TSH',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing8),

          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          SizedBox(height: ResponsiveUtils.spacing8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Farmer Payment:',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${_farmerPayment.toStringAsFixed(0)} TSH',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build notes field
  Widget _buildNotesField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.fontSize14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any additional notes about this sale...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            contentPadding: EdgeInsets.all(ResponsiveUtils.spacing12),
          ),
        ),
      ],
    );
  }

  /// Build footer
  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
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
              onPressed:
                  _isSubmitting ? null : () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _updateSale,
              icon:
                  _isSubmitting
                      ? SizedBox(
                        width: ResponsiveUtils.iconSize16,
                        height: ResponsiveUtils.iconSize16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                      : Icon(Icons.save, size: ResponsiveUtils.iconSize16),
              label: Text(
                _isSubmitting ? 'Updating...' : 'Update Sale',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Update sale in database
  Future<void> _updateSale() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get authenticated user
    final authState = ref.read(mobileAuthProvider);
    if (authState is! AuthAuthenticated) {
      setState(() {
        _error = 'Please log in to update sales';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      // Get farmer and product names
      final farmer = _farmers.firstWhere((f) => f['id'] == _selectedFarmerId);
      final product = _products.firstWhere(
        (p) => p['id'] == _selectedProductId,
      );

      // Create updated sale data
      final updatedData = {
        'farmerId': _selectedFarmerId,
        'farmerName': farmer['name'],
        'productId': _selectedProductId,
        'productName': product['name'],
        'weight': double.parse(_weightController.text),
        'pricePerKg': _priceController.text,
        'fruitType': _fruitType,
        'saleDate': _saleDate,
        'amount': _totalAmount,
        'totalAmount': _totalAmount, // Keep both for compatibility
        'cooperativeCommission': _commission,
        'commission': _commission, // Keep both for compatibility
        'amountFarmerReceive': _farmerPayment,
        'notes': _notesController.text.trim(),
        'updatedAt': DateTime.now(),
        'updatedBy': authState.user.id,
      };

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('sales')
          .doc(widget.sale.id)
          .update(updatedData);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sale updated successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                // TODO: Navigate to sale details
              },
            ),
          ),
        );

        // Refresh activities and sales providers to show updated sale
        ref.invalidate(recentActivitiesProvider);
        ref.invalidate(recentSalesProvider);

        // Close modal and refresh
        Navigator.of(context).pop();
        if (widget.onSaleUpdated != null) {
          widget.onSaleUpdated!();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to update sale: $e';
          _isSubmitting = false;
        });
      }
    }
  }
}

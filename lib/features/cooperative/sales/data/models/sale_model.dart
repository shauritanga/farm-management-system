import 'package:agripoa/features/cooperative/sales/domain/entities/sale_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SaleModel extends SaleCoreEntity {
  const SaleModel({
    required super.id,
    required super.cooperativeId,
    required super.farmerId,
    required super.productId,
    required super.weight,
    required super.pricePerKg,
    required super.amount,
    required super.fruityType,
    super.qualityGrade,
    required super.cooperativeCommission,
    required super.amountFarmerReceive,
    required super.saleDate,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
    super.updatedBy,
  });

  factory SaleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SaleModel.fromMap(data, doc.id);
  }

  factory SaleModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return SaleModel(
      id: id ?? map['id'] ?? '',
      cooperativeId: map['cooperativeId'] ?? '',
      farmerId: map['farmerId'] ?? '',
      productId: map['productId'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      pricePerKg: map['pricePerKg']?.toString() ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      fruityType: map['fruityType'] ?? '',
      qualityGrade: map['qualityGrade'] ?? '',
      cooperativeCommission: (map['cooperativeCommission'] ?? 0.0).toDouble(),
      amountFarmerReceive: (map['amountFarmerReceive'] ?? 0.0).toDouble(),
      saleDate: _parseDateTime(map['saleDate']) ?? DateTime.now(),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt']) ?? DateTime.now(),
      createdBy: map['createdBy']?.toString() ?? '',
      updatedBy: map['updatedBy']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cooperativeId': cooperativeId,
      'farmerId': farmerId,
      'productId': productId,
      'weight': weight,
      'pricePerKg': pricePerKg,
      'amount': amount,
      'fruityType': fruityType,
      'qualityGrade': qualityGrade,
      'cooperativeCommission': cooperativeCommission,
      'amountFarmerReceive': amountFarmerReceive,
      'saleDate': Timestamp.fromDate(saleDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Parse DateTime from various formats (Timestamp, String, etc.)
  static DateTime? _parseDateTime(dynamic dateData) {
    if (dateData == null) return null;

    // Handle Firestore Timestamp
    if (dateData is Timestamp) {
      return dateData.toDate();
    }

    // Handle ISO string
    if (dateData is String) {
      try {
        return DateTime.parse(dateData);
      } catch (e) {
        return null;
      }
    }

    // Handle milliseconds since epoch
    if (dateData is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(dateData);
      } catch (e) {
        return null;
      }
    }

    return null;
  }
}

class Sale extends SaleCoreEntity {
  final String? farmerName;
  final String? productName;
  final double? totalAmount;

  const Sale({
    required super.id,
    required super.cooperativeId,
    required super.farmerId,
    required super.productId,
    required super.weight,
    required super.pricePerKg,
    required super.amount,
    required super.fruityType,
    super.qualityGrade,
    required super.cooperativeCommission,
    required super.amountFarmerReceive,
    required super.saleDate,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
    super.updatedBy,
    this.farmerName,
    this.productName,
    this.totalAmount,
  });

  factory Sale.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Sale.fromMap(data, doc.id);
  }

  factory Sale.fromMap(Map<String, dynamic> map, [String? id]) {
    return Sale(
      id: id ?? map['id'] ?? '',
      cooperativeId: map['cooperativeId'] ?? '',
      farmerId: map['farmerId'] ?? '',
      productId: map['productId'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      pricePerKg: map['pricePerKg']?.toString() ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      fruityType: map['fruityType'] ?? '',
      qualityGrade: map['qualityGrade'] ?? '',
      cooperativeCommission: (map['cooperativeCommission'] ?? 0.0).toDouble(),
      amountFarmerReceive: (map['amountFarmerReceive'] ?? 0.0).toDouble(),
      saleDate: SaleModel._parseDateTime(map['saleDate']) ?? DateTime.now(),
      createdAt: SaleModel._parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: SaleModel._parseDateTime(map['updatedAt']) ?? DateTime.now(),
      createdBy: map['createdBy']?.toString() ?? '',
      updatedBy: map['updatedBy']?.toString() ?? '',
      farmerName: map['farmerName']?.toString() ?? '',
      productName: map['productName']?.toString() ?? '',
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
    );
  }
}

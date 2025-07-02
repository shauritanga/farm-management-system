import 'package:equatable/equatable.dart';

class SaleCoreEntity extends Equatable {
  final String id;
  final String cooperativeId;
  final String farmerId;
  final String productId;
  final double weight;
  final String pricePerKg;
  final double amount;
  final String fruityType;
  final String? qualityGrade;
  final double cooperativeCommission; //70 Tsh per kg
  final double amountFarmerReceive; // amount - cooperativeCommission
  final DateTime saleDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const SaleCoreEntity({
    required this.id,
    required this.cooperativeId,
    required this.farmerId,
    required this.productId,
    required this.weight,
    required this.pricePerKg,
    required this.amount,
    required this.fruityType,
    this.qualityGrade,
    required this.cooperativeCommission,
    required this.amountFarmerReceive,
    required this.saleDate,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory SaleCoreEntity.fromJson(Map<String, dynamic> json) {
    return SaleCoreEntity(
      id: json['id'],
      cooperativeId: json['cooperativeId'],
      farmerId: json['farmerId'],
      productId: json['productId'],
      weight: json['weight'],
      pricePerKg: json['pricePerKg'],
      amount: json['amount'],
      fruityType: json['fruityType'],
      qualityGrade: json['qualityGrade'] ?? '',
      cooperativeCommission: json['cooperativeCommission'],
      amountFarmerReceive: json['amountFarmerReceives'],
      saleDate: DateTime.parse(json['saleDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
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
      'amountFarmerReceives': amountFarmerReceive,
      'saleDate': saleDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  @override
  List<Object?> get props => [
    id,
    cooperativeId,
    farmerId,
    productId,
    weight,
    pricePerKg,
    amount,
    fruityType,
    qualityGrade,
    cooperativeCommission,
    amountFarmerReceive,
    saleDate,
    createdAt,
    updatedAt,
    createdBy,
    updatedBy,
  ];
}

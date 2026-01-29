import 'package:flutter/foundation.dart';

/// Represents a completed purchase of digital gold
class PurchaseModel {
  final String goldWeight;       // in grams
  final double goldPricePerGram; // ₹ per gram
  final double subtotal;
  final double tax;
  final String orderId;
  final DateTime date;

  const PurchaseModel({
    required this.goldWeight,
    required this.goldPricePerGram,
    required this.subtotal,
    required this.tax,
    required this.orderId,
    required this.date,
  });

  double get total => subtotal + tax;

  Map<String, dynamic> toMap() => {
        'goldWeight': goldWeight,
        'goldPricePerGram': goldPricePerGram,
        'subtotal': subtotal,
        'tax': tax,
        'orderId': orderId,
        'date': date.toIso8601String(),
      };

  factory PurchaseModel.fromMap(Map<String, dynamic> map) => PurchaseModel(
        goldWeight: (map['goldWeight'] ?? 0).toDouble(),
        goldPricePerGram: (map['goldPricePerGram'] ?? 0).toDouble(),
        subtotal: (map['subtotal'] ?? 0).toDouble(),
        tax: (map['tax'] ?? 0).toDouble(),
        orderId: map['orderId'] ?? '',
        date: DateTime.parse(
          map['date'] ?? DateTime.now().toIso8601String(),
        ),
      );
}

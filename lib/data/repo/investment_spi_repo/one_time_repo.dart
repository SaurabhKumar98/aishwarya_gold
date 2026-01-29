import 'package:flutter/material.dart';

class OneTimeRepository {
  final double goldPrice;

  OneTimeRepository({required this.goldPrice});

  double calculateInvestment(double grams) => grams * goldPrice;

  double calculateGrams(double amount) => amount / goldPrice;
}

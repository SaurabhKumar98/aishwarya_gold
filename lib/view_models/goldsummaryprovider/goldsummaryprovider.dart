// view_models/goldsummaryprovider/goldsummaryprovider.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:aishwarya_gold/data/models/goldPriceSummary/goldpricesummarymodels.dart';
import 'package:aishwarya_gold/data/repo/goldpricesummaryrepo/goldpricerepo.dart';

class GoldPriceSummaryProvider with ChangeNotifier {
  final GoldPriceSummaryRepo _repository = GoldPriceSummaryRepo();

  bool _isLoading = false;
  GoldPriceSummary? _goldPriceSummary;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ---- Public getters ----------------------------------------------------
  double get currentPricePerGram =>
      _goldPriceSummary?.data?.currentPrice?.toDouble() ?? 0.0;

  double get percentageChange =>
      _goldPriceSummary?.data?.percentageChange ?? 0.0;

  int get difference => (_goldPriceSummary?.data?.difference ?? 0).toInt();


  String get trend => _goldPriceSummary?.data?.trend?.toLowerCase() ?? "stable";

  // Helper – returns the right icon & colour based on trend
  ({IconData icon, Color color}) get trendInfo {
    switch (trend) {
      case 'up':
        return (icon: Icons.trending_up_rounded, color: Colors.green);
      case 'down':
        return (icon: Icons.trending_down_rounded, color: Colors.red);
      default:
        return (icon: Icons.trending_flat_rounded, color: Colors.grey);
    }
  }

  // ------------------------------------------------------------------------
  Future<void> fetchGoldPriceSummary() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.fetchGoldPriceSummary();

      if (result.success && result.data != null) {
        _goldPriceSummary = result;
        log("Gold price summary fetched successfully");
      } else {
        _errorMessage = result.message;
        _goldPriceSummary = null;
      }
    } catch (e, st) {
      _errorMessage = e.toString();
      _goldPriceSummary = null;
      log("Error in provider: $e", stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
import 'package:aishwarya_gold/data/models/onetimesavingmodels/onetime_saving_models.dart';
import 'package:aishwarya_gold/data/models/onetimesavingmodels/onetimebyidmodels.dart';
import 'package:aishwarya_gold/data/repo/investment_spi_repo/ometimesaving_repo.dart';
import 'package:flutter/material.dart';

class OnetimeSavingProvider with ChangeNotifier {
  final OnetimesavingRepo _repository = OnetimesavingRepo();

  List<OneTimeSav> _onetime = [];
  List<OneTimeSav> get onetime => _onetime;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int _currentPage = 1;
  int _totalPages = 1;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  // 🔑 NEW: Store current plan details
  OneTimeByIdModels? _currentPlanDetails;
  OneTimeByIdModels? get currentPlanDetails => _currentPlanDetails;

  /// Fetch paginated One-Time Saving plans
  Future<void> fetchOnetimePlans({bool loadMore = false}) async {
    if (_isLoading) return;

    if (!loadMore) {
      _currentPage = 1;
      _onetime.clear();
      _hasMore = true;
      _error = null;
    } else {
      if (!_hasMore || _currentPage >= _totalPages) return;
      _currentPage++;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final OneTimeSavingPlan response =
          await _repository.getSavingPlan(_currentPage);

      final newData = response.data ?? [];
      _onetime.addAll(newData);

      if (response.meta != null) {
        _totalPages = response.meta!.totalPages ?? 1;
        _hasMore = _currentPage < _totalPages;
      } else {
        _hasMore = newData.isNotEmpty;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint("❌ Error fetching One-Time plans: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch a single plan by its ID and store it
  Future<OneTimeByIdModels?> fetchPlanById(String planId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final plan = await _repository.getPlanById(planId);
      
      if (plan != null) {
        _currentPlanDetails = plan;
        debugPrint("✅ Plan fetched successfully: ${plan.data?.customInvestmentId}");
        
        // Check if profitLoss is available
        if (plan.data?.profitLoss != null) {
          debugPrint("✅ Profit/Loss data available:");
          debugPrint("   Current Value: ₹${plan.data?.profitLoss?.currentValue}");
          debugPrint("   Profit/Loss: ₹${plan.data?.profitLoss?.profitLoss}");
          debugPrint("   Percentage: ${plan.data?.profitLoss?.profitLossPercentage}%");
          debugPrint("   Is Profitable: ${plan.data?.profitLoss?.isProfitable}");
        } else {
          debugPrint("⚠️ No profit/loss data in response");
        }
      }
      
      return plan;
    } catch (e) {
      _error = e.toString();
      debugPrint("❌ Error fetching plan by ID: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get the currently stored plan details
  OneTimeData? getCurrentPlanData() {
    return _currentPlanDetails?.data;
  }

  /// Clear current plan details
  void clearCurrentPlan() {
    _currentPlanDetails = null;
    notifyListeners();
  }

  /// 🧹 Clear all stored data and reset state
  void clearData() {
    _onetime = [];
    _currentPlanDetails = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
    debugPrint("✅ OnetimeSavingProvider cleared");
  }
}
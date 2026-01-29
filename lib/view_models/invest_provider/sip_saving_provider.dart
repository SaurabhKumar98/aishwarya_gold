import 'package:aishwarya_gold/data/models/reedem_sip_models/reedem_sip_modles.dart';
import 'package:flutter/material.dart';
import 'package:aishwarya_gold/data/models/sipsavingmodels/sip_saving_models.dart';
import 'package:aishwarya_gold/data/repo/investment_spi_repo/sip_saving_repo.dart';

class SipSavingProvider with ChangeNotifier {
  final SipSavingRepo _repository = SipSavingRepo();

  List<SipSaving> _sipPlans = [];
  List<SipSaving> get sipPlans => _sipPlans;

  // Store the currently selected plan details
  ReedemSipModels? _currentPlanDetails;
  ReedemSipModels? get currentPlanDetails => _currentPlanDetails;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  /// Fetch SIP plans with pagination
  Future<void> fetchSipPlans({bool loadMore = false}) async {
    if (_isLoading) return;

    if (!loadMore) {
      _currentPage = 1;
      _sipPlans.clear();
      _error = null;
      _hasMore = true;
    } else {
      if (!_hasMore || _currentPage >= _totalPages) return;
      _currentPage++;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final SipSavingPlan response = await _repository.getSavingPlan(_currentPage);

      final newPlans = response.data ?? [];
      if (newPlans.isEmpty) {
        _hasMore = false;
      } else {
        _sipPlans.addAll(newPlans);
      }

      if (response.meta?.totalPages != null) {
        _totalPages = response.meta!.totalPages!;
        _hasMore = _currentPage < _totalPages;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint("❌ Error fetching SIP plans: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch a single SIP plan by ID and store it
 Future<ReedemSipModels?> fetchPlanDetailsById(String planId) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final plan = await _repository.getSavingPlanById(planId);
    _currentPlanDetails = plan;
    _isLoading = false;
    notifyListeners();
    return plan;
  } catch (e) {
    _error = e.toString();
    _currentPlanDetails = null;
    debugPrint("❌ Error fetching plan by ID: $e");
    _isLoading = false;
    notifyListeners();
    return null;
  }
}

  /// Clear current plan details
  void clearCurrentPlan() {
    _currentPlanDetails = null;
    notifyListeners();
  }
    void clearData() {
    _sipPlans = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
    debugPrint("✅ SipSavingProvider cleared");
  }
}
import 'package:aishwarya_gold/data/models/history_models/history_models.dart';
import 'package:aishwarya_gold/data/repo/history_repo/history_repo.dart';
import 'package:flutter/material.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryRepository _repository = HistoryRepository();

  // State variables
  HistoryModels? _historyModels;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  HistoryModels? get historyModels => _historyModels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


  List<AgPlan> get agPlanHistory => _historyModels?.data?.agPlan ?? [];
  List<SipPlan> get sipHistory => _historyModels?.data?.sipPlan ?? [];
  List<OneTimeInvestment> get oneTimeHistory => 
      _historyModels?.data?.oneTimeInvestment ?? [];


  List<dynamic> get agDailyHistory => 
      agPlanHistory.where((plan) => plan.planId?.type == 'daily').toList();
  
  List<dynamic> get agMonthlyHistory => 
      agPlanHistory.where((plan) => plan.planId?.type == 'monthly').toList();

  // Fetch user plans
  Future<void> fetchUserPlans(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _historyModels = await _repository.fetchUserPlans(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refreshData(String userId) async {
    await fetchUserPlans(userId);
  }

  // Clear data
  void clearData() {
    _historyModels = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
import 'package:aishwarya_gold/data/models/agplanbyidmodels/agplanbymodels.dart';
import 'package:aishwarya_gold/data/models/savingagplanmodels/agsavingmodels.dart';
import 'package:aishwarya_gold/data/repo/savinggplansrepo/savingagplanrepo.dart';
import 'package:flutter/foundation.dart';

enum AgSavingState {
  initial,
  loading,
  loaded,
  error
}

class AgSavingProvider with ChangeNotifier {
  AgPlanSavingModels? _savingPlan;
  AgPlanSavingModels? get savingPlan => _savingPlan;

  bool _loading = false;
  bool get loading => _loading;

  // ✅ Use AgPlanByIdModels for single plan data
  AgPlanByIdModels? _planData;
  AgPlanByIdModels? get planData => _planData;

  AgSavingState _state = AgSavingState.initial;
  AgSavingState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final Savingagplagrepo _repo = Savingagplagrepo();

  Future<void> fetchSavingPlan() async {
    _state = AgSavingState.loading;
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repo.getSavingPlan();
      _savingPlan = response;
      _state = AgSavingState.loaded;
    } catch (e) {
      _state = AgSavingState.error;
      _errorMessage = e.toString();
    } finally {
      _loading = false;
    }

    notifyListeners();
  }

  // ✅ Fetch plan by ID and store in _planData
  Future<void> fetchPlanById(String planId) async {
    _loading = true;
    _errorMessage = null;
    _planData = null; // Clear previous data
    notifyListeners();

    try {
      final plan = await _repo.getAgPlanById(planId);
      _planData = plan; // ✅ Store the fetched plan
      _errorMessage = null;
      debugPrint("✅ Plan fetched successfully: ${plan.toString()}");
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("❌ Error fetching plan by ID: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _savingPlan = null;
    _planData = null;
    _state = AgSavingState.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
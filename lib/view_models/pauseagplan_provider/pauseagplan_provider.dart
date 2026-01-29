
import 'package:aishwarya_gold/data/models/pauseagplan_models/pauseagplan_modles.dart';
import 'package:aishwarya_gold/data/repo/pauseagplan_repo/pauseaplan_repo.dart';

import 'package:flutter/material.dart';

class PauseAgPlanProvider with ChangeNotifier {
  final PauseAgPlanRepo _repo = PauseAgPlanRepo();

  bool _loading = false;
  String? _errorMessage;
  PauseAgPlanModels? _pauseData;
  ResumeAgPlanModels? _resumeData;

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  PauseAgPlanModels? get pauseData => _pauseData;
  ResumeAgPlanModels? get resumeData => _resumeData;

  /// Pause plan with selected duration
  Future<bool> pausePlan(String id, int pauseDurationMonths) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repo.pausePlan(id, pauseDurationMonths);
      _pauseData = data;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// Resume paused plan with same duration parameter
  Future<bool> resumePlan(String id, int pauseDurationMonths) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repo.resumePlan(id, pauseDurationMonths);
      _resumeData = data;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  
  
  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _loading = false;
    _errorMessage = null;
    _pauseData = null;
    _resumeData = null;
    notifyListeners();
  }
}
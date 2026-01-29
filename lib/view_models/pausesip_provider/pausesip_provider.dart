import 'package:aishwarya_gold/data/repo/pausesip_repo/pausesip_repo.dart';
import 'package:flutter/material.dart';

class PauseSipProvider with ChangeNotifier {
  final PauseSipRepo _repo = PauseSipRepo();

  bool _isLoading = false;
  String? _error;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> pauseSipPlan(String planId, int months) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repo.pauseSipPlan(planId, months);
      if (response["success"] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response["message"] ?? "Failed to pause plan";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resumeSipPlan(String planId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repo.resumeSipPlan(planId);
      if (response["success"] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response["message"] ?? "Failed to resume plan";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

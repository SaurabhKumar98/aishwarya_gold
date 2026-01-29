// lib/view_models/reedemption_provider/reedemption_provider.dart
// VERSION WITH PERSISTENT STORAGE using SharedPreferences

import 'dart:convert';
import 'package:aishwarya_gold/data/models/reedemptionmodels/reedemption_models.dart';
import 'package:aishwarya_gold/data/models/reedemptionmodels/reedemptionstatus_modles.dart';
import 'package:aishwarya_gold/data/repo/reedemption_repo/reedemption_repo.dart';
import 'package:aishwarya_gold/utils/exports/exports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RedemptionProvider extends ChangeNotifier {
  final RedemptionRepository _repo = RedemptionRepository();

  // SharedPreferences keys
  static const String _storeRedemptionKey = 'store_redemption_cache';
  static const String _currentRedemptionKey = 'current_redemption';

  // ── API responses ───────────────────────────────────────────────────────
  RedemptionRequestModel? redemptionResponse;
  RedemptionStatusModels? redemptionStatusResponse;

  // ── UI state ───────────────────────────────────────────────────────────
  String? errorMessage;
  bool _loading = false;
  bool get isLoading => _loading;

  bool _isLoggedOut = false;
  bool get isLoggedOut => _isLoggedOut;

  // ── Persistent redemption state (survives rebuilds) ─────────────────────
  String? _currentRedemptionId;
  String? _currentRedemptionStatus;
  String? _currentPlanId;
  String? _currentPlanType;
  String? _currentStoreId;

  String? get currentRedemptionId => _currentRedemptionId;
  String? get currentRedemptionStatus => _currentRedemptionStatus;
  String? get currentPlanId => _currentPlanId;
  String? get currentPlanType => _currentPlanType;
  String? get currentStoreId => _currentStoreId;

  // ── Caches ──────────────────────────────────────────────────────────────
  final Map<String, String> _planRedemptionCache = {};
  final Map<String, Map<String, dynamic>> _storeRedemptionCache = {};

  bool _isInitialized = false;

  // ══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION: Load cached data from SharedPreferences
  // Call this in your app's initialization (e.g., main.dart or splash screen)
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load store redemption cache
      final storeCache = prefs.getString(_storeRedemptionKey);
      if (storeCache != null) {
        final decoded = jsonDecode(storeCache) as Map<String, dynamic>;
        _storeRedemptionCache.clear();
        decoded.forEach((key, value) {
          _storeRedemptionCache[key] = Map<String, dynamic>.from(value);
        });
        debugPrint('✅ Loaded ${_storeRedemptionCache.length} cached redemptions');
      }
      
      // Load current redemption
      final currentCache = prefs.getString(_currentRedemptionKey);
      if (currentCache != null) {
        final decoded = jsonDecode(currentCache) as Map<String, dynamic>;
        _currentRedemptionId = decoded['redemptionId'];
        _currentRedemptionStatus = decoded['status'];
        _currentPlanId = decoded['planId'];
        _currentPlanType = decoded['planType'];
        _currentStoreId = decoded['storeId'];
        debugPrint('✅ Loaded current redemption: $_currentRedemptionId');
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading cached redemptions: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SAVE: Persist cache to SharedPreferences
  // ══════════════════════════════════════════════════════════════════════════
Future<void> _saveToPrefs() async {
  if (_isLoggedOut) {
    debugPrint('🚫 Skip saving redemption cache (user logged out)');
    return;
  }

  try {
    final prefs = await SharedPreferences.getInstance();

    if (_storeRedemptionCache.isNotEmpty) {
      await prefs.setString(
        _storeRedemptionKey,
        jsonEncode(_storeRedemptionCache),
      );
    } else {
      await prefs.remove(_storeRedemptionKey);
    }

    if (_currentRedemptionId != null && _currentPlanId != null) {
      await prefs.setString(
        _currentRedemptionKey,
        jsonEncode({
          'redemptionId': _currentRedemptionId,
          'status': _currentRedemptionStatus,
          'planId': _currentPlanId,
          'planType': _currentPlanType,
          'storeId': _currentStoreId,
        }),
      );
    } else {
      await prefs.remove(_currentRedemptionKey);
    }

    debugPrint('💾 Saved redemption cache to SharedPreferences');
  } catch (e) {
    debugPrint('❌ Error saving to prefs: $e');
  }
}


  // ══════════════════════════════════════════════════════════════════════════
  // Get plan redemption with store information
  // ══════════════════════════════════════════════════════════════════════════
  Map<String, dynamic>? getPlanRedemptionWithStore(String planId) {
    debugPrint('🔍 getPlanRedemptionWithStore called for planId: $planId');
    
    // Check cached store-specific redemption info
    if (_storeRedemptionCache.containsKey(planId)) {
      final cached = _storeRedemptionCache[planId];
      debugPrint('✅ Found cached redemption: $cached');
      return cached;
    }
    
    // Check if current redemption matches this plan
    if (_currentPlanId == planId && 
        _currentRedemptionId != null && 
        _currentRedemptionStatus != null &&
        _currentStoreId != null) {
      final result = {
        'storeId': _currentStoreId!,
        'status': _currentRedemptionStatus!,
        'redemptionId': _currentRedemptionId!,
      };
      debugPrint('✅ Using current redemption: $result');
      _storeRedemptionCache[planId] = result;
      _saveToPrefs(); // Persist
      return result;
    }
    
    debugPrint('ℹ️ No redemption found for planId: $planId');
    return null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Update store redemption and persist
  // ══════════════════════════════════════════════════════════════════════════
  void updateStoreRedemption({
    required String planId,
    required String storeId,
    required String status,
    required String redemptionId,
  }) {
    _storeRedemptionCache[planId] = {
      'storeId': storeId,
      'status': status,
      'redemptionId': redemptionId,
    };
    debugPrint('💾 Cached store redemption: planId=$planId, storeId=$storeId, status=$status');
    _saveToPrefs(); // Persist to disk
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Clear store redemption and persist
  // ══════════════════════════════════════════════════════════════════════════
  void clearStoreRedemption(String planId) {
    _storeRedemptionCache.remove(planId);
    debugPrint('🗑️ Cleared store redemption cache for planId: $planId');
    _saveToPrefs(); // Persist
    notifyListeners();
  }

  // ── CREATE ───────────────────────────────────────────────────────────────
Future<bool> createRedemptionRequest({
  String? planId,
  required String planType,
  required String storeId,
  double? amount,
}) async {
  _setLoading(true);

  try {
    redemptionResponse = await _repo.createRedemptionRequest(
      planId: planType == 'WalletBalance' ? null : planId,
      planType: planType,
      storeId: storeId,
      amount: planType == 'WalletBalance' ? amount : null,
    );

    final success = redemptionResponse?.success == true;

    if (success) {
      final id = redemptionResponse?.data?.id;

      if (id != null) {
        // For WalletBalance there is no planId coming from API; create a stable plan key per store
        final planKey = planType == 'WalletBalance' ? 'wallet_balance_$storeId' : (planId ?? '');

        setRedemptionInProgress(
          id,
          'pending',
          planKey,
          planType,
          storeId,
        );

        updateStoreRedemption(
          planId: planKey,
          storeId: storeId,
          status: 'pending',
          redemptionId: id,
        );
      }
    } else {
      // Capture server-provided message to present to the UI
      errorMessage = redemptionResponse?.message ?? 'Failed to create redemption request';
    }

    return success;
  } catch (e) {
    errorMessage = e.toString();
    return false;
  } finally {
    _setLoading(false);
  }
}

  // ── CANCEL ───────────────────────────────────────────────────────────────
  Future<bool> cancelRedemptionRequest(String redemptionId) async {
    _setLoading(true);
    try {
      final resp = await _repo.cancelRedemptionRequest(redemptionId);
      redemptionResponse = resp;

      final success = resp.success == true;
      if (success) {
        if (_currentPlanId != null) {
          _planRedemptionCache[_currentPlanId!] = 'none';
          clearStoreRedemption(_currentPlanId!);
        }
        clearRedemption();
      }
      return success;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── GET STATUS ───────────────────────────────────────────────────────────
  Future<RedemptionStatusModels?> getRedemptionStatus(String redemptionId) async {
    _setLoading(true);
    try {
      final statusResponse = await _repo.getStatusResponse(redemptionId);
      redemptionStatusResponse = statusResponse;

      final status = statusResponse?.data?.status?.toLowerCase();
      if (status != null && _currentPlanId != null && _currentStoreId != null) {
        setRedemptionInProgress(
          redemptionId, 
          status, 
          _currentPlanId!, 
          _currentPlanType ?? '',
          _currentStoreId!,
        );
        _planRedemptionCache[_currentPlanId!] = status;
        updateStoreRedemption(
          planId: _currentPlanId!,
          storeId: _currentStoreId!,
          status: status,
          redemptionId: redemptionId,
        );
      }

      notifyListeners();
      return statusResponse;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchRedemptionStatusForPlan(String planId) async {
    debugPrint('🔄 fetchRedemptionStatusForPlan called for: $planId');
    
    if (_storeRedemptionCache.containsKey(planId)) {
      debugPrint('✅ Already have cached status for $planId');
      return;
    }
    
    if (_currentPlanId == planId && 
        _currentRedemptionId != null && 
        _currentStoreId != null) {
      debugPrint('✅ Using current active redemption');
      updateStoreRedemption(
        planId: planId,
        storeId: _currentStoreId!,
        status: _currentRedemptionStatus ?? 'pending',
        redemptionId: _currentRedemptionId!,
      );
      return;
    }
    
    debugPrint('ℹ️ No cached redemption for planId: $planId');
  }

  String getLatestPlanRedemptionStatus(String planId) {
    final status = _planRedemptionCache[planId] ?? 'none';
    debugPrint('📦 Cache lookup for $planId: $status');
    return status;
  }

  void clearPlanRedemptionCache(String planId) {
    _planRedemptionCache.remove(planId);
    clearStoreRedemption(planId);
    notifyListeners();
  }

  String checkPlanRedemptionStatus(String planId) {
    if (_currentPlanId == planId && _currentRedemptionStatus != null) {
      return _currentRedemptionStatus!;
    }
    if (_planRedemptionCache.containsKey(planId)) {
      return _planRedemptionCache[planId]!;
    }
    return 'none';
  }

  void clearPlanStatus(String planId) {
    _planRedemptionCache.remove(planId);
    clearStoreRedemption(planId);
    if (_currentPlanId == planId) {
      clearRedemption();
    }
    notifyListeners();
  }

  void setRedemptionInProgress(
    String id, 
    String status, 
    String planId, 
    String planType,
    String storeId,
  ) {
    _currentRedemptionId = id;
    _currentRedemptionStatus = status;
    _currentPlanId = planId;
    _currentPlanType = planType;
    _currentStoreId = storeId;
    _planRedemptionCache[planId] = status;
    _saveToPrefs(); // Persist
    notifyListeners();
  }

  Future<bool> cancelRedemptionForCurrentPlan() async {
    if (_currentRedemptionId == null) {
      errorMessage = "No active redemption request found";
      return false;
    }
    return await cancelRedemptionRequest(_currentRedemptionId!);
  }

  void clearRedemption() {
    _currentRedemptionId = null;
    _currentRedemptionStatus = null;
    _currentPlanId = null;
    _currentPlanType = null;
    _currentStoreId = null;
    _saveToPrefs(); // Persist
    notifyListeners();
  }
  


  Future<void> clearOnLogout() async {
  _isLoggedOut = true;

  _storeRedemptionCache.clear();
  _planRedemptionCache.clear();

  _currentRedemptionId = null;
  _currentRedemptionStatus = null;
  _currentPlanId = null;
  _currentPlanType = null;
  _currentStoreId = null;

  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_storeRedemptionKey);
  await prefs.remove(_currentRedemptionKey);

  debugPrint('🧹 RedemptionProvider cleared on logout');
  notifyListeners();
}


  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void clearError() => errorMessage = null;
}

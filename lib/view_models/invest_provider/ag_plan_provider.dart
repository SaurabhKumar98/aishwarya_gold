import 'package:aishwarya_gold/data/models/agplanmodels/purchase_agplan_modles.dart';
import 'package:aishwarya_gold/data/repo/investment_spi_repo/ag_repo.dart';
import 'package:aishwarya_gold/data/models/agplanmodels/agplanmodel.dart';
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum AgPlanType { weekly, monthly }

class AgPlanProvider with ChangeNotifier {
  final AgRepository _repository = AgRepository();

  /// Selected Plan Type
  AgPlanType _selectedType = AgPlanType.monthly;
  DateTime _selectedDate = DateTime.now();

  AgPlanType get selectedType => _selectedType;
  DateTime get selectedDate => _selectedDate;

  void toggleType(AgPlanType type) {
    _selectedType = type;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// API Data
  bool _isLoading = false;
  String? _error;
  List<Plan> _monthlyPlans = [];
  List<Plan> _weeklyPlans = [];
  Plan? _selectedPlan;
  PurchaseAgModel? _purchaseResult;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Plan> get monthlyPlans => _monthlyPlans;
  List<Plan> get dailyPlans => _weeklyPlans;
  Plan? get selectedPlan => _selectedPlan;
  PurchaseAgModel? get purchaseResult => _purchaseResult;

  List<Plan> get filteredPlans =>
      _selectedType == AgPlanType.weekly ? _weeklyPlans : _monthlyPlans;

  /// Purchased Plans (Local)
  final List<Map<String, dynamic>> _purchasedPlans = [];
  List<Map<String, dynamic>> get purchasedPlans =>
      List.unmodifiable(_purchasedPlans);

  void addAgPlan({
    required Plan plan,
    required DateTime startDate,
    required DateTime endDate,
    required AgPlanType planType,
    required String orderId,
    required String paymentId,
    required String signature,
  }) {
    _purchasedPlans.add({
      "razorpayOrderId": orderId,
      "razorpayPaymentId": paymentId,
      "razorpaySignature": signature,
      'plan': plan,
      'startDate': startDate,
      'endDate': endDate,
      'planType': planType,
    });
    notifyListeners();
  }

  /// Fetch Plans from API
  Future<void> fetchPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.fetchAgPlans(
        type: _selectedType.name,
        page: 1,
        limit: 10,
      );

      if (response != null && response.data != null) {
        if (_selectedType == AgPlanType.monthly) {
          _monthlyPlans = response.data!;
        } else {
          _weeklyPlans = response.data!;
        }
      } else {
        _error = "No plans available.";
      }
    } catch (e) {
      _error = "Failed to fetch plans: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPlanById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final plan = await _repository.fetchAgPlanById(id);
      if (plan != null) {
        _selectedPlan = plan;
      } else {
        _error = "Plan not found";
      }
    } catch (e) {
      _error = "Failed to fetch plan: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────
  // NEW: AG Plan Subscription Flow (Similar to SIP)
  // ──────────────────────────────────────────────────────────────

  /// Step 1: Create AG Plan subscription - returns subscriptionId
  Future<Map<String, dynamic>?> createAgPlanSubscription({
    required String userId,
    required String planId,
    required DateTime startDate,
  }) async {
    final url = Uri.parse("${AppUrl.localUrl}/user/agplans/$userId/buy");
    
    final body = {
      "planId": planId,
      "startDate": startDate.toIso8601String(), // Format: "2025-11-10T00:00:00.000Z"
    };

    print("🟡 [CREATE AG PLAN] POST → $url");
    print("   Body: $body");

    try {
      final token = await SessionManager.getAccessToken();
      if (token == null) {
        print("❌ [CREATE AG PLAN] No access token");
        return null;
      }

      final resp = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print("📥 [CREATE AG PLAN] Response: ${resp.statusCode}");
      print("   Body: ${resp.body}");

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final json = jsonDecode(resp.body);
        if (json['success'] == true && json['data'] != null) {
          return json['data']; // Contains subscriptionId and other details
        }
      } else {
        print("❌ [CREATE AG PLAN] Error response: ${resp.body}");
      }
    } catch (e) {
      print("🔴 [CREATE AG PLAN] Error: $e");
    }
    return null;
  }

  /// Step 2: Verify AG Plan subscription after Razorpay payment
Future<bool> verifyAgPlanSubscription({
  required String userId,
  required String planId,
  required DateTime startDate,
  required String subscriptionId,
  required String paymentId,
  required String signature,
}) async {
  final url = Uri.parse("${AppUrl.localUrl}/user/agplans/$userId/verify");

  final body = {
    "planId": planId,
    "startDate": startDate.toIso8601String(),
    "razorpaySubscriptionId": subscriptionId,
    "razorpayPaymentId": paymentId,
    "razorpaySignature": signature,
  };

  print("🟢 [VERIFY AG PLAN] POST → $url");
  print("   Body: $body");

  try {
    final token = await SessionManager.getAccessToken();
    if (token == null) {
      print("❌ [VERIFY AG PLAN] No access token");
      return false;
    }

    final resp = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print("📥 [VERIFY AG PLAN] Response: ${resp.statusCode}");
    print("   Body: ${resp.body}");

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final json = jsonDecode(resp.body);
      return json['success'] == true;
    }
  } catch (e) {
    print("🔴 [VERIFY AG PLAN] Error: $e");
  }
  return false;
}


  // ──────────────────────────────────────────────────────────────
  // OLD METHOD: Keep for backward compatibility (if needed)
  // ──────────────────────────────────────────────────────────────
  
  /// Purchase Plan (Old method - may not be used if using subscription flow)
  Future<void> purchasePlan({
    required String userId,
    required String planId,
    required DateTime startDate,
    required DateTime endDate,
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    _isLoading = true;
    _error = null;
    _purchaseResult = null;
    notifyListeners();

    try {
      final purchase = await _repository.purchaseAgPlan(
        userId: userId,
        planId: planId,
        startDate: startDate,
        endDate: endDate,
      );
      if (purchase != null && purchase.success == true) {
        _purchaseResult = purchase;
        addAgPlan(
          plan: _selectedPlan!,
          startDate: startDate,
          endDate: endDate,
          planType: _selectedType,
          orderId: orderId,
          paymentId: paymentId,
          signature: signature,
        );
      } else {
        _error = purchase?.message ?? "Failed to purchase plan";
      }
    } catch (e) {
      _error = "Error purchasing plan: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Helpers
  Plan? getPlanByAmount(int amount) {
    final list =
        _selectedType == AgPlanType.weekly ? _weeklyPlans : _monthlyPlans;
    try {
      return list.firstWhere((plan) => plan.amount == amount);
    } catch (_) {
      return null;
    }
  }
}
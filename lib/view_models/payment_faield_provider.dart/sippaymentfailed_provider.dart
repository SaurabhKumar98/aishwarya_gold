import 'package:aishwarya_gold/data/repo/paymentfailedrepo/paymentfailed_repo.dart';
import 'package:flutter/material.dart';

/// Provider to handle retry payments for failed SIP installments.
/// Includes initiation, verification, and detailed error handling.
class SipRetryPaymentProvider with ChangeNotifier {
  final SipRetryPaymentRepo _repository = SipRetryPaymentRepo();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Order details for tracking and verification
  String? _currentOrderId;
  double? _currentAmount;
  String? _currentCurrency;
  Map<String, dynamic>? _orderNotes;

  String? get currentOrderId => _currentOrderId;
  double? get currentAmount => _currentAmount;
  String? get currentCurrency => _currentCurrency;
  Map<String, dynamic>? get orderNotes => _orderNotes;

  /// 🔹 Initiate retry payment for a failed installment
  Future<Map<String, dynamic>?> initiateRetryPayment({
    required String planId,
    required int installmentNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    debugPrint("🟡 [SipRetryPaymentProvider] Initiating retry payment...");
    debugPrint("   ▶ Plan ID: $planId");
    debugPrint("   ▶ Installment Number: $installmentNumber");

    try {
      final response = await _repository.initiateRetryPayment(
        planId: planId,
        installmentNumber: installmentNumber,
      );

      debugPrint("🟢 [Provider] API Response: $response");

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        // Extract and store order details
        _currentOrderId = data['orderId']?.toString();
        _currentAmount = (data['amount'] as num?)?.toDouble();
        _currentCurrency = data['currency']?.toString();
        _orderNotes = Map<String, dynamic>.from(data['notes'] ?? {});

        debugPrint("✅ [Provider] Retry Payment Initiated Successfully");
        debugPrint("   ▶ Order ID: $_currentOrderId");
        debugPrint("   ▶ Amount: $_currentAmount");
        debugPrint("   ▶ Currency: $_currentCurrency");

        _isLoading = false;
        notifyListeners();
        return data;
      } else {
        _error = response['message'] ?? 'Failed to initiate payment.';
        debugPrint("🔴 [Provider] Error: $_error");

        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e, st) {
      _error = _getUserFriendlyError(e.toString());
      debugPrint("❌ [Provider] Exception: $e");
      debugPrint("🧾 StackTrace: $st");

      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// 🔹 Verify retry payment after Razorpay success
  Future<bool> verifyRetryPayment({
    required String planId,
    required int installmentNumber,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    debugPrint("🟡 [SipRetryPaymentProvider] Verifying payment...");
    debugPrint("   ▶ Plan ID: $planId");
    debugPrint("   ▶ Installment: $installmentNumber");
    debugPrint("   ▶ Razorpay Order: $razorpayOrderId");
    debugPrint("   ▶ Razorpay Payment: $razorpayPaymentId");

    try {
      final response = await _repository.verifyRetryPayment(
        planId: planId,
        installmentNumber: installmentNumber,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );

      debugPrint("🟢 [Provider] Verification Response: $response");

      if (response['success'] == true) {
        debugPrint("✅ [Provider] Payment verified successfully!");
        _clearOrderData();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Payment verification failed.';
        debugPrint("🔴 [Provider] Verification failed: $_error");

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, st) {
      _error = _getUserFriendlyError(e.toString());
      debugPrint("❌ [Provider] Verification Exception: $e");
      debugPrint("🧾 StackTrace: $st");

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 🔹 Convert technical errors to user-friendly messages
  String _getUserFriendlyError(String error) {
    final lower = error.toLowerCase();

    if (lower.contains('network') || lower.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (lower.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (lower.contains('401') || lower.contains('unauthorized')) {
      return 'Session expired. Please login again.';
    } else if (lower.contains('404')) {
      return 'Payment service unavailable. Please try again later.';
    }
    return 'Something went wrong. Please try again or contact support.';
  }

  /// 🔹 Reset all stored order data
  void _clearOrderData() {
    _currentOrderId = null;
    _currentAmount = null;
    _currentCurrency = null;
    _orderNotes = null;
  }

  /// 🔹 Clear only error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 🔹 Full reset (loading + error + order data)
  void reset() {
    _isLoading = false;
    _error = null;
    _clearOrderData();
    notifyListeners();
  }
}

import 'package:aishwarya_gold/data/models/sip_subscriptionmodels/sipsubmodels.dart';
import 'package:aishwarya_gold/data/repo/sipsubscriptionrepo/sipsubscriptionrepo.dart';
import 'package:flutter/material.dart';

/// 🎯 SIP Subscription Provider
/// Manages SIP subscription state and API calls
class SipsubscriptionProvider with ChangeNotifier {
  final SipRepository _repo = SipRepository();
  
  // 🔄 Loading state
  bool isLoading = false;
  
  // 📦 Current SIP response
  SIPSubscriptionResponse? sipResponse;
  
  // ❌ Error message
  String? errorMessage;

  /// 🚀 Create SIP Subscription
  /// Step 1: Creates subscription on backend and gets subscription ID
  Future<void> createSip({
    required String planName,
    required int investmentAmount,
    required String frequency,
    required String startDate,
  }) async {
    // 🔄 Set loading state
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print("🟢 [SIP Provider] Creating SIP subscription...");
      print("   planName: $planName");
      print("   investmentAmount: $investmentAmount");
      print("   frequency: $frequency");
      print("   startDate: $startDate");

      // 📡 Call repository to create subscription
      final response = await _repo.createSipSubscription(
        planName: planName,
        investmentAmount: investmentAmount,
        frequency: frequency,
        startDate: startDate,
      );

      if (response != null) {
        // ✅ Success
        sipResponse = response;
        print("✅ [SIP Provider] Subscription created successfully");
        print("   subscriptionId: ${response.data?.razorpay?.subscriptionId}");
      } else {
        // ❌ Failed
        errorMessage = "Failed to create SIP subscription";
        print("❌ [SIP Provider] Failed to create subscription");
      }
    } catch (e) {
      // 🔴 Exception
      errorMessage = "Error: $e";
      print("🔴 [SIP Provider] Exception: $e");
    } finally {
      // 🏁 Always clear loading state
      isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Verify SIP Payment
  /// Step 2: Verifies mandate payment after Razorpay success callback
  Future<bool> verifySipPayment({
    required String userId,
    required String razorpaySubscriptionId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String planName,
    required DateTime startDate,
    required double investmentAmount,
    required String frequency,
  }) async {
    try {
      print("🟢 [SIP Provider] Verifying payment...");

      // 📡 Call repository to verify payment
      final success = await _repo.verifySipPayment(
        userId: userId,
        razorpaySubscriptionId: razorpaySubscriptionId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        planName: planName,
        startDate: startDate,
        investmentAmount: investmentAmount,
        frequency: frequency,
      );

      if (success) {
        print("✅ [SIP Provider] Payment verified successfully");
      } else {
        print("❌ [SIP Provider] Payment verification failed");
      }

      return success;
    } catch (e) {
      print("🔴 [SIP Provider] Verification exception: $e");
      return false;
    }
  }

  /// 🗑️ Clear provider state
  void clear() {
    sipResponse = null;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }
}
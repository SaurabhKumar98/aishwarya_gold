import 'package:aishwarya_gold/core/storage/sharedpreference.dart' show SessionManager;
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:aishwarya_gold/view_models/razorpay_provider/razorpay_provider.dart';

/// Centralized Razorpay Service
/// Handles all Razorpay payment operations across the app
class RazorpayService {
  late Razorpay _razorpay;
  String _orderId = "";
  
  // Callbacks
  Function(PaymentSuccessResponse)? _onSuccess;
  Function(PaymentFailureResponse)? _onError;
  Function(ExternalWalletResponse)? _onExternalWallet;

  /// Initialize Razorpay instance
  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _onSuccess = onSuccess;
    _onError = onError;
    _onExternalWallet = onExternalWallet;

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("✅ [RazorpayService] Payment Success");
    print("   paymentId: ${response.paymentId}");
    print("   orderId: ${response.orderId}");
    print("   signature: ${response.signature}");
    
    if (_onSuccess != null) {
      _onSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("❌ [RazorpayService] Payment Error");
    print("   code: ${response.code}");
    print("   message: ${response.message}");
    
    if (_onError != null) {
      _onError!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("🔷 [RazorpayService] External Wallet: ${response.walletName}");
    
    if (_onExternalWallet != null) {
      _onExternalWallet!(response);
    }
  }

  Future<void> openCheckout({
    String? subscriptionId,
    required int amount,
    required String description,
    String? userName,
    String? userContact,
  }) async {
    try {
      print("🟡 [RazorpayService] Opening checkout...");
      
      Map<String, dynamic> options;
      
      // ✅ CRITICAL: Check subscription mode by subscriptionId presence AND amount
      if (subscriptionId != null && subscriptionId.isNotEmpty) {
        // ========== SUBSCRIPTION PAYMENT ==========
        print("🟡 [RazorpayService] Using SUBSCRIPTION mode");
        print("   subscriptionId: $subscriptionId");
        print("   Amount parameter ignored - using subscription plan amount");
        
        options = {
          'key': 'rzp_live_RbbG6ETAwitsPC',
          'subscription_id': subscriptionId,  // ✅ Only subscription_id
          'currency': "INR",
          'name': 'Aishwarya Gold',
          'description': description,
          'prefill': {
            'contact': userContact ?? "7903886623",
            'name': userName ?? "Saurabh"
          },
          'external': {
            'wallets': ['paytm'],
          },
          "timeout": 200,
        };
        // ❌ CRITICAL: DO NOT add 'amount' or 'order_id' for subscriptions
        
      } else {
        // ========== ONE-TIME PAYMENT ==========
        print("🟡 [RazorpayService] Using ONE-TIME payment mode");
        print("   amount: ₹$amount");
        
        // Create order for one-time payment
        String? orderId = await RazorpayProvider.createOrder(amount);
        
        if (orderId == null || orderId.isEmpty) {
          print("🔴 [RazorpayService] Failed to create order");
          throw Exception("Failed to create payment order");
        }

        _orderId = orderId;
        print("🟡 [RazorpayService] Order created: $_orderId");

        // Convert amount to paise for Razorpay checkout
        final int amountInPaise = amount * 100;
        
        options = {
          'key': 'rzp_test_RbX65RuyVPVf9h',
          'amount': amountInPaise,  // ✅ Amount in paise
          'currency': "INR",
          'name': 'Aishwarya Gold',
          'description': description,
          'order_id': _orderId,  // ✅ Order ID for one-time payment
          'prefill': {
            'contact': userContact ?? "7903886623",
            'name': userName ?? "Saurabh"
          },
          'external': {
            'wallets': ['paytm'],
          },
          "timeout": 200,
        };
      }

      print("🟡 [RazorpayService] Opening Razorpay with options:");
      print("   Keys: ${options.keys.join(', ')}");
      _razorpay.open(options);
      
    } catch (e, st) {
      print("🔴 [RazorpayService] Exception: $e");
      print(st);
      rethrow;
    }
  }

  /// Dispose and clear all listeners
  void dispose() {
    print("🟣 [RazorpayService] Disposing");
    _razorpay.clear();
    _onSuccess = null;
    _onError = null;
    _onExternalWallet = null;
  }

  /// Get current order ID
  String get orderId => _orderId;
}
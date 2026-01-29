// razorpay_serviceonetime.dart
import 'package:aishwarya_gold/core/storage/sharedpreference.dart' show SessionManager;
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:aishwarya_gold/view_models/razorpay_provider/razorpay_provider.dart';

/// Centralized Razorpay Service
/// Handles all Razorpay payment operations across the app
class RazorpayServiceOneTime {
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
    debugPrint("SUCCESS [RazorpayService] Payment Success");
    debugPrint("   paymentId: ${response.paymentId}");
    debugPrint("   orderId: ${response.orderId}");
    debugPrint("   signature: ${response.signature}");

    _onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("ERROR [RazorpayService] Payment Error");
    debugPrint("   code: ${response.code}");
    debugPrint("   message: ${response.message}");

    _onError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("EXTERNAL [RazorpayService] External Wallet: ${response.walletName}");
    _onExternalWallet?.call(response);
  }

  /// Open Razorpay checkout
  ///
  /// * If `orderId` is **provided** → use it directly (SIP-retry case).  
  /// * If `orderId` is **null** → create a new order via `RazorpayProvider` (all other screens).
  Future<void> openCheckout({
    String? orderId,               // NEW – optional pre-created order
    // String? subscriptionId,
    required int amount,           // amount **in rupees** (e.g. 132)
    required String description,
    String? userName,
    String? userContact,
  }) async {
    try {
      // -----------------------------------------------------------------
      // 1. Decide which order ID to use
      // -----------------------------------------------------------------
      if (orderId == null || orderId.isEmpty) {
        // ----> Existing behaviour – create a new order <----
        debugPrint("CREATING ORDER [RazorpayService] Creating order for amount: $amount");
        final createdOrderId = await RazorpayProvider.createOrder(amount);
        if (createdOrderId == null || createdOrderId.isEmpty) {
          debugPrint("FAILED [RazorpayService] Failed to create order");
          throw Exception("Failed to create payment order");
        }
        _orderId = createdOrderId;
        debugPrint("CREATED [RazorpayService] Order created: $_orderId");
      } else {
        // ----> SIP-retry – use the backend-generated order <----
        _orderId = orderId;
        debugPrint("USING BACKEND ORDER [RazorpayService] Using provided orderId: $_orderId");
      }

      // -----------------------------------------------------------------
      // 2. Build Razorpay options (amount must be in **paise**)
      // -----------------------------------------------------------------
      final int amountInPaise = amount * 100;

      final options = {
        'key': 'rzp_live_RbbG6ETAwitsPC',
        'amount': amountInPaise,
        'currency': "INR",
        'name': 'Aishwarya_gold',
        'description': description,
        'order_id': _orderId,               // <-- critical field
        // if (subscriptionId != null) 'subscription_id': subscriptionId,
        'prefill': {
          'contact': userContact ?? "7903886623",
          'name': userName ?? "Saurabh",
        },
        'external': {
          'wallets': ['paytm'],
        },
        "timeout": 200,
      };

      debugPrint("OPENING CHECKOUT [RazorpayService] Opening checkout with amount: $amountInPaise paise");
      _razorpay.open(options);
    } catch (e, st) {
      debugPrint("EXCEPTION [RazorpayService] Exception: $e");
      // debugPrint(st);
      rethrow;
    }
  }

  /// Dispose and clear all listeners
  void dispose() {
    debugPrint("DISPOSING [RazorpayService] Disposing");
    _razorpay.clear();
    _onSuccess = null;
    _onError = null;
    _onExternalWallet = null;
  }

  /// Get current order ID (useful for verification)
  String get orderId => _orderId;
}
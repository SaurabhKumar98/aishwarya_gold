// ========================================
// FILE: sip_retry_payment_repo.dart
// ========================================

import 'dart:convert';
import 'package:aishwarya_gold/core/exception/appexception.dart';
import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:flutter/material.dart';

/// Repository for retrying SIP installment payments.
/// Handles API calls for initiating and verifying retry payments.
class SipRetryPaymentRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  /// 🔹 Initiate retry payment for a failed installment
  Future<Map<String, dynamic>> initiateRetryPayment({
    required String planId,
    required int installmentNumber,
  }) async {
    final String url =
        "${AppUrl.localUrl}/user/sip/$planId/installments/$installmentNumber/retry/initiate";

    debugPrint("🟡 [SipRetryPaymentRepo] Initiating retry payment...");
    debugPrint("   ▶ URL: $url");

    try {
      final response = await _apiServices.postApiResponse(url, {});
      debugPrint("🟢 [Repo] Raw API Response (initiate): $response");

      final parsed = _parseResponse(response);
      debugPrint("✅ [Repo] Parsed Response: $parsed");

      if (parsed['success'] == true) {
        debugPrint("✅ [Repo] Retry payment initiated successfully");
      } else {
        debugPrint("🔴 [Repo] Failed initiation: ${parsed['message']}");
      }

      return parsed;
    } catch (e, st) {
      debugPrint("❌ [Repo] Exception during initiateRetryPayment: $e");
      debugPrint("🧾 StackTrace: $st");

      if (e is AppException) rethrow;
      rethrow;
    }
  }

  /// 🔹 Verify retry payment after Razorpay success
  Future<Map<String, dynamic>> verifyRetryPayment({
    required String planId,
    required int installmentNumber,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final String url =
        "${AppUrl.localUrl}/user/sip/$planId/installments/$installmentNumber/retry/verify";

    debugPrint("🟡 [SipRetryPaymentRepo] Verifying retry payment...");
    debugPrint("   ▶ URL: $url");

    final Map<String, dynamic> body = {
      "razorpayOrderId": razorpayOrderId,
      "razorpayPaymentId": razorpayPaymentId,
      "razorpaySignature": razorpaySignature,
    };

    debugPrint("📦 [Repo] Request Body: $body");

    try {
      final response = await _apiServices.postApiResponse(url, body);
      debugPrint("🟢 [Repo] Raw API Response (verify): $response");

      final parsed = _parseResponse(response);
      debugPrint("✅ [Repo] Parsed Verification Response: $parsed");

      if (parsed['success'] == true) {
        debugPrint("✅ [Repo] Payment verified successfully!");
      } else {
        debugPrint("🔴 [Repo] Payment verification failed: ${parsed['message']}");
      }

      return parsed;
    } catch (e, st) {
      debugPrint("❌ [Repo] Exception during verifyRetryPayment: $e");
      debugPrint("🧾 StackTrace: $st");

      if (e is AppException) rethrow;
      // throw AppException(message: _getUserFriendlyError(e.toString()));
      rethrow;
    }
  }

  /// 🔹 Parse any API response into a Map safely
  Map<String, dynamic> _parseResponse(dynamic response) {
    if (response == null) {
      throw Exception("Empty response from server");
    }

    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is String) {
      try {
        final decoded = jsonDecode(response);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (e) {
        debugPrint("⚠️ [Repo] JSON decode failed: $e");
      }
    }

    throw Exception("Unexpected response format: ${response.runtimeType}");
  }

  /// 🔹 Generate user-friendly error messages for exceptions
  String _getUserFriendlyError(String error) {
    final lower = error.toLowerCase();

    if (lower.contains('network') || lower.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (lower.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (lower.contains('404')) {
      return 'Service not found. Please try again later.';
    } else if (lower.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (lower.contains('unauthorized') || lower.contains('401')) {
      return 'Session expired. Please login again.';
    }

    return 'Something went wrong. Please try again.';
  }
}

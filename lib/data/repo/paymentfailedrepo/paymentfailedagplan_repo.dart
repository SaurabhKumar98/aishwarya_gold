// ========================================
// FILE: ag_retry_payment_repo.dart
// ========================================

import 'dart:convert';
import 'package:aishwarya_gold/core/exception/appexception.dart';
import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:flutter/material.dart';

/// Repository for retrying AG Plan installment payments.
/// Handles API calls for initiating and verifying retry payments.
class AgRetryPaymentRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  /// 🔹 Initiate retry payment for a failed AG Plan installment
  Future<Map<String, dynamic>> initiateRetryPayment({
    required String purchaseId,
    required int installmentNumber,
  }) async {
    final String url =
        "${AppUrl.localUrl}/user/agplans/$purchaseId/installments/$installmentNumber/retry/initiate";

 
    try {
      final response = await _apiServices.postApiResponse(url, {});
      

      final parsed = _parseResponse(response);
     

      if (parsed['success'] == true) {
      } else {
      }

      return parsed;
    } catch (e, st) {
    

      if (e is AppException) rethrow;
      rethrow;
    }
  }

  /// 🔹 Verify retry payment after Razorpay success
  Future<Map<String, dynamic>> verifyRetryPayment({
    required String purchaseId,
    required int installmentNumber,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final String url =
        "${AppUrl.localUrl}/user/agplans/$purchaseId/installments/$installmentNumber/retry/verify";



    final Map<String, dynamic> body = {
      "razorpayOrderId": razorpayOrderId,
      "razorpayPaymentId": razorpayPaymentId,
      "razorpaySignature": razorpaySignature,
    };

   

    try {
      final response = await _apiServices.postApiResponse(url, body);
     

      final parsed = _parseResponse(response);
     

      if (parsed['success'] == true) {
        debugPrint("✅ [Repo] AG Plan payment verified successfully!");
      } else {
        debugPrint("🔴 [Repo] Payment verification failed: ${parsed['message']}");
      }

      return parsed;
    } catch (e, st) {
      debugPrint("❌ [Repo] Exception during verifyRetryPayment: $e");
      debugPrint("🧾 StackTrace: $st");

      if (e is AppException) rethrow;
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
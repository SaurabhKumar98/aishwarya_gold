// lib/data/repository/gift_repository.dart

import 'dart:convert';
import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/data/models/giftmodels/giftmodels_myself.dart';
import 'package:aishwarya_gold/data/models/giftmodels/send_giftmodels.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';

class GiftRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  /// 🎁 Create Gift for Others (Without Payment)
  Future<GiftResponse> createGift(GiftRequest request) async {
    try {

      final response = await _apiServices.postApiResponse(
        AppUrl.giftCard,
        request.toJson(),
      );

      
      return GiftResponse.fromJson(response);
    } catch (e) {
     
      rethrow;
    }
  }

  /// 🎁 Create Gift for Myself (Without Payment)
  Future<MySelfGiftResponse> createMySelfGift(MySelfGiftRequest request) async {
    try {
     

      final response = await _apiServices.postApiResponse(
        AppUrl.giftCard,
        request.toJson(),
      );

      
      return MySelfGiftResponse.fromJson(response);
    } catch (e) {
     
      rethrow;
    }
  }

  /// 💳 Verify Razorpay Payment and Create Gift
  Future<GiftResponse> verifyGiftPayment(GiftRequest request) async {
    final url = "${AppUrl.giftCard}";

   

    try {
      final response = await _apiServices.postApiResponse(
        url,
        request.toJson(),
      );

      
      return GiftResponse.fromJson(response);
    } catch (e) {
     
      rethrow;
    }
  }
}

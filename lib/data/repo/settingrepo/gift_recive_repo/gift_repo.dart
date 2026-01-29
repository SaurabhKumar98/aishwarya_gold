import 'dart:convert';
import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/data/models/settingmodels/recive_gift_models.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';

class GiftRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

Future<ReciveGiftModels> getGifts() async {
  try {
    final url = AppUrl.recgift;
    final response = await _apiServices.getApiResponse(url);
    // Token is automatically added by NetworkApiServices
    
    if (response is Map<String, dynamic>) {
      return ReciveGiftModels.fromJson(response);
    }

    if (response is String) {
      final decoded = jsonDecode(response);
      if (decoded is Map<String, dynamic>) {
        return ReciveGiftModels.fromJson(decoded);
      }
    }

    throw Exception("Unexpected response type: ${response.runtimeType}");
  } catch (e) {
    rethrow;
  }
}
}

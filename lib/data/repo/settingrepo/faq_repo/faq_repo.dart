import 'dart:convert';

import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/data/models/settingmodels/faqmodels.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:aishwarya_gold/utils/exports/exports.dart';

class FaqRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<FaqModels> getFaq() async {
    try {
      final url = AppUrl.faq;
      final response = await _apiServices.getApiResponse(url);

      // Case 1: Directly a decoded Map
      if (response is Map<String, dynamic>) {
        return FaqModels.fromJson(response);
      }

      // Case 2: Raw string JSON response
      if (response is String) {
        final decoded = jsonDecode(response);
        if (decoded is Map<String, dynamic>) {
          return FaqModels.fromJson(decoded);
        } else {
          throw Exception("Invalid JSON structure in response string.");
        }
      }

      // Case 3: Unexpected type (e.g. list, int, etc.)
      throw Exception("Unexpected response type: ${response.runtimeType}");
    } catch (e, stackTrace) {
      // You can log the error here if needed
      rethrow;
    }
  }
}

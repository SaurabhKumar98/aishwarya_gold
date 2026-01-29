import 'dart:convert';

import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/data/models/storemodels/store_models.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:aishwarya_gold/utils/exports/exports.dart';

class StoreRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<StoreModels> getStore() async {
    try {
      final url = AppUrl.store;
      final response = await _apiServices.getApiResponse(url);

      if (response is Map<String, dynamic>) {
        return StoreModels.fromJson(response);
      }

      if (response is String) {
        final decoded = jsonDecode(response);
        if (decoded is Map<String, dynamic>) {
          return StoreModels.fromJson(decoded);
        } else {
          throw Exception("Invalid JSON structure in response string.");
        }
      }

      throw Exception("Unexpected response type: ${response.runtimeType}");
    } catch (e, stackTrace) {
      debugPrint("Error in getStore(): $e");
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }
}

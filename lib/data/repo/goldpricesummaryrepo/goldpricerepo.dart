// data/repo/goldpricesummaryrepo/goldpricerepo.dart
import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/data/models/goldPriceSummary/goldpricesummarymodels.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';

class GoldPriceSummaryRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<GoldPriceSummary> fetchGoldPriceSummary() async {
    try {
      // <-- THIS IS THE ENDPOINT THAT WAS FAILING
      final response = await _apiServices.getApiResponse(AppUrl.goldSumm);

      if (response == null) {
        throw Exception("Empty response from server");
      }

      return GoldPriceSummary.fromJson(response);
    } catch (e) {
      // Re-throw a clean message – the provider will catch it
      throw Exception("Failed to fetch gold price summary: $e");
    }
  }
}
import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/data/models/goldprice_models/gold_price_models.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';

class GoldPriceRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  /// Fetches the current gold price from backend
  Future<GoldPrice?> getSavingPrice() async {
    try {
      final url = "${AppUrl.goldprice}/current"; // e.g. http://localhost:8000/admin/goldprice/current

      // ✅ Assuming NetworkApiServices.getApiResponse() returns a decoded JSON map
      final response = await _apiServices.getApiResponse(url);

      // ✅ Convert the response map to model
      return GoldPrice.fromJson(response);
    } catch (e) {
      
      return null;
    }
  }
}

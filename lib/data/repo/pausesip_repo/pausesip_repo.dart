import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';

class PauseSipRepo {
  final NetworkApiServices _apiClient = NetworkApiServices();

  Future<Map<String, dynamic>> pauseSipPlan(String planId, int months) async {
    final response = await _apiClient.putApiResponse(
      "${AppUrl.pausesip}$planId/pause",
      {"pauseDurationMonths": months}, // ✅ No 'data:' here
    );
    return response;
  }

   Future<Map<String, dynamic>> resumeSipPlan(String planId) async {
    final response = await _apiClient.putApiResponse(
      "${AppUrl.pausesip}$planId/resume",
      {}, // Usually empty body
    );
    return response;
  }
}

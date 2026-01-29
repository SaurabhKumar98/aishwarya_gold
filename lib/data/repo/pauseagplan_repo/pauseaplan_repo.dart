import 'package:aishwarya_gold/core/network/network_api_service.dart';

import 'package:aishwarya_gold/data/models/pauseagplan_models/pauseagplan_modles.dart';

import 'package:aishwarya_gold/res/constants/urls.dart';

class PauseAgPlanRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  /// Pause AG plan - PUT API call
  Future<PauseAgPlanModels> pausePlan(
    String id, // User saving plan ID
    int pauseDurationMonths,
  ) async {
    try {
      // Construct URL
      final url = '${AppUrl.pauseAgplan}$id/pause';

    

      // Make API call with proper parameters
      final response = await _apiServices.putApiResponse(
        url,
        {
          "pauseDurationMonths": pauseDurationMonths,
        },
      );

      print('✅ Pause Plan Response: $response');

      // Parse response
      final pausePlanData = PauseAgPlanModels.fromJson(response);

      if (pausePlanData.success == true) {
        print('✅ Plan paused successfully: ${pausePlanData.message}');
        return pausePlanData;
      } else {
        print('❌ Pause failed: ${pausePlanData.message}');
        throw Exception(pausePlanData.message ?? 'Failed to pause plan');
      }
    } catch (e) {
      print('❌ Error pausing plan: $e');
      rethrow;
    }
  }

  /// Resume AG plan - PUT API call
  Future<ResumeAgPlanModels> resumePlan(
    String id, // User saving plan ID
    int pauseDurationMonths, // Same body as pause
  ) async {
    try {
      // Construct URL
      final url = '${AppUrl.pauseAgplan}$id/resume';

      print('🔵 Resume Plan Request:');
      print('URL: $url');
      print('Body: {"pauseDurationMonths": $pauseDurationMonths}');

      // Make API call with proper parameters
      final response = await _apiServices.putApiResponse(
        url,
        {
          "pauseDurationMonths": pauseDurationMonths,
        },
      );

      print('✅ Resume Plan Response: $response');

      // Parse response
      final resumePlanData = ResumeAgPlanModels.fromJson(response);

      if (resumePlanData.success == true) {
        print('✅ Plan resumed successfully: ${resumePlanData.message}');
        return resumePlanData;
      } else {
        print('❌ Resume failed: ${resumePlanData.message}');
        throw Exception(resumePlanData.message ?? 'Failed to resume plan');
      }
    } catch (e) {
      print('❌ Error resuming plan: $e');
      rethrow;
    }
  }
}
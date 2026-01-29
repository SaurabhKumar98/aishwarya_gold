import 'dart:convert';

import 'package:aishwarya_gold/core/exception/appexception.dart';
import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/data/models/videomodels/videomodels.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';

class Videorepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<VideoModels> getVideos() async {
    try {
      final url = "${AppUrl.videourl}"; // Replace with actual URL
      final response = await _apiServices.getApiResponse(url);
      print("🌍 CALLING VIDEO API → $url");



print("🌍 RAW RESPONSE → $response");


      if (response is Map<String, dynamic>) {
        return VideoModels.fromJson(response);
      }

      if (response is String) {
        final decoded = jsonDecode(response);
        if (decoded is Map<String, dynamic>) {
          return VideoModels.fromJson(decoded);
        }
      }
      throw Exception("Unexpected response type: ${response.runtimeType}");
    } catch (e) {
      if (e is AppException) rethrow;
      rethrow;
    }
  }
}
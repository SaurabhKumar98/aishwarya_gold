import 'dart:convert';
import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/data/models/downloadstatemetagmodels/downloadstatementmodels.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';

class DownloadStatementRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<DownloadStatementModels> getDownloadStatement(String id) async {
    try {
      final String url = "${AppUrl.localUrl}/user/agplans/purchase/$id";
      print("Download Statement API: $url");
     

      // ✅ Get API response using your custom network service
      final response = await _apiServices.getApiResponse(url);
     

      // ✅ Safely parse and return model
      return DownloadStatementModels.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching download statement: $e');
    }
  }
}

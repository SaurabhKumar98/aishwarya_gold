import 'dart:convert';
import 'package:aishwarya_gold/core/exception/appexception.dart';
import 'package:aishwarya_gold/core/network/base_api_service.dart';
import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';

class ChangePinRepo {
  final BaseApiServices _apiService = NetworkApiServices();

  Future<Map<String, dynamic>> changePin({
    required String newPin,
    required String confirmPin,
  }) async {
    try {
      final body = {
        "newPin": newPin,
        "confirmPin": confirmPin,
      };

      final response = await _apiService.postApiResponse(
        "${AppUrl.localUrl}/user/change-pin",
        body,
      );

      return response;
    } catch (e) {
      throw "Failed to change PIN";
    }
  }
}

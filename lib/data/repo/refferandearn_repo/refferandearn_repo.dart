import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/data/models/refferandearnmodels/refferandearnmodels.dart';
import 'package:aishwarya_gold/data/models/refferandearnmodels/refferhistorymodels.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';

class RefferandearnRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  /// Fetches the referral and earn data
  Future<RefferAndEarn> getRefferCode() async {
    try {
      final response = await _apiServices.getApiResponse(AppUrl.refferurl);
      return RefferAndEarn.fromJson(response);
    } catch (e) {
      
      rethrow;
    }
  }

  /// Fetch referral history
  Future<RefferHistoryModels> getRefferHistory() async {
    try {
      final response = await _apiServices.getApiResponse(AppUrl.refferhistory);
      return RefferHistoryModels.fromJson(response);
    } catch (e) {
      
      rethrow;
    }
  }
}

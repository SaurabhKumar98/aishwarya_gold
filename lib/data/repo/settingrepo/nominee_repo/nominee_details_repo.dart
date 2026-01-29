import 'package:aishwarya_gold/core/network/base_api_service.dart';
import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/data/models/settingmodels/nominne_details_byuserid_modles.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';

class NomineeDetailsRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  /// 🔹 Fetch all nominee details for a given user
  Future<NomineeDetails> getNomineeDetails(int pageNumber) async {
    try {
      final userid =await SessionManager.getUserId();
      final response = await _apiServices.getApiResponse(
        "${AppUrl.nomineeDet}$userid&page=$pageNumber&limit=10",
      );
      return NomineeDetails.fromJson(response);
    } catch (e) {
      rethrow; // Let provider handle the error
    }
  }
}

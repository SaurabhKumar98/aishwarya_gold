import 'package:aishwarya_gold/core/network/base_api_service.dart';
import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/data/models/settingmodels/nominee_models.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';

class NomineeRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<Nominee> createNominee(Nominee requestModel) async {
    try {
      final response = await _apiServices.postApiResponse(
        "${AppUrl.localUrl}/user/nominee",
        requestModel.toJson(),
      );

      return Nominee.fromJson(response);
    } catch (e) {
      rethrow; // Let ViewModel handle error display/logging
    }
  }
}

import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/data/models/redeemCodemodels/redeemcodemodels.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';

class RedeemCodeRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<RedeemResponse> redeemCode(String code) async {
    try {
      
      
      final response = await _apiServices.postApiResponse(
        AppUrl.redeem,
        {'code': code},
      );

      

      final redeemResponse = RedeemResponse.fromJson(response);
      
     
      
      if (redeemResponse.data?.codeType == 'gift') {
       
      } else if (redeemResponse.data?.codeType == 'promo') {
        
      }

      return redeemResponse;
    } catch (e) {
   
      rethrow;
    }
  }
}
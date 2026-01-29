import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/data/models/settingmodels/profiledatails.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';

class Profilerepo {
  final NetworkApiServices _apiServices =NetworkApiServices();

  Future<ProfileDetailModels> getProfile() async{
    try{
      final userid =await SessionManager.getUserId();
      final url ="${AppUrl.profdet}$userid";

      final response = await _apiServices.getApiResponse(url);
      return ProfileDetailModels.fromJson(response);



    }
    catch(e){
       return ProfileDetailModels(
        success: false,
        message: e.toString(),
        data: null,
        meta: null);

    }
  }
}
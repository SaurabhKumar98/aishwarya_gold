import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/data/models/gstmodels/gst_models.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:aishwarya_gold/utils/exports/exports.dart';

class GstRepo {
  final NetworkApiServices _apiServices =NetworkApiServices();
  
  Future<GstModels?> getAllGst() async{
    try{
      final response = await _apiServices.getApiResponse(AppUrl.gsturl);

      return GstModels.fromJson(response);
    }
    catch(e){
    
      return null;
    }
  }
}
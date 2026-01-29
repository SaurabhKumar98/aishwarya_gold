import 'dart:convert';
import 'package:aishwarya_gold/core/exception/appexception.dart';
import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/data/models/onetimesavingmodels/onetime_saving_models.dart';
import 'package:aishwarya_gold/data/models/onetimesavingmodels/onetimebyidmodels.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:flutter/material.dart';

class OnetimesavingRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<OneTimeSavingPlan> getSavingPlan (int pagenumber) async{
    try{
      final userId = await SessionManager.getUserId();
      final urlOneTime = "${AppUrl.onetimeSaving}$userId/all?page=$pagenumber&limit=15";
     
       final response = await _apiServices.getApiResponse(urlOneTime);//userid/all?page=1&limit=10
      debugPrint(response.toString());
            if(response is Map<String,dynamic>){
        return OneTimeSavingPlan.fromJson(response);
      }

      if(response is String){
        final decoded = jsonDecode(response);
        if(decoded is Map<String,dynamic>){
          return OneTimeSavingPlan.fromJson(decoded);

        }
      }
      throw Exception("Unexpected response type: ${response.runtimeType}");

    }
    catch(e){
           if(e is AppException) rethrow;
      rethrow;

    }
  }
Future<OneTimeByIdModels> getPlanById(String planId) async {
  try {
    final url = "${AppUrl.reedemonetime}$planId"; // /user/onetime/{planId}
    print(" one time $url");
    final response = await _apiServices.getApiResponse(url);

    Map<String, dynamic> data;

    if (response is Map<String, dynamic>) {
      data = response;
    } else if (response is String) {
      final decoded = jsonDecode(response);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      } else {
        throw Exception("Decoded JSON is not a Map: $decoded");
      }
    } else {
      throw Exception("Unexpected response type: ${response.runtimeType}");
    }

    return OneTimeByIdModels.fromJson(data);
  } catch (e) {
    // If you have a custom AppException, keep it
    if (e is AppException) rethrow;

    // You can wrap any other exception into your AppException or just rethrow
    throw Exception("Failed to fetch plan by ID: $e");
  }
}

}
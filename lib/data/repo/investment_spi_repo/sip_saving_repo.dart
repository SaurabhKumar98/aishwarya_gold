import 'dart:convert';

import 'package:aishwarya_gold/core/exception/appexception.dart';
import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/data/models/reedem_sip_models/reedem_sip_modles.dart';
import 'package:aishwarya_gold/data/models/sipsavingmodels/sip_saving_models.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:aishwarya_gold/view_models/user_provider.dart';
import 'package:flutter/material.dart';

class SipSavingRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<SipSavingPlan> getSavingPlan(int pagenumber) async{

    try{
      //  final userProvider = Provider.of<UserProvider>(context, listen: false);

      final userId = await SessionManager.getUserId();

      final url ="${AppUrl.sipSavingPlan}$userId/all?page=$pagenumber&limit=5";
      
      final response = await _apiServices.getApiResponse(url);//userid/all?page=1&limit=10
      debugPrint(response.toString());

      if(response is Map<String,dynamic>){
        return SipSavingPlan.fromJson(response);
      }

      if(response is String){
        final decoded = jsonDecode(response);
        if(decoded is Map<String,dynamic>){
          return SipSavingPlan.fromJson(decoded);

        }
      }
      throw Exception("Unexpected response type: ${response.runtimeType}");

    }
    catch(e){
      if(e is AppException) rethrow;
      rethrow;
      
    }
  }

    /// Get a single SIP saving plan by its ID
  Future<ReedemSipModels> getSavingPlanById(String planId) async {
    try {
      final url = "${AppUrl.reedemsip}$planId";
  

      final response = await _apiServices.getApiResponse(url);
      debugPrint(response.toString());

      if (response is Map<String, dynamic>) {
        return ReedemSipModels.fromJson(response);
      }

      if (response is String) {
        final decoded = jsonDecode(response);
        if (decoded is Map<String, dynamic>) {
          return ReedemSipModels.fromJson(decoded);
        }
      }

      throw Exception("Unexpected response type: ${response.runtimeType}");
    } catch (e) {
      if (e is AppException) rethrow;
      rethrow;
    }
  }
}
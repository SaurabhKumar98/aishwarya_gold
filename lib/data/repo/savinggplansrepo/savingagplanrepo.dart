
import 'dart:convert';
import 'package:aishwarya_gold/core/exception/appexception.dart';
import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/data/models/agplanbyidmodels/agplanbymodels.dart';
import 'package:aishwarya_gold/data/models/pauseagplan_models/pauseagplan_modles.dart';
import 'package:aishwarya_gold/data/models/savingagplanmodels/agsavingmodels.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:flutter/foundation.dart';
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';

class Savingagplagrepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<AgPlanSavingModels> getSavingPlan() async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        
        throw UnauthorizedException("User ID not found in session");
      }
      final urlAgPlan = "${AppUrl.savingagPlan}$userId/plans";
      

      final response = await _apiServices.getApiResponse(urlAgPlan);
      

      if (response is Map<String, dynamic>) {
        return AgPlanSavingModels.fromJson(response);
      }

      if (response is String) {
        final decoded = jsonDecode(response);
        if (decoded is Map<String, dynamic>) {
          return AgPlanSavingModels.fromJson(decoded);
        }
      }

      throw FetchDataException("Unexpected response type: ${response.runtimeType}");
    } catch (e) {
      
      if (e is AppException) rethrow;
      rethrow;
    }
  }

  Future<PauseAgPlanModels> getPausePlan(String planId, int months) async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) {
      
        throw UnauthorizedException("User ID not found in session");
      }
      final urlPauseAg = "${AppUrl.pauseAgplan}$planId/pause";
      

      final body = {
        "status": "paused",
        "months": months,
      };
      

      final response = await _apiServices.putApiResponse(urlPauseAg, body);
      

      if (response is Map<String, dynamic>) {
        return PauseAgPlanModels.fromJson(response);
      }

      if (response is String) {
        final decoded = jsonDecode(response);
        if (decoded is Map<String, dynamic>) {
          return PauseAgPlanModels.fromJson(decoded);
        }
      }

      throw FetchDataException("Unexpected response type: ${response.runtimeType}");
    } catch (e) {
     
      if (e is AppException) rethrow;
      rethrow;
    }
  }

  Future<PauseAgPlanModels> pausePlanByIndex(int index, int months) async {
    try {
      final agPlanSaving = await getSavingPlan();
      if (agPlanSaving.data == null || agPlanSaving.data!.isEmpty) {
        throw InvalidInputException("No plans found");
      }
      if (index < 0 || index >= agPlanSaving.data!.length) {
        throw InvalidInputException("Invalid plan index");
      }
      final agSaving = agPlanSaving.data![index];
      final savingPlanId = agSaving.id;
      if (savingPlanId == null) {
        throw InvalidInputException("Saving Plan ID not found");
      }
      return await getPausePlan(savingPlanId, months);
    } catch (e) {
      if (e is AppException) rethrow;
      rethrow;
    }
  }
    Future<AgPlanByIdModels> getAgPlanById(String planId) async {
    try {
      final url = "${AppUrl.agpruchase}$planId";

      final response = await _apiServices.getApiResponse(url);

      if (response is Map<String, dynamic>) {
        return AgPlanByIdModels.fromJson(response);
      }

      if (response is String) {
        final decoded = jsonDecode(response);
        if (decoded is Map<String, dynamic>) {
          return AgPlanByIdModels.fromJson(decoded);
        }
      }

      throw Exception("Unexpected response type: ${response.runtimeType}");
    } catch (e) {
      if (e is AppException) rethrow;
      rethrow;
    }
  }
}
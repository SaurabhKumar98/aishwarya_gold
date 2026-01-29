// import 'package:aishwarya_gold/core/network/network_api_service.dart';
// import 'package:aishwarya_gold/data/models/reedemptionmodels/reedemption_models.dart';
// import 'package:aishwarya_gold/data/models/reedemptionmodels/reedemptionstatus_modles.dart';
// import 'package:aishwarya_gold/res/constants/urls.dart';
// import 'package:aishwarya_gold/view_models/reedemption_provider/reedemption_provider.dart';

// class RedemptionRepo {
//   final NetworkApiServices _apiServices = NetworkApiServices();

//   /// Create redemption request
//   /// Supports both plan-based (AgPlan, SIP, OneTime) and wallet-based redemption
//   Future<RedemptionRequestModel> createRedemptionRequest({
//     String? planId,  // Optional for wallet balance
//     required String planType,
//     required String storeId,
//     double? amount,  // Optional for wallet balance
//   }) async {
//     try {
//       final Map<String, dynamic> requestBody = {
//         'storeId': storeId,
//         'planType': planType,
//       };

//       // Add planId only if provided (not for wallet balance)
//       if (planId != null && planId.isNotEmpty && planId != 'wallet_balance' && planId != 'referral_wallet') {
//         requestBody['planId'] = planId;
//       }

//       // Add amount if provided (for wallet balance)
//       if (amount != null && amount > 0) {
//         requestBody['amount'] = amount;
//       }

//       final response = await _apiServices.postApiResponse(
//         AppUrl.createRedemption,
//         requestBody,
//       );

//       return RedemptionRequestModel.fromJson(response);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Get redemption status
//   Future<RedemptionStatusModels> getRedemptionStatus(String redemptionId) async {
//     try {
//       final response = await _apiServices.getApiResponse(
//         '${AppUrl.redemptionStatus}/$redemptionId',
//       );
//       return RedemptionStatusResponse.fromJson(response);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Cancel redemption request
//   Future<bool> cancelRedemptionRequest(String redemptionId) async {
//     try {
//       final response = await _apiServices.deleteApiResponse(
//         '${AppUrl.cancelRedemption}/$redemptionId',
//       );
//       return response['success'] == true;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Get all user redemptions (optional, for loading existing redemptions)
//   Future<List<RedemptionData>> getUserRedemptions() async {
//     try {
//       final response = await _apiServices.getApiResponse(
//         AppUrl.userRedemptions,
//       );
      
//       if (response['data'] != null && response['data'] is List) {
//         return (response['data'] as List)
//             .map((item) => RedemptionData.fromJson(item))
//             .toList();
//       }
      
//       return [];
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
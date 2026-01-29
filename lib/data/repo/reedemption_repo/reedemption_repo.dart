// lib/data/repositories/redemption_repository.dart
import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/data/models/reedemptionmodels/reedemption_models.dart';
import 'package:aishwarya_gold/data/models/reedemptionmodels/reedemptionstatus_modles.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:aishwarya_gold/utils/exports/exports.dart';

// lib/data/repositories/redemption_repository.dart
// redemption_repository.dart
class RedemptionRepository {
  final NetworkApiServices _api = NetworkApiServices();

Future<RedemptionRequestModel> createRedemptionRequest({
  String? planId,                 // ✅ optional
  required String planType,
  required String storeId,
  double? amount,                 // ✅ optional
}) async {
  // Normalize planType and prepare body (be permissive: accept 'wallet', 'walletbalance', 'referral', 'W')
  final normalizedPlanType = planType?.trim() ?? '';
  final lower = normalizedPlanType.toLowerCase();
  final bool isWallet = lower.contains('wallet') || lower.contains('referral') || lower == 'w';

  final Map<String, dynamic> body = {
    'storeId': storeId,
    'planType': isWallet ? 'WalletBalance' : normalizedPlanType,
  };

  // Wallet balance redemption must include amount and must not include planId
  if (isWallet) {
    if (amount == null || amount <= 0) {
      throw ArgumentError('Amount is required for WalletBalance redemptions');
    }
    body['amount'] = amount;
  } else {
    // For other plans, ensure planId is provided
    if (planId == null || planId.isEmpty) {
      throw ArgumentError('planId is required for non-WalletBalance redemptions');
    }
    body['planId'] = planId;
  }

  // Log request for debugging
  print('📤 Creating redemption request with body: $body');

  final json = await _api.postApiResponse(
    AppUrl.createRedemption,
    body,
  );

  return RedemptionRequestModel.fromJson(json);
}

  // NO POLLING — NO GET API
  // Future<String?> pollRedemptionStatus(...) => removed

Future<RedemptionRequestModel> cancelRedemptionRequest(String redemptionId) async {
  try {
    final json = await _api.deleteApiResponse('${AppUrl.cancelRedemption}/$redemptionId');
    return RedemptionRequestModel.fromJson(json);
  } catch (e) {
    
    rethrow;
  }
}
// Add this method to your RedemptionRepository class

/// Get redemption status by Plan ID
/// Endpoint: GET /user/redemption-request?planId={planId}
// Add this FIXED method to your RedemptionRepository class

/// Get redemption status by Plan ID
/// Endpoint: GET /user/redemption-request?planId={planId}
Future<RedemptionStatusModels?> getRedemptionByPlanId(String planId) async {
  try {
    
    
    // Query with planId parameter
    // Endpoint: GET /user/redemption-request?planId=xyz
    final url = '${AppUrl.getUserRedemptions}?planId=$planId';
    
   
    
    final json = await _api.getApiResponse(url);
    
  
    
    if (json != null) {
      // If data is a list, get the first one (most recent)
      if (json['data'] is List) {
        final dataList = json['data'] as List;
        if (dataList.isNotEmpty) {
          
          
          final redemptionData = dataList[0];
          
          // Check if it has a status
          final status = redemptionData['status']?.toString().toLowerCase() ?? 'none';
          
          
          return RedemptionStatusModels.fromJson({
            'data': redemptionData,
            'success': json['success'] ?? true,
            'message': json['message'] ?? ''
          });
        }
      } 
      // If data is a single map object
      else if (json['data'] is Map) {
        
        
        final status = json['data']['status']?.toString().toLowerCase() ?? 'none';
        
        
        return RedemptionStatusModels.fromJson(json);
      }
      // If success is true but no data, it means no redemption exists
      else if (json['success'] == true && json['data'] == null) {
        
        return null;
      }
    }
    
    
    return null;
  } catch (e) {
    
    return null;
  }
}
/// Alternative: If backend returns all redemptions, filter by planId
Future<RedemptionStatusModels?> getRedemptionByPlanIdFromList(String planId) async {
  try {
    // Get all user redemptions
    final json = await _api.getApiResponse(AppUrl.getUserRedemptions);
    
    if (json != null && json['data'] is List) {
      final redemptions = json['data'] as List;
      
      // Find the redemption matching this planId
      for (var redemption in redemptions) {
        if (redemption['planId'] == planId) {
          return RedemptionStatusModels.fromJson({
            'data': redemption,
            'success': true,
            'message': ''
          });
        }
      }
    }
    
    return null;
  } catch (e) {
    print("⚠️ Error fetching redemptions: $e");
    return null;
  }
}

Future<RedemptionStatusModels> getStatusResponse(String redemptionId) async {
  try {
    final json = await _api.getApiResponse('${AppUrl.cancelRedemption}/$redemptionId');
    return RedemptionStatusModels.fromJson(json);
  } catch (e) {
    print("❌ Get redemption status failed: $e");
    rethrow;
  }
}


}
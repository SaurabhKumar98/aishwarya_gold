// // lib/view_models/reedemption_provider/reedemption_provider.dart

// import 'package:aishwarya_gold/data/models/reedemptionmodels/reedemption_models.dart';
// import 'package:aishwarya_gold/data/models/reedemptionmodels/reedemptionstatus_modles.dart';
// import 'package:aishwarya_gold/data/repo/reedemption_repo/reedemption_repo.dart';
// import 'package:flutter/foundation.dart';

// class RedemptionProvider with ChangeNotifier {
//   final RedemptionRepository _repo = RedemptionRepository();

//   bool _isLoading = false;
//   String? _errorMessage;
  
//   RedemptionRequestModel? _redemptionResponse;
//   RedemptionStatusModels? _statusResponse;
  
//   // Store all redemptions: planId/storeId -> redemption info
//   final Map<String, Map<String, dynamic>> _redemptions = {};

//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   RedemptionRequestModel? get redemptionResponse => _redemptionResponse;
//   RedemptionStatusModels? get statusResponse => _statusResponse;

//   /// Create redemption request
//   /// Supports both plan-based and wallet-based redemption
//   Future<bool> createRedemptionRequest({
//     String? planId,  // Optional for wallet balance
//     required String planType,
//     required String storeId,
//     double? amount,  // For wallet balance redemption
//   }) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       // For wallet balance, use special handling
//       final isWalletRedemption = planType == 'referral' || planType == 'WalletBalance';
      
//       final response = await _repo.createRedemptionRequest(
//         planId: isWalletRedemption ? '' : (planId ?? ''),
//         planType: isWalletRedemption ? 'WalletBalance' : planType,
//         storeId: storeId,
//       );

//       _redemptionResponse = response;

//       if (response.success && response.data != null) {
//         // Store redemption info with compound key
//         final key = isWalletRedemption ? 'wallet_$storeId' : '${planId}_$storeId';
        
//         _redemptions[key] = {
//           'redemptionId': response.data!.id,
//           'status': response.data!.status ?? 'pending',
//           'storeId': storeId,
//           'planType': isWalletRedemption ? 'WalletBalance' : planType,
//           'planId': isWalletRedemption ? null : planId,
//         };

//         debugPrint('✅ Redemption created: $key -> ${response.data!.id}');
//       }

//       _isLoading = false;
//       notifyListeners();
//       return response.success;
//     } catch (e) {
//       _errorMessage = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       debugPrint('🔴 Error creating redemption: $e');
//       return false;
//     }
//   }

//   /// Get redemption status by redemption ID
//   Future<RedemptionStatusModels?> getRedemptionStatus(String redemptionId) async {
//     try {
//       final response = await _repo.getStatusResponse(redemptionId);
//       _statusResponse = response;
      
//       // Update stored redemption status
//       for (var key in _redemptions.keys) {
//         if (_redemptions[key]?['redemptionId'] == redemptionId) {
//           _redemptions[key]!['status'] = response.data?.status ?? 'pending';
//           debugPrint('✅ Updated status for $key: ${response.data?.status}');
//         }
//       }
      
//       notifyListeners();
//       return response;
//     } catch (e) {
//       debugPrint('🔴 Error fetching status: $e');
//       return null;
//     }
//   }

//   /// Cancel redemption request
//   Future<bool> cancelRedemptionRequest(String redemptionId) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final response = await _repo.cancelRedemptionRequest(redemptionId);
      
//       if (response.success) {
//         // Remove from stored redemptions
//         _redemptions.removeWhere((key, value) => value['redemptionId'] == redemptionId);
//         debugPrint('✅ Redemption cancelled and removed: $redemptionId');
//       }
      
//       _isLoading = false;
//       notifyListeners();
//       return response.success;
//     } catch (e) {
//       _errorMessage = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       debugPrint('🔴 Error canceling redemption: $e');
//       return false;
//     }
//   }

//   /// Check redemption status by Plan ID (loads from backend)
//   Future<void> checkRedemptionByPlanId(String planId) async {
//     try {
//       debugPrint('🔍 Checking redemption for planId: $planId');
      
//       final redemption = await _repo.getRedemptionByPlanId(planId);
      
//       if (redemption != null && redemption.data != null) {
//         final storeId = redemption.data!.storeId ?? '';
//         final key = '${planId}_$storeId';
        
//         _redemptions[key] = {
//           'redemptionId': redemption.data!.id,
//           'status': redemption.data!.status ?? 'pending',
//           'storeId': storeId,
//           'planType': redemption.data!.planType ?? '',
//           'planId': planId,
//         };
        
//         debugPrint('✅ Found existing redemption: $key -> ${redemption.data!.status}');
//         notifyListeners();
//       } else {
//         debugPrint('ℹ️ No existing redemption found for planId: $planId');
//       }
//     } catch (e) {
//       debugPrint('⚠️ Error checking redemption: $e');
//     }
//   }

//   /// Check wallet redemption status (loads from backend)
//   Future<void> checkWalletRedemption() async {
//     try {
//       debugPrint('🔍 Checking wallet redemption');
      
//       // Backend should return wallet redemptions when queried with special identifier
//       final redemption = await _repo.getRedemptionByPlanId('wallet_balance');
      
//       if (redemption != null && redemption.data != null) {
//         final storeId = redemption.data!.storeId ?? '';
//         final key = 'wallet_$storeId';
        
//         _redemptions[key] = {
//           'redemptionId': redemption.data!.id,
//           'status': redemption.data!.status ?? 'pending',
//           'storeId': storeId,
//           'planType': 'WalletBalance',
//           'planId': null,
//         };
        
//         debugPrint('✅ Found wallet redemption: $key -> ${redemption.data!.status}');
//         notifyListeners();
//       } else {
//         debugPrint('ℹ️ No wallet redemption found');
//       }
//     } catch (e) {
//       debugPrint('⚠️ Error checking wallet redemption: $e');
//     }
//   }

//   /// Get redemption info for a specific plan and store
//   Map<String, dynamic>? getPlanRedemptionWithStore(String planId) {
//     // Check all stores for this plan
//     for (var key in _redemptions.keys) {
//       if (key.startsWith('${planId}_')) {
//         return _redemptions[key];
//       }
//     }
//     return null;
//   }

//   /// Get wallet redemption info
//   Map<String, dynamic>? getWalletRedemptionWithStore() {
//     // Check all stores for wallet redemptions
//     for (var key in _redemptions.keys) {
//       if (key.startsWith('wallet_')) {
//         return _redemptions[key];
//       }
//     }
//     return null;
//   }

//   /// Get redemption for specific store (for plan-based)
//   String getStoreRedemptionStatus(String planId, String storeId) {
//     final key = '${planId}_$storeId';
//     return _redemptions[key]?['status'] ?? 'none';
//   }

//   /// Get wallet redemption for specific store
//   String getWalletStoreRedemptionStatus(String storeId) {
//     final key = 'wallet_$storeId';
//     return _redemptions[key]?['status'] ?? 'none';
//   }

//   /// Clear all redemption data
//   void clearData() {
//     _redemptions.clear();
//     _redemptionResponse = null;
//     _statusResponse = null;
//     _errorMessage = null;
//     _isLoading = false;
//     notifyListeners();
//     debugPrint('🧹 RedemptionProvider cleared');
//   }

//   /// Debug: Print all stored redemptions
//   void debugPrintRedemptions() {
//     debugPrint('📋 Current redemptions:');
//     _redemptions.forEach((key, value) {
//       debugPrint('  $key: ${value['status']} (ID: ${value['redemptionId']})');
//     });
//   }
// }
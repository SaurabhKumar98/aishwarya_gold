import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/data/models/sip_subscriptionmodels/sipsubmodels.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';

/// 📡 SIP Repository
/// Handles all SIP subscription API calls
class SipRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  /// 🚀 Create SIP Subscription
  /// Step 1 of SIP flow: Creates subscription and gets subscription ID
  /// Returns: SIPSubscriptionResponse with subscriptionId for Razorpay
  Future<SIPSubscriptionResponse?> createSipSubscription({
    required String planName,
    required int investmentAmount,
    required String frequency,
    required String startDate,
  }) async {
    try {
      // 🔑 Get user ID from session
      final String userId = await SessionManager.getUserId() ?? "";
      
      if (userId.isEmpty) {
        return null;
      }

      // 🌐 Build API endpoint
      final String url = "${AppUrl.localUrl}/user/sip/$userId/buy";

      // 📦 Prepare request body
      final Map<String, dynamic> body = {
        "planName": planName,
        "investmentAmount": investmentAmount,
        "frequency": frequency,
        "startDate": startDate,
      };

      // 📡 Make API call
      final response = await _apiServices.postApiResponse(url, body);


      // ✅ Validate response
      if (response == null) {
        return null;
      }

      // 🔄 Parse response to model
      final result = SIPSubscriptionResponse.fromJson(response);

      // 💾 Save subscription ID to session storage
      // This ID will be used for Razorpay checkout
      final subscriptionId = result.data?.razorpay?.subscriptionId;
      
      if (subscriptionId != null && subscriptionId.isNotEmpty) {
        await SessionManager.saveData("razorpaySubscriptionId", subscriptionId);
        
      } else {
    
      }

      return result;
    } catch (e, stackTrace) {
      
   
      return null;
    }
  }

  /// ✅ Verify SIP Payment
  /// Step 2 of SIP flow: Verifies mandate payment and saves plan to database
  /// Called after successful ₹5 mandate payment
  Future<bool> verifySipPayment({
    required String userId,
    required String razorpaySubscriptionId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String planName,
    required DateTime startDate,
    required double investmentAmount,
    required String frequency,
  }) async {
    try {
      
      // 🌐 Build verification endpoint
      final String url = "${AppUrl.localUrl}/user/sip/$userId/verify";

      // 📦 Prepare verification body
      final Map<String, dynamic> body = {
        "razorpaySubscriptionId": razorpaySubscriptionId,
        "razorpayPaymentId": razorpayPaymentId,
        "razorpaySignature": razorpaySignature,
        "planName": planName,
        "startDate": startDate.toIso8601String(),
        "investmentAmount": investmentAmount,
        "frequency": frequency,
      };

      

      // 📡 Make API call
      final response = await _apiServices.postApiResponse(url, body);

      

      // ✅ Check success
      if (response != null && response['success'] == true) {
        
        // 🗑️ Clear subscription ID from session after successful verification
        await SessionManager.removeData("razorpaySubscriptionId");
        
        return true;
      } else {
        return false;
      }
    } catch (e, stackTrace) {
      
      return false;
    }
  }
}


import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'dart:convert';

class OtpRepo {
  final NetworkApiServices _apiService = NetworkApiServices();

// Temporarily add this to your OtpRepo sendOtp method to see the exact response
Future<Map<String, dynamic>> sendOtp(String phone) async {
  print("the url is ${AppUrl.loginUrl}");
  try {
    final response = await _apiService.postApiResponse(AppUrl.loginUrl, {
      "phone": phone,
    });
    print("🟢 Send OTP Response: $response");
    print("🟢 Response Type: ${response.runtimeType}");
    print("🟢 Response Keys: ${response.keys}");
    print("🟢 Has statusCode? ${response.containsKey('statusCode')}");
    print("🟢 Has success? ${response.containsKey('success')}");
    return response;
  } catch (e) {
    print("🔴 Error sending OTP: $e");
    rethrow;
  }
}

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    print("the url is ${AppUrl.otpverfUrl}");
    try {
      print("the fields are $phone and otp is $otp");
      final response = await _apiService.postApiResponse(AppUrl.otpverfUrl, {
        "phone": phone,
        "otp": otp,
      });
      print("🟢 Verify OTP Response: $response");
      return {'statusCode': response['statusCode'] ?? 200, 'data': response};
    } catch (e) {
      print("🔴 Error verifying OTP: $e");
      if (e.toString().contains('404')) {
        return {'statusCode': 404, 'data': null};
      }
      rethrow;
    }
  }

Future<Map<String, dynamic>> sendFcmToken({
  required String accessToken,
  required String fcmToken,
}) async {
  try {
    print("🌐 Sending FCM token...");
    print("🔑 Access Token: $accessToken");
    print("📱 FCM Token: $fcmToken");

    final response = await _apiService.postApiResponseWithHeader(
      '${AppUrl.localUrl}/user/notifications/register-device',
      {
        'token': fcmToken, // ✅ exact key backend expects
      },
      {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print("📥 Response status: ${response['statusCode']}");
    print("📥 Response body: ${response['body']}");
    return response;
  } catch (e) {
    print("🔴 Error sending FCM token: $e");
    return {
      'statusCode': 500,
      'body': {'error': e.toString()},
    };
  }
}

}

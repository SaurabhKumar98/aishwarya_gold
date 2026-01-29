import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/data/models/authmodels/login_models.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';

class LoginRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<LoginModel> login({required String phone}) async {
    try {
      print("🟡 [LoginRepo] Starting login request...");
      print("🔹 URL: ${AppUrl.loginUrl}");
      print("🔹 Request Body: { phone: $phone }");

      // Send the request to your backend login endpoint
      final response = await _apiServices.postApiResponse(AppUrl.loginUrl, {
        "phone": phone,
      });

      print("🟢 [LoginRepo] Raw Response: $response");

      // Convert API JSON response to model
      final loginModel = LoginModel.fromJson(response);

      print(
        "✅ [LoginRepo] Parsed Response -> "
        "Success: ${loginModel.success}, Message: ${loginModel.message}, "
        "OTP: ${loginModel.data?.otp}",
      );

      return loginModel;
    } catch (e, stackTrace) {
      print("🔴 [LoginRepo] Error during login: $e");
      print("📜 Stack Trace: $stackTrace");
      rethrow;
    }
  }
}

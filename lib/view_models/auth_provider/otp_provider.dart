import 'dart:async';
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/data/models/authmodels/otp_models.dart';
import 'package:aishwarya_gold/data/repo/authrepo/otp_repo.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/utils/exports/exports.dart';
import 'package:aishwarya_gold/view/auth_screen/login_page.dart';
import 'package:aishwarya_gold/view/home_container/Buttom_bar.dart';
import 'package:aishwarya_gold/view_models/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OtpProvider with ChangeNotifier {
  final List<TextEditingController> controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());

  bool _isOtpFilled = false;
  bool get isOtpFilled => _isOtpFilled;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isResending = false;
  bool get isResending => _isResending;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  OtpModel? _verifiedOtp;
  OtpModel? get verifiedOtp => _verifiedOtp;

  // Resend OTP timer and attempts
  int _resendTimer = 30;
  int get resendTimer => _resendTimer;
  
  int _resendAttempts = 0;
  int get resendAttempts => _resendAttempts;
  
  Timer? _timer;
  
  // Lockout mechanism
  bool _isLockedOut = false;
  bool get isLockedOut => _isLockedOut;
  
  DateTime? _lockoutEndTime;
  DateTime? get lockoutEndTime => _lockoutEndTime;
  
  Timer? _lockoutTimer;

  final OtpRepo _otpRepo = OtpRepo();

  void onChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    _isOtpFilled = controllers.every((c) => c.text.isNotEmpty);
    
    // Clear error when user starts typing
    if (_errorMessage != null) {
      _errorMessage = null;
    }
    
    notifyListeners();
  }

  String getOtp() {
    return controllers.map((c) => c.text).join();
  }

  // Start resend timer
  void startResendTimer() {
    _resendTimer = 30;
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        _resendTimer--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  // Resend OTP function
  Future<void> resendOtp(String phone, BuildContext context) async {
    // Check if locked out
    if (_isLockedOut) {
      return;
    }

    // Check attempts
    if (_resendAttempts >= 3) {
      _startLockout();
      return;
    }

    _isResending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint("🔄 Resending OTP to: $phone");
      
      // Call your sendOtp API from OtpRepo
      final response = await _otpRepo.sendOtp(phone).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception("Request timed out"),
      );
      
      debugPrint("📥 Resend OTP Full Response: $response");
      
      // Check multiple possible response structures
      final statusCode = response['statusCode'] ?? 200;
      final success = response['success'] ?? true; // Default to true if not present
      final message = response['message'];
      
      debugPrint("📊 Status Code: $statusCode");
      debugPrint("✅ Success: $success");
      debugPrint("💬 Message: $message");
      
      // Consider it successful if statusCode is 200 OR success is true
      if (statusCode == 200 || statusCode == 201 || success == true) {
        _resendAttempts++;
        startResendTimer();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(message ?? 'OTP sent successfully to $phone'),
                  ),
                ],
              ),
              backgroundColor: AppColors.coinBrown,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        _errorMessage = message ?? "Failed to resend OTP. Please try again.";
        debugPrint("⚠️ Resend failed with message: $_errorMessage");
      }
      
    } catch (e) {
      _errorMessage = "Failed to resend OTP. Please check your connection.";
      debugPrint("🔴 Resend OTP Error: $e");
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    } finally {
      _isResending = false;
      notifyListeners();
    }
  }

  // Start 1-hour lockout
  void _startLockout() {
    _isLockedOut = true;
    _lockoutEndTime = DateTime.now().add(const Duration(hours: 1));
    
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (DateTime.now().isAfter(_lockoutEndTime!)) {
        _isLockedOut = false;
        _resendAttempts = 0;
        _lockoutEndTime = null;
        timer.cancel();
        notifyListeners();
      } else {
        notifyListeners();
      }
    });
    
    notifyListeners();
  }

  // Format lockout time remaining
  String formatLockoutTime() {
    if (_lockoutEndTime == null) return "";
    
    final remaining = _lockoutEndTime!.difference(DateTime.now());
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    
    if (minutes > 0) {
      return "$minutes minute${minutes > 1 ? 's' : ''} ${seconds}s";
    } else {
      return "${seconds}s";
    }
  }

  Future<void> sendFcmTokenIfNeeded() async {
  try {
    final accessToken = await SessionManager.getAccessToken();
    String? fcmToken = await SessionManager.getDeviceToken();
    
    // If no token in storage, fetch fresh
    if (fcmToken == null || fcmToken.isEmpty) {
      fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await SessionManager.storeDeviceToken(fcmToken);
      }
    }
    
    if (fcmToken != null && fcmToken.isNotEmpty && accessToken != null && accessToken.isNotEmpty) {
      final response = await _otpRepo.sendFcmToken(
        accessToken: accessToken,
        fcmToken: fcmToken,
      );
      debugPrint("📲 Device token registered: $response");
    }
  } catch (e) {
    debugPrint("⚠️ Failed to send FCM token: $e");
  }
}

  Future<void> verifyOtp(String phone, BuildContext context) async {
    final enteredOtp = getOtp();
    if (enteredOtp.length != 4) {
      _errorMessage = "Please enter a valid 4-digit OTP";
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _otpRepo.verifyOtp(phone, enteredOtp).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception("Request timed out"),
      );
      final statusCode = response['statusCode'];
      final otpModel = OtpModel.fromJson(response['data']);

      _verifiedOtp = otpModel;

      if (statusCode == 404) {
        _errorMessage = "User not found. Please register.";
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!)),
        );

        await Future.delayed(const Duration(seconds: 1));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      } else if (statusCode == 200 && otpModel.success == true) {
        await _storeUserData(otpModel, context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      } else {
        _errorMessage = otpModel.message ?? "OTP verification failed";
      }
    } catch (e) {
      _errorMessage = "Error verifying OTP: $e";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
      
      // Clear OTP fields on error
      for (var controller in controllers) {
        controller.clear();
      }
      if (focusNodes.isNotEmpty) {
        focusNodes[0].requestFocus();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

Future<void> _storeUserData(OtpModel otpModel, BuildContext context) async {
  if (otpModel.data != null && otpModel.data!.user != null) {
    await SessionManager.loginUser(
      accessToken: otpModel.data!.accessToken ?? '',
      refreshToken: otpModel.data!.refreshToken,
      phone: otpModel.data!.user!.phone ?? '',
      userId: otpModel.data!.user!.id,
    );

    // Update UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.login(
      userId: otpModel.data!.user!.id ?? '',
      accessToken: otpModel.data!.accessToken ?? '',
      refreshToken: otpModel.data!.refreshToken,
      phone: otpModel.data!.user!.phone ?? '',
    );

    // Get FCM token - try from storage first, then fetch fresh
    String? fcmToken = await SessionManager.getDeviceToken();
    
    // If token is null or empty, fetch it fresh from Firebase
    if (fcmToken == null || fcmToken.isEmpty) {
      debugPrint("📲 FCM token not in storage, fetching fresh...");
      fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await SessionManager.storeDeviceToken(fcmToken);
        debugPrint("📲 Fresh FCM token stored: ${fcmToken.substring(0, 20)}...");
      }
    }
    
    final accessToken = otpModel.data!.accessToken ?? '';

    if (fcmToken != null && fcmToken.isNotEmpty && accessToken.isNotEmpty) {
      try {
        final response = await _otpRepo.sendFcmToken(
          accessToken: accessToken,
          fcmToken: fcmToken,
        );
        debugPrint("📲 Device token registered successfully: $response");
      } catch (e) {
        debugPrint("⚠️ Failed to register device token: $e");
      }
    } else {
      debugPrint("⚠️ Missing FCM token or access token — not sent");
      debugPrint("   FCM Token: ${fcmToken ?? 'null'}");
      debugPrint("   Access Token: ${accessToken.isEmpty ? 'empty' : 'present'}");
    }
  }
}
  void reset() {
    for (var c in controllers) {
      c.clear();
    }
    _isOtpFilled = false;
    _isLoading = false;
    _isResending = false;
    _errorMessage = null;
    _verifiedOtp = null;
    _resendTimer = 30;
    _resendAttempts = 0;
    _isLockedOut = false;
    _lockoutEndTime = null;
    _timer?.cancel();
    _lockoutTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lockoutTimer?.cancel();
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}
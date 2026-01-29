
import 'dart:convert';

import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:aishwarya_gold/utils/exports/exports.dart' as http;
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _accessToken;
  String? _refreshToken;
  String? _phone;
  bool _isSessionLoaded = false; // Track session load state

  String? get userId => _userId;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get phone => _phone;
  bool get isSessionLoaded => _isSessionLoaded; // Expose load state

  UserProvider() {
    _loadUserSession(); // Initialize on creation
  }

  Future<void> _loadUserSession() async {
    _userId = await SessionManager.getUserId();
    _accessToken = await SessionManager.getAccessToken();
    _refreshToken = await SessionManager.getRefreshToken();
    _phone = await SessionManager.getUserPhone();
    _isSessionLoaded = true; // Mark as loaded
    print("🟢 [UserProvider] Loaded session: userId=$_userId, phone=$_phone, isLoaded=$_isSessionLoaded");
    notifyListeners();
  }

  // Public method to reload session (optional)
  Future<void> reloadSession() async {
    await _loadUserSession();
  }

  Future<void> login({
    required String userId,
    required String accessToken,
    String? refreshToken,
    required String phone,
  }) async {
    _userId = userId;
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _phone = phone;
    _isSessionLoaded = true;
    print("🟢 [UserProvider] Logged in: userId=$_userId, phone=$_phone");
    notifyListeners();
  }

Future<void> logout() async {
  try {
    final fcmToken = await SessionManager.getDeviceToken();
    final token = await SessionManager.getAccessToken();

    if (fcmToken != null && token != null) {
      final response = await http.post(
        Uri.parse(AppUrl.logout),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'fcmToken': fcmToken}),
      );

      print('📤 Logout API response: ${response.body}');
    } else {
      print('⚠️ Missing FCM or access token during logout');
    }
  } catch (e) {
    print('❌ Logout API error: $e');
  }

  // Clear local session data
  _userId = null;
  _accessToken = null;
  _refreshToken = null;
  _phone = null;
  _isSessionLoaded = false;

  await SessionManager.logoutUser();

  print("🔴 [UserProvider] Logged out and cleared session");
  notifyListeners();
}

}
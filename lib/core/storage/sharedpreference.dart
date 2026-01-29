import 'package:aishwarya_gold/utils/exports/exports.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages user session data (tokens, phone, login state)
class SessionManager {
  // ----------------------------
  // Keys
  // ----------------------------
  static const _keyAccessToken = 'accessToken';
  static const _keyRefreshToken = 'refreshToken';
  static const _keyUserPhone = 'userPhone';
  static const _keyUserId = 'userId';
  static const _keyRole = 'role';
  static const _keyIsLoggedIn = 'isLoggedIn';
  static const _keyFingerprintEnabled = 'fingerprintEnabled';

  static SharedPreferences? _prefs;

  // ----------------------------
  // Initialization
  // ----------------------------
  static Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ----------------------------
  // Save User Login Data
  // ----------------------------
  static Future<void> loginUser({
    required String accessToken,
    String? refreshToken,
    required String phone,
    String? userId,
    String? role,
  }) async {
    await _init();
    await _prefs!.setString(_keyAccessToken, accessToken);
    if (refreshToken != null) {
      await _prefs!.setString(_keyRefreshToken, refreshToken);
    }
    if (userId != null) {
      await _prefs!.setString(_keyUserId, userId);
    }
    if (role != null) {
      await _prefs!.setString(_keyRole, role);
    }
    await _prefs!.setString(_keyUserPhone, phone);
    await _prefs!.setBool(_keyIsLoggedIn, true);
  }

  // ----------------------------
  // Save Access Token
  // ----------------------------
  static Future<void> saveAccessToken(String token) async {
    await _init();
    try {
      await _prefs!.setString(_keyAccessToken, token);
      debugPrint('✅ Access token saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving access token: $e');
      throw Exception('Failed to save access token');
    }
  }

    static Future<void> saveData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }


   static Future<void> storeDeviceToken(String token) async {
    await _init();
    try {
      debugPrint("device token is :$token");
      await _prefs!.setString('device_token', token);

      debugPrint('✅ Device Token saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving access token: $e');
      throw Exception('Failed to save access token');
    }
  }




  // ----------------------------
  // Save Refresh Token
  // ----------------------------
  static Future<void> saveRefreshToken(String token) async {
    await _init();
    try {
      await _prefs!.setString(_keyRefreshToken, token);
      debugPrint('✅ Refresh token saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving refresh token: $e');
      throw Exception('Failed to save refresh token');
    }
  }

  // ----------------------------
  // Logout User (clear data)
  // ----------------------------
  static Future<void> logoutUser() async {
    await _init();
    try {
      await _prefs!.remove(_keyAccessToken);
      await _prefs!.remove(_keyRefreshToken);
      await _prefs!.remove(_keyUserPhone);
      await _prefs!.remove(_keyUserId);
      await _prefs!.remove(_keyRole);
      await _prefs!.setBool(_keyIsLoggedIn, false);
      await _prefs!.remove(_keyFingerprintEnabled);
      debugPrint('✅ Session cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing session: $e');
      throw Exception('Failed to clear session');
    }
  }

  // ----------------------------
  // Getters
  // ----------------------------
  static Future<String?> getAccessToken() async {
    await _init();
    final token = _prefs!.getString(_keyAccessToken);
    debugPrint('✅ Access token retrieved: ${token?.substring(0, 20)}...');
    return token;
  }


   static Future<String?> getDeviceToken() async {
    await _init();
    final token = _prefs!.getString("device_token");
    //  debugPrint("device token iss :$token");
    debugPrint('✅ Device token retrieved: ${token}.');
    return token;
  }

  static Future<String?> getRefreshToken() async {
    await _init();
    final token = _prefs!.getString(_keyRefreshToken);
    debugPrint('✅ Refresh token retrieved: ${token?.substring(0, 20)}...');
    return token;
  }

  static Future<String?> getUserPhone() async {
    await _init();
    return _prefs!.getString(_keyUserPhone);
  }

  static Future<String?> getUserId() async {
    await _init();
    return _prefs!.getString(_keyUserId);
  }

  static Future<String?> getRole() async {
    await _init();
    return _prefs!.getString(_keyRole);
  }

  static Future<String?> getData(String key) async {
  await _init();
  return _prefs!.getString(key);
}


  // ----------------------------
  // Login State
  // ----------------------------
  static Future<bool> isLoggedIn() async {
    await _init();
    return _prefs!.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<void> setFingerprintEnabled(bool value) async {
    await _init();
    await _prefs!.setBool(_keyFingerprintEnabled, value);
  }

  static Future<bool> isFingerprintEnabled() async {
    await _init();
    return _prefs!.getBool(_keyFingerprintEnabled) ?? false;
  }

  // ----------------------------
  // Clear Session (Alias for logoutUser)
  // ----------------------------
  static Future<void> clearSession() async {
    await logoutUser();
  }

  static Future<void> clearAllPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  debugPrint('🧹 All SharedPreferences cleared');
}


  static Future<void> removeData(String key) async {
  await _init();
  try {
    await _prefs!.remove(key);
    debugPrint('✅ Data removed successfully for key: $key');
  } catch (e) {
    debugPrint('❌ Error removing data for key $key: $e');
    throw Exception('Failed to remove data');
  }
}
}
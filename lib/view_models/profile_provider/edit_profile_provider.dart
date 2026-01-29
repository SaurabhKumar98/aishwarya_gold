import 'dart:io';
import 'package:aishwarya_gold/data/repo/settingrepo/profile_repo.dart/editprofile_repo.dart';
import 'package:flutter/material.dart';
import 'package:aishwarya_gold/data/models/settingmodels/editprofile_modles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aishwarya_gold/view_models/user_provider.dart';

class EditProfileProvider extends ChangeNotifier {
  final EditprofileRepo _repo = EditprofileRepo();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  UpdateProfileModel? _updateProfile;
  UpdateProfileModel? get updateProfile => _updateProfile;

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;


  /// Initialize provider with current user data
  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    debugPrint("🟢 [Provider] UserProfile initialized: ${_userProfile?.toMap()}");
    notifyListeners();
  }

  /// Update profile (phone comes from UserProvider, NOT sent to API)
Future<bool> updateProfileData({
  required String name,
  required String email,
  String? profilePath,
}) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  debugPrint("🟡 [Provider] Updating profile: name=$name, email=$email, profilePath=$profilePath");

  try {
    // Build UserProfile for API (phone NOT sent)
    final userProfileForApi = UserProfile(
      name: name,
      email: email,
      profilePath: profilePath,
    );

    // Call repo API
    final response = await _repo.updateProfile(userProfileForApi);
    debugPrint("🟢 [Provider] API response: ${response?.toJson()}");

    if (response != null && response.success) {
      _updateProfile = response;

      // Update local provider data
      _userProfile = UserProfile(
        name: name,
        email: email,
        profilePath: profilePath,
      );

      // Save locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', name);
      await prefs.setString('email', email);
      if (profilePath != null) await prefs.setString('profilePath', profilePath);

      debugPrint("✅ [Provider] Profile updated locally: ${_userProfile?.toMap()}");

      return true; // ✅ success
    } else {
      _error = response?.message ?? "Something went wrong";
      debugPrint("❌ [Provider] API error: $_error");
      return false; // ❌ failed
    }
  } catch (e, st) {
    _error = e.toString();
    debugPrint("❌ [Provider] Exception: $e\n$st");
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

    
    void clearData() {
    _updateProfile = null;
    _userProfile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
    print("🧹 RefferAndEarnProvider data cleared on logout");
  }
}

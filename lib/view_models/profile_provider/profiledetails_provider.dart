import 'package:aishwarya_gold/data/models/settingmodels/profiledatails.dart';
import 'package:aishwarya_gold/data/repo/settingrepo/profile_repo.dart/profilerepo.dart';
import 'package:flutter/material.dart';

class ProfiledetailsProvider with ChangeNotifier {
  final Profilerepo _repository = Profilerepo();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  ProfileDetailModels? _profileDetails;
  ProfileDetailModels? get profileDetails => _profileDetails;

  /// Fetch user profile details from API
  Future<void> fetchProfileDetails() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getProfile();

      if ((response.success ?? false) && response.data != null) {
        // ✅ Safely handle nullable bool
        _profileDetails = response;
      } else {
        _error = response.message!.isNotEmpty
            ? response.message
            : "Failed to fetch profile details";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Optional: Refresh (for pull-to-refresh)
  Future<void> refreshProfile() async {
    await fetchProfileDetails();
  }

  /// Optional: Clear (for logout)
  void clearProfileData() {
    _profileDetails = null;
    _error = null;
    notifyListeners();
  }
}

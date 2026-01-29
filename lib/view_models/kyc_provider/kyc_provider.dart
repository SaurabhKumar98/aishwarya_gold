import 'package:aishwarya_gold/data/models/settingmodels/kycstatusmodels.dart';
import 'package:aishwarya_gold/data/repo/settingrepo/kycstatus_repo/kyc_status_repo.dart';
import 'package:flutter/foundation.dart';

class KycStatusProvider with ChangeNotifier {
  final KycStatusRepo _kycRepo = KycStatusRepo();

  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;
  KycStatusModels? _kycStatus;

  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  KycStatusModels? get kycStatus => _kycStatus;

  bool hasShownKycWarning = false;

  void resetKycWarningFlag() {
    hasShownKycWarning = false;
  }

  // Fetch KYC Status
  Future<void> fetchKycStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _kycRepo.fetchKycStatus();
      _kycStatus = result;
      if (!result.success) {
        _errorMessage = result.message;
      }
    } catch (e) {
      _errorMessage = "Failed to fetch KYC status. Please try again.";
      if (kDebugMode) print("KycStatusProvider Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload KYC Documents
  Future<void> uploadKycDocuments(String aadhaarPath, String panPath) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _kycRepo.uploadKycDocuments( aadhaarPath, panPath);
      if (result.success) {
        // Since upload response has data: null, fetch updated status
        await fetchKycStatus();
      } else {
        _errorMessage = result.message;
      }
    } catch (e) {
      _errorMessage = "Failed to upload documents. Please try again.";
      if (kDebugMode) print("KycStatusProvider Upload Error: $e");
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
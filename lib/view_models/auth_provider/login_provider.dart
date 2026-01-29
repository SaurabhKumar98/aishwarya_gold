import 'package:aishwarya_gold/data/models/authmodels/login_models.dart';
import 'package:aishwarya_gold/data/repo/authrepo/login_repo.dart';
import 'package:flutter/foundation.dart';

class LoginProvider with ChangeNotifier {
  final LoginRepo _loginRepo = LoginRepo();

  bool _isLoading = false;
  String? _errorMessage;
  String? _otp;
  LoginModel? _loginResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get otp => _otp;
  LoginModel? get loginResponse => _loginResponse;

  /// Calls the login API and gets OTP
  Future<void> loginUser(String phone) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _loginRepo.login(phone: phone);
      _loginResponse = response;

      if (response.success == true) {
        _otp = response.data?.otp ?? "";
      } else {
        _errorMessage = response.message ?? "Login failed, please try again.";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clear() {
    _errorMessage = null;
    _otp = null;
    _loginResponse = null;
    notifyListeners();
  }
}

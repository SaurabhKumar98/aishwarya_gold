import 'package:aishwarya_gold/data/models/authmodels/reg_models.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view/auth_screen/kyc_verfication_screen.dart';
import 'package:aishwarya_gold/view/auth_screen/login_page.dart';
import 'package:aishwarya_gold/view/auth_screen/set_pin_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aishwarya_gold/data/repo/authrepo/reg_repo.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class RegistrationProvider with ChangeNotifier {
  final RegRepo _regRepo = RegRepo();

  // ------------------- Persistent data -------------------
  String? name;
  String? phone;
  String? pin;
  String? aadhar;
  String? pan;
  String? userId;
  String? referralCode;               // <-- kept across screens

  // ------------------- UI flags -------------------
  bool _isPanUploaded = false;
  bool get isPanUploaded => _isPanUploaded;

  bool _isAadhaarUploaded = false;
  bool get isAadhaarUploaded => _isAadhaarUploaded;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  RegModel? _regModel;
  RegModel? get regModel => _regModel;

  bool get hasReferralCode =>
      referralCode != null && referralCode!.trim().isNotEmpty;

  // ------------------- PIN UI -------------------
  final List<TextEditingController> controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  bool _isPinFilled = false;
  bool get isPinFilled => _isPinFilled;

  void Function(String, int)? onChanged;

  RegistrationProvider() {
    onChanged = (value, index) {
      if (value.isNotEmpty && index < 3) {
        focusNodes[index + 1].requestFocus();
      } else if (value.isEmpty && index > 0) {
        focusNodes[index - 1].requestFocus();
      }
      _isPinFilled = controllers.every((c) => c.text.isNotEmpty);
      notifyListeners();
    };
  }

  String getPin() => controllers.map((c) => c.text).join();

  // ---------------------------------------------------------
  // STEP 1 – Name + Phone + (optional) Referral
  // ---------------------------------------------------------
  void setNamePhone({
    required String n,
    required String p,
    String? referralCode,
    required BuildContext context,
  }) {
    name = n.trim();
    phone = p.trim();
    this.referralCode =
        (referralCode?.trim().isNotEmpty == true) ? referralCode!.trim() : null;

    _errorMessage = null;
    notifyListeners();

    debugPrint(
        "Step 1 → Name: $name, Phone: $phone, Referral: ${this.referralCode ?? 'none'}");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SetPinScreen(
          name: name!,
          phone: phone!,
          referralCode: this.referralCode,
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // STEP 2 – PIN
  // ---------------------------------------------------------
  void setPin(String p, BuildContext context) {
    pin = p;
    _errorMessage = null;
    notifyListeners();

    debugPrint("Step 2 → PIN stored: $pin");
    debugPrint(
        "Data so far → Name: $name, Phone: $phone, PIN: $pin, Referral: $referralCode");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => KYCScreen(
          name: name!,
          phone: phone!,
          pin: pin!,
          referralCode: referralCode, // <-- safe (can be null)
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // FILE UPLOADS
  // ---------------------------------------------------------
  void uploadPan(String panPath) {
    _isPanUploaded = true;
    pan = panPath;
    _errorMessage = null;
    notifyListeners();
    debugPrint("PAN uploaded: $panPath");
  }

  void uploadAadhaar(String aadharPath) {
    _isAadhaarUploaded = true;
    aadhar = aadharPath;
    _errorMessage = null;
    notifyListeners();
    debugPrint("Aadhaar uploaded: $aadharPath");
  }

  // ---------------------------------------------------------
  // STEP 3 – FINAL SUBMIT
  // ---------------------------------------------------------
  Future<void> submitKYC(BuildContext context) async {
    debugPrint("\nStep 3 → Submitting KYC");
    debugPrint(
        "Final payload → Name: $name, Phone: $phone, PIN: $pin, Aadhaar: $aadhar, PAN: $pan, Referral: $referralCode");

    // ---- Null-aware validation ----
    if (name?.trim().isEmpty ?? true) {
      _errorMessage = "Name is missing";
      notifyListeners();
      return;
    }
    if (phone?.trim().isEmpty ?? true) {
      _errorMessage = "Phone is missing";
      notifyListeners();
      return;
    }
    if (pin?.isEmpty ?? true) {
      _errorMessage = "PIN is missing";
      notifyListeners();
      return;
    }
    if (!_isPanUploaded || pan == null) {
      _errorMessage = "Please upload PAN card";
      notifyListeners();
      return;
    }
    if (!_isAadhaarUploaded || aadhar == null) {
      _errorMessage = "Please upload Aadhaar card";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint("Calling registerUser API...");

      final response = await _regRepo.registerUser(
        name: name!,
        phone: phone!,
        pin: pin!,
        aadhar: aadhar!,
        pan: pan!,
        referralCode: referralCode, // <-- **sent to backend**
      );

      _regModel = response;
      debugPrint(
          "API → success=${response.success}, message=${response.message}");

      if (response.success == true) {
        // ---- SUCCESS ----
        userId = response.data?.user?.id;
        await _storeUserData(response);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Registration successful! Please login to continue."),
            backgroundColor: AppColors.coinBrown,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 800));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => const AuthScreen(initialIsSignUp: false)),
          (route) => false,
        );

        clearData();
      } else if (response.message
              ?.toLowerCase()
              .contains("already exists") ??
          false) {
        // ---- ALREADY REGISTERED ----
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "You are already registered! Redirecting to login..."),
            backgroundColor: AppColors.coinBrown,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => const AuthScreen(initialIsSignUp: false)),
          (route) => false,
        );

        clearData();
      } else {
        // ---- OTHER ERRORS ----
        _errorMessage =
            response.message ?? "Registration failed. Please try again.";
        notifyListeners();
      }
    } catch (e) {
      debugPrint("submitKYC error: $e");
      _errorMessage = "Network error: $e";
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------
  // Persist user data locally
  // ---------------------------------------------------------
  Future<void> _storeUserData(RegModel regModel) async {
    final prefs = await SharedPreferences.getInstance();
    final user = regModel.data?.user;
    if (user == null) return;

    await prefs.setString('userId', user.id ?? '');
    await prefs.setString('name', user.name ?? '');
    await prefs.setString('phone', user.phone ?? '');
    if (user.pin != null) await prefs.setString('pin', user.pin!);
    if (user.aadharcard != null) {
      await prefs.setString('aadhar', user.aadharcard!);
    }
    if (user.pancard?.isNotEmpty ?? false) {
      await prefs.setString('pan', user.pancard!.first);
    }
    debugPrint("User data saved to SharedPreferences");
  }

  // ---------------------------------------------------------
  // Reset everything
  // ---------------------------------------------------------
  void clearData() {
    name = phone = pin = aadhar = pan = userId = referralCode = null;
    _isPanUploaded = _isAadhaarUploaded = false;
    _errorMessage = null;
    _regModel = null;
    for (var c in controllers) c.clear();
    debugPrint("Registration data cleared");
    notifyListeners();
  }

  @override
  void dispose() {
    for (var c in controllers) c.dispose();
    for (var f in focusNodes) f.dispose();
    super.dispose();
  }
}
import 'package:aishwarya_gold/data/models/redeemCodemodels/redeemcodemodels.dart';
import 'package:aishwarya_gold/data/repo/redeemcoderepo/redeem_code_repo.dart';
import 'package:aishwarya_gold/utils/exports/exports.dart';

class RedeemCodeProvider extends ChangeNotifier {
  final RedeemCodeRepo _redeemRepo = RedeemCodeRepo();

  bool _isLoading = false;
  String? _errorMessage;
  RedeemResponse? _redeemResponse;

  // NEW FIELDS
  String appliedCode = "";
  bool isApplied = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RedeemResponse? get redeemResponse => _redeemResponse;

  Future<void> redeemCode(String code) async {
    _isLoading = true;
    _errorMessage = null;
    _redeemResponse = null;
    notifyListeners();

    try {
      final response = await _redeemRepo.redeemCode(code);
      _redeemResponse = response;

      if (response.success) {
        // Store applied code
        appliedCode = code.toUpperCase();
        isApplied = true;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearRedeemState() {
    _redeemResponse = null;
    _errorMessage = null;
    _isLoading = false;

    // Reset applied code
    appliedCode = "";
    isApplied = false;

    notifyListeners();
  }

  bool get hasActiveCode => isApplied && _redeemResponse?.success == true;

  String? get currentCodeType => _redeemResponse?.data?.codeType;

  bool get isGiftCode => currentCodeType == 'gift';

  bool get isPromoCode => currentCodeType == 'promo';
}

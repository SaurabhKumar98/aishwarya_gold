import 'package:aishwarya_gold/data/repo/redeemcoderepo/cancelreddemcoderepo.dart';
import 'package:flutter/material.dart';
import 'package:aishwarya_gold/data/models/redeemCodemodels/cancelreddemcodemodels.dart';
class GiftCancelProvider with ChangeNotifier {
  final GiftCancelRepo _repo = GiftCancelRepo();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  GiftCancelResponse? _response;
  GiftCancelResponse? get response => _response;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// -------------------------------------------------------------
  /// CANCEL GIFT CODE (NO FLUSHBAR)
  /// -------------------------------------------------------------
  Future<void> cancelGift({
    required String token,
    required String code,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final result = await _repo.cancelGift(token, code);
      _response = result;

      if (result.success != true) {
        _errorMessage = result.message;
      }
    } catch (e) {
      _errorMessage = "Something went wrong: $e";
    } finally {
      _setLoading(false);
    }
  }
}

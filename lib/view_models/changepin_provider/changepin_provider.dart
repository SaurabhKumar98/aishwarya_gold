import 'package:aishwarya_gold/data/repo/settingrepo/changepin_repo/changepin_repo.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:flutter/material.dart';

class ChangePinProvider with ChangeNotifier {
  final ChangePinRepo _repo = ChangePinRepo();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;

  Future<void> changePin({
    required String newPin,
    required String confirmPin,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      final response = await _repo.changePin(
        newPin: newPin,
        confirmPin: confirmPin,
      );

      if (response['success'] == true) {
        _message = response['message'] ?? "PIN changed successfully";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_message!),
            backgroundColor: AppColors.coinBrown,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        _message = response['message'] ?? "Failed to change PIN";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_message!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _message = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_message!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

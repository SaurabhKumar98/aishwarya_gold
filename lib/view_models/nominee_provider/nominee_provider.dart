import 'package:aishwarya_gold/data/models/settingmodels/nominee_models.dart';
import 'package:aishwarya_gold/data/repo/settingrepo/nominee_repo/nominee_repo.dart';
import 'package:flutter/material.dart';


class NomineeProvider with ChangeNotifier {
  final NomineeRepo _nomineeRepo = NomineeRepo();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Nominee? _response;
  Nominee? get response => _response;

  Future<void> createNominee(Nominee model) async {
    _isLoading = true;
    notifyListeners();

    try {
      _response = await _nomineeRepo.createNominee(model);
    } catch (e) {
      debugPrint("Error creating nominee: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

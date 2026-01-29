import 'package:aishwarya_gold/data/models/settingmodels/nominne_details_byuserid_modles.dart';
import 'package:aishwarya_gold/data/repo/settingrepo/nominee_repo/nominee_details_repo.dart';
import 'package:flutter/material.dart';

class NomineeDetailsProvider with ChangeNotifier {
  final NomineeDetailsRepo _repo = NomineeDetailsRepo();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  NomineeDetails? _nomineeDetails;
  NomineeDetails? get nomineeDetails => _nomineeDetails;

  /// 🔹 Fetch nominee details (paginated)
  Future<void> fetchNomineeDetails({int pageNumber = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _nomineeDetails = await _repo.getNomineeDetails(pageNumber);
    } catch (e) {
      debugPrint("❌ Error fetching nominee details: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

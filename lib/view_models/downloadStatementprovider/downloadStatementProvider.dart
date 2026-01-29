import 'package:flutter/material.dart';
import 'package:aishwarya_gold/data/models/downloadstatemetagmodels/downloadstatementmodels.dart';
import 'package:aishwarya_gold/data/repo/downloadstatemetagrepo/downloadstatementrepo.dart';

class DownloadStatementProvider with ChangeNotifier {
  final DownloadStatementRepo _repo = DownloadStatementRepo();

  bool _isLoading = false;
  String? _errorMessage;
  DownloadStatementModels? _statementData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DownloadStatementModels? get statementData => _statementData;

  /// Fetch download statement by plan ID
  Future<void> fetchDownloadStatement(String Id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repo.getDownloadStatement(Id);
      _statementData = data;
      _isLoading = false;
      notifyListeners();
      print("✅ Download statement fetched successfully for plan: $Id");
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      print("❌ Error fetching statement: $_errorMessage");
    }
  }

  /// Clear data (optional utility)
  void clearData() {
    _statementData = null;
    _errorMessage = null;
    notifyListeners();
  }
}

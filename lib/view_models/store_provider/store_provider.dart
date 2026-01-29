import 'package:aishwarya_gold/data/models/storemodels/store_models.dart';
import 'package:aishwarya_gold/data/repo/store_repo/store_repo.dart';
import 'package:flutter/foundation.dart';

class StoreProvider with ChangeNotifier {
  final StoreRepo _repo = StoreRepo();

  bool _isLoading = false;
  StoreModels? _storeData;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  StoreModels? get storeData => _storeData;
  String? get errorMessage => _errorMessage;

  /// Fetch stores from API
  Future<void> fetchStores() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repo.getStore();
      _storeData = result;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print("Error fetching stores: $_errorMessage");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  

  /// Refresh stores manually
  Future<void> refreshStores() async {
    await fetchStores();
  }
}

import 'package:aishwarya_gold/data/models/goldprice_models/gold_price_models.dart';
import 'package:aishwarya_gold/data/repo/goldpricerepo/gold_price_repo.dart';
import 'package:flutter/foundation.dart';

class GoldProvider with ChangeNotifier {
  final GoldPriceRepo _goldPriceRepo = GoldPriceRepo();

  

  bool _isLoading = false;
  String? _errorMessage;
  GoldPrice? _goldPrice;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  GoldPrice? get goldPrice => _goldPrice;

  /// ✅ This is the method that must exist
  Future<void> fetchGoldPrice() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _goldPriceRepo.getSavingPrice();

      if (response != null && response.success == true) {
        _goldPrice = response;
      } else {
        _errorMessage = response?.message ?? "Failed to load gold price";
      }
    } catch (e) {
      _errorMessage = "Error: $e";
      if (kDebugMode) print("GoldProvider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double get currentPricePerGram {
    return _goldPrice?.data?.currentPricePerGram ?? 0.0;
  }
}

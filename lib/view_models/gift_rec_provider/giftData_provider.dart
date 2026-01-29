import 'package:aishwarya_gold/data/repo/settingrepo/gift_recive_repo/gift_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:aishwarya_gold/data/models/settingmodels/recive_gift_models.dart';

class GiftsProvider with ChangeNotifier {
  final GiftRepo _repository = GiftRepo();

  List<GiftData> _giftList = [];
  List<GiftData> get giftList => _giftList;

  bool _isGiftLoading = false;
  bool get isGiftLoading => _isGiftLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> getGifts() async {
    _isGiftLoading = true;
    _errorMessage = null;
    notifyListeners(); // notify once at start

    try {
      final response = await _repository.getGifts();

      if (response.success == true) {
        // SUCCESS → update list
        _giftList = response.data ?? [];
      } else {
        // FAILURE → clear list
        _giftList = [];
        _errorMessage = "Please log in to see your gifts.";
      }
    } catch (e) {
      debugPrint("❌ Error fetching gifts: $e");
      _giftList = [];
      _errorMessage = "Unable to load gifts. Please login again.";
    }

    _isGiftLoading = false;
    notifyListeners(); // notify once at end
  }

  void clearGifts() {
    _giftList = [];
    notifyListeners();
  }
}

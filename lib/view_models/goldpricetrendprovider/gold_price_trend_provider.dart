
import 'package:flutter/foundation.dart';
import 'package:aishwarya_gold/data/models/gold_price_trend_models.dart';
import 'package:aishwarya_gold/data/repo/goldpricetrend/gold_price_trend.dart';

class GoldPriceProvider extends ChangeNotifier {
  final GoldPriceRepository _repository = GoldPriceRepository();

  // ✅ Default to 1 Month
  TimePeriod _selectedPeriod = TimePeriod.oneMonth;
  List<GoldPriceData> _prices = [];
  GoldPriceStats? _stats;
  bool _isLoading = false;
  String? _error;

  List<GoldPriceData> get prices => _prices;
  GoldPriceStats? get stats => _stats;
  TimePeriod get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// ✅ Fetch prices for the given period
  Future<void> fetchPrices(TimePeriod period) async {
    _selectedPeriod = period;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prices = await _repository.fetchGoldPrices(period);
      _stats = GoldPriceStats.fromPriceList(_prices);
      debugPrint('✅ Fetched ${_prices.length} price points for ${period.label}');
    } catch (e) {
      _error = e.toString();
      _prices = [];
      _stats = null;
      debugPrint('❌ Error in fetchPrices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Change selected period (used when user taps “1 Month”, “6 Months”, etc.)
  void changePeriod(TimePeriod period) {
    if (_selectedPeriod != period) {
      fetchPrices(period);
    }
  }

  /// ✅ Called once when the screen first opens
  Future<void> initialize() async {
    if (_prices.isEmpty && !_isLoading) {
      await fetchPrices(_selectedPeriod); // 👈 default = 1 month
    }
  }
}

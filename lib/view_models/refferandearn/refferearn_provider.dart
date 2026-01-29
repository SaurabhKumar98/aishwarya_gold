import 'package:aishwarya_gold/data/models/refferandearnmodels/refferandearnmodels.dart';
import 'package:aishwarya_gold/data/models/refferandearnmodels/refferhistorymodels.dart';
import 'package:aishwarya_gold/data/repo/refferandearn_repo/refferandearn_repo.dart';
import 'package:flutter/foundation.dart';

class RefferAndEarnProvider with ChangeNotifier {
  final RefferandearnRepo _repo = RefferandearnRepo();

  bool _loading = false;
  String? _errorMessage;

  RefferAndEarn? _refferData;
  ReferralData? _referralHistoryData;
  List<ReferralHistory> _historyList = [];

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  RefferAndEarn? get refferData => _refferData;
  ReferralData? get referralHistoryData => _referralHistoryData;
  List<ReferralHistory> get historyList => _historyList;

  double get walletBalance => _referralHistoryData?.walletBalance ?? 0;
  String get referralCode => _referralHistoryData?.redeemReferralCode ?? '';
  bool get showRedeemButton =>
      _referralHistoryData?.showReferralRedemption ?? false;

  // ---------------------------------------------------------
  // FETCH REFER & EARN BASIC DATA
  // ---------------------------------------------------------
  Future<void> fetchRefferAndEarnData() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repo.getRefferCode();
      _refferData = response;

      debugPrint(
        "✅ RefferAndEarn fetched: ${response.data?.referralCode}",
      );
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("🔴 Error fetching RefferAndEarn: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------
  // FETCH REFER HISTORY DATA
  // ---------------------------------------------------------
  Future<void> fetchReferHistory() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repo.getRefferHistory();

      _referralHistoryData = response.data;
      _historyList = response.data?.history ?? [];

      debugPrint("✅ Referral history count: ${_historyList.length}");

      for (final item in _historyList) {
        debugPrint(
          "👤 ${item.referredUserName} | 💰 ${item.amountEarned} | 📅 ${item.referredAt} | 📜 ${item.status}",
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("🔴 Error fetching referral history: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------
  // REFRESH ALL DATA
  // ---------------------------------------------------------
  Future<void> refresh() async {
    await fetchRefferAndEarnData();
    await fetchReferHistory();
  }

  // ---------------------------------------------------------
  // CLEAR ALL DATA ON LOGOUT
  // ---------------------------------------------------------
  void clearData() {
    _refferData = null;
    _referralHistoryData = null;
    _historyList.clear();
    _errorMessage = null;
    _loading = false;

    notifyListeners();
    debugPrint("🧹 RefferAndEarnProvider cleared on logout");
  }
}

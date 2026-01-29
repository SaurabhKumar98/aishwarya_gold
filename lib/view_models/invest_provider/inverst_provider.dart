import 'package:aishwarya_gold/data/repo/gstrep/gst_repo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/data/models/buy_sip_models/buysip_models.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:aishwarya_gold/view_models/user_provider.dart';
import 'package:aishwarya_gold/data/models/agplanmodels/agplanmodel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aishwarya_gold/view_models/gold_price_provider/goldprice_provider.dart';

enum InvestmentMode { oneTime, sip, ag }

class InvestmentProvider extends ChangeNotifier {
  final GstRepo _gstRepo = GstRepo();

  // ──────────────────────────────────────────────────────────────
  // Core state
  // ──────────────────────────────────────────────────────────────
  InvestmentMode _mode = InvestmentMode.oneTime; // Default
  bool _agreed = false;
  int _selectedQuickOption = -1; // -1 = none
  bool _isGramMode = true; // true = grams, false = rupees (One-Time only)
  final TextEditingController inputController = TextEditingController();

  double _goldPrice = 0.0;      // per gram
  double gstPercentage = 0.0; // fetched from backend (e.g. 3.0)

  // One-Time
  double _oneTimeCalculatedValue = 0.0; // grams (gram-mode) or rupees (rupee-mode)
  double _oneTimeGrams = 0.0;
  double _oneTimeInvestedAmount = 0.0;
  final List<Map<String, dynamic>> _oneTimePlans = [];

  // SIP
  double _sipAnnualInvestment = 0.0;
  double _sipInvestedAmount = 0.0;
  double _sipGrams = 0.0;
  DateTime _selectedSipDate = DateTime.now();
  final List<Map<String, dynamic>> _sipPlans = [];

  // AG
  final List<Map<String, dynamic>> _agPlans = [];

  String? _warningMessage;

  // ──────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────
  double _calcGst(double amount) => amount * (gstPercentage / 100.0);
  double get goldValue => isOneTime ? _oneTimeInvestedAmount : _sipInvestedAmount;

  // ──────────────────────────────────────────────────────────────
  // Public getters
  // ──────────────────────────────────────────────────────────────
  InvestmentMode get mode => _mode;
  bool get isOneTime => _mode == InvestmentMode.oneTime;
  bool get isSip => _mode == InvestmentMode.sip;
  bool get isAg => _mode == InvestmentMode.ag;
  bool get agreed => _agreed;
  int get selectedQuickOption => _selectedQuickOption;
  bool get isGramMode => _isGramMode;
  String? get warningMessage => _warningMessage;

  double get sipAnnualInvestment => _sipAnnualInvestment;
  double get goldQty => isOneTime ? _oneTimeGrams : _sipGrams;
  double get investedAmount => isOneTime ? _oneTimeInvestedAmount : _sipInvestedAmount;

  double get gst => _calcGst(goldValue);
  double get totalWithGst => goldValue + gst;

  List<Map<String, dynamic>> get sipPlans => _sipPlans;
  DateTime get selectedSipDate => _selectedSipDate;
  List<Map<String, dynamic>> get oneTimePlans => _oneTimePlans;
  List<Map<String, dynamic>> get agPlans => _agPlans;

  // ──────────────────────────────────────────────────────────────
  // UI display strings
  // ──────────────────────────────────────────────────────────────
  String get displayResult {
    if (isOneTime) {
      if (_isGramMode) {
        // user entered grams → show rupees
        return "₹${(_oneTimeCalculatedValue * _goldPrice).toStringAsFixed(2)}";
      } else {
        // user entered rupees → show grams
        return "${(_oneTimeCalculatedValue).toStringAsFixed(3)} g";
      }
    } else if (isSip) {
      return "₹${_sipInvestedAmount.toStringAsFixed(2)}";
    }
    return "N/A";
  }

  String get displayTotal {
    if (isOneTime) {
      if (_isGramMode) {
        // total (incl. GST) when entering grams
        final base = _oneTimeCalculatedValue * _goldPrice;
        return "₹${(base + _calcGst(base)).toStringAsFixed(2)}";
      } else {
        // total = entered rupees + GST on entered rupees
        final entered = double.tryParse(inputController.text) ?? 0.0;
        return "₹${(entered + _calcGst(entered)).toStringAsFixed(2)}";
      }
    } else if (isSip) {
      return "₹${totalWithGst.toStringAsFixed(2)}";
    }
    return "₹0.00";
  }

  // ──────────────────────────────────────────────────────────────
  // Gold price sync
  // ──────────────────────────────────────────────────────────────
  void syncGoldPrice(BuildContext context) {
    final goldProvider = Provider.of<GoldProvider>(context, listen: false);
    final newPrice = goldProvider.currentPricePerGram;
    if (newPrice != _goldPrice) {
      _goldPrice = newPrice;
      _recalculateAll(); // price changed → recalc everything
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Mode switching
  // ──────────────────────────────────────────────────────────────
  void togglePlan(InvestmentMode mode) {
    _mode = mode;
    _resetFieldsForMode();
    _warningMessage = null;
    notifyListeners();
  }

  void _resetFieldsForMode() {
    if (mode == InvestmentMode.sip) {
      _isGramMode = false;
      _selectedQuickOption = -1;
      _oneTimeCalculatedValue = _oneTimeGrams = _oneTimeInvestedAmount = 0;
      inputController.clear();
      _selectedSipDate = DateTime.now();
    } else if (mode == InvestmentMode.oneTime) {
      _isGramMode = true;
      _sipInvestedAmount = _sipAnnualInvestment = _sipGrams = 0;
      _selectedQuickOption = -1;
      inputController.clear();
    } else if (mode == InvestmentMode.ag) {
      _clearAll();
      _isGramMode = true;
    }
  }

  void _clearAll() {
    _oneTimeCalculatedValue = _oneTimeGrams = _oneTimeInvestedAmount = 0;
    _sipInvestedAmount = _sipAnnualInvestment = _sipGrams = 0;
    _selectedQuickOption = -1;
    inputController.clear();
  }

  // ──────────────────────────────────────────────────────────────
  // Agreement & quick options
  // ──────────────────────────────────────────────────────────────
  void toggleAgreement(bool value) {
    _agreed = value;
    notifyListeners();
  }

  void selectQuickOption(int index, BuildContext context) {
    _selectedQuickOption = index;
    syncGoldPrice(context);
    
    if (_goldPrice == 0.0) {
      _warningMessage = "Gold price not available. Please try again.";
      notifyListeners();
      return;
    }

    if (isOneTime) {
      _handleOneTimeQuickOption(index);
    } else if (isSip) {
      _handleSipQuickOption();
    }
    
    // Validate after setting quick option
    if (isOneTime) {
      _validateAmount();
    } else if (isSip) {
      _validateSipAmount();
    }
    
    notifyListeners();
  }

  void _handleOneTimeQuickOption(int index) {
    if (_isGramMode) {
      final grams = [10, 20, 50][index];
      inputController.text = grams.toString();
      _oneTimeCalculatedValue = grams.toDouble();
      _oneTimeGrams = grams.toDouble();
      _oneTimeInvestedAmount = grams * _goldPrice;
    } else {
      final rupees = [1000, 2000, 3000][index];
      inputController.text = rupees.toString();
      _oneTimeCalculatedValue = rupees / _goldPrice;
      _oneTimeGrams = _oneTimeCalculatedValue;
      _oneTimeInvestedAmount = rupees.toDouble();
    }
  }

  void _handleSipQuickOption() {
    final parsed = double.tryParse(inputController.text) ?? 0;
    _sipInvestedAmount = parsed;
    _sipGrams = parsed / _goldPrice;
    
    final multiplier = _selectedQuickOption == 0 
        ? 365 
        : _selectedQuickOption == 1 
            ? 52 
            : 12;
    
    _sipAnnualInvestment = parsed * multiplier;
    
    // Validate the amount with selected frequency
    _validateSipAmount();
  }

  // ──────────────────────────────────────────────────────────────
  // Input handling
  // ──────────────────────────────────────────────────────────────
  void updateValue(String val, BuildContext context) {
    syncGoldPrice(context);
    
    if (val.isEmpty) {
      _clearCalculations();
      _warningMessage = null;
      notifyListeners();
      return;
    }

    if (_goldPrice == 0.0) {
      _warningMessage = "Gold price not available. Please try again.";
      notifyListeners();
      return;
    }

    final parsed = double.tryParse(val) ?? 0;
    
    if (isOneTime) {
      _calcOneTime(parsed);
      _validateAmount();
    } else if (isSip) {
      _calcSip(parsed);
      _validateSipAmount();
    }
    
    notifyListeners();
  }

  void _clearCalculations() {
    if (isOneTime) {
      _oneTimeCalculatedValue = _oneTimeGrams = _oneTimeInvestedAmount = 0;
    } else if (isSip) {
      _sipInvestedAmount = _sipAnnualInvestment = _sipGrams = 0;
    }
  }

  void _calcOneTime(double value) {
    if (_isGramMode) {
      _oneTimeCalculatedValue = value;
      _oneTimeGrams = value;
      _oneTimeInvestedAmount = value * _goldPrice;
    } else {
      _oneTimeCalculatedValue = value / _goldPrice;
      _oneTimeGrams = _oneTimeCalculatedValue;
      _oneTimeInvestedAmount = value;
    }
  }

  void _calcSip(double value) {
    _sipInvestedAmount = value;
    _sipGrams = value / _goldPrice;
    final multiplier = _selectedQuickOption == 0
        ? 365
        : _selectedQuickOption == 1
            ? 52
            : 12;
    _sipAnnualInvestment = value * multiplier;
  }

    bool canProceedToPayment() {
    // Common checks
    if (_warningMessage != null) return false;
    if (inputController.text.isEmpty) return false;
    if (!_agreed) return false;

    if (isOneTime) {
      final value = double.tryParse(inputController.text) ?? 0;
      
      if (_isGramMode) {
        // Check grams range
        return value > 0.1 && value <= 50;
      } else {
        // Check rupees range
        return value > 100 && value <= 450000;
      }
    } else if (isSip) {
      final amount = double.tryParse(inputController.text) ?? 0;
      // Must have amount > 100 AND frequency selected
      return amount > 100 && _selectedQuickOption != -1;
    }

    return false;
  }

  // ──────────────────────────────────────────────────────────────
  // SIP date
  // ──────────────────────────────────────────────────────────────
  void setSelectedSipDate(DateTime date) {
    if (!isSip) return;
    final today = DateTime.now();
    final selected = DateTime(date.year, date.month, date.day);
    final current = DateTime(today.year, today.month, today.day);

    if (selected.isBefore(current)) {
      _warningMessage = "Please select today or a future date for SIP";
    } else {
      _selectedSipDate = selected;
      _warningMessage = null;
    }
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────
  // Gram / Rupee swap (One-Time only)
  // ──────────────────────────────────────────────────────────────
  void swapMode() {
    if (!isOneTime) return;
    _isGramMode = !_isGramMode;
    _selectedQuickOption = -1;
    inputController.clear();
    _clearCalculations();
    _warningMessage = null;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────
  // Validation
  // ──────────────────────────────────────────────────────────────
  void _validateAmount() {
    if (!isOneTime) return;

    if (_isGramMode) {
      final grams = double.tryParse(inputController.text) ?? 0;
      if (grams <= 0) {
        _warningMessage = null; // Empty input, no warning
      } else if (grams < 0.1) {
        _warningMessage = "Minimum gold purchase is 0.1 grams";
      } else if (grams > 50) {
        _warningMessage = "Maximum gold purchase is 50 grams";
      } else {
        _warningMessage = null;
      }
    } else {
      final rupees = double.tryParse(inputController.text) ?? 0;
      if (rupees <= 0) {
        _warningMessage = null; // Empty input, no warning
      } else if (rupees <= 100) {
        _warningMessage = "Minimum investment amount is ₹100";
      } else if (rupees > 450000) {
        _warningMessage = "Maximum investment amount is ₹4,50,000";
      } else {
        _warningMessage = null;
      }
    }
  }

  void _validateSipAmount() {
    if (!isSip) return;
    
    final amount = double.tryParse(inputController.text) ?? 0;
    
    if (amount <= 0) {
      _warningMessage = null; // Empty input, no warning
    } else if (amount <= 100) {
      _warningMessage = "Minimum SIP amount is ₹100";
    } else if (_selectedQuickOption == -1) {
      _warningMessage = "Please select Weekly or Monthly plan";
    } else {
      _warningMessage = null;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Plan adding
  // ──────────────────────────────────────────────────────────────
  void addSipPlan() {
    if (!isSip ||
        _warningMessage != null ||
        inputController.text.isEmpty ||
        _selectedQuickOption == -1) return;

    final freq = ['DAILY', 'WEEKLY', 'MONTHLY'][_selectedQuickOption];
    final amount = double.tryParse(inputController.text) ?? 0;

    _sipPlans.add({
      'name': '$freq $amount',
      'amount': _sipInvestedAmount,
      'frequency': freq,
      'startDate': _selectedSipDate,
    });

    _resetSipFields();
    notifyListeners();
  }

  void _resetSipFields() {
    inputController.clear();
    _sipInvestedAmount = _sipAnnualInvestment = _sipGrams = 0;
    _warningMessage = null;
    _selectedQuickOption = -1;
  }

  void addOneTimePlan() {
    if (!isOneTime || _warningMessage != null || inputController.text.isEmpty) return;

    _oneTimePlans.add({
      'amount': _oneTimeInvestedAmount,
      'grams': _oneTimeGrams,
      'date': DateTime.now(),
    });

    inputController.clear();
    _clearCalculations();
    _warningMessage = null;
    _selectedQuickOption = -1;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────
  // GST fetch
  // ──────────────────────────────────────────────────────────────
  Future<void> fetchGstFromBackend() async {
    try {
      final gstResponse = await _gstRepo.getAllGst();
      if (gstResponse?.success == true) {
        final newPct = (gstResponse!.data?.percentage ?? 0).toDouble();
        if (newPct != gstPercentage) {
          gstPercentage = newPct;
          print("GST Percentage Fetched: $gstPercentage%");
          _recalculateAll(); // GST changed → recalc totals
        }
      } else {
        print("Failed to fetch GST data");
      }
    } catch (e) {
      print("Error fetching GST: $e");
    }
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────
  // Recalculate everything when price or GST changes
  // ──────────────────────────────────────────────────────────────
  void _recalculateAll() {
    if (isOneTime && inputController.text.isNotEmpty) {
      final parsed = double.tryParse(inputController.text) ?? 0;
      _calcOneTime(parsed);
    } else if (isSip && inputController.text.isNotEmpty) {
      final parsed = double.tryParse(inputController.text) ?? 0;
      _calcSip(parsed);
    }
    // No need to notify here – caller already does it
  }

  // ──────────────────────────────────────────────────────────────
  // API calls (unchanged, only added dynamic GST where needed)
  // ──────────────────────────────────────────────────────────────
// Replace the SipPlan method in your InvestmentProvider class with this:

// Replace your existing SipPlan method in inverst_provider.dart with this:

Future<bool> SipPlan({
  required String userId,
  required String planName,
  required DateTime startDate,
  required double investmentAmount,
  required String frequency,
  required String paymentId,
  required String signature,
}) async {
  try {
    print("🔄 Starting SIP verification...");
    
    // Get the stored subscriptionId
    final subscriptionId = await SessionManager.getData("razorpaySubscriptionId");
    
    if (subscriptionId == null || subscriptionId.isEmpty) {
      print("❌ No subscription ID found in session");
      return false;
    }

    print("📦 Retrieved subscription ID: $subscriptionId");

    final url = Uri.parse("${AppUrl.localUrl}/user/sip/$userId/verify");

    final body = {
      "razorpaySubscriptionId": subscriptionId,
      "razorpayPaymentId": paymentId,
      "razorpaySignature": signature,
      "planName": planName,
      "startDate": startDate.toIso8601String(),
      "investmentAmount": investmentAmount,
      "frequency": frequency,
    };

    print("📤 POST → $url");
    print("📤 Body: ${jsonEncode(body)}");

    final token = await SessionManager.getAccessToken();
    if (token == null) {
      print("❌ No access token found");
      return false;
    }

    final resp = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print("📥 Response Status: ${resp.statusCode}");
    print("📥 Response Body: ${resp.body}");

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final json = jsonDecode(resp.body);
      final success = json['success'] == true;
      
      if (success) {
        print("✅ SIP verification successful");
        // Clear the stored subscription ID after successful verification
        await SessionManager.removeData("razorpaySubscriptionId");
        print("🗑️ Cleared subscription ID from session");
      } else {
        print("⚠️ Verification returned success=false");
      }
      
      return success;
    } else {
      print("❌ Verification failed with status: ${resp.statusCode}");
      return false;
    }
  } catch (e) {
    print("❌ SIP verification error: $e");
    return false;
  }
}


  Future<bool> buyOneTimeInvestment({
    required String userId,
    required String orderId,
    required String paymentId,
    required String signature,
    required double goldQty,
    required double totalAmountToPay,
    required double gstAmount,
    double? discountAmount,
    required double amountPaid,
    required double currentDayGoldPrice,
    String? redeemCode,
  }) async {
    final url = Uri.parse("${AppUrl.localUrl}/user/onetime/$userId/verify");

    final body = {
      "razorpayOrderId": orderId,
      "razorpayPaymentId": paymentId,
      "razorpaySignature": signature,
      "goldQty": goldQty,
      "totalAmountToPay": totalAmountToPay,
      "gstAmount": gstAmount,
      "discountAmount": discountAmount ?? 0.0,
      "amountPaid": amountPaid,
      "currentDayGoldPrice": currentDayGoldPrice,
      if (redeemCode != null && redeemCode.isNotEmpty) "redeemCode": redeemCode,
    };

    print("VERIFY → $url | $body");

    try {
      final token = await SessionManager.getAccessToken();
      if (token == null) return false;

      final resp = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final json = jsonDecode(resp.body);
        return json["success"] == true;
      }
    } catch (e) {
      print("One-Time verify error: $e");
    }
    return false;
  }

    // ──────────────────────────────────────────────────────────────
  // CLEAR ALL DATA (Complete Reset)
  // ──────────────────────────────────────────────────────────────
  void clearAllData() {
    // Reset agreement and selection
    _agreed = false;
    _selectedQuickOption = -1;
    _warningMessage = null;

    // Reset gold & GST values
    _goldPrice = 0.0;
    gstPercentage = 0.0;

    // Reset One-Time investment data
    _oneTimeCalculatedValue = 0.0;
    _oneTimeGrams = 0.0;
    _oneTimeInvestedAmount = 0.0;
    _oneTimePlans.clear();

    // Reset SIP data
    _sipAnnualInvestment = 0.0;
    _sipInvestedAmount = 0.0;
    _sipGrams = 0.0;
    _sipPlans.clear();
    _selectedSipDate = DateTime.now();

    // Reset AG plans
    _agPlans.clear();

    // Reset mode and input
    _mode = InvestmentMode.oneTime;
    _isGramMode = true;
    inputController.clear();

    notifyListeners();
  }

}
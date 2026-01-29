
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/data/repo/sipsubscriptionrepo/sipsubscriptionrepo.dart';
import 'package:aishwarya_gold/utils/exports/exports.dart';
import 'package:aishwarya_gold/view/home_container/investment/ag_plan_screen/ag_plan/ag_plan_section_screen.dart';
import 'package:aishwarya_gold/view/home_container/investment/conformpurchase.dart';
import 'package:aishwarya_gold/view_models/invest_provider/inverst_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:aishwarya_gold/data/models/confirm_purchase_onetime_models.dart';
import 'package:aishwarya_gold/data/models/confirm_purchase_sip_model.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/res/widgets/custom_button.dart';
import 'package:aishwarya_gold/view_models/gold_price_provider/goldprice_provider.dart';
import 'package:aishwarya_gold/view/home_container/investment/confirm_purchase_onetime.dart';
import 'package:aishwarya_gold/view/home_container/investment/confirm_purchase_sip.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final goldProvider = Provider.of<GoldProvider>(context, listen: false);
      final investProvider = Provider.of<InvestmentProvider>(context, listen: false);
      final kycProvider = Provider.of<KycStatusProvider>(context, listen: false);

      await Future.wait([
        goldProvider.fetchGoldPrice(),
        investProvider.fetchGstFromBackend(),
        kycProvider.fetchKycStatus(), // Fetch KYC status on init
      ]);

      investProvider.syncGoldPrice(context);
    });
  }

  // Get userId from session
  Future<String?> _getUserId() async {
    try {
      final userId = await SessionManager.getData("userId");
      return userId;
    } catch (e) {
      print("Error getting userId: $e");
      return null;
    }
  }

  // Show login required snackbar
  void _showLoginRequiredSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.login, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Please login to continue with your investment",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: "Login",
          textColor: Colors.white,
          onPressed: () {
            // Navigate to login screen
            // Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ),
    );
  }

  // Show KYC pending snackbar
  void _showKycPendingSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.hourglass_empty, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Your KYC verification is pending. Please wait for admin approval before investing.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
      ),
    );
  }

  // Show KYC rejected snackbar with action
  void _showKycRejectedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Your KYC verification was rejected. Please upload valid documents.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: "Upload",
          textColor: Colors.white,
          onPressed: () {
            // Navigate to KYC upload screen
            // Navigator.pushNamed(context, '/kyc-upload');
          },
        ),
      ),
    );
  }

  // Check KYC status before allowing investment
  Future<bool> _checkKycStatus(BuildContext context) async {
    final kycProvider = Provider.of<KycStatusProvider>(context, listen: false);
    
    // If KYC data is not loaded, fetch it
    if (kycProvider.kycStatus == null) {
      await kycProvider.fetchKycStatus();
    }

    final kycStatus = kycProvider.kycStatus?.data?.kycStatus?.toLowerCase() ?? 'pending';

    switch (kycStatus) {
      case 'approved':
        return true; // Allow investment
      
      case 'rejected':
        _showKycRejectedSnackbar(context);
        return false;
      
      case 'pending':
      default:
        _showKycPendingSnackbar(context);
        return false;
    }
  }

  String formatAmount(num amount) {
    if (amount >= 10000000) {
      return "${(amount / 10000000).toStringAsFixed(2)}Cr";
    } else if (amount >= 100000) {
      return "${(amount / 100000).toStringAsFixed(2)}L";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(2)}k";
    } else {
      return "₹${amount.toStringAsFixed(2)}";
    }
  }

@override
Widget build(BuildContext context) {
  return Consumer2<InvestmentProvider, KycStatusProvider>(
    builder: (context, provider, kycProvider, _) {
      provider.syncGoldPrice(context);

      // Auto-show KYC status SnackBar only once per screen visit
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   final kycStatus = kycProvider.kycStatus?.data?.kycStatus?.toLowerCase() ?? 'pending';

      //   if (kycStatus != 'approved') {
      //     // Prevent showing multiple times using a flag
      //     if (!kycProvider.hasShownKycWarning) {
      //       kycProvider.hasShownKycWarning = true; // Mark as shown

      //       String message;
      //       Color bgColor = Colors.orange.shade700;
      //       SnackBarAction? action;

      //       if (kycStatus == 'rejected') {
      //         message = "Your KYC was rejected. Please upload valid documents to invest.";
      //         bgColor = AppColors.primaryRed;
      //         action = SnackBarAction(
      //           label: "Upload Again",
      //           textColor: Colors.white,
      //           onPressed: () {
      //             // Navigator.pushNamed(context, '/kyc-upload');
      //           },
      //         );
      //       } else {
      //         message = "Your KYC is pending approval. You can invest once approved.";
      //       }

      //       ScaffoldMessenger.of(context).showSnackBar(
      //         SnackBar(
      //           content: Row(
      //             children: [
      //               Icon(
      //                 kycStatus == 'rejected' ? Icons.cancel_outlined : Icons.hourglass_empty,
      //                 color: Colors.white,
      //                 size: 20,
      //               ),
      //               const SizedBox(width: 12),
      //               Expanded(
      //                 child: Text(
      //                   message,
      //                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      //                 ),
      //               ),
      //             ],
      //           ),
      //           backgroundColor: bgColor,
      //           duration: const Duration(seconds: 8),
      //           behavior: SnackBarBehavior.floating,
      //           margin: EdgeInsets.only(bottom: 20, left: 16, right: 16),
      //           action: action,
      //         ),
      //       );
      //     }
      //   }
      // });

      
      
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: const Text(
            "Buy Gold",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          surfaceTintColor: AppColors.backgroundLight,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Consumer<GoldProvider>(
                builder: (context, goldProvider, _) {
                  if (goldProvider.isLoading) {
                    return const SizedBox(
                      width: 80,
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  if (goldProvider.errorMessage != null) {
                    return const Icon(Icons.error, color: Colors.red);
                  }
                  final price = goldProvider.currentPricePerGram;
                  return Row(
                    children: [
                      const Icon(Icons.wifi_rounded, size: 16, color: Color.fromARGB(255, 150, 13, 13)),
                      const SizedBox(width: 4),
                      Text(
                        "₹ ${price.toStringAsFixed(2)}/GM",
                        style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTabs(provider),
                    const SizedBox(height: 20),
                    if (provider.isOneTime) _buildOneTimeInput(provider),
                    if (provider.isSip) _buildSipInput(provider),

                    if (provider.warningMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                provider.warningMessage!,
                                style: TextStyle(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (provider.isSip) _buildSipCalendar(provider),
                    if (provider.isAg) const AgPlanSelectionScreen(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (provider.isOneTime || provider.isSip)
              _buildBottomPaySection(context, provider, kycProvider.kycStatus?.data?.kycStatus?.toLowerCase() ?? 'pending'),
          ],
        ),
      );
    },
  );
}
  Widget _buildTabs(InvestmentProvider provider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.grey.shade200,
      ),
      child: Row(
        children: [
          _tab("One Time", provider.isOneTime, () => provider.togglePlan(InvestmentMode.oneTime)),
          _tab("SIP", provider.isSip, () => provider.togglePlan(InvestmentMode.sip)),
          _tab("AGC Plan ", provider.isAg, () => provider.togglePlan(InvestmentMode.ag)),
        ],
      ),
    );
  }

  Widget _tab(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: active ? AppColors.primaryRed : Colors.transparent,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOneTimeInput(InvestmentProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                provider.isGramMode ? "g |" : "₹ |",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: provider.inputController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) => provider.updateValue(val, context),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: provider.isGramMode ? "Enter grams (0.1 - 50)" : "Enter amount (₹100 - ₹4,50,000)",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: provider.swapMode,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryRed.withOpacity(0.8),
                      child: const Icon(Icons.sync_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  provider.displayResult,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _quickOption(
                provider.isGramMode ? "10 gm" : "₹1000",
                provider.selectedQuickOption == 0,
                () => provider.selectQuickOption(0, context),
                showBest: true,
              ),
              _quickOption(
                provider.isGramMode ? "20 gm" : "₹2000",
                provider.selectedQuickOption == 1,
                () => provider.selectQuickOption(1, context),
              ),
              _quickOption(
                provider.isGramMode ? "50 gm" : "₹3000",
                provider.selectedQuickOption == 2,
                () => provider.selectQuickOption(2, context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSipInput(InvestmentProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("₹ |", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: provider.inputController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) => provider.updateValue(val, context),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter amount (Min ₹100)",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _quickOption("Weekly", provider.selectedQuickOption == 1, () => provider.selectQuickOption(1, context)),
              _quickOption("Monthly", provider.selectedQuickOption == 2, () => provider.selectQuickOption(2, context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSipCalendar(InvestmentProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Select Start Date", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime(2026, 9, 10),
                focusedDay: provider.selectedSipDate,
                calendarFormat: CalendarFormat.month,
                availableGestures: AvailableGestures.none,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black87),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black87),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  defaultTextStyle: const TextStyle(
                    color: Colors.black87,
                  ),
                  weekendTextStyle: const TextStyle(
                    color: Colors.black87,
                  ),
                  disabledTextStyle: TextStyle(
                    color: Colors.grey.shade400,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    if (_isFutureSipDate(day, provider)) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryRed, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  todayBuilder: (context, day, focusedDay) {
                    if (_isTodayValidForSip(provider)) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  weekendStyle: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                enabledDayPredicate: (day) {
                  if (provider.selectedQuickOption == -1) {
                    return false;
                  }
                  
                  final today = DateTime.now();
                  final normalizedToday = DateTime(today.year, today.month, today.day);
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  
                  return isSameDay(normalizedDay, normalizedToday);
                },
                selectedDayPredicate: (day) => isSameDay(day, provider.selectedSipDate),
                onDaySelected: (selectedDay, _) {
                  final today = DateTime.now();
                  final normalizedToday = DateTime(today.year, today.month, today.day);
                  final normalizedSelectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                  
                  if (isSameDay(normalizedSelectedDay, normalizedToday)) {
                    provider.setSelectedSipDate(selectedDay);
                  }
                },
              ),
            ),
          ),
          if (provider.selectedQuickOption == -1)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Please select a frequency (Weekly/Monthly) first",
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isFutureSipDate(DateTime day, InvestmentProvider provider) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDay = DateTime(day.year, day.month, day.day);
    
    if (isSameDay(normalizedDay, normalizedToday)) {
      return false;
    }
    
    if (normalizedDay.isBefore(normalizedToday)) {
      return false;
    }
    
    if (provider.selectedQuickOption == -1) {
      return false;
    }
    
    if (provider.selectedQuickOption == 1) {
      DateTime currentSipDate = normalizedToday;
      
      for (int i = 1; i <= 12; i++) {
        currentSipDate = normalizedToday.add(Duration(days: 7 * i));
        if (isSameDay(normalizedDay, currentSipDate)) {
          return true;
        }
      }
      return false;
    }
    
    if (provider.selectedQuickOption == 2) {
      for (int i = 1; i <= 12; i++) {
        int targetMonth = normalizedToday.month + i;
        int targetYear = normalizedToday.year;
        
        while (targetMonth > 12) {
          targetMonth -= 12;
          targetYear += 1;
        }
        
        final daysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
        final targetDay = normalizedToday.day > daysInTargetMonth 
            ? daysInTargetMonth 
            : normalizedToday.day;
        
        final futureSipDate = DateTime(targetYear, targetMonth, targetDay);
        
        if (isSameDay(normalizedDay, futureSipDate)) {
          return true;
        }
      }
      return false;
    }
    
    return false;
  }

  bool _isTodayValidForSip(InvestmentProvider provider) {
    return provider.selectedQuickOption != -1;
  }

Widget _buildBottomPaySection(BuildContext context, InvestmentProvider provider, String kycStatus) {
  // Always allow button to be tappable (we'll show SnackBar on tap if KYC not approved)
  bool canProceed = provider.agreed;
  bool hasValidInput = false;

  if (provider.isSip) {
    final amount = double.tryParse(provider.inputController.text) ?? 0;
    if (provider.inputController.text.isNotEmpty && amount >= 100 && provider.selectedQuickOption != -1) {
      hasValidInput = true;
    }
    canProceed = canProceed && hasValidInput;
  } else if (provider.isOneTime) {
    if (provider.inputController.text.isNotEmpty) {
      if (provider.isGramMode) {
        final grams = double.tryParse(provider.inputController.text) ?? 0;
        if (grams >= 0.1 && grams <= 50) hasValidInput = true;
      } else {
        final rupees = double.tryParse(provider.inputController.text) ?? 0;
        if (rupees >= 100 && rupees <= 450000) hasValidInput = true;
      }
    }
    canProceed = canProceed && hasValidInput;
  }

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Checkbox(
                value: provider.agreed,
                onChanged: (val) => provider.toggleAgreement(val ?? false),
                activeColor: AppColors.primaryRed,
              ),
              const Expanded(
                child: Text(
                  "I agree to lease gold to AUSPICIOUS GOLD T&C",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${formatAmount(provider.totalWithGst)} (incl. GST)",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => _showBreakupSheet(context, provider, formatAmount),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: Text(
                      "View breakup",
                      style: TextStyle(fontSize: 14, color: AppColors.primaryRed, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                child: CustomButton(
                  text: "Pay Now",
                  onPressed: canProceed
    ? () async {
        // 🔍 FIRST: Check if user is logged in
        final userId = await SessionManager.getUserId(); // or getData("userId")

        if (userId == null || userId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please login to continue."),
              backgroundColor: AppColors.primaryRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return; // ❌ stop here
        }

        // 🔍 SECOND: Check KYC
        if (kycStatus != 'approved') {
          String message;
          Color bgColor = AppColors.primaryGold;
          SnackBarAction? action;

          if (kycStatus == 'rejected') {
            message = "KYC Rejected! Upload valid documents to continue.";
            bgColor = AppColors.primaryRed;
            action = SnackBarAction(
              label: "Upload",
              textColor: Colors.white,
              onPressed: () {
                // Navigator.pushNamed(context, '/kyc-upload');
              },
            );
          } else {
            message = "Your KYC is pending approval. You can invest once approved.";
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    kycStatus == 'rejected'
                        ? Icons.cancel_outlined
                        : Icons.hourglass_empty,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(message)),
                ],
              ),
              backgroundColor: bgColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 6),
              action: action,
            ),
          );
          return;
        }

        // ✅ All good → proceed to payment
        _handlePayNowWithValidation(context, provider);
      }
    : null,


                  isEnabled: canProceed,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}




  void _handlePayNowWithValidation(BuildContext context, InvestmentProvider provider) async {
    // 1️⃣ Check if user is logged in
    final userId = await _getUserId();
    
    if (userId == null || userId.isEmpty) {
      _showLoginRequiredSnackbar(context);
      return;
    }

    // 2️⃣ Check KYC status
    final isKycApproved = await _checkKycStatus(context);
    if (!isKycApproved) {
      return; // KYC check will show appropriate snackbar
    }

    // 3️⃣ Validate investment limits before proceeding
    if (provider.isOneTime) {
      if (provider.isGramMode) {
        final grams = double.tryParse(provider.inputController.text) ?? 0;
        if (grams < 0.1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text("Minimum gold purchase is 0.1 grams")),
                ],
              ),
              backgroundColor: Colors.orange.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (grams > 50) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text("Maximum gold purchase is 50 grams")),
                ],
              ),
              backgroundColor: AppColors.primaryRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      } else {
        final rupees = double.tryParse(provider.inputController.text) ?? 0;
        if (rupees < 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text("Minimum investment amount is ₹100")),
                ],
              ),
              backgroundColor: Colors.orange.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (rupees > 450000) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text("Maximum investment amount is ₹4,50,000")),
                ],
              ),
              backgroundColor: AppColors.primaryRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }
    } else if (provider.isSip) {
      final amount = double.tryParse(provider.inputController.text) ?? 0;
      if (amount < 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text("Minimum SIP amount is ₹100")),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      
      if (provider.selectedQuickOption == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text("Please select a frequency (Weekly/Monthly)")),
              ],
            ),
            backgroundColor: Colors.blue.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    // 4️⃣ All validations passed, proceed with original payment flow
    _handlePayNow(context, provider);
  }

  void _handlePayNow(BuildContext context, InvestmentProvider provider) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 200));

    if (provider.isOneTime) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmPurchaseScreen(
            purchase: ConfirmPurchaseModel(
              goldWeight: provider.goldQty.toStringAsFixed(3),
              goldPricePerGram:
                  Provider.of<GoldProvider>(context, listen: false).currentPricePerGram,
              subtotal: provider.goldValue,
              gst: provider.gst,
              totalWithGst: provider.totalWithGst,
            ),
          ),
        ),
      );
    }
    else if (provider.isSip) {
      final planType = provider.selectedQuickOption == 0
          ? "DAILY"
          : provider.selectedQuickOption == 1
              ? "WEEKLY"
              : "MONTHLY";

      final sipRepo = SipRepository();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.coinBrown),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Creating your SIP plan...",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        final response = await sipRepo.createSipSubscription(
          planName: "SIP_$planType",
          investmentAmount: provider.investedAmount.toInt(),
          frequency: planType,
          startDate: provider.selectedSipDate.toIso8601String(),
        );

        Navigator.pop(context);

        if (response != null && response.success == true) {
          final subscriptionId = response.data?.razorpay?.subscriptionId;

          if (subscriptionId == null || subscriptionId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Failed to get subscription ID from server"),
                backgroundColor: AppColors.primaryRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          final sipPurchase = SipPurchaseModel(
            planType: planType,
            startDate: provider.selectedSipDate,
            nextDueDate: provider.selectedSipDate.add(
              Duration(
                days: provider.selectedQuickOption == 0
                    ? 1
                    : provider.selectedQuickOption == 1
                        ? 7
                        : 30,
              ),
            ),
            amount: provider.investedAmount,
            accumulated: provider.sipAnnualInvestment,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text("SIP plan created! Proceeding to mandate payment..."),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.coinBrown,
              duration: Duration(seconds: 2),
            ),
          );

          await Future.delayed(Duration(milliseconds: 500));

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SipConfirmPurchaseScreen(
                sipPurchase: sipPurchase,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response?.message ?? "Failed to create SIP plan. Please try again.",
              ),
              backgroundColor: AppColors.primaryRed,
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e, st) {
        Navigator.pop(context);
        
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error creating SIP: $e"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showBreakupSheet(BuildContext context, InvestmentProvider provider, String Function(num) formatAmount) {
    final gstPercent = provider.gstPercentage;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Amount Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 20),
                _rowItem("Total Gold Qty", "${provider.goldQty.toStringAsFixed(3)} gm"),
                _rowItem("Gold Value", formatAmount(provider.goldValue)),
                _rowItem("GST (${gstPercent.toStringAsFixed(1)}%)", "₹${provider.gst.toStringAsFixed(2)}"),
                const Divider(),
                _rowItem("To Pay", formatAmount(provider.totalWithGst), bold: true),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Okay", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _rowItem(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: bold ? FontWeight.w600 : FontWeight.w400, fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w600 : FontWeight.w400, fontSize: 14)),
        ],
      ),
    );
  }

  static Widget _quickOption(String text, bool selected, VoidCallback onTap, {bool showBest = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: selected ? AppColors.primaryRed : Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(30),
              color: selected ? const Color(0xFFFFF8E1) : Colors.white,
            ),
            child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.w600, color: selected ? AppColors.primaryRed : AppColors.black),
            ),
          ),
          if (selected && showBest)
            Positioned(
              top: -10,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primaryRed, borderRadius: BorderRadius.circular(10)),
                child: const Text("Best", style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ),
        ],
      ),
    );
  }
}
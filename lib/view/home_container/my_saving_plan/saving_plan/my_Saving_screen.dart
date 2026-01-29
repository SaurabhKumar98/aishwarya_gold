import 'dart:convert';
import 'package:aishwarya_gold/data/models/reedem_sip_models/reedem_sip_modles.dart';
import 'package:aishwarya_gold/data/models/sipsavingmodels/sip_saving_models.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view/home_container/my_saving_plan/saving_plan/download_stmt_sip.dart';
import 'package:aishwarya_gold/view/home_container/my_saving_plan/saving_plan/jewllery_redemption_screen.dart';
import 'package:aishwarya_gold/view/home_container/my_saving_plan/saving_plan/pausesipscreen.dart';
import 'package:aishwarya_gold/view_models/gold_price_provider/goldprice_provider.dart';
import 'package:aishwarya_gold/view_models/invest_provider/onetime_saving_provider.dart';
import 'package:aishwarya_gold/view_models/invest_provider/sip_saving_provider.dart';
import 'package:aishwarya_gold/view_models/pausesip_provider/pausesip_provider.dart';
import 'package:aishwarya_gold/view_models/reedemption_provider/reedemption_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class MySavingPlan extends StatefulWidget {
  final bool isOneTime;
  final bool isAgPlan;
  final Map<String, dynamic>? planData;
  final SipSaving? isSipData;
  final String? planId;

  const MySavingPlan({
    super.key,
    required this.isOneTime,
    this.planData,
    required this.isAgPlan,
    this.planId,
    this.isSipData,
  });

  @override
  State<MySavingPlan> createState() => _MySavingPlanState();
}

class _MySavingPlanState extends State<MySavingPlan> {
  late bool isOneTime;
  bool _isPaying = false;

  bool _isRedemptionAllowed(Data data) {
    final now = DateTime.now();
    final endDate = data.endDate;

    final allPaid =
        data.installments?.every((i) => i.status == Status.PAID) == true;

    bool planEnded = false;
    if (endDate != null) {
      final today = DateTime(now.year, now.month, now.day);
      final planEnd = DateTime(endDate.year, endDate.month, endDate.day);
      planEnded = planEnd.isBefore(today) || planEnd.isAtSameMomentAs(today);
    }

    return allPaid;
  }

  // Update the initState in _MySavingPlanState

  @override
  void initState() {
    super.initState();
    isOneTime = widget.isOneTime;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch live gold price
      Provider.of<GoldProvider>(context, listen: false).fetchGoldPrice();

      // 🔑 IMPORTANT: Fetch redemption status from backend when page loads
      if (widget.planId != null && widget.planId!.isNotEmpty) {
        _fetchRedemptionStatusFromBackend(widget.planId!);
      }
    });
  }

  /// Fetch the latest redemption status from backend
  Future<void> _fetchRedemptionStatusFromBackend(String planId) async {
    try {
      final redemptionProvider = context.read<RedemptionProvider>();

      debugPrint('📡 Fetching redemption status for plan: $planId');

      // This fetches from backend and updates the cache
      await redemptionProvider.fetchRedemptionStatusForPlan(planId);

      debugPrint('✅ Redemption status fetched successfully');
    } catch (e) {
      debugPrint('⚠️ Error fetching redemption status: $e');
    }
  }

  static const Color primaryRed = Color(0xFF960D0D);

  String _getPauseEndDateFormatted(Data data) {
    if (data.pauseEndDate == null) return "N/A";
    try {
      if (data.pauseEndDate is DateTime) {
        return DateFormat('dd-MMM-yyyy').format(data.pauseEndDate as DateTime);
      }
      if (data.pauseEndDate is String) {
        final parsed = DateTime.tryParse(data.pauseEndDate as String);
        if (parsed != null) return DateFormat('dd-MMM-yyyy').format(parsed);
      }
      return "N/A";
    } catch (e) {
      return "N/A";
    }
  }

  // ── DEMO: Pay Installment API Call ─────────────────────
  Future<void> _payDemoInstallment(String planId) async {
    if (_isPaying) return;
    setState(() => _isPaying = true);

    try {
      final url = Uri.parse(
        'https://api.aishwaryagold.shop/user/demo/sip/$planId/pay-installment',
      );
      final response = await http
          .post(url)
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Refresh plan data
        await Provider.of<SipSavingProvider>(
          context,
          listen: false,
        ).fetchPlanDetailsById(planId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Installment paid! Progress updated."),
            backgroundColor: AppColors.coinBrown,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Network error. Try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: AppColors.backgroundLight,
        title: const Text(
          "My Savings Plan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
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
                    const Icon(
                      Icons.wifi_rounded,
                      size: 16,
                      color: Color.fromARGB(255, 150, 13, 13),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "₹ ${price.toStringAsFixed(2)}/GM",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  if (isOneTime)
                    _oneTimeContent(context)
                  else
                    _sipContent(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────── ONE-TIME PLAN (unchanged) ─────────────────────
  Widget _oneTimeContent(BuildContext context) {
    final oneTimeData = Provider.of<OnetimeSavingProvider>(
      context,
    ).currentPlanDetails?.data;
    if (oneTimeData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final investedAmount = oneTimeData.totalAmountToPay ?? 0;
    final goldQty = oneTimeData.goldQty ?? 0;
    final planStatus = oneTimeData.status ?? 'Active';

    final profitLoss = oneTimeData.profitLoss;
    final currentValue = profitLoss?.currentValue ?? 0;
    final profit = profitLoss?.profitLoss ?? 0;
    final percentage = profitLoss?.profitLossPercentage ?? 0;
    final isProfitable = profitLoss?.isProfitable ?? false;
    final currentGoldPrice = profitLoss?.currentGoldPrice ?? 0;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryGold.withOpacity(0.1), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColors.primaryGold.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.primaryGold,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "One Time Plan Summary",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // INVESTED + GOLD PURCHASED
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoTile(
                        icon: Icons.currency_rupee,
                        title: "Invested Amount",
                        value: "₹${investedAmount.toStringAsFixed(2)}",
                        color: AppColors.primaryGold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoTile(
                        icon: Icons.brightness_7,
                        title: "Gold Purchased",
                        value: "${goldQty.toStringAsFixed(3)} g",
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // CURRENT VALUE + PROFIT / LOSS
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryTile(
                        icon: Icons.account_balance,
                        title: "Current Value",
                        value: "₹${currentValue.toStringAsFixed(0)}",
                        color: AppColors.primaryGold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryTile(
                        icon: isProfitable
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        title: "Profit / Loss",
                        value:
                            "${isProfitable ? '+' : '-'}₹${profit.abs().toStringAsFixed(0)} ($percentage%)",
                        color: isProfitable
                            ? AppColors.coinBrown
                            : AppColors.primaryRed,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // CURRENT GOLD PRICE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Current Gold Price",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "₹${currentGoldPrice.toStringAsFixed(2)}/g",
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // STATUS CHIP
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: planStatus == 'Completed'
                        ? Colors.green.withValues(alpha: .1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: planStatus == 'Completed'
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: planStatus == 'Completed'
                              ? Colors.green
                              : AppColors.accentRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        planStatus,
                        style: TextStyle(
                          color: planStatus == 'Completed'
                              ? Colors.green
                              : AppColors.primaryRed,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // REDEEM BUTTON (unchanged)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secRed, AppColors.primaryRed.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final planId = oneTimeData.id ?? '';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JewelleryRedemptionScreen(
                      planId: planId,
                      planType: "OneTimeInvestment",
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/cropped-Aishwaryalogo.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Redeem for Gold",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Visit an Aishwarya Gold Palace store",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // Extracted widgets for clean code

  Widget _buildApprovedCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.coinBrown, AppColors.coinBrown],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 36),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Approved - Visit Store",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Your redemption is approved",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Icon(Icons.info_outline, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingCardWithCancel({
    required BuildContext context,
    required String planId,
    required RedemptionProvider redemptionProvider,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.coinBrown, AppColors.coinBrown],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.hourglass_empty,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Request Pending",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Awaiting store approval",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            // CANCEL BUTTON
            GestureDetector(
              onTap: redemptionProvider.isLoading
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text("Cancel Redemption?"),
                          content: const Text(
                            "Are you sure you want to cancel this request?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("No"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryRed,
                              ),
                              child: const Text("Yes, Cancel"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final success = await redemptionProvider
                            .cancelRedemptionForCurrentPlan();

                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Redemption request cancelled"),
                              backgroundColor: AppColors.primaryRed,
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            ),
                          );
                          // Refresh OneTime plan details
                          context.read<OnetimeSavingProvider>().fetchPlanById(
                            planId,
                          );
                        }
                      }
                    },
              child: redemptionProvider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedeemCard(BuildContext context, String planId) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secRed, AppColors.primaryRed.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => JewelleryRedemptionScreen(
                  planId: planId,
                  planType: "OneTimeInvestment",
                ),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Redeem for Gold",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Visit an Aishwarya Gold Palace store",
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────── SIP PLAN (WITH ADD BUTTON) ─────────────────────
  Widget _sipContent(BuildContext context) {
    return Consumer<SipSavingProvider>(
      builder: (context, sipProvider, _) {
        if (sipProvider.isLoading)
          return const Center(child: CircularProgressIndicator());
        final planDetails = sipProvider.currentPlanDetails;
        if (planDetails == null || planDetails.data == null) {
          return const Center(child: Text("No plan details available"));
        }
        final data = planDetails.data!;
        final profitLoss = data.profitLoss;

        final totalGold = data.totalGoldAccumulated ?? 0.0;
        final totalInvested = data.totalInvested ?? 0;
        final currentValue = profitLoss?.currentValue ?? 0;
        final profit = profitLoss?.profitLoss ?? 0;
        final profitPercentage = profitLoss?.profitLossPercentage ?? 0;
        final isProfitable = profitLoss?.isProfitable ?? false;
        final currentGoldPrice = profitLoss?.currentGoldPrice ?? 0;

        final frequency = (data.frequency ?? 'monthly').toLowerCase();
        final installments = data.installments ?? [];

        int paidInstallments = installments
            .where((i) => i.status == Status.PAID)
            .length;
        int totalInstallments = installments.isNotEmpty
            ? installments.length
            : 52; // fallback
        String progressLabel = frequency == 'weekly' ? 'weeks' : 'months';

        final monthlyAmount =
            "₹${data.investmentAmount?.toStringAsFixed(0) ?? '0'}";
        final nextPayment = data.nextExecutionDate != null
            ? DateFormat('dd-MMM-yyyy').format(data.nextExecutionDate!)
            : "Completed";
        final planStatus = data.status ?? 'Active';
        final isPlanActive = planStatus.toLowerCase() == 'active';
        final isPaused = data.status?.toLowerCase() == 'paused';

        final canRedeem = _isRedemptionAllowed(data);
        final allPaid = installments.every((i) => i.status == Status.PAID);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            _surfaceCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.savings,
                          color: AppColors.primaryGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "SIP Plan Summary",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryTile(
                          icon: Icons.brightness_7,
                          title: "Total Gold",
                          value: "${totalGold.toStringAsFixed(3)} g",
                          color: AppColors.primaryGold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryTile(
                          icon: Icons.account_balance_wallet,
                          title: "Current Value",
                          value: "₹${currentValue.toStringAsFixed(0)}",
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryTile(
                          icon: Icons.trending_up,
                          title: "Invested",
                          value: "₹${totalInvested.toStringAsFixed(0)}",
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryTile(
                          icon: isProfitable
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          title: "Profit/Loss",
                          value:
                              "${isProfitable ? '+' : '-'}₹${profit.abs().toStringAsFixed(0)} ($profitPercentage%)",
                          color: isProfitable ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        "Progress",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: totalInstallments > 0
                                ? (paidInstallments / totalInstallments).clamp(
                                    0.0,
                                    1.0,
                                  )
                                : 0,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isProfitable
                                  ? Colors.green
                                  : AppColors.primaryGold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "$paidInstallments of $totalInstallments $progressLabel",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DownloadStmtSip(planId: data.id ?? ''),
                          ),
                        ),
                        child: const Text(
                          "Download Statement",
                          style: TextStyle(
                            color: primaryRed,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (isPlanActive)
                        Consumer<PauseSipProvider>(
                          builder: (context, pauseProvider, _) =>
                              GestureDetector(
                                onTap: pauseProvider.isLoading
                                    ? null
                                    : () async {
                                        final refresh =
                                            await Navigator.push<bool>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => PauseSipScreen(
                                                  planId: data.id ?? '',
                                                ),
                                              ),
                                            );
                                        if (refresh == true && mounted) {
                                          await sipProvider
                                              .fetchPlanDetailsById(
                                                data.id ?? '',
                                              );
                                        }
                                      },
                                child: pauseProvider.isLoading
                                    ? const SizedBox(
                                        width: 80,
                                        height: 20,
                                        child: Center(
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        "Pause Plan",
                                        style: TextStyle(
                                          color: AppColors.primaryRed,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                              ),
                        )
                      else if (isPaused)
                        const Text(
                          "Paused",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // DEMO: Add Installment Button
            // _surfaceCard(
            //   padding: const EdgeInsets.all(12),
            //   child: ElevatedButton.icon(
            //     onPressed: _isPaying || !isPlanActive
            //         ? null
            //         : () => _payDemoInstallment(data.id ?? ''),
            //     icon: _isPaying
            //         ? const SizedBox(
            //             width: 16,
            //             height: 16,
            //             child: CircularProgressIndicator(
            //               strokeWidth: 2,
            //               color: Colors.white,
            //             ),
            //           )
            //         : const Icon(Icons.add_circle, size: 20),
            //     label: Text(_isPaying ? "Paying..." : "Add Installment (Demo)"),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primaryRed,
            //       foregroundColor: Colors.white,
            //       padding: const EdgeInsets.symmetric(vertical: 14),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //   ),
            // ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    title: data.frequency?.toUpperCase() ?? "N/A",
                    value: monthlyAmount,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoCard(
                    title: isPaused ? "RESUMES ON" : "NEXT PAYMENT",
                    value: isPaused
                        ? _getPauseEndDateFormatted(data)
                        : nextPayment,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _surfaceCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Current Gold Price",
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "₹${currentGoldPrice.toStringAsFixed(2)}/g",
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Redeem Button
            if (canRedeem)
              _surfaceCard(
                padding: const EdgeInsets.all(16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JewelleryRedemptionScreen(
                          planId: data.id ?? '',
                          planType: "SIPPlan",
                        ),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.shop,
                            color: AppColors.primaryGold,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Redeem for Gold",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Visit an Aishwarya Gold Palace store",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              _surfaceCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.lock, color: Colors.grey, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Redemption Locked",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            allPaid
                                ? "Plan end date not reached yet"
                                : "Complete all installments to redeem",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            if (canRedeem) const SizedBox(height: 16),
            if (canRedeem)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGold.withOpacity(0.1),
                      AppColors.primaryGold.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryGold.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.celebration,
                      color: AppColors.primaryGold,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Congratulations!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your SIP is complete! Redeem your gold at any Aishwarya Gold Palace store.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  // ───────────────────── HELPER WIDGETS (unchanged) ─────────────────────
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 10, color: color),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _surfaceCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoCard({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 0.3,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

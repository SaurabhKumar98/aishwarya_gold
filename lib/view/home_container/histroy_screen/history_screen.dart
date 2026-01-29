import 'dart:core';

import 'package:aishwarya_gold/data/models/history_models/history_models.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/utils/exports/exports.dart';
import 'package:aishwarya_gold/view/home_container/histroy_screen/ag_plan_transaction.dart';
import 'package:aishwarya_gold/view/home_container/histroy_screen/onetime_trasaction_screen.dart';
import 'package:aishwarya_gold/view/home_container/histroy_screen/sip_trasaction_screen.dart';
import 'package:aishwarya_gold/view_models/downloadStatementprovider/downloadStatementProvider.dart';
import 'package:aishwarya_gold/view_models/history_screen_provider/history_provider.dart';
import 'package:aishwarya_gold/view_models/invest_provider/onetime_saving_provider.dart';
import 'package:aishwarya_gold/view_models/invest_provider/sip_saving_provider.dart'; // Ensure this is imported
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  final String userId;

  const HistoryScreen({super.key, required this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().fetchUserPlans(widget.userId);
    });
  }

  // Centralized error SnackBar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "History",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        surfaceTintColor: AppColors.backgroundLight,
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          // Loading state
          if (historyProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.coinBrown),
                  const SizedBox(height: 16),
                  Text(
                    "Loading your transactions...",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          String _friendlyHistoryError(String? msg) {
  if (msg == null) return "Unable to load your history.";

  final text = msg.toLowerCase();

  if (text.contains("unauthorized") ||
      text.contains("token") ||
      text.contains("expired") ||
      text.contains("forbidden")) {
    return "Your session has expired. Please login again.";
  }

  if (text.contains("not found")) {
    return "No history available right now.";
  }

  if (text.contains("network") || text.contains("connection")) {
    return "Please check your internet connection and try again.";
  }

  return "Unable to load your history. Please try again.";
}


          // Error state
         if (historyProvider.errorMessage != null) {

  // 🔥 Show friendly SnackBar once
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Unable to load history. Please login again."),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  });

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 70,
            color: Colors.red.withOpacity(0.6),
          ),
          const SizedBox(height: 24),

          const Text(
            "Something went wrong",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),

          const SizedBox(height: 12),

          // ⭐ USER FRIENDLY ERROR MESSAGE
          Text(
            _friendlyHistoryError(historyProvider.errorMessage),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),

          const SizedBox(height: 24),

          // 🔄 RETRY BUTTON
          ElevatedButton.icon(
            onPressed: () => historyProvider.fetchUserPlans(widget.userId),
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coinBrown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    ),
  );
}


          // Combine all history
          final allHistory = [
            ...historyProvider.oneTimeHistory.map((p) => {"type": "oneTime", "data": p}),
            ...historyProvider.sipHistory.map((p) => {"type": "sip", "data": p}),
            ...historyProvider.agPlanHistory.map((p) => {"type": "agPlan", "data": p}),
          ];

          return RefreshIndicator(
            onRefresh: () => historyProvider.refreshData(widget.userId),
            color: AppColors.coinBrown,
            child: Column(
              children: [
                _buildHeaderStats(allHistory, historyProvider),
                Expanded(
                  child: allHistory.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: allHistory.length,
                          itemBuilder: (context, index) {
                            final item = allHistory[index];
                            final type = item["type"] as String;

                            if (type == "oneTime") {
                              final model = item["data"] as OneTimeInvestment;
                              return _buildOneTimeCard(model, df, context);
                            } else if (type == "sip") {
                              final model = item["data"] as SipPlan;
                              return _buildSipCard(model, df, context);
                            } else if (type == "agPlan") {
                              final model = item["data"] as AgPlan;
                              return _buildAgPlanCard(model, df, context);
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderStats(List allHistory, HistoryProvider provider) {
    return Container(); // Placeholder for future stats
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            const Text(
              "No History Yet",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF2D3748)),
            ),
            const SizedBox(height: 12),
            Text(
              "Start your gold investment journey!\nYour purchases will appear here once you\nmake your first transaction.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // ONE-TIME CARD - Direct async navigation (no loading dialog)
  Widget _buildOneTimeCard(OneTimeInvestment model, DateFormat df, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            if (model.id == null) {
              _showErrorSnackBar(context, "Invalid transaction ID");
              return;
            }

            try {
              final onetimeProvider = context.read<OnetimeSavingProvider>();
              final planDetails = await onetimeProvider.fetchPlanById(model.id!);

              if (!context.mounted) return;

              if (planDetails?.data != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OneTimeTransactionDetailScreen(planData: planDetails!.data!),
                  ),
                );
              } else {
                _showErrorSnackBar(context, "Failed to load transaction details");
              }
            } catch (e) {
              if (context.mounted) {
                _showErrorSnackBar(context, "Error: ${e.toString()}");
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                  child: Image.asset('assets/images/coin_no_bg.png'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.coinBrown.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "ONE-TIME",
                          style: TextStyle(color: AppColors.coinBrown, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Gold Purchase",
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF2D3748)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${model.goldQty ?? 0} grams",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            model.createdAt != null ? df.format(model.createdAt!) : "N/A",
                            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: model.status == 'COMPLETED'
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              model.status ?? 'N/A',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: model.status == 'COMPLETED' ? AppColors.coinBrown : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SIP CARD - Direct async navigation (no loading dialog)
  Widget _buildSipCard(SipPlan model, DateFormat df, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            if (model.id == null) {
              _showErrorSnackBar(context, "Invalid SIP plan ID");
              return;
            }

            try {
              final sipProvider = context.read<SipSavingProvider>();
              final sipDetails = await sipProvider.fetchPlanDetailsById(model.id!);

              if (!context.mounted) return;

              if (sipDetails?.data != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SipTransactionScreen(planData: sipDetails!.data!),
                  ),
                );
              } else {
                _showErrorSnackBar(context, "Failed to load SIP transaction details");
              }
            } catch (e) {
              if (context.mounted) {
                _showErrorSnackBar(context, "Error: ${e.toString()}");
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                  child: Image.asset('assets/images/coin_no_bg.png'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.coinBrown.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "SIP",
                          style: TextStyle(color: AppColors.coinBrown, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        model.planName ?? "SIP Plan",
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF2D3748)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Started ${model.startDate != null ? df.format(model.startDate!) : 'N/A'}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            model.frequency ?? "N/A",
                            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: model.status == 'ACTIVE'
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              model.status ?? 'N/A',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: model.status == 'ACTIVE' ? AppColors.coinBrown : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // AG PLAN CARD - Direct navigation (already no loading)
// AG PLAN CARD - Fixed overflow issue
Widget _buildAgPlanCard(AgPlan model, DateFormat df, BuildContext context) {
  final planType = model.planId?.type ?? 'Unknown';
  final title = planType == 'weekly' ? 'AG Weekly Plan' : 'AG Monthly Plan';
  final id = model.id ?? '';

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (id.isEmpty) {
            _showErrorSnackBar(context, "Invalid plan ID");
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => DownloadStatementProvider()..fetchDownloadStatement(id),
                child: AgPlanTransactionScreen(planId: id),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                child: Image.asset('assets/images/coin_no_bg.png'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.coinBrown.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        planType.toUpperCase(),
                        style: const TextStyle(color: AppColors.coinBrown, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF2D3748)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Start: ${model.startDate != null ? df.format(model.startDate!) : 'N/A'}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    // FIXED: Made this row flexible to prevent overflow
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Wrap the date text in Flexible to allow it to shrink if needed
                        Flexible(
                          child: Text(
                            model.endDate != null ? "End: ${df.format(model.endDate!)}" : "No end date",
                            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                            overflow: TextOverflow.ellipsis, // Add ellipsis if still too long
                          ),
                        ),
                        const SizedBox(width: 8), // Add spacing between date and status
                        // Status badge stays at fixed width
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: model.status == 'active'
                                ? Colors.red.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            (model.status ?? 'N/A').toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: model.status == 'active' ? AppColors.coinBrown : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    ),
  );
}
}
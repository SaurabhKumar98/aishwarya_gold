import 'package:aishwarya_gold/data/models/sipsavingmodels/sip_saving_models.dart';
import 'package:aishwarya_gold/data/models/onetimesavingmodels/onetime_saving_models.dart';
import 'package:aishwarya_gold/data/models/onetimesavingmodels/onetimebyidmodels.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/gold_certificate/gold_certificate_screen.dart';
import 'package:aishwarya_gold/view_models/invest_provider/sip_saving_provider.dart';
import 'package:aishwarya_gold/view_models/invest_provider/onetime_saving_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PlanListScreen extends StatefulWidget {
  final String planType; // "SIP" or "One Time"

  const PlanListScreen({Key? key, required this.planType}) : super(key: key);

  @override
  State<PlanListScreen> createState() => _PlanListScreenState();
}

class _PlanListScreenState extends State<PlanListScreen> {


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.planType.toLowerCase() == "sip") {
        Provider.of<SipSavingProvider>(context, listen: false).fetchSipPlans();
      } else {
        Provider.of<OnetimeSavingProvider>(context, listen: false).fetchOnetimePlans();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final isSip = widget.planType.toLowerCase() == 'sip';
    final sipProvider = Provider.of<SipSavingProvider>(context);
    final oneTimeProvider = Provider.of<OnetimeSavingProvider>(context);

    final isLoading = isSip ? sipProvider.isLoading : oneTimeProvider.isLoading;
    final plans = isSip ? sipProvider.sipPlans : oneTimeProvider.onetime;

    return Scaffold(
      appBar: AppBar(title: Text("${widget.planType} Plans")),
      body: isLoading && plans.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: isSip
                  ? sipProvider.fetchSipPlans
                  : oneTimeProvider.fetchOnetimePlans,
              child: plans.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: plans.length,
                      itemBuilder: (ctx, i) {
                        return isSip
                            ? _buildSipPlanCard(context, plans[i] as SipSaving)
                            : _buildOneTimePlanCard(context, plans[i] as OneTimeSav);
                      },
                    ),
            ),
    );
  }

  // ----------------- Empty State Widget -----------------
  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  "No plans found",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Pull down to refresh",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------- SIP Plan Card -----------------
  Widget _buildSipPlanCard(BuildContext context, SipSaving plan) {
    final dateFmt = DateFormat('dd MMM yyyy');
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return GestureDetector(
      onTap: () async {
        final planId = plan.id;
        if (planId == null) {
          _showSnackBar(context, "Invalid Plan ID");
          return;
        }

        _showLoadingDialog(context);

        final provider = Provider.of<SipSavingProvider>(context, listen: false);
        final detail = await provider.fetchPlanDetailsById(planId);
        if (context.mounted) Navigator.of(context).pop();

        if (detail == null || detail.data == null) {
          if (context.mounted) {
            _showSnackBar(context, provider.error ?? "Failed to load plan");
          }
          return;
        }

        final data = detail.data!;
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GoldCertificateScreen(
                customerName: data.username ?? data.userId?.name ?? 'Customer',
                investedAmount: (data.totalInvested ?? 0).toDouble(),
                goldGrams: data.totalGoldAccumulated ?? 0.0,
                purchaseDate: data.startDate ?? DateTime.now(),
                customPlanId: data.customPlanId ?? '',
              ),
            ),
          );
        }
      },
      child: _buildCommonCard(
        title: plan.planName ?? "SIP Investment",
        status: plan.status ?? '',
        amountLabel: "Total Invested",
        amountValue: currency.format(plan.totalInvested ?? 0),
        goldLabel: "Gold Accumulated",
        goldValue: "${(plan.totalGoldAccumulated ?? 0).toStringAsFixed(3)} g",
        planId: plan.id ?? 'N/A',
      ),
    );
  }

  // ----------------- One-Time Plan Card -----------------
  Widget _buildOneTimePlanCard(BuildContext context, OneTimeSav plan) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return GestureDetector(
      onTap: () async {
        final planId = plan.id;
        if (planId == null) {
          _showSnackBar(context, "Invalid Plan ID");
          return;
        }

        _showLoadingDialog(context);

        final provider = Provider.of<OnetimeSavingProvider>(context, listen: false);
        final detail = await provider.fetchPlanById(planId);
        if (context.mounted) Navigator.of(context).pop();

        if (detail == null || detail.data == null) {
          if (context.mounted) {
            _showSnackBar(context, provider.error ?? "Failed to load plan");
          }
          return;
        }

        final data = detail.data!;
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GoldCertificateScreen(
                customerName: data.username ?? data.userId?.name ?? 'Customer',
                investedAmount: (data.totalAmountToPay ?? 0).toDouble(),
                goldGrams: (data.goldQty ?? 0).toDouble(),
                purchaseDate: data.createdAt ?? DateTime.now(),
                customPlanId: data.customInvestmentId ?? '',
              ),
            ),
          );
        }
      },
      child: _buildCommonCard(
        title: "One-Time Purchase",
        status: plan.status ?? '',
        amountLabel: "Amount Paid",
        amountValue: currency.format(plan.amountPaid ?? 0),
        goldLabel: "Gold Quantity",
        goldValue: "${(plan.goldQty ?? 0).toStringAsFixed(3)} g",
        planId: plan.id ?? 'N/A',
      ),
    );
  }

  // ----------------- Common Card Design -----------------
  Widget _buildCommonCard({
    required String title,
    required String status,
    required String amountLabel,
    required String amountValue,
    required String goldLabel,
    required String goldValue,
    required String planId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (status.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getStatusColor(status), width: 1),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "$amountLabel: $amountValue",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            "$goldLabel: $goldValue",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "Plan ID: $planId",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // ----------------- Helper Methods -----------------
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
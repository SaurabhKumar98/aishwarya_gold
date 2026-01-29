import 'package:aishwarya_gold/data/models/downloadstatemetagmodels/downloadstatementmodels.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view_models/downloadStatementprovider/downloadStatementProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AgPlanTransactionScreen extends StatelessWidget {
  final String planId;

  const AgPlanTransactionScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    final amountFormat = NumberFormat('#,##,##0', 'en_IN');

  String getDurationText(PlanId? plan) {
  if (plan == null) return "N/A";

  final duration = plan.durationMonths ?? 0;
  final type = (plan.type ?? "").toLowerCase();

  if (type == "weekly") {
    return "$duration Weeks";
  } else if (type == "monthly") {
    return "$duration Months";
  } else if (type == "daily") {
    return "$duration Days";
  } else {
    return "$duration"; // fallback
  }
}


    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Transaction Details",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<DownloadStatementProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return _buildShimmerList();
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }
          Transaction? _findMatchingTransaction(Installment inst, List<Transaction>? transactions) {
  if (transactions == null || inst.paidDate == null) return null;

  return transactions.firstWhere(
    (tx) => tx.date?.toIso8601String() == inst.paidDate?.toIso8601String(),
    orElse: () => Transaction(),
  );
}


          final data = provider.statementData?.data;
          if (data == null) {
            return const Center(child: Text("No transaction data available."));
          }

          final plan = data.planId;
          final installments = data.installments ?? [];
          final paidInstallments = installments
              .where((i) => i.status == Status.PAID)
              .toList();
          final allPaid = paidInstallments.length == installments.length && installments.isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                // === Hero Card ===
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.check_circle,
                                color: AppColors.primaryGold, size: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            allPaid ? "Plan Completed" : "Plan Active",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "₹${amountFormat.format(plan?.amount ?? 0)}",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Per Installment",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          plan?.name ?? "AG Plan",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // === Plan Details ===
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _enhancedDetailRow("Plan Type", (plan?.type ?? "N/A").toUpperCase()),
                      _enhancedDetailRow("Duration", getDurationText(plan)),
                      _enhancedDetailRow("Total Investment", "₹${amountFormat.format(plan?.totalInvestment ?? 0)}"),
                      _enhancedDetailRow("Maturity Amount", "₹${amountFormat.format(plan?.maturityAmount ?? 0)}", isLast: true),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // === Installments Section ===
                if (allPaid)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.yellow.shade700),
                        const SizedBox(width: 12),
                        Text(
                          "All Installments Paid",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow.shade800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          "Paid Installments",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${paidInstallments.length}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.coinBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // === Paid Installments List (Same UI as SIP) ===
                if (paidInstallments.isNotEmpty)
                  ...paidInstallments.map((inst) {
  final tx = _findMatchingTransaction(inst, data.transactions);
  final paymentId = tx?.razorpayPaymentId ?? "N/A";


                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Installment #${inst.installmentNumber}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.coinBrown,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "PAID",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Amount",
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                              ),
                              Text(
                                "₹${amountFormat.format(inst.baseAmount ?? 0)}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Paid On",
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                              ),
                              Text(
                                inst.paidDate != null ? df.format(inst.paidDate!) : "-",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                "Payment ID:",
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  paymentId,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (paymentId != "N/A")
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: paymentId));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text("Payment ID copied!"),
                                        backgroundColor: AppColors.coinBrown,
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.all(16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList()
               
               
                else if (!allPaid)
                  // Empty state
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Payments Yet",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Installments will appear here once paid.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // Reusable Detail Row
  Widget _enhancedDetailRow(String title, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Shimmer loader
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
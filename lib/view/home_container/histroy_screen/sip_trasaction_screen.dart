import 'package:aishwarya_gold/data/models/reedem_sip_models/reedem_sip_modles.dart';
import 'package:flutter/material.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class SipTransactionScreen extends StatelessWidget {
  final Data planData;

  const SipTransactionScreen({super.key, required this.planData});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    final amountFormat = NumberFormat('#,##,##0.00', 'en_IN');
    final bool isCompleted = planData.status?.toUpperCase() == "COMPLETED";

    final paidInstallments = planData.installments
            ?.where((inst) => inst.status == Status.PAID)
            .toList() ??
        [];

    final transactions = planData.transactions ?? [];

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
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            // Hero Card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
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
                          color: isCompleted ? Colors.green.shade50 : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isCompleted ? Icons.check_circle : Icons.autorenew,
                          color: isCompleted ? Colors.green.shade600 : Colors.amber.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCompleted ? "SIP Completed" : "SIP Active",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? Colors.green.shade700 : Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "₹${amountFormat.format(planData.totalInvested ?? 0)}",
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: AppColors.primaryGold),
                  ),
                  const Text("Total Invested", style: TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.primaryGold.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(planData.planName ?? "SIP Plan", style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            // Plan Details
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  _enhancedDetailRow("Installment Amount", "₹${amountFormat.format(planData.investmentAmount ?? 0)}", isFirst: true),
                  _enhancedDetailRow("Start Date", planData.startDate != null ? df.format(planData.startDate!) : "-"),
                  _enhancedDetailRow(isCompleted ? "Completed On" : "Next Due Date", isCompleted ? (planData.endDate != null ? df.format(planData.endDate!) : "-") : (planData.nextExecutionDate != null ? df.format(planData.nextExecutionDate!) : "-")),
                  _enhancedDetailRow("Status", planData.status?.toUpperCase() ?? "N/A", badgeColor: isCompleted ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1), textColor: isCompleted ? Colors.green.shade700 : Colors.amber.shade700),
                  _enhancedDetailRow("Total Gold", "${planData.totalGoldAccumulated?.toStringAsFixed(4) ?? '0'} g", isLast: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Paid Installments
            if (paidInstallments.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text("Paid Installments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey[800])),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text("${paidInstallments.length}", style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...paidInstallments.asMap().entries.map((entry) {
                final index = entry.key;
                final installment = entry.value;

                // Get transaction by index (100% reliable)
                final transaction = transactions.length > index ? transactions[index] : null;
                final String paymentId = transaction?.razorpayPaymentId ?? "N/A";

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Installment #${installment.installmentNumber?.toInt()}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Text("PAID", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("Amount", style: TextStyle(color: Colors.grey[600])),
                        Text("₹${amountFormat.format(installment.baseAmount ?? 0)}", style: const TextStyle(fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 4),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("Paid On", style: TextStyle(color: Colors.grey[600])),
                        Text(installment.paidAt != null ? df.format(installment.paidAt!) : "-", style: const TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text("Payment ID:", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              paymentId,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: paymentId == "N/A" ? Colors.grey : Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (paymentId != "N/A")
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: paymentId));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment ID copied!"), duration: Duration(seconds: 1)));
                              },
                              child: Icon(Icons.copy, size: 16, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ] else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
                child: Column(children: [
                  Icon(Icons.hourglass_empty, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text("No Payments Yet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text("Payments will appear here once processed.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _enhancedDetailRow(String title, String value, {bool isFirst = false, bool isLast = false, Color? badgeColor, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: isFirst ? const Radius.circular(20) : Radius.zero, bottom: isLast ? const Radius.circular(20) : Radius.zero),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
          badgeColor != null
              ? Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(8)), child: Text(value, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)))
              : Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
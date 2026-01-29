import 'dart:io';
import 'package:aishwarya_gold/data/models/reedem_sip_models/reedem_sip_modles.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view_models/invest_provider/sip_saving_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';

class DownloadStmtSip extends StatefulWidget {
  final String planId;
  const DownloadStmtSip({super.key, required this.planId});

  @override
  State<DownloadStmtSip> createState() => _DownloadStmtSipState();
}

class _DownloadStmtSipState extends State<DownloadStmtSip> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SipSavingProvider>(context, listen: false)
          .fetchPlanDetailsById(widget.planId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: const Text("Download Statement",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Consumer<SipSavingProvider>(
          builder: (context, sipProvider, _) {
            if (sipProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final planDetails = sipProvider.currentPlanDetails;
            if (planDetails == null || planDetails.data == null) {
              return const Center(child: Text("No plan details available"));
            }

            final data = planDetails.data!;
            final paidInstallments =
                data.installments?.where((i) => i.status == Status.PAID).toList() ??
                    [];
            final transactions = data.transactions ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(data),
                  const SizedBox(height: 16),
                  _buildFinancialSummary(data),
                  const SizedBox(height: 16),
                  _buildPlanDetails(data),
                  const SizedBox(height: 16),
                  _buildInvestmentHistory(data, paidInstallments.length),
                  const SizedBox(height: 24),
                  _buildDownloadButton(data, paidInstallments, transactions),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ------------------------- UI PART UNCHANGED -------------------------

  Widget _buildHeaderCard(Data data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [AppColors.primaryGold, AppColors.primaryGold.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryGold.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.description, color: Colors.white, size: 24)),
            const SizedBox(width: 12),
            const Text("SIP Plan Statement",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          Text("Plan ID: ${data.customPlanId ?? data.id ?? 'N/A'}",
              style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20)),
            child: Text(data.status?.toUpperCase() ?? 'ACTIVE',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(Data data) {
    final profitLoss = data.profitLoss;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Financial Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSummaryRow("Total Gold Accumulated",
              "${(data.totalGoldAccumulated ?? 0).toStringAsFixed(4)} g", AppColors.primaryGold),
          const Divider(height: 24),
          _buildSummaryRow("Total Invested",
              "₹${(data.totalInvested ?? 0).toStringAsFixed(2)}", AppColors.coinBrown),
          const Divider(height: 24),
          _buildSummaryRow("Current Value",
              "₹${(profitLoss?.currentValue ?? 0).toStringAsFixed(2)}", AppColors.primaryGold),
          const Divider(height: 24),
          _buildSummaryRow(
            "Profit/Loss",
            "${(profitLoss?.isProfitable == true ? '+' : '-')}"
            "${profitLoss?.profitLoss?.abs().toStringAsFixed(2) ?? '0'} "
            "(${profitLoss?.profitLossPercentage?.toStringAsFixed(1) ?? '0'}%)",
            profitLoss?.isProfitable == true ? Colors.green.shade700 : AppColors.primaryRed,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
      Text(value,
          style:
              TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor)),
    ]);
  }

  Widget _buildPlanDetails(Data data) {
    final df = DateFormat('dd MMM yyyy');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Plan Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildDetailRow("Frequency", data.frequency?.toUpperCase() ?? 'N/A'),
          _buildDetailRow(
              "Monthly Amount", "₹${data.investmentAmount?.toStringAsFixed(2) ?? '0'}"),
          _buildDetailRow(
              "Start Date", data.startDate != null ? df.format(data.startDate!) : 'N/A'),
          _buildDetailRow(
              "End Date", data.endDate != null ? df.format(data.endDate!) : 'N/A'),
          _buildDetailRow(
              "Next Payment",
              data.nextExecutionDate != null
                  ? df.format(data.nextExecutionDate!)
                  : 'Completed'),
          _buildDetailRow(
              "Current Gold Rate",
              "₹${data.profitLoss?.currentGoldPrice?.toStringAsFixed(0) ?? '0'}/g"),
          const Divider(height: 32),
          const Text("Razorpay Subscription",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildDetailRow("Subscription ID", data.razorpaySubscriptionId ?? 'N/A'),
          _buildDetailRow("Status", data.subscriptionStatus?.toUpperCase() ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildInvestmentHistory(Data data, int paidCount) {
    int totalInstallments = 0;

    if (data.frequency?.toLowerCase() == 'weekly') {
      totalInstallments = 52;
    } else if (data.frequency?.toLowerCase() == 'monthly') {
      totalInstallments = 12;
    } else if (data.frequency?.toLowerCase() == 'daily') {
      totalInstallments = 365;
    }

    final progress = totalInstallments > 0 ? paidCount / totalInstallments : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Investment Progress",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Paid Installments",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Text("$paidCount / $totalInstallments",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(AppColors.primaryGold),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${(progress * 100).toStringAsFixed(0)}% Completed",
              style: TextStyle(
                  fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------- ✔ UPDATED DOWNLOAD → SHARE ----------------------

  Widget _buildDownloadButton(Data data, List<Installment> paidInstallments,
      List<Transaction> transactions) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            final doc = pw.Document();
            final df = DateFormat('dd MMM yyyy');
            final amountFmt = NumberFormat('#,##,##0.00');
            final now = DateTime.now();
            final fileName =
                "SIP_Statement_${data.customPlanId ?? data.id}_${now.millisecondsSinceEpoch}.pdf";

            // ---------------- PDF CREATION (UNCHANGED) ----------------
            doc.addPage(
              pw.MultiPage(
                pageFormat: PdfPageFormat.a4,
                margin: const pw.EdgeInsets.all(40),
                header: (context) => pw.Center(
                  child: pw.Text("Aishwarya Gold - SIP Statement",
                      style: pw.TextStyle(
                          fontSize: 22, fontWeight: pw.FontWeight.bold)),
                ),
                build: (context) => [
                  pw.SizedBox(height: 20),
                  pw.Text("Plan ID: ${data.customPlanId ?? data.id}"),
                  pw.Text("Generated: ${df.format(now)}"),
                  pw.Divider(),
                  pw.SizedBox(height: 10),

                  pw.Text("Financial Summary",
                      style:
                          pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  _pdfRow("Total Gold",
                      "${(data.totalGoldAccumulated ?? 0).toStringAsFixed(4)} g"),
                  _pdfRow(
                      "Total Invested", amountFmt.format(data.totalInvested ?? 0)),
                  _pdfRow("Current Value",
                      amountFmt.format(data.profitLoss?.currentValue ?? 0)),
                  _pdfRow(
                    "Profit/Loss",
                    "${data.profitLoss?.isProfitable == true ? '+' : '-'}"
                    "${(data.profitLoss?.profitLoss ?? 0).abs().toStringAsFixed(2)}",
                  ),

                  pw.SizedBox(height: 20),
                  pw.Text("Payment History",
                      style:
                          pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),

                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    children: [
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          _pdfCell("No.", bold: true),
                          _pdfCell("Date", bold: true),
                          _pdfCell("Amount", bold: true),
                          _pdfCell("Gold (g)", bold: true),
                          _pdfCell("Payment ID", bold: true),
                        ],
                      ),
                      ...paidInstallments.asMap().entries.map((e) {
                        final idx = e.key;
                        final inst = e.value;
                        final tx = transactions.length > idx ? transactions[idx] : null;

                        return pw.TableRow(children: [
                          _pdfCell("${idx + 1}"),
                          _pdfCell(
                              inst.paidAt != null ? df.format(inst.paidAt!) : "-"),
                          _pdfCell(amountFmt.format(inst.baseAmount ?? 0)),
                          _pdfCell(
                              tx?.goldBoughtInGram?.toStringAsFixed(4) ?? "-"),
                          _pdfCell(tx?.razorpayPaymentId ?? "N/A"),
                        ]);
                      }),
                    ],
                  ),

                  pw.SizedBox(height: 20),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text("Thank you for trusting Aishwarya Gold",
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey600)),
                  ),
                ],
              ),
            );

            // ---------------------- SAVE → TEMP FOLDER ----------------------
            final tempDir = await getTemporaryDirectory();
            final file = File("${tempDir.path}/$fileName");
            await file.writeAsBytes(await doc.save());

            // ---------------------- SHARE PDF ----------------------
            await Share.shareXFiles([XFile(file.path)],
                text: "Here is your SIP Statement PDF");

          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("Error: $e"), backgroundColor: Colors.red),
              );
            }
          }
        },
        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
        label: const Text("Download PDF Statement",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
        ),
      ),
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child:
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        pw.Text(value,
            style:
                pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ]),
    );
  }

  pw.Widget _pdfCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
    );
  }
}

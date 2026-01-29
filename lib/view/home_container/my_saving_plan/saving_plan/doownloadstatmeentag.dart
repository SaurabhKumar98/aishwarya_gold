import 'dart:io';
import 'package:aishwarya_gold/data/models/downloadstatemetagmodels/downloadstatementmodels.dart';
import 'package:aishwarya_gold/view_models/downloadStatementprovider/downloadStatementProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';

class DownloadStatementScreen extends StatefulWidget {
  final String id;
  const DownloadStatementScreen({super.key, required this.id});

  @override
  State<DownloadStatementScreen> createState() => _DownloadStatementScreenState();
}

class _DownloadStatementScreenState extends State<DownloadStatementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<DownloadStatementProvider>(context, listen: false)
          .fetchDownloadStatement(widget.id);
    });
  }

  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        return Directory('/storage/emulated/0/Downloads');
      }
      return dir;
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text("Download Statement",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<DownloadStatementProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return _buildShimmerLoading();
          if (provider.errorMessage != null) {
            return Center(
                child: Text(provider.errorMessage!,
                    style: const TextStyle(color: Colors.red)));
          }
          if (provider.statementData?.data == null) {
            return const Center(child: Text("No data found"));
          }
          return _buildStatementContent(provider.statementData!);
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          6,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatementContent(DownloadStatementModels model) {
    final data = model.data!;
    final plan = data.planId;
    final installments = data.installments ?? [];
    final paidInstallments =
        installments.where((i) => i.status == Status.PAID).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(data, plan),
          const SizedBox(height: 16),
          _buildFinancialSummary(
              data, plan, paidInstallments.length, installments.length),
          const SizedBox(height: 16),
          _buildPlanDetails(data, plan),
          const SizedBox(height: 16),
          _buildProgressCard(
              paidInstallments.length, installments.length, plan?.type),
          const SizedBox(height: 16),
          _buildInstallmentsSection(paidInstallments),
          const SizedBox(height: 24),
          _buildDownloadButton(data, plan, paidInstallments),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(DownloadData data, PlanId? plan) {
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
                child: const Icon(Icons.description,
                    color: Colors.white, size: 24)),
            const SizedBox(width: 12),
            const Text("AG Plan Statement",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          Text(plan?.name ?? "AG Plan",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          Text("ID: ${data.customPurchaseId ?? data.id ?? 'N/A'}",
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20)),
            child: Text(data.status?.toUpperCase() ?? 'ACTIVE',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(
      DownloadData data, PlanId? plan, int paidCount, int totalCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Financial Summary",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSummaryRow("Total Paid", "${data.totalPaidAmount ?? 0}",
              AppColors.coinBrown),
          const Divider(height: 24),
          _buildSummaryRow("Total Investment", "${plan?.totalInvestment ?? 0}",
              AppColors.primaryGold),
          const Divider(height: 24),
          _buildSummaryRow("Maturity Amount", "${plan?.maturityAmount ?? 0}",
              AppColors.coinBrown),
          const Divider(height: 24),
          _buildSummaryRow("Profit Bonus", "${plan?.profitBonus ?? 0}",
              Colors.green.shade700),
          const Divider(height: 24),
          _buildSummaryRow("Installments Paid", "$paidCount / $totalCount",
              AppColors.primaryGold),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: const TextStyle(fontSize: 14, color: Colors.black54)),
      Text(value,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    ]);
  }

  Widget _buildPlanDetails(DownloadData data, PlanId? plan) {
    final df = DateFormat('dd MMM yyyy');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Plan Details",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildDetailRow("Plan Name", plan?.name ?? 'N/A'),
          _buildDetailRow("Type", plan?.type?.toUpperCase() ?? 'N/A'),
          _buildDetailRow("Amount/Installment", "${plan?.amount ?? 0}"),
          _buildDetailRow(
              "Duration", "${plan?.durationMonths ?? 0} months"),
          _buildDetailRow("Start Date",
              data.startDate != null ? df.format(data.startDate!) : 'N/A'),
          _buildDetailRow("End Date",
              data.endDate != null ? df.format(data.endDate!) : 'N/A'),
          _buildDetailRow(
              "Next Payment",
              data.nextExecutionDate != null
                  ? df.format(data.nextExecutionDate!)
                  : 'Completed'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style:
                const TextStyle(fontSize: 14, color: Colors.black54)),
        Text(value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildProgressCard(int paid, int total, String? type) {
    final progress = total > 0 ? paid / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Progress",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Paid Installments",
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey[600])),
                Text("$paid / $total",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGold)),
              ]),
          const SizedBox(height: 12),
          LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.primaryGold)),
          const SizedBox(height: 8),
          Align(
              alignment: Alignment.centerRight,
              child: Text("${(progress * 100).toStringAsFixed(0)}% Completed",
                  style:
                      TextStyle(color: Colors.grey[600], fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildInstallmentsSection(List<Installment> paidInstallments) {
    if (paidInstallments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(
            child: Text("No paid installments yet",
                style: TextStyle(color: Colors.grey))),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Paid Installments",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...paidInstallments.map(
            (inst) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.green.withOpacity(0.4))),
                child: Row(children: [
                  const CircleAvatar(
                      backgroundColor: AppColors.coinBrown,
                      radius: 18,
                      child:
                          Icon(Icons.check, color: Colors.white, size: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text("Installment ${inst.installmentNumber}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text("Paid: ${_formatDate(inst.paidDate)}",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ])),
                  Text("${inst.totalAmount ?? inst.baseAmount ?? 0}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.coinBrown)),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) =>
      date == null ? "-" : DateFormat('dd MMM yyyy').format(date);

  // 🔥 SHARE PDF INSTEAD OF DOWNLOAD
  Widget _buildDownloadButton(
      DownloadData data, PlanId? plan, List<Installment> paidInstallments) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            final pdf = pw.Document();
            final df = DateFormat('dd MMM yyyy');
            final now = DateTime.now();

            final fileName =
                "AG_Statement_${data.customPurchaseId ?? 'plan'}_${now.millisecondsSinceEpoch}.pdf";

            // ----------- CREATE PDF (unchanged) -------------
            pdf.addPage(
              pw.MultiPage(
                pageFormat: PdfPageFormat.a4,
                margin: const pw.EdgeInsets.all(40),
                build: (c) => [
                  pw.Center(
                      child: pw.Text("Aishwarya Gold Statement",
                          style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold))),
                  pw.SizedBox(height: 20),
                  pw.Text(
                      "Plan ID: ${data.customPurchaseId ?? data.id} • Generated: ${df.format(now)}"),
                  pw.Divider(),
                  pw.SizedBox(height: 10),
                  pw.Text("Financial Summary",
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  _pdfRow("Total Paid", "${data.totalPaidAmount ?? 0}"),
                  _pdfRow(
                      "Total Investment", "${plan?.totalInvestment ?? 0}"),
                  _pdfRow("Maturity Amount",
                      "${plan?.maturityAmount ?? 0}"),
                  _pdfRow(
                      "Installments Paid",
                      "${paidInstallments.length} of ${data.installments?.length ?? 0}"),
                  pw.SizedBox(height: 20),
                  pw.Text("Paid Installments",
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  ...paidInstallments.map((i) => _pdfRow(
                      "Installment ${i.installmentNumber} • ${_formatDate(i.paidDate)}",
                      "${i.totalAmount ?? i.baseAmount ?? 0}")),
                ],
              ),
            );

            // Save to temp folder
            final tempDir = await getTemporaryDirectory();
            final file = File("${tempDir.path}/$fileName");
            await file.writeAsBytes(await pdf.save());

            // SHARE
            await Share.shareXFiles([XFile(file.path)],
                text: "Your Aishwarya Gold Plan Statement");

          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Error: $e"), backgroundColor: Colors.red));
          }
        },
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text("Download PDF Statement",
            style: TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ]),
    );
  }
}

import 'dart:typed_data';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:aishwarya_gold/res/widgets/custom_button.dart';

class GoldCertificateScreen extends StatelessWidget {
  final String customerName;
  final double investedAmount;
  final double goldGrams;
  final DateTime purchaseDate;
  final String customPlanId;
  

  const GoldCertificateScreen({
    super.key,
    required this.customerName,
    required this.investedAmount,
    required this.goldGrams,
    required this.purchaseDate,
    required this.customPlanId,
  });

 Future<void> _downloadCertificate(BuildContext context) async {
  final pdf = pw.Document();
  final formatter = DateFormat('dd MMM yyyy');

  // ✅ Load logo from assets
  final imageBytes = await rootBundle.load('assets/images/cropped-Aishwaryalogo.png');
  final logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 4),
          ),
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // ✅ Logo at top
              pw.Image(logoImage, height: 80), 
              pw.SizedBox(height: 16),

              pw.Text(
                "Aishwarya Gold Palace",
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Text(
                "Gold Investment Certificate",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 30),

              pw.Text(
                "This is to certify that",
                style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 10),

              pw.Text(
                customerName,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.brown800,
                ),
              ),
              pw.SizedBox(height: 10),

              pw.Text(
                "has successfully purchased gold with the following details:",
                style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 20),

              pw.Table.fromTextArray(
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(color: PdfColors.amber50),
                headerHeight: 25,
                cellHeight: 25,
                headerStyle: pw.TextStyle(
                    color: PdfColors.black,
                    fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 14),
                data: [
                  ["Plan ID", customPlanId],
                  ["Investment Amount", "${investedAmount.toStringAsFixed(2)}"],
                  ["Gold Quantity", "${goldGrams.toStringAsFixed(2)} g"],
                  ["Purchase Date", formatter.format(purchaseDate)],
                ],
              ),
              pw.SizedBox(height: 40),

              pw.Text(
                "Thank you for investing with Aishwarya Gold Palace.",
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey800),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        );
      },
    ),
  );

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'Gold_Certificate_$customPlanId.pdf',
  );
}

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text("Gold Certificate"),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryGold, width: 3),
            borderRadius: BorderRadius.circular(16),
            color: Colors.amber.shade50,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "Aishwarya Gold Palace",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.coinBrown,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Gold Investment Certificate",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text("This is to certify that",
                  style: TextStyle(fontSize: 16, color: Colors.grey[800])),
              const SizedBox(height: 8),
              Text(
                customerName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "has successfully purchased gold with the following details:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              _infoRow("Plan ID", customPlanId),
              _infoRow("Investment Amount",
                  "₹${investedAmount.toStringAsFixed(2)}"),
              _infoRow("Gold Quantity", "${goldGrams.toStringAsFixed(3)} grams"),
              _infoRow("Purchase Date", formatter.format(purchaseDate)),
              const SizedBox(height: 40),

              // ✅ Replaced with CustomButton
              CustomButton(
                text: "Download Certificate",
                onPressed: () => _downloadCertificate(context),
                isEnabled: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}

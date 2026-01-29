// import 'package:aishwarya_gold/data/repo/investment_spi_repo/sip_repo.dart';
// import 'package:flutter/material.dart';

// class SipProvider extends ChangeNotifier {
//   final SipRepository repository;
//   final TextEditingController inputController = TextEditingController();

//   double investedAmount = 0.0;
//   double annualInvestment = 0.0;
//   double grams = 0.0;
//   int selectedQuickOption = -1;
//   String? warningMessage;
//   DateTime selectedDate = DateTime.now();
//   List<Map<String, dynamic>> plans = [];

//   SipProvider({required this.repository});

//   void selectQuickOption(int index) {
//     selectedQuickOption = index;
//     double amount = 0;
//     if (index == 0) amount = 1000;
//     if (index == 1) amount = 2000;
//     if (index == 2) amount = 5000;

//     investedAmount = amount;
//     grams = repository.calculateGrams(amount);
//     annualInvestment = repository.calculateAnnualInvestment(amount, index);
//     inputController.text = amount.toString();
//     _validate();
//     notifyListeners();
//   }

//   void updateValue(String val) {
//     double parsed = double.tryParse(val) ?? 0;
//     investedAmount = parsed;
//     grams = repository.calculateGrams(parsed);
//     annualInvestment =
//         repository.calculateAnnualInvestment(parsed, selectedQuickOption);
//     _validate();
//     notifyListeners();
//   }

//   void setDate(DateTime date) {
//     selectedDate = date;
//     notifyListeners();
//   }

//   void addPlan() {
//     if (warningMessage == null && inputController.text.isNotEmpty && selectedQuickOption != -1) {
//       plans.add({
//         'amount': investedAmount,
//         'frequency': selectedQuickOption,
//         'startDate': selectedDate,
//       });
//       inputController.clear();
//       investedAmount = 0;
//       annualInvestment = 0;
//       grams = 0;
//       selectedQuickOption = -1;
//       warningMessage = null;
//       notifyListeners();
//     }
//   }

//   void _validate() {
//     if (investedAmount < 100) {
//       warningMessage = "Minimum ₹100 required for SIP";
//     } else {
//       warningMessage = null;
//     }
//   }

//   @override
//   void dispose() {
//     inputController.dispose();
//     super.dispose();
//   }
// }

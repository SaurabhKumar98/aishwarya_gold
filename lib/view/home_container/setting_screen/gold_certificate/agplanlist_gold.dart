// import 'package:aishwarya_gold/data/models/agdailyplan_models.dart';
// import 'package:aishwarya_gold/data/models/agplanmodels/agplanmodel.dart';
// import 'package:aishwarya_gold/view/home_container/setting_screen/gold_certificate/gold_certificate_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:aishwarya_gold/view_models/invest_provider/ag_plan_provider.dart';
// import 'package:aishwarya_gold/res/constants/app_color.dart';

// class AGPlanListScreen extends StatelessWidget {
//   const AGPlanListScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<AgPlanProvider>(context);
//     final plans = provider.purchasedPlans; // Purchased AG plans
//     final dateFmt = DateFormat('dd MMM yyyy');

//     return Scaffold(
//       appBar: AppBar(title: const Text("AG Plans")),
//       body: plans.isEmpty
//           ? const Center(child: Text("No AG Plans purchased yet"))
//           : ListView.builder(
//               itemCount: plans.length,
//               itemBuilder: (context, index) {
//                 final plan = plans[index];
//                 final planObj = plan['plan'];
//                 final startDate = plan['startDate'] ?? DateTime.now();
//                 final endDate = plan['endDate'] ?? DateTime.now();
//                 final durationMonths = (endDate.difference(startDate).inDays / 30).round();

//                 // Determine plan type label
//                 final String planLabel = plan['planType'] == AgPlanType.daily
//                     ? "Daily AG Plan"
//                     : "Monthly AG Plan";

//                 return GestureDetector(
//                   onTap: () {
//                     final double investedAmount = planObj is AgDailyPlanModel
//                         ? (planObj.dailyAmount ?? 0).toDouble()
//                         : (planObj as Plan).amount?.toDouble() ?? 0.0;

//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => GoldCertificateScreen(
//                           customerName: 'Saurabh Kumar',
//                           investedAmount: investedAmount,
//                           goldGrams: plan['grams'] ?? 0,
//                           purchaseDate: startDate,
//                           planId: planObj.planId ?? 'N/A',
//                         ),
//                       ),
//                     );
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Plan Label
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: AppColors.primaryGold,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             planLabel,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         // Dates
//                         Text(
//                           "Start: ${dateFmt.format(startDate)}",
//                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//                         ),
//                         Text(
//                           "End: ${dateFmt.format(endDate)}",
//                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//                         ),
//                         const SizedBox(height: 8),
//                         // Duration
//                         Text(
//                           "Duration: $durationMonths months",
//                           style: const TextStyle(fontSize: 13, color: Colors.black54),
//                         ),
//                         // Gold info
//                         Text(
//                           "Gold: ${plan['grams'] ?? 0} g",
//                           style: const TextStyle(fontSize: 13, color: Colors.black54),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

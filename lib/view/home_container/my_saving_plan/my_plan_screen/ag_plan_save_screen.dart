// import 'dart:math' as math;
// import 'package:aishwarya_gold/data/models/agplanbyidmodels/agplanbymodels.dart';
// import 'package:aishwarya_gold/data/models/savingagplanmodels/agsavingmodels.dart' hide Installment;
// import 'package:aishwarya_gold/utils/exports/exports.dart';
// import 'package:aishwarya_gold/view/home_container/Buttom_bar.dart';
// import 'package:aishwarya_gold/view/home_container/my_saving_plan/my_plan_screen/agpauseplan.dart';
// import 'package:aishwarya_gold/view/home_container/my_saving_plan/saving_plan/doownloadstatmeentag.dart';
// import 'package:aishwarya_gold/view/home_container/my_saving_plan/saving_plan/download_statement.dart';
// import 'package:aishwarya_gold/view_models/gold_price_provider/goldprice_provider.dart';
// import 'package:aishwarya_gold/view_models/pauseagplan_provider/pauseagplan_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:aishwarya_gold/res/constants/app_color.dart';
// import 'package:provider/provider.dart';
// import 'package:aishwarya_gold/view/home_container/my_saving_plan/saving_plan/jewllery_redemption_screen.dart';

// class AgPlanScreen extends StatefulWidget {
//   final String planId;
//   final String? savingPlanId;
//   final AgSaving? userSavingPlan;

//   const AgPlanScreen({
//     super.key,
//     required this.planId,
//     this.savingPlanId,
//     this.userSavingPlan,
//   });

//   @override
//   State<AgPlanScreen> createState() => _AgPlanScreenState();
// }

// class _AgPlanScreenState extends State<AgPlanScreen> with TickerProviderStateMixin {
//   final NumberFormat currency = NumberFormat.currency(
//     locale: 'en_IN',
//     symbol: '₹',
//     decimalDigits: 0,
//   );

//   bool showMore = false;
//   late AnimationController _progressController;
//   late AnimationController _expandController;
//   late Animation<double> _expandAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _progressController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//     _expandController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _expandAnimation = CurvedAnimation(
//       parent: _expandController,
//       curve: Curves.easeInOut,
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<AgSavingProvider>(context, listen: false);
//       provider.fetchPlanById(widget.planId);

//       final goldProvider = Provider.of<GoldProvider>(context, listen: false);
//       goldProvider.fetchGoldPrice();
//     });
//   }

//   @override
//   void dispose() {
//     _progressController.dispose();
//     _expandController.dispose();
//     super.dispose();
//   }

//   bool _isPlanMatured(AgPlanModels data) {
//     final now = DateTime.now();
//     final end = data.endDate;
//     if (end == null || end.isAfter(now)) return false;

//     final installments = data.installments ?? [];
//     return installments.every((i) => i.status == Status.PAID);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       top: false,
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF8F9FA),
//         appBar: _buildAppBar(),
//         body: Consumer<AgSavingProvider>(
//           builder: (context, provider, _) {
//             if (provider.loading) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (provider.errorMessage != null) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error_outline, size: 48, color: Colors.red),
//                     const SizedBox(height: 16),
//                     Text("Error loading plan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 8),
//                     Text(provider.errorMessage ?? '', textAlign: TextAlign.center),
//                     const SizedBox(height: 24),
//                     ElevatedButton.icon(
//                       onPressed: () => provider.fetchPlanById(widget.planId),
//                       icon: const Icon(Icons.refresh),
//                       label: const Text("Retry"),
//                       style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             if (provider.planData == null || provider.planData!.data == null) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             return _buildContent(provider.planData!.data!);
//           },
//         ),
//       ),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // MAIN CONTENT — 33% PROGRESS + NO RESUME BUTTON
//   // ──────────────────────────────────────────────────────────────
//   Widget _buildContent(AgPlanModels agPlanData) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _progressController
//         ..reset()
//         ..forward();
//     });

//     final planInfo = agPlanData.planId;
//     final amount = planInfo?.amount?.toDouble() ?? 0.0;
//     final maturityAmount = planInfo?.maturityAmount?.toDouble() ?? 0.0;
//     final durationMonths = planInfo?.durationMonths ?? 0;
//     final planType = (planInfo?.type ?? 'monthly').toLowerCase();

//     int paidInstallments = 0;
//     double actualAmountPaid = 0.0;
//     final installments = agPlanData.installments ?? [];

//     debugPrint("Checking ${installments.length} installments:");
//     for (final i in installments) {
//       final installmentAmount = i.totalAmount?.toDouble() ?? 0.0;
//       debugPrint("  Installment ${i.installmentNumber}: status='${i.status}', totalAmount=$installmentAmount");

//       if (i.status == Status.PAID) {
//         paidInstallments++;
//         actualAmountPaid += installmentAmount;
//       }
//     }

//     int totalPeriods = installments.length;
//     if (totalPeriods == 0) {
//       totalPeriods = planType == 'weekly' ? durationMonths * 4 : durationMonths;
//     }

//     final totalExpectedInvestment = amount * totalPeriods;
//     final progress = totalPeriods > 0 ? (paidInstallments / totalPeriods).clamp(0.0, 1.0) : 0.0;

//     final bool isMatured = _isPlanMatured(agPlanData);

//     final String subscriptionStatus = agPlanData.subscriptionStatus?.toLowerCase() ?? '';
//     final bool isPaused = agPlanData.status?.toLowerCase() == 'paused';
//     final bool canPause = subscriptionStatus == 'active' && !isPaused && !isMatured;

//     debugPrint("PAID: $paidInstallments / $totalPeriods → ${(progress * 100).toStringAsFixed(1)}%");

//     final agPlan = {
//       'goalAchieved': actualAmountPaid,
//       'goalTarget': totalExpectedInvestment,
//       'progress': progress,
//       'planType': planInfo?.type ?? 'monthly',
//       'planName': planInfo?.name,
//       'startDate': agPlanData.startDate,
//       'endDate': agPlanData.endDate,
//       'amount': amount,
//       'durationMonths': durationMonths,
//       'profitBonus': planInfo?.profitBonus ?? 0,
//       'completedPeriods': paidInstallments,
//       'totalPeriods': totalPeriods,
//       'isMatured': isMatured,
//       'canPause': canPause,
//       'isPaused': isPaused,
//     };

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           if (isMatured) _buildCongratulationsBanner(),
//           _buildProgressCard(agPlan),
//           const SizedBox(height: 24),
//           _buildShowMoreToggle(),
//           _buildExpandableContent(agPlan),
//           const SizedBox(height: 24),
//           _buildMaturityCard(maturityAmount),
//           const SizedBox(height: 24),
//           _buildActionButtons(agPlan),
//           const SizedBox(height: 20),
//           _buildRedeemButton(isMatured),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // UI COMPONENTS
//   // ──────────────────────────────────────────────────────────────
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       surfaceTintColor: AppColors.backgroundLight,
//       shadowColor: Colors.black.withOpacity(0.1),
//       leading: Container(
//         margin: const EdgeInsets.all(8),
//         child: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
//           onPressed: () => Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const MainScreen(selectedIndex: 1)),
//           ),
//         ),
//       ),
//       title: const Text(
//         "My Saving Plan",
//         style: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
//       ),
//       centerTitle: false,
//       actions: [
//         Padding(
//           padding: const EdgeInsets.only(right: 16.0),
//           child: Consumer<GoldProvider>(
//             builder: (context, goldProvider, _) {
//               if (goldProvider.isLoading) {
//                 return const SizedBox(width: 80, child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))));
//               }
//               if (goldProvider.errorMessage != null) {
//                 return const Icon(Icons.error, color: Colors.red);
//               }
//               final price = goldProvider.currentPricePerGram;
//               return Row(
//                 children: [
//                   const Icon(Icons.wifi_rounded, size: 16, color: Color.fromARGB(255, 150, 13, 13)),
//                   const SizedBox(width: 4),
//                   Text("₹ ${price.toStringAsFixed(2)}/GM", style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600)),
//                 ],
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCongratulationsBanner() {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: [Colors.amber.shade400, Colors.amber.shade600]),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.celebration, size: 44, color: Colors.white),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text("Congratulations!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
//                 SizedBox(height: 4),
//                 Text("Your plan has matured. You can now redeem for gold!", style: TextStyle(fontSize: 14, color: Colors.white70)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProgressCard(Map<String, dynamic> agPlan) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Colors.grey[50]!]),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))],
//         border: Border.all(color: AppColors.primaryRed.withOpacity(0.1), width: 1.5),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Icon(Icons.trending_up, color: AppColors.primaryGold, size: 24),
//               const SizedBox(width: 8),
//               const Text("Overall Plan Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
//             ],
//           ),
//           const SizedBox(height: 24),
//           _buildAnimatedProgress(agPlan),
//           const SizedBox(height: 20),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: AppColors.primaryRed.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(25),
//               border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.check_circle, color: AppColors.primaryRed, size: 16),
//                 const SizedBox(width: 6),
//                 Text(
//                   agPlan['progress'] >= 1.0 ? "Goal Achieved!" : "Your Goal plan is on track",
//                   style: const TextStyle(color: AppColors.primaryRed, fontSize: 14, fontWeight: FontWeight.w600),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//           _buildProgressStats(agPlan),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnimatedProgress(Map<String, dynamic> agPlan) {
//     final planType = agPlan['planType'] == 'weekly' ? 'Weekly' : 'Monthly';
//     final completed = agPlan['completedPeriods'] ?? 0;
//     final total = agPlan['totalPeriods'] ?? 1;

//     return SizedBox(
//       height: 140,
//       width: 280,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           AnimatedBuilder(
//             animation: _progressController,
//             builder: (context, child) {
//               return CustomPaint(
//                 size: const Size(280, 140),
//                 painter: _HalfCirclePainter(
//                   progress: agPlan['progress'] * _progressController.value,
//                   backgroundColor: Colors.grey[300]!,
//                   progressColor: AppColors.primaryGold,
//                 ),
//               );
//             },
//           ),
//           Positioned(
//             bottom: 20,
//             child: AnimatedBuilder(
//               animation: _progressController,
//               builder: (context, child) {
//                 final animatedPct = (agPlan['progress'] * _progressController.value * 100).toInt();
//                 return Column(
//                   children: [
//                     Text("$animatedPct%", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
//                     const SizedBox(height: 4),
//                     Text("$completed/$total ${planType == 'Weekly' ? 'Weeks' : 'Months'}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProgressStats(Map<String, dynamic> agPlan) {
//     return Row(
//       children: [
//         Expanded(child: _buildStatCard("Amount Paid", currency.format(agPlan['goalAchieved']), Icons.emoji_events, AppColors.primaryRed)),
//         const SizedBox(width: 16),
//         Expanded(child: _buildStatCard("Expected Target", currency.format(agPlan['goalTarget']), Icons.flag, AppColors.primaryGold)),
//       ],
//     );
//   }

//   Widget _buildStatCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withOpacity(0.1), color.withOpacity(0.2)]),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color.withOpacity(0.3)),
//         boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: color, size: 18),
//               const SizedBox(width: 6),
//               Expanded(child: Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600))),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
//         ],
//       ),
//     );
//   }

//   Widget _buildShowMoreToggle() {
//     return InkWell(
//       onTap: () {
//         setState(() {
//           showMore = !showMore;
//           if (showMore) {
//             _expandController.forward();
//           } else {
//             _expandController.reverse();
//           }
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(25),
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 2))],
//           border: Border.all(color: AppColors.primaryRed.withOpacity(0.2)),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(showMore ? "Show less" : "Show more", style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.w700, fontSize: 14)),
//             const SizedBox(width: 6),
//             AnimatedRotation(
//               turns: showMore ? 0.5 : 0,
//               duration: const Duration(milliseconds: 300),
//               child: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryRed, size: 20),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildExpandableContent(Map<String, dynamic> agPlan) {
//     return SizeTransition(
//       sizeFactor: _expandAnimation,
//       child: Padding(
//         padding: const EdgeInsets.only(top: 20),
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Colors.grey[50]!]),
//             borderRadius: BorderRadius.circular(18),
//             border: Border.all(color: AppColors.dividerGrey.withOpacity(0.3)),
//             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 3))],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(color: AppColors.coinBrown.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
//                     child: Icon(Icons.assignment, color: AppColors.coinBrown, size: 20),
//                   ),
//                   const SizedBox(width: 12),
//                   const Text("Your Plan Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.coinBrown)),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               _buildPlanDetails(agPlan),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPlanDetails(Map<String, dynamic> agPlan) {
//     final planType = agPlan['planType'] == 'weekly' ? 'Weekly' : 'Monthly';
//     final durationMonths = agPlan['durationMonths'] ?? 0;

//     return Column(
//       children: [
//         _buildDetailRow("Plan Type", planType, Icons.category),
//         _buildDetailRow("Plan Name", agPlan['planName'] ?? 'Unknown', Icons.label),
//         _buildDetailRow("$planType Amount", currency.format(agPlan['amount'] ?? 0), planType == 'Weekly' ? Icons.today : Icons.calendar_month),
//         _buildDetailRow("Duration", "$durationMonths months", Icons.timer),
//         _buildDetailRow("Profit Bonus", currency.format(agPlan['profitBonus'] ?? 0), Icons.card_giftcard),
//       ],
//     );
//   }

//   Widget _buildDetailRow(String label, String value, IconData icon) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[200]!)),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.grey[600], size: 18),
//           const SizedBox(width: 12),
//           Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500))),
//           Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
//         ],
//       ),
//     );
//   }

//   Widget _buildMaturityCard(double maturityAmount) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.amber[50]!, Colors.amber[100]!.withOpacity(0.5)]),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.amber[200]!),
//         boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 4))],
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset('assets/images/coin_no_bg.png', height: 24, width: 24),
//               const SizedBox(width: 8),
//               const Text("Maturity Amount", style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600)),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(currency.format(maturityAmount), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.coinBrown)),
//         ],
//       ),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // ACTION BUTTONS: NO RESUME BUTTON, PAUSE → DISABLED WHEN PAUSED
//   // ──────────────────────────────────────────────────────────────
//   Widget _buildActionButtons(Map<String, dynamic> agPlan) {
//     final bool canPause = agPlan['canPause'] as bool;
//     final bool isPaused = agPlan['isPaused'] as bool;

//     return Row(
//       children: [
//         Expanded(
//           child: _buildOutlinedButton("Download Statement", Icons.download, () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => DownloadStatementScreen(id: widget.savingPlanId!)),
//             );
//           }),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: _buildElevatedButton(
//             isPaused ? "Plan Paused" : "Pause Plan",
//             isPaused ? Icons.pause_circle : Icons.pause_circle,
//             isPaused ? Colors.grey.shade400 : AppColors.primaryRed,
//             canPause
//                 ? () async {
//                     final shouldRefresh = await Navigator.push<bool>(
//                       context,
//                       MaterialPageRoute(builder: (_) => AgPausePlanScreen(id: widget.savingPlanId!)),
//                     );
//                     if (shouldRefresh == true && context.mounted) {
//                       await Provider.of<AgSavingProvider>(context, listen: false).fetchPlanById(widget.planId);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Plan paused successfully"),
//                           backgroundColor: AppColors.coinBrown,
//                           behavior: SnackBarBehavior.floating,
//                         ),
//                       );
//                     }
//                   }
//                 : null,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOutlinedButton(String text, IconData icon, VoidCallback onPressed) {
//     return OutlinedButton(
//       onPressed: onPressed,
//       style: OutlinedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         side: BorderSide(color: Colors.grey[400]!),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, color: Colors.grey[700], size: 18),
//           const SizedBox(width: 6),
//           Flexible(child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color.fromARGB(255, 129, 127, 127), fontWeight: FontWeight.w600, fontSize: 14))),
//         ],
//       ),
//     );
//   }

//   Widget _buildElevatedButton(String text, IconData icon, Color color, VoidCallback? onPressed) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: onPressed != null ? 2 : 0,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, color: Colors.white, size: 18),
//           const SizedBox(width: 6),
//           Flexible(child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
//         ],
//       ),
//     );
//   }

//   Widget _buildRedeemButton(bool isMatured) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [BoxShadow(color: AppColors.coinBrown.withOpacity(isMatured ? 0.3 : 0.1), blurRadius: 15, offset: const Offset(0, 4))],
//       ),
//       child: ElevatedButton(
//         onPressed: isMatured
//             ? () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => JewelleryRedemptionScreen(planId: widget.planId, planType: "AgUserPurchase"),
//                   ),
//                 );
//               }
//             : null,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: isMatured ? AppColors.primaryRed : Colors.grey.shade400,
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           elevation: 0,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(isMatured ? Icons.auto_awesome : Icons.lock, color: Colors.white, size: 24),
//                 const SizedBox(width: 12),
//                 Text(isMatured ? "Redeem for Gold" : "Redemption Locked", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Text(isMatured ? "Visit an Aishwarya Gold Palace store" : "Complete all installments to unlock", style: const TextStyle(color: Colors.white70, fontSize: 13)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _HalfCirclePainter extends CustomPainter {
//   final double progress;
//   final Color backgroundColor;
//   final Color progressColor;

//   _HalfCirclePainter({required this.progress, required this.backgroundColor, required this.progressColor});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height);
//     final radius = size.width / 2 - 8;

//     final backgroundPaint = Paint()
//       ..color = backgroundColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 16
//       ..strokeCap = StrokeCap.round;

//     canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, math.pi, false, backgroundPaint);

//     final progressPaint = Paint()
//       ..shader = LinearGradient(colors: [progressColor, progressColor.withOpacity(0.7), progressColor])
//           .createShader(Rect.fromCircle(center: center, radius: radius))
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 16
//       ..strokeCap = StrokeCap.round;

//     canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, math.pi * progress, false, progressPaint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }



import 'dart:math' as math;
import 'package:aishwarya_gold/data/models/agplanbyidmodels/agplanbymodels.dart';
import 'package:aishwarya_gold/data/models/savingagplanmodels/agsavingmodels.dart' hide Installment;
import 'package:aishwarya_gold/utils/exports/exports.dart';
import 'package:aishwarya_gold/view/home_container/Buttom_bar.dart';
import 'package:aishwarya_gold/view/home_container/my_saving_plan/my_plan_screen/agpauseplan.dart';
import 'package:aishwarya_gold/view/home_container/my_saving_plan/saving_plan/doownloadstatmeentag.dart';
import 'package:aishwarya_gold/view/home_container/my_saving_plan/saving_plan/download_statement.dart';
import 'package:aishwarya_gold/view_models/gold_price_provider/goldprice_provider.dart';
import 'package:aishwarya_gold/view_models/pauseagplan_provider/pauseagplan_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:provider/provider.dart';
import 'package:aishwarya_gold/view/home_container/my_saving_plan/saving_plan/jewllery_redemption_screen.dart';
import 'package:http/http.dart' as http;

class AgPlanScreen extends StatefulWidget {
  final String planId;
  final String? savingPlanId;
  final AgSaving? userSavingPlan;

  const AgPlanScreen({
    super.key,
    required this.planId,
    this.savingPlanId,
    this.userSavingPlan,
  });

  @override
  State<AgPlanScreen> createState() => _AgPlanScreenState();
}

class _AgPlanScreenState extends State<AgPlanScreen> with TickerProviderStateMixin {
  final NumberFormat currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  bool showMore = false;
  bool _isPayingDemo = false;
  late AnimationController _progressController;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AgSavingProvider>(context, listen: false);
      provider.fetchPlanById(widget.planId);

      final goldProvider = Provider.of<GoldProvider>(context, listen: false);
      goldProvider.fetchGoldPrice();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _expandController.dispose();
    super.dispose();
  }

bool _isPlanMatured(AgPlanModels data) {
  final installments = data.installments ?? [];

  // DEMO MODE FIX: If ALL installments are PAID → treat as matured IMMEDIATELY
  if (installments.isNotEmpty && installments.every((i) => i.status == Status.PAID)) {
    return true;
  }

  // Original strict logic for real users (kept for safety)
  final now = DateTime.now();
  final end = data.endDate;
  if (end == null || end.isAfter(now)) return false;

  return installments.every((i) => i.status == Status.PAID);
}
  // DEMO: Pay Installment API
Future<void> _payDemoInstallment() async {
  if (_isPayingDemo) return;

  setState(() => _isPayingDemo = true);

  try {
    final url = Uri.parse(
        'https://api.aishwaryagold.shop/user/demo/ag-plan/${widget.planId}/pay-installment');
        print("abc url :$url");
    
    final response = await http.post(url).timeout(const Duration(seconds: 10));

    if (!mounted) return;

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Refresh the plan
      await Provider.of<AgSavingProvider>(context, listen: false)
          .fetchPlanById(widget.planId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Installment paid successfully! Progress updated"),
          backgroundColor: AppColors.coinBrown,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You have completed all the installments"), backgroundColor: AppColors.primaryRed),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error – try again"), backgroundColor: Colors.red),
      );
    }
  } finally {
    if (mounted) setState(() => _isPayingDemo = false);
  }
}
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(),
        body: Consumer<AgSavingProvider>(
          builder: (context, provider, _) {
            if (provider.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text("Error loading plan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(provider.errorMessage ?? '', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => provider.fetchPlanById(widget.planId),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
                    ),
                  ],
                ),
              );
            }
            if (provider.planData == null || provider.planData!.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildContent(provider.planData!.data!);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: AppColors.backgroundLight,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: Container(
        margin: const EdgeInsets.all(8),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen(selectedIndex: 1)),
          ),
        ),
      ),
      title: const Text(
        "My Saving Plan",
        style: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Consumer<GoldProvider>(
            builder: (context, goldProvider, _) {
              if (goldProvider.isLoading) {
                return const SizedBox(width: 80, child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))));
              }
              if (goldProvider.errorMessage != null) {
                return const Icon(Icons.error, color: Colors.red);
              }
              final price = goldProvider.currentPricePerGram;
              return Row(
                children: [
                  const Icon(Icons.wifi_rounded, size: 16, color: Color.fromARGB(255, 150, 13, 13)),
                  const SizedBox(width: 4),
                  Text("₹ ${price.toStringAsFixed(2)}/GM", style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContent(AgPlanModels agPlanData) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _progressController
        ..reset()
        ..forward();
    });

    final planInfo = agPlanData.planId;
    final amount = planInfo?.amount?.toDouble() ?? 0.0;
    final maturityAmount = planInfo?.maturityAmount?.toDouble() ?? 0.0;
    final durationMonths = planInfo?.durationMonths ?? 0;
    final planType = (planInfo?.type ?? 'monthly').toLowerCase();

    int paidInstallments = 0;
    double actualAmountPaid = 0.0;
    final installments = agPlanData.installments ?? [];

    for (final i in installments) {
      final installmentAmount = i.totalAmount?.toDouble() ?? 0.0;
      if (i.status == Status.PAID) {
        paidInstallments++;
        actualAmountPaid += installmentAmount;
      }
    }

int totalPeriods = installments.isNotEmpty 
    ? installments.length 
    : durationMonths;
        final totalExpectedInvestment = amount * totalPeriods;
    final progress = totalPeriods > 0 ? (paidInstallments / totalPeriods).clamp(0.0, 1.0) : 0.0;

    final bool isMatured = _isPlanMatured(agPlanData);
    final bool isPaused = agPlanData.status?.toLowerCase() == 'paused';
    final bool canPause = agPlanData.subscriptionStatus?.toLowerCase() == 'active' && !isPaused && !isMatured;

    final agPlan = {
      'goalAchieved': actualAmountPaid,
      'goalTarget': totalExpectedInvestment,
      'progress': progress,
      'planType': planInfo?.type ?? 'monthly',
      'planName': planInfo?.name,
      'startDate': agPlanData.startDate,
      'endDate': agPlanData.endDate,
      'amount': amount,
      'durationMonths': durationMonths,
      'profitBonus': planInfo?.profitBonus ?? 0,
      'completedPeriods': paidInstallments,
      'totalPeriods': totalPeriods,
      'isMatured': isMatured,
      'canPause': canPause,
      'isPaused': isPaused,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (isMatured) _buildCongratulationsBanner(),
          _buildProgressCard(agPlan),
          const SizedBox(height: 24),
          _buildShowMoreToggle(),
          _buildExpandableContent(agPlan),
          const SizedBox(height: 24),
          _buildMaturityCard(maturityAmount),
          const SizedBox(height: 24),

          // DEMO BUTTON
          // _surfaceCard(
          //   child: ElevatedButton.icon(
          //     onPressed: _isPayingDemo || isMatured || isPaused
          //         ? null
          //         : _payDemoInstallment,
          //     icon: _isPayingDemo
          //         ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          //         : const Icon(Icons.add_circle_outline, size: 22),
          //     label: Text(_isPayingDemo ? "Adding Installment..." : "Add Installment (Demo)"),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: AppColors.primaryRed,
          //       foregroundColor: Colors.white,
          //       padding: const EdgeInsets.symmetric(vertical: 16),
          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          //       elevation: 4,
          //     ),
          //   ),
          // ),
          const SizedBox(height: 24),

          _buildActionButtons(agPlan),
          const SizedBox(height: 20),
          _buildRedeemButton(isMatured),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _surfaceCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildCongratulationsBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.amber.shade400, Colors.amber.shade600]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Icon(Icons.celebration, size: 44, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Congratulations!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text("Your plan has matured. You can now redeem for gold!", style: TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(Map<String, dynamic> agPlan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Colors.grey[50]!]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.primaryGold, size: 24),
              const SizedBox(width: 8),
              const Text("Overall Plan Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 24),
          _buildAnimatedProgress(agPlan),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: AppColors.primaryRed, size: 16),
                const SizedBox(width: 6),
                Text(
                  agPlan['progress'] >= 1.0 ? "Goal Achieved!" : "Your Goal plan is on track",
                  style: const TextStyle(color: AppColors.primaryRed, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildProgressStats(agPlan),
        ],
      ),
    );
  }

Widget _buildAnimatedProgress(Map<String, dynamic> agPlan) {
  final planTypeRaw = agPlan['planType']?.toString().toLowerCase() ?? 'monthly';
  final planType = planTypeRaw == 'weekly' ? 'Weekly' : 'Monthly';
  final completed = agPlan['completedPeriods'] ?? 0;
  final total = agPlan['totalPeriods'] ?? 1;

  return SizedBox(
    height: 140,
    width: 280,
    child: Stack(
      alignment: Alignment.center,
      children: [AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(280, 140),
                painter: _HalfCirclePainter(
                  progress: agPlan['progress'] * _progressController.value,
                  backgroundColor: Colors.grey[300]!,
                  progressColor: AppColors.primaryGold,
                ),
              );
            },
          ),
        // ... AnimatedBuilder with CustomPaint ...
        Positioned(
          bottom: 20,
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              final animatedPct = (agPlan['progress'] * _progressController.value * 100).toInt();
              return Column(
                children: [
                  Text("$animatedPct%", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text("$completed/$total ${planType == 'Weekly' ? 'Weeks' : 'Months'}", 
                       style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}
  
  Widget _buildProgressStats(Map<String, dynamic> agPlan) {
    return Row(
      children: [
        Expanded(child: _buildStatCard("Amount Paid", currency.format(agPlan['goalAchieved']), Icons.emoji_events, AppColors.primaryRed)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard("Expected Target", currency.format(agPlan['goalTarget']), Icons.flag, AppColors.primaryGold)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withOpacity(0.1), color.withOpacity(0.2)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(child: Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildShowMoreToggle() {
    return InkWell(
      onTap: () {
        setState(() {
          showMore = !showMore;
          if (showMore) {
            _expandController.forward();
          } else {
            _expandController.reverse();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 2))],
          border: Border.all(color: AppColors.primaryRed.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(showMore ? "Show less" : "Show more", style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(width: 6),
            AnimatedRotation(
              turns: showMore ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryRed, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableContent(Map<String, dynamic> agPlan) {
    return SizeTransition(
      sizeFactor: _expandAnimation,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Colors.grey[50]!]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.dividerGrey.withOpacity(0.3)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.coinBrown.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.assignment, color: AppColors.coinBrown, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text("Your Plan Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.coinBrown)),
                ],
              ),
              const SizedBox(height: 20),
              _buildPlanDetails(agPlan),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildPlanDetails(Map<String, dynamic> agPlan) {
  final planTypeRaw = agPlan['planType']?.toString().toLowerCase() ?? 'monthly';
  final planType = planTypeRaw == 'weekly' ? 'Weekly' : 'Monthly';
  final durationMonths = agPlan['durationMonths'] ?? 0;
  
  // Change duration text based on plan type
  final durationText = planTypeRaw == 'weekly' 
      ? "$durationMonths week${durationMonths == 1 ? '' : 's'}"
      : "$durationMonths month${durationMonths == 1 ? '' : 's'}";

  return Column(
    children: [
      _buildDetailRow("Plan Type", planType, Icons.category),
      _buildDetailRow("Plan Name", agPlan['planName'] ?? 'Unknown', Icons.label),
      _buildDetailRow("$planType Amount", currency.format(agPlan['amount'] ?? 0), planType == 'Weekly' ? Icons.today : Icons.calendar_month),
      _buildDetailRow("Duration", durationText, Icons.timer), // ← FIXED
      _buildDetailRow("Profit Bonus", currency.format(agPlan['profitBonus'] ?? 0), Icons.card_giftcard),
    ],
  );
}

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[200]!)),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500))),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildMaturityCard(double maturityAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.amber[50]!, Colors.amber[100]!.withOpacity(0.5)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber[200]!),
        boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/coin_no_bg.png', height: 24, width: 24),
              const SizedBox(width: 8),
              const Text("Maturity Amount", style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Text(currency.format(maturityAmount), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.coinBrown)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> agPlan) {
    final bool canPause = agPlan['canPause'] as bool;
    final bool isPaused = agPlan['isPaused'] as bool;

    return Row(
      children: [
        Expanded(
          child: _buildOutlinedButton("Download Statement", Icons.download, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DownloadStatementScreen(id: widget.savingPlanId!)),
            );
          }),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildElevatedButton(
            isPaused ? "Plan Paused" : "Pause Plan",
            isPaused ? Icons.pause_circle : Icons.pause_circle,
            isPaused ? Colors.grey.shade400 : AppColors.primaryRed,
            canPause
                ? () async {
                    final shouldRefresh = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => AgPausePlanScreen(id: widget.savingPlanId!)),
                    );
                    if (shouldRefresh == true && context.mounted) {
                      await Provider.of<AgSavingProvider>(context, listen: false).fetchPlanById(widget.planId);
                    }
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildOutlinedButton(String text, IconData icon, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: Colors.grey[400]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[700], size: 18),
          const SizedBox(width: 6),
          Flexible(child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color.fromARGB(255, 129, 127, 127), fontWeight: FontWeight.w600, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildElevatedButton(String text, IconData icon, Color color, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: onPressed != null ? 2 : 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Flexible(child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildRedeemButton(bool isMatured) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.coinBrown.withOpacity(isMatured ? 0.3 : 0.1), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: isMatured
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JewelleryRedemptionScreen(planId: widget.planId, planType: "AgUserPurchase"),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isMatured ? AppColors.primaryRed : Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isMatured ? Icons.auto_awesome : Icons.lock, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(isMatured ? "Redeem for Gold" : "Redemption Locked", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 6),
            Text(isMatured ? "Visit an Aishwarya Gold Palace store" : "Complete all installments to unlock", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _HalfCirclePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _HalfCirclePainter({required this.progress, required this.backgroundColor, required this.progressColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, math.pi, false, backgroundPaint);

    final progressPaint = Paint()
      ..shader = LinearGradient(colors: [progressColor, progressColor.withOpacity(0.7), progressColor])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, math.pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
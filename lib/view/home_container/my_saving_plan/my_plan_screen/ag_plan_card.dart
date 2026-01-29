// File: lib/widgets/ag_plan_card.dart
import 'package:aishwarya_gold/view_models/invest_provider/ag_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/data/models/agplanmodels/agplanmodel.dart';

class AgPlanCard extends StatelessWidget {
  final Map<String, dynamic> agPlan;
  final DateFormat dateFmt;
  final NumberFormat currency;
  final VoidCallback onTap;

  const AgPlanCard({
    super.key,
    required this.agPlan,
    required this.dateFmt,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = agPlan['startDate'] as DateTime?;
    final endDate = agPlan['endDate'] as DateTime?;
    final planType = agPlan['planType'] as AgPlanType?;
    final dynamic plan = agPlan['plan'];

    if (startDate == null || endDate == null || planType == null || plan == null) {
      return const SizedBox.shrink();
    }

    // Use backend duration directly!
    final int backendDuration = plan.durationMonths ?? 0; // This is the key!

    String durationText;
    if (planType == AgPlanType.weekly) {
      durationText = "$backendDuration week${backendDuration == 1 ? '' : 's'}";
    } else {
      durationText = "$backendDuration month${backendDuration == 1 ? '' : 's'}";
    }

    String planLabel = planType == AgPlanType.weekly ? "Weekly Plan" : "Monthly Plan";
    String amountText = currency.format(plan.amount ?? 0);
    String maturityText = currency.format(plan.maturityAmount ?? 0);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Plan Started On", style: TextStyle(color: Colors.black54, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(dateFmt.format(startDate), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      const Text("Duration", style: TextStyle(color: Colors.black54, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(durationText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(planType == AgPlanType.weekly ? "Weekly Amount" : "Monthly Amount",
                          style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(amountText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      const Text("Maturity Amount", style: TextStyle(color: Colors.black54, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(maturityText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -12,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3)),
                ],
              ),
              child: Text(
                planLabel,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
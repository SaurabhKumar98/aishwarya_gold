import 'package:aishwarya_gold/utils/plan_card_saving/plan_card.dart' as utils;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';

class SipPlanCard extends StatelessWidget {
  final Map<String, dynamic> sip;
  final DateFormat dateFmt;
  final NumberFormat currency;
  final VoidCallback onTap;

  const SipPlanCard({
    super.key,
    required this.sip,
    required this.dateFmt,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.tryParse(sip['startDate'].toString()) ?? DateTime.now();
    final frequencyStr = (sip['frequency']?.toString() ?? 'DAILY').toUpperCase();
    final status = (sip['status']?.toString() ?? '').toUpperCase();

    // Check if plan is COMPLETED
    final bool isCompleted = status == 'COMPLETED' || sip['nextExecutionDate'] == null && sip['totalInvested'] != null;

    DateTime? nextDate;
    if (!isCompleted) {
      final frequencyIndex = switch (frequencyStr) {
        'DAILY' => 0,
        'WEEKLY' => 1,
        'MONTHLY' => 2,
        _ => 0,
      };
      nextDate = utils.getNextDate(frequencyIndex, startDate);
    }

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
                // Left: Start Date + Accumulated
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Plan Started On", style: TextStyle(color: Colors.black54, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(dateFmt.format(startDate), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      const Text("Accumulated Till Now", style: TextStyle(color: Colors.black54, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(currency.format(sip['accumulated'] ?? sip['totalInvested'] ?? 0),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Right: Next Due OR Completed
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCompleted ? "Status" : "Next Due On",
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const SizedBox(height: 6),

                      isCompleted
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.coinBrown,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.coinBrown, width: 1.5),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: AppColors.backgroundLight, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    "Completed",
                                    style: TextStyle(
                                      color: AppColors.backgroundLight,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Text(
                              nextDate != null ? dateFmt.format(nextDate) : "N/A",
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),

                      const SizedBox(height: 12),
                      const Text("Amount", style: TextStyle(color: Colors.black54, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(currency.format(sip['amount'] ?? sip['investmentAmount']),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Frequency Badge
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
                utils.frequencyLabel(frequencyStr),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
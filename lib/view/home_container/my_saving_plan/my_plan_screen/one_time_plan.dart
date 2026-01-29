import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/data/models/onetimesavingmodels/onetime_saving_models.dart';

class OneTimePlanCard extends StatelessWidget {
  final OneTimeSav oneTime;
  final DateFormat dateFmt;
  final NumberFormat currency;
  final VoidCallback onTap;

  const OneTimePlanCard({
    super.key,
    required this.oneTime,
    required this.dateFmt,
    required this.currency,
    required this.onTap,
  });

@override
Widget build(BuildContext context) {
  final startDate = oneTime.createdAt ?? DateTime.now();
  final grams = oneTime.goldQty ?? 0;
  
  // 🔥 CHANGE THIS LINE: Use totalAmountToPay instead of amountPaid
  final amount = oneTime.totalAmountToPay ?? oneTime.amountPaid ?? 0;

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
                    const Text(
                      "Plan Started On",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dateFmt.format(startDate),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Gold Qty",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${grams.toStringAsFixed(3)} gm",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Amount",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currency.format(amount),  // ← Now shows full ₹206
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    // Optional: Show "You saved ₹50" if discount was applied
                    // if (oneTime.discountAmount != null && (oneTime.discountAmount ?? 0) > 0)
                    //   Padding(
                    //     padding: const EdgeInsets.only(top: 4),
                    //     child: Text(
                    //       "Saved ₹${oneTime.discountAmount?.toStringAsFixed(0)}",
                    //       style: const TextStyle(
                    //         color: Colors.green,
                    //         fontSize: 11,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //   ),
                  
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
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Text(
              "One Time",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}

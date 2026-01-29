import 'package:flutter/material.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';

class OneTimeWidget extends StatelessWidget {
  const OneTimeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Projected 1 year returns",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            "₹1.20L",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text("Investment: ₹1.09L   Earning: ₹10,919.17*"),
        ],
      ),
    );
  }
}

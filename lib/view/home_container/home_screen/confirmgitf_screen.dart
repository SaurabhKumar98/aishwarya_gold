import 'dart:math';

import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/res/widgets/custom_button.dart';
import 'package:aishwarya_gold/view/home_container/Buttom_bar.dart';
import 'package:flutter/material.dart';

class ConfirmGiftScreen extends StatelessWidget {
  final double amount;
  final String mobileNumber;
  final String message;

  const ConfirmGiftScreen({
    super.key,
    required this.amount,
    required this.mobileNumber,
    required this.message, required String email, required String name,
  });

  // Sample gold price per gram
  // static const double goldPricePerGram = 10887.80;

  // // Calculate gold grams based on amount
  // double get goldGrams {
  //   return (amount / goldPricePerGram).toPrecision(3);
  // }

  // // Calculate processing fee (1% of amount)
  // double get processingFee {
  //   return amount * 0.01;
  // }

  // // Total amount including processing fee
  // double get totalAmount {
  //   return amount + processingFee;
  // }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardMaxWidth = screenWidth * 0.9; // 90% of screen width

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>MainScreen())),
        ),
        title: const Text(
          "Confirm Gift",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: cardMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              Text(
                "You are gifting gold worth ₹${amount.toStringAsFixed(0)} to $mobileNumber",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Gift Value Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notification_add, color: Colors.amber, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "GIFT VALUE",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "₹${amount.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Message Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x11000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Message",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message.isEmpty ? "No message added" : message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Confirm & Pay Button
              CustomButton(
                text: "Back to Home",
                onPressed: () {
                  // _showGiftSuccessDialog(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>MainScreen()));
                },
                isEnabled: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Success Dialog
// void _showGiftSuccessDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (ctx) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: const Padding(
//           padding: EdgeInsets.only(bottom: 8),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.check_circle, color: Colors.green, size: 28),
//               SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   "Gift Sent Successfully!",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         content: SingleChildScrollView(
//           child: const Text(
//             "Your gift has been sent to the recipient. They will receive a notification shortly.",
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop(); // Close dialog
//               Navigator.pop(context); // Go back to GiftGoldScreen
//             },
//             child: const Text(
//               "OK",
//               style: TextStyle(
//                 color: AppColors.primaryRed,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       );
//     },
//   );
// }
// }

// // ✅ Extension for double to get precision
// extension DoubleExtension on double {
//   double toPrecision(int fractionDigits) {
//     double mod = pow(10, fractionDigits).toDouble();
//     return ((this * mod).round().toDouble() / mod);
//   }
 }
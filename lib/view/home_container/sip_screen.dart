// import 'package:flutter/material.dart';
// import 'package:aishwarya_gold/res/constants/app_color.dart';

// class SipSection extends StatelessWidget {
//   final TextEditingController controller;

//   const SipSection({super.key, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // 🔹 Price Input Container
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: Row(
//             children: [
//               const Text("g",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               const Icon(Icons.currency_lira, color: Colors.amber),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: TextField(
//                   controller: controller,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     border: InputBorder.none,
//                     hintText: "Enter grams",
//                   ),
//                 ),
//               ),
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Icon(Icons.sync_alt, color: AppColors.textGrey),
//               ),
//               const Text(
//                 "₹ 112467.45",
//                 textAlign: TextAlign.right,
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),

//         // 🔹 Projected Returns Container
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: const [
//               Text(
//                 "Projected 1 year returns",
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 "₹38,168.49",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 5),
//               Text(
//                 "Investment: ₹35,436.89   Earning: ₹2,731.59*",
//                 style: TextStyle(color: Colors.black54),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

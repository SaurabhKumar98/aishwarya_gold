// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class SignUpWidget extends StatelessWidget {
//   final TextEditingController nameController;
//   final TextEditingController phoneController;

//   const SignUpWidget({
//     super.key,
//     required this.nameController,
//     required this.phoneController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Enter Your Name",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey), // static grey border
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: TextField(
//             controller: nameController,
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//               focusedBorder: InputBorder.none,
//               enabledBorder: InputBorder.none,
//               hintText: "Enter Your Name",
//             ),
//           ),
//         ),
//         const SizedBox(height: 30),

//         const Text(
//           "Enter Your Phone Number",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey), // static grey border
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: [
//               const Text(
//                 "+91",
//                 style: TextStyle(
//                   fontWeight: FontWeight.w500,
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: TextField(
//                   controller: phoneController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly, // only digits
//                     LengthLimitingTextInputFormatter(10), // max 10 digits
//                   ],
//                   decoration: const InputDecoration(
//                     border: InputBorder.none,
//                     focusedBorder: InputBorder.none,
//                     enabledBorder: InputBorder.none,
//                     hintText: "Phone Number",
//                   ),
//                 ),
                
//               ),
              
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController? referralCodeController; // ← NEW: Optional

  const SignUpWidget({
    super.key,
    required this.nameController,
    required this.phoneController,
    this.referralCodeController, // ← Accept from parent
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === NAME FIELD ===
        const Text(
          "Enter Your Name",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              hintText: "Enter Your Name",
            ),
          ),
        ),
        const SizedBox(height: 30),

        // === PHONE FIELD ===
        const Text(
          "Enter Your Phone Number",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text(
                "+91",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: "Phone Number",
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // === REFERRAL CODE FIELD (OPTIONAL) ===
        const Text(
          "Referral Code (Optional)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.card_giftcard, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: referralCodeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: "e.g. GOLD123",
                    counterText: "",
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
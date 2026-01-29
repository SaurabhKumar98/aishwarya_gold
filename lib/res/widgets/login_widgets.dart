import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginWidget extends StatelessWidget {
  final TextEditingController phoneController;

  const LoginWidget({super.key, required this.phoneController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enter Your Phone Number",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey), // stays same always
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text(
                "+91",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // digits only
                    LengthLimitingTextInputFormatter(10), // max 10 digits
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
      ],
    );
  }
}

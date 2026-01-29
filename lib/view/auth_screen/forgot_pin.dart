import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/res/widgets/custom_button.dart';
import 'package:aishwarya_gold/res/widgets/opt_row.dart';
import 'package:flutter/material.dart';

class ForgotPinScreen extends StatefulWidget {
  const ForgotPinScreen({super.key});

  @override
  State<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends State<ForgotPinScreen> {
  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> otpControllers =
      List.generate(4, (index) => TextEditingController());
  bool otpSent = false;
  bool otpVerified = false;

  void sendOtp() {
    setState(() => otpSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP sent to your phone number")),
    );
  }

  void verifyOtp() {
    setState(() => otpVerified = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP verified successfully")),
    );
  }

  void resetPin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You can now set a new PIN")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Forgot PIN",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Enter registered phone number",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.phone_android_rounded),
              ),
            ),
            const SizedBox(height: 24),
            if (otpSent)
              OtpRow(
                controllers: otpControllers,
                focusNodes: List.generate(4, (i) => FocusNode()),
                obscureText: false,
                onChanged: (value, index) {},
              ),
            const SizedBox(height: 24),
            CustomButton(
              text: !otpSent
                  ? "Send OTP"
                  : !otpVerified
                      ? "Verify OTP"
                      : "Reset PIN",
              onPressed: () {
                if (!otpSent) {
                  sendOtp();
                } else if (!otpVerified) {
                  verifyOtp();
                } else {
                  resetPin();
                }
              },
              color: AppColors.primaryGold,
            ),
          ],
        ),
      ),
    );
  }
}

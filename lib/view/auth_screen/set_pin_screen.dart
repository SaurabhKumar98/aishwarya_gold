
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/res/widgets/opt_row.dart';
import 'package:aishwarya_gold/res/widgets/custom_button.dart';
import 'package:aishwarya_gold/view_models/auth_provider/repo_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetPinScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String ?referralCode;
  
  const SetPinScreen({
    Key? key,
    required this.name,
    required this.phone,
    this.referralCode,
  }) : super(key: key);

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  @override
  void initState() {
    super.initState();
    // Set the name and phone in provider when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RegistrationProvider>(context, listen: false);
      provider.name = widget.name;
      provider.phone = widget.phone;
      provider.referralCode =widget.referralCode;
      print("📥 SetPinScreen received: Name=${widget.name}, Phone=${widget.phone},ReferralCode =${widget.referralCode}");
    });
  }

  @override
  Widget build(BuildContext context) {
    final registrationProvider = Provider.of<RegistrationProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Set PIN",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed?.withOpacity(0.08) ?? Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 45,
                        color: AppColors.primaryRed ?? Colors.red.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Secure Your Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Hi ${widget.name}!\nEnter a 4-digit PIN to continue",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.6),
                    ),
                    const SizedBox(height: 50),
                    OtpRow(
                      controllers: registrationProvider.controllers,
                      focusNodes: registrationProvider.focusNodes,
                      obscureText: true,
                      onChanged: (value, index) {
                        registrationProvider.onChanged?.call(value, index);
                      },
                    ),
                    const SizedBox(height: 16),
                    if (registrationProvider.errorMessage != null)
                      Center(
                        child: Text(
                          registrationProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 8),
                  child: CustomButton(
                    text: "Continue",
                    isEnabled: registrationProvider.isPinFilled,
                    onPressed: () {
                      // Store PIN and navigate to KYC with name, phone, and pin
                      registrationProvider.setPin(
                        registrationProvider.getPin(),
                        context,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
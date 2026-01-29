import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view/auth_screen/set_pin_screen.dart';
import 'package:aishwarya_gold/view/home_container/Buttom_bar.dart';
import 'package:aishwarya_gold/view_models/auth_provider/otp_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aishwarya_gold/res/widgets/opt_row.dart';
import 'package:aishwarya_gold/res/widgets/custom_button.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String otp;

  const OtpScreen({
    Key? key,
    required this.phone,
    required this.otp,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

  @override
  void initState(){
    super.initState();
      Provider.of<OtpProvider>(context, listen: false).sendFcmTokenIfNeeded();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return ChangeNotifierProvider(
      create: (_) => OtpProvider()..startResendTimer(),
      child: Consumer<OtpProvider>(
        builder: (context, otpProvider, _) {
          return WillPopScope(
            onWillPop: () async {
              if (otpProvider.focusNodes.any((node) => node.hasFocus)) {
                FocusScope.of(context).unfocus();
                return false;
              }
              return true;
            },
            child: Scaffold(
              backgroundColor: AppColors.backgroundWhite,
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  "Verify OTP",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
                backgroundColor: AppColors.backgroundWhite,
                elevation: 0,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Icon/Illustration
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.message_outlined,
                            size: 50,
                            color: AppColors.primaryRed,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Title Text
                        const Text(
                          "Verification Code",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Description
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: "We have sent a verification code to\n"),
                              TextSpan(
                                text:"+91 ${widget.phone}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // OTP Input Boxes
                        OtpRow(
                          controllers: otpProvider.controllers,
                          focusNodes: otpProvider.focusNodes,
                          onChanged: otpProvider.onChanged,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // OTP Validity Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.coinBrown,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.coinBrown,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: AppColors.backgroundLight,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Code valid for 10 minutes",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.backgroundLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Lockout Message
                        if (otpProvider.isLockedOut)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.red[100]!,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.lock_clock_rounded,
                                    color: Colors.red[700],
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Too Many Attempts!",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[900],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Please try again after\n${otpProvider.formatLockoutTime()}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red[700],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          // Resend OTP Section
                          Column(
                            children: [
                              Text(
                                "Didn't receive the code?",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              if (otpProvider.resendTimer > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 18,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Resend in ${otpProvider.resendTimer}s",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                GestureDetector(
                                  onTap: otpProvider.isResending
                                      ? null
                                      : () async {
                                          await otpProvider.resendOtp(
                                            widget.phone,
                                            context,
                                          );
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: otpProvider.isResending
                                          ? Colors.grey[200]
                                          : AppColors.primaryRed,
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color: otpProvider.isResending
                                            ? Colors.grey[300]!
                                            : AppColors.primaryRed,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (otpProvider.isResending)
                                          SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.grey[600],
                                            ),
                                          )
                                        else
                                          Icon(
                                            Icons.refresh_rounded,
                                            size: 18,
                                            color: AppColors.backgroundLight,
                                          ),
                                        const SizedBox(width: 8),
                                        Text(
                                          otpProvider.isResending
                                              ? "Sending..."
                                              : "Resend Code",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: otpProvider.isResending
                                                ? Colors.grey[600]
                                                : AppColors.backgroundLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              
                              if (otpProvider.resendAttempts > 0 &&
                                  otpProvider.resendAttempts < 3)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "${3 - otpProvider.resendAttempts} attempt${3 - otpProvider.resendAttempts > 1 ? 's' : ''} remaining",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange[800],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        
                        SizedBox(height: size.height * 0.05),
                        
                        // Error Message
                        if (otpProvider.errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red[100]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.red[700],
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    otpProvider.errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red[900],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Loading Indicator
                        if (otpProvider.isLoading)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: CircularProgressIndicator(
                              color: AppColors.primaryRed,
                            ),
                          ),
                        
                        // Verify Button
                        CustomButton(
                          text: otpProvider.isLoading
                              ? "Verifying..."
                              : "Verify & Continue",
                          isEnabled: otpProvider.isOtpFilled && 
                                    !otpProvider.isLoading,
                          onPressed: otpProvider.isOtpFilled
                              ? () async {
                                  print("Verify OTP button pressed");
                                  await otpProvider.verifyOtp(widget.phone, context);

                                  if (otpProvider.errorMessage != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(otpProvider.errorMessage!),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              : null,
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
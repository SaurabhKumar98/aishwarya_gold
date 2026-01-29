import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view/home_container/Buttom_bar.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final int investedAmount;
  final String planName;

  const PaymentSuccessScreen({
    super.key,
    required this.investedAmount,
    required this.planName,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    /// Auto redirect after 4 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScreen(selectedIndex: 0),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// ✅ SUCCESS ANIMATION
                SizedBox(
                  width: 300.w,
                  height: 300.h,
                  child: Lottie.asset(
                    'assets/animations/success_celebration.json',
                    controller: _controller,
                    repeat: false,
                    onLoaded: (composition) {
                      _controller
                        ..duration = composition.duration
                        ..forward();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint("❌ Lottie error: $error");
                      return const Icon(
                        Icons.check_circle,
                        size: 120,
                        color: Colors.green,
                      );
                    },
                  ),
                ),

                SizedBox(height: 32.h),

                /// ✅ TITLE
                Text(
                  "Welcome to Aishwarya Gold Company!",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16.h),

                /// ✅ SUBTITLE
                Text(
                  "Thank you for your investment",
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24.h),

                /// ✅ INVESTMENT CARD
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFB8860B),
                        Color(0xFFFFD700),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "₹${widget.investedAmount}",
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "in ${widget.planName}",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40.h),

                /// ✅ MESSAGE
                Text(
                  "Your AG Plan is now active!\n"
                  "Start your journey towards pure gold wealth ✨",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40.h),

                /// ✅ REDIRECT TEXT
                Text(
                  "Redirecting to home...",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
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

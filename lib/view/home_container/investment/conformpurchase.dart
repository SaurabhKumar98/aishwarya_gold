import 'package:aishwarya_gold/data/models/agplanmodels/agplanmodel.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/res/widgets/custom_button.dart';
import 'package:aishwarya_gold/view/home_container/Buttom_bar.dart';
import 'package:aishwarya_gold/view/home_container/investment/ag_plan_screen/paymentsuccessfullscreen.dart';
import 'package:aishwarya_gold/view_models/invest_provider/ag_plan_provider.dart';
import 'package:aishwarya_gold/view_models/razorpay_provider/razorpay_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';

class Agplanconfirmscreen extends StatefulWidget {
  final int amount;
  final Plan selectedPlan;
  final DateTime startDate;
  final DateTime endDate; // This comes from backend → often WRONG (off by 1 month)
  final AgPlanType planType;
  final String selectedUserid;
  final String subscriptionId;

  const Agplanconfirmscreen({
    super.key,
    required this.amount,
    required this.selectedPlan,
    required this.startDate,
    required this.endDate,
    required this.planType,
    required this.selectedUserid,
    required this.subscriptionId,
  });

  @override
  State<Agplanconfirmscreen> createState() => _AgplanconfirmscreenState();
}

class _AgplanconfirmscreenState extends State<Agplanconfirmscreen> {
  final RazorpayService _razorpayService = RazorpayService();
  bool _isProcessing = false;
  bool _showShimmer = false;
  String _processingStatus = "Authorizing Payment...";
  int _shimmerDuration = 0;

  @override
  void initState() {
    super.initState();
    _razorpayService.initialize(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  // CRITICAL FIX: Backend sends wrong endDate (last installment date, not maturity)
  // Correct maturity date = startDate + durationMonths
  DateTime get _correctEndDate {
    final duration = widget.selectedPlan.durationMonths ?? 0;
    if (duration <= 0) return widget.startDate;

    // Weekly plan → duration = number of weeks
    if (widget.planType == AgPlanType.weekly) {
      return widget.startDate.add(Duration(days: duration * 7));
    }

    // Monthly plan
    return DateTime(
      widget.startDate.year,
      widget.startDate.month + duration,
      widget.startDate.day,
    );
  }

  String _formatDuration(int months, AgPlanType planType) {
    if (planType == AgPlanType.weekly) {
      final weeks = months;
      return "$weeks week${weeks == 1 ? '' : 's'}";
    } else {
      return "$months month${months == 1 ? '' : 's'}";
    }
  }

  void _showFriendlySnackBar({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    int duration = 4,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: duration),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;

    setState(() {
      _isProcessing = true;
      _showShimmer = true;
      _processingStatus = "Payment Successful!";
      _shimmerDuration = 0;
    });

    _showFriendlySnackBar(
      message: "Payment successful! Verifying your AG Plan...",
      backgroundColor: AppColors.coinBrown,
      icon: Icons.check_circle,
      duration: 3,
    );

    // Stage 1: Initial processing (3 seconds)
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() {
      _processingStatus = "Verifying Transaction...";
      _shimmerDuration = 3;
    });

    // Stage 2: Razorpay verification (4 seconds)
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    setState(() {
      _processingStatus = "Activating Your Plan...";
      _shimmerDuration = 7;
    });

    // Stage 3: Backend verification (3 seconds)
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    try {
      final agPlanProvider = Provider.of<AgPlanProvider>(
        context,
        listen: false,
      );

      print("🔍 Razorpay Callback Payment ID = ${response.paymentId}");
      print("🔍 Razorpay Callback Signature = ${response.signature}");

      final verified = await agPlanProvider.verifyAgPlanSubscription(
        userId: widget.selectedUserid,
        planId: widget.selectedPlan.id.toString(),
        startDate: widget.startDate,
        subscriptionId: widget.subscriptionId,
        paymentId: response.paymentId ?? '',
        signature: response.signature ?? '',
      );

      print("🔍 Sending to backend → paymentId = ${response.paymentId}");

      if (!mounted) return;

      if (verified) {
  // Add to provider first
  agPlanProvider.addAgPlan(
    plan: widget.selectedPlan,
    startDate: widget.startDate,
    endDate: _correctEndDate,
    planType: widget.planType,
    orderId: '',
    paymentId: response.paymentId ?? '',
    signature: response.signature ?? '',
  );

  // Hide shimmer
  if (mounted) {
    setState(() => _showShimmer = false);
  }

  // Navigate to beautiful success screen
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => PaymentSuccessScreen(
        investedAmount: widget.amount, // or totalInvestment if you want full amount
        planName: widget.selectedPlan.name ?? "AG Plan",
      ),
    ),
  );

  return; // Exit early
} else {
        setState(() => _showShimmer = false);
        _showFriendlySnackBar(
          message:
              "⚠️ Payment verification is taking longer than usual. Your payment will be refunded if the plan isn't activated within 24 hours.",
          backgroundColor: AppColors.primaryRed,
          icon: Icons.warning_amber_rounded,
          duration: 6,
        );
      }
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _showShimmer = false);
      
      _showFriendlySnackBar(
        message:
            "⚠️ Payment received but activation failed. Your amount will be refunded within 5-7 business days. Contact support if needed.",
        backgroundColor: const Color(0xFFD32F2F),
        icon: Icons.error_outline,
        duration: 7,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    
    _showFriendlySnackBar(
      message: "Payment failed: ${response.message ?? 'Please try again'}",
      backgroundColor:AppColors.coinBrown,
      icon: Icons.cancel,
      duration: 5,
    );

    setState(() {
      _isProcessing = false;
      _showShimmer = false;
    });
    Future.delayed(const Duration(seconds: 0), () {
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (_) => MainScreen(selectedIndex: 2),
  ),
  (route) => false,
);

  });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    
    _showFriendlySnackBar(
      message: "💳 ${response.walletName} selected",
      backgroundColor: const Color(0xFF1976D2),
      icon: Icons.account_balance_wallet,
      duration: 3,
    );
  }

  Future<void> _initiatePayment() async {
    if (_isProcessing) return;

    try {
      setState(() => _isProcessing = true);

      await _razorpayService.openCheckout(
        subscriptionId: widget.subscriptionId,
        amount: widget.amount,
        description: 'AG Plan - ${widget.selectedPlan.name}',
      );
    } catch (e, st) {
      if (!mounted) return;
      
      _showFriendlySnackBar(
        message: "Failed to start payment: ${e.toString()}",
        backgroundColor: AppColors.coinBrown,
        icon: Icons.error,
        duration: 5,
      );

      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat("dd-MMM-yyyy");

    return SafeArea(
      top: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFFF5F6F8),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.black,
              size: 24.sp,
            ),
            onPressed: _isProcessing ? null : () => Navigator.pop(context),
          ),
          title: Text(
            "Confirm AG Plan",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              fontSize: 18.sp,
            ),
          ),
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                            image: AssetImage("assets/images/coin_no_bg.png"),
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                            opacity: 0.3,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),

                            // Plan Header Card
                            _whiteCard(
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFB8860B),
                                          Color(0xFFFFD700),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.white,
                                      size: 32.sp,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.selectedPlan.name ?? "AG Plan",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          widget.planType == AgPlanType.weekly
                                              ? "Weekly Plan"
                                              : "Monthly Plan",
                                          style: TextStyle(
                                            color: const Color(0xFFB8860B),
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // Payment Summary - Now with CORRECT End Date
                            _whiteCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Plan Summary",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  Divider(color: Colors.grey, height: 20.h),
                                  _summaryRow(
                                    "Start Date",
                                    dateFmt.format(widget.startDate),
                                  ),
                                  _summaryRow(
                                    "End Date",
                                    dateFmt.format(_correctEndDate),
                                  ), // FIXED
                                  _summaryRow(
                                    widget.planType == AgPlanType.weekly
                                        ? "Weekly Amount"
                                        : "Monthly Amount",
                                    "₹${widget.amount}",
                                  ),
                                  _summaryRow(
                                    "Duration",
                                    _formatDuration(
                                      widget.selectedPlan.durationMonths ?? 0,
                                      widget.planType,
                                    ),
                                  ),
                                  _summaryRow(
                                    "Total Investment",
                                    "₹${widget.selectedPlan.totalInvestment ?? 0}",
                                  ),
                                  Divider(color: Colors.grey, height: 20.h),
                                  _summaryRow(
                                    "Profit Bonus",
                                    "₹${widget.selectedPlan.profitBonus ?? 0}",
                                    valueColor: const Color(0xFF2E7D32),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Maturity Amount:",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "₹${widget.selectedPlan.maturityAmount ?? 0}",
                                        style: TextStyle(
                                          color: const Color(0xFFB8860B),
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // First Payment Card
                            _whiteCard(
                              child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFB8860B).withOpacity(0.1),
                                      const Color(0xFFFFD700).withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFB8860B)
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.payment,
                                          color: const Color(0xFFB8860B),
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          "First Payment:",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "₹${widget.amount}",
                                      style: TextStyle(
                                        color: const Color(0xFFB8860B),
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // Features Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _whiteCard(
                                  width: 160.w,
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/gold-Photoroom.png",
                                        height: 24.h,
                                        width: 24.w,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          "24K \nPurest",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _whiteCard(
                                  width: 160.w,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.lock,
                                        color: AppColors.coinBrown,
                                        size: 24.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          "100% Secured\nand owned vault",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Fixed button at bottom
                  Container(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: CustomButton(
                      text: _isProcessing
                          ? "Processing..."
                          : "Proceed to Pay ₹${widget.amount}",
                      onPressed: _isProcessing ? null : _initiatePayment,
                    ),
                  ),
                ],
              ),
            ),

            // Enhanced Shimmer overlay with progress indicator
            if (_showShimmer)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFF5F6F8),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    period: const Duration(milliseconds: 1200),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),

                            // Header shimmer
                            Row(
                              children: [
                                Container(
                                  width: 56.w,
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 150.w,
                                      height: 18.h,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Container(
                                      width: 100.w,
                                      height: 14.h,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 40.h),

                            // Summary shimmer
                            Container(
                              width: double.infinity,
                              height: 300.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // Payment shimmer
                            Container(
                              width: double.infinity,
                              height: 80.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),

                            const Spacer(),

                            // Center status indicator
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 80.w,
                                        height: 80.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 4,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(
                                            Color(0xFFB8860B),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(16.w),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.lock_clock,
                                          size: 36.sp,
                                          color: const Color(0xFFB8860B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24.w,
                                      vertical: 12.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _processingStatus,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFB8860B),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    "Elapsed: ${_shimmerDuration}s | Please wait...",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFECB3),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 16.sp,
                                          color: const Color(0xFFB8860B),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          "Do not press back or close the app",
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: const Color(0xFF6D4C41),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _whiteCard({required Widget child, double? width}) {
    return Container(
      width: width,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _summaryRow(String left, String right, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: TextStyle(color: Colors.black54, fontSize: 13.sp),
          ),
          Text(
            right,
            style: TextStyle(
              color: valueColor ?? Colors.black87,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
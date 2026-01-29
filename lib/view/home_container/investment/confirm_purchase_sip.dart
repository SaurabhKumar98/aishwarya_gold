import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/data/models/confirm_purchase_sip_model.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/res/widgets/custom_button.dart';
import 'package:aishwarya_gold/view/home_container/investment/purchase_sucess_sip_screen.dart';
import 'package:aishwarya_gold/view_models/invest_provider/inverst_provider.dart';
import 'package:aishwarya_gold/view_models/razorpay_provider/razorpay_service.dart';
import 'package:aishwarya_gold/view_models/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';

class SipConfirmPurchaseScreen extends StatefulWidget {
  final SipPurchaseModel sipPurchase;

  const SipConfirmPurchaseScreen({super.key, required this.sipPurchase});

  @override
  State<SipConfirmPurchaseScreen> createState() =>
      _SipConfirmPurchaseScreenState();
}

class _SipConfirmPurchaseScreenState extends State<SipConfirmPurchaseScreen> {
  final RazorpayService _razorpayService = RazorpayService();
  bool _isProcessing = false;
  bool _showShimmer = false;
  String _processingMessage = "Authorizing Payment...";

  @override
  void initState() {
    super.initState();

    _razorpayService.initialize(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {

    if (!mounted) return;

    setState(() {
      _isProcessing = true;
      _showShimmer = true;
      _processingMessage = "Authorizing Payment...";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Payment successful! Setting up your SIP plan..."),
        backgroundColor: AppColors.coinBrown,
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final investmentProvider =
          Provider.of<InvestmentProvider>(context, listen: false);
      final gstPercentage = investmentProvider.gstPercentage;

      final String userId = userProvider.userId ?? "";
      if (userId.isEmpty) {

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User ID not found. Please login again."),
            backgroundColor: AppColors.primaryRed,
          ),
        );
        setState(() {
          _isProcessing = false;
          _showShimmer = false;
        });
        return;
      }

      final planName =
          "${widget.sipPurchase.planType.toUpperCase()}_${widget.sipPurchase.amount.round()}";
      final startDate = widget.sipPurchase.startDate;

      // Determine frequency from plan type
      String frequencyText = '';
      switch (widget.sipPurchase.planType.toUpperCase()) {

        case 'WEEKLY':
          frequencyText = 'WEEKLY';
          break;
        case 'MONTHLY':
          frequencyText = 'MONTHLY';
          break;
        default:
          frequencyText = 'WEEKLY';
      }

      final double gst = widget.sipPurchase.amount * (gstPercentage / 100);
      final double totalWithGst = widget.sipPurchase.amount + gst;

      // ✅ Reduced retry logic with faster intervals
      bool saved = false;
      int maxRetries = 3;
      int retryCount = 0;

      while (!saved && retryCount < maxRetries) {
        if (!mounted) return;

        // Reduced wait time: 5s, 8s, 12s
        int waitSeconds = 5 + (retryCount * 3);

        if (retryCount > 0) {
          setState(() {
            _processingMessage = "Verifying payment...\n(Attempt ${retryCount + 1}/$maxRetries)";
          });
        }

        await Future.delayed(Duration(seconds: waitSeconds));

        if (!mounted) return;

        try {
          saved = await investmentProvider.SipPlan(
            userId: userId,
            paymentId: response.paymentId ?? '',
            signature: response.signature ?? '',
            planName: planName,
            startDate: startDate,
            investmentAmount: totalWithGst,
            frequency: frequencyText,
          );

          if (saved) {

            break;
          } else {

            retryCount++;

            if (retryCount < maxRetries && mounted) {
              setState(() {
                _processingMessage = "Processing payment...\nPlease wait";
              });
            }
          }
        } catch (e) {

          retryCount++;
        }
      }

      if (!mounted) return;

      if (saved) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PurchaseSuccessSipScreen(
              sipPurchaseModel: widget.sipPurchase,
            ),
          ),
        );
      } else {

        setState(() => _showShimmer = false);

     showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with background
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.schedule,
              size: 48.sp,
              color: Colors.orange[700],
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Title
          Text(
            "Payment Being Processed",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Description
          Text(
            "Your payment was successful, but we're still setting up your SIP plan. This may take a few moments.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Payment ID card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Payment ID",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        response.paymentId ?? 'N/A',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: 'monospace',
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: response.paymentId ?? ''),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, 
                                     color: Colors.white, 
                                     size: 20.sp),
                                SizedBox(width: 8.w),
                                Text("Payment ID copied"),
                              ],
                            ),
                            backgroundColor: AppColors.coinBrown,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w, 
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.coinBrown.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.copy,
                              size: 14.sp,
                              color: AppColors.coinBrown,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "Copy",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.coinBrown,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Info box
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20.sp,
                  color: Colors.blue[700],
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "What happens next?",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[900],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "• Your payment is secure and confirmed\n"
                        "• Your SIP plan will be activated shortly\n"
                        "• Check your investment tab for updates\n"
                        "• Contact support if not activated in 24 hours",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue[800],
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    "Go Back",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    // TODO: Navigate to support/contact screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coinBrown,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    "Contact Support",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
      }
    } catch (e, st) {

      if (!mounted) return;
      setState(() => _showShimmer = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error setting up plan: $e"),
          backgroundColor: AppColors.primaryRed,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment failed: ${response.message ?? 'Unknown error'}"),
        backgroundColor: AppColors.primaryRed,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _isProcessing = false;
      _showShimmer = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External wallet selected: ${response.walletName}"),
        backgroundColor: AppColors.coinBrown,
      ),
    );
  }

  Future<void> openCheckOut(int amount) async {
    if (_isProcessing) {

      return;
    }

    try {
      setState(() => _isProcessing = true);

      final subscriptionId = await SessionManager.getData("razorpaySubscriptionId");

      if (subscriptionId == null || subscriptionId.isEmpty) {

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Subscription ID not found. Please try again."),
            backgroundColor: Colors.red,
          ),
        );

        setState(() => _isProcessing = false);
        return;
      }

      await _razorpayService.openCheckout(
        amount: 0,
        description: 'SIP Investment - ${widget.sipPurchase.planType}',
        subscriptionId: subscriptionId,
      );
    } catch (e, st) {

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error starting payment: $e"),
          backgroundColor: Colors.red,
        ),
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
    final investmentProvider = context.watch<InvestmentProvider>();
    final gstPercentage = investmentProvider.gstPercentage;

    final double gst = widget.sipPurchase.amount * (gstPercentage / 100);
    final double totalWithGst = widget.sipPurchase.amount + gst;

    return SafeArea(
      top: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: AppColors.black, size: 24.sp),
            onPressed: _isProcessing ? null : () => Navigator.pop(context),
          ),
          title: Text(
            "Confirm SIP Payment",
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
              child: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                      image: AssetImage("assets/images/coin_no_bg.png"),
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      opacity: 0.3,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),

                          // Plan Type Card
                          _whiteCard(
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  color: AppColors.backgroundWhite,
                                  child: Image.asset(
                                    "assets/images/gold-Photoroom.png",
                                    height: 50.h,
                                    width: 50.w,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Plan Type",
                                      style: TextStyle(
                                        color: AppColors.dividerGrey,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      widget.sipPurchase.planType,
                                      style: TextStyle(
                                        color: AppColors.coinBrown,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // Payment Summary
                          _whiteCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Payment Summary",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                Divider(color: Colors.grey, height: 20.h),
                                _summaryRow("Plan Started On",
                                    dateFmt.format(widget.sipPurchase.startDate)),
                                _summaryRow("Next Due On",
                                    dateFmt.format(widget.sipPurchase.nextDueDate)),
                                _summaryRow("Amount To Be Paid",
                                    "₹${widget.sipPurchase.accumulated}"),
                                _summaryRow("This Installment",
                                    "₹${widget.sipPurchase.amount}"),
                                _summaryRow("Total GST", "₹${gst.toStringAsFixed(2)}"),
                                Divider(color: Colors.grey, height: 20.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Grand Total:",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "₹${totalWithGst.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: AppColors.coinBrown,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                                        style: TextStyle(color: Colors.black54, fontSize: 12.sp),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _whiteCard(
                                width: 160.w,
                                child: Row(
                                  children: [
                                    Icon(Icons.lock, color: AppColors.coinBrown, size: 24.sp),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        "100% Secured\nand owned vault",
                                        style: TextStyle(color: Colors.black54, fontSize: 12.sp),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Spacer(),

                          // Proceed button
                          CustomButton(
                            text: "Proceed to Pay ₹${totalWithGst.toStringAsFixed(2)}",
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              openCheckOut(totalWithGst.round());
                            },
                          ),

                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            // ✅ Optimized shimmer with faster animation
            if (_showShimmer)
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    period: const Duration(milliseconds: 700), // Reduced from 1500ms
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),

                            // Plan Type Card Shimmer
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50.w,
                                    height: 50.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 70.w,
                                        height: 12.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Container(
                                        width: 100.w,
                                        height: 16.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // Payment Summary Card Shimmer
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 130.w,
                                    height: 16.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  ...List.generate(5, (index) => Padding(
                                    padding: EdgeInsets.only(bottom: 10.h),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 110.w,
                                          height: 12.h,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4.r),
                                          ),
                                        ),
                                        Container(
                                          width: 70.w,
                                          height: 12.h,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4.r),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                  SizedBox(height: 10.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 90.w,
                                        height: 16.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                      ),
                                      Container(
                                        width: 90.w,
                                        height: 18.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // Feature Cards Shimmer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 160.w,
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                Container(
                                  width: 160.w,
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              ],
                            ),

                            Spacer(),

                            // Processing Status Indicator
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(18.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.coinBrown.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.lock_clock,
                                      size: 48.sp,
                                      color: AppColors.coinBrown,
                                    ),
                                  ),
                                  SizedBox(height: 14.h),
                                  Text(
                                    _processingMessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.coinBrown,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    "Please wait, do not press back",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 24.h),

                            // Button Shimmer
                            Container(
                              width: double.infinity,
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
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

  Widget _summaryRow(String left, String right) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: TextStyle(color: Colors.black54, fontSize: 13.sp)),
          Text(
            right,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
// import 'package:aishwarya_gold/data/models/confirm_purchase_sip_model.dart';
// import 'package:aishwarya_gold/res/constants/app_color.dart';
// import 'package:aishwarya_gold/res/widgets/custom_button.dart';
// import 'package:aishwarya_gold/view/home_container/Buttom_bar.dart';
// import 'package:aishwarya_gold/view/home_container/investment/purchase_sucess_sip_screen.dart';
// import 'package:aishwarya_gold/view_models/invest_provider/inverst_provider.dart';
// import 'package:aishwarya_gold/view_models/razorpay_provider/razorpay_service.dart';
// import 'package:aishwarya_gold/view_models/user_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:shimmer/shimmer.dart';

// class SipConfirmPurchaseScreen extends StatefulWidget {
//   final SipPurchaseModel sipPurchase;

//   const SipConfirmPurchaseScreen({super.key, required this.sipPurchase});

//   @override
//   State<SipConfirmPurchaseScreen> createState() =>
//       _SipConfirmPurchaseScreenState();
// }

// class _SipConfirmPurchaseScreenState extends State<SipConfirmPurchaseScreen> {
//   final RazorpayService _razorpayService = RazorpayService();
//   bool _isProcessing = false;
//   bool _showShimmer = false;
//   String _processingMessage = "Authorizing Payment...";

//   @override
//   void initState() {
//     super.initState();

//     _razorpayService.initialize(
//       onSuccess: _handlePaymentSuccess,
//       onError: _handlePaymentError,
//       onExternalWallet: _handleExternalWallet,
//     );
//   }

//   void _showUserFriendlySnackBar(
//     String message, {
//     Color? backgroundColor,
//     Duration? duration,
//   }) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: backgroundColor ?? AppColors.coinBrown,
//         duration: duration ?? const Duration(seconds: 4),
//         behavior: SnackBarBehavior.floating,
//         action: SnackBarAction(
//           label: 'OK',
//           textColor: Colors.white,
//           onPressed: () {
//             ScaffoldMessenger.of(context).hideCurrentSnackBar();
//           },
//         ),
//       ),
//     );
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     if (!mounted) return;

//     setState(() {
//       _isProcessing = true;
//       _showShimmer = true;
//       _processingMessage = "Authorizing Payment...";
//     });

//     _showUserFriendlySnackBar(
//       "✅ Payment successful! Setting up your SIP plan...",
//       backgroundColor: AppColors.coinBrown,
//     );

//     try {
//       final userProvider = Provider.of<UserProvider>(context, listen: false);
//       final investmentProvider = Provider.of<InvestmentProvider>(
//         context,
//         listen: false,
//       );
//       final gstPercentage = investmentProvider.gstPercentage;

//       final String userId = userProvider.userId ?? "";
//       if (userId.isEmpty) {
//         if (!mounted) return;

//         _showUserFriendlySnackBar(
//           "⚠️ Session expired. Please login again.",
//           backgroundColor: AppColors.coinBrown,
//           duration: const Duration(seconds: 5),
//         );

//         setState(() {
//           _isProcessing = false;
//           _showShimmer = false;
//         });

//         // 🔥 FAILED → GO TO MAIN SCREEN
//         Future.delayed(const Duration(seconds: 2), () {
//           if (!mounted) return;
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (_) => MainScreen(selectedIndex: 2)),
//             (route) => false,
//           );
//         });
//         return;
//       }

//       final planName =
//           "${widget.sipPurchase.planType.toUpperCase()}_${widget.sipPurchase.amount.round()}";
//       final startDate = widget.sipPurchase.startDate;

//       String frequencyText =
//           widget.sipPurchase.planType.toUpperCase() == "MONTHLY"
//           ? "MONTHLY"
//           : "WEEKLY";

//       final double gst = widget.sipPurchase.amount * (gstPercentage / 100);
//       final double totalWithGst = widget.sipPurchase.amount + gst;

//       bool saved = false;
//       int maxRetries = 3;
//       int retryCount = 0;

//       // 🔁 RETRY LOOP
//       while (!saved && retryCount < maxRetries) {
//         if (!mounted) return;

//         int waitSeconds = 5 + (retryCount * 3);

//         if (retryCount > 0) {
//           setState(() {
//             _processingMessage =
//                 "Processing payment...\n(Attempt ${retryCount + 1}/$maxRetries)";
//           });

//           _showUserFriendlySnackBar(
//             "⏳ Processing your payment... (Attempt ${retryCount + 1}/$maxRetries)",
//             backgroundColor: AppColors.coinBrown,
//             duration: Duration(seconds: waitSeconds),
//           );
//         }

//         await Future.delayed(Duration(seconds: waitSeconds));

//         if (!mounted) return;

//         try {
//           saved = await investmentProvider.SipPlan(
//             userId: userId,
//             paymentId: response.paymentId ?? '',
//             signature: response.signature ?? '',
//             planName: planName,
//             startDate: startDate,
//             investmentAmount: totalWithGst,
//             frequency: frequencyText,
//           );

//           if (saved) break;
//           retryCount++;
//         } catch (e) {
//           retryCount++;
//         }
//       }

//       if (!mounted) return;

//       // -----------------------------------------------------
//       // 🔥 SUCCESS → GO TO SUCCESS SCREEN
//       // -----------------------------------------------------
//       if (saved) {
//         _showUserFriendlySnackBar(
//           "🎉 SIP plan activated successfully!",
//           backgroundColor: AppColors.coinBrown,
//           duration: const Duration(seconds: 2),
//         );

//         await Future.delayed(const Duration(milliseconds: 500));

//         if (!mounted) return;

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) =>
//                 PurchaseSuccessSipScreen(sipPurchaseModel: widget.sipPurchase),
//           ),
//         );

//         return;
//       }

//       // -----------------------------------------------------
//       // ❌ FAILED / RETRY EXHAUSTED → GO TO MAIN SCREEN
//       // -----------------------------------------------------
//       setState(() => _showShimmer = false);

//       final paymentId = response.paymentId ?? 'N/A';

//       _showUserFriendlySnackBar(
//         "⏳ Payment is being processed.\nPayment ID: $paymentId",
//         backgroundColor: Colors.orange[700],
//         duration: const Duration(seconds: 8),
//       );

//       Clipboard.setData(ClipboardData(text: paymentId));

//       await Future.delayed(const Duration(seconds: 2));

//       if (!mounted) return;

//       _showUserFriendlySnackBar(
//         "📋 Payment ID copied to clipboard",
//         backgroundColor: AppColors.coinBrown,
//         duration: const Duration(seconds: 3),
//       );

//       // 🔥 Navigate to Main Screen
//       Future.delayed(const Duration(seconds: 0), () {
//         if (!mounted) return;

//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => MainScreen(selectedIndex: 2)),
//           (route) => false,
//         );
//       });
//     } catch (e, st) {
//       if (!mounted) return;

//       setState(() => _showShimmer = false);

//       _showUserFriendlySnackBar(
//         "⚠️ Payment done but activation delayed.",
//         backgroundColor: Colors.orange[700],
//         duration: const Duration(seconds: 7),
//       );

//       // ❌ EXCEPTION = FAILURE → Go to Main Screen
//       Future.delayed(const Duration(seconds: 0), () {
//         if (!mounted) return;
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => MainScreen(selectedIndex: 2)),
//           (route) => false,
//         );
//       });
//     } finally {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//       }
//     }
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     if (!mounted) return;

//     final errorMessage = response.message ?? 'Unknown error';

//     _showUserFriendlySnackBar(
//       "❌ Payment failed: $errorMessage\n\nPlease try again or use a different payment method.",
//       backgroundColor: AppColors.primaryRed,
//       duration: const Duration(seconds: 6),
//     );

//     setState(() {
//       _isProcessing = false;
//       _showShimmer = false;
//     });
//     Future.delayed(const Duration(seconds: 0), () {
//       if (!mounted) return;

//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => MainScreen(selectedIndex: 2)),
//         (route) => false,
//       );
//     });
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     if (!mounted) return;

//     _showUserFriendlySnackBar(
//       "💳 ${response.walletName} selected. Complete payment in the wallet app.",
//       backgroundColor: AppColors.coinBrown,
//     );
//   }

//   Future<void> openCheckOut(int amount) async {
//     if (_isProcessing) {
//       _showUserFriendlySnackBar(
//         "⏳ Payment is already in progress. Please wait...",
//         backgroundColor: Colors.orange,
//       );
//       return;
//     }

//     try {
//       setState(() => _isProcessing = true);

//       final subscriptionId = await SessionManager.getData(
//         "razorpaySubscriptionId",
//       );

//       if (subscriptionId == null || subscriptionId.isEmpty) {
//         if (!mounted) return;

//         _showUserFriendlySnackBar(
//           "⚠️ Unable to start payment. Please go back and try again.",
//           backgroundColor: AppColors.primaryRed,
//           duration: const Duration(seconds: 5),
//         );

//         setState(() => _isProcessing = false);
//         return;
//       }

//       await _razorpayService.openCheckout(
//         amount: 0,
//         description: 'SIP Investment - ${widget.sipPurchase.planType}',
//         subscriptionId: subscriptionId,
//       );
//     } catch (e, st) {
//       if (!mounted) return;

//       _showUserFriendlySnackBar(
//         "⚠️ Error starting payment. Please check your internet connection and try again.",
//         backgroundColor: AppColors.primaryRed,
//         duration: const Duration(seconds: 5),
//       );

//       setState(() => _isProcessing = false);
//     }
//   }

//   @override
//   void dispose() {
//     _razorpayService.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dateFmt = DateFormat("dd-MMM-yyyy");
//     final investmentProvider = context.watch<InvestmentProvider>();
//     final gstPercentage = investmentProvider.gstPercentage;

//     final double gst = widget.sipPurchase.amount * (gstPercentage / 100);
//     final double totalWithGst = widget.sipPurchase.amount + gst;

//     return SafeArea(
//       top: false,
//       child: Scaffold(
//         extendBodyBehindAppBar: true,
//         backgroundColor: AppColors.backgroundWhite,
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           leading: IconButton(
//             icon: Icon(
//               Icons.arrow_back_ios,
//               color: AppColors.black,
//               size: 24.sp,
//             ),
//             onPressed: _isProcessing ? null : () => Navigator.pop(context),
//           ),
//           title: Text(
//             "Confirm SIP Payment",
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               color: AppColors.black,
//               fontSize: 18.sp,
//             ),
//           ),
//         ),
//         body: Stack(
//           children: [
//             SafeArea(
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   return Container(
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       image: DecorationImage(
//                         image: AssetImage("assets/images/coin_no_bg.png"),
//                         alignment: Alignment.center,
//                         fit: BoxFit.contain,
//                         opacity: 0.3,
//                       ),
//                     ),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 16.w,
//                       vertical: 16.h,
//                     ),
//                     child: ConstrainedBox(
//                       constraints: BoxConstraints(
//                         minHeight: constraints.maxHeight,
//                       ),
//                       child: IntrinsicHeight(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(height: 20.h),

//                             // Plan Type Card
//                             _whiteCard(
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.all(8.w),
//                                     color: AppColors.backgroundWhite,
//                                     child: Image.asset(
//                                       "assets/images/gold-Photoroom.png",
//                                       height: 50.h,
//                                       width: 50.w,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                   SizedBox(width: 16.w),
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Plan Type",
//                                         style: TextStyle(
//                                           color: AppColors.dividerGrey,
//                                           fontSize: 14.sp,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       SizedBox(height: 6.h),
//                                       Text(
//                                         widget.sipPurchase.planType,
//                                         style: TextStyle(
//                                           color: AppColors.coinBrown,
//                                           fontSize: 16.sp,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             SizedBox(height: 20.h),

//                             // Payment Summary
//                             _whiteCard(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Payment Summary",
//                                     style: TextStyle(
//                                       color: Colors.black87,
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 16.sp,
//                                     ),
//                                   ),
//                                   Divider(color: Colors.grey, height: 20.h),
//                                   _summaryRow(
//                                     "Plan Started On",
//                                     dateFmt.format(
//                                       widget.sipPurchase.startDate,
//                                     ),
//                                   ),
//                                   _summaryRow(
//                                     "Next Due On",
//                                     dateFmt.format(
//                                       widget.sipPurchase.nextDueDate,
//                                     ),
//                                   ),
//                                   _summaryRow(
//                                     "Amount To Be Paid",
//                                     "₹${widget.sipPurchase.accumulated}",
//                                   ),
//                                   _summaryRow(
//                                     "This Installment",
//                                     "₹${widget.sipPurchase.amount}",
//                                   ),
//                                   _summaryRow(
//                                     "Total GST",
//                                     "₹${gst.toStringAsFixed(2)}",
//                                   ),
//                                   Divider(color: Colors.grey, height: 20.h),
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         "Grand Total:",
//                                         style: TextStyle(
//                                           color: Colors.black87,
//                                           fontSize: 15.sp,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       Text(
//                                         "₹${totalWithGst.toStringAsFixed(2)}",
//                                         style: TextStyle(
//                                           color: AppColors.coinBrown,
//                                           fontSize: 16.sp,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             SizedBox(height: 20.h),

//                             // Features Row
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 _whiteCard(
//                                   width: 160.w,
//                                   child: Row(
//                                     children: [
//                                       Image.asset(
//                                         "assets/images/gold-Photoroom.png",
//                                         height: 24.h,
//                                         width: 24.w,
//                                       ),
//                                       SizedBox(width: 8.w),
//                                       Expanded(
//                                         child: Text(
//                                           "24K \nPurest",
//                                           style: TextStyle(
//                                             color: Colors.black54,
//                                             fontSize: 12.sp,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 _whiteCard(
//                                   width: 160.w,
//                                   child: Row(
//                                     children: [
//                                       Icon(
//                                         Icons.lock,
//                                         color: AppColors.coinBrown,
//                                         size: 24.sp,
//                                       ),
//                                       SizedBox(width: 8.w),
//                                       Expanded(
//                                         child: Text(
//                                           "100% Secured\nand owned vault",
//                                           style: TextStyle(
//                                             color: Colors.black54,
//                                             fontSize: 12.sp,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             Spacer(),

//                             // Proceed button
//                             CustomButton(
//                               text:
//                                   "Proceed to Pay ₹${totalWithGst.toStringAsFixed(2)}",
//                               onPressed: () {
//                                 FocusManager.instance.primaryFocus?.unfocus();
//                                 openCheckOut(totalWithGst.round());
//                               },
//                             ),

//                             SizedBox(height: 20.h),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // Optimized shimmer with processing message
//             if (_showShimmer)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.white,
//                   child: Shimmer.fromColors(
//                     baseColor: Colors.grey[300]!,
//                     highlightColor: Colors.grey[100]!,
//                     period: const Duration(milliseconds: 700),
//                     child: SafeArea(
//                       child: Padding(
//                         padding: EdgeInsets.all(16.w),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(height: 20.h),

//                             // Plan Type Card Shimmer
//                             Container(
//                               width: double.infinity,
//                               padding: EdgeInsets.all(16.w),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12.r),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     width: 50.w,
//                                     height: 50.h,
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(8.r),
//                                     ),
//                                   ),
//                                   SizedBox(width: 16.w),
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Container(
//                                         width: 70.w,
//                                         height: 12.h,
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(
//                                             4.r,
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(height: 8.h),
//                                       Container(
//                                         width: 100.w,
//                                         height: 16.h,
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(
//                                             4.r,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             SizedBox(height: 20.h),

//                             // Payment Summary Card Shimmer
//                             Container(
//                               width: double.infinity,
//                               padding: EdgeInsets.all(16.w),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12.r),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     width: 130.w,
//                                     height: 16.h,
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(4.r),
//                                     ),
//                                   ),
//                                   SizedBox(height: 16.h),
//                                   ...List.generate(
//                                     5,
//                                     (index) => Padding(
//                                       padding: EdgeInsets.only(bottom: 10.h),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Container(
//                                             width: 110.w,
//                                             height: 12.h,
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(4.r),
//                                             ),
//                                           ),
//                                           Container(
//                                             width: 70.w,
//                                             height: 12.h,
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(4.r),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(height: 10.h),
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Container(
//                                         width: 90.w,
//                                         height: 16.h,
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(
//                                             4.r,
//                                           ),
//                                         ),
//                                       ),
//                                       Container(
//                                         width: 90.w,
//                                         height: 18.h,
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(
//                                             4.r,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             SizedBox(height: 20.h),

//                             // Feature Cards Shimmer
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Container(
//                                   width: 160.w,
//                                   height: 56.h,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12.r),
//                                   ),
//                                 ),
//                                 Container(
//                                   width: 160.w,
//                                   height: 56.h,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12.r),
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             Spacer(),

//                             // Processing Status Indicator
//                             Center(
//                               child: Column(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.all(18.w),
//                                     decoration: BoxDecoration(
//                                       color: AppColors.coinBrown.withOpacity(
//                                         0.1,
//                                       ),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: Icon(
//                                       Icons.lock_clock,
//                                       size: 48.sp,
//                                       color: AppColors.coinBrown,
//                                     ),
//                                   ),
//                                   SizedBox(height: 14.h),
//                                   Text(
//                                     _processingMessage,
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       fontSize: 16.sp,
//                                       fontWeight: FontWeight.w600,
//                                       color: AppColors.coinBrown,
//                                     ),
//                                   ),
//                                   SizedBox(height: 6.h),
//                                   Text(
//                                     "Please wait, do not press back",
//                                     style: TextStyle(
//                                       fontSize: 12.sp,
//                                       color: Colors.grey[600],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             SizedBox(height: 24.h),

//                             // Button Shimmer
//                             Container(
//                               width: double.infinity,
//                               height: 48.h,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(8.r),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _whiteCard({required Widget child, double? width}) {
//     return Container(
//       width: width,
//       padding: EdgeInsets.all(16.w),
//       margin: EdgeInsets.only(bottom: 12.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }

//   Widget _summaryRow(String left, String right) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 6.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             left,
//             style: TextStyle(color: Colors.black54, fontSize: 13.sp),
//           ),
//           Text(
//             right,
//             style: TextStyle(
//               color: Colors.black87,
//               fontSize: 13.sp,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

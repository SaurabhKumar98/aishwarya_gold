import 'package:aishwarya_gold/core/session/navkey.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aishwarya_gold/data/models/onetimesavingmodels/onetimebyidmodels.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class OneTimeTransactionDetailScreen extends StatelessWidget {
  final OneTimeData planData;
  final bool isLoading;

  const OneTimeTransactionDetailScreen({
    super.key,
    required this.planData,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: AppColors.white,
          leading: IconButton(
            icon: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.arrow_back, color: Colors.black87, size: 18.sp),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Transaction Details",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 20.sp),
          ),
          centerTitle: true,
        ),
        body: _buildShimmerBody(),
      );
    }

    final df = DateFormat('dd MMM yyyy');
    final subtotal = (planData.totalAmountToPay ?? 0) - (planData.gstAmount ?? 0);
    final goldPricePerGram = planData.currentDayGoldPrice ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.arrow_back, color: Colors.black87, size: 18.sp),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Transaction Details",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 20.sp),
        ),
        centerTitle: true,
        surfaceTintColor: AppColors.backgroundWhite,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        children: [
          // Hero Amount Card
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16.r, offset: Offset(0, 6.h)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: _getStatusColor(planData.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(_getStatusIcon(planData.status), color: _getStatusColor(planData.status), size: 18.sp),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _getStatusText(planData.status),
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _getStatusColor(planData.status)),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                FittedBox(
                  child: Text(
                    "₹${(planData.totalAmountToPay ?? 0).toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 38.sp, fontWeight: FontWeight.w800, color: AppColors.primaryGold),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  planData.createdAt != null ? df.format(planData.createdAt!) : "N/A",
                  style: TextStyle(fontSize: 15.sp, color: Colors.black54, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h), // Reduced gap

          // Details Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12.r, offset: Offset(0, 4.h)),
              ],
            ),
            child: Column(
              children: [
                _enhancedDetailRow("Gold Weight", "${planData.goldQty ?? 0} g", isFirst: true),
                _enhancedDetailRow("Gold Price/Gram", "₹$goldPricePerGram"),
                _enhancedDetailRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),
                _enhancedDetailRow("GST", "₹${(planData.gstAmount ?? 0).toStringAsFixed(2)}"),
                if (planData.discountAmount != null && planData.discountAmount! > 0)
                  _enhancedDetailRow("Discount", "- ₹${planData.discountAmount!.toStringAsFixed(2)}"),
                Divider(height: 1.h, color: Colors.grey.shade200),
                _enhancedDetailRow("Investment ID", planData.customInvestmentId ?? "N/A", showCopy: true),
                if (planData.razorpayPaymentId != null && planData.razorpayPaymentId!.isNotEmpty)
                  _enhancedDetailRow("Payment ID", planData.razorpayPaymentId!, showCopy: true),
                _enhancedDetailRow("Payment Status", planData.paymentStatus ?? "N/A", isLast: true),
              ],
            ),
          ),

          SizedBox(height: 12.h), // Reduced gap

          // Uncomment if needed later
          // if (planData.userId != null)
          //   Container(
          //     padding: EdgeInsets.all(16.w),
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(16.r),
          //       boxShadow: [
          //         BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12.r, offset: Offset(0, 4.h)),
          //       ],
          //     ),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text("User Information", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
          //         SizedBox(height: 10.h),
          //         Row(
          //           children: [
          //             Icon(Icons.person_outline, size: 18.sp, color: Colors.grey[600]),
          //             SizedBox(width: 6.w),
          //             Flexible(
          //               child: Text(
          //                 planData.userId?.name ?? planData.username ?? "N/A",
          //                 style: TextStyle(fontSize: 14.sp, color: Colors.black87, fontWeight: FontWeight.w500),
          //                 overflow: TextOverflow.ellipsis,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
        ],
      ),
    );
  }

  // Shimmer Body
  Widget _buildShimmerBody() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      children: [
        // Hero Card Shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 140.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // Details Card Shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 220.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      ],
    );
  }

  // Enhanced Detail Row with Copy
  Widget _enhancedDetailRow(String title, String value,
      {bool isFirst = false, bool isLast = false, bool showCopy = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 18.w),
      decoration: BoxDecoration(
        color: isFirst ? Colors.grey.shade50 : null,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? Radius.circular(16.r) : Radius.zero,
          bottom: isLast ? Radius.circular(16.r) : Radius.zero,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyle(fontSize: 13.5.sp, color: Colors.black54, fontWeight: FontWeight.w500),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showCopy) ...[
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value)).then((_) {
                      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                        SnackBar(
                          content: Text("Copied: $value"),
                          duration: const Duration(seconds: 1),
                          backgroundColor: Colors.blue.shade600,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(16.w),
                        ),
                      );
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(Icons.copy_outlined, size: 14.sp, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Status Helpers
  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'COMPLETED':
        return AppColors.coinBrown;
      case 'PENDING':
        return Colors.orange.shade600;
      case 'FAILED':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'COMPLETED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.pending;
      case 'FAILED':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toUpperCase()) {
      case 'COMPLETED':
        return "Transaction Complete";
      case 'PENDING':
        return "Transaction Pending";
      case 'FAILED':
        return "Transaction Failed";
      default:
        return "Transaction Status";
    }
  }
}
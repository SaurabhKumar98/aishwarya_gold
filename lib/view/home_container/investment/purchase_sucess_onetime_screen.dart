import 'package:aishwarya_gold/data/models/purchase_models.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/res/widgets/custom_button.dart';
import 'package:aishwarya_gold/view/home_container/Buttom_bar.dart';
import 'package:aishwarya_gold/view/home_container/histroy_screen/history_screen.dart';
import 'package:aishwarya_gold/view_models/history_screen_provider/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PurchaseSuccessScreen extends StatefulWidget {
  final PurchaseModel purchase;

  const PurchaseSuccessScreen({super.key, required this.purchase});

  @override
  State<PurchaseSuccessScreen> createState() => _PurchaseSuccessScreenState();
}

class _PurchaseSuccessScreenState extends State<PurchaseSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<HistoryProvider>(context, listen: false)
    //       .addOneTimePurchase(widget.purchase);
    // });
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _mainController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEE, dd MMM yyyy');
    final priceStr = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(widget.purchase.goldPricePerGram);

    return SafeArea(
      top: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8F8F8), Colors.white],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                children: [
                  // Success Icon with Animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        margin: EdgeInsets.only(top: 40.h, bottom: 30.h),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow effect
                            Container(
                              width: 120.w,
                              height: 120.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.coinBrown.withOpacity(0.2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            // Main circle
                            Container(
                              width: 100.w,
                              height: 100.w,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Color(0xFFF8F8F8), Colors.white],
                                ),
                              ),
                              child: Image.asset(
                                'assets/images/gold-Photoroom.png',
                                width: 60.sp,
                                height: 60.sp,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Success Message
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          "Purchase Successful!",
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.coinBrown,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "You have successfully purchased\n${double.tryParse(widget.purchase.goldWeight.toString())?.toStringAsFixed(4) ?? '0.0000'}g of gold",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Purchase Details Card
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  color: AppColors.coinBrown,
                                  size: 24.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  "Purchase Details",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.coinBrown,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),

                            // Details Grid
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailItem(
                                    "Gold Price",
                                    "$priceStr/g",
                                    Icons.trending_up,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: _buildDetailItem(
                                    "Gold Weight",
                                    "${double.tryParse(widget.purchase.goldWeight.toString())?.toStringAsFixed(4) ?? '0.0000'} grams",
                                    Icons.scale,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20.h),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailItem(
                                    "Subtotal",
                                    NumberFormat.currency(
                                      locale: 'en_IN',
                                      symbol: '₹',
                                      decimalDigits: 2,
                                    ).format(widget.purchase.subtotal),
                                    Icons.account_balance_wallet,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: _buildDetailItem(
                                    "GST",
                                    NumberFormat.currency(
                                      locale: 'en_IN',
                                      symbol: '₹',
                                      decimalDigits: 2,
                                    ).format(widget.purchase.tax),
                                    Icons.receipt,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20.h),

                            // Total Amount
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F8F8),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.coinBrown.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total Amount",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.coinBrown,
                                    ),
                                  ),
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'en_IN',
                                      symbol: '₹',
                                      decimalDigits: 2,
                                    ).format(
                                      widget.purchase.subtotal ,
                                          // widget.purchase.tax,
                                    ),
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.coinBrown,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Order Information Card
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Expanded(
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       Text(
                            //         "Transaction Id",
                            //         style: TextStyle(
                            //           color: Colors.grey,
                            //           fontSize: 12.sp,
                            //           fontWeight: FontWeight.w500,
                            //         ),
                            //       ),
                            //       SizedBox(height: 6.h),
                            //       Text(
                            //         widget.purchase.orderId,
                            //         style: TextStyle(
                            //           color: Colors.black87,
                            //           fontWeight: FontWeight.w700,
                            //           fontSize: 14.sp,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          
                          
                            Container(
                              width: 1.w,
                              height: 40.h,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Date",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    df.format(widget.purchase.date),
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Action Buttons
                  // FadeTransition(
                  //   opacity: _fadeAnimation,
                  //   child: Column(
                  //     children: [
                  //       _buildActionButton(
                  //         text: "Order History",
                  //         icon: Icons.history,
                  //         onPressed: () => Navigator.push(
                  //           context,
                  //           MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  //         ),
                  //         isPrimary: true,
                  //       ),
                  //       SizedBox(height: 16.h),
                  //       _buildActionButton(
                  //         text: "Download Invoice",
                  //         icon: Icons.download,
                  //         onPressed: () {},
                  //         isPrimary: false,
                  //       ),
                  //       SizedBox(height: 16.h),
                  //       _buildActionButton(
                  //         text: "Back to Home",
                  //         icon: Icons.home,
                  //         onPressed: () => Navigator.pushAndRemoveUntil(
                  //           context,
                  //           MaterialPageRoute(builder: (_) => const MainScreen()),
                  //           (route) => false,
                  //         ),
                  //         isPrimary: false,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // CustomButton(
                        //   text: "Order History",
                        //   onPressed: () => Navigator.push(
                        //     context,
                        //     MaterialPageRoute(builder: (_) => const HistoryScreen()),
                        //   ),
                        // ),
                        // SizedBox(height: 16.h),
                        // CustomButton(
                        //   text: "Download Invoice",
                        //   onPressed: () {},
                        // ),
                        // SizedBox(height: 16.h),
                        CustomButton(
                          text: "Back to Home",
                          onPressed: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(),
                            ),
                            (route) => false,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: const Color(0xFFC79248)),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildActionButton({
  //   required String text,
  //   required IconData icon,
  //   required VoidCallback onPressed,
  //   required bool isPrimary,
  // }) {
  //   return Container(
  //     width: double.infinity,
  //     height: 55.h,
  //     child: ElevatedButton(
  //       onPressed: onPressed,
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: isPrimary ? const Color(0xFFC79248) : Colors.white,
  //         foregroundColor: isPrimary ? Colors.white : const Color(0xFFC79248),
  //         elevation: isPrimary ? 8 : 2,
  //         shadowColor: isPrimary
  //             ? const Color(0xFFC79248).withOpacity(0.3)
  //             : Colors.black.withOpacity(0.1),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16.r),
  //           side: isPrimary
  //               ? BorderSide.none
  //               : BorderSide(color: const Color(0xFFC79248), width: 1.5),
  //         ),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(icon, size: 20.sp),
  //           SizedBox(width: 12.w),
  //           Text(
  //             text,
  //             style: TextStyle(
  //               fontSize: 16.sp,
  //               fontWeight: FontWeight.w600,
  //               letterSpacing: 0.5,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

// Placeholder classes - replace with your actual models and screens

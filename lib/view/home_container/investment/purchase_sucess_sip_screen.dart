import 'package:aishwarya_gold/data/models/confirm_purchase_sip_model.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/res/widgets/custom_button.dart';
import 'package:aishwarya_gold/view/home_container/Buttom_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 🎉 SIP Purchase Success Screen
/// Shows after successful mandate payment and plan verification
/// User sees confirmation that their SIP plan is set up and will start on schedule
class PurchaseSuccessSipScreen extends StatefulWidget {
  final SipPurchaseModel sipPurchaseModel;

  const PurchaseSuccessSipScreen({super.key, required this.sipPurchaseModel});

  @override
  State<PurchaseSuccessSipScreen> createState() =>
      _PurchaseSuccessSipScreenState();
}

class _PurchaseSuccessSipScreenState extends State<PurchaseSuccessSipScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // 🎬 Setup animations for smooth entrance effects
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 🌟 Fade in animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    // 📏 Scale animation for icon
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    // 📍 Slide animation for card
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    // 🚀 Start animations
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
    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  // ✅ Success Icon with Animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        margin: const EdgeInsets.only(top: 40, bottom: 30),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 🌟 Outer glow effect
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.amber.withOpacity(0.2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            // 🪙 Gold coin icon
                            Container(
                              width: 100,
                              height: 100,
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
                                width: 60,
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 🎉 Success Message with Mandate Info
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const Text(
                          "SIP Setup Successful!",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.coinBrown,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 📝 Detailed success message explaining the mandate flow
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              const TextSpan(
                                text: "Mandate setup successful! Your ",
                              ),
                              TextSpan(
                                text: widget.sipPurchaseModel.planType,
                                style: const TextStyle(
                                  color: AppColors.coinBrown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: " SIP of ₹"),
                              TextSpan(
                                text: widget.sipPurchaseModel.amount
                                    .toStringAsFixed(2),
                                style: const TextStyle(
                                  color: AppColors.coinBrown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: " will start on the scheduled date. "
                                    "First installment will be auto-debited.",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 📋 SIP Details Card
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
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
                            const Text(
                              "SIP Details",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.coinBrown,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 📊 Details Grid - Row 1
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailItem(
                                    "Plan Type",
                                    widget.sipPurchaseModel.planType,
                                    Icons.auto_graph,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDetailItem(
                                    "Installment",
                                    currency.format(
                                      widget.sipPurchaseModel.amount,
                                    ),
                                    Icons.payment,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // 📊 Details Grid - Row 2
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailItem(
                                    "Start Date",
                                    df.format(
                                      widget.sipPurchaseModel.startDate,
                                    ),
                                    Icons.calendar_today,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDetailItem(
                                    "Next Due",
                                    df.format(
                                      widget.sipPurchaseModel.nextDueDate,
                                    ),
                                    Icons.update,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // 💰 Accumulated amount detail
                            _buildDetailItem(
                              "Accumulated Amount",
                              currency.format(
                                widget.sipPurchaseModel.accumulated,
                              ),
                              Icons.account_balance_wallet,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // ℹ️ Important mandate info box
                            // Container(
                            //   padding: const EdgeInsets.all(16),
                            //   decoration: BoxDecoration(
                            //     color: Colors.green.shade50,
                            //     borderRadius: BorderRadius.circular(12),
                            //     border: Border.all(color: Colors.green.shade200),
                            //   ),
                            //   child: Row(
                            //     children: [
                            //       Icon(
                            //         Icons.check_circle_outline,
                            //         color: Colors.green.shade700,
                            //         size: 24,
                            //       ),
                            //       const SizedBox(width: 12),
                            //       Expanded(
                            //         child: Column(
                            //           crossAxisAlignment: CrossAxisAlignment.start,
                            //           children: [
                            //             Text(
                            //               "Mandate Activated",
                            //               style: TextStyle(
                            //                 color: Colors.green.shade900,
                            //                 fontWeight: FontWeight.bold,
                            //                 fontSize: 14,
                            //               ),
                            //             ),
                            //             const SizedBox(height: 4),
                            //             Text(
                            //               "₹5 mandate fee paid successfully. "
                            //               "Your installments will be auto-debited as per schedule.",
                            //               style: TextStyle(
                            //                 color: Colors.green.shade800,
                            //                 fontSize: 12,
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                         
                         
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🏠 Back to Home Button
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: CustomButton(
                      text: "Back to Home",
                      onPressed: () {
                        // 🔄 Navigate back to home and clear navigation stack
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainScreen()),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🎨 Build individual detail item widget
  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📌 Label with icon
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFFC79248)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 💬 Value
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
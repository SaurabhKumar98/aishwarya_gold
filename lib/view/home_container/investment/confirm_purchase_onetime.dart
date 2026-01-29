import 'package:aishwarya_gold/data/models/confirm_purchase_onetime_models.dart';
import 'package:aishwarya_gold/data/models/purchase_models.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/res/widgets/custom_button.dart';
import 'package:aishwarya_gold/view/home_container/investment/purchase_sucess_onetime_screen.dart';
import 'package:aishwarya_gold/view_models/invest_provider/inverst_provider.dart';
import 'package:aishwarya_gold/view_models/razorpay_provider/razorpay_service.dart';
import 'package:aishwarya_gold/view_models/razorpay_provider/razorpay_serviceonetime.dart';
import 'package:aishwarya_gold/view_models/redeemcode_provider/cancelredeemcodeprovider.dart';
import 'package:aishwarya_gold/view_models/redeemcode_provider/redeem_code_provider.dart';
import 'package:aishwarya_gold/view_models/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ConfirmPurchaseScreen extends StatefulWidget {
  final ConfirmPurchaseModel purchase;

  const ConfirmPurchaseScreen({
    Key? key,
    required this.purchase,
  }) : super(key: key);

  @override
  State<ConfirmPurchaseScreen> createState() => _ConfirmPurchaseScreenState();
}

class _ConfirmPurchaseScreenState extends State<ConfirmPurchaseScreen> {
  final TextEditingController _redeemController = TextEditingController();
  final RazorpayServiceOneTime _razorpayService = RazorpayServiceOneTime();
  
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
   
    
    _razorpayService.initialize(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final redeemProvider = Provider.of<RedeemCodeProvider>(context, listen: false);
      redeemProvider.clearRedeemState();
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;

    _updateProcessingState(true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Payment successful! Processing your order..."),
        backgroundColor: AppColors.coinBrown,
      ),
    );

    try {
      final investmentProvider = Provider.of<InvestmentProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final redeemProvider = Provider.of<RedeemCodeProvider>(context, listen: false);
      final userId = userProvider.userId ?? "";

      if (userId.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User ID not found. Please login again."),
            backgroundColor: AppColors.primaryRed,
          ),
        );
        _updateProcessingState(false);
        return;
      }

      final discount = _getDiscountAmount(redeemProvider);
      final goldQty = widget.purchase.goldWeight;
      final totalAmountToPay = widget.purchase.subtotal + widget.purchase.gst;
      final gstAmount = widget.purchase.gst;
      final amountPaid = widget.purchase.subtotal + widget.purchase.gst - discount;
      final currentDayGoldPrice = widget.purchase.goldPricePerGram;
      final redeemCode = _redeemController.text.trim().isEmpty
          ? "N/A"
          : _redeemController.text.trim().toUpperCase();

      bool success = await investmentProvider.buyOneTimeInvestment(
        userId: userId,
        orderId: response.orderId ?? '',
        paymentId: response.paymentId ?? '',
        signature: response.signature ?? '',
        goldQty: double.tryParse(goldQty) ?? 0.0,
        totalAmountToPay: totalAmountToPay,
        gstAmount: gstAmount,
        discountAmount: discount,
        amountPaid: amountPaid,
        currentDayGoldPrice: currentDayGoldPrice,
        redeemCode: redeemCode,
      );

      if (!mounted) return;

      if (success) {
        redeemProvider.clearRedeemState();
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PurchaseSuccessScreen(
              purchase: PurchaseModel(
                goldWeight: goldQty,
                goldPricePerGram: currentDayGoldPrice,
                subtotal: totalAmountToPay,
                tax: gstAmount,
                orderId: 'AG${DateTime.now().millisecondsSinceEpoch}',
                date: DateTime.now(),
              ),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ Payment successful but order processing failed. Please contact support."),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e, st) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error processing order: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        _updateProcessingState(false);
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

    _updateProcessingState(false);
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
      _updateProcessingState(true);

      await _razorpayService.openCheckout(
        amount: amount,
        description: 'Gold Purchase - OneTime',
      );
    } catch (e, st) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error starting payment: $e"),
          backgroundColor: Colors.red,
        ),
      );
      _updateProcessingState(false);
    }
  }

  void _updateProcessingState(bool isProcessing) {
    if (mounted) {
      setState(() {
        _isProcessing = isProcessing;
      });
    }
  }

  double _getDiscountAmount(RedeemCodeProvider redeemProvider) {
  if (redeemProvider.redeemResponse?.success != true) {
    return 0.0;
  }

  final data = redeemProvider.redeemResponse?.data;
  if (data == null) return 0.0;


   if (data.codeType == 'referral' && data.referralRedeemed == true) {
    return (data.referralAmount ?? 0).toDouble();
  }

  // If gift redeemed → return gift value
  if (data.giftRedeemed && data.giftValue != null) {
    return data.giftValue!.toDouble();
  }
  

  // Directly return discount value WITHOUT checking flat / percentage
  final discount = data.promoCodeResult?.discount?.value;
  if (discount == null) return 0.0;

  return discount.toDouble();
}

  
  
  double _calculateGrandTotal(RedeemCodeProvider redeemProvider) {
    final discount = _getDiscountAmount(redeemProvider);
    final total = widget.purchase.subtotal + widget.purchase.gst - discount;
    final grandTotal = (total < 0 ? 0.0 : total).toDouble();
    return grandTotal;
  }

  Future<void> _applyRedeemCode(String code) async {
    if (code.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Text("Please enter a redeem code", style: TextStyle(color: Colors.white)),
            ],
          ),
          backgroundColor: AppColors.coinBrown,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final redeemProvider = Provider.of<RedeemCodeProvider>(context, listen: false);
    await redeemProvider.redeemCode(code.trim());

    if (!mounted) return;

    final response = redeemProvider.redeemResponse;
    final error = redeemProvider.errorMessage;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Error: $error",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

   final discount = _getDiscountAmount(redeemProvider);
String message;

if (response?.data?.codeType == 'gift') {
  message = response?.data?.giftMessage ?? 'Gift code applied!';
  if (discount > 0) {
    message += ' Worth ₹${discount.toStringAsFixed(0)}';
  }

} else if (response?.data?.codeType == 'referral') {
  message = response?.data?.message ?? 'Referral redeemed successfully!';
  if (discount > 0) {
    message += ' ₹${discount.toStringAsFixed(0)} added to wallet';
  }

} else {
  message =
      response?.data?.promoCodeResult?.message ?? 'Promo code applied!';
  if (discount > 0) {
    message += ' Discount ₹${discount.toStringAsFixed(0)}';
  }
}

    
     {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.cancel, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  response?.message ?? "Invalid redeem code",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.coinBrown,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  
  
  // MODIFIED: Now calls the cancel gift API
Future<void> _removeRedeemCode() async {
  final redeemProvider =
      Provider.of<RedeemCodeProvider>(context, listen: false);
  final giftCancelProvider =
      Provider.of<GiftCancelProvider>(context, listen: false);
  final userProvider = Provider.of<UserProvider>(context, listen: false);

  final code = _redeemController.text.trim().toUpperCase();

  if (code.isEmpty) {
    return;
  }

  final token = userProvider.accessToken ?? "";

  if (token.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 12),
            Text(
              "Session expired. Please login again.",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    return;
  }

  // 🔥 SAME cancel API for Gift / Promo / Referral
  await giftCancelProvider.cancelGift(
    token: token,
    code: code,
  );

  if (!mounted) return;

  final response = giftCancelProvider.response;
  final error = giftCancelProvider.errorMessage;

  if (response?.success == true &&
      response?.data?.cancelled == true) {
    // ✅ Clear redeem state
    redeemProvider.clearRedeemState();
    _redeemController.clear();

    String successMessage;

    switch (response?.data?.codeType) {
      case 'gift':
        successMessage = "Gift code cancelled successfully";
        break;
      case 'referral':
        successMessage =
            "Referral redemption cancelled & balance restored";
        break;
      case 'promo':
        successMessage = "Promo code removed successfully";
        break;
      default:
        successMessage = "Redeem code removed successfully";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                successMessage,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error ??
                    response?.message ??
                    "Failed to cancel redeem code",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

  @override
  void dispose() {
    _redeemController.dispose();
    _razorpayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Confirm Purchase",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              fontSize: 18,
            ),
          ),
          centerTitle: false,
        ),
        body: Consumer2<RedeemCodeProvider, GiftCancelProvider>(
          builder: (context, redeemProvider, giftCancelProvider, child) {
            final grandTotal = _calculateGrandTotal(redeemProvider);
            final discountAmount = _getDiscountAmount(redeemProvider);
            final hasActiveCode = redeemProvider.hasActiveCode;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: kToolbarHeight + 20),

                  // Gold weight container
                  const SizedBox(height: 40),
                  _whiteCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: AppColors.backgroundWhite,
                          child: Image.asset(
                            "assets/images/gold-Photoroom.png",
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Gold Weight",
                              style: TextStyle(
                                color: AppColors.dividerGrey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${widget.purchase.goldWeight} /g",
                              style: const TextStyle(
                                color: AppColors.coinBrown,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment summary
                  _whiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Payment Summary",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Divider(color: Colors.grey, height: 20),
                        _summaryRow(
                            "Gold Price", "₹${widget.purchase.goldPricePerGram.toStringAsFixed(2)}/g"),
                        _summaryRow("Gold Weight Bought", "${widget.purchase.goldWeight}/ g"),
                        _summaryRow("Subtotal Amount", "₹${widget.purchase.subtotal.toStringAsFixed(2)}"),
                        _summaryRow("Total Tax (GST)", "₹${widget.purchase.gst.toStringAsFixed(2)}"),
                        if (discountAmount > 0) ...[
                          _summaryRow(
                            redeemProvider.isGiftCode ? "Gift Value" : "Discount",
                            "-₹${discountAmount.toStringAsFixed(2)}",
                            isDiscount: true,
                          ),
                        ],
                        const Divider(color: Colors.grey, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Grand Total:",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "₹${grandTotal.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: AppColors.coinBrown,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Redeem Code Input
                  _whiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasActiveCode) ...[
                          // Show applied code status
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.coinBrown.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  redeemProvider.isGiftCode ? Icons.card_giftcard : Icons.local_offer,
                                  color: AppColors.coinBrown,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        redeemProvider.isGiftCode ? "Gift Code Applied" : "Promo Code Applied",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _redeemController.text.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Show loading indicator while cancelling
                                if (giftCancelProvider.isLoading)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                else
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red, size: 20),
                                    onPressed: _removeRedeemCode,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Show input field
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _redeemController,
                                  decoration: const InputDecoration(
                                    hintText: "Enter Redeem Code",
                                    border: InputBorder.none,
                                  ),
                                  textCapitalization: TextCapitalization.characters,
                                  onSubmitted: (value) => _applyRedeemCode(value),
                                ),
                              ),
                              if (redeemProvider.isLoading)
                                const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              else
                                IconButton(
                                  icon: const Icon(Icons.check, color: AppColors.coinBrown),
                                  onPressed: () => _applyRedeemCode(_redeemController.text),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Features Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _whiteCard(
                        width: 160,
                        child: Row(
                          children: [
                            Image.asset("assets/images/gold-Photoroom.png", height: 24, width: 24),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "24K \nPurest",
                                style: TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _whiteCard(
                        width: 160,
                        child: Row(
                          children: [
                            const Icon(Icons.lock, color: AppColors.coinBrown, size: 24),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "100% Secured\nand owned vault",
                                style: TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Proceed button
                  CustomButton(
                    text: _isProcessing 
                        ? "Processing..." 
                        : "Proceed to Pay ₹${grandTotal.toStringAsFixed(2)}",
                    onPressed: _isProcessing 
                        ? null 
                        : () {
                            openCheckOut(grandTotal.round());
                          },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _whiteCard({required Widget child, double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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

  Widget _summaryRow(String left, String right, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Text(
            right,
            style: TextStyle(
              color: isDiscount ? Colors.green : Colors.black87,
              fontSize: 13,
              fontWeight: isDiscount ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
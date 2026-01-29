// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
// import 'package:aishwarya_gold/res/constants/app_color.dart';
// import 'package:provider/provider.dart';
// import 'package:aishwarya_gold/view_models/invest_provider/inverst_provider.dart';

// class RazorpaySipPaymentScreen extends StatefulWidget {
//   final String subscriptionId;
//   final double amount;
//   final String planType;
//   final DateTime startDate;

//   const RazorpaySipPaymentScreen({
//     Key? key,
//     required this.subscriptionId,
//     required this.amount,
//     required this.planType,
//     required this.startDate,
//   }) : super(key: key);

//   @override
//   State<RazorpaySipPaymentScreen> createState() => _RazorpaySipPaymentScreenState();
// }

// class _RazorpaySipPaymentScreenState extends State<RazorpaySipPaymentScreen> {
//   late Razorpay _razorpay;
//   bool _isProcessing = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeRazorpay();
//     // Auto-trigger payment after a short delay
//     Future.delayed(const Duration(milliseconds: 500), () {
//       _openRazorpayCheckout();
//     });
//   }

//   void _initializeRazorpay() {
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   void _openRazorpayCheckout() async {
//     final userName = await SessionManager.getData("userName") ?? "User";
//     final userEmail = await SessionManager.getData("userEmail") ?? "";
//     final userPhone = await SessionManager.getData("userPhone") ?? "";

//     var options = {
//       'key': 'rzp_test_RbX65RuyVPVf9h', // Replace with your Razorpay key
//       'subscription_id': widget.subscriptionId,
//       'name': 'Aishwarya Gold',
//       'description': 'SIP ${widget.planType} Plan',
//       'prefill': {
//         'contact': userPhone,
//         'email': userEmail,
//         'name': userName,
//       },
//       'theme': {
//         'color': '#8B0000'
//       }
//     };

//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       debugPrint('Error opening Razorpay: $e');
//       _showErrorDialog('Failed to open payment gateway');
//     }
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     setState(() => _isProcessing = true);
    
//     debugPrint('✅ Payment Success');
//     debugPrint('Payment ID: ${response.paymentId}');
//     debugPrint('Signature: ${response.signature}');
//     debugPrint('Subscription ID: ${widget.subscriptionId}');

//     if (!mounted) return;

//     // Call verification API
//     final investProvider = Provider.of<InvestmentProvider>(context, listen: false);
    
//     try {
//       final userId = await SessionManager.getUserId() ?? "";
      
//       final success = await investProvider.SipPlan(
//         userId: userId,
//         planName: 'SIP',
//         startDate: widget.startDate,
//         investmentAmount: widget.amount,
//         frequency: widget.planType,
//         paymentId: response.paymentId ?? '',
//         signature: response.signature ?? '',
//       );

//       setState(() => _isProcessing = false);

//       if (success && mounted) {
//         // Navigate to success page
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (_) => SipPaymentSuccessScreen(
//               amount: widget.amount,
//               planType: widget.planType,
//               startDate: widget.startDate,
//               paymentId: response.paymentId ?? '',
//             ),
//           ),
//         );
//       } else {
//         _showErrorDialog('Payment verification failed. Please contact support.');
//       }
//     } catch (e) {
//       setState(() => _isProcessing = false);
//       debugPrint('Verification error: $e');
//       _showErrorDialog('Payment verification failed: $e');
//     }
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     debugPrint('❌ Payment Error: ${response.code} - ${response.message}');
//     _showErrorDialog('Payment failed: ${response.message}');
    
//     // Go back after error
//     Future.delayed(const Duration(seconds: 2), () {
//       if (mounted) Navigator.of(context).pop();
//     });
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     debugPrint('External Wallet: ${response.walletName}');
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Payment Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//               Navigator.of(context).pop();
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Processing Payment'),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (_isProcessing) ...[
//               const CircularProgressIndicator(
//                 color: AppColors.primaryRed,
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Verifying payment...',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//             ] else ...[
//               Icon(
//                 Icons.payment,
//                 size: 80,
//                 color: AppColors.primaryRed.withOpacity(0.7),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Opening payment gateway...',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 'Amount: ₹${widget.amount.toStringAsFixed(2)}',
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primaryRed,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Success Screen
// class SipPaymentSuccessScreen extends StatelessWidget {
//   final double amount;
//   final String planType;
//   final DateTime startDate;
//   final String paymentId;

//   const SipPaymentSuccessScreen({
//     Key? key,
//     required this.amount,
//     required this.planType,
//     required this.startDate,
//     required this.paymentId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.check_circle,
//                   size: 70,
//                   color: Colors.green.shade600,
//                 ),
//               ),
//               const SizedBox(height: 30),
//               const Text(
//                 'SIP Activated Successfully!',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Your $planType SIP plan has been activated',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey.shade600,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 40),
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade200),
//                 ),
//                 child: Column(
//                   children: [
//                     _buildDetailRow('Plan Type', planType),
//                     const Divider(height: 24),
//                     _buildDetailRow('Amount', '₹${amount.toStringAsFixed(2)}'),
//                     const Divider(height: 24),
//                     _buildDetailRow(
//                       'Start Date',
//                       '${startDate.day}/${startDate.month}/${startDate.year}',
//                     ),
//                     const Divider(height: 24),
//                     _buildDetailRow('Payment ID', paymentId, isSmall: true),
//                   ],
//                 ),
//               ),
//               const Spacer(),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryRed,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   onPressed: () {
//                     // Go back to home or investment screen
//                     Navigator.of(context).popUntil((route) => route.isFirst);
//                   },
//                   child: const Text(
//                     'Back to Home',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value, {bool isSmall = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: isSmall ? 12 : 14,
//             color: Colors.grey.shade600,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         Flexible(
//           child: Text(
//             value,
//             style: TextStyle(
//               fontSize: isSmall ? 11 : 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//             textAlign: TextAlign.right,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }
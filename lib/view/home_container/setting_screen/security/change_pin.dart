// import 'package:aishwarya_gold/res/constants/app_color.dart';
// import 'package:aishwarya_gold/view_models/changepin_provider/changepin_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart';
// import 'package:provider/provider.dart';

// class ChangePinScreen extends StatefulWidget {
//   const ChangePinScreen({super.key});

//   @override
//   State<ChangePinScreen> createState() => _ChangePinScreenState();
// }

// class _ChangePinScreenState extends State<ChangePinScreen> with TickerProviderStateMixin {
//   final TextEditingController newPinController = TextEditingController();
//   final TextEditingController confirmPinController = TextEditingController();

//   bool isButtonEnabled = false;

//   late AnimationController _animationController;
//   late AnimationController _shakeController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _shakeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     _setupListeners();
//     Future.microtask(() {
//     Provider.of<ChangePinProvider>(context, listen: false);
//      // Example: clear previous states or fetch initial data
//   });
//   }

//   void _setupAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _shakeController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );

//     _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
//     );

//     _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
//     );

//     _animationController.forward();
//   }

//   void _setupListeners() {
//     newPinController.addListener(_checkFields);
//     confirmPinController.addListener(_checkFields);
//   }

//   void _checkFields() {
//     setState(() {
//       isButtonEnabled =
//           newPinController.text.length == 4 && confirmPinController.text.length == 4;
//     });
//   }

//   void _shakeField() {
//     _shakeController.forward().then((_) => _shakeController.reset());
//   }

//   void _onChangePin(BuildContext context) {
//     String newPin = newPinController.text.trim();
//     String confirmPin = confirmPinController.text.trim();

//     if (newPin != confirmPin) {
//       _shakeField();
//       _showCustomSnackbar(
//         "New PIN and Confirm PIN do not match",
//         Icons.warning_amber_outlined,
//         AppColors.coinBrown,
//       );
//       return;
//     }

//     final provider = Provider.of<ChangePinProvider>(context, listen: false);
//     provider.changePin(
//       newPin: newPin,
//       confirmPin: confirmPin,
//       context: context,
//     );
//   }

//   void _showCustomSnackbar(String message, IconData icon, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(icon, color: Colors.white, size: 22),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   Widget _modernPinInputField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required Color iconColor,
//   }) {
//     return AnimatedBuilder(
//       animation: _shakeAnimation,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(_shakeAnimation.value * 10 * (1 - _shakeAnimation.value), 0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: iconColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(icon, color: iconColor, size: 20),
//                   ),
//                   const SizedBox(width: 12),
//                   Text(
//                     label,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF1A1A1A),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Center(
//                 child: Pinput(
//                   controller: controller,
//                   length: 4,
//                   obscureText: true,
//                   showCursor: true,
//                   cursor: Container(
//                     width: 2,
//                     height: 14,
//                     color: iconColor,
//                   ),
//                   defaultPinTheme: PinTheme(
//                     width: 48,
//                     height: 48,
//                     textStyle: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: iconColor,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.grey.shade300, width: 1.2),
//                     ),
//                   ),
//                   focusedPinTheme: PinTheme(
//                     width: 48,
//                     height: 48,
//                     textStyle: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: iconColor,
//                     ),
//                     decoration: BoxDecoration(
//                       color: iconColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: iconColor, width: 2),
//                     ),
//                   ),
//                   submittedPinTheme: PinTheme(
//                     width: 48,
//                     height: 48,
//                     textStyle: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.coinBrown,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.amber.shade50,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: AppColors.coinBrown, width: 2),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _shakeController.dispose();
//     newPinController.dispose();
//     confirmPinController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         title: const Text(
//           "Change PIN",
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: SlideTransition(
//           position: _slideAnimation,
//           child: SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 24),

//                   _modernPinInputField(
//                     controller: newPinController,
//                     label: "New PIN",
//                     icon: Icons.lock,
//                     iconColor: AppColors.buttonBorder,
//                   ),

//                   const SizedBox(height: 24),

//                   _modernPinInputField(
//                     controller: confirmPinController,
//                     label: "Confirm New PIN",
//                     icon: Icons.verified_user,
//                     iconColor: AppColors.coinBrown,
//                   ),

//                   const SizedBox(height: 32),

//                   // 🔒 Change PIN Button
//                   Consumer<ChangePinProvider>(
//                     builder: (context, provider, _) {
//                       return SizedBox(
//                         width: double.infinity,
//                         height: 60,
//                         child: ElevatedButton(
//                           onPressed: isButtonEnabled && !provider.isLoading
//                               ? () => _onChangePin(context)
//                               : null,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: isButtonEnabled
//                                 ? AppColors.primaryRed
//                                 : Colors.grey.shade300,
//                             foregroundColor: Colors.white,
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                           ),
//                           child: provider.isLoading
//                               ? const SizedBox(
//                                   width: 28,
//                                   height: 28,
//                                   child: CircularProgressIndicator(
//                                     color: Colors.white,
//                                     strokeWidth: 2,
//                                   ),
//                                 )
//                               : Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.security,
//                                       size: 24,
//                                       color: isButtonEnabled
//                                           ? Colors.white
//                                           : Colors.grey.shade500,
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Text(
//                                       "Update PIN",
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w600,
//                                         color: isButtonEnabled
//                                             ? Colors.white
//                                             : Colors.grey.shade500,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                         ),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 30),

//                   // 🛡️ Security Tips
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.amber.shade50,
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: Colors.amber.shade200, width: 1),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.tips_and_updates,
//                               color: Colors.amber.shade700,
//                               size: 24,
//                             ),
//                             const SizedBox(width: 12),
//                             Text(
//                               "PIN Security Tips",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.amber.shade800,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         ...const [
//                           "• Choose a PIN that's not easily guessable",
//                           "• Avoid using birthdays or repeated numbers",
//                           "• Don't share your PIN with anyone",
//                           "• Change your PIN regularly for better security",
//                         ].map(
//                           (tip) => Padding(
//                             padding: const EdgeInsets.only(bottom: 6),
//                             child: Text(
//                               tip,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.amber.shade700,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

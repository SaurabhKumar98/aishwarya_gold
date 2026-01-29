// import 'dart:async';
// import 'package:aishwarya_gold/view/auth_screen/login_page.dart';
// import 'package:aishwarya_gold/view/home_container/Buttom_bar.dart';
// import 'package:aishwarya_gold/view/home_container/home_screen.dart';
// import 'package:flutter/material.dart';

// class ThirdSplashScreen extends StatefulWidget {
//   const ThirdSplashScreen({super.key});

//   @override
//   State<ThirdSplashScreen> createState() => _ThirdSplashScreenState();
// }

// class _ThirdSplashScreenState extends State<ThirdSplashScreen> {
//   bool showFirst = false;
//   bool showSecond = false;
//   bool showThird = false;
//   double graphProgress = 0; // Control graph animation explicitly

//   final GlobalKey _columnKey = GlobalKey();
//   final GlobalKey _cardKey1 = GlobalKey();
//   final GlobalKey _cardKey2 = GlobalKey();
//   final GlobalKey _cardKey3 = GlobalKey();

//   List<double> _dotCenters = [];

//   @override
//   void initState() {
//     super.initState();

//     // Sequential reveal
//     Future.delayed(const Duration(milliseconds: 500), () {
//       setState(() => showFirst = true);
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _addDotPosition(_cardKey1);
//       });
//     });
//     Future.delayed(const Duration(seconds: 1), () {
//       setState(() {
//         showSecond = true;
//         graphProgress = 1; // Start graph animation when second card is visible
//       });
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _addDotPosition(_cardKey2);
//       });
//     });
//     Future.delayed(const Duration(seconds: 2), () {
//       setState(() => showThird = true);
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _addDotPosition(_cardKey3);
//       });
//     });
//   }

//   void _addDotPosition(GlobalKey key) {
//     if (!mounted) return;

//     final columnRender =
//         _columnKey.currentContext?.findRenderObject() as RenderBox?;
//     if (columnRender == null) return;

//     final columnGlobalY = columnRender.localToGlobal(Offset.zero).dy;

//     final render = key.currentContext?.findRenderObject() as RenderBox?;
//     if (render == null) return;

//     final cardGlobalY = render.localToGlobal(Offset.zero).dy;
//     final relativeY = cardGlobalY - columnGlobalY;
//     final center = relativeY + render.size.height / 2;

//     setState(() {
//       _dotCenters = [..._dotCenters, center];
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Top content scrollable
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Title and SKIP button row
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: RichText(
//                               text: const TextSpan(
//                                 children: [
//                                   TextSpan(
//                                     text: "Benefits of savings\nwith AISHWARYA ",
//                                     style: TextStyle(
//                                       fontSize: 22,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                   TextSpan(
//                                     text: "GOLD",
//                                     style: TextStyle(
//                                       fontSize: 22,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xFFB8860B),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => const MainScreen()));
//                             },
//                             child: const Text(
//                               "SKIP",
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.black54,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       const Text(
//                         "Start Small, Grow Big!",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.black54,
//                         ),
//                       ),
//                       const SizedBox(height: 20),

//                       // Timeline + Cards
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Timeline
//                           SizedBox(
//                             width: 14,
//                             child: IntrinsicHeight(
//                               child: CustomPaint(
//                                 painter: TimelinePainter(_dotCenters),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),

//                           // Cards with animation
//                           Expanded(
//                             child: Column(
//                               key: _columnKey,
//                               children: [
//                                 _animatedCard(
//                                   key: _cardKey1,
//                                   visible: showFirst,
//                                   child: Row(
//                                     children: [
//                                       const Expanded(
//                                         child: Text(
//                                           "Invest in\n24k Gold & get \nhigher returns",
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             color: Colors.black87,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Image.asset(
//                                         "assets/images/mandal.png",
//                                         width: 90,
//                                         height: 120,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 20),
//                                 _animatedCard(
//                                   key: _cardKey2,
//                                   visible: showSecond,
//                                   child: Row(
//                                     children: [
//                                       const Expanded(
//                                         flex: 1,
//                                         child: Text(
//                                           "The Highest\nPerforming Asset\nin last 5 years",
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             color: Colors.black87,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Expanded(
//                                         flex: 2,
//                                         child: SizedBox(
//                                           height: 120,
//                                           child: Stack(
//                                             children: [
//                                               // Horizontal dividers
//                                               Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceEvenly,
//                                                 children:
//                                                     List.generate(4, (i) {
//                                                   return Container(
//                                                     height: 1,
//                                                     color: Colors.grey.shade300,
//                                                   );
//                                                 }),
//                                               ),
//                                               // Animated graph
//                                               ClipRect(
//                                                 child: CustomPaint(
//                                                   size: const Size(
//                                                       double.infinity, 100),
//                                                   painter:
//                                                       GraphPainter(graphProgress),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 20),
//                                 _animatedCard(
//                                   key: _cardKey3,
//                                   visible: showThird,
//                                   child: Row(
//                                     children: [
//                                       const Expanded(
//                                         child: Text(
//                                           "Redeem at\nJeweller Partners\n120+ partners",
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             color: Colors.black87,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Image.asset(
//                                         "assets/images/mandal.png",
//                                         width: 90,
//                                         height: 120,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 2), // space before bottom
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // Fixed bottom section
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     alignment: Alignment.center,
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 8, horizontal: 16),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(30),
//                       color: Colors.grey.shade100,
//                     ),
//                     child: const Text(
//                       "Start as low as ₹100/day 💰",
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color.fromARGB(255, 150, 13, 13),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                       ),
//                       onPressed: () {
//                         Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => const AuthScreen()));
//                       },
//                       child: const Text(
//                         "Get Started",
//                         style: TextStyle(fontSize: 16, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _animatedCard({
//     required bool visible,
//     required Widget child,
//     Key? key,
//   }) {
//     return AnimatedOpacity(
//       opacity: visible ? 1 : 0,
//       duration: const Duration(milliseconds: 600),
//       child: AnimatedSlide(
//         offset: visible ? Offset.zero : const Offset(1, 0),
//         duration: const Duration(milliseconds: 600),
//         child: _buildBigCard(child: child, key: key),
//       ),
//     );
//   }

//   Widget _buildBigCard({required Widget child, Key? key}) {
//     return Container(
//       key: key,
//       margin: const EdgeInsets.symmetric(vertical: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: Colors.black12),
//         borderRadius: BorderRadius.circular(16),
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
// }

// // Custom Painter for Timeline
// class TimelinePainter extends CustomPainter {
//   final List<double> dotCenters;

//   TimelinePainter(this.dotCenters);

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (dotCenters.isEmpty) return;

//     const double radius = 7;
//     final linePaint = Paint()
//       ..color = Colors.amber
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;

//     final dotBorderPaint = Paint()
//       ..color = Colors.amber
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2;

//     final dotFillPaint = Paint()..color = Colors.amber; // Changed to yellow

//     for (var centerY in dotCenters) {
//       final center = Offset(radius, centerY);
//       canvas.drawCircle(center, radius, dotFillPaint);
//       canvas.drawCircle(center, radius, dotBorderPaint);
//     }

//     if (dotCenters.length >= 2) {
//       canvas.drawLine(
//         Offset(radius, dotCenters.first),
//         Offset(radius, dotCenters.last),
//         linePaint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant TimelinePainter oldDelegate) {
//     return oldDelegate.dotCenters != dotCenters;
//   }
// }

// // Custom Painter for Animated Graph
// class GraphPainter extends CustomPainter {
//   final double progress;
//   GraphPainter(this.progress);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.green
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;

//     final path = Path();
//     final points = [
//       Offset(0, size.height * 0.9),
//       Offset(size.width * 0.2, size.height * 0.5),
//       Offset(size.width * 0.4, size.height * 0.7),
//       Offset(size.width * 0.6, size.height * 0.4),
//       Offset(size.width * 0.8, size.height * 0.6),
//       Offset(size.width, size.height * 0.2),
//     ];

//     path.moveTo(points.first.dx, points.first.dy);

//     final totalSegments = points.length - 1;
//     final fractionalIndex = totalSegments * progress;
//     final endIndex = fractionalIndex.floor();

//     for (int i = 1; i <= endIndex; i++) {
//       path.lineTo(points[i].dx, points[i].dy);
//     }

//     if (endIndex < totalSegments) {
//       final frac = fractionalIndex - endIndex;
//       final prev = points[endIndex];
//       final next = points[endIndex + 1];
//       final interpX = prev.dx + (next.dx - prev.dx) * frac;
//       final interpY = prev.dy + (next.dy - prev.dy) * frac;
//       path.lineTo(interpX, interpY);
//     }

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant GraphPainter oldDelegate) {
//     return oldDelegate.progress != progress;
//   }
// }
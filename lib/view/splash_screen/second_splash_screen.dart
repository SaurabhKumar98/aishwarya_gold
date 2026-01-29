// import 'package:flutter/material.dart';
// import 'dart:math';

// class SecondSplashScreen extends StatelessWidget {
//   const SecondSplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFFCF5), // Light cream background
//       body: Stack(
//         children: [
//           // Mandala background
//           Positioned.fill(
//             child: Center(
//               child: CustomPaint(
//                 size: Size(MediaQuery.of(context).size.width * 1.4,
//                     MediaQuery.of(context).size.width * 1.4),
//                 painter: MandalaPainter(),
//               ),
//             ),
//           ),

//           // Center white circle with text
//           Center(
//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.7,
//               height: MediaQuery.of(context).size.width * 0.7,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//               ),
//               child: Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text(
//                       "AISHWARYA",
//                       style: TextStyle(
//                         fontSize: 38,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                         letterSpacing: 1.2,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     Column(
//                       children: [
//                         const Text(
//                           "GOLD",
//                           style: TextStyle(
//                             fontSize: 38,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFFD4AF37), // Gold
//                             letterSpacing: 1.2,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Container(
//                           width: 70,
//                           height: 2,
//                           color: Colors.black87,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Bottom partners row
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   // AUGMONT
//                   Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: const [
//                       Text(
//                         "AUGMONT",
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF6E5C3E),
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         "Gold Partner",
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF777777),
//                         ),
//                       ),
//                     ],
//                   ),

//                   Container(
//                     width: 1,
//                     height: 30,
//                     color: Colors.grey.shade400,
//                   ),

//                   // ICICI
//                   Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: const [
//                       Text(
//                         "ICICI",
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFFE44C2A),
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         "Insured By",
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF777777),
//                         ),
//                       ),
//                     ],
//                   ),

//                   Container(
//                     width: 1,
//                     height: 30,
//                     color: Colors.grey.shade400,
//                   ),

//                   // Cashfree
//                   Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: const [
//                       Text(
//                         "Cashfree",
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF00D4AA),
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         "Payment Partner",
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF777777),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Mandala Painter
// class MandalaPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFFD4AF37).withOpacity(0.25) // soft gold
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 0.8;

//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;

//     // Draw concentric petals
//     for (int i = 0; i < 12; i++) {
//       final angle = (2 * pi / 12) * i;
//       final x = center.dx + radius * cos(angle);
//       final y = center.dy + radius * sin(angle);
//       final path = Path()
//         ..moveTo(center.dx, center.dy - radius * 0.6)
//         ..quadraticBezierTo(center.dx, center.dy, x, y);
//       canvas.drawPath(path, paint);
//     }

//     // Outer circle
//     canvas.drawCircle(center, radius * 0.9, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true
//   ;
// }
import 'dart:async';
import 'package:aishwarya_gold/view/splash_screen/onboarding_screen.dart';
import 'package:aishwarya_gold/view/splash_screen/third_splash_screen.dart';
import 'package:flutter/material.dart';

class SecondSplashScreen extends StatefulWidget {
  const SecondSplashScreen({super.key});

  @override
  State<SecondSplashScreen> createState() => _SecondSplashScreenState();
}

class _SecondSplashScreenState extends State<SecondSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  // Typewriter animation
  String _visibleText = "";
  final String _fullText = "AISHWARYA\nGOLD";
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Rotation controller for mandala image
    _rotationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 25))
          ..repeat();

    // Typewriter effect
    _timer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (_index < _fullText.length) {
        setState(() {
          _visibleText += _fullText[_index];
          _index++;
        });
      } else {
        _timer?.cancel();

        // After showing text, wait 1s then go to ThirdSplashScreen
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF5),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating mandala image (lighter + fully visible)
                RotationTransition(
                  turns: _rotationController,
                  child: Opacity(
                    opacity: 0.25, // <-- make it lighter
                    child: Image.asset(
                      "assets/images/mandal.png", // your mandala image
                      width: size.width * 8,   // expanded to avoid cutting
                      height: size.width * 8,
                      fit: BoxFit.contain,      // full mandala visible
                    ),
                  ),
                ),

                // Inner white circle with text
                // Inner white circle with text
Container(
  width: size.width * 0.60,   // smaller than before (0.72 → 0.62)
  height: size.width * 0.60,
  decoration: const BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
  ),
  child: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Typewriter effect for AISHWARYA GOLD
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: _visibleText.contains("\n")
                    ? _visibleText.split("\n")[0] + "\n"
                    : _visibleText,
                style: const TextStyle(
                  fontSize: 32, // reduced to fit inside smaller circle
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.0,
                  letterSpacing: 1.2,
                ),
              ),
              if (_visibleText.contains("\n"))
                TextSpan(
                  text: _visibleText.split("\n").length > 1
                      ? _visibleText.split("\n")[1]
                      : "",
                  style: const TextStyle(
                    fontSize: 32, // reduced
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB8860B), // gold
                    height: 1,
                    letterSpacing: 1.2,
                  ),
                ),
            ],
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 5),

        // Divider
        const SizedBox(
          width: 160, // narrower to match smaller circle
          child: Divider(
            color: Colors.black54,
            thickness: 0.8,
          ),
        ),

        const SizedBox(height: 5),

        // Tagline
        const Text(
          "Bharat Ka Gold Savings App",
          style: TextStyle(
            fontSize: 12, // reduced to fit inside
            color: Colors.black54,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  ),
),

              ],
            ),
          ),

          // Bottom Partner Logos
          Padding(
            padding: const EdgeInsets.only(bottom: 30, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: const [
                    Text("AUGMONT",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color.fromARGB(255, 35, 116, 182))),
                    Text("Gold Partner",
                        style: TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
                Column(
                  children: const [
                    Text("ICICI Lombard",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color.fromARGB(255, 8, 49, 82))),
                    Text("Insured By",
                        style: TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
                Column(
                  children: const [
                    Text("Cashfree Payments",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.deepPurple)),
                    Text("Payment Partner",
                        style: TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

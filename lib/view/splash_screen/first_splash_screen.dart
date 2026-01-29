// import 'dart:async';
// import 'package:aishwarya_gold/res/constants/app_color.dart';
// import 'package:aishwarya_gold/view/splash_screen/onboarding_screen.dart';
// import 'package:aishwarya_gold/view/splash_screen/second_splash_screen.dart';
// import 'package:flutter/material.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> 
//     with TickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late AnimationController _scaleController;
//   late AnimationController _shimmerController;
  
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _shimmerAnimation;

//   @override
//   void initState() {
//     super.initState();
    
//     // Initialize animation controllers
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
    
//     _scaleController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );
    
//     _shimmerController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );
    
//     // Initialize animations
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     ));
    
//     _scaleAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _scaleController,
//       curve: Curves.elasticOut,
//     ));
    
//     _shimmerAnimation = Tween<double>(
//       begin: -1.0,
//       end: 2.0,
//     ).animate(CurvedAnimation(
//       parent: _shimmerController,
//       curve: Curves.easeInOut,
//     ));
    
//     // Start animations
//     _startAnimations();
    
//     // Navigate after 3 seconds
//     Timer(const Duration(seconds: 3), () {
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const OnboardingScreen()),
//         );
//       }
//     });
//   }

//   void _startAnimations() {
//     _fadeController.forward();
//     _scaleController.forward();
//     _shimmerController.repeat();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _scaleController.dispose();
//     _shimmerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: RadialGradient(
//             center: Alignment.center,
//             radius: 1.2,
//             colors: [
//               AppColors.accentRed, // Lighter maroon center
//               AppColors.secRed, // Medium maroon
              
//               AppColors.secRed // Darker maroon edges
//             ],
//             stops: [0.0, 0.7, 1.0],
//           ),
//         ),
//         child: Stack(
//           children: [
//             // Decorative golden rings
//             Positioned(
//               top: 100,
//               right: -50,
//               child: AnimatedBuilder(
//                 animation: _shimmerController,
//                 builder: (context, child) {
//                   return Transform.rotate(
//                     angle: _shimmerAnimation.value * 6.28, // 2π for full rotation
//                     child: Container(
//                       width: 150,
//                       height: 150,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: const Color(0xFFD4AF37).withOpacity(0.3),
//                           width: 2,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
            
//             Positioned(
//               bottom: 150,
//               left: -30,
//               child: AnimatedBuilder(
//                 animation: _shimmerController,
//                 builder: (context, child) {
//                   return Transform.rotate(
//                     angle: -_shimmerAnimation.value * 6.28,
//                     child: Container(
//                       width: 100,
//                       height: 100,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: const Color(0xFFD4AF37).withOpacity(0.2),
//                           width: 1.5,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
            
//             // Main content
//             Center(
//               child: AnimatedBuilder(
//                 animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
//                 builder: (context, child) {
//                   return FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: Transform.scale(
//                       scale: _scaleAnimation.value,
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Logo with glow effect
//                           Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(20),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: const Color(0xFFD4AF37).withOpacity(0.3),
//                                   blurRadius: 30,
//                                   spreadRadius: 10,
//                                 ),
//                               ],
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(20),
//                               child: Image.asset(
//                                 "assets/images/Aishwarya logo.png",
//                                 width: 220,
//                                 height: 220,
//                                 fit: BoxFit.contain,
//                               ),
//                             ),
//                           ),
                          
//                           const SizedBox(height: 30),
                          
//                           // Tagline with shimmer effect
//                           AnimatedBuilder(
//                             animation: _shimmerController,
//                             builder: (context, child) {
//                               return ShaderMask(
//                                 shaderCallback: (bounds) {
//                                   return LinearGradient(
//                                     begin: Alignment.centerLeft,
//                                     end: Alignment.centerRight,
//                                     colors: const [
//                                       Color(0xFFD4AF37), // Gold
//                                       Color(0xFFF7E98E), // Light gold
//                                       Color(0xFFD4AF37), // Gold
//                                     ],
//                                     stops: [
//                                       (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
//                                       _shimmerAnimation.value.clamp(0.0, 1.0),
//                                       (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
//                                     ],
//                                   ).createShader(bounds);
//                                 },
//                                 // child: const Text(
//                                 //   "भारत का सोना बचत ऐप",
//                                 //   style: TextStyle(
//                                 //     fontSize: 18,
//                                 //     fontWeight: FontWeight.w600,
//                                 //     color: Colors.white,
//                                 //     letterSpacing: 1.2,
//                                 //     height: 1.2,
//                                 //   ),
//                                 //   textAlign: TextAlign.center,
//                                 // ),
//                               );
//                             },
//                           ),
                          
//                           const SizedBox(height: 8),
                          
//                           // English tagline
//                           // Text(
//                           //   "India's Gold Savings App",
//                           //   style: TextStyle(
//                           //     fontSize: 14,
//                           //     fontWeight: FontWeight.w400,
//                           //     color: const Color(0xFFD4AF37).withOpacity(0.9),
//                           //     letterSpacing: 0.8,
//                           //   ),
//                           // ),
                          
//                           const SizedBox(height: 50),
                          
//                           // Loading indicator
//                           Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: const Color(0xFFD4AF37).withOpacity(0.3),
//                                 width: 2,
//                               ),
//                             ),
//                             child: const CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 Color(0xFFD4AF37),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
            
//             // Bottom decorative element
//             Positioned(
//               bottom: 40,
//               left: 0,
//               right: 0,
//               child: FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: Column(
//                   children: [
//                     Container(
//                       width: 60,
//                       height: 4,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(2),
//                         gradient: const LinearGradient(
//                           colors: [
//                             Color(0xFFD4AF37),
//                             Color(0xFFF7E98E),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       "Powered by Excellence",
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w300,
//                         color: const Color(0xFFD4AF37).withOpacity(0.7),
//                         letterSpacing: 1.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
// import 'package:aishwarya_gold/res/constants/app_color.dart';
// import 'package:aishwarya_gold/view/auth_screen/login_page.dart';
// import 'package:aishwarya_gold/view/home_container/Buttom_bar.dart';
// import 'package:aishwarya_gold/view/splash_screen/onboarding_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // import your colors.dart
// import 'package:aishwarya_gold/view/splash_screen/second_splash_screen.dart';
// import 'package:flutter/material.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//    @override
//   void initState() {
//     super.initState();
//     Timer(const Duration(seconds: 3), () async {
//       final prefs = await SharedPreferences.getInstance();
//       bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
//       bool isLoggedIn = await SessionManager.isLoggedIn();

//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => isLoggedIn
//                 ? const MainScreen()
//                 : hasSeenOnboarding
//                     ? const AuthScreen()
//                     : const OnboardingScreen(),
//           ),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.seced, // maroon background
//     body: Center(
//   child: Column(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       // 🔹 Responsive Logo Image
//       Image.asset(
//         "assets/images/cropped-Aishwaryalogo.png",
//         width: MediaQuery.of(context).size.width * 0.6, // 60% of screen width
//         fit: BoxFit.contain,
//       ),

//       const SizedBox(height: 16),

//       // const Text(
//       //   "Bharat Ka Gold Savings App",
//       //   style: TextStyle(
//       //     fontSize: 16,
//       //     fontWeight: FontWeight.w500,
//       //     color: Colors.black87,
//       //     letterSpacing: 0.5,
//       //   ),
//       // ),
//     ],
//   ),
// ),
//     );
//   }
// }
import 'dart:async';
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view/auth_screen/login_page.dart';
import 'package:aishwarya_gold/view/home_container/Buttom_bar.dart';
import 'package:aishwarya_gold/view/splash_screen/onboarding_screen.dart';
import 'package:aishwarya_gold/view_models/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

Future<void> _checkLoginStatus() async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);

  // Wait for session to load
  if (!userProvider.isSessionLoaded) {
    await userProvider.reloadSession();
  }
  while (!userProvider.isSessionLoaded) {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  await Future.delayed(const Duration(seconds: 2)); // Splash delay

  final prefs = await SharedPreferences.getInstance();
  bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  bool isLoggedIn = await SessionManager.isLoggedIn();
  bool isFingerprintEnabled = await SessionManager.isFingerprintEnabled();

  // Handle fingerprint authentication if enabled
  if (isLoggedIn && isFingerprintEnabled) {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      bool canCheck = await auth.canCheckBiometrics;
      bool supported = await auth.isDeviceSupported();

      if (canCheck && supported) {
        bool authenticated = await auth.authenticate(
          localizedReason: 'Authenticate to access the app',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (!authenticated) {
          // Authentication failed → logout user
          await SessionManager.logoutUser();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
          return;
        }
      }
    } catch (e) {
      debugPrint("Biometric error: $e");
    }
  }

  // Navigate normally
  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn && userProvider.userId != null
            ? const MainScreen()
            : hasSeenOnboarding
                ? const AuthScreen()
                : const OnboardingScreen(),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.seced,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/cropped-Aishwaryalogo.png",
              width: MediaQuery.of(context).size.width * 0.6,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
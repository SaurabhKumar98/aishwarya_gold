import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view/auth_screen/set_pin_screen.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/security/change_pin.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> with TickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  bool isFingerprintEnabled = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
@override
void initState() {
  super.initState();
  _animationController = AnimationController(
    duration: const Duration(milliseconds: 800),
    vsync: this,
  );
  _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
  );
  _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
      .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
  _animationController.forward();

  // Load fingerprint state
  _loadFingerprintState();
}

Future<void> _loadFingerprintState() async {
  bool enabled = await SessionManager.isFingerprintEnabled();
  setState(() {
    isFingerprintEnabled = enabled;
  });
}


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

 Future<void> _toggleFingerprint(bool value) async {
  if (value) {
    try {
      bool canCheck = await auth.canCheckBiometrics;
      bool deviceSupported = await auth.isDeviceSupported();

      if (canCheck && deviceSupported) {
        bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Authenticate with your fingerprint to enable it',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (didAuthenticate) {
          setState(() => isFingerprintEnabled = true);
          await SessionManager.setFingerprintEnabled(true);
          _showCustomSnackbar("Fingerprint Enabled", Icons.check_circle, AppColors.coinBrown);
        } else {
          _showCustomSnackbar("Authentication Failed", Icons.error, Colors.red);
        }
      } else {
        _showCustomSnackbar("Biometric not available", Icons.warning, Colors.orange);
      }
    } catch (e) {
      debugPrint("Biometric auth error: $e");
      _showCustomSnackbar("Biometric Error", Icons.error, Colors.red);
    }
  } else {
    setState(() => isFingerprintEnabled = false);
    await SessionManager.setFingerprintEnabled(false);
    _showCustomSnackbar("Fingerprint Disabled", Icons.info, AppColors.coinBrown);
  }
}

 
  void _showCustomSnackbar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          "Security",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.backgroundWhite,
        centerTitle: false,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          // decoration: BoxDecoration(
          //   color: Colors.grey.shade100,
          //   borderRadius: BorderRadius.circular(12),
          // ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Header Section
              // Container(
              //   margin: const EdgeInsets.symmetric(horizontal: 20),
              //   padding: const EdgeInsets.all(24),
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       begin: Alignment.topLeft,
              //       end: Alignment.bottomRight,
              //       colors: [
              //         Colors.blue.shade50,
              //         Colors.indigo.shade50,
              //       ],
              //     ),
              //     borderRadius: BorderRadius.circular(20),
              //     border: Border.all(
              //       color: Colors.blue.shade100,
              //       width: 1,
              //     ),
              //   ),
              //   child: Row(
              //     children: [
              //       Container(
              //         padding: const EdgeInsets.all(16),
              //         decoration: BoxDecoration(
              //           color: Colors.blue.shade100,
              //           borderRadius: BorderRadius.circular(16),
              //         ),
              //         child: Icon(
              //           Icons.security,
              //           color: Colors.blue.shade700,
              //           size: 32,
              //         ),
              //       ),
              //       const SizedBox(width: 16),
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             const Text(
              //               "Secure Your Account",
              //               style: TextStyle(
              //                 fontSize: 20,
              //                 fontWeight: FontWeight.w700,
              //                 color: Color(0xFF1A1A1A),
              //               ),
              //             ),
              //             const SizedBox(height: 4),
              //             Text(
              //               "Manage your security settings",
              //               style: TextStyle(
              //                 fontSize: 14,
              //                 color: Colors.grey.shade600,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              
              // const SizedBox(height: 30),
              
              // Security Options
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Fingerprint Toggle
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isFingerprintEnabled 
                                  ? AppColors.accentGold
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.fingerprint,
                              color: isFingerprintEnabled 
                                  ? AppColors.coinBrown 
                                  : Colors.grey.shade600,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Fingerprint Authentication",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isFingerprintEnabled 
                                      ? "Enabled for quick access"
                                      : "Disabled",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Transform.scale(
                            scale: 1.2,
                            child: Switch(
                              value: isFingerprintEnabled,
                              onChanged: _toggleFingerprint,
                              activeColor: Colors.white,
                              activeTrackColor: AppColors.primaryGold,
                              inactiveThumbColor: Colors.grey.shade300,
                              inactiveTrackColor: Colors.grey.shade200,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.grey.shade200,
                    ),
                    
                    // Change PIN Option
                    // _modernSettingsTile(
                    //   "Change PIN",
                    //   "Update your security PIN",
                    //   Icons.pin,
                    //   Colors.orange,
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (_) => const ChangePinScreen(),
                    //       ),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Security Tips
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Security Tip",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Keep your PIN secure and enable biometric authentication for better security.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor.withOpacity(0.8),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade600,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
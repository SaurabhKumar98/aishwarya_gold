import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/res/components/customproivderclearn.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view/auth_screen/login_page.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/gold_certificate/gold_certificate_plan.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/gold_certificate/gold_certificate_screen.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/helpandSupport/heplandsupport.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/helpandSupport/supportchat_screen.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/kycstatus/kycstatus_screen.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/nominee_details_screen/nominee_details_screen.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/payment_method_screen/payment_method_screen.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/profile_screen/profile_details.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/profile_screen/profile_screen.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/reddem_gift_card/reddem_gift.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/referandearn/referandearn.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/security/biometric.dart';
import 'package:aishwarya_gold/view_models/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Settings",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          surfaceTintColor: AppColors.backgroundLight,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _settingsTile(
                      "Profile Details",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileDetailsScreen(),
                          ),
                        );
                      },
                    ),
                    _settingsTile(
                      "KYC Status",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KYCStatusScreen(),
                          ),
                        );
                      },
                    ),
                    _settingsTile(
                      "Gold Certificate",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GiftScreen()),
                        );
                      },
                    ),
                    // _settingsTile(
                    //   "Payment Methods",
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (_) => const PaymentMethodsScreen(),
                    //       ),
                    //     );
                    //   },
                    // ),
                    _settingsTile(
                      "Security",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SecurityScreen(),
                          ),
                        );
                      },
                    ),
                    _settingsTile(
                      "Refer & Earn",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReferEarnScreen(),
                          ),
                        );
                      },
                    ),
                    // _settingsTile("Support chat", onTap: () {
                    //   Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                    // }),
                    _settingsTile(
                      "Nominee Details",
                      onTap: () async {
                        // Add async here
                        final userId =
                            await SessionManager.getUserId(); // Add await

                        if (userId == null || userId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "User ID not found. Please login again.",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (context.mounted) {
                          // Check if context is still valid
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  NomineeDetailsScreen(userId: userId),
                            ),
                          );
                        }
                      },
                    ),
                    _settingsTile(
                      "Gift Card",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RedeemGiftScreen(),
                          ),
                        );
                      },
                    ),
                    _settingsTile(
                      "Help & Support",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpSupportScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // GestureDetector(
              //   onTap: () async {
              //     try {
              //       // 🔄 Show loading while logging out
              //       showDialog(
              //         context: context,
              //         barrierDismissible: false,
              //         builder: (_) => const Center(
              //           child: CircularProgressIndicator(
              //             color: AppColors.primaryRed,
              //           ),
              //         ),
              //       );

              //       // ✅ Use Provider logout (this will also call logout API)
              //       final userProvider = Provider.of<UserProvider>(
              //         context,
              //         listen: false,
              //       );
              //       await userProvider.logout();
              //        await ProviderCleaner.clearAll(context);

              //       // ✅ Close the loading dialog
              //       if (context.mounted) Navigator.pop(context);

              //       // ✅ Navigate to Auth screen (clearing all previous routes)
              //       if (context.mounted) {
              //         Navigator.pushAndRemoveUntil(
              //           context,
              //           MaterialPageRoute(builder: (_) => const AuthScreen()),
              //           (route) => false,
              //         );
              //       }

              //       print("✅ Logout completed successfully");
              //     } catch (e) {
              //       print("❌ Logout error: $e");

              //       // Make sure dialog closes even on error
              //       if (context.mounted) Navigator.pop(context);
              //     }
              //   },
              //   child: Container(
              //     width: double.infinity,
              //     padding: const EdgeInsets.symmetric(vertical: 16),
              //     decoration: BoxDecoration(
              //       color: AppColors.primaryRed,
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: const Center(
              //       child: Text(
              //         "Logout",
              //         style: TextStyle(
              //           color: AppColors.backgroundLight,
              //           fontWeight: FontWeight.w600,
              //           fontSize: 16,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
             GestureDetector(
  onTap: () async {
    // 1️⃣ Show professional confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  size: 48,
                  color: AppColors.primaryRed,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              const Text(
                "Logout",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Description
              const Text(
                "Are you sure you want to logout from your account?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 28),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // If user cancelled, stop here
    if (shouldLogout != true) return;

    BuildContext? dialogContext;

    try {
      // 2️⃣ Show professional loading dialog
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          dialogContext = ctx;
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.primaryRed,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Logging out...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please wait",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      // 3️⃣ Call API logout (continue even if it fails)
      if (context.mounted) {
        try {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          await userProvider.logout();
          debugPrint("✅ API logout successful");
        } catch (e) {
          debugPrint("⚠️ API logout failed (continuing): $e");
        }
      }

      // 4️⃣ Clear all provider data
      if (context.mounted) {
        await ProviderCleaner.clearAll(context);
        debugPrint("✅ All providers cleared");
      }

      // 5️⃣ Clear SharedPreferences session data
      // await SessionManager.clearSession();
      // debugPrint("✅ Session data cleared");
      

      // 6️⃣ Small delay to ensure cleanup completes
      await Future.delayed(const Duration(milliseconds: 100));

      // 7️⃣ Close the loading dialog
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.pop(dialogContext!);
      }

      // 8️⃣ Navigate to Auth screen (clearing all previous routes)
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
      }

      debugPrint("✅ Logout completed successfully");

      // 9️⃣ Show professional success snackbar
      if (context.mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Success!",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "You've been logged out successfully",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                backgroundColor: AppColors.coinBrown,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                elevation: 6,
              ),
            );
          }
        });
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Logout error: $e");
      debugPrint("Stack trace: $stackTrace");

      // Close loading dialog if it's open
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.pop(dialogContext!);
      }

      // Show professional error snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Logout Failed",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Please try again or contact support",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            elevation: 6,
            action: SnackBarAction(
              label: "Retry",
              textColor: Colors.white,
              onPressed: () {
                // Retry logout
              },
            ),
          ),
        );
      }
    }
  },
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      color: AppColors.primaryRed,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryRed.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: const Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.logout_rounded,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            "Logout",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  ),
)
        
        
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsTile(String title, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.black54,
        ),
        onTap: onTap,
      ),
    );
  }
}

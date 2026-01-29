import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/res/widgets/custom_button.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/referandearn/refferalhistory.dart';
import 'package:aishwarya_gold/view_models/refferandearn/refferearn_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({Key? key}) : super(key: key);

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch referral data when screen opens
    Future.microtask(
      () => Provider.of<RefferAndEarnProvider>(
        context,
        listen: false,
      ).fetchRefferAndEarnData(),
    );
  }

  String _friendlyError(String? error) {
    if (error == null) return "Something went wrong. Please try again.";

    final msg = error.toLowerCase();

    if (msg.contains("unauthorized") ||
        msg.contains("token") ||
        msg.contains("expired") ||
        msg.contains("jwt") ||
        msg.contains("not authenticated") ||
        msg.contains("forbidden")) {
      return "Please log in to continue.";
    }

    return "Please log in to continue.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text("Refer & Earn"),
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<RefferAndEarnProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            // Show SnackBar only once
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Unable to load refer and earn. Please login again.',
                  ),
                  backgroundColor: AppColors.coinBrown,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            });

            return Center(
              child: Text(
                _friendlyError(provider.errorMessage),
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          final referralCode = provider.refferData?.data?.referralCode ?? "N/A";
          final referralLink = "$referralCode";

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/images/cropped-Aishwaryalogo.png',
                    height: 140,
                    width: 140,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Refer a Friend, Earn Gold!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Invite your friends to Aishwarya Gold. When they make their first investment, you both receive exclusive benefits.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 28),

                // Referral Code Box
                // Referral Code Box
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.amber.shade50,
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Referral Code",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          // Referral code (left)
                          Expanded(
                            child: Text(
                              referralCode,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          // Copy button (right - BIG)
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: referralCode),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Referral code copied"),
                                  duration: Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.coinBrown,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.coinBrown,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.copy,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Copy",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Share Button
                CustomButton(
                  text: "Share Referral Link",
                  onPressed: referralCode == "N/A"
                      ? null
                      : () {
                          Share.share(
                            "Join me on Aishwarya Gold! Use my referral code $referralCode and start investing.\n\nReferral Link: $referralLink",
                          );
                        },
                ),

                const SizedBox(height: 16),

                // View Referral History
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReferralHistoryScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "View Referral History",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 150, 13, 13),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

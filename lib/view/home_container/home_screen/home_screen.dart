import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/data/models/videomodels/videomodels.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/utils/exports/exports.dart';
import 'package:aishwarya_gold/view/home_container/Buttom_bar.dart';
import 'package:aishwarya_gold/view/home_container/home_screen/all_partners/all_partners.dart';
import 'package:aishwarya_gold/view/home_container/home_screen/gift_gold.dart';
import 'package:aishwarya_gold/view/home_container/home_screen/gold_price_trend.dart';
import 'package:aishwarya_gold/view/home_container/home_screen/notification_screen.dart';
import 'package:aishwarya_gold/view/home_container/home_screen/video_player.dart';
import 'package:aishwarya_gold/view/home_container/investment/invest_screen.dart';
import 'package:aishwarya_gold/view_models/gold_price_provider/goldprice_provider.dart';
import 'package:aishwarya_gold/view_models/goldsummaryprovider/goldsummaryprovider.dart';
import 'package:aishwarya_gold/view_models/video_provider/video_provider.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Provider.of<OtpProvider>(context, listen: false).sendFcmTokenIfNeeded();
    // final tok=  SessionManager.getDeviceToken();
    // debugPrint("token: $tok");
    Future<String?> _loadDeviceToken() async {
      final tok = await SessionManager.getDeviceToken();
      debugPrint("📱 Device Token: $tok");
    }

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _slideController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goldProvider = Provider.of<GoldPriceSummaryProvider>(
        context,
        listen: false,
      );

      Provider.of<VideoProvider>(
        context,
        listen: false,
      ).fetchVideos(); // 🔥 ADD THIS

      if (goldProvider.currentPricePerGram == 0) {
        goldProvider.fetchGoldPriceSummary();
      }
    });
  }
  // Future<String?> _loadDeviceToken() async {
  //   final tok = await SessionManager.getDeviceToken();
  //   debugPrint("📱 Device Token: $tok");
  // }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 🔹 Enhanced Header section with glassmorphism effect
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 45, bottom: 25),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 248, 250, 140),
                    Color.fromARGB(255, 252, 252, 180),
                    Color(0xFFFFFFFF),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(30, 0, 0, 0),
                    offset: Offset(0, 8),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Enhanced Top bar with glassmorphism
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Enhanced logo with subtle animation
                        SlideTransition(
                          position: _slideAnimation,
                          child: RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'AISHWARYA ',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'GOLD',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFB8860B),
                                    letterSpacing: 1.2,
                                  ),

                                ),
                                TextSpan(
                                  text: '\nCOMPANY',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFB8860B),
                                    letterSpacing: 1.2,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 5),
                            // Enhanced notification icon
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  // print("Menu clicked");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NotificationScreen(),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.black87,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Enhanced Gold Pot Card with modern design
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Background with subtle overlay
                      Container(
                        height: 200,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/images/bg.png',
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // 🔹 Enhanced Quick Actions with modern cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  // Enhanced section header
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 25,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 150, 13, 13),
                              Color.fromARGB(255, 180, 40, 40),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            150,
                            13,
                            13,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          'Popular',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 150, 13, 13),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _enhancedActionButton(
                          'Buy Gold',
                          Icons.diamond_outlined,
                          const LinearGradient(
                            colors: [
                              // Color.fromARGB(255, 235, 225, 225),
                              // Color.fromARGB(255, 225, 203, 32),
                              // Color.fromARGB(255, 250, 240, 140),
                              AppColors.primaryGold,
                              AppColors.accentGold,
                              AppColors.coinBrown
                            ],
                          ),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MainScreen(selectedIndex: 2),
                              ),
                            );
                          },
                          textColor: Colors.black, // ✅ Buy Gold text black
                          iconColor: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _enhancedActionButton(
                          'Gift Card',
                          Icons.card_giftcard_outlined,
                          const LinearGradient(
                            colors: [
                              Color(0xFF70002F),
                              Color(0xFF8B1538),
                              Color(0xFF70002F),
                            ],
                          ),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GiftGoldScreen(),
                              ),
                            );
                          },
                          textColor: Colors.white, // ✅ Gift Card text white
                          iconColor:
                              Colors.black, // optional: make icon white too
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Enhanced Promotional Cards with better design
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: PageView(
                padEnds: false,
                controller: PageController(viewportFraction: 0.9),
                scrollDirection: Axis.horizontal,
                children: [
                  // Enhanced First Card
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF70002F),
                          Color(0xFF8B1538),
                          Color(0xFF70002F),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF70002F).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative elements
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Get 24k',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Gold Coin',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFB8860B),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_shipping_outlined,
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Free Delivery',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                // child: const Icon(
                                //   Icons.arrow_forward_rounded,
                                //   color: Colors.white,
                                //   size: 24,
                                // ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Enhanced Second Card
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromARGB(255, 235, 225, 225),
                          Color.fromARGB(255, 245, 230, 110),
                          Color.fromARGB(255, 250, 240, 140),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            255,
                            239,
                            216,
                            88,
                          ).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative elements
                        Positioned(
                          bottom: -30,
                          left: -30,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Save Smartly In',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '24K gold',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFB8860B),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule_outlined,
                                        color: Colors.black54,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Limited Offer',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                // child: const Icon(
                                //   Icons.arrow_forward_rounded,
                                //   color: Colors.black87,
                                //   size: 24,
                                // ),
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

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // 🔹 Enhanced Gold Price Trend
          // Replace the existing Gold Price Trend section in your home screen with this clickable version
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 25,
                        decoration: BoxDecoration(
                          color: AppColors.accentGold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Gold Price Trend',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            150,
                            13,
                            13,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '↗ Live',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // ✅ Make this container clickable
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GoldPriceTrendScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: // Inside your GestureDetector → Container → Consumer<GoldPriceSummaryProvider>
                      Consumer<GoldPriceSummaryProvider>(
                        builder: (context, goldProvider, _) {
                          if (goldProvider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          String _friendlyGoldError(String? msg) {
                            if (msg == null)
                              return "Unable to load gold price trend.";

                            final t = msg.toLowerCase();

                            if (t.contains("jwt") ||
                                t.contains("token") ||
                                t.contains("expired") ||
                                t.contains("unauthorized") ||
                                t.contains("forbidden")) {
                              return "Your session expired. Please login again.";
                            }

                            if (t.contains("network") ||
                                t.contains("connection")) {
                              return "Network issue — please check your internet connection.";
                            }

                            if (t.contains("timeout")) {
                              return "Server took too long to respond. Please try again.";
                            }

                            return "Unable to fetch gold price data. Please try again.";
                          }

                          if (goldProvider.errorMessage != null) {
                            // Show snackbar automatically once
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _friendlyGoldError(
                                      goldProvider.errorMessage,
                                    ),
                                  ),
                                  backgroundColor: AppColors.primaryRed,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            });

                            return Column(
                              children: [
                                const SizedBox(height: 20),
                                Icon(
                                  Icons.error_outline,
                                  color: AppColors.primaryRed,
                                  size: 40,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  _friendlyGoldError(goldProvider.errorMessage),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.primaryRed,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 15),

                                // 🔄 Retry Button
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      goldProvider.fetchGoldPriceSummary(),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("Retry"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.coinBrown,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // 🔐 If expired token → show Login button
                                if (goldProvider.errorMessage!
                                    .toLowerCase()
                                    .contains("token"))
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const MainScreen(
                                            selectedIndex: 4,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Login Again",
                                      style: TextStyle(
                                        color: AppColors.primaryRed,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }

                          // final price = goldProvider.currentPricePerGram;
                          // final perc = goldProvider.percentageChange;
                          // final diff = goldProvider.difference;
                          // final trendInfo = goldProvider.trendInfo;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header row (unchanged)
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        150,
                                        13,
                                        13,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.trending_up_rounded,
                                      color: AppColors.primaryGold,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Today's Performance",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGold.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: AppColors.primaryGold,
                                      size: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),

                              // ---- DYNAMIC PERCENTAGE CHANGE ----
                              Row(
                                children: [
                                  // Icon(trendInfo.icon, color: trendInfo.color, size: 32),
                                  // const SizedBox(width: 8),
                                  Text(
                                    "${goldProvider.percentageChange >= 0 ? '+' : ''}${goldProvider.percentageChange.toStringAsFixed(2)}%",
                                    style: TextStyle(
                                      fontSize: 32,
                                      color: goldProvider.percentageChange >= 0
                                          ? AppColors.coinBrown
                                          : AppColors.primaryRed,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),

                              // ---- CURRENT PRICE ----
                              Text(
                                '₹${goldProvider.currentPricePerGram.toStringAsFixed(2)} / gm',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // ---- DIFFERENCE ----
                              Text(
                                "${goldProvider.difference >= 0 ? '+' : ''}${goldProvider.difference}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: goldProvider.difference >= 0
                                      ? AppColors.coinBrown
                                      : AppColors.primaryRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Tap to view detailed charts',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(
                                    Icons.touch_app_rounded,
                                    color: Colors.black45,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Enhanced Our Trusted Partners
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.fromLTRB(25, 20, 25, 24),
          //     child: Container(
          //       padding: const EdgeInsets.all(20),
          //       decoration: BoxDecoration(
          //         gradient: const LinearGradient(
          //           begin: Alignment.topLeft,
          //           end: Alignment.bottomRight,
          //           colors: [
          //             Color(0xFFFFF8E8),
          //             Color(0xFFFFFDF5),
          //             Colors.white,
          //           ],
          //         ),
          //         borderRadius: BorderRadius.circular(25),
          //         border: Border.all(color: Colors.orange.withOpacity(0.1)),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.black.withOpacity(0.04),
          //             blurRadius: 20,
          //             offset: const Offset(0, 8),
          //           ),
          //         ],
          //       ),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Row(
          //             children: [
          //               Container(
          //                 padding: const EdgeInsets.all(10),
          //                 decoration: BoxDecoration(
          //                   gradient: const LinearGradient(
          //                     colors: [Color(0xFFB8860B), Color(0xFFDAA520)],
          //                   ),
          //                   borderRadius: BorderRadius.circular(15),
          //                 ),
          //                 child: const Icon(
          //                   Icons.verified_outlined,
          //                   color: Colors.white,
          //                   size: 20,
          //                 ),
          //               ),
          //               const SizedBox(width: 12),
          //               const Text(
          //                 "Our Trusted Partners",
          //                 style: TextStyle(
          //                   fontSize: 20,
          //                   fontWeight: FontWeight.w700,
          //                   color: Colors.black87,
          //                 ),
          //               ),
          //             ],
          //           ),
          //           const SizedBox(height: 20),
          //           GridView.builder(
          //             shrinkWrap: true,
          //             physics: const NeverScrollableScrollPhysics(),
          //             itemCount: 12,
          //             gridDelegate:
          //                 const SliverGridDelegateWithFixedCrossAxisCount(
          //                   crossAxisCount: 4,
          //                   mainAxisSpacing: 16,
          //                   crossAxisSpacing: 16,
          //                 ),
          //             itemBuilder: (_, i) {
          //               return _enhancedPartnerLogo("assets/images/logo.png");
          //             },
          //           ),
          //           const SizedBox(height: 25),
          //           SizedBox(
          //             width: double.infinity,
          //             child: ElevatedButton(
          //               style: ElevatedButton.styleFrom(
          //                 backgroundColor: Colors.white,
          //                 foregroundColor: const Color.fromARGB(
          //                   255,
          //                   150,
          //                   13,
          //                   13,
          //                 ),
          //                 elevation: 0,
          //                 padding: const EdgeInsets.symmetric(vertical: 15),
          //                 side: const BorderSide(
          //                   color: Color.fromARGB(255, 150, 13, 13),
          //                   width: 1.5,
          //                 ),
          //                 shape: RoundedRectangleBorder(
          //                   borderRadius: BorderRadius.circular(15),
          //                 ),
          //               ),
          //               onPressed: () {
          //                 Navigator.push(
          //                   context,
          //                   MaterialPageRoute(
          //                     builder: (_) => AllPartnersScreen(),
          //                   ),
          //                 );
          //               },
          //               child: const Row(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 children: [
          //                   Text(
          //                     "View All Partners",
          //                     style: TextStyle(
          //                       fontWeight: FontWeight.w600,
          //                       fontSize: 16,
          //                     ),
          //                   ),
          //                   SizedBox(width: 8),
          //                   Icon(Icons.arrow_forward_rounded, size: 18),
          //                 ],
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          // 🔹 Enhanced Learn More About Us
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 0, 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Title
                  Padding(
                    padding: const EdgeInsets.only(right: 25),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 25,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 150, 13, 13),
                                Color.fromARGB(255, 180, 40, 40),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Learn more about us",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // // 3 Identical Cards – 100% Dynamic from API
                  // SizedBox(
                  //   height: 220,
                  //   child: Consumer<VideoProvider>(
                  //     builder: (context, videoProvider, child) {
                  //       // Loading state
                  //       if (videoProvider.isLoading) {
                  //         return _buildLoadingCards();
                  //       }

                  //       // Find first active video
                  //       final activeVideo = videoProvider.videoList
                  //           .cast<Datum?>()
                  //           .firstWhere(
                  //             (v) => v?.isActive == true,
                  //             orElse: () => null,
                  //           );

                  //       // If no video found → show placeholder cards

                  //       if (activeVideo == null || activeVideo.url.isEmpty) {
                  //         return _buildNoVideoPlaceholder();
                  //       }

                  //       // Success: Use the same video for all 3 cards
                  //       return ListView(
                  //         scrollDirection: Axis.horizontal,
                  //         padding: const EdgeInsets.symmetric(horizontal: 10),
                  //         children: [
                  //           _enhancedLearnCard(
                  //             title: activeVideo.title,
                  //             videoUrl: activeVideo.url,
                  //           ),
                  //           _enhancedLearnCard(
                  //             title: activeVideo.title,
                  //             videoUrl: activeVideo.url,
                  //           ),
                  //           _enhancedLearnCard(
                  //             title: activeVideo.title,
                  //             videoUrl: activeVideo.url,
                  //           ),
                  //         ],
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _enhancedActionButton(
    String label,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap, {
    Color textColor = Colors.white, // 🔹 default is white
    Color iconColor = Colors.black87, // optional icon color
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: textColor, // 🔹 dynamic text color
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _enhancedPartnerLogo(String assetPath) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFB8860B).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: ClipOval(child: Image.asset(assetPath, fit: BoxFit.contain)),
    );
  }

  Widget _enhancedLearnCard({required String title, required String videoUrl}) {
    return GestureDetector(
      onTap: () {
        print("🎬 VIDEO URL → $videoUrl");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(videoUrl: videoUrl, title: title),
          ),
        );
      },

      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 15),
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset("assets/images/kalcoin.jpeg", fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Align(
                    //   alignment: Alignment.topRight,
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    //     decoration: BoxDecoration(
                    //       color: Colors.yellow.withOpacity(0.2),
                    //       borderRadius: BorderRadius.circular(20),
                    //       border: Border.all(color: Colors.white.withOpacity(0.3)),
                    //     ),
                    //     child: const Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Icon(Icons.play_circle_outline, color: Colors.white, size: 14),
                    //         SizedBox(width: 4),
                    //         Text('2 min', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    const Spacer(),

                    Center(
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.coinBrown,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Learn Now',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 14,
                        ),
                      ],
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

  Widget _buildLoadingCards() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.coinBrown),
        ),
      ),
    );
  }

  Widget _buildNoVideoPlaceholder() {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        _enhancedLearnCard(title: "Video Coming Soon", videoUrl: ""),
        _enhancedLearnCard(title: "Video Coming Soon", videoUrl: ""),
        _enhancedLearnCard(title: "Video Coming Soon", videoUrl: ""),
      ],
    );
  }
}

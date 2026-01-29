import 'package:aishwarya_gold/res/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import '../auth_screen/login_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "Invest in Pure 24K Gold",
      "subtitle":
          "Start your investment journey with gold that’s pure and valuable.",
      "image": "assets/images/coin_no_bg.png", // 👈 coin image
    },
    {
      "title": "Save Monthly for Your Dream Jewellery",
      "subtitle":
          "Invest a fixed amount every month for 11 months and redeem your savings.",
      "image": "assets/images/calander.png", // 👈 calendar image
    },
    {
      "title": "Secured & Insured in Protected Vaults",
      "subtitle":
          "Your gold is safely stored in state-of-the-art, insured vaults.",
      "image": "assets/images/locker_bg.png", // 👈 vault image
    },
  ];

  void _onNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 👇 Show different images
                        Image.asset(
                          _pages[index]["image"]!,
                          height: 160,
                          width: 160,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 30),

                        // Title
                        Text(
                          _pages[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Subtitle
                        Text(
                          _pages[index]["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentIndex == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? const Color.fromARGB(255, 150, 13, 13) // red active
                        : Colors.grey.shade400, // inactive
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // Custom Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomButton(
                text: _currentIndex == _pages.length - 1
                    ? "Get Started"
                    : "Next",
                onPressed: _onNext,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppColors {
  // 🔹 Primary Colors
  static const Color primaryGold = Color(0xFFB8860B); // 24k gold
  static const Color primaryRed = Color.fromARGB(255, 150, 13, 13);
  // static const Color primaryWhite = Colors.white;
  // static const Color primaryBlack = Colors.black;

  // 🔹 Backgrounds & Gradients
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromARGB(255, 246, 248, 133),
      Color(0xFFFFFFFF),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 225, 215, 215),
      Color.fromARGB(255, 239, 216, 88),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient partnerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF6E8), Colors.white],
  );

  // 🔹 Common Neutrals
  static const Color textBlack = Colors.black87;
  static const Color textGrey = Colors.grey;
  static const Color dividerGrey = Colors.grey;
  static const Color backgroundLight = Color(0xFFF8F8F8);

  // 🔹 Chart/Price Colors
  // static const Color trendGreen = Colors.green;
  static const Color coinBrown = Color(0xFFC79248);

  // 🔹 Button Colors
  static const Color buttonBg = Colors.white;
  static const Color buttonBorder = primaryRed;
  static const Color buttonText = primaryRed;

  // static const Color primaryGold = Color(0xFFFFD700); // Golden shade
  // static const Color primaryRed = Color(0xFF800000);  // Deep maroon/red

  // Gradients (for backgrounds, buttons, etc.)
  static const LinearGradient goldGradient = LinearGradient(
    colors: [
      Color(0xFFFFD700), // Gold
      Color(0xFFFFC107), // Amber gold
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [
      Color(0xFF800000), // Dark maroon
      Color(0xFFB22222), // Firebrick red
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Colors
  static const Color textGold = Color(0xFFFFD700);
  static const Color textDark = Color(0xFF2C2C2C);
  static const Color textWhite = Colors.white;

  // Background Colors
  static const Color backgroundDarkRed = Color(0xFF4B0000); // Deep background red
  static const Color backgroundWhite = Colors.white;

  // Accent / Icon Colors
  static const Color accentGold = Color(0xFFFFE680); // Soft gold
  static const Color accentRed = Color(0xFFE53935); // Highlight red
  static const Color white = Colors.white;
  static const Color black = Colors.black87;
  static const Color secondaryRed = Color.fromARGB(255, 180, 40, 40);
  static const Color secRed = Color(0xFF6C1013);
  
  static const Color seced = Color.fromRGBO(91, 9, 15, 1); //for splash screen
}

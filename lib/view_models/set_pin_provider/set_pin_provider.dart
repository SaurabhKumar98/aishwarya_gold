// import 'package:flutter/material.dart';

// class SetPinProvider extends ChangeNotifier {
//   final int length = 4;
//   late List<TextEditingController> controllers;
//   late List<FocusNode> focusNodes;

//   // 🔐 Static app PIN
//   final String _staticPin = "1234";

//   SetPinProvider() {
//     controllers = List.generate(length, (_) => TextEditingController());
//     focusNodes = List.generate(length, (_) => FocusNode());
//   }

//   // Check if all PIN boxes are filled
//   bool get isPinFilled => controllers.every((c) => c.text.isNotEmpty);

//   // Get full PIN as string
//   String getPin() => controllers.map((c) => c.text).join();

//   // Validate entered PIN with static PIN
//   bool validatePin() {
//     return getPin() == _staticPin;
//   }

//   // Call this in OtpRow's onChanged
//   void onChanged(String value, int index) {
//     notifyListeners();
//   }
// }

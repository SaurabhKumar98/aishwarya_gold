import 'package:aishwarya_gold/view/auth_screen/kyc_verfication_screen.dart';
import 'package:aishwarya_gold/view/home_container/Buttom_bar.dart';
import 'package:flutter/material.dart';


class AppRoutes {
  static const String kyc = '/kyc';
  static const String dashboard = '/MainScreen';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // kyc: (context) => const KYCScreen(),
      dashboard: (context) => const MainScreen(),
    };
  }
}

import 'package:aishwarya_gold/view/home_container/histroy_screen/history_screen.dart';
import 'package:aishwarya_gold/view/home_container/home_screen/home_screen.dart';
import 'package:aishwarya_gold/view/home_container/investment/invest_screen.dart';
import 'package:aishwarya_gold/view/home_container/my_saving_plan/my_plan_screen/my_plan_screen.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/setting_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final int selectedIndex;
  const MainScreen({super.key, this.selectedIndex = 0}); // default Home


  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
   void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex; // <-- use passed index
  }

  // List of screens to navigate
  final List<Widget> _screens = [
    const HomeScreen(),
    const MyPlanScreen(),
    const InvestmentScreen(),
    const HistoryScreen(userId: '',),
    const SettingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0); // go back to Home tab
          return false; // don't exit app
        }
        return true; // exit app if already on Home
      },
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color.fromARGB(255, 150, 13, 13),
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'My Plan'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Invest'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view/auth_screen/otp_screen.dart';
import 'package:aishwarya_gold/view/auth_screen/set_pin_screen.dart';
import 'package:aishwarya_gold/view/home_container/Buttom_bar.dart';
import 'package:aishwarya_gold/res/widgets/login_widgets.dart';
import 'package:aishwarya_gold/res/widgets/sign_up_widgets.dart';
import 'package:aishwarya_gold/res/widgets/custom_button.dart';
import 'package:aishwarya_gold/res/widgets/troggle_button.dart';
import 'package:aishwarya_gold/view_models/auth_provider/login_provider.dart';
import 'package:aishwarya_gold/view_models/auth_provider/repo_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  final bool initialIsSignUp; // Added to control initial mode
  const AuthScreen({Key? key, this.initialIsSignUp = true}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool isSignUp;
  late TextEditingController _signUpNameController;
  late TextEditingController _signUpPhoneController;
  late TextEditingController _refferalCodeController;
  late TextEditingController _loginPhoneController;
  bool _isFormFilled = false;

  @override
  void initState() {
    super.initState();
    isSignUp = widget.initialIsSignUp; // Set initial mode
    _signUpNameController = TextEditingController()
      ..addListener(_checkFormFilled);
    _signUpPhoneController = TextEditingController()
      ..addListener(_checkFormFilled);
    _loginPhoneController = TextEditingController()
      ..addListener(_checkFormFilled);
    _refferalCodeController = TextEditingController()
      ..addListener(_checkFormFilled);
  }

  void _checkFormFilled() {
    setState(() {
      if (isSignUp) {
        _isFormFilled =
            _signUpNameController.text.isNotEmpty &&
            _signUpPhoneController.text.length == 10;
      } else {
        _isFormFilled = _loginPhoneController.text.length == 10;
      }
    });
  }

  @override
  void dispose() {
    _signUpNameController.dispose();
    _signUpPhoneController.dispose();
    _loginPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registrationProvider = Provider.of<RegistrationProvider>(context);
    return ChangeNotifierProvider(
      create: (_) => LoginProvider(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF9E6), Color(0xFFFFFFFF)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MainScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "SKIP",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          "Welcome!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB8860B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Invest in AISHWARYA GOLD,\nEarn up to 21% Extra p.a.",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ToggleButton(
                              text: "Sign Up",
                              isActive: isSignUp,
                              onPressed: () => setState(() => isSignUp = true),
                            ),
                            const SizedBox(width: 10),
                            ToggleButton(
                              text: "Login",
                              isActive: !isSignUp,
                              onPressed: () => setState(() => isSignUp = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        isSignUp
                            ? SignUpWidget(
                                nameController: _signUpNameController,
                                phoneController: _signUpPhoneController,
                                referralCodeController: _refferalCodeController,
                              )
                            : LoginWidget(
                                phoneController: _loginPhoneController,
                              ),
                        const SizedBox(height: 24),
                        if (registrationProvider.isLoading)
                          const Center(child: CircularProgressIndicator()),
                        if (registrationProvider.errorMessage != null)
                          Center(
                            child: Text(
                              registrationProvider.errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        const SizedBox(height: 200),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              "By proceeding you agree to our",
                              style: TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Terms and Conditions",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 150, 13, 13),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(" & "),
                                Text(
                                  "Privacy Policy",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 150, 13, 13),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: isSignUp
                      ? CustomButton(
                          text: "Continue",
                          isEnabled: _isFormFilled,
                          onPressed: () {
                            registrationProvider.setNamePhone(
                              n: _signUpNameController.text.trim(),
                              p: _signUpPhoneController.text.trim(),
                              referralCode:
                                  _refferalCodeController.text.trim().isNotEmpty
                                  ? _refferalCodeController.text.trim()
                                  : null,
                              context: context,
                            );
                          },
                        )
                      : Consumer<LoginProvider>(
                          builder: (context, loginProvider, child) {
                            return CustomButton(
                              text: loginProvider.isLoading
                                  ? "Loading..."
                                  : "Get OTP",
                              isEnabled:
                                  _isFormFilled && !loginProvider.isLoading,
                              onPressed: () async {
                                final phone = _loginPhoneController.text;
                                await loginProvider.loginUser(phone);
                                if (loginProvider.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        loginProvider.errorMessage!,
                                      ),
                                      backgroundColor: AppColors.primaryRed,
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OtpScreen(
                                        phone: phone,
                                        otp: loginProvider.otp ?? "1234",
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

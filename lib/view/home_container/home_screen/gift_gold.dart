import 'package:aishwarya_gold/data/models/giftmodels/giftmodels_myself.dart';
import 'package:aishwarya_gold/view_models/gift_provider/gift_provider.dart';
import 'package:aishwarya_gold/view_models/razorpay_provider/razorpay_serviceonetime.dart';
import 'package:aishwarya_gold/view_models/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:flutter/services.dart';
import 'confirmgitf_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your gift provider and models
import 'package:aishwarya_gold/data/models/giftmodels/send_giftmodels.dart';

class GiftGoldScreen extends StatefulWidget {
  const GiftGoldScreen({super.key});

  @override
  State<GiftGoldScreen> createState() => _GiftGoldScreenState();
}

class _GiftGoldScreenState extends State<GiftGoldScreen>
    with TickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final RazorpayServiceOneTime _razorpayService = RazorpayServiceOneTime();
  bool _isProcessing = false;
  String? _userId;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final List<int> presetAmounts = [50, 200, 300, 400];
  int? _selectedAmount;
  bool _isOtherSelected = false;
  bool _isForFriend = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _razorpayService.initialize(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  Future<void> _loadUserId() async {
    // Load userId from SharedPreferences or your auth provider
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId') ?? prefs.getString('user_id');
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final giftProvider = Provider.of<GiftProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.isSessionLoaded || userProvider.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User session not loaded. Please login again."),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid amount.")));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      bool success = false;

      if (_isForFriend) {
        // 🎁 Gift for others
        final giftRequest = GiftRequest(
          // userId: userProvider.userId!,
          razorpayOrderId: response.orderId ?? '',
          razorpayPaymentId: response.paymentId ?? '',
          razorpaySignature: response.signature ?? '',
          giftValue: amount,
          giftType: "others",
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _mobileController.text.trim(),
          message: _messageController.text.trim().isEmpty
              ? "Hope you enjoy this gift card!"
              : _messageController.text.trim(),
        );

        success = await giftProvider.sendGift(giftRequest);
      } else {
        // 🎁 Gift for myself
        final mySelfRequest = MySelfGiftRequest(
          // userId: userProvider.userId!,
          razorpayOrderId: response.orderId ?? '',
          razorpayPaymentId: response.paymentId ?? '',
          razorpaySignature: response.signature ?? '',
          giftValue: amount,
          giftType: "myself",
          message: _messageController.text.trim().isEmpty
              ? "A little something for myself!"
              : _messageController.text.trim(),
        );

        success = await giftProvider.sendMySelfGift(mySelfRequest);
      }

      if (!mounted) return;
      Navigator.pop(context); // close loading dialog

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(giftProvider.message ?? "Gift sent successfully!"),
            backgroundColor: AppColors.coinBrown,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ConfirmGiftScreen(
              amount: amount.toDouble(),
              name: _isForFriend ? _nameController.text.trim() : "Self",
              email: _isForFriend ? _emailController.text.trim() : "",
              mobileNumber: _isForFriend ? _mobileController.text.trim() : "",
              message: _messageController.text.trim().isEmpty
                  ? (_isForFriend
                        ? "Hope you enjoy this gift card!"
                        : "A little something for myself!")
                  : _messageController.text.trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(giftProvider.message ?? "Gift failed to send"),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send gift: ${e.toString()}"),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment failed: ${response.message ?? 'Unknown error'}"),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External wallet selected: ${response.walletName}"),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> openCheckOut(int amount) async {
    if (_isProcessing) return;

    // Check if userId is available before proceeding
    if (_userId == null || _userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User ID not found. Please login again."),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    try {
      setState(() => _isProcessing = true);

      await _razorpayService.openCheckout(
        amount: amount,
        description: "Gift Gold Purchase",
        userName: _isForFriend ? _nameController.text.trim() : "Self",
        userContact: _isForFriend ? _mobileController.text.trim() : "",
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error starting payment: $e"),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  bool _isValidInput() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return false;

    if (_isForFriend) {
      final name = _nameController.text.trim();
      final mobile = _mobileController.text.trim();

      if (name.isEmpty) return false;

      // Email validation (optional)
      final email = _emailController.text.trim();

      // STRICT email validation
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9]+[a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );

      if (email.isEmpty ||
          email.startsWith(RegExp(r'[_\.\-]')) || // ❌ Cannot start with _ . -
          email.contains("..") || // ❌ No double dots
          email.contains("__") || // ❌ No double underscore
          email.contains("--") || // ❌ No double hyphen
          !emailRegex.hasMatch(email)) {
        return false;
      }
    }
    return true;
  }

  void _onAmountTap(int? value) {
    setState(() {
      if (value == null) {
        _isOtherSelected = true;
        _selectedAmount = null;
        _amountController.clear();
      } else {
        _isOtherSelected = false;
        _selectedAmount = value;
        _amountController.text = value.toString();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _amountController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: AppColors.backgroundLight,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
              size: 18,
            ),
          ),
        ),
        title: const Text(
          'Gift Card',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Selection Section
              _buildSectionHeader('Choose your amount'),
              const SizedBox(height: 15),

              // Amount Chips
              SizedBox(
                height: 60,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var amt in presetAmounts) ...[
                        _buildAmountChip(
                          text: amt.toString(),
                          selected: _selectedAmount == amt && !_isOtherSelected,
                          onTap: () => _onAmountTap(amt),
                        ),
                        const SizedBox(width: 12),
                      ],
                      _buildAmountChip(
                        text: "Other",
                        selected: _isOtherSelected,
                        onTap: () => _onAmountTap(null),
                        isOther: true,
                      ),
                    ],
                  ),
                ),
              ),

              if (_isOtherSelected) ...[
                const SizedBox(height: 15),
                _buildTextField(
                  controller: _amountController,
                  label: "Enter custom amount",
                  keyboardType: TextInputType.number,
                ),
              ],

              const SizedBox(height: 30),

              // Buy This Gift Card Section
              _buildSectionHeader('Buy this Gift Card'),
              const SizedBox(height: 15),

              // For Friend / For Myself Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildToggleButton("For others", _isForFriend, () {
                      setState(() => _isForFriend = true);
                    }),
                    _buildToggleButton("For myself", !_isForFriend, () {
                      setState(() => _isForFriend = false);
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Friend Details Section
              if (_isForFriend) ...[
                _buildTextField(
                  controller: _nameController,
                  label: "Name*",
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _emailController,
                  label: "Email (Required)",
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  placeholder: "abc@example.com",
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                      RegExp(r'\s'),
                    ), // ❌ No spaces
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z0-9@._-]'), // allowed email characters
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                _buildTextField(
                  controller: _mobileController,
                  label: "Mobile* (Must be registered)",
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  placeholder: "10-digit mobile number",

                  // ✅ Add this for 10-digit restriction
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),

                const SizedBox(height: 25),

                Container(),
                const SizedBox(height: 25),
              ],

              // Message Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _messageController,
                      maxLines: 4,
                      maxLength: 200,
                      decoration: InputDecoration(
                        hintText: "Hope you enjoy this gift card!",
                        hintStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Proceed Button
              Container(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isValidInput() && !_isProcessing
                      ? () {
                          final amount = int.tryParse(
                            _amountController.text.trim(),
                          );
                          if (amount != null && amount > 0) {
                            openCheckOut(amount);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isValidInput() && !_isProcessing
                        ? AppColors.buttonText
                        : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: _isValidInput() && !_isProcessing ? 5 : 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Proceed to payment",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _isValidInput()
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildAmountChip({
    required String text,
    required bool selected,
    required VoidCallback onTap,
    bool isOther = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFB8860B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFB8860B) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFFB8860B).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFB8860B) : Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    String? placeholder,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters, // ✅ WORKING
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.grey.shade600, size: 22)
              : null,
          labelStyle: TextStyle(
            color: Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}

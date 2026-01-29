import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view/auth_screen/login_page.dart';
import 'package:aishwarya_gold/view/home_container/investment/ag_plan_screen/ag_plan/ag_plandescp.dart';
import 'package:aishwarya_gold/view_models/invest_provider/ag_plan_provider.dart';
import 'package:aishwarya_gold/view_models/kyc_provider/kyc_provider.dart';
import 'package:aishwarya_gold/view_models/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AgPlanSelectionScreen extends StatefulWidget {
  const AgPlanSelectionScreen({super.key});

  @override
  State<AgPlanSelectionScreen> createState() => _AgPlanSelectionScreenState();
}

class _AgPlanSelectionScreenState extends State<AgPlanSelectionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final kycProvider = Provider.of<KycStatusProvider>(context, listen: false);

      if (!userProvider.isSessionLoaded) {
        await userProvider.reloadSession();
      }

      // Optional: Pre-fetch KYC status so it's ready when user taps
      if (kycProvider.kycStatus == null) {
        kycProvider.fetchKycStatus();
      }

      await Provider.of<AgPlanProvider>(context, listen: false).fetchPlans();
    });
  }

  void _handlePlanTap(String planId, String userId) {
    final kycProvider = Provider.of<KycStatusProvider>(context, listen: false);
    final kycStatus = kycProvider.kycStatus?.data?.kycStatus?.toLowerCase() ?? 'pending';

    // 1. Check if logged in
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please login to proceed with AG Plan"),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
          // action: SnackBarAction(
          //   label: "Login",
          //   textColor: Colors.white,
          //   // onPressed: () {
          //   //   Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
          //   // },
          // ),
        ),
      );
      return;
    }

    // 2. Check KYC status
    if (kycStatus != 'approved') {
      String message;
      Color bgColor = AppColors.coinBrown;

      if (kycStatus == 'rejected') {
        message = "Your KYC was rejected. Please upload valid documents to continue.";
        bgColor = AppColors.primaryRed;
      } else {
        message = "Your KYC is pending approval. You can proceed once approved.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: bgColor,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          action: kycStatus == 'rejected'
              ? SnackBarAction(
                  label: "Upload Again",
                  textColor: Colors.white,
                  onPressed: () {
                    // Navigator.pushNamed(context, '/kyc-upload');
                  },
                )
              : null,
        ),
      );
      return;
    }

    // All good → Navigate
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Agplandescriptionscreen(
          planId: planId,
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AgPlanProvider, UserProvider>(
      builder: (context, agProvider, userProvider, _) {
        final plans = agProvider.filteredPlans;
        final userId = userProvider.userId ?? "";

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Weekly / Monthly Toggle
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        agProvider.toggleType(AgPlanType.weekly);
                        await agProvider.fetchPlans();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: agProvider.selectedType == AgPlanType.weekly
                              ? AppColors.primaryRed
                              : Colors.grey.shade200,
                        ),
                        child: Center(
                          child: Text(
                            "Weekly",
                            style: TextStyle(
                              color: agProvider.selectedType == AgPlanType.weekly
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        agProvider.toggleType(AgPlanType.monthly);
                        await agProvider.fetchPlans();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: agProvider.selectedType == AgPlanType.monthly
                              ? AppColors.primaryRed
                              : Colors.grey.shade200,
                        ),
                        child: Center(
                          child: Text(
                            "Monthly",
                            style: TextStyle(
                              color: agProvider.selectedType == AgPlanType.monthly
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (agProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (agProvider.error != null)
                Center(
                  child: Text(
                    agProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (plans.isEmpty)
                const Center(child: Text("No plans available"))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final isMonthly = agProvider.selectedType == AgPlanType.monthly;
                    final periodText = isMonthly ? "per month" : "per week";

                    return GestureDetector(
                      onTap: () => _handlePlanTap(plan.id!, userId),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Colors.white, Color(0xFFF5F5F5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade200, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryRed,
                                      AppColors.primaryRed.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Image.asset(
                                  "assets/images/coin_no_bg.png",
                                  width: 38,
                                  height: 38,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plan.name ?? "Unnamed Plan",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      isMonthly ? "Monthly Investment" : "Weekly Investment",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.currency_rupee,
                                            size: 18, color: AppColors.primaryRed),
                                        const SizedBox(width: 4),
                                        Text(
                                          (plan.amount ?? 0).toStringAsFixed(0),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryRed,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          periodText,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Optional: Show lock icon if access blocked
                              if (userId.isEmpty ||
                                  (Provider.of<KycStatusProvider>(context, listen: false)
                                          .kycStatus
                                          ?.data
                                          ?.kycStatus
                                          ?.toLowerCase() !=
                                      'approved'))
                                const Icon(
                                  Icons.lock_outline,
                                  color: Colors.grey,
                                  size: 20,
                                )
                              else
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
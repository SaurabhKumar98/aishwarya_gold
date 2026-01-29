import 'package:aishwarya_gold/core/session/firebaseNotificationMessaging.dart'
    as sip;
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view/home_container/my_saving_plan/saving_plan/my_Saving_screen.dart';
import 'package:aishwarya_gold/view/home_container/my_saving_plan/my_plan_screen/ag_plan_card.dart';
import 'package:aishwarya_gold/view/home_container/my_saving_plan/my_plan_screen/ag_plan_save_screen.dart';
import 'package:aishwarya_gold/view/home_container/my_saving_plan/my_plan_screen/one_time_plan.dart';
import 'package:aishwarya_gold/view/home_container/my_saving_plan/my_plan_screen/sip_plan_card.dart';
import 'package:aishwarya_gold/view_models/invest_provider/ag_plan_provider.dart';
import 'package:aishwarya_gold/view_models/invest_provider/agsaving_provider.dart';
import 'package:aishwarya_gold/view_models/invest_provider/inverst_provider.dart';
import 'package:aishwarya_gold/view_models/invest_provider/onetime_saving_provider.dart';
import 'package:aishwarya_gold/view_models/invest_provider/sip_saving_provider.dart';
import 'package:aishwarya_gold/data/models/savingagplanmodels/agsavingmodels.dart';
import 'package:aishwarya_gold/data/models/agplanmodels/agplanmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  final DateFormat dateFmt = DateFormat('dd-MMM-yyyy');
  final NumberFormat currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // Preload plans
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reset to One Time tab when screen is loaded
      //new added .
      final investmentProvider = Provider.of<InvestmentProvider>(
        context,
        listen: false,
      );
      investmentProvider.togglePlan(InvestmentMode.oneTime);
      final sipProvider = Provider.of<SipSavingProvider>(
        context,
        listen: false,
      );
      sipProvider.fetchSipPlans();

      final onetimeProvider = Provider.of<OnetimeSavingProvider>(
        context,
        listen: false,
      );
      onetimeProvider.fetchOnetimePlans();

      final agProvider = Provider.of<AgSavingProvider>(context, listen: false);
      agProvider.fetchSavingPlan(); // Fetch AG plans on load
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InvestmentProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: const Text(
              "My Saving Plan",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            surfaceTintColor: AppColors.backgroundLight,
          ),
          body: Column(
            children: [
              // Tabs
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      // One Time Tab
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              provider.togglePlan(InvestmentMode.oneTime),
                          child: _tabItem(
                            title: "One Time",
                            isActive: provider.isOneTime,
                          ),
                        ),
                      ),
                      // SIP Tab
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            provider.togglePlan(InvestmentMode.sip);
                            final sipProvider = Provider.of<SipSavingProvider>(
                              context,
                              listen: false,
                            );
                            if (sipProvider.sipPlans.isEmpty &&
                                !sipProvider.isLoading) {
                              sipProvider.fetchSipPlans();
                            }
                          },
                          child: _tabItem(
                            title: "SIP",
                            isActive: provider.isSip,
                          ),
                        ),
                      ),
                      // AG Plan Tab
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            provider.togglePlan(InvestmentMode.ag);
                            final agProvider = Provider.of<AgSavingProvider>(
                              context,
                              listen: false,
                            );
                            if (agProvider.state == AgSavingState.initial) {
                              agProvider.fetchSavingPlan();
                            }
                          },
                          child: _tabItem(
                            title: "AGC Plan",
                            isActive: provider.isAg,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Plans List Section
              Expanded(
                child: provider.isOneTime
                    ? _buildOneTimePlans()
                    : provider.isSip
                    ? _buildSipPlans()
                    : provider.isAg
                    ? _buildAgPlans()
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------- UI HELPERS -------------------

  Widget _tabItem({required String title, required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isActive ? AppColors.primaryRed : Colors.transparent,
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // ------------------- ONE TIME PLANS -------------------

  Widget _buildOneTimePlans() {
    return Consumer<OnetimeSavingProvider>(
      builder: (context, onetimeProvider, _) {
        if (onetimeProvider.isLoading && onetimeProvider.onetime.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (onetimeProvider.error != null) {
          return Center(child: Text("Error: ${onetimeProvider.error}"));
        }

        if (onetimeProvider.onetime.isEmpty) {
          return const Center(child: Text("No One-Time Investments Available"));
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            // Trigger pagination when reaching near the bottom (no visible loader)
            if (!onetimeProvider.isLoading &&
                onetimeProvider.hasMore &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 100) {
              onetimeProvider.fetchOnetimePlans(loadMore: true);
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: () async {
              onetimeProvider.clearData(); // reset pagination
              await onetimeProvider.fetchOnetimePlans(); // reload fresh data
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: onetimeProvider.onetime.length,
              itemBuilder: (context, index) {
                final oneTime = onetimeProvider.onetime[index];

                return OneTimePlanCard(
                  oneTime: oneTime,
                  dateFmt: dateFmt,
                  currency: currency,
                  onTap: () async {
                    final planId = oneTime.id ?? '';
                    if (planId.isEmpty) return;

                    // Show temporary loader dialog only when fetching a specific plan
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    final planDetails = await onetimeProvider.fetchPlanById(
                      planId,
                    );

                    Navigator.pop(context); // close dialog

                    if (planDetails != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MySavingPlan(
                            isOneTime: true,
                            isAgPlan: false,
                            planData: {
                              'id': planDetails.data?.id,
                              'grams':
                                  planDetails.data?.goldQty?.toDouble() ?? 0.0,
                              'amount':
                                  planDetails.data?.totalAmountToPay
                                      ?.toDouble() ??
                                  0.0,
                              'status': planDetails.data?.status ?? 'Active',
                            },
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to fetch plan details'),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ------------------- SIP PLANS -------------------

  // In the _buildSipPlans method, update the navigation part:

  Widget _buildSipPlans() {
    return Consumer<SipSavingProvider>(
      builder: (context, sipProvider, _) {
        if (sipProvider.isLoading && sipProvider.sipPlans.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (sipProvider.error != null) {
          return Center(child: Text("Error: ${sipProvider.error}"));
        }

        if (sipProvider.sipPlans.isEmpty) {
          return const Center(child: Text("No SIP Plans Available"));
        }

        return RefreshIndicator(
          onRefresh: () async => sipProvider.fetchSipPlans(loadMore: false),
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (!sipProvider.isLoading &&
                  sipProvider.hasMore &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 100) {
                sipProvider.fetchSipPlans(loadMore: true);
              }
              return false;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount:
                  sipProvider.sipPlans.length + (sipProvider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == sipProvider.sipPlans.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final sip = sipProvider.sipPlans[index];
                return SipPlanCard(
                  sip: {
                    'startDate': sip.startDate,
                    'amount': sip.investmentAmount,
                    'frequency': sip.frequency,
                    'accumulated': sip.totalInvested,
                    'status': sip.status, // ADD THIS
                    'nextExecutionDate': sip
                        .nextExecutionDate, // ADD THIS TOO (for extra safety)
                  },
                  dateFmt: dateFmt,
                  currency: currency,
                  onTap: () async {
                    final planId = sip.id ?? '';
                    if (planId.isEmpty) return;

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    final success = await sipProvider.fetchPlanDetailsById(
                      planId,
                    );
                    Navigator.pop(context);

                    if (success?.data != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MySavingPlan(
                            isOneTime: false,
                            planId: planId,
                            isAgPlan: false,
                            isSipData: sip,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to fetch plan details'),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
  // ------------------- AG PLANS -------------------

  Widget _buildAgPlans() {
    return Consumer<AgSavingProvider>(
      builder: (context, agProvider, _) {
        if (agProvider.state == AgSavingState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (agProvider.state == AgSavingState.error) {
          return Center(child: Text("Error: ${agProvider.errorMessage}"));
        }

        final agPlans = agProvider.savingPlan?.data ?? [];
        if (agPlans.isEmpty) {
          return const Center(child: Text("No AG Plans Available"));
        }

        return RefreshIndicator(
          onRefresh: () async => agProvider.fetchSavingPlan(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: agPlans.length,
            itemBuilder: (context, index) {
              final agPlan = agPlans[index];
              if (agPlan.planId == null || agPlan.planId!.id == null) {
                debugPrint('Skipping plan with null planId at index $index');
                return const SizedBox.shrink();
              }

              return AgPlanCard(
                agPlan: {
                  'startDate': agPlan.startDate ?? DateTime.now(),
                  'endDate': agPlan.endDate ?? DateTime.now(),
                  'planType': agPlan.planId!.type == 'weekly'
                      ? AgPlanType.weekly
                      : AgPlanType.monthly,
                  'plan': Plan(
                    amount: agPlan.planId!.amount ?? 0,
                    maturityAmount: agPlan.planId!.maturityAmount ?? 0,
                    durationMonths:
                        agPlan.planId!.durationMonths ?? 0, // ADD THIS
                  ),
                },
                dateFmt: dateFmt,
                currency: currency,
                onTap: () {
                  // ✅ CORRECT: Use agPlan.id (Purchase ID)
                  debugPrint(
                    'Purchase ID: ${agPlan.id}',
                  ); // "6913051a56d3068e6e809454"

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AgPlanScreen(
                        planId: agPlan.id!, // ✅ Purchase ID
                        savingPlanId: agPlan.id, // ✅ Same ID
                        userSavingPlan: agPlan,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

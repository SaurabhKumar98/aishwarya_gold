import 'package:aishwarya_gold/data/models/agplanmodels/agplanmodel.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view/home_container/investment/conformpurchase.dart';
import 'package:aishwarya_gold/view_models/invest_provider/ag_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class Agplandescriptionscreen extends StatefulWidget {
  final String planId;
  final String userId;

  const Agplandescriptionscreen({
    super.key,
    required this.planId,
    required this.userId,
  });

  @override
  State<Agplandescriptionscreen> createState() => _AgplandescriptionscreenState();
}

class _AgplandescriptionscreenState extends State<Agplandescriptionscreen> {
  DateTime? _selectedDate = DateTime.now(); // Auto-select today
  DateTime _focusedDay = DateTime.now();
  bool _isCreatingSubscription = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AgPlanProvider>(context, listen: false)
          .fetchPlanById(widget.planId);
    });
  }

  Future<void> _handleProceedToConfirmation(Plan plan) async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a start date"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isCreatingSubscription) {
      return;
    }

    setState(() => _isCreatingSubscription = true);

    try {
      

      final agPlanProvider = Provider.of<AgPlanProvider>(context, listen: false);

      // Step 1: Create AG Plan subscription
      final result = await agPlanProvider.createAgPlanSubscription(
        userId: widget.userId,
        planId: widget.planId,
        startDate: _selectedDate!,
      );

      if (!mounted) return;

      if (result == null || result['razorpay']?['subscriptionId'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to create AG Plan subscription. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isCreatingSubscription = false);
        return;
      }

      final subscriptionId = result['razorpay']['subscriptionId'];

      // Calculate end date (1 year from start date)
      final endDate = DateTime(
        _selectedDate!.year + 1,
        _selectedDate!.month,
        _selectedDate!.day,
      );

      final AgPlanType planType = plan.type == "weekly"
          ? AgPlanType.weekly
          : AgPlanType.monthly;

      // Step 2: Navigate to confirmation screen with subscription ID
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Agplanconfirmscreen(
            amount: plan.amount ?? 0,
            selectedPlan: plan,
            startDate: _selectedDate!,
            endDate: endDate,
            planType: planType,
            selectedUserid: widget.userId,
            subscriptionId: subscriptionId, // Pass subscription ID
          ),
        ),
      ).then((_) {
        // Reset loading state when returning from confirmation screen
        if (mounted) {
          setState(() => _isCreatingSubscription = false);
        }
      });
    } catch (e, st) {
    

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isCreatingSubscription = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AgPlanProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6F8),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primaryRed,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Loading plan details...",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6F8),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                "Plan Details",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final plan = provider.selectedPlan;
        if (plan == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F6F8),
            body: Center(
              child: Text(
                "No plan found",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6F8),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
              onPressed: _isCreatingSubscription ? null : () => Navigator.pop(context),
            ),
            title: Text(
              plan.name ?? "AG Plan",
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Plan Header Card
                        _buildPlanHeaderCard(plan),
                        
                        const SizedBox(height: 20),
                        
                        // Investment Details
                        _buildSectionTitle("Investment Details"),
                        const SizedBox(height: 12),
                        _buildDetailsCard(plan),
                        
                        const SizedBox(height: 20),
                        
                        // Returns Card
                        _buildReturnsCard(plan),
                        
                        const SizedBox(height: 24),
                        
                        // Calendar Section - Now shows only today
                        _buildSectionTitle("Start Date"),
                        const SizedBox(height: 12),
                        _buildCalendar(),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Fixed Bottom Button
              _buildFixedBottomButton(plan),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlanHeaderCard(Plan plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFB8860B),
            const Color(0xFFFFD700),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB8860B).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            plan.name ?? "AG Plan",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${plan.durationMonths ?? 0} ${plan.type == "weekly" ? "Week" : "Month"}${plan.durationMonths == 1 ? "" : "s"} Investment",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDetailsCard(Plan plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            Icons.payments,
            plan.type == "weekly" ? "Weekly Amount" : "Monthly Amount",
            "₹${plan.amount ?? 0}",
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.calendar_month,
            "Duration",
            "${plan.durationMonths ?? 0} ${plan.type == "weekly" ? "week" : "month"}${plan.durationMonths == 1 ? "" : "s"}",
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.account_balance_wallet,
            "Total Investment",
            "₹${plan.totalInvestment ?? 0}",
          ),
        ],
      ),
    );
  }

  Widget _buildReturnsCard(Plan plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFB8860B).withOpacity(0.1),
            const Color(0xFFFFD700).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB8860B).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8860B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFFB8860B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Expected Returns",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Profit Bonus",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "₹${plan.profitBonus ?? 0}",
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Maturity Amount",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "₹${plan.maturityAmount ?? 0}",
                style: const TextStyle(
                  color: Color(0xFFB8860B),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFFB8860B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TableCalendar(
          // CHANGED: Set first and last day to today only
          firstDay: todayOnly,
          lastDay: todayOnly,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
          calendarFormat: CalendarFormat.month,
          // CHANGED: Disable all gestures including swipe
          availableGestures: AvailableGestures.none,
          // CHANGED: Only allow today to be selected
          onDaySelected: (selectedDay, focusedDay) {
            if (isSameDay(selectedDay, todayOnly)) {
              setState(() {
                _selectedDate = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          // CHANGED: Disable month changing
          onPageChanged: null,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            // CHANGED: Hide chevrons since user can't navigate
            leftChevronVisible: false,
            rightChevronVisible: false,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            // Today is both today and selected
            todayDecoration: BoxDecoration(
              color: AppColors.primaryRed,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: AppColors.primaryRed,
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            defaultTextStyle: const TextStyle(
              color: Colors.black87,
            ),
            weekendTextStyle: const TextStyle(
              color: Colors.black87,
            ),
            disabledTextStyle: TextStyle(
              color: Colors.grey.shade300,
            ),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            weekendStyle: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          // CHANGED: Enable only today
          enabledDayPredicate: (day) {
            return isSameDay(day, todayOnly);
          },
        ),
      ),
    );
  }

  Widget _buildFixedBottomButton(Plan plan) {
    final isDateSelected = _selectedDate != null;
    final isDisabled = !isDateSelected || _isCreatingSubscription;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDateSelected)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8860B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.event_available,
                      size: 16,
                      color: Color(0xFFB8860B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Start Date: Today (${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year})",
                      style: const TextStyle(
                        color: Color(0xFFB8860B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isDisabled
                    ? null
                    : () => _handleProceedToConfirmation(plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreatingSubscription
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Creating Subscription...",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        "Proceed to Confirmation",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
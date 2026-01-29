import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view_models/pausesip_provider/pausesip_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PauseSipScreen extends StatefulWidget {
  final String planId;

  const PauseSipScreen({super.key, required this.planId});

  @override
  State<PauseSipScreen> createState() => _PauseSipScreenState();
}

class _PauseSipScreenState extends State<PauseSipScreen> {
  int? selectedMonths;

  @override
  Widget build(BuildContext context) {
    final pauseProvider = Provider.of<PauseSipProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: AppColors.backgroundLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pause SIP Plan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryRed.withOpacity(0.1),
                      AppColors.primaryRed.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryRed.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.pause_circle_outline,
                        color: AppColors.primaryRed,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Temporary Pause",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Your SIP will automatically resume after the selected duration",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Duration Selection Section
              const Text(
                "Select Pause Duration",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Choose how long you want to pause your SIP investments",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 20),

              // Custom Duration Cards
              _buildDurationOption(1, "1 Month", "Resume on ${_getResumeDate(1)}"),
              const SizedBox(height: 12),
              _buildDurationOption(2, "2 Months", "Resume on ${_getResumeDate(2)}"),
              const SizedBox(height: 12),
              _buildDurationOption(3, "3 Months", "Resume on ${_getResumeDate(3)}"),

              const SizedBox(height: 32),

              // Important Notes
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber[800],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Important Notes:",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "• No installments will be deducted during pause\n"
                            "• Your plan will auto-resume after the period\n"
                            "• You can resume manually anytime",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Pause Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedMonths == null
                        ? Colors.grey[300]
                        : AppColors.primaryRed,
                    foregroundColor: selectedMonths == null
                        ? Colors.grey[500]
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: selectedMonths == null ? 0 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: selectedMonths == null || pauseProvider.isLoading
                      ? null
                      : () => _handlePause(pauseProvider),
                  child: pauseProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.pause_circle, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              selectedMonths == null
                                  ? "Select Duration to Continue"
                                  : "Pause SIP for $selectedMonths Month${selectedMonths! > 1 ? 's' : ''}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: pauseProvider.isLoading
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationOption(int months, String title, String subtitle) {
    final isSelected = selectedMonths == months;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMonths = months;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // color: isSelected ? AppColors.primaryRed.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          // boxShadow: isSelected
          //     ? [
          //         BoxShadow(
          //           color: AppColors.primaryRed.withOpacity(0.1),
          //           blurRadius: 8,
          //           offset: const Offset(0, 2),
          //         ),
          //       ]
              // : [],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryRed : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? AppColors.primaryRed : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primaryRed : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            // if (isSelected)
            //   Icon(
            //     Icons.arrow_forward_ios,
            //     size: 16,
            //     color: AppColors.primaryRed,
            //   ),
          ],
        ),
      ),
    );
  }

  String _getResumeDate(int months) {
    final resumeDate = DateTime.now().add(Duration(days: months * 30));
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${resumeDate.day} ${monthNames[resumeDate.month - 1]}, ${resumeDate.year}";
  }

  Future<void> _handlePause(PauseSipProvider pauseProvider) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.pause_circle, color: AppColors.primaryRed),
            const SizedBox(width: 12),
            const Text("Confirm Pause"),
          ],
        ),
        content: Text(
          "Are you sure you want to pause your SIP for $selectedMonths month${selectedMonths! > 1 ? 's' : ''}?\n\n"
          "Your plan will automatically resume on ${_getResumeDate(selectedMonths!)}.",
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm Pause"),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await pauseProvider.pauseSipPlan(
      widget.planId,
      selectedMonths!,
    );

    if (!mounted) return;

    // Show result snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                success
                    ? "✓ SIP plan paused for $selectedMonths month${selectedMonths! > 1 ? 's' : ''}"
                    : pauseProvider.error ?? "Failed to pause SIP plan",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: success ? AppColors.coinBrown : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );

    if (success) {
      Navigator.pop(context, true);
    }
  }
}
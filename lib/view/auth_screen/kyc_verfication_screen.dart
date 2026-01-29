import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/res/widgets/custom_button.dart';
import 'package:aishwarya_gold/res/widgets/custom_error.dart';
import 'package:aishwarya_gold/view/auth_screen/login_page.dart';
import 'package:aishwarya_gold/view_models/auth_provider/repo_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path; // <-- Add this import

class KYCScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String pin;
  final String? referralCode;

  const KYCScreen({
    Key? key,
    required this.name,
    required this.phone,
    required this.pin,
    this.referralCode,
  }) : super(key: key);

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> {
  @override
  void initState() {
    super.initState();

    // Only set referralCode — name/phone/pin are already in provider!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RegistrationProvider>(context, listen: false);
      provider.referralCode = widget.referralCode;

      debugPrint(
          "KYCScreen init → Name: ${widget.name}, Phone: ${widget.phone}, PIN: ${widget.pin}, Referral: ${widget.referralCode}");
    });
  }

  // --- Safe file picker ---
  Future<void> pickFile(BuildContext context, Function(String) onFilePicked) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = path.basename(filePath); // Safe basename

        onFilePicked(filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Uploaded: $fileName"),
            backgroundColor: AppColors.primaryGold,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No file selected"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- Reusable Upload Card ---
  Widget modernUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isUploaded,
    required VoidCallback onTap,
    String? filePath,
  }) {
    final fileName = filePath != null ? path.basename(filePath) : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? AppColors.coinBrown : Colors.grey.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: isUploaded
                    ? AppColors.goldGradient
                    : LinearGradient(colors: [Colors.grey[300]!, Colors.grey[400]!]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle_rounded : icon,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              isUploaded && fileName != null ? "Uploaded: $fileName" : subtitle,
              style: TextStyle(
                fontSize: 13,
                color: isUploaded ? AppColors.coinBrown : Colors.grey[600],
                fontWeight: isUploaded ? FontWeight.w500 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationProvider>(
      builder: (context, regProvider, child) {
        final canSubmit = regProvider.isPanUploaded &&
            regProvider.isAadhaarUploaded &&
            !regProvider.isLoading;

        return Scaffold(
          backgroundColor: AppColors.backgroundWhite,
          appBar: AppBar(
              leading: Container(
          margin: const EdgeInsets.all(8),
          // decoration: BoxDecoration(
          //   color: Colors.grey.shade100,
          //   borderRadius: BorderRadius.circular(12),
          // ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AuthScreen()),
    )
          ),
        ),
            title: const Text(
              "KYC Verification",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppColors.textDark,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // --- Welcome Card ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.coinBrown,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.verified_user_rounded, size: 50, color: Colors.white),
                      const SizedBox(height: 16),
                      const Text(
                        "Verify Your Identity",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Hi ${widget.name}!\nUpload your documents to complete registration",
                        style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // --- PAN Card ---
                modernUploadCard(
                  title: 'PAN Card',
                  subtitle: 'Upload PAN card document',
                  icon: Icons.insert_drive_file_rounded,
                  isUploaded: regProvider.isPanUploaded,
                  filePath: regProvider.pan,
                  onTap: () => pickFile(context, regProvider.uploadPan),
                ),
                const SizedBox(height: 20),

                // --- Aadhaar Card ---
                modernUploadCard(
                  title: 'Aadhaar Card',
                  subtitle: 'Upload Aadhaar document',
                  icon: Icons.insert_drive_file_rounded,
                  isUploaded: regProvider.isAadhaarUploaded,
                  filePath: regProvider.aadhar,
                  onTap: () => pickFile(context, regProvider.uploadAadhaar),
                ),
                const SizedBox(height: 24),

                // --- Loading / Error ---
                if (regProvider.isLoading)
                  const Center(child: CircularProgressIndicator()),

                if (regProvider.errorMessage != null)
  CustomErrorWidget(
    message: regProvider.errorMessage!,
    onRetry: regProvider.isLoading
        ? null
        : () => regProvider.submitKYC(context), // retry same action
    icon: Icons.cloud_off_rounded,
    backgroundColor: Colors.red.shade50,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),

                const SizedBox(height: 16),

                // --- Submit Button ---
                CustomButton(
                  text: regProvider.isLoading ? "Submitting..." : "Submit KYC",
                  isEnabled: canSubmit,
                  onPressed: canSubmit
                      ? () async {
                          debugPrint("\nSubmitting KYC:");
                          debugPrint("   Name: ${widget.name}");
                          debugPrint("   Phone: ${widget.phone}");
                          debugPrint("   PIN: ${widget.pin}");
                          debugPrint("   PAN: ${regProvider.pan}");
                          debugPrint("   Aadhaar: ${regProvider.aadhar}");
                          debugPrint("   Referral: ${regProvider.referralCode}");

                          await regProvider.submitKYC(context);
                        }
                      : null,
                  color: AppColors.primaryGold,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
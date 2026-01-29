
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view_models/kyc_provider/kyc_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class KYCStatusScreen extends StatefulWidget {
  const KYCStatusScreen({super.key});

  @override
  State<KYCStatusScreen> createState() => _KYCStatusScreenState();
}

class _KYCStatusScreenState extends State<KYCStatusScreen> {
  File? _aadhaarFile;
  File? _panFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<KycStatusProvider>(context, listen: false).fetchKycStatus();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return AppColors.coinBrown;
      case "rejected":
        return Colors.red;
      default:
        return AppColors.coinBrown;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Icons.verified_user;
      case "rejected":
        return Icons.cancel;
      default:
        return Icons.hourglass_bottom;
    }
  }

  String _getMessage(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return "Your KYC verification is complete! You can now access all features.";
      case "rejected":
        return "Your KYC was rejected. Please re-upload valid documents.";
      default:
        return "Your KYC is under review. We will notify you once it's verified.";
    }
  }

  Future<void> _pickDocument(String docType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
);
      if (result != null && result.files.single.path != null) {
        setState(() {
          if (docType == 'aadhaar') {
            _aadhaarFile = File(result.files.single.path!);
          } else {
            _panFile = File(result.files.single.path!);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${docType == 'aadhaar' ? 'Aadhaar' : 'PAN'} card selected'),
            backgroundColor: AppColors.coinBrown,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    print("Launching URL: $url");
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open document'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  String _friendlyKycError(String? msg) {
  if (msg == null) return "Something went wrong.";

  msg = msg.toLowerCase();

  if (msg.contains("unauthorized") ||
      msg.contains("token") ||
      msg.contains("expired")) {
    return "Your session has expired. Please login again.";
  }

  if (msg.contains("not found")) {
    return "KYC details not found.";
  }

  return "Unable to load KYC status. Please try again.";
}


  @override
  Widget build(BuildContext context) {
    return Consumer<KycStatusProvider>(
      builder: (context, provider, child) {
        // Loading state
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error state
        if (provider.errorMessage != null) {

  // Show SnackBar once when error occurs
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Unable to load KYC status. Please login again."),
        backgroundColor: AppColors.primaryGold,
        behavior: SnackBarBehavior.floating,
      ),
    );
  });

  return Scaffold(
    appBar: AppBar(title: const Text("KYC Status")),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _friendlyKycError(provider.errorMessage),
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.fetchKycStatus(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}


        // Data available
        final kycData = provider.kycStatus?.data;
        final kycStatus = kycData?.kycStatus ?? "Pending";
        final isPending = kycStatus.toLowerCase() == "pending";
        final isRejected = kycStatus.toLowerCase() == "rejected";
        final isVerified = kycStatus.toLowerCase() == "approved";

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text(
              "KYC Status",
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Status Card
                  _buildStatusCard(kycStatus),

                  // Pending: Show submitted documents
                  if (isPending && kycData != null) ...[
                    const SizedBox(height: 24),
                    _buildDocumentSection(kycData.pancard, kycData.aadharcard),
                  ],

                  // Rejected: Show upload section
                  if (isRejected) ...[
                    const SizedBox(height: 24),
                    _buildUploadSection(provider),
                  ],

                  // Verified: Show features
                  if (isVerified) ...[
                    const SizedBox(height: 24),
                    _buildFeatureItem(Icons.shopping_bag_outlined, 'Full Access',
                        'Complete access to all features', AppColors.coinBrown),
                    const SizedBox(height: 12),
                    _buildFeatureItem(Icons.security, 'Secure Account',
                        'Your account is fully verified', AppColors.coinBrown),
                    const SizedBox(height: 12),
                    _buildFeatureItem(Icons.savings_outlined, 'Premium Plans',
                        'Access to exclusive gold plans', Colors.amber),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(String kycStatus) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getStatusColor(kycStatus).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(kycStatus),
              size: 64,
              color: _getStatusColor(kycStatus),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            kycStatus,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(kycStatus),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getMessage(kycStatus),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection(List<String> pancard, String aadharcard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.coinBrown,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.description, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text('Submitted Documents',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildDocumentViewCard(
          title: 'Aadhaar Card',
          url: aadharcard.isNotEmpty ? aadharcard : 'No Aadhaar card uploaded',
          icon: Icons.credit_card,
          onTap: aadharcard.isNotEmpty ? () => _launchUrl(aadharcard) : null,
        ),
        const SizedBox(height: 16),
        _buildDocumentViewCard(
          title: 'PAN Card',
          url: pancard.isNotEmpty ? pancard[0] : 'No PAN card uploaded',
          icon: Icons.badge,
          onTap: pancard.isNotEmpty ? () => _launchUrl(pancard[0]) : null,
        ),
      ],
    );
  }

  Widget _buildDocumentViewCard({
    required String title,
    required String url,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.grey.shade600),
          title: Text(title),
          subtitle: Text(
            url,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: onTap != null
              ? const Icon(Icons.open_in_new, color: AppColors.coinBrown)
              : null,
        ),
      ),
    );
  }

  Widget _buildUploadSection(KycStatusProvider provider) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.coinBrown,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.upload_file, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text('Upload Documents',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildDocumentUploadCard(
          title: 'Aadhaar Card',
          subtitle: 'Upload your Aadhaar card (PDF / JPG / PNG)',

          icon: Icons.credit_card,
          file: _aadhaarFile,
          onTap: () => _pickDocument('aadhaar'),
          onRemove: () => setState(() => _aadhaarFile = null),
        ),
        const SizedBox(height: 16),
        _buildDocumentUploadCard(
              title: 'PAN Card',
              subtitle: 'Upload your PAN card (PDF / JPG / PNG)',
          icon: Icons.badge,
          file: _panFile,
          onTap: () => _pickDocument('pan'),
          onRemove: () => setState(() => _panFile = null),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: provider.isUploading || _aadhaarFile == null || _panFile == null
                ? null
                : () async {
                    await provider.uploadKycDocuments(_aadhaarFile!.path, _panFile!.path);
                    if (provider.errorMessage == null && provider.kycStatus?.success == true) {
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: Row(
                              children: [
                                Icon(Icons.check_circle, color: AppColors.coinBrown, size: 28),
                                const SizedBox(width: 12),
                                const Text('Success!'),
                              ],
                            ),
                            content: const Text(
                              'Your documents have been submitted successfully. We will review them within 24-48 hours.',
                            ),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGold,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  setState(() {
                                    _aadhaarFile = null;
                                    _panFile = null;
                                  });
                                  provider.fetchKycStatus(); // Refresh status
                                },
                                child: const Text('OK', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.errorMessage ?? 'Upload failed'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: provider.isUploading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Submit Documents",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required File? file,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final hasFile = file != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasFile ? AppColors.coinBrown : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Icon(hasFile ? Icons.check_circle : icon,
            color: hasFile ? AppColors.coinBrown : Colors.grey.shade600),
        title: Text(title),
        subtitle: Text(hasFile ? file!.path.split('/').last : subtitle),
        trailing: hasFile
            ? IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, color: Colors.red),
              )
            : IconButton(
                onPressed: onTap,
                icon: const Icon(Icons.upload_file),
              ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
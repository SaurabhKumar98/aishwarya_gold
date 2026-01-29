import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view/home_container/setting_screen/profile_screen/profile_screen.dart';
import 'package:aishwarya_gold/view_models/profile_provider/edit_profile_provider.dart';
import 'package:aishwarya_gold/view_models/profile_provider/profiledetails_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProfiledetailsProvider>(context, listen: false)
          .fetchProfileDetails();
      Provider.of<EditProfileProvider>(context, listen: false);
    });
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );

    // If profile was successfully updated, refresh the data
    if (result == true && mounted) {
      final provider = Provider.of<ProfiledetailsProvider>(
        context,
        listen: false,
      );
      await provider.fetchProfileDetails();
    }
  }
  String _friendlyProfileError(String? msg) {
  if (msg == null) return "Unable to load your profile.";

  final text = msg.toLowerCase();

  if (text.contains("unauthorized") ||
      text.contains("token") ||
      text.contains("expired") ||
      text.contains("forbidden")) {
    return "Your session has expired. Please login again.";
  }

  if (text.contains("not found")) {
    return "Profile information not found.";
  }

  return "Unable to load your profile. Please try again.";
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<ProfiledetailsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.coinBrown,
              ),
            );
          }

         if (provider.error != null) {
  
  // 🔥 Show user-friendly SnackBar only once
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Unable to load profile. Please login again."),
        backgroundColor: AppColors.primaryGold,
        behavior: SnackBarBehavior.floating,
      ),
    );
  });

  return Center(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: screenWidth * 0.15,
            color: AppColors.primaryRed,
          ),
          SizedBox(height: screenHeight * 0.02),

          // 🎨 Friendly Error Message
          Text(
            _friendlyProfileError(provider.error),
            style: TextStyle(
              color: AppColors.primaryRed,
              fontSize: screenWidth * 0.04,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: screenHeight * 0.03),

          // 🔄 Retry Button
          ElevatedButton.icon(
            onPressed: provider.fetchProfileDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coinBrown,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenHeight * 0.015,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


          final data = provider.profileDetails?.data;
          if (data == null) {
            return const Center(child: Text("No profile data found."));
          }

          return RefreshIndicator(
            color: AppColors.coinBrown,
            onRefresh: provider.refreshProfile,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Custom App Bar with Profile Header
                SliverAppBar(
                  expandedHeight: screenHeight * 0.35,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.coinBrown,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.coinBrown, AppColors.primaryRed],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: screenHeight * 0.05),
                              // Profile Picture
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: screenWidth * 0.15,
                                  backgroundColor: Colors.grey[300],
                                  child: (data.profile != null && 
                                          data.profile!.isNotEmpty)
                                      ? ClipOval(
                                          child: Image.network(
                                            data.profile!,
                                            width: screenWidth * 0.3,
                                            height: screenWidth * 0.3,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, 
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress
                                                      .expectedTotalBytes != null
                                                      ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                      : null,
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              );
                                            },
                                            errorBuilder: (_, __, ___) {
                                              return Icon(
                                                Icons.person,
                                                size: screenWidth * 0.15,
                                                color: Colors.grey[600],
                                              );
                                            },
                                          ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: screenWidth * 0.15,
                                          color: Colors.grey[600],
                                        ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              // Name
                              Flexible(
                                child: Text(
                                  (data.name?.isNotEmpty ?? false) 
                                      ? data.name! 
                                      : 'Unknown User',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.06,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              // Contact Info
                              Flexible(
                                child: _buildContactChip(
                                  icon: Icons.email_outlined,
                                  text: (data.email != null && 
                                         data.email.toString().isNotEmpty)
                                      ? data.email.toString()
                                      : 'No email',
                                  screenWidth: screenWidth,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.008),
                              Flexible(
                                child: _buildContactChip(
                                  icon: Icons.phone_outlined,
                                  text: (data.phone?.isNotEmpty ?? false) 
                                      ? data.phone! 
                                      : 'No phone',
                                  screenWidth: screenWidth,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // KYC Status Card
                        _buildKycStatusCard(data, screenWidth, screenHeight),
                        SizedBox(height: screenHeight * 0.025),

                        // Section Header
                        _buildSectionHeader('Documents', screenWidth),
                        SizedBox(height: screenHeight * 0.015),

                        // Documents
                        _buildDocumentTile(
                          title: 'PAN Card',
                          icon: Icons.credit_card_rounded,
                          isUploaded: data.pancard != null && 
                                     data.pancard!.isNotEmpty,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        _buildDocumentTile(
                          title: 'Aadhar Card',
                          icon: Icons.badge_rounded,
                          isUploaded: data.aadharcard != null && 
                                     data.aadharcard!.isNotEmpty,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),
                        SizedBox(height: screenHeight * 0.025),

                        // Member Info
                        _buildInfoCard(
                          icon: Icons.calendar_today_rounded,
                          label: 'Member Since',
                          value: (data.createdAt != null)
                              ? data.createdAt!.toLocal()
                                  .toString().split(' ').first
                              : 'N/A',
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),
                        SizedBox(height: screenHeight * 0.035),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: _navigateToEditProfile,
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: screenWidth * 0.042,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactChip({
    required IconData icon,
    required String text,
    required double screenWidth,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: screenWidth * 0.85),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: screenWidth * 0.04, color: Colors.white),
          SizedBox(width: screenWidth * 0.02),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycStatusCard(
    dynamic data,
    double screenWidth,
    double screenHeight,
  ) {
    final isVerified = (data.kycStatus?.toLowerCase() ?? '') == 'verified';
    final statusColor = isVerified ? Colors.green[700]! : Colors.orange[700]!;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.045),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isVerified
              ? [Colors.green[50]!, Colors.green[100]!]
              : [Colors.orange[50]!, Colors.orange[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.035),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isVerified ? Icons.verified : Icons.pending,
              color: statusColor,
              size: screenWidth * 0.07,
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KYC Status',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: screenWidth * 0.033,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  (data.kycStatus != null && data.kycStatus!.isNotEmpty)
                      ? data.kycStatus!.toUpperCase()
                      : 'NOT VERIFIED',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, double screenWidth) {
    return Text(
      title,
      style: TextStyle(
        fontSize: screenWidth * 0.05,
        fontWeight: FontWeight.bold,
        color: AppColors.coinBrown,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildDocumentTile({
    required String title,
    required IconData icon,
    required bool isUploaded,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded 
              ? AppColors.coinBrown.withOpacity(0.4) 
              : Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.025),
            decoration: BoxDecoration(
              color: isUploaded 
                  ? AppColors.coinBrown.withOpacity(0.1) 
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isUploaded ? AppColors.coinBrown : Colors.grey[400],
              size: screenWidth * 0.06,
            ),
          ),
          SizedBox(width: screenWidth * 0.035),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                color: isUploaded ? Colors.black87 : Colors.grey[600],
              ),
            ),
          ),
          Icon(
            isUploaded ? Icons.check_circle : Icons.upload_outlined,
            color: isUploaded ? Colors.green[600] : Colors.grey[400],
            size: screenWidth * 0.055,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.045),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.coinBrown.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.025),
            decoration: BoxDecoration(
              color: AppColors.coinBrown.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: screenWidth * 0.055,
              color: AppColors.coinBrown,
            ),
          ),
          SizedBox(width: screenWidth * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: screenWidth * 0.033,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
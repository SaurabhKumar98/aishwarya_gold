// Complete Fixed jewellery_redemption_screen.dart

import 'package:aishwarya_gold/data/models/storemodels/store_models.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view_models/reedemption_provider/reedemption_provider.dart';
import 'package:aishwarya_gold/view_models/store_provider/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Refferalredemptionreqest extends StatefulWidget {
  final String? planId;
  final String? planType;
   final double? walletBalance;
  
  const Refferalredemptionreqest({
    this.planId,
    this.planType,
     this.walletBalance,
    super.key,
  });

  @override
  State<Refferalredemptionreqest> createState() =>
      _RefferalredemptionreqestState();
}

class _RefferalredemptionreqestState extends State<Refferalredemptionreqest> {
  // Store redemption info per store: storeId -> {status, redemptionId}
  Map<String, Map<String, dynamic>> _storeRedemptions = {};
  bool _isCheckingStatus = true;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().fetchStores();
      _checkExistingRedemptionStatus();
    });
  }

  // Check redemption status for this plan across all stores
  Future<void> _checkExistingRedemptionStatus() async {
    if (widget.planType != 'WalletBalance' && widget.planId == null) {
  setState(() => _isCheckingStatus = false);
  return;
}


    try {
      final provider = context.read<RedemptionProvider>();
      
      // Get redemption info including storeId
      final redemptionInfo = provider.getPlanRedemptionWithStore(widget.planId!);
      
      if (mounted && redemptionInfo != null) {
        setState(() {
          _storeRedemptions[redemptionInfo['storeId']] = {
            'status': redemptionInfo['status'],
            'redemptionId': redemptionInfo['redemptionId'],
          };
          _isCheckingStatus = false;
        });
      } else {
        setState(() => _isCheckingStatus = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingStatus = false);
      }
    }
  }

  String _getStoreStatus(String? storeId) {
    if (storeId == null) return 'none';
    return _storeRedemptions[storeId]?['status'] ?? 'none';
  }

  String? _getStoreRedemptionId(String? storeId) {
    if (storeId == null) return null;
    return _storeRedemptions[storeId]?['redemptionId'];
  }

  Future<void> _openGoogleMaps(String? mapUrl, String? location) async {
    if (mapUrl != null && mapUrl.isNotEmpty) {
      final uri = Uri.parse(mapUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open map');
      }
    } else if (location != null && location.isNotEmpty) {
      final encodedLocation = Uri.encodeComponent(location);
      final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedLocation',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open map');
      }
    } else {
      _showErrorSnackBar('Location not available');
    }
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showErrorSnackBar('Phone number not available');
      return;
    }

    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showErrorSnackBar('Could not make call');
    }
  }

  void _navigateToRedeemScreen(StoreData store) {
    final currentStatus = _getStoreStatus(store.id);
    
    // If already approved for this store, don't allow navigation
    if (currentStatus == 'approved') {
      _showFriendlySnackBar(
        'Your gold redemption for this store has already been approved! Please visit to collect.',
        type: SnackBarType.info,
      );
      return;
    }
    
    // If pending for this store, inform user
    if (currentStatus == 'pending') {
      _showFriendlySnackBar(
        'You already have a pending redemption request for this store. Please wait for approval.',
        type: SnackBarType.info,
      );
      return;
    }

    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RedeemInstructionScreen(
      store: store,
      planId: widget.planId,
      planType: widget.planType,
      walletBalance: widget.walletBalance, // ✅ PASS IT
    ),
  ),
)
.then((result) {
      if (result != null && result is Map && mounted) {
        setState(() {
          _storeRedemptions[store.id!] = {
            'status': result['status'],
            'redemptionId': result['redemptionId'],
          };
        });
      }
    });
  }

  Future<void> _cancelRedemption(String storeId, String redemptionId) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Redemption?'),
        content: const Text('Are you sure you want to cancel this redemption request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldCancel != true) return;

    try {
      final provider = context.read<RedemptionProvider>();
      final success = await provider.cancelRedemptionRequest(redemptionId);

      if (!mounted) return;

      if (success) {
        setState(() {
          _storeRedemptions.remove(storeId);
        });
        _showFriendlySnackBar(
          'Request cancelled successfully',
          type: SnackBarType.success,
        );
      } else {
        _showFriendlySnackBar(
          provider.errorMessage ?? 'Failed to cancel',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showFriendlySnackBar('Error: $e', type: SnackBarType.error);
    }
  }

  void _showFriendlySnackBar(String message, {required SnackBarType type}) {
    Color backgroundColor;
    IconData icon;
    
    switch (type) {
      case SnackBarType.success:
        backgroundColor = AppColors.coinBrown;
        icon = Icons.check_circle_rounded;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red.shade600;
        icon = Icons.error_rounded;
        break;
      case SnackBarType.info:
        backgroundColor = Colors.blue.shade600;
        icon = Icons.info_rounded;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.orange.shade600;
        icon = Icons.warning_rounded;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    _showFriendlySnackBar(message, type: SnackBarType.error);
  }

  @override
  Widget build(BuildContext context) {
    // Check if ANY store has an approved redemption
    final hasAnyApprovedRedemption = _storeRedemptions.values
        .any((redemption) => redemption['status'] == 'approved');
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Our Showrooms',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: _isCheckingStatus
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Checking redemption status...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            )
          : Consumer<StoreProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGold,
                    ),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading showrooms...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Oops! Something went wrong',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.errorMessage ?? 'Unable to load showrooms',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: provider.fetchStores,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final stores = provider.storeData?.activeStores ?? [];

          if (stores.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.store_mall_directory_rounded,
                      size: 72,
                      color: AppColors.primaryGold.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Showrooms Available',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Please check back later for available locations',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Global Approved Status Banner (if ANY store has approved redemption)
              if (hasAnyApprovedRedemption)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.coinBrown, AppColors.coinBrown],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coinBrown.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Redemption Approved!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Visit the approved store below to collect your gold',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Info Banner
              if (!hasAnyApprovedRedemption)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGold.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryGold,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${stores.length} ${stores.length == 1 ? 'Location' : 'Locations'} Available',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Select a showroom to redeem your gold',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Store Cards
              ...stores.map((store) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildShowroomCard(store),
              )),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildShowroomCard(StoreData store) {
    final storeStatus = _getStoreStatus(store.id);
    final redemptionId = _getStoreRedemptionId(store.id);
    final bool canRedeem = storeStatus == 'none';
    final bool isApproved = storeStatus == 'approved';
    final bool isPending = storeStatus == 'pending';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Image
          if (store.storeImage.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: store.storeImage,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGold,
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Image unavailable',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Store Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store-specific status badge
                if (isPending || isApproved)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isApproved 
                          ? AppColors.coinBrown.withOpacity(0.1)
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isApproved 
                            ? AppColors.coinBrown.withOpacity(0.3)
                            : Colors.orange.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isApproved ? Icons.check_circle : Icons.hourglass_empty,
                          size: 16,
                          color: isApproved ? AppColors.coinBrown : Colors.orange.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isApproved ? 'Approved' : 'Pending Approval',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isApproved ? AppColors.coinBrown : Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),

                Text(
                  store.name ?? 'Aishwarya Gold Showroom',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                if (store.location != null && store.location!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.red[400], size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          store.location!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (store.number != null && store.number!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, color: AppColors.primaryGold, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        store.number!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openGoogleMaps(store.map, store.location),
                        icon: const Icon(Icons.directions, size: 18),
                        label: const Text('Directions'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGold,
                          side: BorderSide(color: AppColors.primaryGold.withOpacity(0.3)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: store.number != null && store.number!.isNotEmpty
                            ? () => _makePhoneCall(store.number)
                            : null,
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Call'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGold,
                          side: BorderSide(
                            color: store.number != null && store.number!.isNotEmpty
                                ? AppColors.primaryGold.withOpacity(0.3)
                                : Colors.grey[300]!,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Redeem/Cancel Buttons - Store specific
                if (isApproved)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text('Approved - Visit Store'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coinBrown,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.coinBrown,
                        disabledForegroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  )
                else if (isPending)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.hourglass_empty, size: 20),
                          label: const Text('Request Pending'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.coinBrown,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.coinBrown,
                            disabledForegroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: redemptionId != null 
                              ? () => _cancelRedemption(store.id!, redemptionId)
                              : null,
                          icon: const Icon(Icons.cancel, size: 18),
                          label: const Text('Cancel Request'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade600,
                            side: BorderSide(color: Colors.red.shade200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else if (canRedeem)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToRedeemScreen(store),
                      icon: const Icon(Icons.card_giftcard, size: 20),
                      label: const Text('Redeem Gold'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
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

// Add enum for snackbar types
enum SnackBarType {
  success,
  error,
  info,
  warning,
}


// ═══════════════════════════════════════════════════════════════════════════
// REDEEM INSTRUCTION SCREEN
// ═══════════════════════════════════════════════════════════════════════════

// Updated RedeemInstructionScreen - Key changes highlighted

class RedeemInstructionScreen extends StatefulWidget {
  final StoreData store;
  final String? planId;
  final String? planType;
  final double? walletBalance;

  const RedeemInstructionScreen({
    super.key,
    required this.store,
    this.planId,
    this.walletBalance,
    this.planType,
  });

  @override
  State<RedeemInstructionScreen> createState() =>
      _RedeemInstructionScreenState();
}

class _RedeemInstructionScreenState extends State<RedeemInstructionScreen> {
  bool _isProcessing = false;
  String _currentStatus = 'idle';
  String? _redemptionId;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onRedeemPressed() async {
    if (widget.planType == null || widget.store.id == null) {
  _showSnackBar('Missing plan information', isError: true);
  return;
}

if (widget.planType == 'WalletBalance' && widget.walletBalance == null) {
  _showSnackBar('Wallet balance not available', isError: true);
  return;
}


    setState(() {
      _isProcessing = true;
      _currentStatus = 'processing';
    });

    try {
      final provider = context.read<RedemptionProvider>();
final success = await provider.createRedemptionRequest(
  planId: widget.planType == 'WalletBalance' ? null : widget.planId,
  planType: widget.planType ?? '',
  storeId: widget.store.id!,
  amount: widget.planType == 'WalletBalance'
      ? widget.walletBalance
      : null,
);

if (!success) {
        setState(() {
          _isProcessing = false;
          _currentStatus = 'idle';
        });
        String friendlyError = _convertBackendError(provider.errorMessage);
        _showSnackBar(friendlyError, isError: true);
        return;
      }

      final redemptionId = provider.redemptionResponse?.data?.id;
      if (redemptionId == null) {
        setState(() {
          _isProcessing = false;
          _currentStatus = 'idle';
        });
        _showSnackBar('No redemption ID returned', isError: true);
        return;
      }

      setState(() {
        _redemptionId = redemptionId;
        _currentStatus = 'pending';
        _isProcessing = false;
      });

      _showFriendlySnackBar(
        'Request submitted successfully! The store will review it shortly.',
        type: SnackBarType.success,
      );
      _startCheckingStatus(redemptionId);

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _currentStatus = 'idle';
      });
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _startCheckingStatus(String redemptionId) async {
    final provider = context.read<RedemptionProvider>();
    const checkInterval = Duration(seconds: 5);
    const maxChecks = 60;

    for (int i = 0; i < maxChecks; i++) {
      if (!mounted) return;

      final statusResponse = await provider.getRedemptionStatus(redemptionId);
      final currentStatus = statusResponse?.data?.status?.toLowerCase() ?? 'pending';

      if (!mounted) return;

      setState(() {
        _currentStatus = currentStatus;
      });

      if (currentStatus == 'approved') {
        _showApprovedDialog();
        return;
      } else if (currentStatus == 'rejected') {
        _showFriendlySnackBar(
          'Your redemption request was not approved. Please contact the store for details.',
          type: SnackBarType.error,
        );
        return;
      }

      await Future.delayed(checkInterval);
    }

    _showFriendlySnackBar(
      'Unable to confirm approval status. Please check back later or contact the store.',
      type: SnackBarType.warning,
    );
  }

  Future<void> _onCancelPressed() async {
    if (_redemptionId == null) {
      Navigator.pop(context);
      return;
    }

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Redemption?'),
        content: const Text('Are you sure you want to cancel this redemption request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldCancel != true) return;

    setState(() => _isProcessing = true);

    try {
      final provider = context.read<RedemptionProvider>();
      final success = await provider.cancelRedemptionRequest(_redemptionId!);

      if (!mounted) return;

      if (success) {
        _showSnackBar('Request cancelled successfully', isError: false);
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        
        // ✅ Return map indicating cancellation
        Navigator.pop(context, {
          'status': 'cancelled',
          'redemptionId': null,
        });
      } else {
        setState(() => _isProcessing = false);
        _showSnackBar(
          provider.errorMessage ?? 'Failed to cancel',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showSnackBar('Error: $e', isError: true);
    }
  }

  void _showApprovedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 64,
                  color: AppColors.coinBrown,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Approved!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your redemption has been approved. Please visit the store to collect your gold.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    
                    // ✅ Return map with store-specific redemption info
                    Navigator.pop(context, {
                      'status': 'approved',
                      'redemptionId': _redemptionId,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coinBrown,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  String _convertBackendError(String? msg) {
    if (msg == null) return "Something went wrong. Please try again.";

    msg = msg.toLowerCase();

    if (msg.contains("already exists") && msg.contains("approved")) {
      return "Your gold redemption for this plan is already approved!";
    }

    if (msg.contains("already exists") && msg.contains("pending")) {
      return "You already have a pending redemption request for this plan.";
    }

    if (msg.contains("duplicate") || msg.contains("exists")) {
      return "A redemption request already exists for this plan.";
    }

    if (msg.contains("not enough") || msg.contains("insufficient")) {
      return "You don't have enough balance to redeem this plan.";
    }

    return "Unable to submit request. Please try again later.";
  }

  void _showSnackBar(String message, {required bool isError}) {
    _showFriendlySnackBar(
      message,
      type: isError ? SnackBarType.error : SnackBarType.success,
    );
  }

  void _showFriendlySnackBar(String message, {required SnackBarType type}) {
    Color backgroundColor;
    IconData icon;
    
    switch (type) {
      case SnackBarType.success:
        backgroundColor = AppColors.coinBrown;
        icon = Icons.check_circle_rounded;
        break;
      case SnackBarType.error:
        backgroundColor = AppColors.primaryRed;
        icon = Icons.error_rounded;
        break;
      case SnackBarType.info:
        backgroundColor = Colors.blue.shade600;
        icon = Icons.info_rounded;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.orange.shade600;
        icon = Icons.warning_rounded;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final showCancelButton = _currentStatus == 'pending' || _currentStatus == 'processing';
    final isApproved = _currentStatus == 'approved';
    final canRedeem = _currentStatus == 'idle';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: (_isProcessing && _currentStatus == 'pending') 
              ? null 
              : () => Navigator.pop(context),
        ),
        title: const Text(
          'Redeem Gold',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Store Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (store.storeImage.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: store.storeImage,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    store.name ?? 'Aishwarya Gold Showroom',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  if (store.location != null && store.location!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            store.location!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Status Card
            if (_currentStatus != 'idle')
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getStatusColor().withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(_getStatusIcon(), color: _getStatusColor(), size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStatusTitle(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getStatusMessage(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_currentStatus == 'pending')
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getStatusColor(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            if (_currentStatus != 'idle') const SizedBox(height: 24),

            // Action Buttons
            if (canRedeem)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _onRedeemPressed,
                  icon: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.card_giftcard, size: 22),
                  label: Text(
                    _isProcessing ? 'Processing...' : 'Submit Redemption Request',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

            if (showCancelButton)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _onCancelPressed,
                  icon: const Icon(Icons.cancel, size: 20),
                  label: const Text(
                    'Cancel Request',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

            if (isApproved)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.check_circle, size: 22),
                  label: const Text(
                    'Approved - Visit Store',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coinBrown,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.coinBrown,
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.shade200,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Important Information',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getInfoMessage(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange.shade900,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case 'pending':
      case 'processing':
        return Colors.orange.shade600;
      case 'approved':
        return AppColors.coinBrown;
      case 'rejected':
        return Colors.red.shade600;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case 'pending':
      case 'processing':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusTitle() {
    switch (_currentStatus) {
      case 'processing':
        return 'Creating Request...';
      case 'pending':
        return 'Pending Approval';
      case 'approved':
        return 'Request Approved';
      case 'rejected':
        return 'Request Rejected';
      default:
        return 'Status Unknown';
    }
  }

  String _getStatusMessage() {
    switch (_currentStatus) {
      case 'processing':
        return 'Please wait while we process your request';
      case 'pending':
        return 'Your request is being reviewed by the store';
      case 'approved':
        return 'You can now collect your gold from the store';
      case 'rejected':
        return 'Please contact the store for more information';
      default:
        return '';
    }
  }

  String _getInfoMessage() {
    switch (_currentStatus) {
      case 'pending':
        return 'Your redemption request is under review. You can cancel it anytime before approval. The store will notify you once approved.';
      case 'approved':
        return 'Your request has been approved! Please visit the store with a valid ID to collect your gold. Bring this confirmation screen.';
      case 'rejected':
        return 'Your redemption request was not approved. Please contact the store directly for more details or try again later.';
      default:
        return 'Once you submit the request, the store will review it. You\'ll be notified when it\'s approved. Make sure to bring a valid ID when visiting.';
    }
  }
}
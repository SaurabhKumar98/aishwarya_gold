import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view_models/notification_provider/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      await provider.fetchNotifications();
      provider.markAllRead();
    });
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  // ------------------ SHIMMER LOADER ------------------
  Widget _shimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 90,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  // ------------------ COPY FUNCTION ------------------
  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Promo code copied!"),
        backgroundColor: AppColors.coinBrown,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      // ------------------ MAIN BODY ------------------
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return _shimmerLoader();
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  Text("No notifications yet",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  Text("We’ll notify you when something arrives",
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: provider.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),

            itemBuilder: (context, index) {
              final notif = provider.notifications[index];
              final promoCode = notif.data?.promoCode ?? "";

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ICON
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.coinBrown.withOpacity(0.15),
                              AppColors.coinBrown.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.notifications_active,
                            color: AppColors.coinBrown, size: 24),
                      ),

                      const SizedBox(width: 14),

                      // TEXT SECTION
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif.title ?? "",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              notif.message ?? "",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // TIME
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 14, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTime(notif.createdAt),
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 12),
                                ),
                              ],
                            ),

                            // ---------------- PROMO CODE SECTION ----------------
                            if (promoCode.isNotEmpty) ...[
                              const SizedBox(height: 12),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.coinBrown.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.coinBrown, width: 0.8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      promoCode,
                                      style: TextStyle(
                                        color: AppColors.coinBrown,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    InkWell(
                                      onTap: () => _copyToClipboard(promoCode),
                                      child: Icon(Icons.copy,
                                          size: 20,
                                          color: AppColors.coinBrown),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

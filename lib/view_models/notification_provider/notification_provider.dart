import 'package:aishwarya_gold/data/models/notificationmodels/notification_models.dart';
import 'package:aishwarya_gold/data/repo/notificationrepo/notification_repo.dart';
import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepo _repo = NotificationRepo();

  bool isLoading = false;

  List<NotficationData> notifications = [];

  int unreadCount = 0; // 🔥 Unread notifications counter

  Future<void> fetchNotifications() async {
    try {
      isLoading = true;
      notifyListeners();

      final model = await _repo.getAllNotifications();

      if (model != null && (model.success ?? false)) {
        notifications = model.data ?? [];

        // 🔥 Count unread notifications (if isRead is null → treat as unread)
        unreadCount = notifications
            .where((n) => n.isRead == false || n.isRead == null)
            .length;

      } else {
        notifications = [];
        unreadCount = 0;
      }
    } catch (e) {
      debugPrint("❌ Error fetching notifications: $e");
      notifications = [];
      unreadCount = 0;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 CALL THIS WHEN USER OPENS NOTIFICATION SCREEN
  void markAllRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    unreadCount = 0;
    notifyListeners();
  }
}

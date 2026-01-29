// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'package:aishwarya_gold/core/session/navkey.dart';
// import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
// import 'package:aishwarya_gold/view/home_container/home_screen/notification_screen.dart';

// /// 🔥 REQUIRED for iOS background notifications
// @pragma('vm:entry-point')
// Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(); // IMPORTANT

//   if (kDebugMode) {
//     print('Handling background message: ${message.messageId}');
//   }
// }

// // 🔔 Local notifications plugin
// final FlutterLocalNotificationsPlugin fltNotification =
//     FlutterLocalNotificationsPlugin();

// int _notificationId = 0;

// // 🔔 Notification initialization
// const AndroidInitializationSettings androidInit =
//     AndroidInitializationSettings('@mipmap/ic_launcher');

// const DarwinInitializationSettings iosInit =
//     DarwinInitializationSettings(
//   defaultPresentAlert: true,
//   defaultPresentBadge: true,
//   defaultPresentSound: true,
// );

// const InitializationSettings initSetting =
//     InitializationSettings(android: androidInit, iOS: iosInit);

// /// 🔔 Show foreground notification
// Future<void> showGeneralNotification(
//   Map<String, dynamic> data,
//   RemoteNotification notification,
// ) async {
//   const AndroidNotificationDetails androidDetails =
//       AndroidNotificationDetails(
//     'general_channel',
//     'General Notifications',
//     channelDescription: 'General app notifications',
//     importance: Importance.high,
//     priority: Priority.high,
//     playSound: true,
//     enableVibration: true,
//     visibility: NotificationVisibility.public,
//   );

//   const DarwinNotificationDetails iosDetails =
//       DarwinNotificationDetails(
//     presentAlert: true,
//     presentBadge: true,
//     presentSound: true,
//   );

//   const NotificationDetails notificationDetails =
//       NotificationDetails(android: androidDetails, iOS: iosDetails);

//   await fltNotification.show(
//     _notificationId++,
//     notification.title,
//     notification.body,
//     notificationDetails,
//     payload: jsonEncode(data),
//   );
// }

// /// 🔔 Handle notification tap
// void onNotificationTap(NotificationResponse response) {
//   if (response.payload == null || response.payload!.isEmpty) return;

//   final Map<String, dynamic> data =
//       jsonDecode(response.payload!) as Map<String, dynamic>;

//   Future.microtask(() => handleNotificationNavigation(data));
// }

// /// 🔔 Navigation logic
// void handleNotificationNavigation(Map<String, dynamic> data) {
//   navigatorKey.currentState?.push(
//     MaterialPageRoute(builder: (_) => const NotificationScreen()),
//   );
// }

// /// 🔥 MAIN FCM INITIALIZATION (call from main.dart AFTER Firebase.init)
// Future<void> initMessaging() async {
//   // 🔥 Register background handler FIRST
//   FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

//   // 🔔 Init local notifications
//   await fltNotification.initialize(
//     initSetting,
//     onDidReceiveNotificationResponse: onNotificationTap,
//     onDidReceiveBackgroundNotificationResponse: onNotificationTap,
//   );

//   // 🔐 Ask notification permission (iOS)
//   await FirebaseMessaging.instance.requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   // 📱 Get FCM token
//   final String? token = await FirebaseMessaging.instance.getToken();
//   await SessionManager.storeDeviceToken(token ?? '');

//   if (kDebugMode) {
//     print('FCM TOKEN: $token');
//   }

//   // 🔔 App opened from terminated state
//   final RemoteMessage? initialMessage =
//       await FirebaseMessaging.instance.getInitialMessage();

//   if (initialMessage != null) {
//     handleNotificationNavigation(initialMessage.data);
//   }

//   // 🔔 Foreground notifications
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     final notification = message.notification;
//     if (notification != null) {
//       showGeneralNotification(message.data, notification);
//     }
//   });

//   // 🔔 App opened from background
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     handleNotificationNavigation(message.data);
//   });
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../session/navkey.dart';
import '../storage/sharedpreference.dart';
import '../../view/home_container/home_screen/notification_screen.dart';

/// 🔥 Background isolate MUST init Firebase (iOS rule)
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
  }
}

final FlutterLocalNotificationsPlugin fltNotification =
    FlutterLocalNotificationsPlugin();

int notificationId = 0;

const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
  defaultPresentAlert: true,
  defaultPresentBadge: true,
  defaultPresentSound: true,
);

const InitializationSettings initSetting =
    InitializationSettings(android: androidInit, iOS: iosInit);

Future<void> showGeneralNotification(
  Map<String, dynamic> data,
  RemoteNotification notification,
) async {
  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
    'general_channel',
    'General Notifications',
    channelDescription: 'General app notifications',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    visibility: NotificationVisibility.public,
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails, iOS: iosDetails);

  await fltNotification.show(
    notificationId++,
    notification.title,
    notification.body,
    notificationDetails,
    payload: jsonEncode(data),
  );
}

void onNotificationTap(NotificationResponse response) {
  if (response.payload == null || response.payload!.isEmpty) return;

  final Map<String, dynamic> data =
      jsonDecode(response.payload!) as Map<String, dynamic>;

  Future.microtask(() => handleNotificationNavigation(data));
}

void handleNotificationNavigation(Map<String, dynamic> data) {
  navigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => const NotificationScreen()),
  );
}

Future<void> initMessaging() async {
  // 🔥 Register background handler FIRST
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  // 🔔 Local notifications init
  await fltNotification.initialize(
    initSetting,
    onDidReceiveNotificationResponse: onNotificationTap,
    onDidReceiveBackgroundNotificationResponse: onNotificationTap,
  );

  // 🔐 Ask permission
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // 📱 Token
  final String? token = await FirebaseMessaging.instance.getToken();
  await SessionManager.storeDeviceToken(token ?? '');

  // 🔔 Terminated state
  final RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    handleNotificationNavigation(initialMessage.data);
  }

  // 🔔 Foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      showGeneralNotification(message.data, notification);
    }
  });

  // 🔔 Background opened
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    handleNotificationNavigation(message.data);
  });
}

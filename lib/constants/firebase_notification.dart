import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Must be a top-level function — FCM requirement
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final notification = message.notification;
  if (notification != null) {
    FirebaseHelpers.saveNotificationLocally(message);
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'alerts',
        title: notification.title,
        body: notification.body,
        notificationLayout: NotificationLayout.BigText,
        payload: Map<String, String?>.from(
          message.data.map((k, v) => MapEntry(k, v?.toString())),
        ),
      ),
    );
  }
}

class FirebaseHelpers {
  static final box = GetStorage();
  static List<String> customerSubscribeList = [];
  static const String notificationKey = 'local_notifications';
  static final RxList<dynamic> localNotifications = <dynamic>[].obs;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'foduu_ecommerce_notifications',
    importance: Importance.high,
    playSound: true,
    showBadge: true,
    enableLights: true,
    enableVibration: true,
  );

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ─── Initialisation ───────────────────────────────────────────────────────

  static Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      settings: const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          navigateOnNotificationClick({'type': response.payload});
        }
      },
    );
  }

  static Future<void> _initAwesomeNotifications() async {
    _setAwesomeNotificationListeners();
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'alerts',
          channelName: 'Alerts',
          channelDescription: 'App push notifications',
          playSound: true,
          onlyAlertOnce: true,
          criticalAlerts: true,
          enableVibration: true,
          enableLights: true,
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Private,
          defaultColor: DynamicThemeManager().lightColors.primary,
          ledColor: DynamicThemeManager().lightColors.primary,
        ),
      ],
      debug: false,
    );
  }

  static void _setAwesomeNotificationListeners() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (receivedAction) async {
        final payload = receivedAction.payload ?? {};
        navigateOnNotificationClick(payload);
      },
    );
  }

  static Future<void> firebaseInitialise() async {
    if (kIsWeb) return;

    await _initAwesomeNotifications();
    await _initLocalNotifications();

    // Create Android high-importance channel
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await syncTopics();

    // Handle notification that launched app from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(seconds: 2), () {
        openAppFromNotification(initialMessage);
      });
    }

    // Handle notification tap when app is in background (resumed)
    FirebaseMessaging.onMessageOpenedApp.listen(openAppFromNotification);

    // Initialize local notifications from storage
    final stored = box.read(notificationKey);
    if (stored != null && stored is List) {
      localNotifications.assignAll(stored);
    }

    firebaseNotificationOnAppOpen();
  }

  // ─── Foreground notification display ──────────────────────────────────────

  static void firebaseNotificationOnAppOpen() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      if (notification == null) return;

      saveNotificationLocally(message);

      final myToken = box.read('my_fcm_token');
      final senderId = message.data['sender_id'];
      if (senderId != null && myToken != null && senderId == myToken) return;

      final bgColor = message.data['color'] == 'green'
          ? DynamicThemeManager().lightColors.secondary
          : DynamicThemeManager().lightColors.primary;

      final textColor = message.data['color'] == 'green'
          ? DynamicThemeManager().lightColors.onSecondary
          : DynamicThemeManager().lightColors.onPrimary;

      Get.snackbar(
        notification.title ?? '',
        notification.body ?? '',
        backgroundColor: bgColor,
        colorText: textColor,
        duration: const Duration(seconds: 10),
        dismissDirection: DismissDirection.horizontal,
        onTap: (_) => navigateOnNotificationClick(message.data),
      );
    });
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  static void navigateOnNotificationClick(Map data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final type = data['type']?.toString();
      if (type == 'product') {
        final id = data['product_id'] ?? data['id'];
        if (id != null) {
          Get.toNamed(Routes.PRODUCTDETAILS, arguments: {'productId': id});
          return;
        }
      }
      if (type == 'blog') {
        final id = data['blog_id'] ?? data['id'];
        if (id != null) {
          Get.toNamed(Routes.BLOG_DETAILS, arguments: {'id': id});
          return;
        }
      }
      if (type == 'order') {
        final id = data['order_id'] ?? data['id'];
        if (id != null) {
          Get.toNamed(Routes.ORDER_DETAILS, arguments: {'id': id});
          return;
        }
      }
      Get.toNamed(Routes.BOTTOMBAR);
    } catch (e) {
      print('Notification navigation error: $e');
    }
  }

  static void openAppFromNotification(RemoteMessage? message) {
    if (message == null) return;
    saveNotificationLocally(message);
    navigateOnNotificationClick(message.data);
  }

  static void saveNotificationLocally(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final newNotif = {
      'title': notification.title,
      'body': notification.body,
      'data': message.data,
      'created_at': DateTime.now().toIso8601String(),
      'is_local': true,
    };

    // Add to reactive list (at the top)
    localNotifications.insert(0, newNotif);

    // Limit to 50 items
    if (localNotifications.length > 50) {
      localNotifications.removeLast();
    }

    // Persist to storage
    box.write(notificationKey, localNotifications.toList());
  }

  static void clearLocalNotifications() {
    localNotifications.clear();
    box.remove(notificationKey);
  }

  // ─── FCM Token ────────────────────────────────────────────────────────────

  static Future<String?> getFCMToken() async {
    if (kIsWeb) return null;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        box.write('my_fcm_token', token);
        debugPrint('====================================');
        debugPrint('FCM TOKEN: $token');
        debugPrint('====================================');
        // Send token to backend if user is logged in
        if (AuthDetails.isUserLogin()) {
          try {
            await BasicProvider('public/customer/fcm-token')
                .postRequest({'fcm_token': token});
          } catch (_) {}
        }
      }
      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        box.write('my_fcm_token', newToken);
        if (AuthDetails.isUserLogin()) {
          BasicProvider('public/customer/fcm-token')
              .postRequest({'fcm_token': newToken}).catchError((_) {});
        }
      });
      return token;
    } catch (e) {
      print('FCM token error: $e');
      return null;
    }
  }

  // ─── Topic subscriptions ──────────────────────────────────────────────────

  static const List<String> defaultTopics = [
    'promotions',
    'news',
    'general',
    'newrelease',
    'deals'
  ];

  static Future<void> syncTopics() async {
    await _subscribeToDefaultTopics();
    if (AuthDetails.isUserLogin()) {
      await _subscribeToUserTopics();
    }
  }

  static Future<void> _subscribeToDefaultTopics() async {
    if (kIsWeb) return;
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    // We keep the prefix if preferred by user, but plan said raw strings for backend alignment.
    // Based on question 3 in the plan, I will use raw strings for backend topics but keep prefix for user topics as suggested in Phase 2.
    final topics = defaultTopics;

    customerSubscribeList = [...topics];
    for (final topic in topics) {
      debugPrint(
          "---------------Subscribing to topic: $topic-------------------");
      try {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
      } catch (e) {
        debugPrint("Error subscribing to topic $topic: $e");
      }
    }
  }

  static Future<void> _subscribeToUserTopics() async {
    if (kIsWeb) return;
    final userDetails = box.read('userData');
    if (userDetails == null) return;
    final userId = userDetails['_id']?.toString();
    if (userId == null) return;

    final userTopics = [
      'foduu_ecommerce_user_$userId',
      'foduu_ecommerce_orders_$userId',
    ];

    for (final topic in userTopics) {
      if (!customerSubscribeList.contains(topic)) {
        customerSubscribeList.add(topic);
        debugPrint(
            "---------------Subscribing to user topic: $topic-------------------");
        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
          try {
            await FirebaseMessaging.instance.subscribeToTopic(topic);
          } catch (e) {
            debugPrint("Error subscribing to user topic $topic: $e");
          }
        }
      }
    }
  }

  static Future<void> afterLoginSubscribe() async {
    await _subscribeToUserTopics();
  }

  static Future<void> afterLogoutUnsubscribe() async {
    if (kIsWeb) return;
    final userDetails = box.read('userData');
    if (userDetails == null) return;
    final userId = userDetails['_id']?.toString();
    if (userId != null) {
      debugPrint(
          "---------------Unsubscribing from user topics for: $userId-------------------");
      try {
        await FirebaseMessaging.instance
            .unsubscribeFromTopic('foduu_ecommerce_user_$userId');
      } catch (e) {
        debugPrint("Error unsubscribing from foduu_ecommerce_user_$userId: $e");
      }
      try {
        await FirebaseMessaging.instance
            .unsubscribeFromTopic('foduu_ecommerce_orders_$userId');
      } catch (e) {
        debugPrint(
            "Error unsubscribing from foduu_ecommerce_orders_$userId: $e");
      }
    }
  }

  static Future<bool> unsubscribeFromAllTopics() async {
    for (final topic in customerSubscribeList) {
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      } catch (e) {
        debugPrint("Error unsubscribing from topic $topic: $e");
      }
    }
    customerSubscribeList.clear();
    return true;
  }
}

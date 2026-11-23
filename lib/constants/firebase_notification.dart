import 'dart:async';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foddu/app/data/basic_provider.dart';
import 'package:foddu/app/modules/auth/auth_details.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:foddu/constants/dynamic_theme.dart';
import 'package:foddu/models/local_notification.dart';
import 'package:foddu/services/local_storage_notification_service.dart';
import 'package:foddu/services/notification_sync_service.dart';
import 'package:foddu/firebase_options.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Must be a top-level function — FCM requirement
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  final notification = message.notification;
  if (notification != null) {
    await GetStorage.init();
    await FirebaseHelpers.saveNotificationLocally(message);
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
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static StreamSubscription<RemoteMessage>? _openedMessageSubscription;
  static StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  static bool _handlersInitialized = false;

  // ─── Initialisation ───────────────────────────────────────────────────────

  static Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
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

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    final payload = receivedAction.payload ?? {};
    navigateOnNotificationClick(payload);
  }

  static void _setAwesomeNotificationListeners() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  static Future<void> firebaseInitialise() async {
    if (kIsWeb) return;
    if (_handlersInitialized) return;

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
    _openedMessageSubscription ??=
        FirebaseMessaging.onMessageOpenedApp.listen(openAppFromNotification);
    _tokenRefreshSubscription ??=
        FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);

    // Initialize local notifications from storage
    final stored = box.read(notificationKey);
    if (stored != null && stored is List) {
      localNotifications.assignAll(stored);
    }

    firebaseNotificationOnAppOpen();
    _handlersInitialized = true;
  }

  // ─── Foreground notification display ──────────────────────────────────────

  static void firebaseNotificationOnAppOpen() {
    _foregroundMessageSubscription ??=
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

  static Future<void> saveNotificationLocally(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final id =
        message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final localNotif = LocalNotification(
      id: id,
      title: notification.title ?? '',
      body: notification.body ?? '',
      type: message.data['type']?.toString() ?? 'general',
      timestamp: message.sentTime ?? DateTime.now(),
      isRead: false,
      isSynced: false,
      metadata: Map<String, dynamic>.from(message.data),
    );

    LocalStorageNotificationService storageService;
    if (Get.isRegistered<LocalStorageNotificationService>()) {
      storageService = Get.find<LocalStorageNotificationService>();
    } else {
      storageService = Get.put(LocalStorageNotificationService());
    }
    await storageService.saveNotification(localNotif);

    // Update legacy list for compatibility
    final legacyNotif = {
      'title': localNotif.title,
      'body': localNotif.body,
      'data': localNotif.metadata,
      'created_at': localNotif.timestamp.toIso8601String(),
      'is_local': true,
      'id': localNotif.id,
      'is_read': localNotif.isRead,
      'is_synced': localNotif.isSynced,
    };

    final existingIndex =
        localNotifications.indexWhere((n) => n['id'] == localNotif.id);
    if (existingIndex != -1) {
      localNotifications[existingIndex] = legacyNotif;
    } else {
      localNotifications.insert(0, legacyNotif);
    }

    if (localNotifications.length > 50) {
      localNotifications.removeLast();
    }

    box.write(notificationKey, localNotifications.toList());

    // Trigger sync
    NotificationSyncService syncService;
    if (Get.isRegistered<NotificationSyncService>()) {
      syncService = Get.find<NotificationSyncService>();
    } else {
      syncService = Get.put(NotificationSyncService());
    }
    syncService.syncPendingNotifications();
  }

  static Future<void> clearLocalNotifications() async {
    localNotifications.clear();
    if (Get.isRegistered<LocalStorageNotificationService>()) {
      await LocalStorageNotificationService.to.clearAll();
    } else {
      await box.remove(notificationKey);
    }
  }

  // ─── FCM Token ────────────────────────────────────────────────────────────

  static Future<String?> getFCMToken() async {
    if (kIsWeb) return null;
    try {
      if (Platform.isIOS &&
          await FirebaseMessaging.instance.getAPNSToken() == null) {
        debugPrint(
            'FCM token is not available until APNs registration completes.');
        return null;
      }
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        box.write('my_fcm_token', token);
        await _uploadTokenForCurrentUser(token);
      }
      _tokenRefreshSubscription ??=
          FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);
      return token;
    } catch (e) {
      print('FCM token error: $e');
      return null;
    }
  }

  static Future<bool> hasNotificationPermission() async {
    if (kIsWeb) return false;
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestNotificationPermission() async {
    if (kIsWeb) return false;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      if (granted) await registerCurrentTokenForUser();
      return granted;
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
      return false;
    }
  }

  static Future<void> registerCurrentTokenForUser() async {
    if (!AuthDetails.isUserLogin()) return;
    var token = box.read('my_fcm_token')?.toString();
    if (token == null || token.isEmpty) {
      await getFCMToken(); // getFCMToken also registers a newly obtained token.
      return;
    }
    await _uploadTokenForCurrentUser(token);
  }

  static Future<void> _onTokenRefresh(String token) async {
    box.write('my_fcm_token', token);
    await _uploadTokenForCurrentUser(token);
  }

  static Future<void> _uploadTokenForCurrentUser(String token) async {
    if (!AuthDetails.isUserLogin()) return;
    try {
      await BasicProvider('public/customer/fcm-token')
          .postRequest({'fcm_token': token});
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
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
    if (Platform.isIOS &&
        await FirebaseMessaging.instance.getAPNSToken() == null) {
      debugPrint('Skipping push topics until APNs registration completes.');
      return;
    }

    // We keep the prefix if preferred by user, but plan said raw strings for backend alignment.
    // Based on question 3 in the plan, I will use raw strings for backend topics but keep prefix for user topics as suggested in Phase 2.
    const topics = defaultTopics;

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
    if (Platform.isIOS &&
        await FirebaseMessaging.instance.getAPNSToken() == null) {
      debugPrint('Skipping account topics until APNs registration completes.');
      return;
    }
    final userDetails = box.read('userData');
    if (userDetails == null) return;
    if (userDetails is! Map) return;
    final userId = (userDetails['_id'] ?? userDetails['id'])?.toString();
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
    try {
      await _subscribeToUserTopics();
      await registerCurrentTokenForUser();
      if (Get.isRegistered<NotificationSyncService>()) {
        await NotificationSyncService.to.syncPendingNotifications();
      }
    } catch (e) {
      debugPrint('Post-login push registration failed: $e');
    }
  }

  /// Best-effort topic cleanup. Each call is time-limited so an unreachable
  /// Firebase can never hang a caller; pass [userId] when local storage has
  /// already been cleared.
  static Future<void> afterLogoutUnsubscribe({String? userId}) async {
    if (kIsWeb) return;
    if (userId == null) {
      final userDetails = box.read('userData');
      if (userDetails is Map) userId = userDetails['_id']?.toString();
    }
    if (userId == null) return;
    customerSubscribeList.removeWhere((topic) =>
        topic == 'foduu_ecommerce_user_$userId' ||
        topic == 'foduu_ecommerce_orders_$userId');
    debugPrint(
        "---------------Unsubscribing from user topics for: $userId-------------------");
    for (final topic in [
      'foduu_ecommerce_user_$userId',
      'foduu_ecommerce_orders_$userId',
    ]) {
      try {
        await FirebaseMessaging.instance
            .unsubscribeFromTopic(topic)
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint("Error unsubscribing from $topic: $e");
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

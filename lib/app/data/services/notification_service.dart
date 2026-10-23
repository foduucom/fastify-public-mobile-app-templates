import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';

class NotificationService {
  static final GetStorage _box = GetStorage();
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (e) {
      print("Firebase background initialization failed: $e");
    }
    print(
        "Background message received: ${message.messageId} - ${message.data}");
  }

  // Initialize all notification logic
  static Future<void> init() async {
    try {
      // 1. Initialize Local Notifications Settings
      AndroidInitializationSettings initializationSettingsAndroid =
          const AndroidInitializationSettings('ic_notification');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        requestCriticalPermission: false,
      );

      InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      // Initialize local notification plugin
      try {
        await _localNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            if (response.payload != null) {
              try {
                final Map<String, dynamic> data = jsonDecode(response.payload!);
                navigateOnNotificationClick(data);
              } catch (e) {
                print("Error parsing local notification payload: $e");
              }
            }
          },
        );
      } catch (e) {
        print(
            "Failed to initialize with ic_notification, falling back to launcher_icon: $e");
        initializationSettingsAndroid =
            const AndroidInitializationSettings('launcher_icon');
        initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );
        await _localNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            if (response.payload != null) {
              try {
                final Map<String, dynamic> data = jsonDecode(response.payload!);
                navigateOnNotificationClick(data);
              } catch (e) {
                print("Error parsing local notification payload: $e");
              }
            }
          },
        );
      }

      // Create Android Notification Channel
      if (Platform.isAndroid) {
        await _localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_channel);
      }

      // 2. Set Firebase Presentation Options (for foreground state)
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Register background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Request user notifications permission on startup
      requestPermissionToSendNotifications();

      // 3. Register state message listeners
      _setupMessageListeners();

      // 4. Retrieve/Save FCM token
      saveTokenToBackend();

      // 5. Setup Token refresh listener
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        _box.write('my_fcm_token', newToken);
        saveTokenToBackend();
      });

      // 6. Subscribe to default topics (for promo/broadcasts)
      subscribeToTopic('promo');
      subscribeToTopic('products');
      subscribeToTopic('order');
      subscribeToTopic('registration');
    } catch (e) {
      print("NotificationService initialization failed: $e");
    }
  }

  // Check if permissions are allowed
  static Future<bool> isNotificationAllowed() async {
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      print("Error checking notification settings: $e");
      return false;
    }
  }

  // Request user permissions
  static Future<void> requestPermissionToSendNotifications() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      print(
          "User notification permission status: ${settings.authorizationStatus}");
    } catch (e) {
      print("Error requesting notification permissions: $e");
    }
  }

  static bool _isTokenSaving = false;

  // Save FCM Token to local storage and try sending to backend
  static Future<void> saveTokenToBackend() async {
    if (_isTokenSaving) return;
    try {
      if (Firebase.apps.isEmpty) return;
      _isTokenSaving = true;

      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        _box.write('my_fcm_token', token);

        // Send to backend only if user is logged in
        final isUserLoggedIn =
            _box.read('userData') != null || _box.read('token') != null;

        if (isUserLoggedIn) {
          final userData = _box.read('userData');
          final userId = (userData is Map) ? (userData['_id'] ?? userData['id']) : null;
          final lastSyncedToken = _box.read('last_synced_fcm_token');
          final lastSyncedUser = _box.read('last_synced_fcm_user');

          // Skip if token & user have already been successfully registered in this session
          if (lastSyncedToken == token && lastSyncedUser == userId) {
            print("🔔 [Firebase Messaging] FCM token already registered for current user. Skipping redundant request.");
            _isTokenSaving = false;
            return;
          }

          print("🔔 [Firebase Messaging] FCM DEVICE TOKEN: $token");
          final form = {
            'fcm_token': token,
            'notification_token': token,
          };
          print("🔔 [Firebase Messaging] Sending token to profile/update...");
          await BasicProvider("auth/customer/profile/update").postRequest(form);

          print(
              "🔔 [Firebase Messaging] Sending token to dedicated fcm-token endpoint...");
          await BasicProvider("auth/customer/fcm-token").postRequest({
            'fcm_token': token,
          });

          _box.write('last_synced_fcm_token', token);
          if (userId != null) {
            _box.write('last_synced_fcm_user', userId);
          }
          print("🔔 [Firebase Messaging] Token registration calls completed successfully.");
        } else {
          print(
              "🔔 [Firebase Messaging] User is not logged in yet. Token registration skipped.");
        }
      }
    } catch (e) {
      print("Error saving token to backend: $e");
    } finally {
      _isTokenSaving = false;
    }
  }

  // Configure listeners for Foreground, Background, and Terminated States
  static void _setupMessageListeners() {
    // A. Foreground State Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("Received foreground message data: ${message.data}");

      // Filter out own notification if sender matches
      final myToken = _box.read("my_fcm_token");
      final senderId = message.data['sender_id'];
      if (senderId != null && myToken != null && senderId == myToken) {
        print("🔕 Skipped own notification");
        return;
      }

      String? title = message.notification?.title ?? message.data['title'];
      String? body = message.notification?.body ?? message.data['body'];

      if (title != null || body != null) {
        _localNotificationsPlugin.show(
          message.hashCode,
          title ?? "Notification",
          body ?? "",
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: 'ic_notification',
              largeIcon:
                  const DrawableResourceAndroidBitmap('ic_large_notification'),
              color:
                  Colors.grey[300], // Branded primary color //Color(0xFF0052CC)
              styleInformation: const BigTextStyleInformation(''),
              autoCancel: true,
              timeoutAfter: 60000,
              playSound: true,
              enableVibration: true,
              enableLights: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // B. Background State Click Listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked in background: ${message.data}");
      navigateOnNotificationClick(message.data);
    });

    // C. Terminated State Click Listener
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print("Notification clicked from terminated state: ${message.data}");
        Future.delayed(const Duration(seconds: 1), () {
          navigateOnNotificationClick(message.data);
        });
      }
    });
  }

  // Get dynamic FCM token with cache fallback
  static Future<String?> getFcmToken() async {
    try {
      // 1. Try reading from cache
      String? token = _box.read('my_fcm_token');
      if (token != null && token.isNotEmpty) {
        return token;
      }

      // 2. If null, request from FirebaseMessaging directly
      if (Firebase.apps.isNotEmpty) {
        token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          _box.write('my_fcm_token', token);
          print(
              "🔔 [Firebase Messaging] Dynamically retrieved FCM DEVICE TOKEN: $token");
          return token;
        }
      }
    } catch (e) {
      print("Error fetching FCM token dynamically: $e");
    }
    return null;
  }

  // Handle GetX routing navigation on click
  static navigateOnNotificationClick(Map<String, dynamic>? data) async {
    if (data == null) return;

    // Prevent concurrency issues and wait for routing engine readiness
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final type = data['type']?.toString();
      print("Navigating for notification click type: $type, payload: $data");

      switch (type) {
        case 'welcome':
        case 'registration':
          BottombarController.switchTab(0);
          break;
        case 'order':
          final orderNo = data['orderId'] ?? data['order_no'] ?? data['id'];
          if (orderNo != null) {
            Get.toNamed(Routes.ORDER_DETAILS_NEW,
                arguments: {'id': orderNo.toString()});
          } else {
            BottombarController.switchTab(0);
          }
          break;
        case 'product':
          final productId = data['productId']?.toString();
          final productSlug =
              data['productSlug']?.toString() ?? data['slug']?.toString();
          if (productId != null || productSlug != null) {
            Get.toNamed(Routes.PRODUCTDETAILS, arguments: {
              'productId': productId,
              'slug': productSlug,
            });
          } else {
            BottombarController.switchTab(0);
          }
          break;
        case 'security':
          Get.toNamed(Routes.SECURITY_SETTINGS);
          break;
        case 'cart':
          BottombarController.switchTab(2);
          break;
        case 'promo':
          BottombarController.switchTab(1);
          break;
        default:
          BottombarController.switchTab(0);
          break;
      }
    } catch (e) {
      print('Navigation error: $e');
    }
  }

  // Topic subscription management
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      print("Successfully subscribed to topic: $topic");
    } catch (e) {
      print("Failed to subscribe to topic '$topic': $e");
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance
          .unsubscribeFromTopic(topic)
          .timeout(const Duration(seconds: 5));
      print("Successfully unsubscribed from topic: $topic");
    } catch (e) {
      print("Failed to unsubscribe from topic '$topic': $e");
    }
  }

  static Future<void> unsubscribeFromAllTopics() async {
    try {
      await unsubscribeFromTopic('promo');
      await unsubscribeFromTopic('products');
      // legacy topics:
      await unsubscribeFromTopic('foduu_event');
      await unsubscribeFromTopic('foduu_news');
      await unsubscribeFromTopic('foduu_vacancy');
      print("Unsubscribed from all notification topics");
    } catch (e) {
      print("Error unsubscribing from all topics: $e");
    }
  }
}

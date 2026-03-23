// import 'package:flutter/foundation.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'dart:io' show Platform;

// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:foduu_ecommerce/app/routes/app_pages.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// class FirebaseHelpers {
//   static var box = GetStorage();
//   static var userType;
//   static List<String> customerSubscribeList = [];
//   static final List<String> _vendorSubscribeList = [];

//   static late BuildContext myContext;
//   static ReceivedAction? initialAction;
//   static Future<void> initializeLocalNotifications() async {
//     await AwesomeNotifications().initialize(
//         'resource://drawable/applogo',
//         [
//           NotificationChannel(
//               channelKey: 'alerts',
//               channelName: 'alerts',
//               channelDescription: 'Notification tests as alerts',
//               playSound: true,
//               onlyAlertOnce: true,
//               criticalAlerts: true,
//               enableVibration: true,
//               locked: true,
//               enableLights: true,
//               importance: NotificationImportance.High,
//               defaultPrivacy: NotificationPrivacy.Private,
//               defaultColor: Colors.deepPurple,
//               ledColor: Colors.deepPurple)
//         ],
//         debug: true);

//     // Get initial notification action is optional
//     initialAction = await AwesomeNotifications()
//         .getInitialNotificationAction(removeFromActionEvents: false);
//   }

//   static const AndroidNotificationChannel blgosChannel =
//       AndroidNotificationChannel(
//           'high_importance_channel', 'foduu_ecommerce_blog',
//           importance: Importance.high,
//           playSound: true,
//           showBadge: true,
//           enableLights: true,
//           enableVibration: true);

//   static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static void initialize() {
//     // final InitializationSettings initializationSettings =
//     //     InitializationSettings();

//     DarwinInitializationSettings initIOS = const DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//       requestCriticalPermission: true,
//     );

//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//             android: const AndroidInitializationSettings("@mipmap/ic_launcher"),
//             iOS: initIOS);

//     flutterLocalNotificationsPlugin.initialize(
//       settings: initializationSettings,
//       onDidReceiveNotificationResponse:
//           (NotificationResponse notificationResponse) async {
//         // Handle notification tap
//         print('Notification tapped: ${notificationResponse.payload}');
//       },
//     );
//   }

//   static Future onDidReceiveLocalNotification(
//       int? id, String? title, String? body, String? payload) async {
//     print("------------------");
//     print("On did receive local noatification");
//     print("------------------");
//     showDialog(
//         context: myContext,
//         builder: (context) => CupertinoAlertDialog(
//               title: Text(title!),
//               content: Text(body!),
//               actions: [
//                 CupertinoDialogAction(
//                   isDefaultAction: true,
//                   child: const Text("OK"),
//                   onPressed: () =>
//                       Navigator.of(context, rootNavigator: true).pop(),
//                 )
//               ],
//             ));
//   }

//   static Future<void> firebaseMessagingBackgroundHandler(
//       RemoteMessage message) async {
//     print("-----------------This is a background -----------------");
//     print(message.data);
//     print("----------------------------------");

//     print(
//         '<<<<<<<<<<<<<<<<<<<<<<<<${message.data['body']}>>>>>>>>>>>>>>>>>>>>>>>>');
//     await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//       id: -1,
//       channelKey: 'alerts',
//       title: message.data['title'],
//       body: message.data['body'],
//       notificationLayout: NotificationLayout.BigText,
//     ));
//   }

//   static navigateOnNotificationClick(message) async {
//     await Future.delayed(Duration(seconds: 2));
//     if (message != null) {
//       try {
//         if (message["type"] != null) {
//           // if (message['type'] == 'interview') {
//           //   Get.toNamed(Routes.SHEDULE,
//           //       arguments: {'id': message['schedule_id']});
//           // }
//           // if (message["type"] == 'news') {
//           //   Get.toNamed(Routes.NEWSDETAILS,
//           //       arguments: {'id': message['news_id']});
//           // }
//           // if (message["type"] == 'vacancy') {
//           //   Get.toNamed(Routes.JOB_DETAILS,
//           //       arguments: {'id': message['vacancy_id']});
//           // }
//         }

//         if (message['meta_type'] == 'idea_box') {
//           // if (message['meta_id'] != null) {
//           //   Get.toNamed(Routes.IDEA_BOX_DETAILS,
//           //       arguments: {"id": message['meta_id']});
//           // } else {
//           //   Get.toNamed(Routes.IDEA_BOX);
//           // }
//         }

//         // if (message['type'] == 'internship') {
//         //   Get.toNamed(Routes.BOTTOMBAR, arguments: {'jupmto': 1});
//         // }
//         Get.toNamed(Routes.BOTTOMBAR, arguments: {});
//       } catch (e) {
//         print('notificatoin error $e');
//       }
//     }
//   }

//   static openAppFromNotification(RemoteMessage? message) {
//     if (message != null) {
//       print("------------------- open app from notificatoin");
//       print(message.data.toString());
//       print("-------------------");
//       navigateOnNotificationClick(message.data);
//       // box.write('pending_notification', message.data);
//     }
//   }

//   static Future<void> firebaseInitialise() async {
//     if (kIsWeb) return;
//     await Firebase.initializeApp();
//     initialize();

//     FirebaseMessaging instance = FirebaseMessaging.instance;
//     // var userdetails;
//     // if (AuthDetails.i) {
//     //   userdetails = box.read("userDetails")['userData'];
//     // }

//     customerSubscribeList
//         .addAll(["promotions", "news", "general", 'newrelease', 'deals']);

//     customerSubscribeList.forEach((element) async {
//       print("---------------Subscribe to $element-------------------");
//       if (!kIsWeb && Platform.isAndroid) {
//         await instance.subscribeToTopic(element);
//       }
//     });

//     // await FirebaseMessaging.instance
//     //     .getInitialMessage()
//     //     .then(openAppFromNotification);
//     RemoteMessage? initialMessage =
//         await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       Future.delayed(Duration(seconds: 1), () {
//         FirebaseHelpers.openAppFromNotification(initialMessage);
//       });
//     }

//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//     firebaseNotificationOnAppOpen();

//     if (!kIsWeb && Platform.isAndroid) {
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>()
//           ?.createNotificationChannel(blgosChannel);
//     }

//     if (!kIsWeb && Platform.isIOS) {
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               IOSFlutterLocalNotificationsPlugin>();
//     }

//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//             alert: true, badge: true, sound: true);
//   }

//   static void firebaseNotificationOnAppOpen() async {
//     // when APP is OPEN and notification is clicked
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       print("---------------------------------- firebaseNotificationOnAppOpen");
//       print(message.data.toString());
//       print("----------------------------------");
//       RemoteNotification? notification = message.notification;

//       if (message.data != null) {
//         final myToken = await box.read("my_fcm_token");
//         final senderId = message.data['sender_id'];

//         if (senderId != null && myToken != null && senderId == myToken) {
//           print("🔕 Skipped own notification (foreground)");
//           return;
//         }
//         if (message.data["color"] != null) {
//           Get.snackbar(notification!.title!, notification.body!,
//               backgroundColor:
//                   message.data['color'] == 'green' ? Colors.green : Colors.red,
//               colorText: Colors.white,
//               duration: const Duration(seconds: 30),
//               dismissDirection: DismissDirection.horizontal, onTap: (value) {
//             navigateOnNotificationClick(message.data);
//           });
//         } else {
//           Get.snackbar(notification!.title!, notification.body!,
//               backgroundColor: Colors.red,
//               colorText: Colors.white,
//               dismissDirection: DismissDirection.horizontal,
//               duration: const Duration(seconds: 30), onTap: (value) {
//             navigateOnNotificationClick(message.data);
//           });
//         }
//       }
//     });

//     Future<String> getFirebaseDeviceToken() async {
//       var deviceFcmToken;
//       FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
//       deviceFcmToken = await firebaseMessaging.getToken();
//       if (deviceFcmToken != null) {
//         box.write('my_fcm_token', deviceFcmToken);
//       }
//       firebaseMessaging.onTokenRefresh.listen((newToken) async {
//         deviceFcmToken = newToken;
//       });
//       return deviceFcmToken;
//     }
//   }

//   Future<bool> unsubscribeFromAllTopics() async {
//     // if (userType == "customer") {
//     customerSubscribeList.forEach((topic) async {
//       await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
//     });

//     return true;
//   }
// }

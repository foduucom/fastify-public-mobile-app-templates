// import 'dart:io';

// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
// import 'package:foduu_ecommerce/app/routes/app_pages.dart';

// import 'package:foduu_ecommerce/constants/constants.dart';
// import 'package:foduu_ecommerce/constants/helper_functions.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// class FirebaseHelpers {
//   static var box = GetStorage();
//   static var userType;
//   static List<String> customerSubscribeList = [];
//   static final List<String> _vendorSubscribeList = [];

//   static late BuildContext myContext;
//   static Future<void> initializeLocalNotifications() async {
//     setNotificationListeners();
//     checkInitialNotificationAction();
//     await AwesomeNotifications().initialize(
//         null, //'resource://drawable/res_app_icon',//
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
//     // initialAction = await AwesomeNotifications()
//     //     .getInitialNotificationAction(removeFromActionEvents: false);
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

//     flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
//     print(message.notification);
//     print("----------------------------------");

//     print(
//         '<<<<<<<<<<<<<<<<<<<<<<<<${message.notification}>>>>>>>>>>>>>>>>>>>>>>>>');
//     await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//       id: -1, // -1 is replaced by a random number
//       channelKey: 'alerts',
//       title: message.notification!.title,
//       body: message.notification!.body,
//       notificationLayout: NotificationLayout.BigText,
//       //     "A small step for a man, but a giant leap to Flutter's community!",
//       // bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
//       // largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
//       //'asset://assets/images/balloons-in-sky.jpg',

//       // payload: {'notificationId': '1234567890'}),
//     ));
//   }

//   // static navigateOnNotificationClick(message) {
//   //   if (message != null) {
//   //     print('arguments fffffffffffffff');
//   //     // Get.toNamed(Routes.BLOG, arguments: '6645fd26f0dbfef4515b110a');
//   //     Get.toNamed(Routes.DELETE_ACCOUNT);
//   //     //   if (message["type"] != null) {
//   //     //     if (message['type'] == 'event') {
//   //     //       // Get.toNamed(Routes.EVENTS_DETAIL,
//   //     //       //     arguments: {"slug": message["slug"], "type": "pushnotification"});
//   //     //     }
//   //     //     if (message["type"] == 'blog') {
//   //     //       // Get.toNamed(Routes.BLOG_DETAIL,
//   //     //       //     arguments: {"slug": message["slug"], "type": "pushnotification"});
//   //     //     }
//   //     //     if (message["type"] == 'product') {
//   //     //       // Get.toNamed(Routes.SINGLE_PRODUCT,
//   //     //       //     arguments: {"slug": message["slug"], "type": "pushnotification"});
//   //     //     }
//   //     //     // if (message["type"] == 'video') {
//   //     //     //   Get.toNamed(Routes.WATCHVEDIO);
//   //     //     // }
//   //     //   }
//   //   }
//   // }

//   // this is main function which get executed when app we recieve a notification and app is COMPLETELY CLOSED or TERMINATED!
//   static openAppFromNotification(RemoteMessage? message) {
//     if (message != null) {
//       print("-------------------");
//       print(message.data.toString());
//       print("-------------------");
//       // navigateOnNotificationClick(message.data);
//     }
//   }

//   static Future<void> firebaseInitialise() async {
//     initialize();
//     FirebaseMessaging instance = FirebaseMessaging.instance;
//     var userdetails;
//     if (AuthDetails.isUserLogin()) {
//       userdetails = box.read('userData');
//     }

//     customerSubscribeList.addAll([
//       // "khedusathi_event",
//       "foduu_ecommerce_blog",
//       "foduu_ecommerce_news",
//       "foduu_ecommerce_order",
//       // "khedusathi_tutorial",
//       "foduu_ecommerce_product",
//       "foduu_ecommerce_marketing",
//       "foduu_ecommerce_promotion",
//       // "khedusathi_cropcare",
//     ]);
//     if (userdetails != null) {
//       customerSubscribeList.addAll([
//         "foduu_ecommerce_${userdetails['_id']}",
//         "foduu_ecommerce_order_${userdetails['_id']}",
//       ]);
//     }

//     customerSubscribeList.forEach((element) async {
//       print("---------------Subscribe to $element-------------------");
//       await instance.subscribeToTopic(element);
//     });

//     await FirebaseMessaging.instance
//         .getInitialMessage()
//         .then(openAppFromNotification);

//     // on background notification - When app is not loaded at all!
//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//     firebaseNotificationOnAppOpen();

//     if (Platform.isAndroid) {
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>()
//           ?.createNotificationChannel(blgosChannel);
//     }

//     if (Platform.isIOS) {
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
//       RemoteNotification? notification = message.notification;
//       print("----------------------------------");
//       print(message.data.toString());
//       print("----------------------------------");

//       // AndroidNotification? androidNotification = message.notification?.android;
//       if (notification != null) {
//         if (message.data["color"] != null) {
//           Get.snackbar(notification.title!, notification.body!,
//               backgroundColor:
//                   message.data['color'] == 'green' ? Colors.green : Colors.red,
//               colorText: Colors.white,
//               duration: const Duration(seconds: 30),
//               dismissDirection: DismissDirection.horizontal, onTap: (value) {
//             // navigateOnNotificationClick(message.data);
//           });
//         } else {
//           Get.snackbar(notification.title!, notification.body!,
//               backgroundColor: themePrimaryColor,
//               colorText: Colors.white,
//               dismissDirection: DismissDirection.horizontal,
//               duration: const Duration(seconds: 30), onTap: (value) {
//             // navigateOnNotificationClick(message.data);
//           });
//         }
//       }
//     });

//     Future<String> getFirebaseDeviceToken() async {
//       var deviceFcmToken;
//       FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
//       deviceFcmToken = await firebaseMessaging.getToken();

//       return deviceFcmToken;
//     }

//     Future<bool> unsubscribeFromAllTopics() async {
//       // if (userType == "customer") {
//       customerSubscribeList.forEach((topic) async {
//         print(
//             "---------------- On Logout unsusbcribing to $topic -------------------");
//         await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
//       });

//       return true;
//     }

//     Future<void> unsubscribeToTopic() async {
//       // var userdetails = box.read("token");
//       //
//       // FirebaseMessaging instance = FirebaseMessaging.instance;
//     }

//     Future<void> unSubscribeToSpecificTopic(String topic) async {
//       await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
//     }

//     Future<void> subscribeToSpecificTopic(String topic) async {
//       await FirebaseMessaging.instance.subscribeToTopic(topic);
//     }

//     void afterLoginSubscribe() {
//       var userdetails = box.read('userData');

//       if (userdetails != null) {
//         customerSubscribeList.addAll([
//           "foduu_ecommerce_${userdetails['_id']}",
//         ]);
//       }
//       customerSubscribeList.forEach((element) async {
//         await subscribeToSpecificTopic(element);
//       });
//     }

//     Future<void> afterLogoutUnsubscribe() async {
//       var userdetails = box.read('userData');

//       if (userdetails != null) {
//         await unSubscribeToSpecificTopic(
//           "foduu_ecommerce_${userdetails['_id']}",
//         );
//       }
//     }
//   }
// }

// void setNotificationListeners() {
//   AwesomeNotifications().setListeners(
//     onActionReceivedMethod: (receivedAction) async {
//       print('TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT');
//       Get.toNamed(Routes.DELETE_ACCOUNT);
//     },
//   );
// }

// void checkInitialNotificationAction() {
//   print('QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ');
//   AwesomeNotifications()
//       .getInitialNotificationAction(removeFromActionEvents: false)
//       .then((receivedAction) {
//     print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
//     Get.toNamed(Routes.DELETE_ACCOUNT);
//   });
// }

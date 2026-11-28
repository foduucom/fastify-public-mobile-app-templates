import 'package:foduu_ecommerce/constants/firebase_notification.dart';
import 'package:foduu_ecommerce/models/local_notification.dart';
import 'package:foduu_ecommerce/services/local_storage_notification_service.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationsController extends GetxController {
  late final LocalStorageNotificationService storage;
  final isLoading = false.obs;
  final permissionGranted = Rxn<bool>();
  final permissionNeedsSettings = false.obs;

  List<LocalNotification> get notifications => storage.notifications;
  int get unreadCount => storage.getUnreadCount();

  @override
  void onInit() {
    super.onInit();
    storage = Get.isRegistered<LocalStorageNotificationService>()
        ? Get.find<LocalStorageNotificationService>()
        : Get.put(LocalStorageNotificationService());
    checkPermission();
  }

  Future<void> checkPermission() async {
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      permissionGranted.value =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      permissionNeedsSettings.value =
          (await Permission.notification.status).isPermanentlyDenied;
    } catch (_) {
      permissionGranted.value = null;
      permissionNeedsSettings.value = false;
    }
  }

  Future<void> requestPermission() async {
    try {
      await FirebaseMessaging.instance
          .requestPermission(alert: true, badge: true, sound: true);
      await checkPermission();
    } catch (_) {
      permissionGranted.value = false;
    }
  }

  Future<void> openNotificationSettings() async {
    await openAppSettings();
    await checkPermission();
  }

  Future<void> onPullToRefresh() async => checkPermission();

  Future<void> markAllAsRead() async => storage.markAllAsRead();

  Future<void> openNotification(LocalNotification notification) async {
    await storage.markAsRead(notification.id);
    FirebaseHelpers.navigateOnNotificationClick(notification.metadata);
  }

  Future<void> deleteNotification(String id) async {
    await storage.deleteNotification(id);
  }

  Future<void> clearNotifications() =>
      FirebaseHelpers.clearLocalNotifications();
}

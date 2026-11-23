import 'package:flutter/foundation.dart';
import 'package:foddu/constants/firebase_notification.dart';
import 'package:foddu/constants/helper_functions.dart';
import 'package:foddu/models/local_notification.dart';
import 'package:foddu/services/local_storage_notification_service.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  late final LocalStorageNotificationService notificationService;
  final permissionGranted = false.obs;
  final isRequestingPermission = false.obs;

  RxList<LocalNotification> get notifications =>
      notificationService.notifications;
  int get unreadCount => notificationService.getUnreadCount();

  @override
  void onInit() {
    super.onInit();
    notificationService = Get.isRegistered<LocalStorageNotificationService>()
        ? Get.find<LocalStorageNotificationService>()
        : Get.put(LocalStorageNotificationService());
    notificationService.reload();
    if (kIsWeb) {
      permissionGranted.value = true;
    } else {
      FirebaseHelpers.hasNotificationPermission().then((granted) {
        if (!isClosed) permissionGranted.value = granted;
      });
    }
  }

  Future<void> refreshNotifications() async => notificationService.reload();

  Future<void> markAllAsRead() => notificationService.markAllAsRead();

  Future<void> openNotification(LocalNotification notification) async {
    await notificationService.markAsRead(notification.id);
    FirebaseHelpers.navigateOnNotificationClick(notification.metadata);
  }

  Future<void> deleteNotification(String id) =>
      notificationService.deleteNotification(id);

  Future<void> clearAll() => notificationService.clearAll();

  Future<void> requestPermission() async {
    isRequestingPermission.value = true;
    try {
      permissionGranted.value =
          await FirebaseHelpers.requestNotificationPermission();
      if (!permissionGranted.value) {
        HelperFunctions().showSnackBarError(
          'Notifications are disabled. You can enable them in device settings.',
        );
      }
    } finally {
      isRequestingPermission.value = false;
    }
  }
}

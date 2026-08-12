import 'package:flutter/cupertino.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/models/local_notification.dart';
import 'package:foduu_ecommerce/services/local_storage_notification_service.dart';
import 'package:foduu_ecommerce/services/notification_sync_service.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController with BaseController {
  var isLoading = true.obs;
  var allnotificationList = <LocalNotification>[].obs;
  var currentPage = 1.obs;
  var maxPage = 1.obs;
  late ScrollController scrollController;

  final allnotificationListFromApi = <dynamic>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController = ScrollController();

    // Initial merge of local notifications
    _mergeNotifications();

    // Initial fetch from backend
    await fetchallnotificationlist();
    await fetchMoreDataOnScroll();

    // Listen to changes in local storage notifications
    ever(LocalStorageNotificationService.to.notifications, (_) {
      _mergeNotifications();
    });
  }

  void _mergeNotifications() {
    final combined = <LocalNotification>[];

    // Add all local notifications
    combined.addAll(LocalStorageNotificationService.to.notifications);

    // Map and merge API notifications (filtering out duplicates)
    for (var apiRaw in allnotificationListFromApi) {
      final apiNotif = _apiToLocal(apiRaw);
      final exists = combined.any((local) =>
          (local.id.isNotEmpty && local.id == apiNotif.id) ||
          (local.title == apiNotif.title && local.body == apiNotif.body));
      if (!exists) {
        combined.add(apiNotif);
      }
    }

    // Sort combined list by timestamp (newest first)
    combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    allnotificationList.assignAll(combined);
  }

  LocalNotification _apiToLocal(dynamic raw) {
    if (raw is LocalNotification) return raw;
    final map = Map<String, dynamic>.from(raw as Map);
    final id = map['id']?.toString() ??
        map['_id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final metadata = map['metadata'] != null
        ? Map<String, dynamic>.from(map['metadata'] as Map)
        : (map['data'] != null ? Map<String, dynamic>.from(map['data'] as Map) : <String, dynamic>{});
    
    return LocalNotification(
      id: id,
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? map['message']?.toString() ?? '',
      type: map['type']?.toString() ?? metadata['type']?.toString() ?? 'general',
      timestamp: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : (map['timestamp'] != null ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now() : DateTime.now()),
      isRead: map['is_read'] == true || map['is_read'] == 1 || map['read_at'] != null || map['read'] == true,
      isSynced: true, // Fetched from backend, so it is synced
      metadata: metadata,
    );
  }

  Future<void> fetchallnotificationlist() async {
    isLoading.value = true;
    try {
      var response = await BasicProvider(
              "frontend/notifications?count=10&page=${currentPage.value}")
          .getRequest()
          .catchError(handleError);
      if (response != null && response["data"] != null) {
        if (currentPage.value == 1) {
          allnotificationListFromApi.clear();
        }
        allnotificationListFromApi.addAll(response["data"]);
        maxPage(response["last_page"] ?? 1);
        _mergeNotifications();
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMoreDataOnScroll() async {
    scrollController.addListener(() async {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 50.0) {
        if (!isLoading.value && currentPage.value < maxPage.value) {
          currentPage(currentPage.value + 1);
          await fetchallnotificationlist();
        }
      }
    });
  }

  Future<void> onPullToRefresh() async {
    currentPage.value = 1;
    maxPage.value = 1;
    allnotificationListFromApi.clear();
    allnotificationList.clear();
    await fetchallnotificationlist();
    // Also trigger background sync in case we have offline pending syncs
    NotificationSyncService.to.syncPendingNotifications();
  }

  Future<void> markNotificationAsRead(String id) async {
    await LocalStorageNotificationService.to.markAsRead(id);
    _mergeNotifications();
    // Non-blocking sync to backend
    NotificationSyncService.to.syncPendingNotifications();
  }

  Future<void> markAllNotificationsAsRead() async {
    await LocalStorageNotificationService.to.markAllAsRead();
    _mergeNotifications();
    // Non-blocking sync to backend
    NotificationSyncService.to.syncPendingNotifications();
  }

  // Handle incoming static notification: Save locally first, push to backend, then fetch history
  Future<void> onStaticNotificationReceived(Map<String, dynamic> notificationData) async {
    try {
      // Step 1: Save to local storage
      final localNotif = LocalNotification(
        id: notificationData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: notificationData['title']?.toString() ?? '',
        body: notificationData['body']?.toString() ?? '',
        type: notificationData['type']?.toString() ?? 'general',
        timestamp: notificationData['timestamp'] != null
            ? DateTime.tryParse(notificationData['timestamp'].toString()) ?? DateTime.now()
            : DateTime.now(),
        isRead: false,
        isSynced: false,
        metadata: notificationData['metadata'] != null
            ? Map<String, dynamic>.from(notificationData['metadata'] as Map)
            : {},
      );

      await LocalStorageNotificationService.to.saveNotification(localNotif);
      _mergeNotifications();

      // Step 2: Push/Sync to Backend API
      await NotificationSyncService.to.syncPendingNotifications();

      // Step 3: Fetch latest notification data from server to keep list updated
      currentPage.value = 1;
      await fetchallnotificationlist();
    } catch (e) {
      debugPrint("Error handling static notification: $e");
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}

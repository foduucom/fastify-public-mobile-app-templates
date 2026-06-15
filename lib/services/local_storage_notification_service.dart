import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/local_notification.dart';

class LocalStorageNotificationService extends GetxService {
  static LocalStorageNotificationService get to => Get.find();

  final _box = GetStorage();
  static const String _storageKey = 'local_notifications';

  final RxList<LocalNotification> notifications = <LocalNotification>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  void _loadNotifications() {
    try {
      final stored = _box.read(_storageKey);
      if (stored != null && stored is List) {
        notifications.assignAll(
          stored
              .map((e) => LocalNotification.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList(),
        );
      }
    } catch (e) {
      print('Error loading notifications from GetStorage: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      await _box.write(
          _storageKey, notifications.map((e) => e.toJson()).toList());
    } catch (e) {
      print('Error saving notifications to GetStorage: $e');
    }
  }

  Future<void> saveNotification(LocalNotification newNotif) async {
    // Check for duplicate ID
    final existingIndex = notifications.indexWhere((n) => n.id == newNotif.id);

    if (existingIndex != -1) {
      // Preserve read status if it was already marked as read, unless the new one explicitly says read
      final existing = notifications[existingIndex];
      final mergedNotif = newNotif.copyWith(
        isRead: existing.isRead || newNotif.isRead,
        // If it was already synced, and the content/read-state hasn't changed, keep synced.
        // If the read status changed, we need to sync it again.
        isSynced:
            (existing.isRead == newNotif.isRead) ? existing.isSynced : false,
      );
      notifications[existingIndex] = mergedNotif;
    } else {
      // Insert at the beginning of the list
      notifications.insert(0, newNotif);
    }

    // Cap at 500 items to prevent performance issues
    if (notifications.length > 500) {
      notifications.removeLast();
    }

    await _saveToStorage();
  }

  List<LocalNotification> getPaginatedNotifications(int limit, int offset) {
    if (offset >= notifications.length) return [];
    final end = (offset + limit) > notifications.length
        ? notifications.length
        : (offset + limit);
    return notifications.sublist(offset, end);
  }

  int getUnreadCount() {
    return notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index] = notifications[index].copyWith(
        isRead: true,
        isSynced:
            false, // Mark as unsynced so the read status updates to backend
      );
      await _saveToStorage();
    }
  }

  Future<void> markAllAsRead() async {
    bool updated = false;
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(
          isRead: true,
          isSynced: false,
        );
        updated = true;
      }
    }
    if (updated) {
      await _saveToStorage();
    }
  }

  Future<void> updateSyncStatus(String id, bool isSynced,
      {int? retryCount, DateTime? lastSyncAttempt}) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(
        isSynced: isSynced,
        syncRetryCount: retryCount ?? notifications[index].syncRetryCount,
        lastSyncAttempt:
            lastSyncAttempt ?? notifications[index].lastSyncAttempt,
      );
      await _saveToStorage();
    }
  }

  Future<void> cleanOldNotifications(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final originalCount = notifications.length;
    notifications.removeWhere((n) => n.timestamp.isBefore(cutoff));

    if (notifications.length != originalCount) {
      await _saveToStorage();
    }
  }

  Future<void> clearAll() async {
    notifications.clear();
    await _box.remove(_storageKey);
  }
}

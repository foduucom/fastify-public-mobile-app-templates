import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../app/data/basic_provider.dart';
import '../models/local_notification.dart';
import 'local_storage_notification_service.dart';

class NotificationSyncService extends GetxService {
  static NotificationSyncService get to => Get.find();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  @override
  void onInit() {
    super.onInit();
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        debugPrint('Connectivity restored. Triggering notification sync...');
        syncPendingNotifications();
      }
    });
  }

  Future<void> syncPendingNotifications() async {
    if (_isSyncing) return;

    final unsynced = LocalStorageNotificationService.to.notifications
        .where((n) => !n.isSynced)
        .toList();

    if (unsynced.isEmpty) return;

    _isSyncing = true;
    debugPrint('Starting sync for ${unsynced.length} pending notifications...');

    try {
      for (var notification in unsynced) {
        // Check network before each item
        final network = await _connectivity.checkConnectivity();
        if (network == ConnectivityResult.none) {
          debugPrint('Sync aborted: No internet connection.');
          break;
        }

        // Exponential backoff logic based on retry count
        if (notification.syncRetryCount > 0 &&
            notification.lastSyncAttempt != null) {
          final backoffSeconds =
              1 << notification.syncRetryCount.clamp(1, 6); // Cap at 2^6 = 64s
          final backoffDuration = Duration(seconds: backoffSeconds);
          final nextAllowedAttempt =
              notification.lastSyncAttempt!.add(backoffDuration);
          if (DateTime.now().isBefore(nextAllowedAttempt)) {
            // Skip for this run to respect backoff
            continue;
          }
        }

        final success = await _pushNotificationToBackend(notification);
        if (success) {
          await LocalStorageNotificationService.to.updateSyncStatus(
            notification.id,
            true,
            retryCount: 0,
            lastSyncAttempt: DateTime.now(),
          );
        } else {
          final newRetryCount = notification.syncRetryCount + 1;
          await LocalStorageNotificationService.to.updateSyncStatus(
            notification.id,
            false,
            retryCount: newRetryCount,
            lastSyncAttempt: DateTime.now(),
          );

          if (newRetryCount >= 5) {
            debugPrint(
                'Notification ${notification.id} exceeded max retries. Mark status as synced to avoid blocking queue.');
            // We can set as synced (even if failed) or keep it failed so it doesn't block the sync loop indefinitely
            await LocalStorageNotificationService.to.updateSyncStatus(
              notification.id,
              true,
              retryCount: newRetryCount,
              lastSyncAttempt: DateTime.now(),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Sync loop error: $e');
    } finally {
      _isSyncing = false;
      debugPrint('Notification sync completed.');
    }
  }

  Future<bool> _pushNotificationToBackend(
      LocalNotification notification) async {
    try {
      final payload = {
        'id': notification.id,
        'title': notification.title,
        'body': notification.body,
        'type': notification.type,
        'timestamp': notification.timestamp.toIso8601String(),
        'is_read': notification.isRead ? 1 : 0,
        'metadata': notification.metadata,
      };

      debugPrint('Syncing notification ${notification.id} to backend...');

      // Call endpoint. It will append to apiURL.
      final response =
          await BasicProvider('notifications/receive').postRequest(payload);

      if (response != null) {
        debugPrint(
            'Successfully synced notification ${notification.id} to backend.');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(
          'Failed to sync notification ${notification.id} with error: $e');
      return false;
    }
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}

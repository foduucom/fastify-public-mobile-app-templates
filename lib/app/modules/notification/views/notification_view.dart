import 'package:flutter/material.dart';
import 'package:foddu/app/modules/notification/controller/notification_controller.dart';
import 'package:foddu/components/commonWidgets/secondary_app_header.dart';
import 'package:foddu/models/local_notification.dart';
import 'package:get/get.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: SecondaryAppHeader(
        title: 'Notifications',
        showRight: false,
        extraActions: [
          Obx(() => controller.unreadCount == 0
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Mark all as read',
                  onPressed: controller.markAllAsRead,
                  icon: const Icon(Icons.done_all_rounded),
                )),
          Obx(() => controller.notifications.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Clear notifications',
                  onPressed: controller.clearAll,
                  icon: const Icon(Icons.delete_outline_rounded),
                )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshNotifications,
        child: Obx(() {
          final notifications = controller.notifications.toList();
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _PermissionCard(controller: controller),
              const SizedBox(height: 12),
              if (notifications.isEmpty)
                SizedBox(
                  height: Get.height * 0.48,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_none_rounded,
                            size: 52, color: scheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text('No notifications yet',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                            'Updates about your orders and store activity will appear here.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                )
              else
                ...notifications.map((notification) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Dismissible(
                        key: ValueKey(notification.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) =>
                            controller.deleteNotification(notification.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: scheme.error,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child:
                              Icon(Icons.delete_outline, color: scheme.onError),
                        ),
                        child: _NotificationTile(
                          notification: notification,
                          onTap: () =>
                              controller.openNotification(notification),
                        ),
                      ),
                    )),
            ],
          );
        }),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.controller});
  final NotificationsController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      if (controller.permissionGranted.value) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_active_outlined,
                color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Turn on notifications for order and store updates.',
                  style: TextStyle(color: scheme.onSecondaryContainer)),
            ),
            TextButton(
              onPressed: controller.isRequestingPermission.value
                  ? null
                  : controller.requestPermission,
              child: controller.isRequestingPermission.value
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enable'),
            ),
          ],
        ),
      );
    });
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});
  final LocalNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = switch (notification.type.toLowerCase()) {
      'order' => Icons.local_shipping_outlined,
      'product' => Icons.shopping_bag_outlined,
      'promotion' || 'offer' || 'deal' => Icons.local_offer_outlined,
      _ => Icons.notifications_none_rounded,
    };
    return Material(
      color: notification.isRead
          ? scheme.surfaceContainerLow
          : scheme.primaryContainer.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: scheme.surface,
                foregroundColor: scheme.primary,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(notification.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(notification.body,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(_formatDate(notification.timestamp),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final date = '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
    final time = '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
    return '$date · $time';
  }
}

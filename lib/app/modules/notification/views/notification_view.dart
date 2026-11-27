import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/notification/controller/notification_controller.dart';
import 'package:foduu_ecommerce/components/commonWidgets/secondary_app_header.dart';
import 'package:foduu_ecommerce/models/local_notification.dart';
import 'package:get/get.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar:
            const SecondaryAppHeader(title: 'Notifications', showRight: false),
        body: RefreshIndicator(
          onRefresh: controller.onPullToRefresh,
          child: Obx(() {
            final items = controller.notifications.toList();
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (controller.permissionGranted.value == false)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.notifications_off_outlined),
                      title: const Text('Notifications are turned off'),
                      subtitle:
                          const Text('Enable permission to receive updates.'),
                      trailing: TextButton(
                          onPressed: controller.requestPermission,
                          child: const Text('Enable')),
                    ),
                  ),
                if (items.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(spacing: 8, children: [
                      if (controller.unreadCount > 0)
                        TextButton.icon(
                          onPressed: controller.markAllAsRead,
                          icon: const Icon(Icons.done_all),
                          label: const Text('Mark all read'),
                        ),
                      TextButton.icon(
                        onPressed: () => Get.dialog(AlertDialog(
                          title: const Text('Clear notifications?'),
                          content: const Text(
                              'This removes all saved notifications from this device.'),
                          actions: [
                            TextButton(
                                onPressed: Get.back,
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () async {
                                  Get.back();
                                  await controller.clearNotifications();
                                },
                                child: const Text('Clear')),
                          ],
                        )),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Clear all'),
                      ),
                    ]),
                  ),
                if (items.isEmpty)
                  SizedBox(
                    height: Get.height * .65,
                    child: const Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.notifications_none, size: 56),
                      SizedBox(height: 12),
                      Text('No notifications yet',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('Updates about your activity will appear here.'),
                    ])),
                  )
                else
                  ...items.map((item) => _NotificationTile(
                        item: item,
                        onTap: () => controller.openNotification(item),
                        onDelete: () => controller.deleteNotification(item.id),
                      )),
              ],
            );
          }),
        ),
      );
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile(
      {required this.item, required this.onTap, required this.onDelete});
  final LocalNotification item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        color: item.isRead
            ? theme.colorScheme.surface
            : theme.colorScheme.primaryContainer.withOpacity(.35),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(child: Icon(_iconFor(item.type))),
          title: Text(item.title.isEmpty ? 'Update' : item.title,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.body, maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5),
              Text(_formatTime(item.timestamp),
                  style: theme.textTheme.labelSmall),
            ]),
          ),
          trailing: item.isRead
              ? null
              : Icon(Icons.circle, size: 9, color: theme.colorScheme.primary),
        ),
      ),
    );
  }

  IconData _iconFor(String type) => switch (type.toLowerCase()) {
        'order' => Icons.receipt_long_outlined,
        'product' => Icons.local_offer_outlined,
        'blog' => Icons.article_outlined,
        _ => Icons.notifications_active_outlined,
      };

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final date = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final today = DateTime(now.year, now.month, now.day);
    if (date == today)
      return 'Today · ${TimeOfDay.fromDateTime(timestamp).format(Get.context!)}';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
  }
}

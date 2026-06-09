import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/app/modules/notification/controller/notification_controller.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/firebase_notification.dart';
import 'package:foduu_ecommerce/models/local_notification.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() {
            final unreadCount = controller.allnotificationList.where((n) => !n.isRead).length;
            return Text(unreadCount > 0 
                ? '${'Notifications'.tr} ($unreadCount)' 
                : 'Notifications'.tr);
          }),
          elevation: 0,
          actions: [
            Obx(() {
              final hasUnread = controller.allnotificationList.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.mark_chat_read_outlined),
                tooltip: 'Mark all as read'.tr,
                onPressed: () => controller.markAllNotificationsAsRead(),
              );
            }),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await controller.onPullToRefresh();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: ListView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Column(
                  children: [
                    Obx(
                      () => controller.allnotificationList.isEmpty &&
                              controller.isLoading.isFalse
                          ? SizedBox(
                              height: Get.height * 0.6,
                              child: Center(
                                child: Text(
                                  'No notification found'.tr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: controller.allnotificationList.isNotEmpty
                                  ? controller.allnotificationList.length
                                  : 10,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                if (controller.allnotificationList.isEmpty &&
                                    controller.isLoading.isTrue) {
                                  return const NotificationListShimmer();
                                }
                                return NotificationList(
                                  item: controller.allnotificationList[index],
                                );
                              },
                            ),
                    ),
                  ],
                ),
                Obx(() => controller.isLoading.isTrue &&
                        controller.allnotificationList.isNotEmpty
                    ? HelperFunctions().loadingIndicator()
                    : Container()),
                const SizedBox(height: 20)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  final LocalNotification item;

  const NotificationList({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    IconData typeIcon;
    Color iconColor;
    Color iconBgColor;

    switch (item.type) {
      case 'job_application':
        typeIcon = Icons.work_outline;
        iconColor = Colors.blue;
        iconBgColor = Colors.blue.withOpacity(0.1);
        break;
      case 'product':
        typeIcon = Icons.shopping_bag_outlined;
        iconColor = Colors.orange;
        iconBgColor = Colors.orange.withOpacity(0.1);
        break;
      case 'blog':
        typeIcon = Icons.article_outlined;
        iconColor = Colors.purple;
        iconBgColor = Colors.purple.withOpacity(0.1);
        break;
      case 'order':
        typeIcon = Icons.local_shipping_outlined;
        iconColor = Colors.green;
        iconBgColor = Colors.green.withOpacity(0.1);
        break;
      case 'deals':
      case 'promotions':
        typeIcon = Icons.local_offer_outlined;
        iconColor = Colors.red;
        iconBgColor = Colors.red.withOpacity(0.1);
        break;
      default:
        typeIcon = Icons.notifications_none;
        iconColor = DynamicThemeManager().lightColors.primary;
        iconBgColor = DynamicThemeManager().lightColors.primary.withOpacity(0.1);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: InkWell(
            onTap: () {
              controller.markNotificationAsRead(item.id);
              final Map<String, dynamic> navigationData = {
                'type': item.type,
                ...item.metadata,
              };
              FirebaseHelpers.navigateOnNotificationClick(navigationData);
            },
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: item.isRead
                    ? const Color.fromARGB(255, 248, 248, 248)
                    : DynamicThemeManager().lightColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: item.isRead
                      ? Colors.transparent
                      : DynamicThemeManager().lightColors.primary.withOpacity(0.15),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 2.0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (item.metadata['topic'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: DynamicThemeManager().lightColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: DynamicThemeManager().lightColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              item.metadata['topic']
                                  .toString()
                                  .replaceAll('foduu_ecommerce_', '')
                                  .capitalizeFirst!,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: DynamicThemeManager().lightColors.primary,
                              ),
                            ),
                          )
                        else
                          const SizedBox(),
                        if (!item.isSynced)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cloud_queue,
                                size: 12,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Pending sync'.tr,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (item.metadata['topic'] != null || !item.isSynced)
                      const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            typeIcon,
                            color: iconColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: item.isRead ? FontWeight.bold : FontWeight.w900,
                                        color: item.isRead ? Colors.black87 : Colors.black,
                                      ),
                                    ),
                                  ),
                                  if (!item.isRead)
                                    Container(
                                      margin: const EdgeInsets.only(left: 6, top: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.body,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: item.isRead ? Colors.grey.shade600 : Colors.black87,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        HelperFunctions().toCarbonToHumanDateFormat(item.timestamp.toIso8601String()),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationListShimmer extends StatelessWidget {
  const NotificationListShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey,
        highlightColor: Colors.grey,
        child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: pageSurroundingPadding,
            width: Get.width * 0.4,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(50))),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 15,
                        width: Get.width * 0.5,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(30))),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                        height: 15,
                        width: 90,
                        alignment: Alignment.topLeft,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(30))),
                    const SizedBox(
                      height: 7,
                    ),
                    Container(
                        height: 15,
                        width: Get.width * 0.6,
                        alignment: Alignment.topLeft,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(30))),
                  ],
                ),
              ],
            )));
  }
}

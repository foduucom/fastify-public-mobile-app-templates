import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/app/modules/notification/controller/notification_controller.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text('Notifications'.tr),
            elevation: 0,
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
                                    child: Text('No notification found'.tr,
                                        style: TextStyle(
                                            // color: themePrimaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20))))
                            : ListView.builder(
                                itemCount:
                                    controller.allnotificationList.isNotEmpty
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
          )),
    );
  }
}

class NotificationList extends StatelessWidget {
  final dynamic item;

  NotificationList({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     item['type'] != null
        //         ? Text(
        //             item['type'].toString().capitalizeFirst.toString(),
        //             style: const TextStyle(
        //               fontWeight: FontWeight.w600,
        //               fontSize: 16,
        //             ),
        //           )
        //         : Container(),
        // Text(
        //   HelperFunctions().toCarbonToHumanDateFormat(item["created_at"]),
        // )
        //   ],
        // ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 238, 238, 238),
              borderRadius: BorderRadius.circular(10.0),
              // border: Border.all(color: Colors.blue),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 1.0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/notification.png',
                    height: 70,
                    width: 50,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          child: Text(
                            item["title"] != null
                                ? item["title"].toString()
                                : '',
                            style: const TextStyle(
                              // color: themeTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          child: Text(
                            item["body"] != null ? item["body"].toString() : '',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      HelperFunctions()
                          .toCarbonToHumanDateFormat(item["created_at"]),
                    ),
                  )
                ],
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

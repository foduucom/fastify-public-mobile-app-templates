import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/notification/controller/notification_controller.dart';
import 'package:foduu_ecommerce/components/commonWidgets/secondary_app_header.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//           appBar: AppBar(
//             title: Text('Notifications'.tr),
//             elevation: 0,
//           ),
//           body: RefreshIndicator(
//             onRefresh: () async {
//               await controller.onPullToRefresh();
//             },
//             child: Padding(
//               padding: const EdgeInsets.only(left: 10, right: 10),
//               child: ListView(
//                 controller: controller.scrollController,
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 children: [
//                   Column(
//                     children: [
//                       Obx(
//                         () => controller.allnotificationList.isEmpty &&
//                                 controller.isLoading.isFalse
//                             ? SizedBox(
//                                 height: Get.height * 0.6,
//                                 child: Center(
//                                     child: Text('No notification found'.tr,
//                                         style: TextStyle(
//                                             // color: themePrimaryColor,
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 20))))
//                             : ListView.builder(
//                                 itemCount:
//                                     controller.allnotificationList.isNotEmpty
//                                         ? controller.allnotificationList.length
//                                         : 10,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 shrinkWrap: true,
//                                 itemBuilder: (context, index) {
//                                   if (controller.allnotificationList.isEmpty &&
//                                       controller.isLoading.isTrue) {
//                                     return const NotificationListShimmer();
//                                   }
//                                   return NotificationList(
//                                     item: controller.allnotificationList[index],
//                                   );
//                                 },
//                               ),
//                       ),
//                     ],
//                   ),
//                   Obx(() => controller.isLoading.isTrue &&
//                           controller.allnotificationList.isNotEmpty
//                       ? HelperFunctions().loadingIndicator()
//                       : Container()),
//                   const SizedBox(height: 20)
//                 ],
//               ),
//             ),
//           )),
    var width = Get.width;
    var height = Get.height;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.02,
        ),
        child: Column(
          children: [
            SizedBox(height: height * 0.02),
            //HEADER PAGE
            SecondaryAppHeader(
              title: "Checkout",
              showRight: false,
            ),
            SizedBox(height: height * 0.02),
            Container(
              width: width * 0.92, // ≈ 345
              height: height * 0.75, // ≈ 580
              child: Column(
                children: [
                  SizedBox(
                    width: width * 0.92,
                    height: height * 0.46, // ≈ 364
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: const Color(0xFFE0E0E0),
                              ),
                            ),
                            SizedBox(width: width * 0.03),
                            Text(
                              "Today",
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: height * 0.018, // ≈ 14
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                color: const Color(0xFFA3A3A3),
                              ),
                            ),
                            SizedBox(width: width * 0.03),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: const Color(0xFFE0E0E0),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.02),
                        _notificationRow(
                            timeText: "2m ago", width: width, height: height),
                        SizedBox(height: height * 0.02),
                        _notificationRow(
                            timeText: "5m ago", width: width, height: height),
                        SizedBox(height: height * 0.02),
                        _notificationRow(
                            timeText: "10m ago", width: width, height: height),
                        SizedBox(height: height * 0.02),
                        _notificationRow(
                            timeText: "15m ago", width: width, height: height),
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.03), // gap 24
                  SizedBox(
                    width: width * 0.92,
                    height: height * 0.25, // ≈ 192
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: const Color(0xFFE0E0E0),
                              ),
                            ),
                            SizedBox(width: width * 0.03),
                            Text(
                              "Yesterday",
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: height * 0.018,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                color: const Color(0xFFA3A3A3),
                              ),
                            ),
                            SizedBox(width: width * 0.03),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: const Color(0xFFE0E0E0),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.02),
                        _notificationRow(
                            timeText: "Yesterday",
                            width: width,
                            height: height),
                        SizedBox(height: height * 0.02),
                        _notificationRow(
                            timeText: "Yesterday",
                            width: width,
                            height: height),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationRow({
    required timeText,
    required width,
    required height,
  }) {
    return Container(
      width: width * 0.94,
      height: height * 0.088, // ≈ 70
      padding: EdgeInsets.all(width * 0.026), // ≈ 10
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.015), // ≈ 12
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: height * 0.062, // ≈ 50
            height: height * 0.062,
            decoration: BoxDecoration(
              color: const Color(0xFF5A2658),
              borderRadius: BorderRadius.circular(height * 0.012), // ≈ 10
            ),
            child: Center(
              child: Icon(
                Icons.check_circle,
                size: height * 0.03, // ≈ 24
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: width * 0.03),
          SizedBox(
            width: width * 0.58, // ≈ 219
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "New Collection Arrival",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: height * 0.018,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: const Color(0xFF4C4C4C),
                  ),
                ),
                SizedBox(height: height * 0.004),
                Text(
                  "Your favorite brand, XYZ Fashion, has just released their latest collection. Explore the freshest trends today!",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: height * 0.015,
                    fontWeight: FontWeight.w400,
                    height: 2,
                    color: const Color(0xFF858585),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            timeText,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: height * 0.01, // ≈ 10
              fontWeight: FontWeight.w500,
              height: 2.2, // ≈ 22
              color: const Color(0xFF858585),
            ),
          ),
        ],
      ),
    );
  }
}

// class NotificationList extends StatelessWidget {
//   final dynamic item;

//   NotificationList({Key? key, required this.item}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
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
//         const SizedBox(
//           height: 10,
//         ),
//         Padding(
//           padding: const EdgeInsets.only(bottom: 15),
//           child: Container(
//             decoration: BoxDecoration(
//               color: const Color.fromARGB(255, 238, 238, 238),
//               borderRadius: BorderRadius.circular(10.0),
//               // border: Border.all(color: Colors.blue),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.white.withOpacity(0.2),
//                   blurRadius: 1.0,
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     'assets/images/notification.png',
//                     height: 70,
//                     width: 50,
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(
//                           child: Text(
//                             item["title"] != null
//                                 ? item["title"].toString()
//                                 : '',
//                             style: const TextStyle(
//                               // color: themeTextColor,
//                               fontSize: 15,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         SizedBox(
//                           child: Text(
//                             item["body"] != null ? item["body"].toString() : '',
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Align(
//                     alignment: Alignment.bottomRight,
//                     child: Text(
//                       HelperFunctions()
//                           .toCarbonToHumanDateFormat(item["created_at"]),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class NotificationListShimmer extends StatelessWidget {
//   const NotificationListShimmer({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//         baseColor: Colors.grey,
//         highlightColor: Colors.grey,
//         child: Container(
//             margin: const EdgeInsets.only(bottom: 10),
//             padding: pageSurroundingPadding,
//             width: Get.width * 0.4,
//             decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(12)),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                     height: 50,
//                     width: 50,
//                     decoration: BoxDecoration(
//                         color: Colors.grey,
//                         borderRadius: BorderRadius.circular(50))),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 const SizedBox(width: 10),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                         height: 15,
//                         width: Get.width * 0.5,
//                         decoration: BoxDecoration(
//                             color: Colors.grey,
//                             borderRadius: BorderRadius.circular(30))),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                     Container(
//                         height: 15,
//                         width: 90,
//                         alignment: Alignment.topLeft,
//                         decoration: BoxDecoration(
//                             color: Colors.grey,
//                             borderRadius: BorderRadius.circular(30))),
//                     const SizedBox(
//                       height: 7,
//                     ),
//                     Container(
//                         height: 15,
//                         width: Get.width * 0.6,
//                         alignment: Alignment.topLeft,
//                         decoration: BoxDecoration(
//                             color: Colors.grey,
//                             borderRadius: BorderRadius.circular(30))),
//                   ],
//                 ),
//               ],
//             )));
//   }
// }

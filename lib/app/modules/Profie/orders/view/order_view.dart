import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/components/buttons/custom_textbutton.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../controller/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  OrdersView({Key? key}) : super(key: key);
  var controllerval = Get.lazyPut(() => OrdersController());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(title: Text('Orders'.tr), elevation: 0.0),
          body: RefreshIndicator(
            onRefresh: () async {
              controller.onRefresh();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Obx(
                () =>
                    controller.isLoading.isFalse && controller.orderList.isEmpty
                        ? const NoOrders()
                        : ListView(
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            controller: controller.scrollController,
                            children: [
                              // TextWidget('past_orders'.tr, FontWeight.w600, 18,
                              //     Colors.black),
                              // const SizedBox(height: 20),
                              const Text(
                                'Past Orders',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: Colors.black),
                              ),
                              ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    if (controller.isLoading.isTrue &&
                                        controller.orderList.isEmpty) {
                                      return const OrderListShimmer();
                                    } else {
                                      return PastOrders(
                                        item: controller.orderList[index],
                                        onTapHelp: () {
                                          Get.toNamed(Routes.HELPANDSUPPORT);
                                        },
                                      );
                                    }
                                  },
                                  separatorBuilder: (context, index) {
                                    return Container();
                                  },
                                  itemCount: controller.orderList.isNotEmpty
                                      ? controller.orderList.length
                                      : 6),
                              if (controller.isLoading.isTrue)
                                Center(
                                  child: HelperFunctions().loadingIndicator(),
                                )
                            ],
                          ),
              ),
            ),
          )),
    );
  }
}

class PastOrders extends StatelessWidget {
  const PastOrders({super.key, required this.item, required this.onTapHelp});

  final dynamic item;
  final Function()? onTapHelp;

  @override
  Widget build(BuildContext context) {
    var ordername = 'Orders'.tr;
    var need_help = 'need_help'.tr;
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    print(item);
                    // Get.toNamed(Routes.ORDER_DETAILS,
                    //     arguments: {'id': item["_id"]});
                  },
                  child: Container(
                      height: Get.width * 0.26,
                      margin: const EdgeInsets.only(right: 18),
                      width: Get.width * 0.26,
                      decoration: BoxDecoration(
                          border: Border.all(width: 2),
                          borderRadius: BorderRadius.circular(6)),
                      child: CachedNetworkImage(
                          imageUrl: item['products'][0]['image'] == null
                              ? HelperFunctions.getNoImage()
                              : url + item['products'][0]['image'],
                          errorWidget: (context, url, error) {
                            return Container(
                              color: Colors.grey,
                              child: Icon(Icons.error),
                            );
                          },
                          // item['orderdetail'][0]['products']['image']
                          //     .toString(),
                          fit: BoxFit.cover)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: Get.width * 0.3,
                        child: Text(item['products'][0]['name'].toString(),
                            style:
                                const TextStyle(fontWeight: FontWeight.w500))),
                    const SizedBox(height: 6),
                    Text(
                      'Quantity:'.tr + '${item['products'][0]['qty']}',
                    ),
                    // TextButtonCustom('view all'.tr, FontWeight.w400, () {
                    //   Get.toNamed(Routes.ORDER_DETAILS,
                    //       arguments: {'id': item["_id"]});
                    //   // print(item['_id']);
                    // }, themeGreenColor, 14)
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  ordername.length > 5
                      ? 'Orders'.tr.substring(0, 5) +
                          '..' +
                          ' #${item["order_no"]}'
                      : ordername + ' #${item["id"]}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                // Align(
                //     alignment: Alignment.centerRight,
                //     child: Button(
                //         name: item['paymentmethod'] != null
                //             ? '${item['paymentmethod']}'
                //             : ' ',
                //         onPressed: () {},
                //         color: Colors.white,
                //         bgcolor: secondaryGreenColor)),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Get.toNamed(Routes.ORDER_DETAILS, arguments: {'id': item["id"]});
          },
          child: Stack(
            children: [
              Image(
                  image: const AssetImage('assets/images/mapsection.png'),
                  width: Get.width,
                  height: Get.height * 0.1,
                  fit: BoxFit.cover),
              Positioned(
                  left: 20,
                  bottom: 24,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // TextWidget('ordered'.tr, FontWeight.w400, 14,
                              //     greyTextColor),
                              // TextWidget(
                              //     ':', FontWeight.w400, 14, greyTextColor),
                              Text(
                                'ordered',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                ':',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            HelperFunctions().toCarbonToHumanDateFormat(
                                item['created_at'].toString()),
                            style: TextStyle(color: Colors.black),
                          )
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              // TextWidget('delivery_status'.tr, FontWeight.w400,
                              //     14, greyTextColor),
                              // TextWidget(
                              //     ':', FontWeight.w400, 14, greyTextColor),
                              Text(
                                'delivery_status',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                ':',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          // TextWidget(item['status_name'], FontWeight.w400, 14,
                          //     Colors.black),
                          Text(
                            item['payment_status'],
                            style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ))
            ],
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.star_border_outlined, size: 16),
            Text('rate and review product'.tr,
                style: const TextStyle(
                  fontSize: 12,
                )),
            const SizedBox(width: 15),
            GestureDetector(
              onTap: onTapHelp,
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16),
                  Text(
                      need_help.length > 9
                          ? need_help.substring(0, 8) + '..'
                          : need_help,
                      style: const TextStyle(
                        fontSize: 12,
                      )),
                  const Text(':',
                      style: TextStyle(
                        fontSize: 12,
                      ))
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 5),
        const Divider(thickness: 2)
      ],
    );
  }
}

class OrderListShimmer extends StatelessWidget {
  const OrderListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  height: Get.width * 0.26,
                  margin: const EdgeInsets.only(right: 18),
                  width: Get.width * 0.26,
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 2),
                      borderRadius: BorderRadius.circular(6))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: Get.width * 0.6,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                      )),
                  const SizedBox(height: 6),
                  SizedBox(
                      width: Get.width * 0.16,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                      )),
                  const SizedBox(height: 6),
                  SizedBox(
                      width: Get.width * 0.2,
                      child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)))),
                ],
              )
            ],
          ),
          const SizedBox(height: 15),
          Stack(
            children: [
              Container(
                  width: Get.width,
                  height: Get.height * 0.1,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10))),
              Positioned(
                  left: 20,
                  bottom: 24,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: Get.width * 0.15,
                              child: Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(10)))),
                          const SizedBox(height: 6),
                          SizedBox(
                              width: Get.width * 0.2,
                              child: Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(10)))),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: Get.width * 0.15,
                              child: Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(10)))),
                          const SizedBox(height: 6),
                          SizedBox(
                              width: Get.width * 0.2,
                              child: Container(
                                height: 10,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                              )),
                        ],
                      ),
                    ],
                  ))
            ],
          ),
          const SizedBox(height: 5),
          const Divider(
            thickness: 2,
            color: Colors.white,
          )
        ],
      ),
    );
  }
}

class NoOrders extends StatelessWidget {
  const NoOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: pageSurroundingPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child:
                  Image(image: AssetImage('assets/images/emptyimagecart.png'))),
          const SizedBox(height: 20),
          Text(
            'whoops_no_order_yet'.tr,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 18, color: Colors.black),
          ),
          const SizedBox(height: 10),
          Text('look_like_you_have_no_orders_yet.'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          AppButton(
            keypressEvent: () {
              // Get.toNamed(Routes.HOME,
              //     arguments: {"slug": "AllProducts", "name": "All Products"});
              Get.find<BottombarController>().currentPageIndex.value = 0;
              Get.find<BottombarController>().pageController.jumpToPage(0);
              Get.back();

              Get.back();
            },

            // child: Text('start_shopping'.tr,
            //     style: const TextStyle(
            //         fontWeight: FontWeight.w500,
            //         fontSize: 16,
            //         color: Colors.white))
            itemText: 'start Shopping'.tr,
          )
        ],
      ),
    );
  }
}

// Row(
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//     Flexible(
//       flex: 10,
//       child: Card(
//         color: const Color(0xffEDEFF4).withOpacity(0.5),
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(6),
//           side: BorderSide(
//               color: const Color(0xffEDEFF4).withOpacity(0.5),
//               width: 1),
//         ),
//         child: Padding(
//           padding:
//               const EdgeInsets.only(left: 10, top: 9, bottom: 9),
//           child: Row(
//             children: [
//               Icon(
//                 CupertinoIcons.search,
//                 color: greyTextColor,
//                 size: 30,
//               ),
//               const SizedBox(width: 8),
//               TextWidget('Search Orders', FontWeight.w400, 18,
//                   greyTextColor),
//             ],
//           ),
//         ),
//       ),
//     ),
//     Flexible(
//       flex: 2,
//       child: Container(
//         height: 48,
//         width: 48,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         decoration: BoxDecoration(
//             color: const Color(0xff309530),
//             borderRadius: BorderRadius.circular(6)),
//         child: const Image(
//             image: AssetImage('assets/images/filter.png')),
//       ),
//     )
//   ],
// ),
//===========================
// Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Flexible(
//                                 flex: 12,
//                                 child: GestureDetector(
//                                     onTap: () {
//                                       // Get.toNamed(Routes.SEARCH_VIEW);
//                                     },
//                                     child: SearchBarDashboard(
//                                         bgcolour: searchColor,
//                                         searchBarRadius:
//                                             BorderRadius.circular(20)))),
//                             Flexible(
//                                 flex: 2,
//                                 child: Container(
//                                     height: 40,
//                                     width: 40,
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 10),
//                                     decoration: BoxDecoration(
//                                         color: secondaryGreenColor,
//                                         borderRadius: BorderRadius.circular(6)),
//                                     child: const Image(
//                                         image: AssetImage(
//                                             'assets/images/filter.png'))))
//                           ]),
//                       const SizedBox(height: 20),

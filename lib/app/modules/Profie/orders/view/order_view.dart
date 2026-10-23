import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/buttons/appbutton.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/order_currency.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zouhi/components/product_image_placeholder.dart';

import '../controller/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  OrdersView({Key? key}) : super(key: key);
  final controllerval = Get.lazyPut(() => OrdersController());
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
                () => controller.isLoading.value
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          PastOrdersShimmer(),
                          PastOrdersShimmer(),
                          PastOrdersShimmer(),
                          PastOrdersShimmer(),
                        ],
                      )
                    : ListView(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: controller.scrollController,
                        children: [
                          Text(
                            'Past Orders ${controller.orderList.length}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: context.themeTextColor),
                          ),
                          controller.orderList.isEmpty
                              ? const NoOrders()
                              : Column(
                                  children: [
                                    ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          // return SizedBox();
                                          return PastOrders(
                                            item: controller.orderList[index],
                                            onTapHelp: () {
                                              // Get.toNamed(Routes.HELPANDSUPPORT);
                                            },
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return Container();
                                        },
                                        itemCount: controller.orderList.length),
                                    if (controller.isLoadMore.value)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                                context.themeRedColor),
                                          ),
                                        ),
                                      ),
                                    if (!controller.hasMore.value &&
                                        controller.orderList.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0),
                                        child: Center(
                                          child: Text(
                                            "No more orders",
                                            style: TextStyle(
                                              color: context.themeSecondrytext,
                                              fontSize: 13,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
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
    final symbol = orderCurrencySymbol(item['currency']);
    final double totalVal =
        double.tryParse(item['total']?.toString() ?? '0') ?? 0.0;
    final totalStr = totalVal.toStringAsFixed(totalVal % 1 == 0 ? 0 : 2);

    var firstProduct = (item['products'] != null && item['products'].isNotEmpty)
        ? item['products'][0]
        : null;
    var productObj = firstProduct != null ? (firstProduct['product_id'] ?? firstProduct['product']) : null;
    var productType = (productObj is Map ? productObj['type'] : null) ?? 'simple';
    var variantObj = firstProduct != null ? firstProduct['variant'] : null;
    var variantName = (variantObj is Map
            ? (variantObj['name'] ?? variantObj['variant'])?.toString()
            : null) ??
        '';
    final imageUrl = HelperFunctions().getImage([
      if (variantObj is Map) ...[
        variantObj['front_image'],
        variantObj['featured_image'],
        variantObj['image'],
      ],
      if (firstProduct is Map) ...[
        firstProduct['image'],
        firstProduct['featured_image'],
        firstProduct['front_image'],
      ],
      if (firstProduct is Map && firstProduct['product_id'] is Map) ...[
        firstProduct['product_id']['front_image'],
        firstProduct['product_id']['featured_image'],
        firstProduct['product_id']['image'],
        if (firstProduct['product_id']['images'] is List &&
            firstProduct['product_id']['images'].isNotEmpty)
          firstProduct['product_id']['images'][0],
      ],
      if (firstProduct is Map && firstProduct['product'] is Map) ...[
        firstProduct['product']['front_image'],
        firstProduct['product']['featured_image'],
        firstProduct['product']['image'],
        if (firstProduct['product']['images'] is List &&
            firstProduct['product']['images'].isNotEmpty)
          firstProduct['product']['images'][0],
      ],
    ]);
    final bool hasValidImage = imageUrl.isNotEmpty &&
        imageUrl != HelperFunctions.getNoImage();

    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.ORDER_DETAILS, arguments: {'id': item["_id"]});
      },
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: Get.width * 0.26,
                      margin: const EdgeInsets.only(right: 16),
                      width: Get.width * 0.26,
                      decoration: BoxDecoration(
                          border: Border.all(color: context.themeBorderColor, width: 1),
                          borderRadius: BorderRadius.circular(8)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Container(
                          color: context.themegreyColor,
                          child: hasValidImage
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: context.themegreyColor,
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) {
                                    return const ProductImagePlaceholder(
                                      radius: 7,
                                    );
                                  },
                                )
                              : const ProductImagePlaceholder(
                                  radius: 7,
                                ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (firstProduct != null)
                            Text(
                              firstProduct['name']?.toString() ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: context.themeTextColor),
                            ),
                           if (variantName.isNotEmpty &&
                              productType == 'variable' &&
                              (firstProduct == null ||
                                  variantName.trim() !=
                                      (firstProduct['name']?.toString() ?? '')
                                          .trim())) ...[
                            const SizedBox(height: 4),
                            Text(
                              variantName,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.themeSecondrytext,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          if (firstProduct != null)
                            Text(
                              '${'Quantity: '.tr}${firstProduct['qty'] ?? firstProduct['quantity'] ?? 1}',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.themeSecondrytext,
                              ),
                            ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(Routes.ORDER_DETAILS,
                                  arguments: {'id': item["_id"]});
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                'view all'.tr,
                                style: TextStyle(
                                  color: context.themeGreenColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item["order_no"] != null
                        ? 'Order #${item["order_no"]}'
                        : 'Order #${item["_id"]?.toString().substring(0, 8) ?? ""}',
                    style: TextStyle(
                      color: context.themeSecondrytext,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$symbol $totalStr',
                    style: TextStyle(
                      color: context.themeRedColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                    image: const AssetImage('assets/images/mapsection.png'),
                    width: Get.width,
                    height: 75,
                    fit: BoxFit.cover),
              ),
              Container(
                width: Get.width,
                height: 75,
                decoration: BoxDecoration(
                  color: context.colors.surface.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Order Placed:'.tr,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                  color: context.themeSecondrytext),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              HelperFunctions.formatOrderPlacedDate(item),
                              style: TextStyle(
                                color: context.themeTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Payment Status:'.tr,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                  color: context.themeSecondrytext),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (item['payment_status'] ?? 'pending')
                                  .toString()
                                  .toUpperCase(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: item['payment_status']
                                              ?.toString()
                                              .toLowerCase() ==
                                          'paid'
                                      ? context.themeGreenColor
                                      : (item['payment_status']
                                                  ?.toString()
                                                  .toLowerCase() ==
                                              'failed'
                                          ? context.themeRedColor
                                          : Colors.orange)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 10),
          // Row(
          //   children: [
          //     const SizedBox(width: 4),
          //     GestureDetector(
          //       onTap: onTapHelp,
          //       child: Row(
          //         children: [
          //           const Icon(Icons.info_outline,
          //               color: themeSecondrytext, size: 16),
          //           const SizedBox(width: 4),
          //           Text('need help ?'.tr,
          //               style: const TextStyle(
          //                   fontSize: 12,
          //                   color: themeSecondrytext,
          //                   fontWeight: FontWeight.w500)),
          //         ],
          //       ),
          //     )
          //   ],
          // ),
          const SizedBox(height: 10),
          Divider(thickness: 1, color: context.themeBorderColor)
        ],
      ),
    );
  }
}

class OrderListShimmer extends StatelessWidget {
  const OrderListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.themegreyColor,
      highlightColor: context.themegreyColor,
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
                      color: context.colors.surface,
                      border: Border.all(color: context.themeTextColor, width: 2),
                      borderRadius: BorderRadius.circular(6))),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 80,
                      height: 10,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 100,
                      height: 10,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ],
                ),
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
                  right: 10,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: 60,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10))),
                            const SizedBox(height: 6),
                            Container(
                                width: 80,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: 60,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10))),
                            const SizedBox(height: 6),
                            Container(
                              width: 80,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ],
                        ),
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
            'whoops no order yet'.tr,
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 18, color: context.themeTextColor),
          ),
          const SizedBox(height: 10),
          Text('look like you have no orders yet.'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          AppButton(
            keypressEvent: () {
              Get.find<BottombarController>().currentPageIndex.value = 0;
              Get.find<BottombarController>().pageController.jumpToPage(0);
              Get.back();

              Get.back();
            },
            itemText: 'start Shopping'.tr,
          )
        ],
      ),
    );
  }
}

class PastOrdersShimmer extends StatelessWidget {
  const PastOrdersShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    double imageSize = Get.width * 0.26;
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: imageSize,
                      width: imageSize,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 80,
                            height: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 60,
                            height: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 100,
                height: 16,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: Get.width,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 4),
              Container(
                width: 100,
                height: 16,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(thickness: 1, color: Colors.white),
        ],
      ),
    );
  }
}

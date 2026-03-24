import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import '/app/modules/Profie/orders/orders_details/controller/orderdetails_controller.dart';
import '/app/routes/app_pages.dart';
import '/components/order_detail.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import '/constants/theme.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderdetailView extends GetView<OrderdetailController> {
  OrderdetailView({Key? key}) : super(key: key);
  int totalSteps = 3;

  List name = [
    'out for delivery'.tr,
    'in transit'.tr,
    'ready to ship'.tr,
    'ordered'.tr
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
              title: Obx(
                () => Text(
                    controller.item.isEmpty || controller.item["id"] == null
                        ? 'order details'.tr
                        : 'Order Details'.tr + '#${controller.item["id"]}'),
              ),
              elevation: 0.0),
          body: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                left: 0,
                child: ListView(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 30, top: 20),
                        child: ListView.builder(
                            itemCount: 4,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return TimelineTile(
                                // isFirst: index == 0 ? true : false,
                                // isLast: index == totalSteps - 1 ? true : false,
                                indicatorStyle: IndicatorStyle(
                                    color: const Color(0xff309530),
                                    indicator: Container(
                                      height: 50,
                                      width: 50,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                          color: Color(0xff309530),
                                          shape: BoxShape.circle),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    )),
                                beforeLineStyle:
                                    const LineStyle(color: Colors.grey),
                                afterLineStyle:
                                    const LineStyle(color: Color(0xff309530)),
                                endChild: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 28,
                                        width: Get.width * 0.42,
                                        decoration: BoxDecoration(
                                            color: const Color(0xffEDEFF4),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        alignment: Alignment.center,
                                        child: Text(
                                          name[index],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            // color: themeTextColor
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        "expected delivery on monday",
                                        style: TextStyle(
                                          fontSize: 12,
                                          // color: themeTextColor
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.star,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                reviewModal(controller);
                              },
                              child: Text(
                                'rate and review product'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SvgPicture.asset(
                            'assets/images/helpcircle.svg',
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(Routes.HELPANDSUPPORT);
                            },
                            child: Row(
                              children: [
                                Text(
                                  'need help'.tr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                                const Text(
                                  ' ?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    const SizedBox(height: 10),
                    Obx(() => controller.item.isNotEmpty &&
                            controller.item['customer'] != null &&
                            controller.item['customer'] is Map &&
                            controller.item['address'] != null
                        ? ShippingAddress(
                            mobileNo: controller.item['customer']['mobile']
                                    ?.toString() ??
                                '',
                            address: controller.item['address'])
                        : const ShippingAddressShimmer()),
                    const SizedBox(height: 20),
                    Container(
                      height: 10,
                    ),
                    const SizedBox(height: 20),
                    Obx(() => controller.item.isNotEmpty
                        ? PriceDetails(item: controller.item)
                        : const ShippingAddressShimmer()),
                    const SizedBox(height: 10),
                    Obx(
                      () => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: BeveledRectangleBorder(),
                          ),
                          onPressed: () => controller
                              .downloadAndSavePDF(controller.item['_id']),
                          child: controller.downloading.value
                              ? HelperFunctions().loadingIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Download PDF'.tr,
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // Positioned(
              //   bottom: 10,
              //   right: 10,
              //   left: 10,
              //   child: Center(
              //     child: Obx(
              //       () => controller.downloading.value
              //           ? HelperFunctions().loadingIndicator()
              //           : ElevatedButton(
              //               onPressed: () => controller
              //                   .downloadAndSavePDF(controller.item['_id']),
              //               child: Text('Download PDF'.tr),
              //             ),
              //     ),
              //   ),
              // ),

              // DownloadInvoice(item: controller.item['invoice'] ?? '')
            ],
          )),
    );
  }
}

class ShippingAddress extends StatelessWidget {
  const ShippingAddress({
    super.key,
    required this.address,
    required this.mobileNo,
  });

  final dynamic address;
  final String mobileNo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: pageSurroundingPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('shipping details'.tr,
              style: const TextStyle(
                  // color: themeTextColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 14)),
          const Divider(),
          // address != null
          //     ? Text(address.toString(),
          //         style: const TextStyle(
          //             fontWeight: FontWeight.w600, fontSize: 16))
          //     : const SizedBox(),
          // const SizedBox(height: 6),
          Text(
              '${address['house_no']}  ${address['address'].toString().capitalize},',
              style: const TextStyle(
                  // color: themeTextColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 14)),
          const SizedBox(height: 6),
          Text('${address['city']['name']},',
              style: const TextStyle(
                  // color: themeTextColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 14)),
          const SizedBox(height: 6),
          Text('${address['state']['name']}, ${address['pincode']}',
              style: const TextStyle(
                  // color: themeTextColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            '${mobileNo}',
            style: const TextStyle(
                // color: themeTextColor,
                fontWeight: FontWeight.w400,
                fontSize: 14),
          )
        ],
      ),
    );
  }
}

class ShippingAddressShimmer extends StatelessWidget {
  const ShippingAddressShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey,
        highlightColor: Colors.white,
        child: Padding(
          padding: pageSurroundingPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 12,
                  width: 100,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5))),
              const Divider(color: Colors.white, thickness: 2),
              Container(
                  height: 12,
                  width: 120,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5))),
              const SizedBox(height: 6),
              Container(
                  height: 10,
                  width: 160,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5))),
              const SizedBox(height: 6),
              Container(
                  height: 10,
                  width: 50,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5))),
              const SizedBox(height: 6),
              Container(
                  height: 10,
                  width: 100,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5))),
              const SizedBox(height: 6),
              Container(
                  height: 10,
                  width: 140,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6)))
            ],
          ),
        ));
  }
}

class PriceDetails extends StatelessWidget {
  const PriceDetails({super.key, required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: pageSurroundingPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('price details'.tr,
              style: const TextStyle(
                  // color: themeTextColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 14)),
          const Divider(),
          const SizedBox(height: 5),
          ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 10,
              );
            },
            itemCount: item['products'].length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                color: Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: Get.width * 0.26,
                        margin: const EdgeInsets.only(right: 15),
                        width: Get.width * 0.26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(width: 2),
                            borderRadius: BorderRadius.circular(8)),
                        child: CachedNetworkImage(
                            errorWidget: (context, url, error) => Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade300),
                                  child: const Center(
                                    child: Icon(Icons.error),
                                  ),
                                ),
                            height: 100,
                            width: 100,
                            imageUrl: item['products'][index]['image'] == null
                                ? HelperFunctions.getNoImage()
                                : url + item['products'][index]['image'],
                            fit: BoxFit.cover)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: Get.width * 0.6,
                            child: Text(item['products'][index]['name'],
                                style: const TextStyle(fontSize: 12))),
                        const SizedBox(height: 6),
                        Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                // color: themegreyColor,
                                borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              children: [
                                Text(
                                  'Quantity:'.tr,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text('${item['products'][index]['qty']}',
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            )),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("price".tr,
                                style: const TextStyle(fontSize: 12)),
                            const Text(" : ", style: TextStyle(fontSize: 12)),
                            Text("₹${item['products'][index]['unit_price']}",
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text('by'.tr, style: const TextStyle(fontSize: 12)),
                        //     const Text(' : ', style: TextStyle(fontSize: 12)),
                        //     Text('${item['orderdetail'][0]['vendor']['name']}',
                        //         style: const TextStyle(fontSize: 12)),
                        //   ],
                        // )
                      ],
                    )
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 5),
          const Divider(),
          // OrderDetail(
          //     title: 'sub total'.tr,
          //     amount: Text('\u{20B9}${item['subtotal'].toStringAsFixed(2)}',
          //         style: txtTheme().displaySmall)),
          // item['discount'] != 0 && item['discount'] != null
          //     ? OrderDetail(
          //         title: 'coupon Discount'.tr,
          //         amount: Text(
          //             '- \u{20B9}${item['discount'].toStringAsFixed(2)}',
          //             style: const TextStyle(
          //                 color: Colors.green,
          //                 fontWeight: FontWeight.w400,
          //                 fontSize: 14)))
          //     : Container(),
          // OrderDetail(
          //     title: "Tax".tr + "",
          //     amount: Text('\u{20B9} ${19.toStringAsFixed(2)}',
          //         style: txtTheme().displaySmall)),
          // OrderDetail(
          //     title: 'Delivery'.tr,
          //     amount: Text('\u{20B9}${item['shipping'].toStringAsFixed(2)}',
          //         style: txtTheme().displaySmall)),
          const Divider(thickness: 1.5),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('discount'.tr, style: txtTheme().displayMedium),
            Text('\u{20B9}${item['discount'].toStringAsFixed(2)}',
                style: txtTheme().displayMedium)
          ]),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}

// class DownloadInvoice extends StatelessWidget {
//   const DownloadInvoice({super.key, required this.item});
//   final dynamic item;

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//         bottom: 10,
//         right: 10,
//         left: 10,
//         child: DownloadButton(
//           onTap: () async {
//           item != null
//               ? await HelperFunctions().downloadAndSavePDF(item, 'invoice.pdf')
//               : ShoppingHelper.defaultdialog(
//                   'something_went_wrong'.tr, Colors.red);
//         }));
//   }
// }

reviewModal(OrderdetailController controller) {
  TextEditingController reviewController = TextEditingController();
  int rating = 3;
  return Get.dialog(AlertDialog(
      content: SizedBox(
        // width: MediaQuery.of(context).size.width * 80,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Write Review',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              RatingBar.builder(
                initialRating: 3,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: EdgeInsets.zero,
                itemBuilder: (context, _) => Transform.scale(
                  scale: 0.6,
                  child: const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                ),
                onRatingUpdate: (value) {
                  rating = value.toInt();
                },
              ),
              const SizedBox(height: 10),
              const Text("Review:",
                  style: TextStyle(
                      // color: themeSecondrytext,
                      // fontFamily: 'Lato',
                      fontSize: 14)),
              const SizedBox(height: 10),
              TextFormField(
                controller: reviewController,
                maxLength: 300,
                scrollPhysics: AlwaysScrollableScrollPhysics(),
                onChanged: (value) {
                  // .text = value;
                },
                // cursorColor: themePrimaryColor,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFDDDDDD), width: 1)),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFDDDDDD), width: 1)),
                ),
                minLines: 1,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: SizedBox(
                    height: 45,
                    child: Center(
                      child: Text('Back'.toUpperCase(),
                          style: txtTheme().titleLarge),
                    )),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    if (reviewController.text.isNotEmpty) {
                      // print('23234554');
                      controller.postReview(
                          summary: reviewController.text, rating: rating);
                    } else {
                      // Get.showSnackbar(const GetSnackBar(
                      //   message: 'Enter review',
                      // ));
                      HelperFunctions().showSnackBarError('Enter review');
                    }
                  },
                  style: themeButton,
                  child: Text('Submit'.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        // fontFamily: 'Lato'
                      )),
                ),
              ),
            ),
          ],
        ),
      ]));
}
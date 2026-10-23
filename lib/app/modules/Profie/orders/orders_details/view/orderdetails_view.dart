import 'package:cached_network_image/cached_network_image.dart';
import '/components/app_image_placeholder.dart';
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Obx(() {
            final orderData = controller.item.containsKey('data') &&
                    controller.item['data'] is Map
                ? controller.item['data']
                : controller.item;
            final orderNo = orderData['order_no'] ??
                orderData['_id'] ??
                controller.id.value;
            return Text(
              orderNo != null && orderNo.toString().isNotEmpty && orderNo != '0'
                  ? 'Order #$orderNo'
                  : 'Order Details',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'lato',
              ),
            );
          }),
          elevation: 0.0,
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.item.isEmpty) {
            return Center(child: HelperFunctions().loadingIndicator());
          }

          final orderData = controller.item.containsKey('data') &&
                  controller.item['data'] is Map
              ? controller.item['data']
              : controller.item;

          if (orderData == null || (orderData is Map && orderData.isEmpty)) {
            return const Center(child: Text('Order not found'));
          }

          final currentStage = controller.getCurrentStage();
          final paymentStatus =
              (orderData['payment_status'] ?? '').toString().toLowerCase();
          final isPaid = paymentStatus == 'paid';

          return ListView(
            children: [
              const SizedBox(height: 12),

              // ── Dynamic Order Tracking Timeline ─────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Status',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'lato',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      itemCount: controller.stages.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final isCompleted = (index + 1) <= currentStage;
                        final isLast = index == controller.stages.length - 1;

                        return TimelineTile(
                          isFirst: index == 0,
                          isLast: isLast,
                          indicatorStyle: IndicatorStyle(
                            width: 28,
                            height: 28,
                            indicator: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? colorScheme.primary
                                    : colorScheme.surfaceContainerHighest,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCompleted
                                      ? colorScheme.primary
                                      : colorScheme.outline
                                          .withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                isCompleted ? Icons.check : Icons.circle,
                                color: isCompleted
                                    ? colorScheme.onPrimary
                                    : colorScheme.outline,
                                size: isCompleted ? 16 : 8,
                              ),
                            ),
                          ),
                          beforeLineStyle: LineStyle(
                            color: isCompleted
                                ? colorScheme.primary
                                : colorScheme.outline.withValues(alpha: 0.3),
                            thickness: 2,
                          ),
                          afterLineStyle: LineStyle(
                            color: (index + 1) < currentStage
                                ? colorScheme.primary
                                : colorScheme.outline.withValues(alpha: 0.3),
                            thickness: 2,
                          ),
                          endChild: Padding(
                            padding: const EdgeInsets.only(
                                left: 16, top: 12, bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.stages[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isCompleted
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontFamily: 'lato',
                                    color: isCompleted
                                        ? colorScheme.onSurface
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (index + 1 == currentStage) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'In Progress',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.primary,
                                      fontFamily: 'lato',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              Divider(
                thickness: 8,
                color: colorScheme.surfaceContainerHighest,
              ),

              // ── Payment Transactions Card ───────────────────────
              PaymentTransactionsCard(item: orderData),

              Divider(
                thickness: 8,
                color: colorScheme.surfaceContainerHighest,
              ),

              // ── Price Details ───────────────────────────────────
              PriceDetails(item: orderData),

              Divider(
                thickness: 8,
                color: colorScheme.surfaceContainerHighest,
              ),

              // ── Shipping Address ────────────────────────────────
              if (orderData['address'] != null)
                ShippingAddress(
                  mobileNo: orderData['customer'] is Map
                      ? (orderData['customer']['mobile']?.toString() ?? '')
                      : '',
                  address: orderData['address'],
                ),

              const SizedBox(height: 16),

              // ── Download Invoice Button (Paid only) ─────────────
              if (isPaid)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => controller
                        .downloadAndSavePDF(orderData['_id'] ?? controller.id.value),
                    child: controller.downloading.value
                        ? HelperFunctions().loadingIndicator(
                            color: colorScheme.onPrimary,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.download_rounded,
                                  size: 20, color: colorScheme.onPrimary),
                              const SizedBox(width: 8),
                              Text(
                                'Download Invoice'.tr,
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'lato',
                                ),
                              ),
                            ],
                          ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 18, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Invoice will be available for download once order payment is completed.',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                              fontFamily: 'lato',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // ── Need Help Section ────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.HELPANDSUPPORT);
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/helpcircle.svg',
                        height: 20,
                        width: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'need help'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          fontFamily: 'lato',
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          );
        }),
      ),
    );
  }
}

class PaymentTransactionsCard extends StatelessWidget {
  const PaymentTransactionsCard({super.key, required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    final symbol = (item['currency'] ?? '₹').toString();
    final double totalVal = parseDouble(item['total']);
    final payments = item['payments'] as List?;
    final paymentStatus =
        (item['payment_status'] ?? '').toString().toUpperCase();
    final paymentMethod =
        (item['payment_method'] ?? 'COD').toString().toUpperCase();
    final isCod = paymentMethod.toLowerCase() == 'cod';

    double amountPaid = 0.0;
    if (payments != null && payments.isNotEmpty) {
      for (var pay in payments) {
        if (pay is Map) {
          final pStatus = (pay['status'] ?? '').toString().toLowerCase();
          if (pStatus == 'paid' ||
              pStatus == 'success' ||
              pStatus == 'completed') {
            amountPaid += parseDouble(pay['amount']);
          }
        }
      }
    } else if (paymentStatus == 'PAID' && !isCod) {
      amountPaid = totalVal;
    }

    double pendingAmount = totalVal - amountPaid;
    if (pendingAmount < 0) pendingAmount = 0.0;

    final String amountPaidStr = amountPaid.toStringAsFixed(2);
    final String pendingAmountStr = pendingAmount.toStringAsFixed(2);

    return Padding(
      padding: pageSurroundingPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3.5,
                height: 16,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.payment_outlined,
                  size: 17, color: colorScheme.primary),
              const SizedBox(width: 6),
              const Text(
                'Payment Summary',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'lato',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Highlight Metric Boxes
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            color: Color(0xFF16A34A), size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AMOUNT PAID',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF166534),
                                fontFamily: 'lato',
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$symbol$amountPaidStr',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                                fontFamily: 'lato',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: pendingAmount > 0
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: pendingAmount > 0
                          ? const Color(0xFFFCA5A5)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: pendingAmount > 0
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.access_time_rounded,
                          color: pendingAmount > 0
                              ? const Color(0xFFDC2626)
                              : Colors.grey,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DUE ON DELIVERY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: pendingAmount > 0
                                    ? const Color(0xFF991B1B)
                                    : Colors.grey.shade700,
                                fontFamily: 'lato',
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$symbol$pendingAmountStr',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: pendingAmount > 0
                                    ? const Color(0xFFDC2626)
                                    : Colors.grey.shade800,
                                fontFamily: 'lato',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

          // COD Advisory Message
          if (isCod && pendingAmount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.amber.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Payment of $symbol$pendingAmountStr will be collected on delivery.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade900,
                        fontFamily: 'lato',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
                color: Theme.of(context).colorScheme.surface,
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: (item['products'][index]['image'] != null &&
                                  item['products'][index]['image']
                                      .toString()
                                      .isNotEmpty &&
                                  (url + item['products'][index]['image']) !=
                                      HelperFunctions.getNoImage())
                              ? CachedNetworkImage(
                                  errorWidget: (context, url, error) =>
                                      const AppImagePlaceholder(
                                    radius: 6,
                                    height: 100,
                                    width: 100,
                                  ),
                                  height: 100,
                                  width: 100,
                                  imageUrl:
                                      url + item['products'][index]['image'],
                                  fit: BoxFit.cover,
                                )
                              : const AppImagePlaceholder(
                                  radius: 6,
                                  height: 100,
                                  width: 100,
                                ),
                        )),
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
                  child: Builder(builder: (ctx) => Text('Submit'.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(ctx).colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        // fontFamily: 'Lato'
                      ))),
                ),
              ),
            ),
          ],
        ),
      ]));
}

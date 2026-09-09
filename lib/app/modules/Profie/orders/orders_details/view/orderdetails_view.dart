import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/app/modules/Profie/orders/orders_details/controller/orderdetails_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class OrderdetailView extends GetView<OrderdetailController> {
  OrderdetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order Details'.tr,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    controller.item.isEmpty || controller.item['id'] == null
                        ? ''
                        : '#${controller.item["id"]}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          elevation: 0.0,
        ),
        body: Obx(
          () => controller.isLoading.value && controller.item.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    // Order Tracking Card
                    OrderTrackingCard(),
                    const SizedBox(height: 10),
                    Divider(
                      thickness: 8,
                      color: Theme.of(context).dividerTheme.color ??
                          Colors.grey.shade100,
                    ),

                    // Rate & review / help row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.star,
                            size: 18,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                reviewModal(context, controller);
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
                            height: 18,
                            width: 18,
                          ),
                          const SizedBox(width: 6),
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
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Theme.of(context).dividerTheme.color,
                      height: 1,
                    ),

                    // Shipping Details
                    Obx(() => controller.item.isNotEmpty &&
                            controller.item['address'] != null
                        ? ShippingAddress(
                            mobileNo: (controller.item['address'] is Map &&
                                    controller.item['address']['mobile'] !=
                                        null)
                                ? controller.item['address']['mobile']
                                    .toString()
                                : (controller.item['customer'] is Map &&
                                        controller.item['customer']
                                                ['mobile'] !=
                                            null)
                                    ? controller.item['customer']['mobile']
                                        .toString()
                                    : '',
                            address: controller.item['address'],
                          )
                        : const ShippingAddressShimmer()),
                    Divider(
                      color: Theme.of(context).dividerTheme.color,
                      height: 1,
                    ),

                    // Price Details
                    Obx(() => controller.item.isNotEmpty
                        ? PriceDetails(item: controller.item)
                        : const ShippingAddressShimmer()),

                    const SizedBox(height: 20),

                    // Download Invoice Button
                    Obx(() {
                      final status = controller.item['payment_status']
                              ?.toString()
                              .toLowerCase() ??
                          '';
                      if (status != 'paid') return const SizedBox.shrink();
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: themeButton,
                            onPressed: () => controller
                                .downloadAndSavePDF(controller.item['_id']),
                            child: controller.downloading.value
                                ? HelperFunctions()
                                    .loadingIndicator(color: Colors.white)
                                : Text(
                                    'Download Invoice'.tr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 30),
                  ],
                ),
        ),
      ),
    );
  }
}

class OrderTrackingCard extends StatelessWidget {
  final OrderdetailController controller = Get.find<OrderdetailController>();

  OrderTrackingCard({Key? key}) : super(key: key);

  String _formatDate(dynamic dateTimeString) {
    if (dateTimeString == null) return '-';
    try {
      final dateTime = DateTime.parse(dateTimeString.toString());
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      if (dateTimeString.toString().contains('T')) {
        return dateTimeString.toString().split('T')[0];
      }
      return dateTimeString.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final item = controller.item;
      if (item.isEmpty) return const OrderTrackingShimmer();

      final total =
          double.tryParse(item['total']?.toString() ?? '0') ?? 0.0;
      final totalStr = '\u{20B9}${total.toStringAsFixed(total % 1 == 0 ? 0 : 2)}';

      final paymentStatus =
          item['payment_status']?.toString().toLowerCase() ?? '';
      final isPaid = paymentStatus == 'paid';
      final isFailed = paymentStatus == 'failed';
      final payments = item['payments'] as List?;
      final paidAt =
          payments != null && payments.isNotEmpty ? payments[0]['paid_at'] : null;
      final paymentMethod =
          item['payment_method']?.toString().toUpperCase() ?? '';
      final orderDate = paidAt ?? item['createdAt'];

      final statusColor = isPaid
          ? Colors.green
          : (isFailed ? Colors.red : Colors.orange);

      return Padding(
        padding: pageSurroundingPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isPaid
                        ? Icons.check_circle
                        : (isFailed ? Icons.error_outline : Icons.access_time),
                    color: statusColor.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPaid
                              ? 'Payment Confirmed'.tr
                              : (isFailed
                                  ? 'Payment Failed'.tr
                                  : 'Payment Pending'.tr),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: statusColor.shade700,
                          ),
                        ),
                        if (isPaid && paidAt != null)
                          Text(
                            _formatDate(paidAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    totalStr,
                    style: txtTheme()
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Order Timeline'.tr,
              style:
                  txtTheme().titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _TimelineItem(
              title: 'Order Placed'.tr,
              date: _formatDate(orderDate),
              description: 'Your order has been placed successfully'.tr,
              isCompleted: true,
              icon: Icons.shopping_bag_outlined,
            ),
            _TimelineItem(
              title: 'Payment'.tr,
              date: isPaid
                  ? _formatDate(paidAt)
                  : (isFailed ? 'Failed'.tr : 'Pending'.tr),
              description: isPaid
                  ? 'Payment received via $paymentMethod'
                  : (isFailed
                      ? 'Payment failed via $paymentMethod'
                      : 'Awaiting payment confirmation'.tr),
              isCompleted: isPaid,
              isFailed: isFailed,
              icon: Icons.payment_outlined,
            ),
            _TimelineItem(
              title: 'Order Confirmed'.tr,
              date: isPaid ? _formatDate(paidAt) : '-',
              description: isPaid
                  ? 'Your order has been confirmed and will be processed soon'
                      .tr
                  : (isFailed
                      ? 'Order confirmation failed due to failed payment'.tr
                      : 'Will be confirmed after payment'.tr),
              isCompleted: isPaid,
              isFailed: isFailed,
              icon: isFailed ? Icons.cancel_outlined : Icons.check_circle_outline,
              isLast: true,
            ),
          ],
        ),
      );
    });
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.date,
    required this.description,
    required this.isCompleted,
    this.isFailed = false,
    required this.icon,
    this.isLast = false,
  });

  final String title;
  final String date;
  final String description;
  final bool isCompleted;
  final bool isFailed;
  final IconData icon;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    final containerColor = isCompleted
        ? Colors.green.shade50
        : (isFailed ? Colors.red.shade50 : Colors.grey.shade100);
    final iconColor = isCompleted ? Colors.green : Colors.grey;
    final titleColor = isCompleted
        ? Theme.of(context).textTheme.bodyLarge?.color
        : outline;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(shape: BoxShape.circle, color: containerColor),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: titleColor),
                    ),
                    Text(date, style: TextStyle(fontSize: 11, color: outline)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 12, color: outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderTrackingShimmer extends StatelessWidget {
  const OrderTrackingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: pageSurroundingPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 60, color: Colors.white),
            const SizedBox(height: 20),
            Container(height: 16, width: 120, color: Colors.white),
            const SizedBox(height: 16),
            Container(height: 40, color: Colors.white),
          ],
        ),
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
    final bool isAddressMap = address is Map;
    final outline = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: pageSurroundingPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: outline),
              const SizedBox(width: 8),
              Text('shipping details'.tr,
                  style: txtTheme()
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(),
          if (isAddressMap) ...[
            if (address['name'] != null) ...[
              Text(
                address['name'].toString(),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              '${address['house_no'] != null && address['house_no'].toString().isNotEmpty ? '${address['house_no']}, ' : ''}${address['address']?.toString().capitalize ?? ''}',
              style: TextStyle(color: outline, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              '${address['city'] is Map ? address['city']['name'] ?? '' : address['city'] ?? ''}, ${address['state'] is Map ? address['state']['name'] ?? '' : address['state'] ?? ''}',
              style: TextStyle(color: outline, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              '${address['pincode'] ?? address['postal_code'] ?? ''}',
              style: TextStyle(color: outline, fontSize: 13),
            ),
            if (mobileNo.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 14, color: outline),
                  const SizedBox(width: 4),
                  Text(mobileNo, style: TextStyle(color: outline, fontSize: 13)),
                ],
              ),
            ],
          ] else
            Text(
              address?.toString() ?? 'No address details available',
              style: TextStyle(color: outline, fontSize: 13),
            ),
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
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade100,
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

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  double _getUnitPrice(Map p) {
    double up = _parseDouble(p['unit_price']);
    if (up > 0) return up;
    up = _parseDouble(p['price']);
    if (up > 0) return up;
    final prodId = p['product_id'];
    if (prodId is Map) {
      up = _parseDouble(prodId['price']);
    }
    return up;
  }

  double _getOriginalPrice(Map p, double resolvedUnitPrice) {
    double op = _parseDouble(p['price']);
    if (op > 0) return op;
    final variant = p['variant'];
    if (variant is Map) {
      op = _parseDouble(variant['price']);
    }
    if (op > 0) return op;
    final prodId = p['product_id'];
    if (prodId is Map) {
      op = _parseDouble(prodId['price']);
    }
    if (op > 0) return op;
    if (resolvedUnitPrice > 0) return resolvedUnitPrice;
    return 0.0;
  }

  Widget _buildPriceRow(BuildContext context, String label, double amount,
      {bool isTotal = false, bool isNegative = false}) {
    final outline = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? txtTheme().titleLarge!.copyWith(fontWeight: FontWeight.w600)
                : TextStyle(fontSize: 13, color: outline),
          ),
          Text(
            '${isNegative ? '-' : ''}\u{20B9}${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isNegative ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = item['products'] is List ? item['products'] as List : [];

    double originalBagTotal = 0.0;
    double actualBagTotal = 0.0;
    for (var currentProduct in products) {
      if (currentProduct is Map) {
        final qty =
            (currentProduct['qty'] ?? currentProduct['quantity'] ?? 1)
                .toDouble();
        final unitPrice = _getUnitPrice(currentProduct);
        final originalPrice = _getOriginalPrice(currentProduct, unitPrice);
        originalBagTotal += originalPrice * qty;
        actualBagTotal += unitPrice * qty;
      }
    }

    double itemSavings = originalBagTotal - actualBagTotal;
    if (itemSavings < 0) itemSavings = 0.0;

    final discount = _parseDouble(item['discount']);
    final shippingCharges =
        _parseDouble(item['shipping_charges'] ?? item['shipping']);
    final taxAmount = _parseDouble(item['tax_amount']);
    final total = actualBagTotal + taxAmount - discount + shippingCharges;

    return Padding(
      padding: pageSurroundingPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_outlined,
                  size: 18, color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 8),
              Text('price details'.tr,
                  style: txtTheme()
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(),
          const SizedBox(height: 5),
          ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemCount: products.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final currentProduct = products[index];
              final unitPrice = _getUnitPrice(currentProduct);
              final originalPrice =
                  _getOriginalPrice(currentProduct, unitPrice);
              final hasDiscount = originalPrice > unitPrice && unitPrice > 0;
              final quantity =
                  (currentProduct['qty'] ?? currentProduct['quantity'] ?? 1);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: Get.width * 0.26,
                    width: Get.width * 0.26,
                    margin: const EdgeInsets.only(right: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).colorScheme.outline),
                        borderRadius: BorderRadius.circular(8)),
                    child: CachedNetworkImage(
                        errorWidget: (context, url, error) => Container(
                              decoration:
                                  BoxDecoration(color: Colors.grey.shade300),
                              child: const Center(child: Icon(Icons.error)),
                            ),
                        height: 100,
                        width: 100,
                        imageUrl: HelperFunctions()
                            .getImage(currentProduct['image']),
                        fit: BoxFit.contain),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentProduct['name']?.toString() ?? '',
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text('Quantity:'.tr,
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text('$quantity',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasDiscount) ...[
                              Text(
                                '\u{20B9}${originalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.outline,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              '\u{20B9}${unitPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 5),
          const Divider(),
          const SizedBox(height: 5),
          _buildPriceRow(context, 'Bag Total'.tr, originalBagTotal),
          if (itemSavings > 0)
            _buildPriceRow(context, 'Product Savings'.tr, -itemSavings,
                isNegative: true),
          if (discount > 0)
            _buildPriceRow(context, 'discount'.tr, -discount,
                isNegative: true),
          if (shippingCharges > 0)
            _buildPriceRow(context, 'Delivery'.tr, shippingCharges),
          if (taxAmount > 0) _buildPriceRow(context, 'Tax'.tr, taxAmount),
          const Divider(thickness: 1.5),
          const SizedBox(height: 5),
          _buildPriceRow(context, 'Total Amount'.tr, total, isTotal: true),
          const SizedBox(height: 10),
          if (item['payment_method'] != null) ...[
            Builder(builder: (context) {
              final status =
                  item['payment_status']?.toString().toLowerCase() ?? '';
              final isPaid = status == 'paid';
              final isFailed = status == 'failed';
              final boxColor = isPaid
                  ? Colors.green.shade50
                  : (isFailed ? Colors.red.shade50 : Colors.orange.shade50);
              final textColor = isPaid
                  ? Colors.green.shade700
                  : (isFailed ? Colors.red.shade700 : Colors.orange.shade700);
              final icon = isPaid
                  ? Icons.check_circle_outline
                  : (isFailed ? Icons.error_outline : Icons.access_time);
              final method =
                  item['payment_method']?.toString().toUpperCase() ?? '';
              final methodText = isPaid
                  ? 'Paid via $method'
                  : (isFailed
                      ? 'Payment Failed via $method'
                      : 'Payment Pending via $method');

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: textColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(methodText,
                          style: TextStyle(fontSize: 12, color: textColor)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

void reviewModal(BuildContext context, OrderdetailController controller) {
  TextEditingController reviewController = TextEditingController();
  int rating = 3;
  Get.dialog(AlertDialog(
      content: SizedBox(
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
              const Text("Review:", style: TextStyle(fontSize: 14)),
              const SizedBox(height: 10),
              TextFormField(
                controller: reviewController,
                maxLength: 300,
                scrollPhysics: const AlwaysScrollableScrollPhysics(),
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
                      controller.postReview(
                          summary: reviewController.text, rating: rating);
                    } else {
                      HelperFunctions().showSnackBarError('Enter review');
                    }
                  },
                  style: themeButton,
                  child: Text('Submit'.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
            ),
          ],
        ),
      ]));
}

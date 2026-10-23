import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zouhi/app/modules/Profie/orders/orders_details/controller/orderdetails_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/order_currency.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/components/product_image_placeholder.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class OrderdetailView extends GetView<OrderdetailController> {
  const OrderdetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: context.colors.surface,
          foregroundColor: context.themeTextColor,
          title: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    controller.item["order_no"] == null
                        ? ''
                        : '#${controller.item["order_no"]}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.themeSecondrytext,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Obx(() => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  // Order Tracking Card
                  OrderTrackingCard(),
                  const SizedBox(height: 12),

                  // Price Details (Order Items & Order Summary)
                  Container(
                    color: context.colors.surface,
                    child: Obx(
                      () => controller.item.isNotEmpty
                          ? PriceDetails(item: controller.item)
                          : const ShippingAddressShimmer(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Shipping Address & Payment Info Cards
                  Container(
                    color: context.colors.surface,
                    child: Obx(
                      () => controller.item.isNotEmpty
                          ? ShippingAndPaymentInfo(item: controller.item)
                          : const ShippingAddressShimmer(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Payment Transactions Card
                  Container(
                    color: context.colors.surface,
                    child: Obx(
                      () => controller.item.isNotEmpty
                          ? PaymentTransactionsCard(item: controller.item)
                          : const SizedBox(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Download PDF Button
                  Obx(() {
                    if (controller.item['payment_status']
                            ?.toString()
                            .toLowerCase() !=
                        'paid') {
                      return const SizedBox.shrink();
                    }
                    final isDownloading = controller.downloading.value;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: context.themeRedColor,
                          elevation: 0,
                        ),
                        onPressed: isDownloading
                            ? null
                            : () => controller.downloadPdf(controller.item['_id']),
                        child: isDownloading
                            ? SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: context.colors.onPrimary,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.download_rounded,
                                    size: 20,
                                    color: context.colors.onPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Download Invoice',
                                    style: TextStyle(
                                      color: context.colors.onPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  }),

                  // Help Section
                  Container(
                    color: context.colors.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.HELPANDSUPPORT);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/images/helpcircle.svg',
                            height: 20,
                            width: 20,
                            colorFilter: ColorFilter.mode(
                              context.themeSecondrytext,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Need help?',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: context.themeSecondrytext,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: context.themeSecondrytext,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              )),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 18, color: context.themeSecondrytext),
              const SizedBox(width: 8),
              Text(
                'Shipping Address',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: context.themeTextColor,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          if (isAddressMap) ...[
            Text(
              address['name'] ?? 'Customer',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: context.themeTextColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${address['house_no'] != null && address['house_no'].toString().isNotEmpty ? '${address['house_no']}, ' : ''}${address['address'] ?? ''}',
              style: TextStyle(
                color: context.themeSecondrytext,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${address['city'] is Map ? address['city']['name'] ?? '' : address['city'] ?? ''}, ${address['state'] is Map ? address['state']['name'] ?? '' : address['state'] ?? ''}',
              style: TextStyle(
                color: context.themeSecondrytext,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${address['pincode'] ?? address['postal_code'] ?? ''}',
              style: TextStyle(
                color: context.themeSecondrytext,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 14, color: context.themeSecondrytext),
                const SizedBox(width: 4),
                Text(
                  mobileNo,
                  style: TextStyle(
                    color: context.themeSecondrytext,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ] else
            Text(
              address?.toString() ?? 'No address details available',
              style: TextStyle(color: context.themeSecondrytext, fontSize: 13),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 18, width: 120, color: Colors.white),
            const SizedBox(height: 16),
            Container(height: 14, width: 100, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 12, width: 200, color: Colors.white),
            const SizedBox(height: 6),
            Container(height: 12, width: 150, color: Colors.white),
            const SizedBox(height: 6),
            Container(height: 12, width: 80, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class ShippingAndPaymentInfo extends StatelessWidget {
  const ShippingAndPaymentInfo({super.key, required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final address = item['address'];
    final isAddressMap = address is Map;
    final mobileNo = (isAddressMap && address['mobile'] != null)
        ? address['mobile'].toString()
        : (item['customer'] is Map && item['customer']['mobile'] != null)
            ? item['customer']['mobile'].toString()
            : '';

    final paymentMethod =
        (item['payment_method'] ?? 'COD').toString().toUpperCase();
    final paymentStatus =
        (item['payment_status'] ?? '').toString().toUpperCase();
    final isPaid = paymentStatus == 'PAID';
    final isFailed = paymentStatus == 'FAILED';

    final orderNotes = (item['notes'] ??
            item['order_notes'] ??
            item['comment'] ??
            item['order_note'] ??
            '')
        .toString()
        .trim();

    final shippingCard = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.themeBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 17, color: Color(0xFF20558A)),
              SizedBox(width: 6),
              Text(
                'Shipping Address',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          if (isAddressMap) ...[
            Text(
              address['name'] ?? 'Customer',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: context.themeTextColor,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mobileNo,
              style: TextStyle(
                color: context.themeSecondrytext,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${address['house_no'] != null && address['house_no'].toString().isNotEmpty ? '${address['house_no']}, ' : ''}${address['address'] ?? ''}',
              style: TextStyle(
                color: context.themeSecondrytext,
                fontSize: 12,
                height: 1.3,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${address['city'] is Map ? address['city']['name'] ?? '' : address['city'] ?? ''}${address['state'] != null ? ', ${address['state'] is Map ? address['state']['name'] ?? '' : address['state']}' : ''}, ${address['pincode'] ?? address['postal_code'] ?? ''}',
              style: TextStyle(
                color: context.themeSecondrytext,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ] else ...[
            Text(
              address?.toString() ?? 'No address details available',
              style: TextStyle(
                color: context.themeSecondrytext,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );

    final paymentCard = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.themeBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment_outlined,
                  size: 17, color: Color(0xFF20558A)),
              SizedBox(width: 6),
              Text(
                'Payment Info',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            children: [
              Text(
                'Method: ',
                style: TextStyle(
                  fontSize: 12,
                  color: context.themeSecondrytext,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                paymentMethod,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.themeTextColor,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Status: ',
                style: TextStyle(
                  fontSize: 12,
                  color: context.themeSecondrytext,
                  fontFamily: 'Poppins',
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPaid
                      ? const Color(0xFFDCFCE7)
                      : (isFailed
                          ? const Color(0xFFFEF2F2)
                          : const Color(0xFFFEF3C7)),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isPaid
                        ? const Color(0xFF86EFAC)
                        : (isFailed
                            ? const Color(0xFFFECACA)
                            : const Color(0xFFFDE68A)),
                  ),
                ),
                child: Text(
                  isPaid ? 'Paid' : (isFailed ? 'Failed' : 'Pending'),
                  style: TextStyle(
                    color: isPaid
                        ? const Color(0xFF166534)
                        : (isFailed
                            ? const Color(0xFF991B1B)
                            : const Color(0xFF92400E)),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          if (orderNotes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Order Notes:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.themeTextColor,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              orderNotes,
              style: TextStyle(
                fontSize: 11,
                color: context.themeSecondrytext,
                fontFamily: 'Poppins',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 550) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: shippingCard),
                const SizedBox(width: 12),
                Expanded(child: paymentCard),
              ],
            );
          } else {
            return Column(
              children: [
                shippingCard,
                const SizedBox(height: 12),
                paymentCard,
              ],
            );
          }
        },
      ),
    );
  }
}

class PriceDetails extends StatelessWidget {
  const PriceDetails({super.key, required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    final double exchangeRate = orderExchangeRate(item['currency']);
    final symbol = orderCurrencySymbol(item['currency']);

    double getUnitPrice(Map p) {
      double up = parseDouble(p['unit_price']);
      if (up > 0) return up;
      up = parseDouble(p['price']) * exchangeRate;
      if (up > 0) return up;
      final prodId = p['product_id'];
      if (prodId is Map) {
        up = parseDouble(prodId['price']) * exchangeRate;
      }
      return up;
    }

    double getOriginalPrice(Map p, double resolvedUnitPrice) {
      double op = parseDouble(p['price']) * exchangeRate;
      if (op > 0) return op;

      final variant = p['variant'];
      if (variant is Map) {
        op = parseDouble(variant['price']) * exchangeRate;
      }
      if (op > 0) return op;

      final prodId = p['product_id'];
      if (prodId is Map) {
        op = parseDouble(prodId['price']) * exchangeRate;
      }
      if (op > 0) return op;

      if (resolvedUnitPrice > 0) return resolvedUnitPrice;

      return 0.0;
    }

    // Calculate Bag Total dynamically from products list
    double originalBagTotal = 0.0;
    double actualBagTotal = 0.0;
    if (item['products'] is List) {
      for (var currentProduct in item['products']) {
        if (currentProduct is Map) {
          final qty =
              parseDouble(currentProduct['qty'] ?? currentProduct['quantity'] ?? 1);
          final unitPrice = getUnitPrice(currentProduct);
          final originalPrice = getOriginalPrice(currentProduct, unitPrice);
          originalBagTotal += originalPrice * qty;
          actualBagTotal += unitPrice * qty;
        }
      }
    }

    double itemSavings = originalBagTotal - actualBagTotal;
    if (itemSavings < 0) itemSavings = 0.0;

    // Use backend subtotal directly to mirror website truth
    final double apiSubtotal = parseDouble(item['subtotal']);
    final double subtotal = apiSubtotal > 0
        ? apiSubtotal
        : (originalBagTotal > 0 ? originalBagTotal : actualBagTotal);

    final rawCoupon = item['coupon'];
    double couponDiscount = 0.0;
    String couponPrefix = '';
    if (rawCoupon is Map && rawCoupon.isNotEmpty) {
      couponDiscount = parseDouble(rawCoupon['discount'] ?? rawCoupon['discount_amount']);
      final isPercentCoupon = (rawCoupon['discount_type']?.toString().toLowerCase() ?? '')
          .contains('percent');
      final couponPercent = rawCoupon['discount_value'] ?? rawCoupon['type_value'];
      if (isPercentCoupon && couponPercent != null) {
        couponPrefix = '($couponPercent%)';
      }
    }

    final discount = parseDouble(item['discount']);
    final shippingCharges = parseDouble(item['shipping_charges']);
    final taxAmount = parseDouble(item['tax_amount'] ?? item['tax']);

    // Total from API
    final double apiTotal = parseDouble(item['total']);
    final total = apiTotal > 0
        ? apiTotal
        : (actualBagTotal + taxAmount - discount + shippingCharges);
    final isCod = item['payment_method']?.toString().toLowerCase() == 'cod';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_outlined,
                  size: 18, color: context.themeSecondrytext),
              const SizedBox(width: 8),
              const Text(
                'Price Details',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Products List
          ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemCount: item['products']?.length ?? 0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              var currentProduct = item['products'][index];
              var productObj =
                  currentProduct['product_id'] ?? currentProduct['product'];
              var productType =
                  (productObj is Map ? productObj['type'] : null) ?? 'simple';
              var variantObj = currentProduct['variant'];
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
                if (currentProduct is Map) ...[
                  currentProduct['image'],
                  currentProduct['featured_image'],
                  currentProduct['front_image'],
                ],
                if (currentProduct is Map &&
                    currentProduct['product_id'] is Map) ...[
                  currentProduct['product_id']['front_image'],
                  currentProduct['product_id']['featured_image'],
                  currentProduct['product_id']['image'],
                  if (currentProduct['product_id']['images'] is List &&
                      currentProduct['product_id']['images'].isNotEmpty)
                    currentProduct['product_id']['images'][0],
                ],
                if (currentProduct is Map &&
                    currentProduct['product'] is Map) ...[
                  currentProduct['product']['front_image'],
                  currentProduct['product']['featured_image'],
                  currentProduct['product']['image'],
                  if (currentProduct['product']['images'] is List &&
                      currentProduct['product']['images'].isNotEmpty)
                    currentProduct['product']['images'][0],
                ],
              ]);
              final bool hasValidImage = imageUrl.isNotEmpty &&
                  imageUrl != HelperFunctions.getNoImage();

              var productName = currentProduct['name']?.toString() ?? '';
              var quantity = parseDouble(
                      currentProduct['qty'] ?? currentProduct['quantity'] ?? 1)
                  .toInt();

              var unitPrice = getUnitPrice(currentProduct);
              var originalPrice = getOriginalPrice(currentProduct, unitPrice);
              final hasDiscount = originalPrice > unitPrice && unitPrice > 0;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: context.themegreyColor,
                        border: Border.all(color: context.themeBorderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                              errorWidget: (context, url, error) =>
                                  const ProductImagePlaceholder(radius: 8),
                            )
                          : const ProductImagePlaceholder(radius: 8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            color: context.themeTextColor,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (variantName.isNotEmpty &&
                            productType == 'variable' &&
                            variantName.trim() != productName.trim()) ...[
                          const SizedBox(height: 4),
                          Text(
                            variantName,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.themeSecondrytext,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: context.themegreyColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Qty: $quantity',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.themeTextColor,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (hasDiscount) ...[
                              Text(
                                '$symbol${originalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.themeSecondrytext,
                                  decoration: TextDecoration.lineThrough,
                                  fontFamily: 'Lato',
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              '$symbol${unitPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.themeTextColor,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$symbol${(unitPrice * quantity).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: context.themeTextColor,
                                fontFamily: 'Poppins',
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

          const Divider(height: 32),

          // Price Breakdown (Order Summary)
          _buildPriceRow(symbol, 'Subtotal', subtotal),
          if (itemSavings > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow(symbol, 'Product Savings', -itemSavings,
                isNegative: true),
          ],
          if (couponDiscount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow(
                symbol, 'Coupon Discount $couponPrefix', -couponDiscount,
                isNegative: true),
          ] else if (discount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow(symbol, 'Discount', -discount, isNegative: true),
          ],
          if (shippingCharges > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow(symbol, 'Shipping Charges', shippingCharges),
          ],
          if (taxAmount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow(symbol, 'Tax', taxAmount),
          ],
          const Divider(height: 24),
          _buildPriceRow(
            symbol,
            'Grand Total',
            total,
            isTotal: true,
          ),
          if (isCod) ...[
            const SizedBox(height: 8),
            _buildPriceRow(
              symbol,
              'COD',
              -total,
              isNegative: true,
              valueColor: context.themeTextColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceRow(String symbol, String label, double amount,
      {bool isTotal = false, bool isNegative = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal
                ? Get.context!.themeTextColor
                : Get.context!.themeSecondrytext,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          '${isNegative ? '-' : ''}$symbol ${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal
                ? const Color(0xFF20558A)
                : (valueColor ??
                    (isNegative ? Colors.green.shade700 : Get.context!.themeTextColor)),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}

class PaymentTransactionsCard extends StatelessWidget {
  const PaymentTransactionsCard({super.key, required this.item});
  final dynamic item;

  String _formatOrderDate(dynamic dateVal) {
    if (dateVal == null) return '';
    try {
      final dt = DateTime.parse(dateVal.toString()).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return dateVal.toString();
    }
  }

  Widget _buildStatusBadge({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    final symbol = orderCurrencySymbol(item['currency']);
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

    // Strict 2-decimal formatting to mirror website truth
    final String amountPaidStr = amountPaid.toStringAsFixed(2);
    final String pendingAmountStr = pendingAmount.toStringAsFixed(2);
    final orderDateRaw = item['created_at'] ??
        item['createdAt'] ??
        DateTime.now().toIso8601String();
    final formattedDate = _formatOrderDate(orderDateRaw);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3.5,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF20558A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.sync_alt_rounded,
                  size: 17, color: Color(0xFF20558A)),
              const SizedBox(width: 6),
              const Text(
                'Payment Transactions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Two Highlight Metric Boxes
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
                        child: const Icon(Icons.add,
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
                                fontFamily: 'Poppins',
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
                                fontFamily: 'Poppins',
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
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.access_time_rounded,
                            color: Color(0xFFDC2626), size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PENDING AMOUNT',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF991B1B),
                                fontFamily: 'Poppins',
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$symbol$pendingAmountStr',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDC2626),
                                fontFamily: 'Poppins',
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
          const SizedBox(height: 16),

          // Transactions Table (5 Columns matching website truth: DATE, METHOD, REFERENCE, AMOUNT, STATUS)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.themeBorderColor),
            ),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.themegreyColor,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'DATE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: themeSecondrytext,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'METHOD',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: themeSecondrytext,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'REFERENCE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: themeSecondrytext,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'AMOUNT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: themeSecondrytext,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'STATUS',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: themeSecondrytext,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (payments != null && payments.isNotEmpty)
                  ...payments.map((p) {
                    final pMap = p is Map ? p : {};
                    final pDate = _formatOrderDate(pMap['created_at'] ??
                        pMap['createdAt'] ??
                        pMap['date'] ??
                        formattedDate);
                    final pMethod = (pMap['gateway'] ?? paymentMethod)
                        .toString()
                        .toUpperCase();
                    final pAmt = parseDouble(pMap['amount']);
                    final pRef = (pMap['reference'] ??
                            pMap['transaction_id'] ??
                            pMap['ref'] ??
                            '-')
                        .toString();
                    final pStatusRaw =
                        (pMap['status'] ?? '').toString().toLowerCase();
                    final isPPaid = pStatusRaw == 'paid' ||
                        pStatusRaw == 'success' ||
                        pStatusRaw == 'completed';

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: context.themeBorderColor, width: 0.8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              pDate,
                              style: TextStyle(
                                fontSize: 11,
                                color: context.themeTextColor,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              pMethod,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: context.themeTextColor,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              pRef,
                              style: TextStyle(
                                fontSize: 11,
                                color: context.themeSecondrytext,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                if (!isPPaid) ...[
                                  const Icon(Icons.access_time_rounded,
                                      size: 12, color: Color(0xFFDC2626)),
                                  const SizedBox(width: 3),
                                ],
                                Text(
                                  '$symbol${pAmt.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isPPaid
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _buildStatusBadge(
                                text: isPPaid ? 'PAID' : 'Pending',
                                backgroundColor: isPPaid
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFFEF3C7),
                                textColor: isPPaid
                                    ? const Color(0xFF047857)
                                    : const Color(0xFF92400E),
                                borderColor: isPPaid
                                    ? const Color(0xFFA7F3D0)
                                    : const Color(0xFFFDE68A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList()
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.themeTextColor,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            paymentMethod,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: context.themeTextColor,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '-',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.themeSecondrytext,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              if (pendingAmount > 0) ...[
                                const Icon(Icons.access_time_rounded,
                                    size: 12, color: Color(0xFFDC2626)),
                                const SizedBox(width: 3),
                              ],
                              Text(
                                '$symbol$pendingAmountStr',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: pendingAmount > 0
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF16A34A),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _buildStatusBadge(
                              text: pendingAmount > 0
                                  ? 'Pending'
                                  : (paymentStatus.isNotEmpty
                                      ? paymentStatus
                                      : 'PAID'),
                              backgroundColor: pendingAmount > 0
                                  ? const Color(0xFFFEF3C7)
                                  : const Color(0xFFECFDF5),
                              textColor: pendingAmount > 0
                                  ? const Color(0xFF92400E)
                                  : const Color(0xFF047857),
                              borderColor: pendingAmount > 0
                                  ? const Color(0xFFFDE68A)
                                  : const Color(0xFFA7F3D0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          if (isCod && pendingAmount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: context.themegreyColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 15, color: themeSecondrytext),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Payment of $symbol$pendingAmountStr will be collected on delivery.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: themeSecondrytext,
                        fontFamily: 'Poppins',
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

class OrderTrackingCard extends StatelessWidget {
  final OrderdetailController controller = Get.find<OrderdetailController>();

  OrderTrackingCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final symbol = orderCurrencySymbol(controller.item['currency']);
    final double totalVal =
        double.tryParse(controller.item['total']?.toString() ?? '0') ?? 0.0;
    final totalStr = totalVal.toStringAsFixed(totalVal % 1 == 0 ? 0 : 2);

    final paymentStatus =
        controller.item['payment_status']?.toString().toLowerCase() ?? '';
    final isPaid = paymentStatus == 'paid';
    final isFailed = paymentStatus == 'failed';
    final payments = controller.item['payments'] as List?;
    final paidAt =
        payments != null && payments.isNotEmpty ? payments[0]['paid_at'] : null;
    final paymentMethod =
        controller.item['payment_method']?.toString().toUpperCase() ??
            'RAZORPAY';

    return Container(
      color: context.colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Order # and Dual Badges (Mirroring Website Image 1)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.item['order_no'] != null
                            ? 'Order #${controller.item['order_no']}'
                            : 'Order Details',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: context.themeTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Placed on ${HelperFunctions.formatOrderPlacedDate(controller.item)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: context.themeSecondrytext,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  children: [
                    // Order Status Badge (Navy Blue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF20558A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (controller.item['status'] is Map
                                ? controller.item['status']['name']
                                : (controller.item['status'] ?? 'Processing'))
                            .toString()
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    // Payment Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? const Color(0xFFECFDF5)
                            : (isFailed
                                ? const Color(0xFFFEF2F2)
                                : const Color(0xFFFEF3C7)),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isPaid
                              ? const Color(0xFFA7F3D0)
                              : (isFailed
                                  ? const Color(0xFFFECACA)
                                  : const Color(0xFFFDE68A)),
                        ),
                      ),
                      child: Text(
                        (paymentStatus.isNotEmpty
                                ? paymentStatus
                                : 'PENDING')
                            .toUpperCase(),
                        style: TextStyle(
                          color: isPaid
                              ? const Color(0xFF047857)
                              : (isFailed
                                  ? const Color(0xFFB91C1C)
                                  : const Color(0xFFB45309)),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Order Status Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPaid
                    ? (context.isDark
                        ? Colors.green.shade900.withOpacity(0.3)
                        : Colors.green.shade50)
                    : (isFailed
                        ? (context.isDark
                            ? Colors.red.shade900.withOpacity(0.3)
                            : Colors.red.shade50)
                        : (context.isDark
                            ? Colors.orange.shade900.withOpacity(0.3)
                            : Colors.orange.shade50)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isPaid
                        ? Icons.check_circle
                        : (isFailed ? Icons.error_outline : Icons.access_time),
                    color: isPaid
                        ? (context.isDark
                            ? Colors.green.shade300
                            : Colors.green.shade700)
                        : (isFailed
                            ? (context.isDark
                                ? Colors.red.shade300
                                : Colors.red.shade700)
                            : (context.isDark
                                ? Colors.orange.shade300
                                : Colors.orange.shade700)),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPaid
                              ? 'Payment Confirmed'
                              : (isFailed
                                  ? 'Payment Failed'
                                  : 'Payment Pending'),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isPaid
                                ? (context.isDark
                                    ? Colors.green.shade300
                                    : Colors.green.shade700)
                                : (isFailed
                                    ? (context.isDark
                                        ? Colors.red.shade300
                                        : Colors.red.shade700)
                                    : (context.isDark
                                        ? Colors.orange.shade300
                                        : Colors.orange.shade700)),
                          ),
                        ),
                        if (isPaid && paidAt != null)
                          Text(
                            _formatDate(paidAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: context.isDark
                                  ? Colors.green.shade200
                                  : Colors.green.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '$symbol $totalStr',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.themeTextColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Timeline
            Text(
              'Order Timeline',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: context.themeTextColor,
              ),
            ),
            const SizedBox(height: 16),

            _buildTimelineItem(
              title: 'Order Placed',
              date: HelperFunctions.formatOrderPlacedDate(controller.item),
              description: 'Your order has been placed successfully',
              isCompleted: true,
              icon: Icons.shopping_bag_outlined,
            ),

            _buildTimelineItem(
              title: 'Payment',
              date: isPaid
                  ? _formatDate(paidAt)
                  : (isFailed ? 'Failed' : 'Pending'),
              description: isPaid
                  ? 'Payment received via $paymentMethod'
                  : (isFailed
                      ? 'Payment failed via $paymentMethod'
                      : 'Awaiting payment confirmation'),
              isCompleted: isPaid,
              isFailed: isFailed,
              icon: Icons.payment_outlined,
            ),

            _buildTimelineItem(
              title: 'Order Confirmed',
              date: isPaid ? _formatDate(paidAt) : '-',
              description: isPaid
                  ? 'Your order has been confirmed and will be processed soon'
                  : (isFailed
                      ? 'Order confirmation failed due to failed payment'
                      : 'Will be confirmed after payment'),
              isCompleted: isPaid,
              isFailed: isFailed,
              icon:
                  isFailed ? Icons.cancel_outlined : Icons.check_circle_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String date,
    required String description,
    required bool isCompleted,
    bool isFailed = false,
    required IconData icon,
  }) {
    Color containerColor = isCompleted
        ? Colors.green.shade50
        : (isFailed ? Colors.red.shade50 : Colors.grey.shade100);
    Color iconColor =
        isCompleted ? Colors.green : (isFailed ? Colors.grey : Colors.grey);
    Color titleColor =
        isCompleted ? Colors.black87 : (isFailed ? Colors.grey : Colors.grey);
    Color descColor = isCompleted
        ? Colors.grey.shade600
        : (isFailed ? Colors.grey.shade400 : Colors.grey.shade400);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: containerColor,
            ),
            child: Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: titleColor,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 11,
                        color: isFailed
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: descColor,
                  ),
                ),
                if (isCompleted || isFailed) ...[
                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

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
}

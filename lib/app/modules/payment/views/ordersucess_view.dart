import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zouhi/app/modules/payment/controllers/ordersucess_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/order_currency.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/components/product_image_placeholder.dart';
import 'package:get/get.dart';

class OrdersucessView extends GetView<OrderSuccessController> {
  OrdersucessView({Key? key}) : super(key: key);
  @override
  final controller = Get.put(OrderSuccessController());

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

  Widget _buildSectionHeader(BuildContext context, String title,
      {IconData? icon}) {
    return Row(
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
        if (icon != null) ...[
          Icon(icon, size: 17, color: const Color(0xFF20558A)),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: context.themeTextColor,
            ),
          ),
        ),
      ],
    );
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
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value,
      {bool isDiscount = false, bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? context.themeTextColor : context.themeSecondrytext,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: valueColor ??
                (isDiscount
                    ? context.themeGreenColor
                    : (isTotal ? const Color(0xFF20558A) : context.themeTextColor)),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(Routes.BOTTOMBAR);
        return false;
      },
      child: Scaffold(
        backgroundColor: context.themegreyColor,
        appBar: AppBar(
            backgroundColor: context.colors.surface,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Order Placed',
              style: txtTheme().headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            iconTheme: IconThemeData(
              color: context.colors.onSurface,
            ),
            elevation: 0,
          ),
          body: Obx(() {
            final orderData = controller.item.containsKey('data')
                ? controller.item['data']
                : controller.item;

            final hasValidOrderId = controller.id.value.isNotEmpty &&
                controller.id.value != '0';
            final isDataEmpty =
                orderData == null || (orderData is Map && orderData.isEmpty);

            if (controller.isLoading.value ||
                (hasValidOrderId && isDataEmpty)) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: context.themeGreenColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded,
                          color: context.themeGreenColor, size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Order Placed Successfully!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: context.themeTextColor,
                        fontSize: 22,
                      ),
                    ),
                    if (controller.orderNo.value.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Your order #${controller.orderNo.value} has been placed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: context.themeSecondrytext,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    HelperFunctions()
                        .loadingIndicator(color: context.themeRedColor),
                  ],
                ),
              );
            }

            if (isDataEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No order details found"),
                ),
              );
            }

            final double exchangeRate =
                orderExchangeRate(orderData['currency']);
            final String symbol =
                orderCurrencySymbol(orderData['currency']);

            final addressData = orderData['address'] ?? {};
            final payments = orderData['payments'] as List?;
            final paymentStatus =
                (orderData['payment_status'] ?? '').toString().toUpperCase();
            final orderNo = orderData['order_no'] ?? 'N/A';
            final orderStatus = orderData['status'] is Map
                ? orderData['status']['name']
                : (orderData['status'] ?? 'Processing');

            final orderDateRaw = orderData['created_at'] ??
                orderData['createdAt'] ??
                DateTime.now().toIso8601String();
            final formattedDate = _formatOrderDate(orderDateRaw);

            final paymentMethod = payments != null && payments.isNotEmpty
                ? payments[0]['gateway'] ??
                    orderData['payment_method'] ??
                    'COD'
                : orderData['payment_method'] ?? 'COD';
            final isCod = paymentMethod.toString().toLowerCase() == 'cod';
            final isPaid = paymentStatus == 'PAID';
            final isFailed = !isCod && paymentStatus == 'FAILED';

            double parseDouble(dynamic value) {
              if (value == null) return 0.0;
              return double.tryParse(value.toString()) ?? 0.0;
            }

            final double totalVal = parseDouble(orderData['total']);
            final String totalStr = totalVal.toStringAsFixed(2);
            final products = orderData['products'] as List? ?? [];

            // Helper to get unit price and original catalog price
            double getUnitPrice(Map p) {
              double up = parseDouble(p['unit_price']);
              if (up > 0) return up;
              up = parseDouble(p['price']);
              if (up > 0) return up;
              final prodId = p['product_id'];
              if (prodId is Map) {
                up = parseDouble(prodId['price']) * exchangeRate;
              }
              return up;
            }

            double getOriginalPrice(Map p, double resolvedUnitPrice) {
              double op = parseDouble(p['price']);
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

            // Calculate Subtotal and Item Savings accurately
            double originalBagTotal = 0.0;
            double actualBagTotal = 0.0;
            for (var p in products) {
              if (p is Map) {
                double qty = parseDouble(p['quantity'] ?? p['qty'] ?? 1);
                if (qty <= 0) qty = 1.0;
                double unitPrice = getUnitPrice(p);
                double origPrice = getOriginalPrice(p, unitPrice);
                originalBagTotal += origPrice * qty;
                actualBagTotal += unitPrice * qty;
              }
            }

            double itemSavings = originalBagTotal - actualBagTotal;
            if (itemSavings < 0) itemSavings = 0.0;

            final double subtotalVal = orderData['subtotal'] != null &&
                    parseDouble(orderData['subtotal']) > 0
                ? parseDouble(orderData['subtotal'])
                : (originalBagTotal > 0 ? originalBagTotal : actualBagTotal);

            // Robust coupon discount handling (NO null values rendered!)
            final rawCoupon = orderData['coupon'];
            final flatDiscount = parseDouble(orderData['discount']);
            double couponDiscountVal = 0.0;
            String couponPrefix = '';
            if (rawCoupon is Map && rawCoupon.isNotEmpty) {
              couponDiscountVal = parseDouble(rawCoupon['discount']);
              final isPercentCoupon = (rawCoupon['discount_type']
                          ?.toString()
                          .toLowerCase() ??
                      '')
                  .contains('percent');
              final couponPercent =
                  rawCoupon['discount_value'] ?? rawCoupon['type_value'];
              if (isPercentCoupon && couponPercent != null) {
                couponPrefix = '($couponPercent%)';
              }
            } else if (flatDiscount > 0) {
              couponDiscountVal = flatDiscount;
            }
            final bool hasValidCoupon = couponDiscountVal > 0;

            final double shippingCharges =
                parseDouble(orderData['shipping_charges']);
            final double tax = parseDouble(
                orderData['tax'] ?? orderData['tax_amount'] ?? 0);
            final double taxPercentage =
                parseDouble(orderData['tax_percentage'] ?? 0);

            // Compute paid and pending amounts
            double amountPaid = 0.0;
            if (payments != null && payments.isNotEmpty) {
              for (var pay in payments) {
                if (pay is Map) {
                  final pStatus =
                      (pay['status'] ?? '').toString().toLowerCase();
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

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                          // 1. Success Icon & Title
                          Center(
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: (isFailed
                                        ? context.themeRedColor
                                        : context.themeGreenColor)
                                    .withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  isFailed
                                      ? Icons.error_outline
                                      : Icons.check_rounded,
                                  color: isFailed
                                      ? context.themeRedColor
                                      : context.themeGreenColor,
                                  size: 38,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              isFailed
                                  ? 'Payment Failed'
                                  : 'Order Placed Successfully!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: context.themeTextColor,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 2. Order Header & Status Card (Mirroring Image 1)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: context.themeBorderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Order #$orderNo',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                              color: context.themeTextColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Placed on $formattedDate',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontFamily: 'Poppins',
                                              color:
                                                  context.themeSecondrytext,
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
                                        _buildStatusBadge(
                                          text: orderStatus
                                              .toString()
                                              .toUpperCase(),
                                          backgroundColor:
                                              const Color(0xFF20558A),
                                          textColor: Colors.white,
                                        ),
                                        // Payment Status Badge (Amber or Green)
                                        _buildStatusBadge(
                                          text: paymentStatus.isNotEmpty
                                              ? paymentStatus
                                              : 'PENDING',
                                          backgroundColor: isPaid
                                              ? const Color(0xFFECFDF5)
                                              : (isFailed
                                                  ? const Color(0xFFFEF2F2)
                                                  : const Color(0xFFFEF3C7)),
                                          textColor: isPaid
                                              ? const Color(0xFF047857)
                                              : (isFailed
                                                  ? const Color(0xFFB91C1C)
                                                  : const Color(0xFFB45309)),
                                          borderColor: isPaid
                                              ? const Color(0xFFA7F3D0)
                                              : (isFailed
                                                  ? const Color(0xFFFECACA)
                                                  : const Color(0xFFFDE68A)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 3. Order Items Card (Mirroring Image 1)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: context.themeBorderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(context, 'Order Items'),
                                const SizedBox(height: 16),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  itemCount: products.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                          height: 24, thickness: 0.8),
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    final qty = parseDouble(product['qty'] ??
                                        product['quantity'] ??
                                        1);
                                    final int qtyInt = qty.toInt();
                                    final productName =
                                        product['name'] ?? 'Product';
                                    final sku = product['variant'] is Map
                                        ? product['variant']['sku']
                                        : product['sku'];

                                    final unitPrice = getUnitPrice(product);
                                    final originalPrice =
                                        getOriginalPrice(product, unitPrice);
                                    final totalLinePrice = unitPrice * qty;
                                    final hasDiscount = originalPrice >
                                            unitPrice &&
                                        unitPrice > 0;

                                    final productObj = product['product_id'] ??
                                        product['product'];
                                    final productType = (productObj is Map
                                            ? productObj['type']
                                            : null) ??
                                        'simple';
                                    final variantObj = product['variant'];
                                    final variantName = (variantObj is Map
                                            ? (variantObj['name'] ??
                                                    variantObj['variant'])
                                                ?.toString()
                                            : null) ??
                                        '';

                                    final imageUrl =
                                        HelperFunctions().getImage([
                                      if (variantObj is Map) ...[
                                        variantObj['front_image'],
                                        variantObj['featured_image'],
                                        variantObj['image'],
                                      ],
                                      product['image'],
                                      product['featured_image'],
                                      product['front_image'],
                                      if (product['product_id'] is Map) ...[
                                        product['product_id']['front_image'],
                                        product['product_id']
                                            ['featured_image'],
                                        product['product_id']['image'],
                                      ],
                                      if (product['product'] is Map) ...[
                                        product['product']['front_image'],
                                        product['product']['featured_image'],
                                        product['product']['image'],
                                      ],
                                    ]);

                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: context
                                                    .themeBorderColor),
                                            color: context.themegreyColor,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: imageUrl.isEmpty ||
                                                    imageUrl ==
                                                        HelperFunctions
                                                            .getNoImage()
                                                ? const ProductImagePlaceholder(
                                                    radius: 8,
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl: imageUrl,
                                                    fit: BoxFit.contain,
                                                    progressIndicatorBuilder:
                                                        (context, url,
                                                                progress) =>
                                                            HelperFunctions()
                                                                .loadingIndicator(),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const ProductImagePlaceholder(
                                                      radius: 8,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                productName,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Poppins',
                                                  color:
                                                      context.themeTextColor,
                                                ),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              if (variantName.isNotEmpty &&
                                                  productType == 'variable' &&
                                                  variantName.trim() !=
                                                      productName.trim()) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  variantName,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: context
                                                        .themeSecondrytext,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ],
                                              if (sku != null &&
                                                  sku
                                                      .toString()
                                                      .trim()
                                                      .isNotEmpty &&
                                                  sku
                                                          .toString()
                                                          .trim()
                                                          .toLowerCase() !=
                                                      'n/a') ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'SKU: $sku',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: context
                                                        .themeSecondrytext,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(height: 6),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Qty: $qtyInt',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: context
                                                              .themeSecondrytext,
                                                          fontFamily: 'Poppins',
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        '× $symbol${unitPrice.toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: context
                                                              .themeSecondrytext,
                                                          fontFamily: 'Poppins',
                                                        ),
                                                      ),
                                                      if (hasDiscount) ...[
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '$symbol${originalPrice.toStringAsFixed(2)}',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: context
                                                                .themeSecondrytext,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            fontFamily: 'Lato',
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  Text(
                                                    '$symbol${totalLinePrice.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: context
                                                          .themeTextColor,
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
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 4. Order Summary Card (Mirroring Image 2)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: context.themeBorderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(context, 'Order Summary'),
                                const SizedBox(height: 16),
                                _buildPriceRow(
                                  context,
                                  'Subtotal',
                                  '$symbol ${subtotalVal.toStringAsFixed(2)}',
                                ),
                                if (itemSavings > 0) ...[
                                  const SizedBox(height: 10),
                                  _buildPriceRow(
                                    context,
                                    'You Save',
                                    '-$symbol ${itemSavings.toStringAsFixed(2)}',
                                    isDiscount: true,
                                  ),
                                ],
                                if (hasValidCoupon) ...[
                                  const SizedBox(height: 10),
                                  _buildPriceRow(
                                    context,
                                    'Coupon Discount $couponPrefix',
                                    '-$symbol ${couponDiscountVal.toStringAsFixed(2)}',
                                    isDiscount: true,
                                  ),
                                ],
                                if (tax > 0) ...[
                                  const SizedBox(height: 10),
                                  _buildPriceRow(
                                    context,
                                    taxPercentage > 0
                                        ? 'Tax (${taxPercentage.toStringAsFixed(0)}%)'
                                        : 'Tax',
                                    '+$symbol ${tax.toStringAsFixed(2)}',
                                  ),
                                ],
                                if (shippingCharges > 0) ...[
                                  const SizedBox(height: 10),
                                  _buildPriceRow(
                                    context,
                                    'Delivery Charges',
                                    '+$symbol ${shippingCharges.toStringAsFixed(2)}',
                                  ),
                                ],
                                const Divider(height: 24, thickness: 0.8),
                                _buildPriceRow(
                                  context,
                                  'Grand Total',
                                  '$symbol $totalStr',
                                  isTotal: true,
                                ),
                                if (isCod) ...[
                                  const SizedBox(height: 10),
                                  _buildPriceRow(
                                    context,
                                    'COD',
                                    '-$symbol $totalStr',
                                    valueColor: context.themeTextColor,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 5. Shipping Address & Payment Info Cards (Responsive Layout)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final streetAddress = [
                                if (addressData['house_no'] != null &&
                                    addressData['house_no'].toString().trim().isNotEmpty)
                                  addressData['house_no'].toString().trim(),
                                if (addressData['address'] != null &&
                                    addressData['address'].toString().trim().isNotEmpty)
                                  addressData['address'].toString().trim()
                                else if (addressData['street'] != null &&
                                    addressData['street'].toString().trim().isNotEmpty)
                                  addressData['street'].toString().trim(),
                                if (addressData['landmark'] != null &&
                                    addressData['landmark'].toString().trim().isNotEmpty)
                                  addressData['landmark'].toString().trim(),
                              ].join(', ');

                              final stateName = addressData['state'] is Map
                                  ? addressData['state']['name']
                                  : addressData['state'];
                              final cityName = addressData['city'] is Map
                                  ? addressData['city']['name']
                                  : addressData['city'];
                              final pin = addressData['pincode'] ?? addressData['postal_code'];

                              final cityStatePin = [
                                if (cityName != null && cityName.toString().trim().isNotEmpty)
                                  cityName.toString().trim(),
                                if (stateName != null && stateName.toString().trim().isNotEmpty)
                                  stateName.toString().trim(),
                                if (pin != null && pin.toString().trim().isNotEmpty)
                                  pin.toString().trim(),
                              ].join(', ');

                              final shippingCard = Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: context.colors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: context.themeBorderColor),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionHeader(
                                        context, 'Shipping Address',
                                        icon: Icons.location_on_outlined),
                                    const SizedBox(height: 12),
                                    Text(
                                      (addressData['name'] ?? 'Customer')
                                          .toString()
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                        color: context.themeTextColor,
                                      ),
                                    ),
                                    if (addressData['mobile'] != null &&
                                        addressData['mobile'].toString().trim().isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.phone_outlined,
                                              size: 14,
                                              color: context.themeSecondrytext),
                                          const SizedBox(width: 6),
                                          Text(
                                            addressData['mobile'].toString().trim(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              color: context.themeSecondrytext,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (streetAddress.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        streetAddress,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                          color: context.themeSecondrytext,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                    if (cityStatePin.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        cityStatePin,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                          color: context.themeSecondrytext,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );

                              final paymentCard = Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: context.colors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: context.themeBorderColor),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionHeader(
                                        context, 'Payment Info',
                                        icon: Icons.payment_outlined),
                                    const SizedBox(height: 12),
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
                                          paymentMethod
                                              .toString()
                                              .toUpperCase(),
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
                                        _buildStatusBadge(
                                          text: paymentStatus.isNotEmpty
                                              ? paymentStatus
                                              : 'PENDING',
                                          backgroundColor: isPaid
                                              ? const Color(0xFFECFDF5)
                                              : (isFailed
                                                  ? const Color(0xFFFEF2F2)
                                                  : const Color(0xFFFEF3C7)),
                                          textColor: isPaid
                                              ? const Color(0xFF047857)
                                              : (isFailed
                                                  ? const Color(0xFFB91C1C)
                                                  : const Color(0xFFB45309)),
                                          borderColor: isPaid
                                              ? const Color(0xFFA7F3D0)
                                              : (isFailed
                                                  ? const Color(0xFFFECACA)
                                                  : const Color(0xFFFDE68A)),
                                        ),
                                      ],
                                    ),
                                    if (orderData['notes'] != null &&
                                        orderData['notes']
                                            .toString()
                                            .trim()
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: context.themegreyColor,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
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
                                              orderData['notes'].toString().trim(),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: context.themeSecondrytext,
                                                fontFamily: 'Poppins',
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );

                              if (constraints.maxWidth > 550) {
                                return Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                          const SizedBox(height: 16),

                          // 6. Payment Transactions Card (Mirroring Images 2 & 3)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: context.themeBorderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                    context, 'Payment Transactions',
                                    icon: Icons.sync_alt_rounded),
                                const SizedBox(height: 16),

                                // Dual Highlight Boxes
                                Row(
                                  children: [
                                    // AMOUNT PAID
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0FDF4),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: const Color(0xFF86EFAC)),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFDCFCE7),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.add,
                                                  color: Color(0xFF16A34A),
                                                  size: 18),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'AMOUNT PAID',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF166534),
                                                      fontFamily: 'Poppins',
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '$symbol$amountPaidStr',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF16A34A),
                                                      fontFamily: 'Poppins',
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // PENDING AMOUNT
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: const Color(0xFFFCA5A5)),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFFEE2E2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                  Icons.access_time_rounded,
                                                  color: Color(0xFFDC2626),
                                                  size: 18),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'PENDING AMOUNT',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF991B1B),
                                                      fontFamily: 'Poppins',
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '$symbol$pendingAmountStr',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFFDC2626),
                                                      fontFamily: 'Poppins',
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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

                                // Transactions Table
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: context.themeBorderColor),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: context.themegreyColor,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(8)),
                                        ),
                                        child: const Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'DATE',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                                'REF #',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                      if (payments != null &&
                                          payments.isNotEmpty)
                                        ...payments.map((p) {
                                          final pMap = p is Map ? p : {};
                                          final pDate = _formatOrderDate(
                                              pMap['created_at'] ??
                                                  pMap['createdAt'] ??
                                                  pMap['date'] ??
                                                  formattedDate);
                                          final pMethod =
                                              (pMap['gateway'] ?? paymentMethod)
                                                  .toString()
                                                  .toUpperCase();
                                          final pAmt =
                                              parseDouble(pMap['amount']);
                                          final pRef = (pMap['reference'] ??
                                                  pMap['transaction_id'] ??
                                                  pMap['ref'] ??
                                                  '-')
                                              .toString();
                                          final pStatusRaw =
                                              (pMap['status'] ?? '')
                                                  .toString()
                                                  .toLowerCase();
                                          final isPPaid = pStatusRaw ==
                                                  'paid' ||
                                              pStatusRaw == 'success' ||
                                              pStatusRaw == 'completed';

                                          return Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 10),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                    color: context
                                                        .themeBorderColor,
                                                    width: 0.8),
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
                                                      color: context
                                                          .themeTextColor,
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: context
                                                          .themeTextColor,
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
                                                      color: context
                                                          .themeSecondrytext,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Row(
                                                    children: [
                                                      if (!isPPaid) ...[
                                                        const Icon(
                                                            Icons
                                                                .access_time_rounded,
                                                            size: 12,
                                                            color: Color(
                                                                0xFFDC2626)),
                                                        const SizedBox(
                                                            width: 3),
                                                      ],
                                                      Text(
                                                        '$symbol${pAmt.toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isPPaid
                                                              ? const Color(
                                                                  0xFF16A34A)
                                                              : const Color(
                                                                  0xFFDC2626),
                                                          fontFamily:
                                                              'Poppins',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: _buildStatusBadge(
                                                      text: isPPaid
                                                          ? 'PAID'
                                                          : 'Pending',
                                                      backgroundColor: isPPaid
                                                          ? const Color(
                                                              0xFFECFDF5)
                                                          : const Color(
                                                              0xFFFEF3C7),
                                                      textColor: isPPaid
                                                          ? const Color(
                                                              0xFF047857)
                                                          : const Color(
                                                              0xFF92400E),
                                                      borderColor: isPPaid
                                                          ? const Color(
                                                              0xFFA7F3D0)
                                                          : const Color(
                                                              0xFFFDE68A),
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
                                                    color: context
                                                        .themeTextColor,
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
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: context
                                                        .themeTextColor,
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
                                                    color: context
                                                        .themeSecondrytext,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Row(
                                                  children: [
                                                    if (pendingAmount > 0) ...[
                                                      const Icon(
                                                          Icons
                                                              .access_time_rounded,
                                                          size: 12,
                                                          color: Color(
                                                              0xFFDC2626)),
                                                      const SizedBox(
                                                          width: 3),
                                                    ],
                                                    Text(
                                                      '$symbol$pendingAmountStr',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: pendingAmount >
                                                                0
                                                            ? const Color(
                                                                0xFFDC2626)
                                                            : const Color(
                                                                0xFF16A34A),
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: _buildStatusBadge(
                                                    text: pendingAmount > 0
                                                        ? 'Pending'
                                                        : (paymentStatus
                                                                .isNotEmpty
                                                            ? paymentStatus
                                                            : 'PAID'),
                                                    backgroundColor:
                                                        pendingAmount > 0
                                                            ? const Color(
                                                                0xFFFEF3C7)
                                                            : const Color(
                                                                0xFFECFDF5),
                                                    textColor:
                                                        pendingAmount > 0
                                                            ? const Color(
                                                                0xFF92400E)
                                                            : const Color(
                                                                0xFF047857),
                                                    borderColor:
                                                        pendingAmount > 0
                                                            ? const Color(
                                                                0xFFFDE68A)
                                                            : const Color(
                                                                0xFFA7F3D0),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // COD Advisory Message
                                if (isCod && pendingAmount > 0) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: context.themegreyColor,
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.info_outline,
                                            size: 15,
                                            color: themeSecondrytext),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Payment of $symbol$pendingAmountStr will be collected on delivery.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  context.themeSecondrytext,
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
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
          }),
          bottomNavigationBar: Obx(() {
            final orderData = controller.item.containsKey('data')
                ? controller.item['data']
                : controller.item;
            if (controller.isLoading.value ||
                orderData == null ||
                (orderData is Map && orderData.isEmpty)) {
              return const SizedBox.shrink();
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.offAllNamed(Routes.BOTTOMBAR);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF20558A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'CONTINUE SHOPPING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
    );
  }
}

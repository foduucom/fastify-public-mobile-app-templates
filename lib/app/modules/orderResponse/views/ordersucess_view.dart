// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/Profie/orders/controller/orders_controller.dart';
import '../controllers/ordersucess_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/bottombutton.dart';
import 'package:foduu_ecommerce/components/oderdetail.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class OrdersucessView extends GetView<OrderSuccessController> {
  const OrdersucessView({Key? key}) : super(key: key);

  bool get _isCod =>
      controller.item['payment_method']?.toString().toLowerCase() == 'cod' ||
      controller.checkoutMethod.value == 'cod';

  /// [amountPaid, amountPending] derived from the order's payments.
  List<double> _paidAndPending() {
    double parse(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0.0;
    final total = parse(controller.item['total']);
    double paid = 0.0;
    final payments = controller.item['payments'];
    if (payments is List && payments.isNotEmpty) {
      for (final pay in payments) {
        if (pay is Map) {
          final status = (pay['status'] ?? '').toString().toLowerCase();
          if (status == 'paid' ||
              status == 'success' ||
              status == 'completed') {
            paid += parse(pay['amount']);
          }
        }
      }
    } else if (controller.item['payment_status'] == 'paid' && !_isCod) {
      paid = total;
    }
    final pending = total - paid;
    return [paid, pending < 0 ? 0.0 : pending];
  }

  Widget _statusBadge(BuildContext context, String text, bool pending) {
    final scheme = Theme.of(context).colorScheme;
    // Pending uses a fixed amber (no colour-scheme slot); paid follows the theme.
    final fg = pending ? Colors.amber.shade900 : scheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Text(text.toUpperCase(),
          style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'lato',
              letterSpacing: 0.5)),
    );
  }

  Widget _priceRow(BuildContext context, String label, String value,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: 'lato',
                  fontSize: bold ? 15 : 14,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontFamily: 'lato',
                  fontSize: bold ? 15 : 14,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  /// Shown while the order is still loading, so the user sees confirmation
  /// immediately instead of a bare spinner.
  Widget _interimLoading(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          LottieBuilder.asset('assets/lotti/order-success.json',
              fit: BoxFit.cover, height: 180),
          const SizedBox(height: 16),
          Text('Order Placed Successfully!',
              style: textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'lato')),
          if (controller.orderNo.value.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Your order #${controller.orderNo.value} has been placed.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant, fontFamily: 'lato')),
          ],
          const SizedBox(height: 24),
          HelperFunctions().loadingIndicator(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(Routes.BOTTOMBAR);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('Order Placed',
                  style: txtTheme().titleLarge!.copyWith(
                      fontWeight: FontWeight.bold, fontFamily: 'Lato')),
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
              // backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: SingleChildScrollView(
                    child: Obx(
                      () => controller.isLoading.value
                          ? (controller.item.isEmpty
                              ? _interimLoading(context)
                              : HelperFunctions().loadingIndicator())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: pageSurroundingPadding,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                            child: LottieBuilder.asset(
                                                controller.item['payment_status'] ==
                                                            'paid' ||
                                                        controller.item[
                                                                'payment_method'] ==
                                                            'cod' ||
                                                        controller
                                                                .checkoutMethod
                                                                .value ==
                                                            'cod'
                                                    ? 'assets/lotti/order-success.json'
                                                    : 'assets/lotti/emptyanimation.json',
                                                fit: BoxFit.cover,
                                                height: 180)),
                                        Center(
                                            child: Text(
                                                controller.item['payment_status'] ==
                                                            'paid' ||
                                                        controller.item['payment_method'] ==
                                                            'cod' ||
                                                        controller
                                                                .checkoutMethod
                                                                .value ==
                                                            'cod'
                                                    ? 'Order Placed successfully!'
                                                    : 'Order Placement Failed!',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'lato',
                                                    color: controller.item['payment_status'] ==
                                                                'paid' ||
                                                            controller.item[
                                                                    'payment_method'] ==
                                                                'cod' ||
                                                            controller
                                                                    .checkoutMethod
                                                                    .value ==
                                                                'cod'
                                                        ? Colors.black
                                                        : Colors.black54,
                                                    fontSize: 22))),
                                        SizedBox(height: 20),
                                        Center(
                                          child: Text(
                                              controller.item['payment_status'] ==
                                                          'paid' ||
                                                      controller.item[
                                                              'payment_method'] ==
                                                          'cod' ||
                                                      controller.checkoutMethod
                                                              .value ==
                                                          'cod'
                                                  ? 'Payment is successfully processed and your Order is on the way.'
                                                  : 'Payment was not completed. Your order is pending payment.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'lato',
                                                fontSize: 16,
                                              )),
                                        ),
                                        if (_isCod &&
                                            _paidAndPending()[1] > 0) ...[
                                          SizedBox(height: 14),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.amber
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.amber
                                                      .withValues(alpha: 0.4)),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.info_outline,
                                                    size: 20,
                                                    color:
                                                        Colors.amber.shade800),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    'Payment of ${controller.item['currency'] ?? '₹'}${_paidAndPending()[1].toStringAsFixed(2)} will be collected on delivery.',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors
                                                            .amber.shade900,
                                                        fontFamily: 'lato'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        SizedBox(height: 20),
                                        const Text(
                                          'Order Details:',
                                          style: TextStyle(
                                              fontFamily: 'Lato',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                            'Your order # is: ${controller.item['order_no']}',
                                            style: TextStyle(
                                                fontFamily: 'lato',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600)),
                                        const Text(
                                            'An email receipt including the details about your order has been sent to your email ID.',
                                            style: TextStyle(
                                              fontFamily: 'lato',
                                              fontSize: 14,
                                              // color: themeSecondrytext
                                            )),
                                        SizedBox(height: 20),
                                        const Text(
                                            'This order will be shipped to:',
                                            style: TextStyle(
                                                fontFamily: 'lato',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600)),
                                        SizedBox(
                                            width: double.infinity,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    '${controller.address['name'] ?? ''}',
                                                    style: TextStyle(
                                                        fontFamily: 'lato',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                Text(
                                                    '${controller.address['address'] ?? ''}',
                                                    style: TextStyle(
                                                      fontFamily: 'lato',
                                                      fontSize: 14,
                                                    )),
                                                (() {
                                                  final isHexId = RegExp(
                                                      r'^[a-fA-F0-9]{24}$');
                                                  String? getVal(dynamic val) {
                                                    if (val == null)
                                                      return null;
                                                    if (val is Map)
                                                      return val['name']
                                                              ?.toString() ??
                                                          val['title']
                                                              ?.toString() ??
                                                          '';
                                                    final str =
                                                        val.toString().trim();
                                                    return isHexId.hasMatch(str)
                                                        ? null
                                                        : str;
                                                  }

                                                  final city = getVal(controller
                                                      .address['city']);
                                                  final state = getVal(
                                                      controller
                                                          .address['state']);
                                                  final country = getVal(
                                                      controller
                                                          .address['country']);
                                                  final pincode = controller
                                                          .address['pincode'] ??
                                                      controller.address[
                                                          'postal_code'];

                                                  final addressParts = [
                                                    city,
                                                    state,
                                                    country
                                                  ]
                                                      .where((e) =>
                                                          e != null &&
                                                          e
                                                              .toString()
                                                              .trim()
                                                              .isNotEmpty)
                                                      .map((e) =>
                                                          e.toString().trim())
                                                      .toList();

                                                  if (addressParts.isEmpty &&
                                                      (pincode == null ||
                                                          pincode
                                                              .toString()
                                                              .trim()
                                                              .isEmpty)) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }

                                                  final formattedAddressLine =
                                                      addressParts.join(', ') +
                                                          (pincode != null &&
                                                                  pincode
                                                                      .toString()
                                                                      .trim()
                                                                      .isNotEmpty
                                                              ? ' - ${pincode.toString().trim()}'
                                                              : '');

                                                  return Text(
                                                    formattedAddressLine,
                                                    style: const TextStyle(
                                                      fontFamily: 'lato',
                                                      fontSize: 14,
                                                    ),
                                                  );
                                                })(),
                                                Text(
                                                    'Mobile: ${controller.address['mobile'] ?? ''}',
                                                    style: TextStyle(
                                                      fontFamily: 'lato',
                                                      fontSize: 14,
                                                    )),
                                              ],
                                            )),
                                        SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('Payment Method',
                                                    style: TextStyle(
                                                        fontFamily: 'lato',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                Text(
                                                    _isCod
                                                        ? 'Cash On Delivery'
                                                        : controller.item[
                                                                'payment_method']
                                                            .toString()
                                                            .toUpperCase(),
                                                    style: TextStyle(
                                                      fontFamily: 'lato',
                                                      fontSize: 14,
                                                    )),
                                              ],
                                            ),
                                            if (_isCod ||
                                                controller.item[
                                                        'payment_status'] ==
                                                    'paid')
                                              _statusBadge(
                                                  context,
                                                  _isCod &&
                                                          _paidAndPending()[1] >
                                                              0
                                                      ? 'Pending'
                                                      : (controller.item[
                                                                  'payment_status']
                                                              ?.toString() ??
                                                          'Paid'),
                                                  _isCod &&
                                                      _paidAndPending()[1] > 0),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                      ]),
                                ),
                                Divider(
                                  thickness: 10,
                                ),
                                Padding(
                                  padding: pageSurroundingPadding,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Obx(
                                        () {
                                          final subtotal =
                                              HelperFunctions.parseAmount(
                                                  controller.item['subtotal']);
                                          final total =
                                              HelperFunctions.parseAmount(
                                                  controller.item['total']);
                                          final discount =
                                              HelperFunctions.parseAmount(
                                                  controller.item['discount']);
                                          final shippingCharges =
                                              HelperFunctions.parseAmount(
                                                  controller.item[
                                                      'shipping_charges']);
                                          // savings = MRP bag total - sale price total
                                          // total = subtotal - savings - discount + shippingCharges
                                          // So: savings = subtotal - discount + shippingCharges - total
                                          final savings = subtotal -
                                              discount +
                                              shippingCharges -
                                              total;
                                          final hasSavings = savings >
                                              0.5; // threshold to avoid floating-point noise

                                          return orderDetial(
                                            isShowBagSaving: hasSavings,
                                            savedPrice: hasSavings
                                                ? savings.toStringAsFixed(2)
                                                : null,
                                            couponPrefix: '',
                                            price: controller.item['subtotal']
                                                .toString(),
                                            cuponValue:
                                                '${controller.item['currency'] ?? '₹'}${controller.item['discount'].toString()}',
                                            deliveryStatus:
                                                '${controller.item['currency'] ?? '₹'}${controller.item['shipping_charges'].toString()}',
                                            totalAmount: controller
                                                .item['total']
                                                .toString(),
                                          );
                                        },
                                      ),
                                      if (_isCod)
                                        Obx(() {
                                          final cur =
                                              controller.item['currency'] ??
                                                  '₹';
                                          final amounts = _paidAndPending();
                                          return Column(
                                            children: [
                                              _priceRow(context, 'Amount Paid',
                                                  '$cur${amounts[0].toStringAsFixed(2)}',
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                              _priceRow(
                                                  context,
                                                  'Payable on Delivery',
                                                  '$cur${amounts[1].toStringAsFixed(2)}',
                                                  bold: true,
                                                  color: amounts[1] > 0
                                                      ? Colors.amber.shade900
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                            ],
                                          );
                                        }),
                                      const SizedBox(height: 90),
                                    ],
                                  ),
                                )
                              ],
                            ),
                    ),
                  ),
                ),
                Obx(
                  () => bottomButton(
                    opacity: 1,
                    deliveryAmount:
                        controller.item['shipping']?.toString() ?? '0',
                    buttonText: controller.item['payment_status'] == 'paid' ||
                            controller.item['payment_method'] == 'cod' ||
                            controller.checkoutMethod.value == 'cod'
                        ? 'Continue Shopping'
                        : 'View My Orders',
                    priceText: controller.item['total']?.toString() ?? '0',
                    keypressEvent: () {
                      if (controller.item['payment_status'] == 'paid' ||
                          controller.item['payment_method'] == 'cod' ||
                          controller.checkoutMethod.value == 'cod') {
                        Get.offAllNamed(Routes.BOTTOMBAR);
                      } else {
                        // Navigate to orders section if payment failed
                        Get.offAllNamed(Routes.BOTTOMBAR);
                        // Optional: trigger navigation to the orders tab if possible
                      }
                    },
                    otherText: 'View details',
                  ),
                )
              ],
            )),
      ),
    );
  }
}

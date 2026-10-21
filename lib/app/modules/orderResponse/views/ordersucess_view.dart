import 'package:flutter/material.dart';
import '../controllers/ordersucess_controller.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class OrdersucessView extends GetView<OrderSuccessController> {
  OrdersucessView({Key? key}) : super(key: key);
  @override
  final controller = Get.put(OrderSuccessController());

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
          fontFamily: 'lato',
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String value,
    bool isBold = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'lato',
              fontSize: isBold ? 15 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'lato',
              fontSize: isBold ? 15 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(Routes.BOTTOMBAR);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Order Placed',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'lato',
              ),
            ),
            automaticallyImplyLeading: false,
            elevation: 0,
          ),
          body: Obx(() {
            final orderData = controller.item.containsKey('data') &&
                    controller.item['data'] is Map
                ? controller.item['data']
                : controller.item;

            final bool hasItem = orderData is Map && orderData.isNotEmpty;

            // If still loading and orderData is empty, show clean interim progress
            if (controller.isLoading.value && !hasItem) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: LottieBuilder.asset(
                          'assets/lotti/order-success.json',
                          fit: BoxFit.cover,
                          height: 180,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Order Placed Successfully!',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'lato',
                        ),
                      ),
                      if (controller.orderNo.value.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Your order #${controller.orderNo.value} has been placed.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontFamily: 'lato',
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      HelperFunctions().loadingIndicator(),
                    ],
                  ),
                ),
              );
            }

            final paymentMethod = (orderData['payment_method'] ?? 'COD')
                .toString()
                .toUpperCase();
            final isCod = paymentMethod.toLowerCase() == 'cod';
            final paymentStatus =
                (orderData['payment_status'] ?? (isCod ? 'PENDING' : 'PAID'))
                    .toString()
                    .toUpperCase();
            final currency = (orderData['currency'] ?? '₹').toString();

            double parseDouble(dynamic value) {
              if (value == null) return 0.0;
              return double.tryParse(value.toString()) ?? 0.0;
            }

            final double totalVal = parseDouble(orderData['total']);
            final double subtotalVal = parseDouble(orderData['subtotal']) > 0
                ? parseDouble(orderData['subtotal'])
                : totalVal;
            final double discountVal = parseDouble(orderData['discount']);
            final double shippingVal =
                parseDouble(orderData['shipping_charges'] ?? orderData['shipping']);

            final List? payments = orderData['payments'] is List
                ? orderData['payments']
                : null;

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

            final String displayedOrderNo =
                (orderData['order_no'] ?? controller.orderNo.value).toString();

            return Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: pageSurroundingPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: LottieBuilder.asset(
                                  'assets/lotti/order-success.json',
                                  fit: BoxFit.cover,
                                  height: 170,
                                ),
                              ),
                              Center(
                                child: Text(
                                  'Order Placed Successfully!',
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'lato',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  isCod
                                      ? 'Your order has been confirmed and will be delivered soon.'
                                      : 'Payment is successfully processed and your order is on the way.',
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontFamily: 'lato',
                                  ),
                                ),
                              ),

                              // COD Advisory Notice Box
                              if (isCod && pendingAmount > 0) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.amber.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline,
                                          size: 20,
                                          color: Colors.amber.shade800),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Payment of $currency${pendingAmount.toStringAsFixed(2)} will be collected on delivery.',
                                          style: TextStyle(
                                            fontSize: 13,
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

                              const SizedBox(height: 20),
                              Text(
                                'Order Details:',
                                style: textTheme.titleMedium?.copyWith(
                                  fontFamily: 'lato',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (displayedOrderNo.isNotEmpty) ...[
                                Text(
                                  'Your order # is: $displayedOrderNo',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontFamily: 'lato',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                'An email receipt including the details about your order has been sent to your email ID.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontFamily: 'lato',
                                ),
                              ),

                              // Delivery Address
                              const SizedBox(height: 20),
                              Text(
                                'This order will be shipped to:',
                                style: textTheme.titleSmall?.copyWith(
                                  fontFamily: 'lato',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (controller.address['name'] != null)
                                      Text(
                                        '${controller.address['name']}',
                                        style: const TextStyle(
                                          fontFamily: 'lato',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    if (controller.address['address'] != null)
                                      Text(
                                        '${controller.address['address']}',
                                        style: const TextStyle(
                                            fontFamily: 'lato', fontSize: 13),
                                      ),
                                    Text(
                                      '${controller.address['city'] is Map ? controller.address['city']['name'] : ''}, ${controller.address['state'] is Map ? controller.address['state']['name'] : ''}, ${controller.address['country'] is Map ? controller.address['country']['name'] : ''}',
                                      style: const TextStyle(
                                          fontFamily: 'lato', fontSize: 13),
                                    ),
                                    if (controller.address['pincode'] != null)
                                      Text(
                                        'Pincode: ${controller.address['pincode']}',
                                        style: const TextStyle(
                                            fontFamily: 'lato', fontSize: 13),
                                      ),
                                    if (controller.address['mobile'] != null)
                                      Text(
                                        'Mobile: ${controller.address['mobile']}',
                                        style: const TextStyle(
                                            fontFamily: 'lato', fontSize: 13),
                                      ),
                                  ],
                                ),
                              ),

                              // Payment Info & Status
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Payment Method',
                                        style: textTheme.bodySmall?.copyWith(
                                          fontFamily: 'lato',
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isCod
                                            ? 'Cash On Delivery'
                                            : paymentMethod,
                                        style: const TextStyle(
                                          fontFamily: 'lato',
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  _buildStatusBadge(
                                    text: isCod && pendingAmount > 0
                                        ? 'Pending'
                                        : (paymentStatus.isNotEmpty
                                            ? paymentStatus
                                            : 'PAID'),
                                    backgroundColor: isCod && pendingAmount > 0
                                        ? const Color(0xFFFEF3C7)
                                        : const Color(0xFFECFDF5),
                                    textColor: isCod && pendingAmount > 0
                                        ? const Color(0xFF92400E)
                                        : const Color(0xFF047857),
                                    borderColor: isCod && pendingAmount > 0
                                        ? const Color(0xFFFDE68A)
                                        : const Color(0xFFA7F3D0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 8,
                          color: colorScheme.surfaceContainerHighest,
                        ),

                        // Price Details Summary
                        Padding(
                          padding: pageSurroundingPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price Summary',
                                style: textTheme.titleMedium?.copyWith(
                                  fontFamily: 'lato',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildPriceRow(
                                label: 'Subtotal',
                                value:
                                    '$currency${subtotalVal.toStringAsFixed(2)}',
                              ),
                              if (discountVal > 0)
                                _buildPriceRow(
                                  label: 'Discount',
                                  value:
                                      '-$currency${discountVal.toStringAsFixed(2)}',
                                  textColor: Colors.green,
                                ),
                              _buildPriceRow(
                                label: 'Shipping Charges',
                                value: shippingVal > 0
                                    ? '$currency${shippingVal.toStringAsFixed(2)}'
                                    : 'FREE',
                                textColor: shippingVal == 0
                                    ? Colors.green
                                    : null,
                              ),
                              const Divider(height: 20),
                              _buildPriceRow(
                                label: 'Total Amount',
                                value:
                                    '$currency${totalVal.toStringAsFixed(2)}',
                                isBold: true,
                              ),
                              if (isCod) ...[
                                _buildPriceRow(
                                  label: 'Amount Paid',
                                  value:
                                      '$currency${amountPaid.toStringAsFixed(2)}',
                                  textColor: Colors.green,
                                ),
                                _buildPriceRow(
                                  label: 'Payable on Delivery',
                                  value:
                                      '$currency${pendingAmount.toStringAsFixed(2)}',
                                  isBold: true,
                                  textColor: pendingAmount > 0
                                      ? Colors.amber.shade900
                                      : Colors.green,
                                ),
                              ],
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Continue Shopping Button
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
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
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Continue Shopping',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'lato',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

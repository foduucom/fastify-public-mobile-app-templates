import 'package:flutter/material.dart';
import '/app/modules/orderResponse/controllers/ordersucess_controller.dart';
import '/app/routes/app_pages.dart';
import '/components/order_product_image.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';

class OrdersucessView extends GetView<OrderSuccessController> {
  const OrdersucessView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(Routes.BOTTOMBAR);
        return false;
      },
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: Text('Order confirmation'.tr),
          centerTitle: false,
          elevation: 0,
          backgroundColor: colors.surface,
          foregroundColor: colors.onSurface,
          surfaceTintColor: Colors.transparent,
        ),
        body: Obx(() {
          final hasOrder = controller.item.isNotEmpty;
          if (controller.isLoading.value && !hasOrder) {
            return Center(child: HelperFunctions().loadingIndicator());
          }
          if (!hasOrder) return _emptyOrderState(context);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _successHeader(context),
              if (controller.isLoading.value) ...[
                const SizedBox(height: 10),
                const LinearProgressIndicator(minHeight: 2),
              ],
              if (controller.detailsRefreshFailed.value) ...[
                const SizedBox(height: 10),
                _refreshNotice(context),
              ],
              const SizedBox(height: 14),
              _orderCard(context),
              if (controller.item['products'] is List &&
                  (controller.item['products'] as List).isNotEmpty) ...[
                const SizedBox(height: 12),
                _productsCard(context),
              ],
              if (controller.address.isNotEmpty) ...[
                const SizedBox(height: 12),
                _addressCard(context),
              ],
              if (_hasPriceData(controller.item)) ...[
                const SizedBox(height: 12),
                _priceCard(context),
              ],
            ],
          );
        }),
        bottomNavigationBar: Obx(() => controller.item.isEmpty
            ? const SizedBox.shrink()
            : _bottomActions(context)),
      ),
    );
  }

  Widget _emptyOrderState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.receipt_long_outlined, size: 44, color: colors.primary),
          const SizedBox(height: 12),
          Text('Order details are unavailable'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 6),
          Text('You can find the order in your order history.'.tr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  )),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => Get.offAllNamed(Routes.BOTTOMBAR),
            child: Text('Continue shopping'.tr),
          ),
        ]),
      ),
    );
  }

  Widget _refreshNotice(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer.withOpacity(0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(Icons.cloud_off_outlined,
            color: colors.onErrorContainer, size: 18),
        const SizedBox(width: 9),
        Expanded(
          child: Text('Showing the order information available right now.'.tr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onErrorContainer,
                  )),
        ),
        TextButton(
          onPressed: controller.OrderDetail,
          child: Text('Retry'.tr),
        ),
      ]),
    );
  }

  Widget _bottomActions(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final item = controller.item;
    final currency = (item['currency'] ?? '₹').toString();
    final total =
        HelperFunctions.parseAmount(item['total'] ?? item['subtotal']);
    final hasPrice = _hasPriceData(item);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outlineVariant)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark
                      ? 0.22
                      : 0.06),
              blurRadius: 14,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(children: [
          Expanded(
            child: hasPrice
                ? TextButton(
                    onPressed: () => _showPriceDetails(context),
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Total'.tr,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: colors.onSurfaceVariant)),
                        Text(_money(currency, total),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w800,
                                )),
                        Text('View price details'.tr,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                )),
                      ],
                    ),
                  )
                : Text('Order received'.tr,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        )),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () => Get.offAllNamed(Routes.BOTTOMBAR),
                child: Text('Continue shopping'.tr),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  bool _hasPriceData(Map item) =>
      item['total'] != null ||
      item['subtotal'] != null ||
      item['grand_total'] != null ||
      item['total_amount'] != null ||
      (item['products'] is List && (item['products'] as List).isNotEmpty);

  void _showPriceDetails(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: _priceCard(context),
        ),
      ),
    );
  }

  Widget _successHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const successColor = Color(0xFF168B67);
    final markColor = controller.isPaymentFailed
        ? colors.error
        : (controller.isCashOrder || controller.isPaymentConfirmed
            ? successColor
            : colors.primary);
    final heading = controller.isCashOrder || controller.isPaymentConfirmed
        ? 'Order placed successfully!'
        : controller.isPaymentFailed
            ? 'Payment needs attention'
            : 'Order received';
    final message = controller.isCashOrder
        ? 'Your order is confirmed. We’ll collect payment on delivery.'
        : controller.isPaymentConfirmed
            ? 'Your payment is confirmed and your order is being processed.'
            : controller.isPaymentFailed
                ? 'Your order was created, but payment was not confirmed. Check your order status before trying again.'
                : 'Your order is received. Payment status is awaiting confirmation.';

    final orderNumber = _customerOrderNumber(controller.item['order_no']);
    final icon = controller.isPaymentFailed
        ? Icons.error_outline_rounded
        : (controller.isCashOrder || controller.isPaymentConfirmed
            ? Icons.check_rounded
            : Icons.hourglass_top_rounded);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: markColor.withOpacity(
            Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: markColor.withOpacity(0.28)),
      ),
      child: Column(children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: markColor.withOpacity(0.16),
          ),
          child: Icon(icon, size: 34, color: markColor),
        ),
        const SizedBox(height: 14),
        Text(heading.tr,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                )),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(message.tr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.45,
                  )),
        ),
        if (orderNumber != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: colors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text('Order #$orderNumber',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    )),
          ),
        ],
      ]),
    );
  }

  Widget _orderCard(BuildContext context) {
    final item = controller.item;
    final colors = Theme.of(context).colorScheme;
    final orderNumber = _customerOrderNumber(item['order_no']);
    final paymentMethod = _paymentLabel(
      item['payment_method'] ?? item['primary_method'],
      controller.isCashOrder,
    );
    final status = controller.isPaymentFailed
        ? 'PAYMENT FAILED'
        : controller.isPaymentConfirmed
            ? 'PAID'
            : controller.isCashOrder
                ? 'PENDING'
                : 'PROCESSING';
    // Only show known customer-facing order states. Some APIs use `status`
    // for internal values or IDs, so it must not be used as a display fallback.
    final orderStatus =
        _orderStatus(item['order_status'] ?? item['orderStatus']);
    final statusColor = controller.isPaymentFailed
        ? colors.error
        : controller.isPaymentConfirmed
            ? const Color(0xFF168B67)
            : (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFFFBBF24)
                : const Color(0xFFB45309));

    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      orderNumber == null
                          ? 'Order confirmed'.tr
                          : 'Order #$orderNumber',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                  const SizedBox(height: 3),
                  Text('Your order has been received'.tr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          )),
                ],
              ),
            ),
            _statusPill(context, orderStatus, colors.primary),
          ]),
          const SizedBox(height: 14),
          Divider(
              height: 1,
              thickness: 1,
              color: colors.outlineVariant.withOpacity(0.45)),
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.credit_card_outlined,
                size: 18, color: colors.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_humanize(paymentMethod).tr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
            ),
            _statusPill(context, status, statusColor),
          ]),
        ],
      ),
    );
  }

  Widget _addressCard(BuildContext context) {
    final address = controller.address;
    final city = _addressValue(address['city']);
    final state = _addressValue(address['state']);
    final country = _addressValue(address['country']);
    final locality = [city, state, country]
        .where((value) => value.trim().isNotEmpty)
        .join(', ');
    final street = _addressValue(address['address'] ?? address['street']);
    final landmark = _addressValue(address['landmark']);
    final addressLine =
        [street, landmark].where((value) => value.trim().isNotEmpty).join(', ');
    final lines = <String>[
      (address['name'] ?? '').toString(),
      addressLine,
      locality,
      address['pincode'] == null
          ? ''
          : '${'Pincode'.tr}: ${address['pincode']}',
      address['mobile'] == null ? '' : '${'Mobile'.tr}: ${address['mobile']}',
    ].where((line) => line.trim().isNotEmpty).toList();

    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
              context, Icons.location_on_outlined, 'Delivery address'.tr),
          const SizedBox(height: 12),
          if (lines.isEmpty)
            Text('Delivery address unavailable'.tr,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ))
          else
            ...lines.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(entry.value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: entry.key == 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                            height: 1.4,
                          )),
                )),
        ],
      ),
    );
  }

  Widget _productsCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final products = controller.item['products'] as List;
    final currency = (controller.item['currency'] ?? '₹').toString();
    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, Icons.shopping_bag_outlined,
              '${'Items'.tr} (${products.length})'),
          const SizedBox(height: 14),
          ...products.whereType<Map>().toList().asMap().entries.map((entry) {
            final product = entry.value;
            final nested = product['product_id'] ?? product['product'];
            final name = product['name'] ??
                (nested is Map ? nested['name'] : null) ??
                'Product'.tr;
            final quantity = product['qty'] ?? product['quantity'] ?? 1;
            final unitPrice = HelperFunctions.parseAmount(
                product['unit_price'] ??
                    product['price'] ??
                    (nested is Map ? nested['price'] : null));
            final lineTotal = HelperFunctions.parseAmount(
                        product['total'] ?? product['line_total']) >
                    0
                ? HelperFunctions.parseAmount(
                    product['total'] ?? product['line_total'])
                : unitPrice * (double.tryParse(quantity.toString()) ?? 1);
            return Padding(
              padding: EdgeInsets.only(
                  bottom: entry.key == products.length - 1 ? 0 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ColoredBox(
                      color: colors.surface,
                      child: OrderProductImage(
                        orderLine: product,
                        width: 64,
                        height: 64,
                        radius: 12,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name.toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w700,
                                )),
                        const SizedBox(height: 5),
                        Text('${'Quantity'.tr}: $quantity',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(_money(currency, lineTotal),
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _priceCard(BuildContext context) {
    final item = controller.item;
    final currency = (item['currency'] ?? '₹').toString();
    final rawTotal =
        item['total'] ?? item['grand_total'] ?? item['total_amount'];
    final shipping = HelperFunctions.parseAmount(
        item['shipping_charges'] ?? item['shipping']);
    final discount = HelperFunctions.parseAmount(item['discount']);
    final tax = HelperFunctions.parseAmount(item['tax_amount'] ?? item['tax']);
    final rawSubtotal = item['subtotal'] ?? item['sub_total'];
    final subtotal = rawSubtotal == null
        ? (rawTotal == null
            ? 0.0
            : (HelperFunctions.parseAmount(rawTotal) -
                    shipping -
                    tax +
                    discount)
                .clamp(0.0, double.infinity)
                .toDouble())
        : HelperFunctions.parseAmount(rawSubtotal);
    final total = rawTotal == null
        ? subtotal + shipping + tax - discount
        : HelperFunctions.parseAmount(rawTotal);
    final rawAmountPaid =
        item['amount_paid'] ?? item['paid_amount'] ?? item['amountPaid'];
    final amountPaid = rawAmountPaid == null
        ? (controller.isPaymentConfirmed ? total : 0.0)
        : HelperFunctions.parseAmount(rawAmountPaid);
    final rawAmountDue = item['amount_due'] ??
        item['payable_on_delivery'] ??
        item['pending_amount'] ??
        item['pendingAmount'];
    final amountDue = rawAmountDue == null
        ? (controller.isPaymentConfirmed
            ? 0.0
            : (controller.isCashOrder
                ? total
                : (total - amountPaid).clamp(0.0, total).toDouble()))
        : HelperFunctions.parseAmount(rawAmountDue);

    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
              context, Icons.receipt_long_outlined, 'Price summary'.tr),
          const SizedBox(height: 14),
          _priceRow(context, 'Subtotal'.tr, _money(currency, subtotal)),
          const SizedBox(height: 8),
          _priceRow(context, 'Shipping',
              shipping <= 0 ? 'FREE'.tr : _money(currency, shipping),
              valueColor: shipping <= 0 ? Colors.green : null),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _priceRow(context, 'Discount'.tr, '-${_money(currency, discount)}',
                valueColor: Colors.green),
          ],
          if (tax > 0) ...[
            const SizedBox(height: 8),
            _priceRow(context, 'Tax'.tr, _money(currency, tax)),
          ],
          const SizedBox(height: 12),
          Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withOpacity(0.45)),
          const SizedBox(height: 12),
          _priceRow(context, 'Total amount'.tr, _money(currency, total),
              strong: true),
          if (amountPaid > 0 || amountDue > 0) ...[
            const SizedBox(height: 8),
            _priceRow(context, 'Amount paid'.tr, _money(currency, amountPaid),
                valueColor: Colors.green),
            const SizedBox(height: 8),
            _priceRow(
                context,
                controller.isCashOrder
                    ? 'Payable on delivery'.tr
                    : 'Amount due'.tr,
                _money(currency, amountDue),
                valueColor: Colors.orange.shade800,
                strong: true),
          ],
        ],
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.3)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(BuildContext context, IconData icon, String title) {
    final colors = Theme.of(context).colorScheme;
    return Row(children: [
      Icon(icon, size: 18, color: colors.primary),
      const SizedBox(width: 8),
      Text(title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              )),
    ]);
  }

  Widget _statusPill(BuildContext context, String label, Color color) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              )),
    );
  }

  Widget _priceRow(BuildContext context, String label, String value,
      {bool strong = false, Color? valueColor}) {
    final colors = Theme.of(context).colorScheme;
    return Row(children: [
      Expanded(
        child: Text(label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: strong ? colors.onSurface : colors.onSurfaceVariant,
                  fontWeight: strong ? FontWeight.w700 : FontWeight.normal,
                )),
      ),
      Text(value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor ?? colors.onSurface,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
              )),
    ]);
  }

  String _addressValue(dynamic value) => value is Map
      ? (value['name'] ?? value['label'] ?? value['value'] ?? '').toString()
      : (value ?? '').toString();

  String? _customerOrderNumber(dynamic value) {
    final number = value?.toString().trim() ?? '';
    final looksLikeMongoId =
        RegExp(r'^[a-f0-9]{24}$', caseSensitive: false).hasMatch(number);
    if (number.isEmpty || looksLikeMongoId) {
      return null;
    }
    return number;
  }

  String _orderStatus(dynamic value) {
    final raw = value is Map
        ? (value['name'] ?? value['label'] ?? value['status'] ?? value['value'])
        : value;
    final normalized = (raw ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[_-]+'), ' ');
    const labels = <String, String>{
      'pending': 'PENDING',
      'processing': 'PROCESSING',
      'confirmed': 'CONFIRMED',
      'received': 'RECEIVED',
      'shipped': 'SHIPPED',
      'out for delivery': 'OUT FOR DELIVERY',
      'delivered': 'DELIVERED',
      'completed': 'COMPLETED',
      'complete': 'COMPLETED',
      'cancelled': 'CANCELLED',
      'canceled': 'CANCELLED',
    };
    return labels[normalized] ?? 'PROCESSING';
  }

  String _paymentLabel(dynamic method, bool isCashOrder) {
    final raw = method is Map
        ? (method['name'] ??
            method['label'] ??
            method['method'] ??
            method['value'])
        : method;
    final normalized = (raw ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[_-]+'), ' ');
    if (normalized.isEmpty || normalized == 'cod' || normalized == 'cash') {
      return isCashOrder || normalized.isNotEmpty
          ? 'Cash on delivery'
          : 'Online payment';
    }
    return _humanize(normalized);
  }

  String _money(String currency, double value) =>
      '$currency${value.toStringAsFixed(2)}';

  String _humanize(String value) => value
      .toLowerCase()
      .split(' ')
      .map((word) =>
          word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

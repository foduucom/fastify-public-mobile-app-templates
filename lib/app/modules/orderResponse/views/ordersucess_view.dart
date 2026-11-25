import 'package:flutter/material.dart';
import '../controllers/ordersucess_controller.dart';
import '/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '/constants/dynamic_theme.dart';
import '/constants/helper_functions.dart';

class OrdersucessView extends GetView<OrderSuccessController> {
  OrdersucessView({Key? key}) : super(key: key);

  @override
  final controller = Get.put(OrderSuccessController());

  Widget _statusBadge(String text, Color background, Color foreground,
      {Color? border}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Text(text.toUpperCase(),
          style: TextStyle(
              color: foreground,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: .45)),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 9),
      Text(title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              )),
    ]);
  }

  Widget _card(BuildContext context, Widget child) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .55)),
      ),
      child: child,
    );
  }

  Widget _priceRow(BuildContext context, String label, String value,
      {bool strong = false, Color? valueColor}) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: TextStyle(
                  fontSize: strong ? 15 : 14,
                  fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
                  color: colors.onSurfaceVariant,
                ))),
        const SizedBox(width: 12),
        Text(value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: strong ? 16 : 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? colors.onSurface,
            )),
      ]),
    );
  }

  String _addressValue(dynamic value) {
    final displayValue = value is Map
        ? (value['name'] ?? '').toString().trim()
        : (value ?? '').toString().trim();
    if (RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(displayValue)) return '';
    return displayValue;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(Routes.BOTTOMBAR);
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Order Placed',
              style: TextStyle(fontWeight: FontWeight.w700)),
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: colors.surface,
          surfaceTintColor: Colors.transparent,
        ),
        body: Obx(() {
          final rawData = controller.item['data'];
          final orderData = rawData is Map ? rawData : controller.item;
          final hasItem = orderData is Map && orderData.isNotEmpty;

          if (controller.isLoading.value && !hasItem) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _successMark(colors),
                const SizedBox(height: 16),
                Text('Order placed successfully!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                if (controller.orderNo.value.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Order #${controller.orderNo.value}',
                      style: TextStyle(color: colors.onSurfaceVariant)),
                ],
                const SizedBox(height: 24),
                HelperFunctions().loadingIndicator(),
              ]),
            ));
          }

          if (!hasItem) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _successMark(colors),
                const SizedBox(height: 16),
                Text('Order placed successfully!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                if (controller.orderNo.value.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Order #${controller.orderNo.value}',
                      style: TextStyle(color: colors.onSurfaceVariant)),
                ],
                const SizedBox(height: 12),
                const Text('Your order confirmation is ready.'),
              ]),
            ));
          }

          dynamic read(String key) => orderData[key];
          double amount(dynamic value) => double.tryParse('${value ?? 0}') ?? 0;
          final method = (read('payment_method') ?? 'COD').toString();
          final isCod = method.toLowerCase() == 'cod';
          final paymentStatus =
              (read('payment_status') ?? (isCod ? 'PENDING' : 'PAID'))
                  .toString()
                  .toUpperCase();
          final currency = (read('currency') ?? '₹').toString();
          final total = amount(read('total'));
          final subtotal =
              amount(read('subtotal')) > 0 ? amount(read('subtotal')) : total;
          final discount = amount(read('discount'));
          final shipping = amount(read('shipping_charges') ?? read('shipping'));
          final payments =
              read('payments') is List ? read('payments') as List : <dynamic>[];
          var paid = 0.0;
          for (final payment in payments) {
            if (payment is Map &&
                ['paid', 'success', 'completed']
                    .contains('${payment['status']}'.toLowerCase())) {
              paid += amount(payment['amount']);
            }
          }
          if (payments.isEmpty && paymentStatus == 'PAID' && !isCod)
            paid = total;
          final pending = (total - paid).clamp(0.0, double.infinity);
          final orderNo =
              (read('order_no') ?? controller.orderNo.value).toString();
          final statusValue = read('status');
          final orderStatus = statusValue is Map
              ? (statusValue['name'] ?? 'Processing').toString()
              : (statusValue ?? 'Processing').toString();
          final address = read('address') is Map
              ? read('address') as Map
              : controller.address;
          final city = _addressValue(address['city']);
          final state = _addressValue(address['state']);
          final country = _addressValue(address['country']);
          final locality = [city, state, country]
              .where((value) => value.isNotEmpty)
              .join(', ');

          return Stack(children: [
            Positioned.fill(
                child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 116),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Column(children: [
                      _successMark(colors),
                      const SizedBox(height: 14),
                      Text('Order placed successfully!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                          isCod
                              ? 'Your order is confirmed. We’ll collect payment on delivery.'
                              : 'Your payment is confirmed and your order is being prepared.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant)),
                    ])),
                    const SizedBox(height: 22),
                    _card(
                        context,
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(
                                          orderNo.isEmpty
                                              ? 'Order details'
                                              : 'Order #$orderNo',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 5),
                                      Text('Your order has been received',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: colors.onSurfaceVariant)),
                                    ])),
                                const SizedBox(width: 8),
                                Flexible(
                                    child: _statusBadge(
                                        orderStatus,
                                        colors.primary.withValues(alpha: .1),
                                        colors.primary)),
                              ]),
                              const SizedBox(height: 14),
                              const Divider(height: 1),
                              const SizedBox(height: 14),
                              Row(children: [
                                Icon(Icons.payment_outlined,
                                    size: 19, color: colors.onSurfaceVariant),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                        isCod ? 'Cash on delivery' : method,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600))),
                                _statusBadge(
                                    isCod && pending > 0
                                        ? 'Pending'
                                        : paymentStatus,
                                    (isCod && pending > 0
                                            ? context.semanticColors.warning
                                            : context.semanticColors.success)
                                        .withValues(alpha: 0.14),
                                    isCod && pending > 0
                                        ? context.semanticColors.warning
                                        : context.semanticColors.success,
                                    border: (isCod && pending > 0
                                            ? context.semanticColors.warning
                                            : context.semanticColors.success)
                                        .withValues(alpha: 0.4)),
                              ]),
                            ])),
                    const SizedBox(height: 14),
                    _card(
                        context,
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle(context, 'Delivery address',
                                  Icons.location_on_outlined),
                              const SizedBox(height: 14),
                              if ((address['name'] ?? '').toString().isNotEmpty)
                                Text('${address['name']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                              if ((address['address'] ?? '')
                                  .toString()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('${address['address']}',
                                    style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                        height: 1.45)),
                              ],
                              if (locality.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(locality,
                                    style: TextStyle(
                                        color: colors.onSurfaceVariant)),
                              ],
                              if ((address['pincode'] ?? '')
                                  .toString()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 5),
                                Text('Pincode: ${address['pincode']}',
                                    style: TextStyle(
                                        color: colors.onSurfaceVariant)),
                              ],
                              if ((address['mobile'] ?? '')
                                  .toString()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text('Mobile: ${address['mobile']}',
                                    style: TextStyle(
                                        color: colors.onSurfaceVariant)),
                              ],
                            ])),
                    const SizedBox(height: 14),
                    _card(
                        context,
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle(context, 'Price summary',
                                  Icons.receipt_long_outlined),
                              const SizedBox(height: 12),
                              _priceRow(context, 'Subtotal',
                                  '$currency${subtotal.toStringAsFixed(2)}'),
                              if (discount > 0)
                                _priceRow(context, 'Discount',
                                    '-$currency${discount.toStringAsFixed(2)}',
                                    valueColor: context.semanticColors.success),
                              _priceRow(
                                  context,
                                  'Shipping',
                                  shipping > 0
                                      ? '$currency${shipping.toStringAsFixed(2)}'
                                      : 'FREE',
                                  valueColor: shipping == 0
                                      ? context.semanticColors.success
                                      : null),
                              const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Divider(height: 1)),
                              _priceRow(context, 'Total amount',
                                  '$currency${total.toStringAsFixed(2)}',
                                  strong: true),
                              if (isCod) ...[
                                _priceRow(context, 'Amount paid',
                                    '$currency${paid.toStringAsFixed(2)}',
                                    valueColor: context.semanticColors.success),
                                _priceRow(context, 'Payable on delivery',
                                    '$currency${pending.toStringAsFixed(2)}',
                                    strong: true,
                                    valueColor: pending > 0
                                        ? context.semanticColors.warning
                                        : context.semanticColors.success),
                              ],
                            ])),
                  ]),
            )),
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: BoxDecoration(color: colors.surface, boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: .08),
                        blurRadius: 12,
                        offset: const Offset(0, -3)),
                  ]),
                  child: SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Get.offAllNamed(Routes.BOTTOMBAR),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text('Continue shopping',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      )),
                )),
          ]);
        }),
      ),
    );
  }

  Widget _successMark(ColorScheme colors) => Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
            color: colors.secondary.withValues(alpha: .12),
            shape: BoxShape.circle),
        child: Icon(Icons.check_rounded, color: colors.secondary, size: 42),
      );
}

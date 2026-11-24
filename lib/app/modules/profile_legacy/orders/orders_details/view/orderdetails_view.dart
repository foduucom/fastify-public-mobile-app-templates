import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/components/order_product_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '/app/modules/profile_legacy/orders/orders_details/controller/orderdetails_controller.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import '/constants/theme.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class OrderdetailView extends GetView<OrderdetailController> {
  const OrderdetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: colors.surface,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            tooltip: 'Back'.tr,
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Details'.tr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        )),
                if (_customerOrderNumber(controller.item['order_no']) != null)
                  Text('#${_customerOrderNumber(controller.item['order_no'])}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          )),
              ],
            ),
          ),
          elevation: 0,
        ),
        body: Obx(
          () => controller.isLoading.value && controller.item.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : controller.item.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.receipt_long_outlined, size: 40),
                            const SizedBox(height: 12),
                            Text(controller.errorMessage.value),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: controller.OrderDetail,
                              child: Text('Retry'.tr),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      children: [
                        OrderTrackingCard(),
                        const SizedBox(height: 14),
                        PaymentSummaryCard(item: controller.item),
                        const SizedBox(height: 14),
                        PriceDetails(item: controller.item),
                        const SizedBox(height: 14),
                        ShippingAddress(
                          address: controller.item['address'],
                          mobileNo: _mobileNumber(controller.item),
                          paymentMethod: _displayValue(
                            controller.item['payment_method'] ??
                                controller.item['primary_method'],
                          ),
                          paymentStatus:
                              _displayValue(controller.item['payment_status']),
                        ),
                        const SizedBox(height: 14),
                        _OrderActions(controller: controller),
                      ],
                    ),
        ),
      ),
    );
  }

  String _mobileNumber(Map item) {
    final address = item['address'];
    final customer = item['customer'];
    return (address is Map ? address['mobile'] : null)?.toString() ??
        (customer is Map ? customer['mobile'] : null)?.toString() ??
        '';
  }
}

class OrderTrackingCard extends StatelessWidget {
  final OrderdetailController controller = Get.find<OrderdetailController>();

  OrderTrackingCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final item = controller.item;
      if (item.isEmpty) return const OrderTrackingShimmer();
      final colors = Theme.of(context).colorScheme;
      final status = _orderStatus(item);
      final stage = _orderStage(status);
      final isCancelled = status.contains('cancel') || status.contains('fail');
      final orderNumber = _customerOrderNumber(item['order_no']);
      final steps = [
        'Order Placed'.tr,
        'Confirmed'.tr,
        'Shipped'.tr,
        'Delivered'.tr
      ];
      final orderDate = item['created_at'] ?? item['createdAt'];

      return _OrderSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    orderNumber == null ? 'Order'.tr : 'Order #$orderNumber',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                  ),
                ),
                _StatusPill(
                  label: _prettyStatus(item['payment_status'] ?? 'Pending'),
                  tone: _paymentTone(item['payment_status']),
                  icon: Icons.payments_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusPill(
                  label: _prettyStatus(status),
                  tone: isCancelled ? _OrderTone.error : _OrderTone.primary,
                  icon: Icons.local_shipping_outlined,
                ),
                if ((item['payment_method'] ?? item['primary_method']) != null)
                  _StatusPill(
                    label: _prettyStatus(
                        item['payment_method'] ?? item['primary_method']),
                    tone: _OrderTone.neutral,
                    icon: Icons.credit_card_outlined,
                  ),
              ],
            ),
            if (orderDate != null) ...[
              const SizedBox(height: 10),
              Text('Placed ${_formatDate(orderDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      )),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Icon(Icons.local_shipping_outlined,
                    size: 16, color: colors.primary),
                const SizedBox(width: 8),
                Text('Order status'.tr,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        )),
                const Spacer(),
                Text(_prettyStatus(status),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isCancelled ? colors.error : colors.primary,
                          fontWeight: FontWeight.w700,
                        )),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: List.generate(steps.length, (index) {
                final complete = index == 0 || (!isCancelled && index <= stage);
                return Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: complete
                              ? colors.primary
                              : colors.surfaceContainerHighest,
                          border: Border.all(
                            color: complete
                                ? colors.primary
                                : colors.outlineVariant,
                          ),
                        ),
                        child: Icon(
                          complete ? Icons.check_rounded : Icons.circle,
                          size: complete ? 15 : 6,
                          color: complete ? colors.onPrimary : colors.outline,
                        ),
                      ),
                      if (index < steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: index < stage && !isCancelled
                                ? colors.primary
                                : colors.outlineVariant,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(steps.length, (index) {
                return Expanded(
                  child: Text(
                    steps[index],
                    textAlign: index == 0
                        ? TextAlign.left
                        : (index == steps.length - 1
                            ? TextAlign.right
                            : TextAlign.center),
                    maxLines: 2,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: index == 0 || (!isCancelled && index <= stage)
                              ? colors.onSurface
                              : colors.onSurfaceVariant,
                          fontWeight: !isCancelled && index == stage
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                  ),
                );
              }),
            ),
            if (isCancelled) ...[
              const SizedBox(height: 12),
              Text(_prettyStatus(status),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.error,
                        fontWeight: FontWeight.w600,
                      )),
            ],
          ],
        ),
      );
    });
  }
}

String _formatDate(dynamic value) {
  if (value == null) return '';
  final date = DateTime.tryParse(value.toString())?.toLocal();
  if (date == null) return value.toString();
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String _displayValue(dynamic value) {
  if (value is Map) {
    const preferredKeys = [
      'name',
      'label',
      'status',
      'method',
      'display_name',
      'title',
      'value',
    ];
    for (final key in preferredKeys) {
      final matches = value.entries.where(
        (entry) => entry.key.toString().toLowerCase() == key,
      );
      if (matches.isEmpty) continue;
      final candidate = matches.first.value;
      if (candidate != null && candidate is! Map && candidate is! List) {
        final text = candidate.toString().trim();
        if (text.isNotEmpty) return text;
      }
    }
    return '';
  }
  if (value is List) {
    return value.map(_displayValue).where((part) => part.isNotEmpty).join(', ');
  }
  return value?.toString().trim() ?? '';
}

String? _customerOrderNumber(dynamic value) {
  final number = _displayValue(value);
  if (number.isEmpty ||
      RegExp(r'^[0-9a-f]{24}$', caseSensitive: false).hasMatch(number)) {
    return null;
  }
  return number;
}

String _addressValue(dynamic value) {
  final display = _displayValue(value);
  if (RegExp(r'^[0-9a-f]{24}$', caseSensitive: false).hasMatch(display)) {
    return '';
  }
  return display;
}

String _orderStatus(Map item) {
  final explicitStatus =
      _displayValue(item['order_status'] ?? item['orderStatus']);
  if (explicitStatus.isNotEmpty) return explicitStatus.toLowerCase();
  final fallback = _displayValue(item['status']).toLowerCase();
  if ({'paid', 'unpaid', 'pending', 'failed', 'refunded'}.contains(fallback)) {
    return 'order placed';
  }
  return fallback.isEmpty ? 'order placed' : fallback;
}

int _orderStage(String status) {
  if (status.contains('deliver') || status.contains('complete')) return 3;
  if (status.contains('ship') ||
      status.contains('dispatch') ||
      status.contains('transit')) return 2;
  if (status.contains('confirm') ||
      status.contains('process') ||
      status.contains('pack')) return 1;
  return 0;
}

String _prettyStatus(dynamic value) {
  final raw = _displayValue(value);
  if (raw == null || raw.isEmpty) return 'Pending'.tr;
  return raw
      .replaceAll('_', ' ')
      .split(RegExp(r'\s+'))
      .map((word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
      .join(' ');
}

enum _OrderTone { success, warning, error, primary, neutral }

_OrderTone _paymentTone(dynamic value) {
  final status = _displayValue(value).toLowerCase();
  if (status == 'paid' || status == 'complete' || status == 'completed') {
    return _OrderTone.success;
  }
  if (status == 'failed' || status == 'cancelled' || status == 'canceled') {
    return _OrderTone.error;
  }
  return _OrderTone.warning;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(
      {required this.label, required this.tone, required this.icon});
  final String label;
  final _OrderTone tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = switch (tone) {
      _OrderTone.success =>
        dark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
      _OrderTone.warning =>
        dark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
      _OrderTone.error => colors.error,
      _OrderTone.primary => colors.primary,
      _OrderTone.neutral => colors.onSurfaceVariant,
    };
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: dark ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ]),
    );
  }
}

class _OrderSurface extends StatelessWidget {
  const _OrderSurface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: colors.outlineVariant.withValues(alpha: 0.65)),
      ),
      child: child,
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

class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({super.key, required this.item});
  final Map item;

  double _number(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final paymentStatus = _displayValue(item['payment_status']).toLowerCase();
    final paid = paymentStatus == 'paid' ||
        paymentStatus == 'success' ||
        paymentStatus == 'completed';
    final total = _number(item['total']);
    final payments =
        item['payments'] is List ? item['payments'] as List : const [];
    final explicitPaid =
        item['amount_paid'] ?? item['paid_amount'] ?? item['amountPaid'];
    final transactionPaid = payments.whereType<Map>().fold<double>(
      0,
      (sum, payment) {
        final status = _displayValue(payment['status']).toLowerCase();
        final transactionAmount =
            payment['amount'] ?? payment['total'] ?? payment['paid_amount'];
        if (status == 'paid' || (status == null && paid)) {
          return sum + _number(transactionAmount);
        }
        return sum;
      },
    );
    final amountPaid = explicitPaid != null
        ? _number(explicitPaid)
        : (paid ? total : transactionPaid);
    final pending = _number(item['pending_amount'] ?? item['pendingAmount']) > 0
        ? _number(item['pending_amount'] ?? item['pendingAmount'])
        : (total - amountPaid).clamp(0.0, total).toDouble();
    final method = _displayValue(
            item['payment_method'] ?? item['primary_method'] ?? 'Payment')
        .toUpperCase();

    return _OrderSurface(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionHeading(
            icon: Icons.credit_card_outlined, title: 'Payment Summary'.tr),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: _AmountTile(
              title: 'Amount paid'.tr,
              amount: amountPaid,
              tone: _OrderTone.success,
              icon: Icons.check_circle_outline,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _AmountTile(
              title: 'Pending amount'.tr,
              amount: pending,
              tone: pending > 0 ? _OrderTone.warning : _OrderTone.success,
              icon: pending > 0
                  ? Icons.schedule_rounded
                  : Icons.check_circle_outline,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: (paid ? const Color(0xFF22C55E) : const Color(0xFFF59E0B))
                .withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.15
                        : 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Icon(paid ? Icons.check_circle : Icons.info_outline,
                size: 17,
                color:
                    paid ? const Color(0xFF22C55E) : const Color(0xFFF59E0B)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                paid
                    ? 'Payment of ${_currency(amountPaid)} completed ($method).'
                    : 'Payment is ${_prettyStatus(item['payment_status'] ?? 'pending').toLowerCase()} ($method).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Text('Payment transactions'.tr,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                )),
        const SizedBox(height: 8),
        if (payments.isEmpty)
          Text(
              '$method • ${paid ? 'Paid'.tr : _prettyStatus(item['payment_status'] ?? 'pending')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ))
        else
          ...payments.whereType<Map>().map((payment) {
            final transactionStatus = _displayValue(payment['status']).isEmpty
                ? (item['payment_status'] ?? 'pending')
                : payment['status'];
            final rawAmount =
                payment['amount'] ?? payment['total'] ?? payment['paid_amount'];
            final amount = _number(rawAmount);
            final date = payment['paid_at'] ??
                payment['created_at'] ??
                payment['createdAt'];
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 17, color: colors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _displayValue(payment['method'] ??
                                payment['payment_method'] ??
                                method)
                            .toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(
                      label: _prettyStatus(transactionStatus),
                      tone: _paymentTone(transactionStatus),
                      icon: Icons.check,
                    ),
                  ]),
                  if (date != null || rawAmount != null) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Row(children: [
                        if (date != null)
                          Expanded(
                            child: Text(_formatDate(date),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: colors.onSurfaceVariant)),
                          ),
                        if (rawAmount != null)
                          Text('+ ${_currency(amount)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: const Color(0xFF22C55E),
                                    fontWeight: FontWeight.w700,
                                  )),
                      ]),
                    ),
                  ],
                ],
              ),
            );
          }),
      ]),
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile(
      {required this.title,
      required this.amount,
      required this.tone,
      required this.icon});
  final String title;
  final double amount;
  final _OrderTone tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = tone == _OrderTone.warning
        ? (dark ? const Color(0xFFFBBF24) : const Color(0xFFB45309))
        : (dark ? const Color(0xFF4ADE80) : const Color(0xFF15803D));
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: dark ? 0.14 : 0.08),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 7),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: color)),
          const SizedBox(height: 3),
          Text(_currency(amount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  )),
        ])),
      ]),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(children: [
      Container(
        width: 3,
        height: 18,
        decoration: BoxDecoration(
            color: colors.primary, borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 9),
      Icon(icon, size: 17, color: colors.primary),
      const SizedBox(width: 7),
      Text(title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              )),
    ]);
  }
}

String _currency(double value) => '₹${value.toStringAsFixed(2)}';

class _OrderActions extends StatelessWidget {
  const _OrderActions({required this.controller});
  final OrderdetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final colors = Theme.of(context).colorScheme;
      final paid =
          _displayValue(controller.item['payment_status']).toLowerCase() ==
              'paid';
      return Column(children: [
        if (paid)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: controller.downloading.value
                  ? null
                  : () => controller.downloadAndSavePDF(
                        (controller.item['_id'] ??
                                controller.item['id'] ??
                                controller.id.value)
                            .toString(),
                      ),
              icon: controller.downloading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download_rounded),
              label: Text('Download Invoice'.tr),
            ),
          ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => reviewModal(context, controller),
              icon: const Icon(CupertinoIcons.star, size: 18),
              label: Text('Rate product'.tr),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Get.toNamed(Routes.HELPANDSUPPORT),
              icon: const Icon(Icons.help_outline_rounded, size: 18),
              label: Text('Need help?'.tr),
              style:
                  OutlinedButton.styleFrom(foregroundColor: colors.onSurface),
            ),
          ),
        ]),
      ]);
    });
  }
}

class ShippingAddress extends StatelessWidget {
  const ShippingAddress({
    super.key,
    required this.address,
    required this.mobileNo,
    required this.paymentMethod,
    required this.paymentStatus,
  });

  final dynamic address;
  final String mobileNo;
  final String? paymentMethod;
  final String? paymentStatus;

  @override
  Widget build(BuildContext context) {
    final isAddressMap = address is Map;
    final colors = Theme.of(context).colorScheme;
    final lines = <String>[
      if (isAddressMap && (address['house_no'] ?? '').toString().isNotEmpty)
        address['house_no'].toString(),
      if (isAddressMap && _addressValue(address['address']).isNotEmpty)
        _addressValue(address['address']),
      if (isAddressMap &&
          [
            _addressValue(address['city']),
            _addressValue(address['state']),
            _addressValue(address['country']),
          ].where((part) => part.isNotEmpty).isNotEmpty)
        [
          _addressValue(address['city']),
          _addressValue(address['state']),
          _addressValue(address['country']),
        ].where((part) => part.isNotEmpty).join(', '),
      if (isAddressMap &&
          _addressValue(address['pincode'] ?? address['postal_code'])
              .isNotEmpty)
        _addressValue(address['pincode'] ?? address['postal_code']),
    ];
    return _OrderSurface(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: _SectionHeading(
              icon: Icons.location_on_outlined,
              title: 'Shipping details'.tr,
            ),
          ),
          if (paymentStatus != null)
            _StatusPill(
              label: _prettyStatus(paymentStatus),
              tone: _paymentTone(paymentStatus),
              icon: Icons.payments_outlined,
            ),
        ]),
        const SizedBox(height: 14),
        if (isAddressMap && _addressValue(address['name']).isNotEmpty)
          Text(_addressValue(address['name']),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  )),
        if (lines.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(lines.join('\n'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.45,
                  )),
        ] else
          Text('No address details available'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  )),
        if (mobileNo.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.phone_outlined,
                size: 16, color: colors.onSurfaceVariant),
            const SizedBox(width: 7),
            Text(mobileNo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    )),
          ]),
        ],
        if (paymentMethod != null && paymentMethod!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Divider(
              color: colors.outlineVariant.withValues(alpha: 0.6), height: 1),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 16, color: colors.primary),
            const SizedBox(width: 7),
            Text('Payment method: '.tr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    )),
            Expanded(
              child: Text(paymentMethod!.toUpperCase(),
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      )),
            ),
          ]),
        ],
      ]),
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
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          isTotal ? colors.onSurface : colors.onSurfaceVariant,
                      fontWeight: isTotal ? FontWeight.w800 : FontWeight.w400,
                    )),
          ),
          Text(
            '${isNegative ? '-' : ''}${_currency(amount.abs())}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: isTotal ? 17 : null,
                  fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                  color:
                      isNegative ? const Color(0xFF22C55E) : colors.onSurface,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = item['products'] is List ? item['products'] as List : [];
    final colors = Theme.of(context).colorScheme;

    double originalBagTotal = 0.0;
    double actualBagTotal = 0.0;
    for (var currentProduct in products) {
      if (currentProduct is Map) {
        final qty = _parseDouble(
            currentProduct['qty'] ?? currentProduct['quantity'] ?? 1);
        final unitPrice = _getUnitPrice(currentProduct);
        final originalPrice = _getOriginalPrice(currentProduct, unitPrice);
        originalBagTotal += originalPrice * qty;
        actualBagTotal += unitPrice * qty;
      }
    }

    double itemSavings = originalBagTotal - actualBagTotal;
    if (itemSavings < 0) itemSavings = 0.0;

    final discount = _parseDouble(item['discount'] ??
        (item['coupon'] is Map ? item['coupon']['discount_amount'] : null));
    final shippingCharges =
        _parseDouble(item['shipping_charges'] ?? item['shipping']);
    final taxAmount = _parseDouble(item['tax_amount']);
    // The server total is authoritative; the client calculation is a fallback
    // for older order payloads that do not include it.
    final total = _parseDouble(item['total']) > 0
        ? _parseDouble(item['total'])
        : actualBagTotal + taxAmount - discount + shippingCharges;

    return _OrderSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            icon: Icons.receipt_long_outlined,
            title: 'Price details'.tr,
          ),
          const SizedBox(height: 14),
          ListView.separated(
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                height: 1,
                color: colors.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            itemCount: products.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final currentProduct = products[index] is Map
                  ? products[index] as Map
                  : <String, dynamic>{};
              final unitPrice = _getUnitPrice(currentProduct);
              final originalPrice =
                  _getOriginalPrice(currentProduct, unitPrice);
              final hasDiscount = originalPrice > unitPrice && unitPrice > 0;
              final quantity =
                  (currentProduct['qty'] ?? currentProduct['quantity'] ?? 1);
              final product =
                  currentProduct['product_id'] ?? currentProduct['product'];
              final productName = currentProduct['name'] ??
                  (product is Map ? product['name'] : null) ??
                  'Product'.tr;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 74,
                      height: 74,
                      color: colors.surface,
                      child: OrderProductImage(
                        orderLine: currentProduct,
                        width: 74,
                        height: 74,
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
                        Text(productName.toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w700,
                                )),
                        const SizedBox(height: 6),
                        Text('${'Quantity'.tr}: $quantity',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    )),
                        const SizedBox(height: 5),
                        Wrap(spacing: 7, children: [
                          if (hasDiscount)
                            Text(_currency(originalPrice),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colors.onSurfaceVariant,
                                      decoration: TextDecoration.lineThrough,
                                    )),
                          Text(_currency(unitPrice),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w800,
                                  )),
                        ]),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Divider(
              height: 1, color: colors.outlineVariant.withValues(alpha: 0.65)),
          const SizedBox(height: 12),
          _buildPriceRow(
              context,
              'Subtotal'.tr,
              _parseDouble(item['subtotal']) > 0
                  ? _parseDouble(item['subtotal'])
                  : actualBagTotal),
          if (itemSavings > 0)
            _buildPriceRow(context, 'Product Savings'.tr, -itemSavings,
                isNegative: true),
          if (discount > 0)
            _buildPriceRow(context, 'discount'.tr, -discount, isNegative: true),
          if (shippingCharges > 0)
            _buildPriceRow(context, 'Delivery'.tr, shippingCharges),
          if (taxAmount > 0) _buildPriceRow(context, 'Tax'.tr, taxAmount),
          Divider(height: 1, thickness: 1.5, color: colors.outlineVariant),
          const SizedBox(height: 8),
          _buildPriceRow(context, 'Total Amount'.tr, total, isTotal: true),
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

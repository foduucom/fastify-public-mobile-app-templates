import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/components/order_product_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import '/app/modules/Profie/orders/orders_details/controller/orderdetails_controller.dart';
import '/app/routes/app_pages.dart';
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
            final orderNo =
                HelperFunctions.displayReferenceName(orderData['order_no']);
            return Text(
              orderNo.isNotEmpty ? 'Order #$orderNo' : 'Order Details',
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
              if (orderData['address'] != null || orderData['customer'] != null)
                ShippingAddress(
                  customerName: orderData['customer'] is Map
                      ? (orderData['customer']['name']?.toString() ?? '')
                      : '',
                  mobileNo: orderData['customer'] is Map
                      ? (orderData['customer']['mobile']?.toString() ?? '')
                      : '',
                  address: orderData['address'],
                  paymentMethod: (orderData['payment_method'] ?? '').toString(),
                  paymentStatus: (orderData['payment_status'] ?? '').toString(),
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
                    onPressed: () => controller.downloadAndSavePDF(
                        orderData['_id'] ?? controller.id.value),
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
    } else if (paymentStatus == 'PAID') {
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

          // COD Advisory Message (only when pending amount remains and not already marked paid)
          if (isCod && pendingAmount > 0 && paymentStatus != 'PAID') ...[
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
                  Icon(Icons.info_outline,
                      size: 16, color: Colors.amber.shade800),
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
    this.customerName = '',
    this.paymentMethod = '',
    this.paymentStatus = '',
  });

  final dynamic address;
  final String mobileNo;
  final String customerName;
  final String paymentMethod;
  final String paymentStatus;

  static bool _isPlaceholder(String val) {
    final s = val.trim().toUpperCase();
    return s.isEmpty ||
        s == 'NA' ||
        s == 'N/A' ||
        s == 'NULL' ||
        s == 'UNDEFINED' ||
        s == 'NONE' ||
        RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(val.trim());
  }

  static String _clean(dynamic val) {
    if (val == null) return '';
    final s = HelperFunctions.displayReferenceName(val).trim();
    return _isPlaceholder(s) ? '' : s;
  }

  @override
  Widget build(BuildContext context) {
    final Map? addressMap = address is Map ? address as Map : null;

    final String recipientName =
        _clean(addressMap?['name'] ?? customerName);
    final String phone = _clean(
        addressMap?['mobile'] ?? addressMap?['phone'] ?? mobileNo);
    final String houseNo = _clean(addressMap?['house_no']);
    final String street =
        _clean(addressMap?['address'] ?? addressMap?['street']);
    final String landmark = _clean(addressMap?['landmark']);
    final String city = _clean(addressMap?['city']);
    final String state = _clean(addressMap?['state']);
    final String pincode =
        _clean(addressMap?['pincode'] ?? addressMap?['postal_code']);

    final streetParts = [houseNo, street, landmark]
        .where((part) => part.isNotEmpty)
        .toList();
    final String streetLine = streetParts.join(', ');

    final localityParts =
        [city, state].where((part) => part.isNotEmpty).toList();
    String cityLine = localityParts.join(', ');
    if (pincode.isNotEmpty) {
      cityLine = cityLine.isNotEmpty ? '$cityLine - $pincode' : pincode;
    }

    final bool hasValidAddress = recipientName.isNotEmpty ||
        phone.isNotEmpty ||
        streetLine.isNotEmpty ||
        cityLine.isNotEmpty;

    final pStatus = paymentStatus.toUpperCase();
    final bool isPaid =
        pStatus == 'PAID' || pStatus == 'SUCCESS' || pStatus == 'COMPLETED';
    final Color statusBg =
        isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
    final Color statusTextColor =
        isPaid ? const Color(0xFF166534) : const Color(0xFF92400E);
    final Color statusBorder =
        isPaid ? const Color(0xFF86EFAC) : const Color(0xFFFCD34D);

    return Padding(
      padding: pageSurroundingPadding,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outline
                .withValues(alpha: 0.16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'shipping details'.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                if (paymentStatus.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusBorder),
                    ),
                    child: Text(
                      isPaid ? 'PAID' : paymentStatus.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusTextColor,
                        fontFamily: 'lato',
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (recipientName.isNotEmpty) ...[
              Text(
                recipientName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 4),
            ],
            if (phone.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.phone_outlined,
                      size: 15,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    phone,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (streetLine.isNotEmpty) ...[
              Text(
                streetLine,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 2),
            ],
            if (cityLine.isNotEmpty) ...[
              Text(
                cityLine,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            if (!hasValidAddress)
              Text(
                'No shipping address provided'.tr,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            if (paymentMethod.isNotEmpty) ...[
              const SizedBox(height: 12),
              Divider(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.12),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      size: 15,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Payment Method: '.tr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    paymentMethod.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
    final products =
        item['products'] is List ? item['products'] as List : const <dynamic>[];
    final currency = (item['currency'] ?? '₹').toString();
    final colors = Theme.of(context).colorScheme;
    double amount(dynamic value) =>
        double.tryParse(value?.toString() ?? '') ?? 0.0;
    final subtotal = amount(item['subtotal'] ?? item['sub_total']);
    final shipping = amount(item['shipping_charges'] ?? item['shipping']);
    final discount = amount(item['discount']);
    final total = amount(item['total']);

    Widget summaryRow(String label, double value,
        {bool strong = false, bool isDiscount = false}) {
      final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
            color: strong ? colors.onSurface : colors.onSurfaceVariant,
          );
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(child: Text(label, style: style)),
            Text(
              isDiscount
                  ? '-$currency${value.abs().toStringAsFixed(2)}'
                  : '$currency${value.toStringAsFixed(2)}',
              style: style,
            ),
          ],
        ),
      );
    }

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
          if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No product details available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ),
          ListView.separated(
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: products.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final currentProduct = products[index] is Map
                  ? products[index] as Map
                  : const <String, dynamic>{};
              final product = currentProduct['product_id'] is Map
                  ? currentProduct['product_id'] as Map
                  : currentProduct['product'] is Map
                      ? currentProduct['product'] as Map
                      : currentProduct;
              final name =
                  (currentProduct['name'] ?? product['name'] ?? 'Product')
                      .toString();
              final quantity = int.tryParse(
                    (currentProduct['qty'] ?? currentProduct['quantity'] ?? 1)
                        .toString(),
                  ) ??
                  1;
              final unitPrice = double.tryParse(
                    (currentProduct['unit_price'] ??
                            currentProduct['price'] ??
                            product['price'] ??
                            0)
                        .toString(),
                  ) ??
                  0;
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: colors.outline.withValues(alpha: 0.12)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OrderProductImage(
                      orderLine: currentProduct,
                      width: 86,
                      height: 86,
                      radius: 10,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${'Quantity'.tr}: $quantity',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$currency${unitPrice.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colors.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 5),
          if (products.isNotEmpty) ...[
            const Divider(height: 22),
            summaryRow('Subtotal'.tr, subtotal),
            if (shipping > 0) summaryRow('Shipping'.tr, shipping),
            if (discount > 0)
              summaryRow('Discount'.tr, discount, isDiscount: true),
            const Divider(height: 18),
            summaryRow('Total'.tr, total, strong: true),
          ],
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
                  child: Builder(
                      builder: (ctx) => Text('Submit'.toUpperCase(),
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/components/app_image_placeholder.dart';
import '/app/routes/app_pages.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';

class OrderProductsView extends StatelessWidget {
  const OrderProductsView({super.key});

  double _amount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(
            value?.toString().replaceAll(',', '').replaceAll('₹', '').trim() ??
                '') ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    final rawArguments = Get.arguments;
    final args = rawArguments is Map ? rawArguments : const {};
    final rawOrder = args['order'] ?? args['data'] ?? rawArguments;
    final orderValue = rawOrder is Map && rawOrder['order'] is Map
        ? rawOrder['order']
        : rawOrder;
    final Map order = orderValue is Map ? orderValue : const {};

    if (order.isEmpty) {
      final colors = Theme.of(context).colorScheme;
      return Scaffold(
        appBar: AppBar(title: Text('OrderDetails'.tr)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.receipt_long_outlined, size: 44),
                const SizedBox(height: 12),
                Text(
                  'Order details are unavailable. Open this order from order history.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: Get.back,
                  child: Text('Back'.tr),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final orderId = (order['order_no'] ?? order['_id'] ?? '').toString();
    final mongoId = (order['_id'] ?? order['id'] ?? '').toString();
    final rawPaymentStatus = order['payment_status']?.toString() ?? 'pending';
    final paymentMethod =
        (order['payment_method'] ?? order['primary_method'] ?? '')
            .toString()
            .toLowerCase();
    final paymentStatus = (paymentMethod == 'cod' || paymentMethod == 'cash') &&
            rawPaymentStatus.toLowerCase() == 'pending'
        ? 'COD - Pending'
        : rawPaymentStatus;
    final currency = (order['currency'] ?? '₹').toString();
    final total = _amount(
        order['total'] ?? order['grand_total'] ?? order['total_amount']);
    final subtotal = _amount(order['subtotal'] ?? order['sub_total']);
    final discount = _amount(order['discount'] ?? order['coupon_discount']);
    final tax = _amount(order['tax'] ?? order['tax_amount']);
    final shippingValue = order['shipping_charges'] ??
        order['shipping'] ??
        order['delivery_charge'];
    final shipping = _amount(shippingValue);
    final displayPaymentMethod = paymentMethod.toUpperCase();
    final notes = (order['notes'] ?? '').toString();
    final orderDate = (order['created_at'] ?? order['createdAt']) != null
        ? HelperFunctions().toCarbonToHumanDateFormat(
            (order['created_at'] ?? order['createdAt']).toString())
        : '';

    final address = order['address'] is Map ? order['address'] as Map : null;

    final List<dynamic> products =
        (order['products'] is List) ? order['products'] as List : [];

    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final height = Get.height;

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          'OrderDetails'.tr,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: height * 0.025,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: mongoId.isEmpty
                ? null
                : () => Get.toNamed(
                      Routes.ORDER_DETAILS,
                      arguments: {'id': mongoId, 'order': order},
                    ),
            child: Text(
              'View Details'.tr,
              style: TextStyle(
                color: theme.primary,
                fontSize: 13,
                fontFamily: 'lato',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        children: [
          // ── Order Header ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.outline.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        orderId,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          fontFamily: 'lato',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _statusChip(paymentStatus, context),
                  ],
                ),
                if (orderDate.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 12,
                          color: theme.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 5),
                      Text(
                        orderDate,
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.onSurface.withValues(alpha: 0.45),
                          fontSize: 11,
                          fontFamily: 'lato',
                        ),
                      ),
                    ],
                  ),
                ],
                if (displayPaymentMethod.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.payment_outlined,
                          size: 12,
                          color: theme.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 5),
                      Text(
                        displayPaymentMethod,
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.onSurface.withValues(alpha: 0.45),
                          fontSize: 11,
                          fontFamily: 'lato',
                        ),
                      ),
                    ],
                  ),
                ],
                if (address != null) ...[
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 12,
                          color: theme.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          [
                            address['name'],
                            address['address'],
                            address['pincode'],
                          ]
                              .where(
                                  (e) => e != null && e.toString().isNotEmpty)
                              .join(', '),
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.onSurface.withValues(alpha: 0.45),
                            fontSize: 11,
                            fontFamily: 'lato',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Products Header ───────────────────────────────────────────────
          Row(
            children: [
              Text(
                'PurchasedProducts'.tr,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${products.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.primary,
                    fontFamily: 'lato',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Products List ─────────────────────────────────────────────────
          ...products
              .map((prod) => _ProductTile(product: prod, currency: currency)),

          const SizedBox(height: 18),

          // ── Price Breakdown ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.outline.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PriceBreakdown'.tr,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const SizedBox(height: 10),
                _amountRow(context, 'Subtotal'.tr,
                    '$currency ${subtotal.toStringAsFixed(2)}'),
                if (discount > 0)
                  _amountRow(
                    context,
                    'Discount'.tr,
                    '-$currency ${discount.toStringAsFixed(2)}',
                    valueColor: const Color(0xFF3BC24F),
                  ),
                if (tax > 0)
                  _amountRow(
                      context, 'Tax'.tr, '$currency ${tax.toStringAsFixed(2)}'),
                if (shippingValue != null)
                  _amountRow(
                      context,
                      'Shipping'.tr,
                      shipping == 0
                          ? 'FREE'.tr
                          : '$currency ${shipping.toStringAsFixed(2)}'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                      height: 1, color: theme.outline.withValues(alpha: 0.25)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total'.tr,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: 'lato',
                      ),
                    ),
                    Text(
                      '$currency ${total.toStringAsFixed(2)}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: theme.primary,
                        fontFamily: 'lato',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Notes ─────────────────────────────────────────────────────────
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9A825).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFFF9A825).withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.sticky_note_2_outlined,
                      size: 14,
                      color: const Color(0xFFF9A825).withValues(alpha: 0.8)),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      notes,
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.onSurface.withValues(alpha: 0.65),
                        fontSize: 12,
                        fontFamily: 'lato',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _amountRow(BuildContext context, String label, String value,
      {Color? valueColor}) {
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: theme.onSurface.withValues(alpha: 0.5),
              fontSize: 12,
              fontFamily: 'lato',
            ),
          ),
          Text(
            value,
            style: textTheme.bodySmall?.copyWith(
              color: valueColor ?? theme.onSurface.withValues(alpha: 0.65),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'lato',
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status, BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'paid':
      case 'completed':
        color = const Color(0xFF3BC24F);
        break;
      case 'pending':
      case 'unpaid':
      case 'processing':
        color = const Color(0xFFF9A825);
        break;
      case 'cancelled':
      case 'failed':
        color = theme.error;
        break;
      default:
        color = theme.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status.tr,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontFamily: 'lato',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single Product Row ─────────────────────────────────────────────────────────

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.currency});

  final dynamic product;
  final String currency;

  String? _extractImageUrl(dynamic product) {
    try {
      if (product is! Map) return null;
      final productObj = product['product_id'] ?? product['product'];
      final directImage = product['image'] ?? product['featured_image'];
      if (directImage is Map || directImage is List) {
        return HelperFunctions().getImage(directImage);
      }
      if (directImage is String &&
          directImage.isNotEmpty &&
          !RegExp(r'^[a-f0-9]{24}$').hasMatch(directImage)) {
        return HelperFunctions().getImage(directImage);
      }

      if (productObj is Map) {
        final fi = productObj['featured_image'];
        if (fi is Map || fi is List) {
          return HelperFunctions().getImage(fi);
        }
        if (fi is String &&
            fi.isNotEmpty &&
            !RegExp(r'^[a-f0-9]{24}$').hasMatch(fi)) {
          return HelperFunctions().getImage(fi);
        }

        final frontImageId = productObj['front_image']?.toString() ?? '';
        final gallery = productObj['gallery'];

        if (gallery is List && frontImageId.isNotEmpty) {
          final match = gallery.firstWhere(
            (g) =>
                g is Map && (g['_id'] ?? g['id'])?.toString() == frontImageId,
            orElse: () => null,
          );
          if (match != null) return HelperFunctions().getImage(match);
        }
      }
    } catch (e) {
      debugPrint('Order product image resolution failed: ${e.runtimeType}');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final line = product is Map ? product as Map : const {};
    final productObj = line['product_id'] ?? line['product'];
    final name = (line['name'] ??
            (productObj is Map ? productObj['name'] : null) ??
            'Product')
        .toString();
    final qty = (line['qty'] ?? line['quantity'] ?? 1).toString();
    final unitAmount = line['unit_price'] ?? line['price'] ?? 0;
    final parsedUnitAmount = unitAmount is num
        ? unitAmount.toDouble()
        : double.tryParse(unitAmount.toString()) ?? 0;
    final unitPrice = parsedUnitAmount.toStringAsFixed(2);
    final lineTotal = line['total'] ??
        line['line_total'] ??
        (parsedUnitAmount * (double.tryParse(qty) ?? 1));

    final variant = line['variant'] ?? line['variant_id'];
    String variantLabel = '';
    if (variant is Map) {
      final attrs = variant['attributes'];
      if (attrs is Map) {
        variantLabel =
            attrs.entries.map((e) => '${e.key}: ${e.value}').join('  ·  ');
      } else if (attrs is List) {
        variantLabel = attrs
            .whereType<Map>()
            .map((a) => '${a['name'] ?? 'Option'}: ${a['value'] ?? ''}')
            .join('  ·  ');
      }
    }

    final String? imageUrl = _extractImageUrl(product);

    // SKU: prefer variant sku, fall back to product_id sku
    final variantSku =
        (variant is Map ? variant['sku'] : null)?.toString().trim() ?? '';
    final productSku =
        (productObj is Map ? productObj['sku'] : null)?.toString().trim() ?? '';
    final sku = variantSku.isNotEmpty ? variantSku : productSku;

    // Product type: simple / variable / digital
    final productType = (productObj is Map ? productObj['type'] : null)
            ?.toString()
            .toLowerCase() ??
        '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // ── Product Image ──
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 62,
              height: 62,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 62,
                      height: 62,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _placeholder(theme),
                      errorWidget: (_, __, ___) {
                        debugPrint('Image failed to load: $imageUrl');
                        return _placeholder(theme);
                      },
                    )
                  : _placeholder(theme),
            ),
          ),

          const SizedBox(width: 12),

          // ── Product Info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    fontFamily: 'lato',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (variantLabel.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    variantLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.onSurface.withValues(alpha: 0.45),
                      fontSize: 11,
                      fontFamily: 'lato',
                    ),
                  ),
                ],
                if (sku.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code_rounded,
                          size: 11,
                          color: theme.onSurface.withValues(alpha: 0.35)),
                      const SizedBox(width: 4),
                      Text(
                        sku,
                        style: TextStyle(
                          color: theme.onSurface.withValues(alpha: 0.4),
                          fontSize: 10,
                          fontFamily: 'lato',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 5),
                Text(
                  '$currency $unitPrice × $qty',
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.onSurface.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontFamily: 'lato',
                  ),
                ),
                if (productType.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _typeBadge(productType, theme),
                ],
              ],
            ),
          ),

          // ── Line Total ──
          const SizedBox(width: 8),
          Text(
            '$currency ${_formatAmount(lineTotal)}',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: theme.primary,
              fontFamily: 'lato',
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(dynamic value) {
    if (value is num) return value.toStringAsFixed(2);
    final parsed = double.tryParse(value.toString());
    return parsed?.toStringAsFixed(2) ?? value.toString();
  }

  Widget _typeBadge(String type, ColorScheme theme) {
    // Each type maps to a universally recognisable icon + vivid colour
    // so the user understands at a glance — no jargon needed.
    const Color digitalColor = Color(0xFF6366F1); // indigo  → "cloud/digital"
    const Color variableColor =
        Color(0xFF0891B2); // cyan    → "customisable options"
    const Color simpleColor =
        Color(0xFF059669); // emerald → "ready / straightforward"

    final Color color;
    final IconData icon;
    final String label;

    switch (type) {
      case 'digital':
        color = digitalColor;
        icon = Icons.cloud_download_outlined;
        label = 'Digital';
        break;
      case 'variable':
        color = variableColor;
        icon = Icons.tune_rounded;
        label = 'Variants';
        break;
      case 'simple':
        color = simpleColor;
        icon = Icons.sell_outlined;
        label = 'In Stock';
        break;
      default:
        color = theme.onSurface.withValues(alpha: 0.35);
        icon = Icons.inventory_2_outlined;
        label = type;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontFamily: 'lato',
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(ColorScheme theme) => const AppImagePlaceholder(
        radius: 6,
        width: 62,
        height: 62,
        fit: BoxFit.contain,
      );
}

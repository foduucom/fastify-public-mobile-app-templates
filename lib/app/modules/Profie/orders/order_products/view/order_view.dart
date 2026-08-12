import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/app/routes/app_pages.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';

class OrderProductsView extends StatelessWidget {
  const OrderProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map? ?? {};
    final dynamic order = args['order'];

    final orderId = (order['order_no'] ?? order['_id'] ?? '').toString();
    final mongoId = (order['_id'] ?? order['id'] ?? '').toString();
    final paymentStatus = order['payment_status']?.toString() ?? 'pending';
    final currency = (order['currency'] ?? '₹').toString();
    final total = double.tryParse(order['total']?.toString() ?? '0') ?? 0;
    final subtotal = double.tryParse(order['subtotal']?.toString() ?? '0') ?? 0;
    final discount = double.tryParse(order['discount']?.toString() ?? '0') ?? 0;
    final tax = double.tryParse(order['tax']?.toString() ?? '0') ?? 0;
    final shipping =
        double.tryParse(order['shipping_charges']?.toString() ?? '0') ?? 0;
    final paymentMethod =
        (order['payment_method'] ?? '').toString().toUpperCase();
    final notes = (order['notes'] ?? '').toString();
    final orderDate = order['created_at'] != null
        ? HelperFunctions()
            .toCarbonToHumanDateFormat(order['created_at'].toString())
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
            onPressed: () =>
                Get.toNamed(Routes.ORDER_DETAILS, arguments: {'id': mongoId}),
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
                if (paymentMethod.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.payment_outlined,
                          size: 12,
                          color: theme.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 5),
                      Text(
                        paymentMethod,
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
                if (shipping > 0)
                  _amountRow(context, 'Shipping'.tr,
                      '$currency ${shipping.toStringAsFixed(2)}'),
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

  String _constructImageUrl(Map imageObj) {
    final filepath = imageObj['filepath']?.toString() ?? '';
    if (filepath.isNotEmpty) {
      final cleanPath =
          filepath.startsWith('/') ? filepath.substring(1) : filepath;
      return 'https://mywatch.vbought.com/images/$cleanPath';
    }
    final url = imageObj['download_url']?.toString() ?? '';
    return _fixImageUrl(url);
  }

  String _fixImageUrl(String url) {
    if (url.isEmpty) return '';
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    if (uri.host.endsWith('.vbought.com') &&
        uri.host != 'mywatch.vbought.com') {
      return url.replaceFirst(uri.host, 'mywatch.vbought.com');
    }
    return url;
  }

  String? _extractImageUrl(dynamic product) {
    try {
      final productObj = product['product_id'];

      if (productObj is Map) {
        final fi = productObj['featured_image'];
        if (fi is Map) {
          final url = _constructImageUrl(fi);
          if (url.isNotEmpty) return url;
        }

        final frontImageId = productObj['front_image']?.toString() ?? '';
        final gallery = productObj['gallery'];

        if (gallery is List && frontImageId.isNotEmpty) {
          final match = gallery.firstWhere(
            (g) =>
                g is Map && (g['_id'] ?? g['id'])?.toString() == frontImageId,
            orElse: () => null,
          );
          if (match != null) return _constructImageUrl(match);
        }
      }

      final directImage = product['image'] ?? product['featured_image'];
      if (directImage is Map) return _constructImageUrl(directImage);
      if (directImage is String && directImage.startsWith('http')) {
        return _fixImageUrl(directImage);
      }
    } catch (e) {
      debugPrint('Image extraction error: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final name = (product['name'] ?? '').toString();
    final qty = (product['qty'] ?? 1).toString();
    final unitPrice = (product['unit_price'] ?? 0).toString();
    final lineTotal = (product['total'] ?? 0).toString();

    final variant = product['variant'];
    String variantLabel = '';
    if (variant is Map) {
      final attrs = variant['attributes'];
      if (attrs is Map) {
        variantLabel =
            attrs.entries.map((e) => '${e.key}: ${e.value}').join('  ·  ');
      } else if (attrs is List) {
        variantLabel =
            attrs.map((a) => '${a['name']}: ${a['value']}').join('  ·  ');
      }
    }

    final String? imageUrl = _extractImageUrl(product);

    // SKU: prefer variant sku, fall back to product_id sku
    final productObj = product['product_id'];
    final variantSku =
        (product['variant'] is Map ? product['variant']['sku'] : null)
                ?.toString()
                .trim() ??
            '';
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
            child: Container(
              width: 62,
              height: 62,
              color: theme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 62,
                      height: 62,
                      fit: BoxFit.contain,
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
            '$currency $lineTotal',
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

  Widget _placeholder(ColorScheme theme) => Container(
        color: theme.surfaceContainerHighest.withValues(alpha: 0.5),
        child: Center(
          child: Icon(
            Icons.shopping_bag_outlined,
            color: theme.onSurface.withValues(alpha: 0.3),
            size: 24,
          ),
        ),
      );
}

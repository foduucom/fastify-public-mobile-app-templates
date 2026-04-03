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

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        title: Text('OrderDetails'.tr),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () =>
                Get.toNamed(Routes.ORDER_DETAILS, arguments: {'id': mongoId}),
            child: Text(
              'View Details'.tr,
              style: TextStyle(color: theme.primary, fontSize: 13),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        children: [
          //──OrderHeader──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.surfaceVariant.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _statusChip(paymentStatus, context),
                  ],
                ),
                if (orderDate.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    orderDate,
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.onSurface.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
                if (paymentMethod.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.payment_outlined,
                          size: 13, color: theme.onSurface.withOpacity(0.4)),
                      const SizedBox(width: 5),
                      Text(
                        paymentMethod,
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.onSurface.withOpacity(0.45),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
                //Address
                if (address != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13, color: theme.onSurface.withOpacity(0.4)),
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
                            color: theme.onSurface.withOpacity(0.45),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          //──ProductsHeader──
          Text(
            '${'PurchasedProducts'.tr} (${products.length})',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),

          //──ProductsList──
          ...products
              .map((prod) => _ProductTile(product: prod, currency: currency)),

          const SizedBox(height: 16),

          //──AmountBreakdown──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.surfaceVariant.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PriceBreakdown'.tr,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
                    valueColor: Colors.green.shade600,
                  ),
                if (tax > 0)
                  _amountRow(
                      context, 'Tax'.tr, '$currency ${tax.toStringAsFixed(2)}'),
                if (shipping > 0)
                  _amountRow(context, 'Shipping'.tr,
                      '$currency ${shipping.toStringAsFixed(2)}'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total'.tr,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$currency ${total.toStringAsFixed(2)}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          //──Notes──
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
                border:
                Border.all(color: Colors.amber.shade200.withOpacity(0.6)),
              ),
              child: Text(
                '📝 $notes',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade900.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
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
          Text(label,
              style: textTheme.bodySmall?.copyWith(
                color: theme.onSurface.withOpacity(0.5),
                fontSize: 12,
              )),
          Text(value,
              style: textTheme.bodySmall?.copyWith(
                color: valueColor ?? theme.onSurface.withOpacity(0.65),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }

  Widget _statusChip(String status, BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'paid':
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
      case 'unpaid':
      case 'processing':
        color = Colors.orange;
        break;
      case 'cancelled':
      case 'failed':
        color = Colors.red;
        break;
      default:
        color = Theme.of(context).colorScheme.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(status.tr,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

//──SingleProductRow──
class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.currency});

  final dynamic product;
  final String currency;

  // ─── URL Fixers ────────────────────────────────────────────────────────
  String _constructImageUrl(Map imageObj) {
    final filepath = imageObj['filepath']?.toString() ?? '';
    if (filepath.isNotEmpty) {
      final cleanPath = filepath.startsWith('/') ? filepath.substring(1) : filepath;
      return 'https://mywatch.vbought.com/images/$cleanPath';
    }
    final url = imageObj['download_url']?.toString() ?? '';
    return _fixImageUrl(url);
  }

  String _fixImageUrl(String url) {
    if (url.isEmpty) return '';
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    if (uri.host.endsWith('.vbought.com') && uri.host != 'mywatch.vbought.com') {
      return url.replaceFirst(uri.host, 'mywatch.vbought.com');
    }
    return url;
  }

  String? _extractImageUrl(dynamic product) {
    try {
      final productObj = product['product_id'];

      // Case 1: product_id is a fully populated Map
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
                (g) => g is Map && (g['_id'] ?? g['id'])?.toString() == frontImageId,
            orElse: () => null,
          );
          if (match != null) {
            return _constructImageUrl(match);
          }
        }
      }

      // Case 2: Top level direct image (fallback)
      final directImage = product['image'] ?? product['featured_image'];
      if (directImage is Map) {
        return _constructImageUrl(directImage);
      }
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

    // Variant label
    final variant = product['variant'];
    String variantLabel = '';
    if (variant is Map) {
      final attrs = variant['attributes'];
      if (attrs is Map) {
        // Safely handle map attributes
        variantLabel = attrs.entries.map((e) => '${e.key}: ${e.value}').join('   ·   ');
      } else if (attrs is List) {
        // Safely handle list attributes
        variantLabel = attrs.map((a) => '${a['name']}: ${a['value']}').join('   ·   ');
      }
    }

    final String? imageUrl = _extractImageUrl(product);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.outline.withOpacity(0.09)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Product Image ──
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 64,
              height: 64,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                // Show shimmer while loading
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: theme.surfaceVariant.withOpacity(0.4),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes !=
                              null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                          color: theme.primary.withOpacity(0.5),
                        ),
                      ),
                    ),
                  );
                },
                // On error: show placeholder
                errorBuilder: (context, error, stackTrace) {
                  debugPrint(
                      'Image failed to load: $imageUrl\nError: $error');
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
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (variantLabel.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    variantLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.onSurface.withOpacity(0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
                const SizedBox(height: 5),
                Text(
                  '$currency $unitPrice × $qty',
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.onSurface.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // ── Line Total ──
          Text(
            '$currency $lineTotal',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: theme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(ColorScheme theme) => Container(
    color: theme.surfaceVariant.withOpacity(0.4),
    child: Center(
      child: Icon(
        Icons.shopping_bag_outlined,
        color: theme.onSurfaceVariant.withOpacity(0.4),
        size: 26,
      ),
    ),
  );
}
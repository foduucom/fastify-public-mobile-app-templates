import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductGridCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;

  const ProductGridCard({Key? key, required this.product, required this.onTap})
      : super(key: key);

  String _getImageUrl() {
    final featuredImg = product['featured_image'];
    if (featuredImg != null && featuredImg is Map) {
      final downloadUrl = featuredImg['download_url']?.toString() ?? '';
      final filepath = featuredImg['filepath']?.toString() ?? '';
      if (downloadUrl.isNotEmpty) return downloadUrl;
      if (filepath.isNotEmpty) {
        final cleanPath =
            filepath.startsWith('/') ? filepath.substring(1) : filepath;
        return 'https://mywatch.vbought.com/images/$cleanPath';
      }
    }
    return '';
  }

  double _getPrice(String field) {
    final variants = product['variants'];
    if (variants == null) return 0.0;
    if (variants is List && variants.isNotEmpty) {
      final firstVariant = variants[0];
      if (firstVariant is Map) {
        return double.tryParse(firstVariant[field]?.toString() ?? '0') ?? 0.0;
      }
    }
    if (variants is Map) {
      return double.tryParse(variants[field]?.toString() ?? '0') ?? 0.0;
    }
    return 0.0;
  }

  int? _getQuantity() {
    final variants = product['variants'];
    if (variants == null) return null;
    if (variants is List && variants.isNotEmpty) {
      final firstVariant = variants[0];
      if (firstVariant is Map) {
        final quantityValue = firstVariant['quantity'];
        if (quantityValue == null) return null;
        return int.tryParse(quantityValue.toString());
      }
    }
    if (variants is Map) {
      final quantityValue = variants['quantity'];
      if (quantityValue == null) return null;
      return int.tryParse(quantityValue.toString());
    }
    return null;
  }

  bool _isOutOfStock() {
    final quantity = _getQuantity();
    return quantity != null && quantity <= 0;
  }

  bool _isStockLimited() {
    final quantity = _getQuantity();
    return quantity != null && quantity > 0;
  }

  Color _getBadgeColor(String type, ColorScheme colorScheme) {
    switch (type) {
      case 'trending':
        return Colors.purple.shade600;
      case 'recommended':
        return Colors.green.shade600;
      default:
        return colorScheme.primary;
    }
  }

  IconData _getBadgeIcon(String type) {
    switch (type) {
      case 'featured':
        return Icons.star;
      case 'hot':
        return Icons.local_fire_department;
      case 'trending':
        return Icons.trending_up;
      case 'recommended':
        return Icons.thumb_up;
      default:
        return Icons.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final String imageUrl = _getImageUrl();
    final String name = product['name']?.toString() ?? 'Unknown Product';

    final double price = _getPrice('price');
    final double salePrice = _getPrice('sale_price');
    final bool hasDiscount = salePrice > 0 && salePrice < price;

    final int? quantity = _getQuantity();
    final bool isOutOfStock = _isOutOfStock();
    final bool isLimitedStock = _isStockLimited();
    final bool isLowStock = isLimitedStock && quantity != null && quantity <= 10;

    final bool hot = product['hot'] ?? false;
    final bool trending = product['trending'] ?? false;

    final double displayPrice = hasDiscount ? salePrice : price;

    final List<String> activeBadges = <String, bool>{
      'hot': hot,
      'trend': trending,
    }.entries.where((e) => e.value).map((e) => e.key).toList();

    return InkWell(
      onTap: isOutOfStock ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOutOfStock
                ? colorScheme.error.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Section ──
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Container(
                      width: double.infinity,
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                  child: CupertinoActivityIndicator()),
                              errorWidget: (context, url, error) => Icon(
                                  Icons.image_not_supported_outlined,
                                  color: colorScheme.outline),
                            )
                          : Icon(Icons.image_not_supported_outlined,
                              color: colorScheme.outline),
                    ),
                  ),

                  // Out of Stock Overlay
                  if (isOutOfStock)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15)),
                        color: Colors.black.withValues(alpha: 0.7),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shopping_cart_outlined,
                                  size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'OUT OF STOCK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Badges
                  if (activeBadges.isNotEmpty && !isOutOfStock)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: activeBadges.map((badge) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _getBadgeColor(badge, colorScheme),
                                  _getBadgeColor(badge, colorScheme)
                                      .withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _getBadgeColor(badge, colorScheme)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getBadgeIcon(badge),
                                    size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  badge.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),

            // ── Details Section ──
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              color: isOutOfStock
                                  ? colorScheme.onSurfaceVariant
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hot && !isOutOfStock)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.star,
                                size: 16, color: Colors.amber.shade700),
                          ),
                      ],
                    ),

                    // Price Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (hasDiscount && !isOutOfStock)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              "₹${price.toStringAsFixed(2)}",
                              style: textTheme.bodyMedium?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        Text(
                          "₹${displayPrice.toStringAsFixed(2)}",
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isOutOfStock
                                ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                                : colorScheme.primary,
                          ),
                        ),
                        if (isLowStock && !isOutOfStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Low Stock',
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                      ],
                    ),

                    if (hasDiscount && price > 0 && !isOutOfStock)
                      Text(
                        "${((price - salePrice) / price * 100).round()}% off",
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

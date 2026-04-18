import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/constants/product_helper.dart';
import '/constants/helper_functions.dart';

class ProductGridCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;

  const ProductGridCard({Key? key, required this.product, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final String imageUrl = ProductHelper.getProductImage(product);
    final String name = ProductHelper.getProductName(product);
    final String storeName = product['storeName']?.toString() ?? '';
    final priceInfo = ProductHelper.calculatePriceInfo(product);
    final productType = priceInfo['productType'];
    final bool isOutOfStock = !priceInfo['hasValidVariants'];

    return InkWell(
      onTap: isOutOfStock ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 185 / 205,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (_, __, ___) =>
                          HelperFunctions().loadingIndicator(),
                      errorWidget: (_, __, ___) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.image_outlined,
                            color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),

                // Discount badge
                if (priceInfo['discountRate'] != null &&
                    priceInfo['discountRate'].toString().isNotEmpty)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        priceInfo['discountRate'].toString(),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onError,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Out of stock overlay
                if (isOutOfStock)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.55),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'OUT OF STOCK',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onError,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Info ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.2,
                        color: isOutOfStock
                            ? colorScheme.onSurfaceVariant
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (storeName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        storeName,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    if (!isOutOfStock)
                      productType == 'variable'
                          ? Text(
                              '₹${priceInfo['lowestPrice']} - ₹${priceInfo['highestPrice']}',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: colorScheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                text: '₹${priceInfo['productPrice']}',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: colorScheme.primary,
                                ),
                                children: [
                                  if (priceInfo['discountRate'] != null &&
                                      priceInfo['discountRate']
                                          .toString()
                                          .isNotEmpty) ...[
                                    const TextSpan(text: '  '),
                                    TextSpan(
                                      text: '₹${priceInfo['discountPrice']}',
                                      style: textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                        decoration:
                                            TextDecoration.lineThrough,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
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

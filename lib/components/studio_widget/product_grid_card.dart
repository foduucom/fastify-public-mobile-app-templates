import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';

/// Shared product grid card — image, wishlist toggle, discount/out-of-stock
/// badges, name, rating, price. Used by both the Shop tab and Search results
/// so the two screens don't maintain duplicate near-identical card widgets.
class ProductGridCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;

  const ProductGridCard({super.key, required this.product, required this.onTap});

  Widget _buildWishlistButton(BuildContext context, Map<String, dynamic> product) {
    final colorScheme = Theme.of(context).colorScheme;
    final productId = ProductHelper.getProductId(product);

    return GestureDetector(
      onTap: () => _handleWishlistTap(product),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: colorScheme.surface.withValues(alpha: 0.85),
        ),
        padding: const EdgeInsets.all(6.0),
        child: Obx(() {
          final isInWishlist = WishListService.to.isInWishlist(productId);
          return SvgPicture.asset(
            isInWishlist ? 'assets/icon/like.svg' : 'assets/icon/unlike.svg',
            width: 16,
            height: 16,
          );
        }),
      ),
    );
  }

  void _handleWishlistTap(Map<String, dynamic> product) async {
    final productId = ProductHelper.getProductId(product);
    String variantSlug = '';
    String? variantId;

    final variants = product['variants'];
    if (variants is List && variants.isNotEmpty) {
      final variant = variants[0];
      variantId = (variant['_id'] ?? variant['id'])?.toString();
      variantSlug = variant['slug'] ?? variant['variant_slug'] ?? '';
    }

    if (variantSlug.isEmpty) {
      variantSlug = product['variant_slug'] ?? product['slug'] ?? '';
    }

    await WishListService.to.toggleWishlist(
      productId: productId,
      variantSlug: variantSlug,
      variantId: variantId,
      productData: product,
    );
  }

  Widget _buildVariablePrice(BuildContext context, Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      '₹${priceInfo['lowestPrice']} - ₹${priceInfo['highestPrice']}',
      style: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildSimplePrice(BuildContext context, Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RichText(
      text: TextSpan(
        text: '₹${priceInfo['productPrice']}',
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
        children: [
          if (priceInfo['discountRate'] != null &&
              priceInfo['discountRate'].toString().isNotEmpty) ...[
            const TextSpan(text: '  '),
            TextSpan(
              text: '₹${priceInfo['salePrice']}',
              style: textTheme.bodySmall?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final productName = ProductHelper.getProductName(product);
    final imageUrl = ProductHelper.getProductImage(product);
    final priceInfo = ProductHelper.calculatePriceInfo(product);
    final productType = priceInfo['productType'];
    final inStock = ProductHelper.isInStock(product);

    return GestureDetector(
      onTap: inStock ? onTap : null,
      child: Opacity(
        opacity: inStock ? 1.0 : 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 0.9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
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
                // Wishlist Button
                Positioned(
                  left: 6,
                  top: 6,
                  child: _buildWishlistButton(context, product),
                ),
                // Discount Badge
                if (inStock &&
                    priceInfo['discountRate'] != null &&
                    priceInfo['discountRate'].toString().isNotEmpty)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        priceInfo['discountRate'],
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onError,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                // Out of Stock Badge
                if (!inStock)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Out of Stock',
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Product Name
            Text(
              productName,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            ProductHelper.buildRatingWidget(product, textTheme, colorScheme),
            const SizedBox(height: 4),
            // Price
            if (productType == 'variable')
              _buildVariablePrice(context, priceInfo)
            else
              _buildSimplePrice(context, priceInfo),
          ],
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';
import 'package:get/get.dart';

class ParentWebProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isList;
  final VoidCallback? onTap;
  final String? categoryLabel;

  const ParentWebProductCard({
    Key? key,
    required this.product,
    this.isList = false,
    this.onTap,
    this.categoryLabel,
  }) : super(key: key);

  String get _productId => ProductHelper.getProductId(product);

  String _resolveCategoryLabel() {
    final explicit = categoryLabel?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final raw = product['categories'] ?? product['category'];
    final categories = raw is List
        ? raw
        : raw == null
            ? const []
            : [raw];
    for (final category in categories) {
      if (category is Map) {
        final name = (category['name'] ?? category['title'])?.toString().trim();
        if (name != null && name.isNotEmpty) return name;
      }
    }
    final brand = product['brand'];
    if (brand is Map) {
      final name = brand['name']?.toString().trim();
      if (name != null && name.isNotEmpty) return name;
    }
    return '';
  }

  String _resolveDefaultVariantId() {
    final variants = product['variants'];
    if (variants is! List || variants.isEmpty) return '';

    Map? bestInStock;
    double bestInStockPrice = double.infinity;
    Map? bestOverall;
    double bestOverallPrice = double.infinity;

    for (final v in variants) {
      if (v is! Map) continue;
      final price = HelperFunctions.parseAmount(v['sale_price']) > 0
          ? HelperFunctions.parseAmount(v['sale_price'])
          : HelperFunctions.parseAmount(v['price']);

      if (price < bestOverallPrice) {
        bestOverallPrice = price;
        bestOverall = v;
      }

      final stockStatus =
          (v['stock_status'] ?? '').toString().toLowerCase().trim();
      final isOutOfStock =
          stockStatus == 'out_of_stock' || stockStatus == 'outofstock';
      final quantity = v['quantity'];
      final inStock = !isOutOfStock &&
          (quantity == null || HelperFunctions.parseAmount(quantity) > 0);
      if (inStock && price < bestInStockPrice) {
        bestInStockPrice = price;
        bestInStock = v;
      }
    }

    final chosen = bestInStock ?? bestOverall;
    return (chosen?['_id'] ?? chosen?['id'] ?? '').toString();
  }

  Widget _buildRating(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme,
      {bool centered = false}) {
    final rating = double.tryParse(
            (product['average_rating'] ?? product['rating'] ?? 0).toString()) ??
        0;
    final count = int.tryParse(
            (product['rating_count'] ?? product['review_count'] ?? 0)
                .toString()) ??
        0;
    return Row(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final full = rating >= index + 1;
          final half = !full && rating >= index + 0.5;
          return Icon(
            half
                ? Icons.star_half_rounded
                : full
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
            size: 13,
            color: full || half
                ? const Color(0xFFFFB800)
                : colorScheme.outline.withValues(alpha: 0.45),
          );
        }),
        const SizedBox(width: 4),
        Text(
          rating > 0 ? rating.toStringAsFixed(1) : '($count)',
          style: textTheme.labelSmall?.copyWith(
            color: context.onSurfaceVariantColor,
          ),
        ),
      ],
    );
  }

  void _navigateToDetail() {
    if (onTap != null) {
      onTap!();
      return;
    }
    Get.toNamed(
      Routes.PRODUCTDETAILS,
      arguments: {'productId': _productId},
    );
  }

  Future<void> _handleAddToCart(BuildContext context) async {
    final inStock = ProductHelper.isInStock(product);
    if (!inStock) {
      Get.snackbar(
        'Out of Stock',
        'This product is currently out of stock',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final variantId = _resolveDefaultVariantId();

    await CartService.to.manageCart(
      productId: _productId,
      variantId: variantId,
      quantity: 1,
      product: product,
    );

    Get.snackbar(
      'Added to Cart',
      '${ProductHelper.getProductName(product)} added to your cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: primaryColor,
      colorText: onPrimaryColor,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> _updateCartQuantity(BuildContext context, int delta) async {
    final variantId = _resolveDefaultVariantId();
    await CartService.to.manageCart(
      productId: _productId,
      variantId: variantId,
      quantity: delta,
      product: product,
    );
  }

  Future<void> _handleToggleWishlist() async {
    final slug = product['slug']?.toString() ?? '';
    final variantId = _resolveDefaultVariantId();
    await WishListService.to.toggleWishlist(
      productId: _productId,
      variantSlug: slug,
      variantId: variantId.isNotEmpty ? variantId : null,
      productData: product,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isList) {
      return _buildListCard(context);
    }
    return _buildGridCard(context);
  }

  // ─────────────────────────────────────────────────────────────
  // 1. GRID CARD (Portrait 2-column fashion card)
  // ─────────────────────────────────────────────────────────────
  Widget _buildGridCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final priceInfo = ProductHelper.calculatePriceInfo(product);

    final imageUrl = ProductHelper.getProductImage(product);
    final productName = ProductHelper.getProductName(product);
    final categoryText = _resolveCategoryLabel();
    final priceStr = priceInfo['productPrice']?.toString() ?? '0';
    final regularPriceStr = priceInfo['salePrice']?.toString() ?? '';
    final discountRateStr = priceInfo['discountRate']?.toString() ?? '';
    final hasDiscount = discountRateStr.trim().isNotEmpty;

    return GestureDetector(
      onTap: _navigateToDetail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Image with Floating Wishlist and Bag
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (_, __, ___) =>
                        HelperFunctions().loadingIndicator(),
                    errorWidget: (_, __, ___) => Container(
                      color: context.surfaceVariantColor,
                      child: Icon(Icons.image_outlined,
                          color: context.onSurfaceVariantColor),
                    ),
                  ),

                  // Sale badge (top-left)
                  if (hasDiscount)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          discountRateStr.isNotEmpty ? discountRateStr : 'SALE',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onError,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),

                  // Floating Wishlist Heart (top-right)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Obx(() {
                      final isFav = WishListService.to.isInWishlist(_productId);
                      return GestureDetector(
                        onTap: _handleToggleWishlist,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.surfaceColor.withValues(alpha: 0.9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 17,
                            color: isFav
                                ? colorScheme.error
                                : context.onSurfaceColor,
                          ),
                        ),
                      );
                    }),
                  ),

                  // Floating Quick Add to Bag (bottom-right)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: GestureDetector(
                      onTap: () => _handleAddToCart(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  colorScheme.primary.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 17,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Rating stars reflect the product's actual review data.
          _buildRating(context, colorScheme, textTheme, centered: true),
          const SizedBox(height: 3),

          if (categoryText.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                categoryText.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  letterSpacing: 0.4,
                  color: context.onSurfaceVariantColor,
                ),
              ),
            ),
            const SizedBox(height: 2),
          ],

          // Product Title (centered)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              productName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: context.onSurfaceColor,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 3),

          // Product Price (centered)
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ProductHelper.formatPrice(priceStr),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                    maxLines: 1,
                  ),
                  if (hasDiscount && regularPriceStr.isNotEmpty) ...[
                    const SizedBox(width: 5),
                    Text(
                      ProductHelper.formatPrice(regularPriceStr),
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                        color: context.onSurfaceVariantColor,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2. LIST CARD (Luxury Mobile Fashion Row Card)
  // ─────────────────────────────────────────────────────────────
  Widget _buildListCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final priceInfo = ProductHelper.calculatePriceInfo(product);

    final imageUrl = ProductHelper.getProductImage(product);
    final productName = ProductHelper.getProductName(product);
    final priceStr = priceInfo['productPrice']?.toString() ?? '0';
    final regularPriceStr = priceInfo['salePrice']?.toString() ?? '';
    final discountRateStr = priceInfo['discountRate']?.toString() ?? '';
    final hasDiscount = discountRateStr.trim().isNotEmpty;
    final inStock = ProductHelper.isInStock(product);

    return GestureDetector(
      onTap: _navigateToDetail,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.outlineColor.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Portrait Fashion Thumbnail (~3:4 aspect ratio)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  SizedBox(
                    width: 112,
                    height: 145,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (_, __, ___) =>
                          HelperFunctions().loadingIndicator(),
                      errorWidget: (_, __, ___) => Container(
                        color: context.surfaceVariantColor,
                        child: Icon(Icons.image_outlined,
                            color: context.onSurfaceVariantColor, size: 28),
                      ),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Text(
                          discountRateStr.isNotEmpty ? discountRateStr : 'SALE',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onError,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Product Details & Actions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title + Wishlist Heart Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            height: 1.25,
                            color: context.onSurfaceColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Dedicated Touch-Friendly Wishlist Button
                      Obx(() {
                        final isFav =
                            WishListService.to.isInWishlist(_productId);
                        return GestureDetector(
                          onTap: _handleToggleWishlist,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFav
                                  ? colorScheme.error.withValues(alpha: 0.1)
                                  : context.surfaceVariantColor
                                      .withValues(alpha: 0.4),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 18,
                              color: isFav
                                  ? colorScheme.error
                                  : context.onSurfaceVariantColor,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 6),

                  _buildRating(context, colorScheme, textTheme),
                  const SizedBox(height: 8),

                  // Pricing Block
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 2,
                    children: [
                      Text(
                        ProductHelper.formatPrice(priceStr),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: colorScheme.primary,
                        ),
                      ),
                      if (hasDiscount && regularPriceStr.isNotEmpty)
                        Text(
                          ProductHelper.formatPrice(regularPriceStr),
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: context.onSurfaceVariantColor,
                          ),
                        ),
                      if (hasDiscount && discountRateStr.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: colorScheme.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            discountRateStr,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Bottom Action Row: Stock status & Cart button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        inStock ? 'In Stock' : 'Out of Stock',
                        style: textTheme.labelSmall?.copyWith(
                          color: inStock
                              ? const Color(0xFF16A34A)
                              : colorScheme.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      _buildCartActionButton(context, inStock),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 3. CART ACTION BUTTON / STEPPER
  // ─────────────────────────────────────────────────────────────
  Widget _buildCartActionButton(BuildContext context, bool inStock) {
    final colorScheme = Theme.of(context).colorScheme;
    final variantId = _resolveDefaultVariantId();

    if (!inStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Unavailable',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Obx(() {
      final cartItem = CartService.to.cartItems.firstWhereOrNull((item) {
        final p = item['product_id'];
        final pid = (p is Map ? (p['_id'] ?? p['id']) : p)?.toString();
        return pid == _productId &&
            (variantId.isEmpty || item['variant_id'] == variantId);
      });

      if (cartItem != null) {
        final qty = cartItem['quantity'] ?? 1;
        return Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.primary, width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _updateCartQuantity(context, -1),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child:
                      Icon(Icons.remove, size: 14, color: colorScheme.primary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '$qty',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: context.onSurfaceColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _updateCartQuantity(context, 1),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Icon(Icons.add, size: 14, color: colorScheme.primary),
                ),
              ),
            ],
          ),
        );
      }

      return ElevatedButton.icon(
        onPressed: () => _handleAddToCart(context),
        icon: const Icon(Icons.shopping_bag_outlined, size: 13),
        label: const Text(
          'Add',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    });
  }
}

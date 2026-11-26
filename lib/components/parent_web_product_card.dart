import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/commonWidgets/arrow_tooltip.dart';
import 'package:foduu_ecommerce/components/product_quick_view_modal.dart';
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

      final stockStatus = (v['stock_status'] ?? '').toString();
      final inStock = stockStatus.isEmpty || stockStatus == 'in_stock';
      if (inStock && price < bestInStockPrice) {
        bestInStockPrice = price;
        bestInStock = v;
      }
    }

    final chosen = bestInStock ?? bestOverall;
    return (chosen?['_id'] ?? chosen?['id'] ?? '').toString();
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

  String _resolveCategoryLabel() {
    if (categoryLabel != null && categoryLabel!.trim().isNotEmpty) {
      return categoryLabel!.trim().toUpperCase();
    }
    final cats = product['categories'];
    if (cats is List && cats.isNotEmpty) {
      final first = cats.first;
      if (first is Map && first['name'] != null) {
        return first['name'].toString().trim().toUpperCase();
      }
    }
    final brand = product['brand'];
    if (brand is Map && brand['name'] != null) {
      return brand['name'].toString().trim().toUpperCase();
    }
    return '';
  }

  // ─────────────────────────────────────────────────────────────
  // 1. GRID CARD (Parent-website parity 2-column electronics card)
  // ─────────────────────────────────────────────────────────────
  Widget _buildGridCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final priceInfo = ProductHelper.calculatePriceInfo(product);

    final imageUrl = ProductHelper.getProductImage(product);
    final hasValidImage =
        imageUrl.isNotEmpty && imageUrl != HelperFunctions.getNoImage();
    final productName = ProductHelper.getProductName(product);
    final priceStr = priceInfo['productPrice']?.toString() ?? '0';
    final regularPriceStr = priceInfo['salePrice']?.toString() ?? '';
    final discountRateStr = priceInfo['discountRate']?.toString() ?? '';
    final hasDiscount = discountRateStr.trim().isNotEmpty;
    final badgeText = discountRateStr.trim().isNotEmpty
        ? '-${discountRateStr.trim().replaceAll(RegExp(r'[^0-9.]'), '')}%'
        : (regularPriceStr.isNotEmpty ? 'SALE' : '');
    final categoryText = _resolveCategoryLabel();

    final avgRating =
        double.tryParse((product['average_rating'] ?? 0).toString()) ?? 0.0;
    final ratingCount =
        int.tryParse((product['rating_count'] ?? 0).toString()) ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 130;
        final isUltraCompact = constraints.maxWidth < 100;
        final cardPadding = isUltraCompact ? 4.0 : (isCompact ? 6.0 : 8.0);
        final actionSize = isUltraCompact ? 20.0 : (isCompact ? 24.0 : 28.0);
        final actionIconSize = isUltraCompact ? 11.0 : (isCompact ? 13.0 : 15.0);

        return GestureDetector(
          onTap: _navigateToDetail,
          child: Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(isCompact ? 10 : 14),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.12),
              ),
            ),
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                // Image with Discount Badge & Wishlist Heart
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(isCompact ? 4.0 : 10.0),
                            child: hasValidImage
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.contain,
                                    progressIndicatorBuilder: (_, __, ___) =>
                                        HelperFunctions().loadingIndicator(),
                                    errorWidget: (_, __, ___) =>
                                        _imageFallback(colorScheme),
                                  )
                                : _imageFallback(colorScheme),
                          ),

                          // Sale badge (top-left)
                          if (badgeText.isNotEmpty)
                            Positioned(
                              left: isCompact ? 3 : 6,
                              top: isCompact ? 3 : 6,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isCompact ? 4 : 7,
                                    vertical: isCompact ? 2 : 3),
                                decoration: BoxDecoration(
                                  color: colorScheme.error,
                                  borderRadius: BorderRadius.circular(
                                      isCompact ? 4 : 5),
                                ),
                                child: Text(
                                  badgeText,
                                  style: TextStyle(
                                    color: colorScheme.onError,
                                    fontWeight: FontWeight.w700,
                                    fontSize: isCompact ? 8.0 : 10,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),

                          // Floating Wishlist & Quick View Actions (top-right)
                          Positioned(
                            right: isCompact ? 3 : 6,
                            top: isCompact ? 3 : 6,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Obx(() {
                                  final isFav = WishListService.to
                                      .isInWishlist(_productId);
                                  return ArrowTooltip(
                                    message: isFav
                                        ? 'Remove from Wishlist'
                                        : 'Add to Wishlist',
                                    direction: ArrowDirection.bottom,
                                    child: GestureDetector(
                                      onTap: _handleToggleWishlist,
                                      child: Container(
                                        width: actionSize,
                                        height: actionSize,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colorScheme.surface
                                              .withOpacity(0.92),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.10),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          isFav
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                          size: actionIconSize,
                                          color: isFav
                                              ? colorScheme.error
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                if (!isUltraCompact) ...[
                                  SizedBox(height: isCompact ? 4 : 6),
                                  ArrowTooltip(
                                    message: 'Quick View',
                                    direction: ArrowDirection.bottom,
                                    child: GestureDetector(
                                      onTap: () => ProductQuickViewModal.show(
                                          context, product),
                                      child: Container(
                                        width: actionSize,
                                        height: actionSize,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colorScheme.surface
                                              .withOpacity(0.92),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.10),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.visibility_outlined,
                                          size: actionIconSize,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
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
                ),
                SizedBox(height: isCompact ? 4 : 8),

                // Category Eyebrow
                if (categoryText.isNotEmpty && !isUltraCompact) ...[
                  Text(
                    categoryText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: isCompact ? 8.5 : 9.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: context.onSurfaceVariantColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],

                // Product Title
                SizedBox(
                  height: isUltraCompact ? 24 : (isCompact ? 28 : 32),
                  child: Text(
                    productName,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: isUltraCompact ? 9.5 : (isCompact ? 11 : 12.5),
                      fontWeight: FontWeight.w700,
                      color: context.onSurfaceColor,
                      height: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: isCompact ? 2 : 4),

                // Rating Stars
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      ...List.generate(5, (index) {
                        final filled = avgRating >= index + 1;
                        final half = !filled && avgRating >= index + 0.5;
                        return Icon(
                          half
                              ? Icons.star_half_rounded
                              : (filled
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded),
                          size: isCompact ? 10 : 13,
                          color: (filled || half)
                              ? context.semanticColors.warning
                              : colorScheme.outline.withOpacity(0.45),
                        );
                      }),
                      const SizedBox(width: 3),
                      Text(
                        avgRating > 0
                            ? '(${avgRating.toStringAsFixed(1)})'
                            : '($ratingCount)',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: isCompact ? 9 : 10.5,
                          color: context.onSurfaceVariantColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isCompact ? 3 : 5),

                // Product Price
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ProductHelper.formatPrice(priceStr),
                        style: textTheme.titleSmall?.copyWith(
                          fontSize: isUltraCompact ? 11 : (isCompact ? 12.5 : 14),
                          fontWeight: FontWeight.w800,
                          color: context.onSurfaceColor,
                        ),
                        maxLines: 1,
                      ),
                      if (hasDiscount && regularPriceStr.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          ProductHelper.formatPrice(regularPriceStr),
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: isCompact ? 9.5 : 11,
                            decoration: TextDecoration.lineThrough,
                            color: context.onSurfaceVariantColor,
                          ),
                          maxLines: 1,
                        ),
                      ],
                      if (badgeText.startsWith('-') && !isUltraCompact) ...[
                        const SizedBox(width: 4),
                        Text(
                          badgeText,
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: isCompact ? 9 : 10.5,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: isCompact ? 4 : 8),

                // Full-Width Add To Cart / Quantity Stepper CTA
                SizedBox(
                  width: double.infinity,
                  height: isCompact ? 26 : 32,
                  child: _buildGridCartCta(
                    context,
                    isCompact: isCompact,
                    isUltraCompact: isUltraCompact,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _imageFallback(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.05),
            colorScheme.surfaceVariant.withOpacity(0.35),
          ],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.75),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.devices_other_outlined,
            color: colorScheme.primary.withOpacity(0.55),
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildGridCartCta(
    BuildContext context, {
    bool isCompact = false,
    bool isUltraCompact = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final inStock = ProductHelper.isInStock(product);
    final variantId = _resolveDefaultVariantId();

    if (!inStock) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isUltraCompact ? 'Out' : 'Out of Stock',
          style: TextStyle(
            fontSize: isCompact ? 9.5 : 11,
            fontWeight: FontWeight.w600,
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
            color: colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.primary, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => _updateCartQuantity(context, -1),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 4 : 10, vertical: 2),
                  child: Icon(Icons.remove,
                      size: isCompact ? 12 : 15, color: colorScheme.primary),
                ),
              ),
              Text(
                '$qty',
                style: TextStyle(
                  fontSize: isCompact ? 10.5 : 12,
                  fontWeight: FontWeight.bold,
                  color: context.onSurfaceColor,
                ),
              ),
              GestureDetector(
                onTap: () => _updateCartQuantity(context, 1),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 4 : 10, vertical: 2),
                  child: Icon(Icons.add,
                      size: isCompact ? 12 : 15, color: colorScheme.primary),
                ),
              ),
            ],
          ),
        );
      }

      return ElevatedButton.icon(
        onPressed: () => _handleAddToCart(context),
        icon: Icon(Icons.shopping_bag_outlined, size: isCompact ? 11 : 13),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            isUltraCompact ? 'Add' : 'Add To Cart',
            style: TextStyle(
                fontSize: isCompact ? 10 : 11.5, fontWeight: FontWeight.w600),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    });
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
    final badgeText = discountRateStr.trim().isNotEmpty
        ? discountRateStr.trim().toUpperCase()
        : (regularPriceStr.isNotEmpty ? 'SALE' : '');
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
                  if (badgeText.isNotEmpty)
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: colorScheme.onError,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
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

                  // Rating Stars + Score
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: context.semanticColors.warning,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '5.0',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.onSurfaceVariantColor,
                        ),
                      ),
                    ],
                  ),
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
                              ? context.semanticColors.success
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

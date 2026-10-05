import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
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

  const ParentWebProductCard({
    Key? key,
    required this.product,
    this.isList = false,
    this.onTap,
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

  void _handleCompare(BuildContext context) {
    Get.snackbar(
      'Compare',
      '${ProductHelper.getProductName(product)} added to comparison',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      colorText: Theme.of(context).colorScheme.onSecondary,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
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
  // 1. GRID CARD (2-Column portrait layout mirroring parent website)
  // ─────────────────────────────────────────────────────────────
  Widget _buildGridCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final priceInfo = ProductHelper.calculatePriceInfo(product);

    final imageUrl = ProductHelper.getProductImage(product);
    final productName = ProductHelper.getProductName(product);
    final priceStr = priceInfo['productPrice']?.toString() ?? '0';
    final regularPriceStr = priceInfo['salePrice']?.toString() ?? '';
    final hasDiscount = priceInfo['discountRate'] != null &&
        priceInfo['discountRate'].toString().trim().isNotEmpty;

    return GestureDetector(
      onTap: _navigateToDetail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image with Floating Action Stack
          AspectRatio(
            aspectRatio: 0.85,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Sale',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onError,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),

                  // Floating 4-Action Stack (top-right)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: _buildActionStack(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Rating Stars (5 gold stars centered)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => const Icon(
                Icons.star_rounded,
                size: 14,
                color: DefaultThemeColors.alertWarninglight,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Product Title (centered)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              productName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.onSurfaceColor,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Product Price (centered)
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              Text(
                ProductHelper.formatPrice(priceStr),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              if (hasDiscount && regularPriceStr.isNotEmpty)
                Text(
                  ProductHelper.formatPrice(regularPriceStr),
                  style: textTheme.bodySmall?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: context.onSurfaceVariantColor,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2. LIST CARD (1-Column horizontal row mirroring #aq-listLayout)
  // ─────────────────────────────────────────────────────────────
  Widget _buildListCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final priceInfo = ProductHelper.calculatePriceInfo(product);

    final imageUrl = ProductHelper.getProductImage(product);
    final productName = ProductHelper.getProductName(product);
    final priceStr = priceInfo['productPrice']?.toString() ?? '0';
    final regularPriceStr = priceInfo['salePrice']?.toString() ?? '';
    final hasDiscount = priceInfo['discountRate'] != null &&
        priceInfo['discountRate'].toString().trim().isNotEmpty;

    return GestureDetector(
      onTap: _navigateToDetail,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.outlineColor.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail with Sale badge
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  SizedBox(
                    width: 100,
                    height: 110,
                    child: CachedNetworkImage(
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
                  ),
                  if (hasDiscount)
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Sale',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onError,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Info (Title, Rating, Price)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) => const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: DefaultThemeColors.alertWarninglight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        ProductHelper.formatPrice(priceStr),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      if (hasDiscount && regularPriceStr.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          ProductHelper.formatPrice(regularPriceStr),
                          style: textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: context.onSurfaceVariantColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Action Stack in list mode
            _buildActionStack(context, isCompact: true),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 3. 4-ACTION FLOATING BUTTON STACK
  // ─────────────────────────────────────────────────────────────
  Widget _buildActionStack(BuildContext context, {bool isCompact = false}) {
    final double buttonSize = isCompact ? 30.0 : 34.0;
    final double iconSize = isCompact ? 15.0 : 17.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Add to Cart Button
        _actionButton(
          context: context,
          size: buttonSize,
          onTap: () => _handleAddToCart(context),
          tooltip: 'Add to Cart',
          child: Icon(
            Icons.shopping_bag_outlined,
            size: iconSize,
            color: context.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 6),

        // 2. Quick View Button
        _actionButton(
          context: context,
          size: buttonSize,
          onTap: () => ProductQuickViewModal.show(context, product),
          tooltip: 'Quick View',
          child: Icon(
            Icons.remove_red_eye_outlined,
            size: iconSize,
            color: context.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 6),

        // 3. Wishlist Button (Reactive)
        Obx(() {
          final isFav = WishListService.to.isInWishlist(_productId);
          return _actionButton(
            context: context,
            size: buttonSize,
            onTap: _handleToggleWishlist,
            tooltip: 'Wishlist',
            child: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: iconSize,
              color: isFav
                  ? Theme.of(context).colorScheme.error
                  : context.onSurfaceColor,
            ),
          );
        }),
        const SizedBox(height: 6),

        // 4. Compare Button
        _actionButton(
          context: context,
          size: buttonSize,
          onTap: () => _handleCompare(context),
          tooltip: 'Compare',
          child: Icon(
            Icons.swap_horiz_rounded,
            size: iconSize,
            color: context.onSurfaceColor,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required double size,
    required VoidCallback onTap,
    required Widget child,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.surfaceColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: context.outlineColor.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

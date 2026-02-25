import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/modules/product/views/product_view.dart';
import '/app/modules/wishlist/controllers/wishlist_controller.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import '/constants/product_helper.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class TrendingProductSection extends StatefulWidget {
  final Map<String, dynamic>? contentJson;

  const TrendingProductSection({
    super.key,
    this.contentJson,
  });

  @override
  State<TrendingProductSection> createState() => _TrendingProductCardState();
}

class _TrendingProductCardState extends State<TrendingProductSection>
    with BaseController {
  List trendingList = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    if (widget.contentJson != null && widget.contentJson!['products'] != null) {
      trendingList = List.from(widget.contentJson!['products']);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final heading = widget.contentJson?['heading'] ?? 'Trending';
    final subheading = widget.contentJson?['subheading'] ?? '';
    final categoryType =
        widget.contentJson?['category_type'] ?? 'random_category';
    final categoryIds = widget.contentJson?['categories'];
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ─── Layout Configuration ───
    // 'style': 'standard' (default), 'horizontal', or 'overlay'
    String style = widget.contentJson?['layout'] ?? 'standard';

    return Column(
      children: [
        // ─── Section Header ───
        Padding(
          padding: pageSurroundingPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(heading, style: textTheme.titleLarge),
                    subheading.isEmpty
                        ? Container()
                        : Text(subheading,
                            style: textTheme.titleSmall!
                                .copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
                    'productId': categoryIds,
                    'name': heading,
                    'productype': categoryType,
                    'source': 'dashboard'
                  });
                },
                child: Text(
                  'See all',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // ─── Product Cards ───
        trendingList.isEmpty
            ? const SizedBox(
                height: 300,
                child: Padding(
                  padding: EdgeInsets.only(left: 6.0),
                  child: TrendingProductsShimmer(),
                ),
              )
            : _buildProductLayout(style),
        const SizedBox(height: 10),
      ],
    );
  }

  /// Route to the correct style builder
  Widget _buildProductLayout(String style) {
    switch (style) {
      case 'horizontal':
        return _buildHorizontalStyleList();
      case 'overlay':
        return _buildOverlayStyleList();
      case 'standard':
      default:
        return _buildStandardStyleList();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLE 1 — STANDARD (Vertical Card, Image on Top)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStandardStyleList() {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: SizedBox(
        height: 300,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            shrinkWrap: false,
            cacheExtent: 9999,
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: trendingList.length,
            itemBuilder: (context, index) {
              final product = trendingList[index];
              final priceInfo = ProductHelper.calculatePriceInfo(product);
              if (!priceInfo['hasValidVariants'])
                return const SizedBox.shrink();
              return _buildStandardItem(product, priceInfo);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStandardItem(
      Map<String, dynamic> product, Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final productName = ProductHelper.getProductName(product);
    final imageUrl = ProductHelper.getProductImage(product);
    final productType = priceInfo['productType'];

    return GestureDetector(
      onTap: () => _navigateToProduct(product),
      child: SizedBox(
        width: 160,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 180,
                    width: 160,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (_, __, ___) =>
                        HelperFunctions().loadingIndicator(),
                    errorWidget: (_, __, ___) => Container(
                      height: 180,
                      width: 160,
                      color: colorScheme.surfaceVariant,
                      child: Icon(Icons.image_outlined,
                          color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
                // Wishlist Button
                _buildWishlistButton(product),
                // Discount Badge
                if (priceInfo['discountRate'] != null &&
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
            const SizedBox(height: 4),
            // Price
            if (productType == 'variable')
              _buildVariablePrice(priceInfo)
            else
              _buildSimplePrice(priceInfo),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLE 2 — HORIZONTAL (Image Left, Info Right Card)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHorizontalStyleList() {
    return Padding(
      padding: pageSurroundingPadding,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: trendingList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final product = trendingList[index] as Map<String, dynamic>;
          final priceInfo = ProductHelper.calculatePriceInfo(product);
          if (!priceInfo['hasValidVariants']) return const SizedBox.shrink();
          return _buildHorizontalItem(product, priceInfo);
        },
      ),
    );
  }

  Widget _buildHorizontalItem(
      Map<String, dynamic> product, Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final productName = ProductHelper.getProductName(product);
    final imageUrl = ProductHelper.getProductImage(product);
    final productType = priceInfo['productType'];

    return GestureDetector(
      onTap: () => _navigateToProduct(product),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (_, __, ___) =>
                        HelperFunctions().loadingIndicator(),
                    errorWidget: (_, __, ___) => Container(
                      width: 120,
                      height: 120,
                      color: colorScheme.surfaceVariant,
                      child: Icon(Icons.image_outlined,
                          color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
                // Discount Badge
                if (priceInfo['discountRate'] != null &&
                    priceInfo['discountRate'].toString().isNotEmpty)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(8),
                        ),
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
              ],
            ),
            // Product Info
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      productName,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (productType == 'variable')
                      _buildVariablePrice(priceInfo)
                    else
                      _buildSimplePrice(priceInfo),
                    const Spacer(),
                    // Add to cart hint
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'View Product',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Wishlist on the right
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: _buildWishlistIcon(product),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLE 3 — OVERLAY (Full Image Card with Overlay Text)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildOverlayStyleList() {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: SizedBox(
        height: 260,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: ListView.separated(
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            shrinkWrap: false,
            cacheExtent: 9999,
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: trendingList.length,
            itemBuilder: (context, index) {
              final product = trendingList[index] as Map<String, dynamic>;
              final priceInfo = ProductHelper.calculatePriceInfo(product);
              if (!priceInfo['hasValidVariants'])
                return const SizedBox.shrink();
              return _buildOverlayItem(product, priceInfo);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayItem(
      Map<String, dynamic> product, Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final productName = ProductHelper.getProductName(product);
    final imageUrl = ProductHelper.getProductImage(product);
    final productType = priceInfo['productType'];

    return GestureDetector(
      onTap: () => _navigateToProduct(product),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full background image
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (_, __, ___) =>
                    HelperFunctions().loadingIndicator(),
                errorWidget: (_, __, ___) => Container(
                  color: colorScheme.surfaceVariant,
                  child: Icon(Icons.image_outlined,
                      color: colorScheme.onSurfaceVariant, size: 40),
                ),
              ),
              // Gradient overlay at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        colorScheme.surface.withOpacity(0.7),
                        colorScheme.surface.withOpacity(0.95),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        productName,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (productType == 'variable')
                        _buildVariablePrice(priceInfo)
                      else
                        _buildSimplePrice(priceInfo),
                    ],
                  ),
                ),
              ),
              // Wishlist at top-left
              Positioned(
                left: 6,
                top: 6,
                child: _buildWishlistButton(product),
              ),
              // Discount badge at top-right
              if (priceInfo['discountRate'] != null &&
                  priceInfo['discountRate'].toString().isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      priceInfo['discountRate'],
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Navigate to product detail page
  void _navigateToProduct(Map<String, dynamic> product) {
    final productId = ProductHelper.getProductId(product);
    Get.to(
      () => ProductView(),
      preventDuplicates: false,
      arguments: {'productId': productId},
    );
  }

  /// Wishlist button with background circle (for Standard & Overlay styles)
  Widget _buildWishlistButton(Map<String, dynamic> product) {
    final colorScheme = Theme.of(context).colorScheme;
    final productId = ProductHelper.getProductId(product);

    return GestureDetector(
      onTap: () => _handleWishlistTap(product),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: colorScheme.surface.withOpacity(0.85),
        ),
        padding: const EdgeInsets.all(6.0),
        child: GetBuilder<WishlistController>(
          builder: (controller) {
            final isInWishlist =
                controller.wishlistProductIds.contains(productId);
            return SvgPicture.asset(
              isInWishlist ? 'assets/icon/like.svg' : 'assets/icon/unlike.svg',
              width: 16,
              height: 16,
            );
          },
        ),
      ),
    );
  }

  /// Wishlist icon without background (for Horizontal style)
  Widget _buildWishlistIcon(Map<String, dynamic> product) {
    final productId = ProductHelper.getProductId(product);

    return GestureDetector(
      onTap: () => _handleWishlistTap(product),
      child: GetBuilder<WishlistController>(
        builder: (controller) {
          final isInWishlist =
              controller.wishlistProductIds.contains(productId);
          return SvgPicture.asset(
            isInWishlist ? 'assets/icon/like.svg' : 'assets/icon/unlike.svg',
            width: 20,
            height: 20,
          );
        },
      ),
    );
  }

  /// Handle wishlist tap
  void _handleWishlistTap(Map<String, dynamic> product) async {
    final WishlistController wishlistCtrl = Get.find<WishlistController>();
    final productId = ProductHelper.getProductId(product);
    await wishlistCtrl.addProductToWishlist(productid: productId);
    await wishlistCtrl.getwishlist();
  }

  /// Variable product price display
  Widget _buildVariablePrice(Map<String, dynamic> priceInfo) {
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

  /// Simple product price display with discount
  Widget _buildSimplePrice(Map<String, dynamic> priceInfo) {
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
              text: '₹${priceInfo['discountPrice']}',
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
}

// ═══════════════════════════════════════════════════════════════════════════
// SHIMMER PLACEHOLDER
// ═══════════════════════════════════════════════════════════════════════════
class TrendingProductsShimmer extends StatelessWidget {
  const TrendingProductsShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
        enabled: true,
        direction: ShimmerDirection.ltr,
        loop: 0,
        period: const Duration(seconds: 1),
        baseColor: colorScheme.surfaceVariant,
        highlightColor: colorScheme.onSurfaceVariant.withOpacity(0.3),
        child: ListView.separated(
          itemCount: 10,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, index) {
            return const SizedBox(
              width: 10,
            );
          },
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 180,
                  width: 160,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10)),
                  height: 11,
                  width: 150,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10)),
                  height: 11,
                  width: 50,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10)),
                  height: 11,
                  width: 100,
                ),
              ],
            );
          },
        ));
  }
}

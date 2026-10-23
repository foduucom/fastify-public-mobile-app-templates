import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/data/models/product_model.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:zouhi/app/modules/shop/views/productdetail_view.dart';
import 'package:zouhi/app/modules/shop/views/registry_quote_flow.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';
import 'package:zouhi/components/shimmer_effects.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:zouhi/components/product_image_placeholder.dart';
import 'package:zouhi/components/catalog_mode_bottom_sheet.dart';

class TrendingProductSection extends StatefulWidget {
  String productType;
  String? heading;
  int count = 10;
  var categoryIds;
  String? subHeading;
  bool isShowSeeAll;
  bool isShowTwoRows; // New parameter

  TrendingProductSection({
    super.key,
    this.categoryIds,
    this.count = 10,
    this.heading,
    this.subHeading,
    this.isShowSeeAll = false,
    this.isShowTwoRows = false, // Default to false
    required this.productType,
  });

  @override
  State<TrendingProductSection> createState() => _TrendingProductCardState();
}

class _TrendingProductCardState extends State<TrendingProductSection>
    with BaseController, AutomaticKeepAliveClientMixin {
  late HomepageController homeController;
  WishlistController wishlistController = Get.find<WishlistController>();
  bool _isProcessingLike = false;

  List get trendingList {
    if (widget.productType == 'popular_products') {
      return homeController.trendingProductList;
    } else if (widget.productType == 'trending') {
      return homeController.trendingProductsList;
    } else {
      return homeController.editorsChoiceList;
    }
  }

  bool get isLoading {
    if (widget.productType == 'popular_products') {
      return homeController.isTrendingLoading.value;
    } else if (widget.productType == 'trending') {
      return homeController.isTrendingProductsLoading.value;
    } else {
      return homeController.isEditorsChoiceLoading.value;
    }
  }

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomepageController>();
  }

  // Modified getImage to accept a product item
  String getImage(Map<String, dynamic> productItem) {
    final featuredImage = productItem['featured_image'];
    if (featuredImage != null) {
      // if (featuredImage is String) {
      //   return url + featuredImage;
      // } else if (featuredImage is Map && featuredImage['url'] != null) {
      //   return url + featuredImage['url'].toString();
      // }
      return HelperFunctions().getImage(featuredImage);
    }
    return HelperFunctions.getNoImage();
  }

  // // Function to calculate lowest sale price
  // int lowestPrice(List<dynamic> variantIds) {
  //   int minPrice = variantIds.first['sale_price'];

  //   for (var variant in variantIds) {
  //     if (variant['sale_price'] < minPrice) {
  //       minPrice = variant['sale_price'];
  //     }
  //   }
  //   return minPrice;
  // }

  // // Function to calculate highest sale price
  // int highestPrice(List<dynamic> variantIds) {
  //   int maxPrice = 0;
  //   for (var variant in variantIds) {
  //     if (variant['sale_price'] > maxPrice) {
  //       maxPrice = variant['sale_price'];
  //     }
  //   }
  //   return maxPrice;
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      if (!isLoading && trendingList.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        children: [
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
                        Text(
                          widget.heading ?? 'Trending',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (widget.subHeading != null &&
                            widget.subHeading!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subHeading!,
                            style: txtTheme()
                                .headlineMedium!
                                .copyWith(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.isShowSeeAll && trendingList.length > 4) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        BottombarController.switchTab(1, arguments: {
                          'productId': widget.categoryIds,
                          'name': widget.heading ?? 'Products',
                          'productType': widget.productType,
                          'source': 'dashboard'
                        });
                      },
                      child: Text(
                        'See all',
                        style: TextStyle(color: context.themeSecondrytext),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: widget.isShowTwoRows
                  ? const EdgeInsets.symmetric(horizontal: 8)
                  : const EdgeInsets.only(left: 4.0),
              child: isLoading
                  ? TrendingProductsShimmer(isGrid: widget.isShowTwoRows)
                  : widget.isShowTwoRows
                      ? ExcludeSemantics(
                          excluding: true,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            addSemanticIndexes: false,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                              childAspectRatio: 0.70,
                            ),
                            itemCount:
                                widget.isShowSeeAll && trendingList.length > 4
                                    ? 4
                                    : trendingList.length,
                            itemBuilder: (context, index) {
                              return _buildProductItem(
                                  trendingList[index], index);
                            },
                          ),
                        )
                      : _buildHorizontalListView(trendingList),
            ),
          ],
        );
    });
  }

  Widget _buildHorizontalListView(List products) {
    return SizedBox(
      height: 250,
      child: ExcludeSemantics(
        excluding: true,
        child: ListView.separated(
          padding: const EdgeInsets.only(left: 6.0, right: 16.0),
          scrollDirection: Axis.horizontal,
          addSemanticIndexes: false,
          separatorBuilder: (context, index) => const SizedBox(width: 5),
          itemCount:
              widget.isShowSeeAll && products.length > 4 ? 4 : products.length,
          itemBuilder: (context, index) {
            return SizedBox(
              width: 160,
              child: _buildProductItem(products[index], index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductItem(var product, int index) {
    double? originalPrice;
    double? salePrice;
    bool isVariable =
        product['type'] == 'variable' || product['type'] == 'variant';

    final variants =
        (product['variants'] ?? product['variant_ids'] ?? []) as List;
    String? variantId;

    if (product['type'] == 'simple') {
      // Find the default variant; fall back to first if none marked
      Map? defaultVariant;
      for (var v in variants) {
        if (v is Map && v['is_default'] == true) {
          defaultVariant = v;
          break;
        }
      }
      defaultVariant ??= (variants.isNotEmpty && variants.first is Map)
          ? variants.first as Map
          : null;

      if (defaultVariant != null) {
        variantId = defaultVariant['_id']?.toString();
        originalPrice =
            double.tryParse(defaultVariant['price']?.toString() ?? '');
        salePrice =
            double.tryParse(defaultVariant['sale_price']?.toString() ?? '');
      } else {
        // Absolute fallback to product-level fields
        originalPrice = double.tryParse(product['price']?.toString() ?? '');
        salePrice = double.tryParse(product['sale_price']?.toString() ?? '');
      }
    } else if (isVariable) {
      bool isVariantInStock(Map v) {
        final vStatus = v['stock_status']
            ?.toString()
            .toLowerCase()
            .replaceAll('_', '')
            .replaceAll(' ', '');
        if (vStatus == 'outofstock') return false;

        final qty = v['quantity'] ?? v['stock'] ?? v['stock_quantity'];
        if (qty != null) {
          final parsedQty = int.tryParse(qty.toString());
          if (parsedQty != null && parsedQty <= 0) return false;
        }
        return true;
      }

      // Find variant with lowest effective price (preferring in-stock variants)
      Map? lowestVariant;
      double? minEffective;

      for (var pass = 0; pass < 2; pass++) {
        // Pass 0: check in-stock variants only; Pass 1: fallback to all variants
        for (var v in variants) {
          if (v is! Map) continue;
          if (pass == 0 && !isVariantInStock(v)) continue;

          double vP = double.tryParse(v['price']?.toString() ?? '') ?? 0;
          double? vSP = double.tryParse(v['sale_price']?.toString() ?? '');
          double effective = (vSP != null && vSP > 0) ? vSP : vP;

          if (minEffective == null || effective < minEffective) {
            minEffective = effective;
            lowestVariant = v;
          }
        }
        if (lowestVariant != null) break;
      }

      if (lowestVariant != null) {
        variantId = lowestVariant['_id']?.toString();
        originalPrice =
            double.tryParse(lowestVariant['price']?.toString() ?? '');
        salePrice =
            double.tryParse(lowestVariant['sale_price']?.toString() ?? '');
      }
    }

    // Normalise: treat sale_price == 0 as no discount
    if (salePrice != null && salePrice <= 0) salePrice = null;

    if (originalPrice != null) originalPrice = originalPrice.toConvertedPrice();
    if (salePrice != null) salePrice = salePrice.toConvertedPrice();

    // Format strings for display
    String displayPrice = (salePrice != null)
        ? salePrice.toStringAsFixed(2)
        : (originalPrice?.toStringAsFixed(2) ?? '0.00');
    String displayOriginal = (salePrice != null && originalPrice != null)
        ? originalPrice.toStringAsFixed(2)
        : '';

    // Discount % badge
    String discountRate = '';
    if (salePrice != null && originalPrice != null && originalPrice > 0) {
      discountRate =
          '${(100 - (salePrice * 100 / originalPrice)).round()}% off';
    }

    final catalogMode = product['catalog_mode'];
    final bool isCatalogMode = (catalogMode is Map && catalogMode['is_enabled'] == true) ||
        (double.tryParse(displayPrice) ?? 0.0) <= 0.0;
    final String catalogButtonText = (catalogMode is Map && catalogMode['button_text'] != null)
        ? catalogMode['button_text'].toString()
        : 'Contact for Pricing';
    if (isCatalogMode) {
      discountRate = '';
      displayOriginal = '';
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => ProductdetailView(),
            preventDuplicates: false, arguments: {'productId': product['_id']});
      },
      child: TrendingProducts(
        index: index,
        highestPrice: '',
        lowestPrice: '',
        assetImage: getImage(product),
        productName: product['name'] ?? '',
        discountPrice: displayOriginal,
        productPrice: displayPrice,
        discountRate: discountRate,
        isCatalogMode: isCatalogMode,
        catalogButtonText: catalogButtonText,
        productType: product['type'] ?? '',
        productId: product['_id'].toString(),
        variantId: variantId,
        isOutOfStock:
            Product.fromJson(Map<String, dynamic>.from(product)).isOutOfStock,
        isRegistryProduct: product['is_registry'] == true,
        onRequestQuote: () => RegistryQuoteFlow()
            .open(product['_id'].toString(), variantId: variantId),
        onAddToCart: isCatalogMode
            ? null
            : () async {
                await Get.find<CartController>().addToCart(
                  productId: product['_id'].toString(),
                  quantity: 1,
                  variantId: variantId ?? '',
                  productType: product['type'] ?? '',
                );
              },
        onlike: () async {
          if (_isProcessingLike) return;
          _isProcessingLike = true;
          try {
            if (!HelperFunctions.checkAndPromptLogin(
                message: "Please login to add products to your wishlist.")) {
              return;
            }
            String pid = product['_id'].toString();
            if (wishlistController.wishlistProductIds.contains(pid)) {
              wishlistController.wishlistProductIds.remove(pid);
              wishlistController.update();
              await wishlistController.removeProductFromWishlist(
                  productid: pid, variant_id: variantId);
            } else {
              wishlistController.wishlistProductIds.add(pid);
              wishlistController.update();
              await wishlistController.addProductToWishlist(
                  productid: pid, variant_id: variantId);
            }
          } finally {
            _isProcessingLike = false;
          }
        },
        likeWidget: GetBuilder<WishlistController>(
          builder: (controller) {
            return controller.wishlistProductIds
                    .contains(product['_id'].toString())
                ? SvgPicture.asset('assets/icon/like.svg', width: 18, height: 18)
                : SvgPicture.asset('assets/icon/unlike.svg', width: 18, height: 18);
          },
        ),
      ),
    );
  }

  @override
  void detach() {
    // TODO: implement detach
  }

  @override
  // TODO: implement keptAlive
  bool get keptAlive => true;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class TrendingProducts extends StatefulWidget {
  final String assetImage;
  final String productName;
  final String productPrice;
  final String discountPrice;
  final String discountRate;
  final VoidCallback onlike;
  final String productType;
  final String lowestPrice;
  final String highestPrice;
  final int index;
  final Widget likeWidget;
  final String productId;
  final String? variantId;
  final bool isOutOfStock;
  final VoidCallback? onAddToCart;
  final double? rating;
  final int? reviewCount;
  final bool isRegistryProduct;
  final VoidCallback? onRequestQuote;
  final bool? isContactForPrice;
  final String? contactPriceLabel;
  final bool isCatalogMode;
  final String? catalogButtonText;
  final VoidCallback? onCatalogModeTap;
  //final List<String> badges;
  const TrendingProducts({
    super.key,
    required this.assetImage,
    required this.productName,
    required this.productPrice,
    required this.discountPrice,
    required this.discountRate,
    required this.onlike,
    required this.likeWidget,
    required this.productType,
    required this.lowestPrice,
    required this.highestPrice,
    required this.index,
    required this.productId,
    this.variantId,
    this.isOutOfStock = false,
    this.onAddToCart,
    this.rating,
    this.reviewCount,
    this.isRegistryProduct = false,
    this.onRequestQuote,
    this.isContactForPrice,
    this.contactPriceLabel,
    this.isCatalogMode = false,
    this.catalogButtonText,
    this.onCatalogModeTap,
    //required this.badges,
  });

  @override
  State<TrendingProducts> createState() => _TrendingProductsState();
}

class _TrendingProductsState extends State<TrendingProducts>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  String get _currencySymbol {
    if (Get.isRegistered<CurrencyController>()) {
      return Get.find<CurrencyController>()
              .selectedCurrency['symbol']
              ?.toString() ??
          currency;
    }
    return currency;
  }

  bool get _isContactForPrice {
    if (widget.isCatalogMode) return true;
    if (widget.isContactForPrice != null) return widget.isContactForPrice!;
    final cleaned = widget.productPrice
        .replaceAll(RegExp(r'[^\d.]'), '')
        .trim();
    if (cleaned.isEmpty) return true;
    final priceValue = double.tryParse(cleaned);
    return priceValue == null || priceValue <= 0.0;
  }

  String get _contactLabel {
    if (widget.catalogButtonText != null &&
        widget.catalogButtonText!.isNotEmpty) {
      return widget.catalogButtonText!;
    }
    if (widget.contactPriceLabel != null &&
        widget.contactPriceLabel!.isNotEmpty) {
      return widget.contactPriceLabel!;
    }
    return 'Contact for Pricing';
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    super.initState();
  }

  // /// Returns a distinct color for each badge type.
  // Color _badgeColor(String badge) {
  //   switch (badge) {
  //     case 'Back to School':
  //       return const Color(0xFFFB8C00); // vivid orange
  //     case 'Seasonal Items':
  //       return const Color(0xFF00897B); // teal
  //     case 'Top Highlights':
  //       return const Color(0xFF7B1FA2); // purple
  //     case 'Recommended':
  //       return const Color(0xFF3C8A38); // deep green
  //     default:
  //       return const Color(0xFF20558A); // blue fallback
  //   }
  // }

  // Widget _buildBadgeChip(String badge) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  //     decoration: BoxDecoration(
  //       color: _badgeColor(badge),
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Text(
  //       badge,
  //       style: const TextStyle(
  //         color: Colors.white,
  //         fontSize: 8,
  //         fontWeight: FontWeight.w700,
  //         letterSpacing: 0.2,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: widget.assetImage.isEmpty ||
                          widget.assetImage == HelperFunctions.getNoImage()
                      ? const ProductImagePlaceholder(radius: 5)
                      : CachedNetworkImage(
                          imageUrl: widget.assetImage,
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          memCacheWidth:
                              (160 * MediaQuery.of(context).devicePixelRatio).round(),
                          memCacheHeight:
                              (160 * MediaQuery.of(context).devicePixelRatio).round(),
                          progressIndicatorBuilder: (context, url, progress) =>
                              HelperFunctions().loadingIndicator(),
                          errorWidget: ((context, url, error) {
                            return const ProductImagePlaceholder(radius: 5);
                          }),
                        ),
                ),
                // Discount % sticker — top-left corner
                if (widget.discountRate.isNotEmpty && !_isContactForPrice)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.discountRate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                // Like Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(17),
                      onTap: widget.onlike,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: context.themeWhiteColor.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: widget.likeWidget,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Registry (Request Quote) / Out of stock badge / Add-to-cart control
                if (widget.isRegistryProduct)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: GestureDetector(
                      onTap: widget.onRequestQuote,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: context.themePrimaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.request_quote_outlined,
                            color: context.colors.onPrimary, size: 16),
                      ),
                    ),
                  )
                else if (widget.isOutOfStock)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Out of Stock',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else if (widget.onAddToCart != null && !_isContactForPrice)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: _CartControl(
                      productId: widget.productId,
                      variantId: widget.variantId,
                      productType: widget.productType,
                      onAddToCart: widget.onAddToCart!,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 06),
          // // Badge row — shown below the image
          // if (widget.badges.isNotEmpty) ...[
          //   Wrap(
          //     spacing: 4,
          //     runSpacing: 4,
          //     children: widget.badges.map((badge) {
          //       return _buildBadgeChip(badge);
          //     }).toList(),
          //   ),
          //   const SizedBox(height: 4),
          // ],
          if (widget.rating != null &&
              widget.rating! > 0 &&
              (widget.reviewCount ?? 0) > 0) ...[
            Row(
              children: [
                Icon(Icons.star, size: 12, color: Colors.amber.shade700),
                const SizedBox(width: 2),
                Text(
                  widget.rating!.toStringAsFixed(1),
                  style: TextStyle(fontSize: 10, color: context.themeTextColor),
                ),
                if (widget.reviewCount != null) ...[
                  const SizedBox(width: 3),
                  Text(
                    '(${widget.reviewCount})',
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 3),
          ],
          Text(
            widget.productName,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.themeTextColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          // Price row
          if (_isContactForPrice)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (widget.onCatalogModeTap != null) {
                  widget.onCatalogModeTap!();
                } else {
                  showCatalogModeBottomSheet(
                    context,
                    productName: widget.productName,
                    productId: widget.productId,
                    productImage: widget.assetImage,
                    buttonText: _contactLabel,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  _contactLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: context.themePrimaryColor,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            )
          else
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                Text(
                  '$_currencySymbol${widget.productPrice}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: context.themeTextColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                if (widget.discountPrice.isNotEmpty)
                  Text(
                    '$_currencySymbol${widget.discountPrice}',
                    style: TextStyle(
                      fontSize: 10,
                      color: context.themeSecondrytext,
                      decoration: TextDecoration.lineThrough,
                      fontFamily: 'Poppins',
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CartControl extends StatelessWidget {
  final String productId;
  final String? variantId;
  final String productType;
  final VoidCallback onAddToCart;

  const _CartControl({
    required this.productId,
    required this.variantId,
    required this.productType,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final effectiveVariantId = variantId ?? '';

    return Obx(() {
      dynamic existingItem;
      if (AuthDetails.isUserLogin()) {
        existingItem = cartController.cartItems.firstWhereOrNull((item) =>
            item['product']?['_id'] == productId &&
            (item['variant']?['_id'] == effectiveVariantId ||
                effectiveVariantId.isEmpty ||
                item['variant'] == null));
      } else {
        existingItem = cartController.guestUserCartList.firstWhereOrNull(
            (item) =>
                item['_id'] == productId &&
                (item['variant_name'] == effectiveVariantId ||
                    effectiveVariantId.isEmpty ||
                    item['variant_name'] == null));
      }

      if (existingItem == null) {
        return GestureDetector(
          onTap: onAddToCart,
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: context.themePrimaryColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.add, color: context.colors.onPrimary, size: 18),
          ),
        );
      }

      final qty = existingItem['quantity'] ?? 1;
      final String itemVid = existingItem is Map &&
              existingItem['variant'] is Map &&
              existingItem['variant']['_id'] != null
          ? existingItem['variant']['_id'].toString()
          : effectiveVariantId;

      return Container(
        height: 32,
        decoration: BoxDecoration(
          color: context.themeWhiteColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.themePrimaryColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                bottomLeft: Radius.circular(7),
              ),
              onTap: () => cartController.updateCartQuantity(
                productId: productId,
                variantId: itemVid,
                delta: -1,
              ),
              child: Container(
                height: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                child: Icon(Icons.remove,
                    size: 16, color: context.themePrimaryColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                qty.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.themeTextColor,
                ),
              ),
            ),
            InkWell(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(7),
                bottomRight: Radius.circular(7),
              ),
              onTap: () => cartController.updateCartQuantity(
                productId: productId,
                variantId: itemVid,
                delta: 1,
              ),
              child: Container(
                height: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                child:
                    Icon(Icons.add, size: 16, color: context.themePrimaryColor),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class TrendingProductsShimmer extends StatelessWidget {
  final bool isGrid;
  const TrendingProductsShimmer({
    super.key,
    this.isGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
        child: isGrid
            ? ExcludeSemantics(
                excluding: true,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  addSemanticIndexes: false,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.70,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildShimmerItem();
                  },
                ),
              )
            : SizedBox(
                height: 250,
                child: ExcludeSemantics(
                  excluding: true,
                  child: ListView.separated(
                    itemCount: 6,
                    scrollDirection: Axis.horizontal,
                    addSemanticIndexes: false,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return SizedBox(width: 160, child: _buildShimmerItem());
                    },
                  ),
                ),
              ));
  }

  Widget _buildShimmerItem() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE8EEF5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFFE8EEF5),
                      borderRadius: BorderRadius.circular(4)),
                  height: 10,
                  width: 60,
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFFE8EEF5),
                      borderRadius: BorderRadius.circular(4)),
                  height: 12,
                  width: double.infinity,
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFFE8EEF5),
                      borderRadius: BorderRadius.circular(4)),
                  height: 12,
                  width: 90,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFFE8EEF5),
                      borderRadius: BorderRadius.circular(4)),
                  height: 14,
                  width: 50,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

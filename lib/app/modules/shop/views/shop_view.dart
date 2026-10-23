import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/controllers/internetconnection_controller.dart';
import 'package:zouhi/app/data/models/product_model.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:zouhi/app/modules/shop/controllers/shop_controller.dart';
import 'package:zouhi/app/modules/shop/views/productdetail_view.dart';
import 'package:zouhi/app/modules/shop/views/registry_quote_flow.dart';
import 'package:zouhi/app/modules/shop/views/widgets/shop_filter_drawer.dart';
import 'package:zouhi/app/modules/shop/views/widgets/shop_hero_header.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/components/check_internet_widget.dart';
import 'package:zouhi/components/commonWidgets/empty_product_state.dart';
import 'package:zouhi/components/home_component/trending_product_card.dart';
import 'package:zouhi/components/shimmer_effects.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

class ShopView extends GetView<ShopController> {
  ShopView({super.key});

  final WishlistController wishlistController = Get.find<WishlistController>();
  final CartController cartController = Get.find<CartController>();
  bool _isProcessingLike = false;

  static const _sortOptions = <(String, String, String)>[
    ('Default sorting', 'created_at', 'desc'),
    ('Name: A to Z', 'name', 'asc'),
    ('Name: Z to A', 'name', 'desc'),
    ('Price: low to high', 'price', 'asc'),
    ('Price: high to low', 'price', 'desc'),
  ];

  String get _sortLabel {
    final by = controller.sortBy.value;
    final order = controller.sortOrder.value;
    return _sortOptions
        .firstWhere((o) => o.$2 == by && o.$3 == order,
            orElse: () => _sortOptions.first)
        .$1;
  }

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<ShopController>()) {
      Get.put(ShopController());
    }

    return PopScope(
      canPop: controller.filterCategoryStack.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.goUpFilterCategory();
      },
      child: Scaffold(
        endDrawer: ShopFilterDrawer(controller: controller),
        onEndDrawerChanged: (isOpen) {
          if (!isOpen) return;
          controller.ensureFilterDataLoaded();
          controller.ensureCategoryTreeLoaded();
          controller.filterDrawerOpenTick.value++;
        },
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.collectionName.value,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.themeTextColor,
                    ),
                  ),
                  if (controller.totalProducts.value > 0)
                    Text(
                      '${controller.totalProducts.value} items',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.themeSecondrytext,
                      ),
                    ),
                ],
              )),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  Builder(
                    builder: (ctx) => _Pill(
                      icon: Icons.tune_rounded,
                      label: 'Filter',
                      badge: Obx(() => controller.activeFilterCount > 0
                          ? _Badge(count: controller.activeFilterCount)
                          : const SizedBox.shrink()),
                      onTap: () => Scaffold.of(ctx).openEndDrawer(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() {
                      final label = _sortLabel;
                      return PopupMenuButton<int>(
                        tooltip: 'Sort',
                        onSelected: (i) => controller.updateSort(
                            _sortOptions[i].$2, _sortOptions[i].$3),
                        itemBuilder: (_) => [
                          for (var i = 0; i < _sortOptions.length; i++)
                            CheckedPopupMenuItem<int>(
                              value: i,
                              checked: _sortOptions[i].$1 == label,
                              child: Text(_sortOptions[i].$1),
                            ),
                        ],
                        child: IgnorePointer(
                          child: _Pill(
                            icon: Icons.sort_rounded,
                            label: 'Sort: $label',
                            expand: true,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Obx(() {
          final isOffline =
              !Get.find<InternetconnectionController>().connectionStatus.value;
          if (isOffline &&
              controller.products.isEmpty &&
              !controller.isLoading.value) {
            return InternetConnectionError(
              onRetry: () => controller.fetchProducts(isRefresh: true),
            );
          }

          final loading =
              controller.isLoading.value && controller.products.isEmpty;
          final empty = !loading && controller.products.isEmpty;
          final itemCount =
              controller.products.length + (controller.hasNextPage ? 1 : 0);

          return RefreshIndicator(
            onRefresh: () => controller.fetchProducts(isRefresh: true),
            child: CustomScrollView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                const SliverToBoxAdapter(child: ShopHeroHeader()),
                if (loading)
                  const _ShimmerGrid()
                else if (empty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyProductState(
                      hasActiveFilters: controller.hasActiveFilters,
                      onClearFilters: () => controller.clearAllFilters(),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 5,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= controller.products.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return _buildProductItem(index);
                        },
                        childCount: itemCount,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProductItem(int index) {
    final product = controller.products[index] as Map<String, dynamic>;
    final productModel = Product.fromJson(product);

    // Extract price info from variants
    final variants =
        (product['variants'] ?? product['variant_ids'] ?? []) as List;
    double? originalPrice;
    double? salePrice;
    final productType = product['type'] ?? '';

    if (productType == 'simple') {
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
        originalPrice =
            double.tryParse(defaultVariant['price']?.toString() ?? '');
        salePrice =
            double.tryParse(defaultVariant['sale_price']?.toString() ?? '');
      } else {
        originalPrice = double.tryParse(product['price']?.toString() ?? '');
        salePrice = double.tryParse(product['sale_price']?.toString() ?? '');
      }
    } else {
      // variant/variable: find lowest price
      double? minEffective;
      for (var v in variants) {
        if (v is! Map) continue;
        double vP = double.tryParse(v['price']?.toString() ?? '') ?? 0;
        double? vSP = double.tryParse(v['sale_price']?.toString() ?? '');
        double eff = (vSP != null && vSP > 0) ? vSP : vP;
        if (minEffective == null || eff < minEffective) {
          minEffective = eff;
          originalPrice = vP;
          salePrice = (vSP != null && vSP > 0) ? vSP : null;
        }
      }
    }

    if (salePrice != null && salePrice <= 0) salePrice = null;

    if (originalPrice != null) originalPrice = originalPrice.toConvertedPrice();
    if (salePrice != null) salePrice = salePrice.toConvertedPrice();

    String displayPrice = (salePrice != null)
        ? salePrice.toStringAsFixed(2)
        : (originalPrice?.toStringAsFixed(2) ?? '0.00');
    String displayOriginal = (salePrice != null && originalPrice != null)
        ? originalPrice.toStringAsFixed(2)
        : '';
    String discountRate = '';
    if (salePrice != null && originalPrice != null && originalPrice > 0) {
      discountRate =
          '${(100 - (salePrice * 100 / originalPrice)).round()}% off';
    }

    final catalogMode = product['catalog_mode'];
    final bool isCatalogMode = (catalogMode is Map && catalogMode['is_enabled'] == true) ||
        productModel.isCatalogMode ||
        (double.tryParse(displayPrice) ?? 0.0) <= 0.0;
    final String catalogButtonText = (catalogMode is Map && catalogMode['button_text'] != null)
        ? catalogMode['button_text'].toString()
        : productModel.catalogButtonText;
    if (isCatalogMode) {
      discountRate = '';
      displayOriginal = '';
    }

    final imageUrl = HelperFunctions().getImage(product['featured_image']);
    final productId = product['_id'].toString();
    final variantId = productModel.defaultVariantId;

    return GestureDetector(
      onTap: () => Get.to(
        () => ProductdetailView(),
        preventDuplicates: false,
        arguments: {'productId': product['_id']},
      ),
      child: TrendingProducts(
        index: index,
        lowestPrice: displayPrice,
        highestPrice: displayPrice,
        assetImage: imageUrl,
        productName: product['name']?.toString() ?? '',
        discountPrice: displayOriginal,
        productPrice: displayPrice,
        discountRate: discountRate,
        isContactForPrice: isCatalogMode,
        contactPriceLabel: catalogButtonText,
        isCatalogMode: isCatalogMode,
        catalogButtonText: catalogButtonText,
        productType: productType,
        productId: productId,
        variantId: variantId,
        isOutOfStock: productModel.isOutOfStock,
        isRegistryProduct: productModel.isRegistry,
        rating: productModel.averageRating,
        reviewCount: productModel.reviewCount,
        onRequestQuote: () =>
            RegistryQuoteFlow().open(productId, variantId: variantId),
        onAddToCart: isCatalogMode
            ? null
            : () async {
                await cartController.addToCart(
                  productId: productId,
                  quantity: 1,
                  variantId: variantId ?? '',
                  productType: productType,
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
            if (wishlistController.wishlistProductIds.contains(productId)) {
              wishlistController.wishlistProductIds.remove(productId);
              wishlistController.update();
              await wishlistController.removeProductFromWishlist(
                  productid: productId, variant_id: variantId);
            } else {
              wishlistController.wishlistProductIds.add(productId);
              wishlistController.update();
              await wishlistController.addProductToWishlist(
                  productid: productId, variant_id: variantId);
            }
          } finally {
            _isProcessingLike = false;
          }
        },
        likeWidget: GetBuilder<WishlistController>(
          builder: (wishController) {
            return wishController.wishlistProductIds.contains(productId)
                ? SvgPicture.asset('assets/icon/like.svg', width: 18, height: 18)
                : SvgPicture.asset('assets/icon/unlike.svg', width: 18, height: 18);
          },
        ),
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, __) => const AppShimmer(
            child: SkeletonBox(borderRadius: 16),
          ),
          childCount: 6,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? badge;
  final bool expand;
  final VoidCallback? onTap;

  const _Pill({
    required this.icon,
    required this.label,
    this.badge,
    this.expand = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.themeBorderColor),
        color: context.themegreyColor,
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: context.themeTextColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.themeTextColor,
              ),
            ),
          ),
          if (badge != null) ...[const SizedBox(width: 6), badge!],
        ],
      ),
    );
    return onTap == null ? pill : GestureDetector(onTap: onTap, child: pill);
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: themeRedColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}

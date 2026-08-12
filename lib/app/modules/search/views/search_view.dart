import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:foduu_ecommerce/app/modules/product/views/product_view.dart';
import 'package:foduu_ecommerce/app/modules/shop/bindings/shop_binding.dart';
import '../../../../components/studio_widget/studio_search_bar_rounded.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';
import 'package:get/get.dart';

import '../controllers/search_controller.dart';

// ── Safe capitalize ──────────
String _cap(dynamic value) {
  if (value == null) return '';
  final s = value.toString().trim();
  if (s.isEmpty) return '';
  return s[0].toUpperCase() + s.substring(1);
}

class SearchView extends GetView<SearchsController> {
  const SearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: () => HelperFunctions().closeKeyboard(context),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: colorScheme.background,

          // ── PREMIUM APP BAR WITH INTEGRATED SEARCH ──
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70.0),
            child: AppBar(
              backgroundColor: colorScheme.background,
              elevation: 0,
              titleSpacing: 0,
              iconTheme: IconThemeData(color: colorScheme.onBackground),
              title: Padding(
                padding:
                    const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
                child: SearchBarRounded(
                  SearchsController: controller.searchTextController,
                  onChanged: (value) {
                    controller.getSearchSuggestion(text: value);
                  },
                  searchHintText: 'Search products, categories...',
                ),
              ),
            ),
          ),

          // ── SCROLLABLE CONTENT ──
          body: Obx(() {
            // ── INITIAL LOADING STATE ──
            if (controller.isSearching.value &&
                controller.searchProduct.isEmpty) {
              return _buildGridShimmer(colorScheme);
            }

            return SingleChildScrollView(
              controller: controller
                  .scrollController, // ✅ Attached Pagination Controller
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── RECENT SEARCHES (CHIPS) ──
                  if (controller.searchTextController.text.isEmpty &&
                      controller.recentSearchList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Recent Searches",
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Icon(Icons.history,
                                  size: 20,
                                  color: colorScheme.onSurfaceVariant),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                controller.recentSearchList.take(6).map((item) {
                              return ActionChip(
                                label: Text(item['name']?.toString() ?? ''),
                                backgroundColor:
                                    colorScheme.surfaceVariant.withOpacity(0.4),
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                labelStyle: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w500),
                                onPressed: () {
                                  controller.searchTextController.text =
                                      item['name']?.toString() ?? '';
                                  controller.getSearchSuggestion(
                                      text:
                                          controller.searchTextController.text);
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                  // ── SECTION TITLE ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text(
                      controller.searchTextController.text.trim().isEmpty
                          ? "Discover Products"
                          : "Search Results", // Removed length since it paginates now
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),

                  // ── EMPTY STATE ──
                  if (!controller.isSearching.value &&
                      controller.searchProduct.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 80,
                                color: colorScheme.outline.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text("No products found",
                                style: textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text("Try searching with a different keyword.",
                                style: TextStyle(
                                    color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),

                  // ── PRODUCT GRID ──
                  if (controller.searchProduct.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // Scroll handled by SingleChildScrollView
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.58,
                      ),
                      itemCount: controller.searchProduct.length,
                      itemBuilder: (context, index) {
                        final product = controller.searchProduct[index];
                        return _ProductGridCard(
                          product: product,
                          onTap: () {
                            final productId = product['_id']?.toString() ?? '';
                            final productName =
                                product['name']?.toString() ?? '';
                            if (productId.isNotEmpty) {
                              controller.saveRecentSearch(
                                  id: productId,
                                  name: productName,
                                  type: 'product');
                              Get.to(() => ProductView(),
                                  binding: ShopBinding(),
                                  arguments: {'productId': productId});
                            }
                          },
                        );
                      },
                    ),

                  // ── PAGINATION LOADER ──
                  Obx(() {
                    if (controller.isFetchingMore.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CupertinoActivityIndicator(radius: 14),
                        ),
                      );
                    } else if (!controller.hasNextPage &&
                        controller.searchProduct.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text("No more products",
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant)),
                        ),
                      );
                    }
                    return const SizedBox(height: 40); // Bottom padding
                  }),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Grid Shimmer Loading Effect ──
  Widget _buildGridShimmer(ColorScheme colorScheme) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.58,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ── Beautiful Product Grid Card ─────────────────────────────────────────────
class _ProductGridCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;

  const _ProductGridCard({required this.product, required this.onTap});

  Widget _buildWishlistButton(BuildContext context, Map<String, dynamic> product) {
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
                        color: colorScheme.surfaceVariant,
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
                        color: Colors.black.withOpacity(0.6),
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

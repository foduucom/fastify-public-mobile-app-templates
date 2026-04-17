import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../components/app_bar2.dart';
import '../../../../components/shimmer/cart_shimmer.dart';
import '/app/modules/auth/auth_details.dart';
import '/constants/constants.dart';
import '/constants/product_helper.dart';
import '/core/foduuStudio/foduu_studio_layout_view.dart';
import '/app/modules/bottomar/controllers/bottombar_controller.dart';
import '/app/routes/app_pages.dart';
import '/components/buttons/appbutton.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import '/core/services/wishlistService.dart';
import '../controllers/wishlist_controller.dart';

class WishlistView extends GetView<WishlistController> {
  WishlistView({Key? key}) : super(key: key);
  final wishlist = Get.put(WishlistController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (!AuthDetails.isUserLogin()) {
      return _buildNotLoggedIn(context, colorScheme, textTheme);
    }

    return Scaffold(
      appBar: _buildAppBar(context, colorScheme, textTheme),
      body: Obx(() {
        if (controller.isLoading.value) return const CartShimmer();
        if (controller.wishlistItems.isEmpty) {
          return _buildEmptyWishlist(context, colorScheme, textTheme);
        }
        return _buildWishlistContent(context, colorScheme, textTheme);
      }),
    );
  }

  // ── Not logged in screen ──────────────────────────────────────────────────
  Widget _buildNotLoggedIn(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Scaffold(
      appBar: _buildAppBar(context, colorScheme, textTheme),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite_border_rounded,
                    size: 48, color: colorScheme.primary),
              ),
              const SizedBox(height: 24),
              Text('Login to view your wishlist',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'Save your favourite items and\nshop them anytime.',
                style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  itemText: 'Login',
                  keypressEvent: () => Get.offAllNamed(Routes.LOGIN),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Custom AppBar ─────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(65),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.surfaceContainerHighest,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text('My Wishlist',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontSize: 22,
                    )),
                const Spacer(),
                Obx(() => controller.wishlistItems.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${controller.wishlistItems.length} items',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Empty State - Minimalist Version ─────────────────────────────────────
  Widget _buildEmptyWishlist(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated heart with ripple effect
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.3),
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 55 + (10 * value),
                      color: colorScheme.primary.withOpacity(0.8),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'No favorites yet?',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Start exploring and save your favorite products here",
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                Get.find<BottombarController>().currentPageIndex.value = 0;
                Get.find<BottombarController>().pageController.jumpToPage(0);
              },
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Start Shopping'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                side: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main wishlist content ─────────────────────────────────────────────────
  Widget _buildWishlistContent(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      color: colorScheme.primary,
      child: ListView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          // ── Wishlist Items ─────────────────────────────────────────
          Obx(() => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.wishlistItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _WishListItemCard(
                    controller: controller,
                    index: index,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  );
                },
              )),

          const SizedBox(height: 16),

          // ── Dynamic Layout Widgets ─────────────────────────────────
          Obx(() => controller.widgetList.isNotEmpty
              ? FoduuStudioLayoutView.embedded(
                  widgetList: controller.widgetList,
                  isLoading: controller.isLayoutLoading)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

// ── Wishlist Item Card ────────────────────────────────────────────────────────
class _WishListItemCard extends StatelessWidget {
  final WishlistController controller;
  final int index;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _WishListItemCard({
    required this.controller,
    required this.index,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final product = controller.getProduct(index);
    final variant = controller.getVariant(index);
    final productId = controller.getProductId(index);
    final variantSlug = controller.getVariantSlug(index);
    final imageUrl = ProductHelper.getProductImage(product);

    // final variantPrice        = HelperFunctions.parseAmount(variant['sale_price'] ?? variant['price']);
    // final variantRegularPrice = HelperFunctions.parseAmount(variant['price']);
    // final hasDiscount         = HelperFunctions.parseAmount(variant['sale_price']) > 0 &&
    //     variantRegularPrice > HelperFunctions.parseAmount(variant['sale_price']);
    // final discountPct = hasDiscount
    //     ? (100 - (variantPrice * 100 / variantRegularPrice)).round()
    //     : 0;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.surfaceContainerHighest,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product Image ──────────────────────────────────────
            GestureDetector(
              onTap: () => _navigateToProduct(productId),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 100,
                      height: 110,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 100,
                        height: 110,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.image_not_supported_outlined,
                            color: colorScheme.onSurfaceVariant),
                      ),
                      progressIndicatorBuilder: (_, __, progress) => Container(
                        width: 100,
                        height: 110,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: progress.progress,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Discount badge ─────────────────────────────
                  //       if (hasDiscount)
                  //         Positioned(
                  //           top: 6, left: 6,
                  //           child: Container(
                  //             padding: const EdgeInsets.symmetric(
                  //                 horizontal: 6, vertical: 3),
                  //             decoration: BoxDecoration(
                  //               color: colorScheme.error,
                  //               borderRadius: BorderRadius.circular(6),
                  //             ),
                  //             child: Text(
                  //               '$discountPct%',
                  //               style: TextStyle(
                  //                 color: colorScheme.onError,
                  //                 fontSize: 10,
                  //                 fontWeight: FontWeight.bold,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // ── Product Details ────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Remove button row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _navigateToProduct(productId),
                          child: Text(
                            product['name'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => WishListService.to.removeFromWishlist(
                          productId: productId,
                          variantSlug: variantSlug,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(left: 6),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.favorite_rounded,
                              size: 16, color: colorScheme.error),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ── Badges row ─────────────────────────────────
                  _buildBadges(product, colorScheme, textTheme),

                  // ── Rating row ─────────────────────────────────
                  _buildRating(product, colorScheme, textTheme),

                  // Variant chip
                  if (variant['variant_name'] != null &&
                      variant['variant_name'].toString().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        variant['variant_name'],
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 10),

                  // // Price row
                  // Row(
                  //   children: [
                  //     Text(
                  //       '₹$variantPrice',
                  //       style: textTheme.titleSmall?.copyWith(
                  //         fontWeight: FontWeight.bold,
                  //         color: colorScheme.onSurface,
                  //         fontSize: 16,
                  //       ),
                  //     ),
                  //     if (hasDiscount) ...[
                  //       const SizedBox(width: 6),
                  //       Text(
                  //         '₹$variantRegularPrice',
                  //         style: textTheme.bodySmall?.copyWith(
                  //           decoration: TextDecoration.lineThrough,
                  //           decorationColor: colorScheme.error,
                  //           color: colorScheme.error,
                  //         ),
                  //       ),
                  //     ],
                  //   ],
                  // ),

                  //const SizedBox(height: 12),

                  // Add to Cart button
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToProduct(productId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      icon:
                          const Icon(Icons.add_shopping_cart_rounded, size: 16),
                      label: Text('Add to Cart',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadges(
      Map product, ColorScheme colorScheme, TextTheme textTheme) {
    final badges = <MapEntry<String, Color>>[
      if (product['featured'] == true) MapEntry('Featured', Colors.teal),
      if (product['hot'] == true) MapEntry('Hot', Colors.deepOrange),
      if (product['trending'] == true) MapEntry('Trending', Colors.purple),
      if (product['recommended'] == true)
        MapEntry('Recommended', Colors.indigo),
    ];
    if (badges.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: badges
            .map((b) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: b.value.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: b.value.withValues(alpha: 0.4)),
                  ),
                  child: Text(b.key,
                      style: TextStyle(
                          color: b.value,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildRating(
      Map product, ColorScheme colorScheme, TextTheme textTheme) {
    final rating =
        double.tryParse(product['average_rating']?.toString() ?? '0') ?? 0.0;
    final count = int.tryParse(product['rating_count']?.toString() ?? '0') ?? 0;
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.star_rounded, size: 13, color: Colors.amber.shade600),
          const SizedBox(width: 2),
          Text(rating.toStringAsFixed(1),
              style: textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600, fontSize: 11)),
          const SizedBox(width: 3),
          Text('($count)',
              style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant, fontSize: 10)),
        ],
      ),
    );
  }

  void _navigateToProduct(String productId) {
    Get.toNamed(Routes.PRODUCTDETAILS, arguments: {'productId': productId});
  }
}

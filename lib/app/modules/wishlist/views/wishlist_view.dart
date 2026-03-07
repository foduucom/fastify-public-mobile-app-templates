import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/views/home_wishlist_empty_view.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';
import 'package:get/get.dart';
import '../controllers/wishlist_controller.dart';

class WishlistView extends GetView<WishlistController> {
  WishlistView({Key? key}) : super(key: key);
  final wishlist = Get.put(WishlistController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.fetchWishlist();
        },
      ),
      appBar: AppBar(
        title: Obx(() {
          final colors = Theme.of(context).colorScheme;
          final wishlistService = Get.find<WishListService>();
          String titleText = controller.wishlistItems.isEmpty
              ? 'Wishlist ${wishlistService.wishListItemCount}'
              : 'Wishlist (${controller.wishlistItems.length})';

          return Text(
            titleText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.onSurface, // Using theme color
            ),
          );
        }),
        centerTitle: false,
        backgroundColor:
            Theme.of(context).colorScheme.surface, // Theme-aware background
        iconTheme: IconThemeData(
          color:
              Theme.of(context).colorScheme.onSurface, // Theme-aware icon color
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: HelperFunctions().loadingIndicator());
        }

        if (controller.wishlistItems.isEmpty) {
          return _buildEmptyWishlist(context, colorScheme, textTheme);
        }

        return _buildWishlistContent(context, colorScheme, textTheme);
      }),
    );
  }

  Widget _buildEmptyWishlist(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return HomeWishlistEmptyView(
      colorScheme: colorScheme,
      textTheme: textTheme,
      onShoppingPressed: () {
        Get.back();
        // Your navigation logic here
      },
      title: "Your wishlist is empty",
      description:
          "Start adding your favorite items to create your personalized shopping list.",
      icon: Icons.inventory_2_outlined,
    );
  }

  Widget _buildWishlistContent(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      child: ListView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          // ── Cart Items ──
          Obx(() => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.wishlistItems.length,
                separatorBuilder: (_, __) => Divider(
                  thickness: 1,
                  color: colorScheme.outline.withOpacity(0.3),
                ),
                itemBuilder: (context, index) {
                  if (index >= controller.wishlistItems.length) {
                    return const SizedBox.shrink();
                  }
                  return _WishListItemCard(
                    controller: controller,
                    index: index,
                  );
                },
              )),

          const Divider(thickness: 8),

          // ── Dynamic Layout Widgets ──
          Obx(() => controller.widgetList.isNotEmpty
              ? FoduuStudioLayoutView.embedded(
                  widgetList: controller.widgetList,
                  isLoading: controller.isLayoutLoading)
              : const SizedBox.shrink()),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _WishListItemCard extends StatelessWidget {
  final WishlistController controller;
  final int index;

  const _WishListItemCard({
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final product = controller.getProduct(index);
    final productId = controller.getProductId(index);
    final variantSlug = controller.getVariantSlug(index);
    final variantId = controller.getVariantId(index);

    final productName = ProductHelper.getProductName(product);
    final imageUrl = ProductHelper.getProductImage(product);
    final storeName = controller.getStoreName(index);
    final priceInfo = controller.getPriceInfo(index);
    final productType = priceInfo['productType'];

    return InkWell(
      onTap: () => _navigateToProduct(productId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Row(
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
                          child: Icon(
                            Icons.image_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
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
                            horizontal: 8,
                            vertical: 4,
                          ),
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
                  ],
                ),
                // Product Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          productName,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          storeName,
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (productType == 'variable')
                          _buildVariablePrice(context, priceInfo)
                        else
                          _buildSimplePrice(context, priceInfo),
                        const Spacer(),
                        // Add to cart controls
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Quantity Selector
                            Container(
                              height: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: DefaultThemeColors.darklight,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 28,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.remove, size: 16),
                                      onPressed: () => controller
                                          .decrementItemQuantity(index),
                                    ),
                                  ),
                                  Obx(() => Text(
                                        controller
                                            .getItemQuantity(index)
                                            .toString(),
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      )),
                                  SizedBox(
                                    width: 28,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.add, size: 16),
                                      onPressed: () => controller
                                          .incrementItemQuantity(index),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Add to Cart Button
                            Expanded(
                              child: PrimaryActionButton(
                                onPressed: () => controller.addToCart(index),
                                text: 'Add Cart',
                                height: 0.05, // Compact height
                                fontSize: 12, // Smaller font for consistency
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Remove Button at top right
            Positioned(
              right: 5,
              top: 5,
              child: InkWell(
                onTap: () {
                  WishListService.to.removeFromWishlist(
                    productId: productId,
                    variantId: variantId,
                  );
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Remove",
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Variable product price display (compact version from HomeProducts)
  Widget _buildVariablePrice(
      BuildContext context, Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      '₹${priceInfo['lowestPrice']} - ₹${priceInfo['highestPrice']}',
      style: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: colorScheme.primary,
      ),
    );
  }

  /// Simple product price display with discount (compact version from HomeProducts)
  Widget _buildSimplePrice(
      BuildContext context, Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RichText(
      text: TextSpan(
        text: '₹${priceInfo['productPrice']}',
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: colorScheme.primary,
        ),
        children: [
          if (priceInfo['discountRate'] != null &&
              priceInfo['discountRate'].toString().isNotEmpty) ...[
            const TextSpan(text: '  '),
            TextSpan(
              text: '₹${priceInfo['discountPrice']}',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 10,
                decoration: TextDecoration.lineThrough,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: priceInfo['discountRate'],
              style: textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToProduct(String productId) {
    Get.toNamed(Routes.PRODUCTDETAILS, arguments: {'productId': productId});
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../components/shimmer/cart_shimmer.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';
import '../controllers/wishlist_controller.dart';

class WishlistView extends GetView<WishlistController> {
  WishlistView({Key? key}) : super(key: key);
  final wishlist = Get.put(WishlistController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (!AuthDetails.isUserLogin()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Wishlist',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'lato',
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Text(
              'Login to View Wishlist',
              style: Theme.of(context).textTheme.titleLarge,
            )),
            const SizedBox(height: 15),
            SizedBox(
              width: Get.width * 0.6,
              child: AppButton(
                  itemText: 'Login',
                  keypressEvent: () {
                    // controller.box.erase();
                    Get.offAllNamed(Routes.LOGIN);
                  }),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'wishlist_fab',
        onPressed: () {
          controller.fetchWishlist();
        },
      ),
      appBar: AppBar(
        title: Obx(() => Text(
              controller.wishlistItems.isEmpty
                  ? 'Wishlist ${WishListService.to.wishListItemCount}'
                  : 'Wishlist (${controller.wishlistItems.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return  const CartShimmer();
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
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: pageSurroundingPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Image(
                      image: AssetImage('assets/images/emptyimagecart.png'))),
              const SizedBox(height: 20),
              Text('whoops you no like products yet'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  )),
              const SizedBox(height: 10),
              Text(
                  'Looks like you haven’t seee , You will find a lot of interesting products on our “Shop” page'
                      .tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 20),
              AppButton(
                  keypressEvent: () {
                    Get.back();
                    Get.find<BottombarController>().currentPageIndex.value = 0;
                    Get.find<BottombarController>()
                        .pageController
                        .jumpToPage(0);
                  },
                  itemText: 'GO BACK')
            ],
          ),
        ),
      ),
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
    final variant = controller.getVariant(index);
    final productId = controller.getProductId(index);
    final variantSlug = controller.getVariantSlug(index);

    print('varienat in wishlist ${variant.toString()}');

    // Use ProductHelper to get image and price info
    final imageUrl = ProductHelper.getProductImage(product);

    // Get variant's effective price
    final variantPrice = HelperFunctions.parseAmount(variant['sale_price'] ?? variant['price']);
    final variantRegularPrice = HelperFunctions.parseAmount(variant['price']);
    final hasDiscount = HelperFunctions.parseAmount(variant['sale_price']) > 0 &&
        variantRegularPrice > HelperFunctions.parseAmount(variant['sale_price']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Product Image ──
          GestureDetector(
            onTap: () => _navigateToProduct(productId),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 100,
                height: 110,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 100,
                  height: 110,
                  color: colorScheme.surfaceVariant,
                  child: Icon(Icons.image_not_supported_outlined,
                      color: colorScheme.onSurfaceVariant),
                ),
                progressIndicatorBuilder: (_, __, progress) => Container(
                  width: 100,
                  height: 110,
                  color: colorScheme.surfaceVariant,
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
          ),

          const SizedBox(width: 12),

          // ── Product Details ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _navigateToProduct(productId),
                        child: Text(
                          product['name'] ?? 'ff',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        WishListService.to.removeFromWishlist(
                          productId: productId,
                          variantSlug: variantSlug,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                        child: Icon(Icons.close,
                            size: 20, color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Variant Name
                if (variant['variant_name'] != null &&
                    variant['variant_name'].toString().isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      variant['variant_name'],
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Price Row
                Row(
                  children: [
                    Text(
                      '₹$variantPrice',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(width: 6),
                      Text(
                        '₹$variantRegularPrice',
                        style: textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${(100 - (variantPrice * 100 / variantRegularPrice)).round()}% off',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProduct(String productId) {
    Get.toNamed(Routes.PRODUCTDETAILS, arguments: {'productId': productId});
  }
}

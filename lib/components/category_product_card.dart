import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/components/cart_auth_bottom_sheet.dart';
import 'package:zouhi/components/catalog_mode_bottom_sheet.dart';
import 'package:zouhi/app/data/models/category_products_page.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:zouhi/app/modules/shop/views/productdetail_view.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/components/home_component/trending_product_card.dart';
import 'package:zouhi/constants/helper_functions.dart';

/// Product card used by the category screen and the home sections.
/// Adopts the unified TrendingProducts card from ShopView for app-wide consistency.
class CategoryProductCard extends StatelessWidget {
  final CategoryProduct product;
  final int index;
  const CategoryProductCard({super.key, required this.product, this.index = 0});

  int _discountPercent(double original, double effective) {
    if (original <= 0) return 0;
    return (((original - effective) / original) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final double effPrice = product.effectivePrice.toConvertedPrice();
    final double origPrice = product.price.toConvertedPrice();

    final String displayPrice = effPrice.toStringAsFixed(2);
    final String displayOriginal =
        product.hasDiscount ? origPrice.toStringAsFixed(2) : '';

    final String discountRate = product.hasDiscount && origPrice > 0
        ? '${_discountPercent(origPrice, effPrice)}% off'
        : '';

    final String imageUrl =
        product.image == null ? '' : HelperFunctions().getImage(product.image);

    final String productId = product.id;
    final bool isCatalogMode = product.isCatalogMode;
    final String catalogButtonText = product.catalogButtonText;

    return GestureDetector(
      onTap: () => Get.to(
        () => ProductdetailView(),
        preventDuplicates: false,
        arguments: {'productId': productId},
      ),
      child: TrendingProducts(
        index: index,
        lowestPrice: displayPrice,
        highestPrice: displayPrice,
        assetImage: imageUrl,
        productName: product.name,
        discountPrice: displayOriginal,
        productPrice: displayPrice,
        discountRate: discountRate,
        isCatalogMode: isCatalogMode,
        catalogButtonText: catalogButtonText,
        onCatalogModeTap: () {
          showCatalogModeBottomSheet(
            context,
            productName: product.name,
            productId: productId,
            productImage: product.image,
            buttonText: catalogButtonText,
          );
        },
        productType: product.type,
        productId: productId,
        variantId: product.variantId,
        rating: product.averageRating,
        reviewCount: product.ratingCount,
        onAddToCart: isCatalogMode
            ? null
            : () async {
                if (!AuthDetails.isUserLogin()) {
                  showCartAuthBottomSheet();
                  return;
                }
                if (!Get.isRegistered<CartController>()) {
                  Get.put(CartController());
                }
                await Get.find<CartController>().addToCart(
                  productId: productId,
                  quantity: 1,
                  variantId: product.variantId,
                  productType: product.type,
                );
              },
        onlike: () async {
          if (!Get.isRegistered<WishlistController>()) {
            Get.put(WishlistController(), permanent: true);
          }
          final wishlist = Get.find<WishlistController>();
          if (!HelperFunctions.checkAndPromptLogin(
              message: "Please login to add products to your wishlist.")) {
            return;
          }
          if (wishlist.wishlistProductIds.contains(productId)) {
            wishlist.wishlistProductIds.remove(productId);
            wishlist.update();
            await wishlist.removeProductFromWishlist(productid: productId);
          } else {
            wishlist.wishlistProductIds.add(productId);
            wishlist.update();
            await wishlist.addProductToWishlist(productid: productId);
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:zouhi/app/modules/shop/bindings/shop_binding.dart';
import 'package:zouhi/app/modules/shop/views/productdetail_view.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/buttons/appbutton.dart';
import 'package:zouhi/components/commonWidgets/appbarIcons.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:get/get.dart';

import 'package:zouhi/app/controllers/internetconnection_controller.dart';
import 'package:zouhi/components/check_internet_widget.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';
import 'package:zouhi/components/home_component/trending_product_card.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/components/product_image_placeholder.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return !AuthDetails.isUserLogin()
        ? Scaffold(
            backgroundColor: context.themeBackground,
            appBar: AppBar(
              title: Text(
                'Wishlist'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: context.themetitleColor,
                ),
              ),
              backgroundColor: context.themeWhiteColor,
              elevation: 0.0,
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  // Hero Incentive Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: context.themeWhiteColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.themeBorderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.themePrimaryLight,
                            border: Border.all(
                              color: context.themePrimaryColor.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 36,
                            color: context.themePrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Save What You Love',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: context.themetitleColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Keep track of your favorite fiber optics and networking equipment. Sign in to sync your wishlist across all devices.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            color: context.themeSecondrytext,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0B7FD4),
                                      Color(0xFF1257A5),
                                      Color(0xFF0A2A6B),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1257A5)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    isOtpLogin
                                        ? Get.toNamed(Routes.MOBILELOGIN)
                                        : Get.toNamed(Routes.LOGIN);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Sign In to Sync',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: OutlinedButton(
                                  onPressed: () {
                                    final bottombar =
                                        Get.find<BottombarController>();
                                    bottombar.onTabChange(1);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: context.themePrimaryColor,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Explore Shop',
                                    style: TextStyle(
                                      color: context.themePrimaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Trending recommendations
                  TrendingProductSection(
                    productType: 'trending',
                    categoryIds: '',
                    heading: 'Popular Equipment',
                    subHeading: 'Browse top trending network products',
                    isShowSeeAll: true,
                    isShowTwoRows: false,
                    count: 10,
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            backgroundColor: context.themeWhiteColor,
            appBar: AppBar(
              backgroundColor: context.themeWhiteColor,
              title: Text('Wishlist',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.themeTextColor)),
              titleSpacing: 0,
              elevation: 0,
              centerTitle: true,
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Obx(
                      () => Get.find<BottombarController>().cartbadge(
                          child: CartIcon(() {
                            Get.find<BottombarController>()
                                .pageController
                                .jumpToPage(2);
                            Get.find<BottombarController>()
                                .currentPageIndex
                                .value = 2;
                          }),
                          badgeNumber: Get.find<CartController>().cartItemCount),
                    ),
                  ),
                ),
              ],
            ),
              body: RefreshIndicator(
                onRefresh: () async {
                  return await controller.getwishlist();
                },
                child: Obx(() {
                  final isOffline = !Get.find<InternetconnectionController>()
                      .connectionStatus
                      .value;
                  if ((isOffline || controller.loadError) &&
                      controller.wishList.isEmpty &&
                      !controller.isLoading.value) {
                    final failure = controller.loadFailure.value;
                    if (isOffline || failure == LoadFailure.offline) {
                      return InternetConnectionError(
                        onRetry: () {
                          controller.getwishlist();
                        },
                      );
                    }
                    return GenericErrorRetry(
                      onRetry: () {
                        controller.getwishlist();
                      },
                    );
                  }

                  if (controller.isLoading.value &&
                      controller.wishList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.wishList.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        alignment: Alignment.center,
                        height: Get.height -
                            AppBar().preferredSize.height -
                            MediaQuery.of(context).padding.top -
                            40,
                        padding: pageSurroundingPadding,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                child: Image(
                                    image: AssetImage(
                                        'assets/images/emptyimagecart.png'))),
                            const SizedBox(height: 20),
                            Text('whoops you no like products yet'.tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: context.themeTextColor)),
                            const SizedBox(height: 10),
                            Text(
                                'Looks like you haven’t seee , You will find a lot of interesting products on our “Shop” page'
                                    .tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: context.themeSecondrytext,
                                    fontSize: 16)),
                            const SizedBox(height: 20),
                            AppButton(
                                keypressEvent: () {
                                  BottombarController.switchTab(0);
                                },
                                itemText: 'GO BACK')
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => Divider(
                            thickness: 10,
                            color: context.themegreyColor,
                            height: 20,
                          ),
                      itemCount: controller.wishList.length,
                      shrinkWrap: true,
                      itemBuilder: ((context, index) {
                        var item = controller.wishList[index];
                        var product = item['product'] ?? {};
                        var variant = controller.getVariantForItem(item);
                        var variants = (product['variants'] ??
                            product['variant_ids'] ??
                            []) as List;

                        double? originalPrice;
                        double? salePrice;
                        bool isVariable = product['type'] == 'variable' ||
                            product['type'] == 'variant';

                        if (variant is Map && variant.isNotEmpty) {
                          originalPrice = double.tryParse(
                              variant['price']?.toString() ?? '0');
                          salePrice = double.tryParse(
                              variant['sale_price']?.toString() ?? '0');
                        } else if (product['type'] == 'simple') {
                          Map? v = variants.isNotEmpty ? variants.first : null;
                          originalPrice = double.tryParse(
                              v?['price']?.toString() ??
                                  product['price']?.toString() ??
                                  '0');
                          salePrice = double.tryParse(
                              v?['sale_price']?.toString() ??
                                  product['sale_price']?.toString() ??
                                  '0');
                        } else if (isVariable) {
                          double? minEffective;
                          Map? lowestVariant;
                          for (var v in variants) {
                            if (v is! Map) continue;
                            double vP = double.tryParse(
                                    v['price']?.toString() ?? '0') ??
                                0.0;
                            double vSP = double.tryParse(
                                    v['sale_price']?.toString() ?? '0') ??
                                0.0;
                            double effective = (vSP > 0) ? vSP : vP;
                            if (minEffective == null ||
                                effective < minEffective) {
                              minEffective = effective;
                              lowestVariant = v;
                            }
                          }
                          if (lowestVariant != null) {
                            originalPrice = double.tryParse(
                                lowestVariant['price']?.toString() ?? '0');
                            salePrice = double.tryParse(
                                lowestVariant['sale_price']?.toString() ?? '0');
                          }
                        }

                        if (salePrice != null && salePrice <= 0)
                          salePrice = null;

                        String displayPrice = (salePrice != null)
                            ? salePrice.toStringAsFixed(2)
                            : (originalPrice?.toStringAsFixed(2) ?? '0.00');
                        String displayOriginal =
                            (salePrice != null && originalPrice != null)
                                ? originalPrice.toStringAsFixed(2)
                                : '';

                        String discountRate = '';
                        if (salePrice != null &&
                            originalPrice != null &&
                            originalPrice > 0) {
                          discountRate =
                              '${((originalPrice - salePrice) * 100 / originalPrice).round()}% off';
                        }

                        String? lowestP, highestP;
                        if (isVariable) {
                          double? min, max;
                          for (var v in variants) {
                            if (v is! Map) continue;
                            double vP = double.tryParse(
                                    v['price']?.toString() ?? '0') ??
                                0.0;
                            double vSP = double.tryParse(
                                    v['sale_price']?.toString() ?? '0') ??
                                0.0;
                            double effective = (vSP > 0) ? vSP : vP;
                            if (min == null || effective < min) min = effective;
                            if (max == null || effective > max) max = effective;
                          }
                          lowestP = min?.toStringAsFixed(2);
                          highestP = max?.toStringAsFixed(2);
                        }

                        bool hasSelectedVariant = variant is Map &&
                            variant.isNotEmpty &&
                            variant['_id'] != null &&
                            variant['_id'] != product['_id'];

                        return Padding(
                          padding: pageSurroundingPadding,
                          child: WishListCard(
                            highestPrice:
                                hasSelectedVariant ? '' : (highestP ?? ''),
                            lowestPrice:
                                hasSelectedVariant ? '' : (lowestP ?? ''),
                            productType: hasSelectedVariant
                                ? 'simple'
                                : (product['type'] ?? 'simple'),
                            assetImage: HelperFunctions().getImage([
                              variant is Map ? variant['front_image'] : null,
                              variant is Map ? variant['featured_image'] : null,
                              product['featured_image'],
                            ]),
                            name: product['name'] ?? '',
                            category: '',
                            price: displayOriginal,
                            discountPrice: displayPrice,
                            discountRate: discountRate,
                            controller: controller,
                            variantName: variant != null &&
                                    hasSelectedVariant &&
                                    isVariable
                                ? (variant['name'] ?? variant['variant'] ?? '')
                                : '',
                            onRemove: () async {
                              Get.back(); // Close the confirmation dialog

                              var item = controller.wishList[index];
                              var product = item['product'];
                              String? pid = product is Map
                                  ? product['_id']?.toString()
                                  : item['product_id']?.toString();

                              if (pid != null) {
                                var variant =
                                    controller.getVariantForItem(item);
                                String? variantIdStr = variant != null
                                    ? (variant['_id'] ?? variant['id'])
                                        ?.toString()
                                    : null;

                                // Optimistic UI update: remove from local state immediately
                                controller.toggleLocalWishlist(
                                    pid, variantIdStr, false);

                                // Call the API
                                await controller.removeProductFromWishlist(
                                    productid: pid, variant_id: variantIdStr);

                                HelperFunctions.defaultdialogbox(
                                    'The Product Has been removed from your Wishlist',
                                    Colors.green);

                                // Auto-close success dialog after 2 seconds
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (Get.isDialogOpen ?? false) Get.back();
                                });
                              }
                            },
                              onAddToCart: () async {
                                var item = controller.wishList[index];
                                var product = item['product'];
                                String? pid = product is Map
                                    ? product['_id']?.toString()
                                    : item['product_id']?.toString();

                                if (pid == null) return;

                                var variant = controller.getVariantForItem(item);
                                String? variantIdStr = variant != null
                                    ? (variant['_id'] ?? variant['id'])
                                        ?.toString()
                                    : null;

                                // Fallback for variantId if missing
                                if ((variantIdStr == null ||
                                        variantIdStr.isEmpty ||
                                        variantIdStr == pid) &&
                                    product is Map) {
                                  var variants = (product['variant_ids'] ??
                                      product['variants']) as List?;
                                  if (variants != null && variants.isNotEmpty) {
                                    final firstV = variants[0];
                                    if (firstV is Map) {
                                      variantIdStr = firstV['_id']?.toString();
                                    } else if (firstV is String) {
                                      variantIdStr = firstV;
                                    }
                                  }
                                }

                                if (variantIdStr == pid) {
                                  variantIdStr = '';
                                }

                                var cartController = Get.find<CartController>();

                                // Check if already in cart
                                bool isAlreadyInCart =
                                    cartController.cartItems.any((cartItem) {
                                  var cpId =
                                      cartItem['product']?['_id']?.toString() ??
                                          cartItem['product_id']?.toString();
                                  var cvId =
                                      cartItem['variant']?['_id']?.toString() ??
                                          cartItem['variant_id']?.toString();
                                  return cpId == pid &&
                                      (cvId == variantIdStr ||
                                          variantIdStr == null ||
                                          variantIdStr.isEmpty);
                                });

                                if (isAlreadyInCart) {
                                  HelperFunctions.defaultdialogbox(
                                      'Product Already Added In Cart',
                                      themeGreenColor);
                                  Future.delayed(const Duration(seconds: 2))
                                      .then((value) {
                                    if (Get.isDialogOpen ?? false) Get.back();
                                  });
                                } else {
                                  HelperFunctions().showOverlayLoader();

                                  // Add to cart
                                  await cartController.addToCart(
                                      productId: pid,
                                      quantity: 1,
                                      variantId: variantIdStr ?? '',
                                      productType: (product is Map
                                              ? product['type']
                                              : null) ??
                                          'simple');

                                  Get.until((route) => !Get.isDialogOpen!);
                                  BottombarController.switchTab(2);
                                }
                              },
                            goToProductDetails: () {
                              var item = controller.wishList[index];
                              var product = item['product'];
                              var variant = controller.getVariantForItem(item);
                              String? variantIdStr = variant != null
                                  ? (variant['_id'] ?? variant['id'])
                                      ?.toString()
                                  : null;

                              Get.to(ProductdetailView(),
                                  binding: ShopBinding(),
                                  arguments: {
                                    'productId': product['_id'],
                                    'variantId': variantIdStr,
                                  });
                            },
                          ),
                        );
                      }));
                }),
              ),
            );
  }
}

class WishListCard extends StatelessWidget {
  WishListCard(
      {Key? key,
      required this.assetImage,
      required this.name,
      required this.category,
      required this.price,
      required this.discountPrice,
      required this.discountRate,
      required this.onRemove,
      required this.onAddToCart,
      required this.productType,
      required this.lowestPrice,
      required this.highestPrice,
      required this.goToProductDetails,
      this.variantName = '',
      required this.controller})
      : super(key: key);
  String? assetImage;
  String name;
  String category;

  String price;
  String discountPrice;
  String discountRate;

  final String productType;
  final String lowestPrice;
  final String highestPrice;
  final String variantName;
  WishlistController controller;
  VoidCallback onRemove;
  VoidCallback onAddToCart;
  VoidCallback goToProductDetails;

  String get _currencySymbol {
    if (Get.isRegistered<CurrencyController>()) {
      return Get.find<CurrencyController>()
              .selectedCurrency['symbol']
              ?.toString() ??
          currency;
    }
    return currency;
  }

  @override
  Widget build(BuildContext context) {
    print('assets image $assetImage');
    return GestureDetector(
      onTap: goToProductDetails,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: SizedBox(
                height: 100,
                child: (assetImage != null &&
                        assetImage.toString().isNotEmpty &&
                        assetImage.toString() !=
                            HelperFunctions.getNoImage())
                    ? CachedNetworkImage(
                        progressIndicatorBuilder: (context, url, progress) {
                          return HelperFunctions().loadingIndicator();
                        },
                        errorWidget: (context, url, error) =>
                            const ProductImagePlaceholder(radius: 5),
                        imageUrl: assetImage.toString(),
                        height: 100,
                        fit: BoxFit.contain,
                      )
                    : const ProductImagePlaceholder(radius: 5),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.themeTextColor)),
              if (variantName.isNotEmpty && variantName != name)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    variantName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: context.themeSecondrytext,
                    ),
                  ),
                ),
              const SizedBox(height: 5.0),
              Obx(
                () => productType == 'variant'
                    ? Row(
                        children: [
                          Text(
                            '$_currencySymbol${lowestPrice.toString()} - $_currencySymbol${highestPrice.toString()}',
                            style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: context.themeTextColor),
                          ),
                        ],
                      )
                    : RichText(
                        text: TextSpan(
                            text: '$_currencySymbol${discountPrice.toString()} ',
                            style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: context.themeTextColor),
                            children: [
                              if (price != '')
                                TextSpan(
                                    text: '$_currencySymbol$price',
                                    style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: context.themeSecondrytext)),
                              if (discountRate != '')
                                TextSpan(
                                    text: ' ($discountRate)',
                                    style: TextStyle(
                                        color: context.themeRedColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                            ]),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(height: 1.0, color: context.themeBorderColor),
              ),
              SizedBox(
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: GestureDetector(
                        onTap: () {
                          onAddToCart();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 15,
                                color: context.themeTextColor,
                              ),
                              const SizedBox(width: 4.0),
                              Text('Add to Cart',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: context.themeTextColor))
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1.1,
                      color: context.themeBorderColor,
                      height: 15,
                    ),
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        onTap: () {
                          removeItemModel(context: context, onRemove: onRemove);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: context.themeTextColor,
                              ),
                              const SizedBox(width: 4.0),
                              Text('Remove',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: context.themeTextColor))
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  removeItemModel(
      {required BuildContext context, required VoidCallback onRemove}) {
    return Get.dialog(
      AlertDialog(
        backgroundColor: context.themeWhiteColor,
        actionsPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10)
            .copyWith(top: 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Remove Item',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.themeTextColor),
            ),
            const SizedBox(height: 8),
            Text(
              "Are you sure you want to remove product from your wishlist?",
              style: TextStyle(
                  fontSize: 13, color: context.themeSecondrytext),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Add logic for going back
              Get.back();
            },
            child: const Text(
              'Back',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: onRemove,
            child: const Text(
              'Remove',
              style: TextStyle(color: themeRedColor),
            ),
          ),
        ],
      ),
    );
    // removeItemModel(BuildContext context, VoidCallback onremove) {
    //   return Get.defaultDialog(
    //       title: "",
    //       titleStyle: const TextStyle(height: 0.0),
    //       contentPadding: EdgeInsets.zero,
    //       content: Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
    //         child: SizedBox(
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               Text(
    //                 'Remove Item',
    //                 style: txtTheme().headlineMedium,
    //               ),
    //               Text(
    //                 "Are you sure you want to remove or move this item from the cart?",
    //                 style:
    //                     txtTheme().headlineSmall!.copyWith(color: themeSecondrytext),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //       actions: [
    //         Material(
    //           elevation: 05,
    //           child: SizedBox(
    //               width: Get.width,
    //               height: 50,
    //               child: Row(
    //                 children: [
    //                   Expanded(
    //                     flex: 1,
    //                     child: GestureDetector(
    //                       onTap: () {
    //                         Get.back();
    //                       },
    //                       child: Center(
    //                         child: Text("Back",
    //                             style:
    //                                 txtTheme().headlineMedium!.copyWith(fontSize: 16)),
    //                       ),
    //                     ),
    //                   ),
    //                   const VerticalDivider(
    //                     width: 20,
    //                     thickness: 1.5,
    //                     indent: 10,
    //                     endIndent: 10,
    //                     color: themegreyColor,
    //                   ),
    //                   Expanded(
    //                     flex: 1,
    //                     child: GestureDetector(
    //                       onTap: onremove,
    //                       child: Center(
    //                         child: Text("Remove".toUpperCase(),
    //                             style: txtTheme().headlineMedium!.copyWith(
    //                                 color: themeRedColor, fontSize: 16)),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               )),
    //         )
    //       ],
    //       radius: 0.0);
    // }
  }
}

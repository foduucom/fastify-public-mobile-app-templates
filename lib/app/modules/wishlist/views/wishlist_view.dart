import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/modules/home_wishlist/views/home_wishlist_empty_view.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/components/commonWidgets/appbarIcons.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:get/get.dart';

import '../../../../../constants/constants.dart';
import '../controllers/wishlist_controller.dart';

class WishlistView extends GetView<WishlistController> {
  WishlistView({Key? key}) : super(key: key);
  final wishlist = Get.put(WishlistController());

  @override
  Widget build(BuildContext context) {
    return !AuthDetails.isUserLogin()
        ? SafeArea(
            child: Scaffold(
              // appBar: AppBar(title: Text('Wishlist'.tr), elevation: 0.0),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: Text(
                    'Login to View Wishlist',
                    style: txtTheme().displayMedium,
                  )),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: Get.width * 0.6,
                    child: AppButton(
                        itemText: 'Login',
                        keypressEvent: () {
                          controller.box.erase();
                          isOtpLogin
                              ? Get.offAllNamed(Routes.MOBILELOGIN)
                              : Get.offAllNamed(Routes.LOGIN);
                        }),
                  ),
                ],
              ),
            ),
          )
        : Obx(
            () => controller.wishList.isEmpty
                ? HomeWishlistEmptyView()
                : SafeArea(
                    child: Scaffold(
                      appBar: AppBar(
                        title: const Text('Wishlist',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        titleSpacing: 0,
                        elevation: 0,
                        centerTitle: true,
                        actions: [
                          // Obx(() =>
                          //     Get.find<BottombarController>().cartbadge(child: HeartIcon(() {
                          //       // Get.toNamed(Routes.WISHLIST);
                          //     }))),
                          const SizedBox(width: 14),
                          Obx(
                            () => Get.find<BottombarController>().cartbadge(
                                child: CartIcon(() {
                                  Get.find<BottombarController>()
                                      .pageController
                                      .jumpToPage(2);
                                  Get.find<BottombarController>()
                                      .currentPageIndex
                                      .value = 2;
                                }),
                                badgeNumber: Get.find<CartController>()
                                    .productDetails
                                    .length),
                          ),
                          const SizedBox(width: 15)
                        ],
                      ),
                      body: RefreshIndicator(
                        onRefresh: () async {
                          // controller.wishList.clear();
                          return await controller.getwishlist();
                        },
                        child: Obx(
                          () => ListView.separated(
                              // physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    thickness: 10,
                                    // color: themegreyColor,
                                    height: 20,
                                  ),
                              itemCount: controller.wishList.length,
                              shrinkWrap: true,
                              itemBuilder: ((context, index) {
                                var lowest;
                                var highest;
                                if (controller.wishList[index]['product']
                                        ['type'] ==
                                    'variant') {
                                  lowest = HelperFunctions.lowestPrice(
                                      controller.wishList[index]['product']
                                          ['variant_ids']);
                                  highest = HelperFunctions.highestPrice(
                                      controller.wishList[index]['product']
                                          ['variant_ids']);
                                }
                                return Padding(
                                  padding: pageSurroundingPadding,
                                  child: WishListCard(
                                    highestPrice: highest.toString(),
                                    lowestPrice: lowest.toString(),
                                    productType: controller.wishList[index]
                                        ['product']['type'],
                                    assetImage: controller.wishList[index]
                                                ['product']['featured_image'] ==
                                            null
                                        ? HelperFunctions.getNoImage()
                                        : url +
                                            controller.wishList[index]
                                                    ['product']
                                                ['featured_image']['filepath'],
                                    name: controller.wishList[index]['product']
                                        ['name'],
                                    category: '',
                                    price: controller.wishList[index]['product']
                                                    ['variant_ids'][0]
                                                ['sale_price'] ==
                                            null
                                        ? ''
                                        : controller.wishList[index]['product']
                                                ['variant_ids'][0]['price']
                                            .toString(),
                                    discountPrice: controller.wishList[index]
                                                    ['product']['variant_ids']
                                                [0]['sale_price'] ==
                                            null
                                        ? controller.wishList[index]['product']
                                                ['variant_ids'][0]['price']
                                            .toString()
                                        : controller.wishList[index]['product']
                                                ['variant_ids'][0]['sale_price']
                                            .toString(),
                                    discountRate: controller.wishList[index]
                                                    ['product']['variant_ids']
                                                [0]['sale_price'] !=
                                            null
                                        ? "${(100 - controller.wishList[index]['product']['variant_ids'][0]['sale_price'] * 100 / controller.wishList[index]['product']['variant_ids'][0]['price']).round()}" +
                                            "%off"
                                        : '',
                                    controller: controller,
                                    onRemove: () async {
                                      Get.back();

                                      await controller.addProductToWishlist(
                                          productid: controller.wishList[index]
                                              ['product']['_id']);
                                      await controller.getwishlist();
                                      HelperFunctions.defaultdialogbox(
                                        'The Product Has been removed from your Wishlist',
                                      );
                                      await Future.delayed(
                                          Duration(seconds: 3));
                                      Get.until((route) => !Get.isDialogOpen!);

                                      // Get.back();
                                    },
                                    onAddToCart: () async {
                                      if (controller.wishList[index]['product']
                                              ['type'] ==
                                          'simple') {
                                        HelperFunctions.defaultdialogbox(
                                          'The Product Has been added to your cart successfully',
                                        );
                                        Get.find<CartController>().addToCart(
                                            productId:
                                                controller.wishList[index]
                                                    ['product']['_id'],
                                            quantity: 1,
                                            variantName: 'null',
                                            productType: 'simple');
                                        controller.addProductToWishlist(
                                            productid: controller
                                                .wishlistProductIds[index]);
                                        controller.wishlistProductIds
                                            .removeAt(index);
                                        controller.wishList.removeAt(index);
                                        await Future.delayed(
                                            Duration(seconds: 3));

                                        Get.until(
                                            (route) => !Get.isDialogOpen!);
                                        // Get.toNamed(Routes.CART);
                                      } else {
                                        // Get.to(() => ProductView(),
                                        //     binding: ShopBinding(),
                                        //     arguments: {
                                        //       'productId':
                                        //           controller.wishList[index]
                                        //               ['product']['_id']
                                        //     });
                                      }
                                    },
                                    goToProductDetails: () {
                                      // Get.to(ProductdetailView(),
                                      //     binding: ShopBinding(),
                                      //     arguments: {
                                      //       'productId':
                                      //           controller.wishList[index]
                                      //               ['product']['_id']
                                      //     });
                                    },
                                  ),
                                );
                              })),
                        ),
                      ),
                    ),
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
      required this.controller})
      : super(key: key);
  String assetImage;
  String name;
  String category;

  String price;
  String discountPrice;
  String discountRate;

  final String productType;
  final String lowestPrice;
  final String highestPrice;
  WishlistController controller;
  VoidCallback onRemove;
  VoidCallback onAddToCart;
  VoidCallback goToProductDetails;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: goToProductDetails,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              // child: Image.asset(assetImage, height: 110, fit: BoxFit.cover),
              child: CachedNetworkImage(
                progressIndicatorBuilder: (context, url, progress) {
                  return HelperFunctions().loadingIndicator();
                },
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(color: Colors.grey.shade300),
                  child: const Center(
                    child: Icon(Icons.error),
                  ),
                ),
                imageUrl: assetImage,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: txtTheme().titleLarge),
              // const SizedBox(height: 5.0),
              // Text(category,
              //     style: txtTheme()
              //         .titleLarge!
              //         .copyWith(fontSize: 13, color: themeSecondrytext)),
              const SizedBox(height: 5.0),
              productType == 'variant'
                  ? Row(
                      children: [
                        Text(
                          '\u{20B9}${lowestPrice.toString()} - \u{20B9}${highestPrice.toString()}',
                          style: txtTheme()
                              .titleLarge!
                              .copyWith(fontSize: 12, fontFamily: 'Lato'),
                        ),
                      ],
                    )
                  : RichText(
                      text: TextSpan(
                          text: '\u{20B9}${discountPrice.toString()} ',
                          style: txtTheme()
                              .titleLarge!
                              .copyWith(fontSize: 12, fontFamily: 'Lato'),
                          children: [
                            if (price != '')
                              TextSpan(
                                  text: '\u{20B9}$price',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                  )),
                            if (discountRate != '')
                              TextSpan(
                                  text: ' ($discountRate)',
                                  style: txtTheme()
                                      .titleLarge!
                                      .copyWith(fontSize: 12)),
                          ]),
                    ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(
                  height: 1.0,
                ),
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
                              const Icon(
                                Icons.shopping_bag,
                                size: 15,
                              ),
                              const SizedBox(width: 4.0),
                              Text('Add to Cart',
                                  style: txtTheme()
                                      .titleLarge!
                                      .copyWith(fontSize: 13))
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1.1,
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
                              const Icon(
                                Icons.delete,
                                size: 16,
                              ),
                              const SizedBox(width: 4.0),
                              Text('Remove',
                                  style: txtTheme()
                                      .titleLarge!
                                      .copyWith(fontSize: 13))
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
        actionsPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10)
            .copyWith(top: 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Remove Item',
              style: txtTheme().headlineSmall,
            ),
            Text(
              "Are you sure you want to remove product from you wishlist?",
              style: txtTheme().titleLarge!,
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
              style: TextStyle(),
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
    //                 style: txtTheme().headlineSmall,
    //               ),
    //               Text(
    //                 "Are you sure you want to remove or move this item from the cart?",
    //                 style:
    //                     txtTheme().titleLarge!.copyWith(color: themeSecondrytext),
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
    //                                 txtTheme().headlineSmall!.copyWith(fontSize: 16)),
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
    //                             style: txtTheme().headlineSmall!.copyWith(
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

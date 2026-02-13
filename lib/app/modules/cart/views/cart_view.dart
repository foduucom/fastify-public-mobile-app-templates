import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foduu_ecommerce/app/modules/address/views/addupdateAddress_view.dart';
import 'package:foduu_ecommerce/app/modules/address/views/delivery_detial_view.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/modules/cart/views/cupon_view.dart';
import 'package:foduu_ecommerce/app/modules/cart/views/empycart_view.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/components/buttons/bottombutton.dart';
import 'package:foduu_ecommerce/components/oderdetail.dart';
import 'package:foduu_ecommerce/components/order_detail.dart';
import 'package:foduu_ecommerce/components/productcard.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';

class CartView extends GetView<CartController> {
  CartView({Key? key}) : super(key: key);

  var bottomController = Get.find<BottombarController>();
  // var cartController = Get.find<ShoppingCartController>();
  // var wishListController = Get.find<WishlistController>();
  WishlistController wishListController = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    return
        //  Obx(
        //   () => controller.productDetails.isEmpty
        //       ? Scaffold(
        //           appBar: AppBar(
        //             title: const Text('Shop',
        //                 style: TextStyle(
        //                     fontFamily: 'lato',
        //                     fontSize: 16,
        //                     color: themeTextColor,
        //                     fontWeight: FontWeight.w600)),
        //             actions: [
        //               IconButton(
        //                   onPressed: () {},
        //                   icon: SvgPicture.asset('assets/icon/appbarshop.svg'))
        //             ],
        //             automaticallyImplyLeading: false,
        //             iconTheme: const IconThemeData(
        //               color: Colors.black,
        //             ),
        //             backgroundColor: Colors.transparent,
        //             elevation: 0,
        //           ),
        //           body: Padding(
        //             padding: pageSurroundingPadding,
        //             child: Column(
        //               children: [
        //                 Lottie.asset('assets/lotti/emptyanimation.json'),
        //                 const SizedBox(height: 20),
        //                 const Text('Whoops !! Cart is Empty',
        //                     style: TextStyle(
        //                         fontFamily: 'lato',
        //                         fontSize: 18,
        //                         fontWeight: FontWeight.w600)),
        //                 const SizedBox(height: 20),
        //                 const SizedBox(
        //                     width: 320,
        //                     child: Text(
        //                         'Looks like you haven’t added anything to your cart yet. You will find a lot of interesting products on our “Shop” page',
        //                         textAlign: TextAlign.center,
        //                         style:
        //                             TextStyle(fontFamily: 'lato', fontSize: 16))),
        //                 const SizedBox(height: 20),
        //                 AppButton(
        //                     itemText: 'START SHOPPING',
        //                     keypressEvent: () {
        //                       Get.find<BottombarController>()
        //                           .currentPageIndex
        //                           .value = 0;
        //                       Get.find<BottombarController>()
        //                           .pageController
        //                           .jumpToPage(0);
        //                     })
        //               ],
        //             ),
        //           ))
        SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shopping Cart',
              style:
                  TextStyle(fontFamily: 'lato', fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
                onPressed: () {
                  // Get.toNamed(Routes.WISHLIST);
                  controller.box.erase();
                },
                icon: SvgPicture.asset('assets/icon/appbarlike.svg'))
          ],

          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          // backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Obx(() => controller.productDetails.isEmpty
            ? Padding(
                padding: pageSurroundingPadding,
                child: Column(
                  children: [
                    Lottie.asset('assets/lotti/emptyanimation.json'),
                    const SizedBox(height: 20),
                    const Text('Whoops !! Cart is Empty',
                        style: TextStyle(
                            fontFamily: 'lato',
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    const SizedBox(
                        width: 320,
                        child: Text(
                            'Looks like you haven’t added anything to your cart yet. You will find a lot of interesting products on our “Shop” page',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontFamily: 'lato', fontSize: 16))),
                    const SizedBox(height: 20),
                    AppButton(
                        itemText: 'START SHOPPING',
                        keypressEvent: () {
                          Get.back();
                          Get.find<BottombarController>()
                              .currentPageIndex
                              .value = 0;
                          Get.find<BottombarController>()
                              .pageController
                              .jumpToPage(0);
                        })
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () {
                  return controller.onRefresh();
                },
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: controller.scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() {
                                  return ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      separatorBuilder: (context, index) =>
                                          const Divider(
                                            thickness: 10,
                                            // color: themegreyColor,
                                          ),
                                      itemCount:
                                          controller.productDetails.length,
                                      itemBuilder: (context, index) {
                                        var product =
                                            controller.productDetails[index];
                                        var variantIndex =
                                            controller.getVariantIndex(index);

                                        return ShoppingCartItem(
                                          variantName: AuthDetails.isUserLogin()
                                              ? controller.cartProducts[index]
                                                          ['value']
                                                      ['variant_name'] ??
                                                  'null'
                                              : controller.guestUserCartList[
                                                              index]
                                                          ['producttype'] ==
                                                      'simple'
                                                  ? 'null'
                                                  : controller
                                                          .guestUserCartList[
                                                      index]['variant_name'],
                                          goToProductDetail: () {
                                            Get.toNamed(Routes.PRODUCTDETAILS,
                                                arguments: {
                                                  'productId': product['_id']
                                                });
                                          },
                                          item: 10,
                                          assetImage:
                                              product['featured_image'] == null
                                                  ? HelperFunctions.getNoImage()
                                                  : url +
                                                      product['featured_image']
                                                          ['filepath'],
                                          productName: controller
                                              .productDetails[index]['name'],
                                          quantity: AuthDetails.isUserLogin()
                                              ? controller.cartProducts[index]
                                                  ['value']['quantity']
                                              : controller
                                                  .productQuntity[index],
                                          //     controller.productQuntity[index],
                                          pressForIncrement: () {
                                            controller.isRefresh.value = true;
                                            if (AuthDetails.isUserLogin()) {
                                              HelperFunctions()
                                                  .showOverlayLoader();
                                              var quantity =
                                                  controller.cartProducts[index]
                                                      ['value']['quantity'];
                                              var variantName =
                                                  controller.cartProducts[index]
                                                      ['value']['variant_name'];
                                              var producttype =
                                                  controller.cartProducts[index]
                                                      ['value']['producttype'];

                                              controller
                                                  .addToCart(
                                                      productId: product['_id'],
                                                      quantity: quantity + 1,
                                                      variantName: variantName,
                                                      productType: producttype)
                                                  .then((value) => Get.until(
                                                      (route) =>
                                                          !Get.isDialogOpen!));
                                            } else {
                                              controller.increment(index);
                                            }
                                          },
                                          pressForDecrement: () {
                                            controller.isRefresh.value = true;
                                            if (AuthDetails.isUserLogin()) {
                                              var quantity =
                                                  controller.cartProducts[index]
                                                      ['value']['quantity'];
                                              var variantName =
                                                  controller.cartProducts[index]
                                                      ['value']['variant_name'];
                                              var producttype =
                                                  controller.cartProducts[index]
                                                      ['value']['producttype'];
                                              quantity--;
                                              if (quantity >= 1) {
                                                HelperFunctions()
                                                    .showOverlayLoader();
                                                controller
                                                    .addToCart(
                                                        productId:
                                                            product['_id'],
                                                        quantity: quantity,
                                                        variantName:
                                                            variantName,
                                                        productType:
                                                            producttype)
                                                    .then((value) => Get.until(
                                                        (route) => !Get
                                                            .isDialogOpen!));
                                              }
                                            } else {
                                              controller.decrement(index);
                                            }
                                          },
                                          price: product['variant_ids']
                                                          [variantIndex]
                                                      ['sale_price'] ==
                                                  null
                                              ? product['variant_ids']
                                                  [variantIndex]['price']
                                              : product['variant_ids']
                                                  [variantIndex]['sale_price'],
                                          discount:
                                              '${((100 - (product['variant_ids'][variantIndex]['sale_price'] == null ? 0 : product['variant_ids'][0]['sale_price']) * 100 / product['variant_ids'][0]['price']).round())}% off',
                                          discountPrice: product['variant_ids']
                                                          [variantIndex]
                                                      ['sale_price'] ==
                                                  null
                                              ? ''
                                              : product['variant_ids']
                                                      [variantIndex]['price']
                                                  .toString(),
                                          onRemove: () async {
                                            Get.back();
                                            await controller.removeCartProduct(
                                                productId: product['_id'],
                                                index: index);
                                          },
                                          onMovetoWishlist: () async {
                                            controller.couponDetails.value = {};
                                            controller.isCouponApply.value =
                                                false;
                                            controller.couponController.text =
                                                '';
                                            var wishListControlller =
                                                Get.find<WishlistController>();

                                            controller.removeCartProduct(
                                                productId: product['_id'],
                                                index: index);
                                            await Get.find<WishlistController>()
                                                .addProductToWishlist(
                                                    productid: product['_id']);
                                            await Get.find<WishlistController>()
                                                .getwishlist();
                                            HelperFunctions.defaultdialogbox(
                                              'The Product Has been successfully added to Wishlist',
                                            );

                                            // Get.find<BottombarController>()
                                            //     .currentPageIndex
                                            //     .value = 3;
                                            // Get.find<BottombarController>()
                                            //     .pageController
                                            //     .jumpToPage(3);
                                            // Get.back();
                                          },
                                          likeWidget:
                                              GetBuilder<WishlistController>(
                                            builder: (controller) {
                                              return controller
                                                      .wishlistProductIds
                                                      .contains(product['_id'])
                                                  ? SvgPicture.asset(
                                                      'assets/icon/like.svg')
                                                  : SvgPicture.asset(
                                                      'assets/icon/unlike.svg');
                                            },
                                          ),
                                        );
                                        //  cartController
                                        //     .showPrice(
                                        //         bottomController.cart[index])
                                        //     .toStringAsFixed(2));
                                      });

                                  // );
                                  // }
                                }),
                                Obx(
                                  () => controller.similarProduct.isEmpty
                                      ? Container()
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Divider(
                                              thickness: 10,
                                              // color: themegreyColor,
                                              height: 40,
                                            ),
                                            Text("You May also Like",
                                                style: txtTheme()
                                                    .titleLarge!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16)),
                                            const SizedBox(height: 20),
                                            SizedBox(
                                              height: 230,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: controller
                                                    .similarProduct.length,
                                                itemBuilder: (context, index) {
                                                  var lowest;
                                                  var highest;
                                                  if (controller.similarProduct[
                                                          index]['type'] ==
                                                      'variant') {
                                                    // for (var item in trendingList) {
                                                    lowest = HelperFunctions
                                                        .lowestPrice(controller
                                                                .similarProduct[
                                                            index]['variant_ids']);
                                                    highest = HelperFunctions
                                                        .highestPrice(controller
                                                                .similarProduct[
                                                            index]['variant_ids']);

                                                    // }
                                                  }

                                                  return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Get.toNamed(
                                                              Routes
                                                                  .PRODUCTDETAILS,
                                                              preventDuplicates: false,
                                                              arguments: {
                                                                'productId': controller
                                                                        .similarProduct[
                                                                    index]['_id']
                                                              });
                                                        },
                                                        child: ProductCard(
                                                          highestPrice: highest
                                                              .toString(),
                                                          lowestPrice:
                                                              lowest.toString(),
                                                          productType: controller
                                                                  .similarProduct[
                                                              index]['type'],
                                                          like: GetBuilder<
                                                              WishlistController>(
                                                            builder:
                                                                (wishlistcontroller) {
                                                              return wishlistcontroller
                                                                      .wishlistProductIds
                                                                      .contains(
                                                                          controller.similarProduct[index]
                                                                              [
                                                                              '_id'])
                                                                  ? SvgPicture
                                                                      .asset(
                                                                          'assets/icon/like.svg')
                                                                  : SvgPicture
                                                                      .asset(
                                                                          'assets/icon/unlike.svg');
                                                            },
                                                          ),
                                                          onLike: () async {
                                                            await wishListController
                                                                .addProductToWishlist(
                                                                    productid: controller
                                                                            .similarProduct[index]
                                                                        [
                                                                        '_id']);
                                                            await wishListController
                                                                .getwishlist();
                                                          },
                                                          averageRating:
                                                              double.parse(
                                                            controller.similarProduct[
                                                                            index]
                                                                        [
                                                                        'average_rating'] ==
                                                                    null
                                                                ? '0'
                                                                : controller
                                                                    .similarProduct[
                                                                        index][
                                                                        'average_rating']
                                                                    .toString(),
                                                          ),
                                                          assetImage: controller
                                                                              .similarProduct[
                                                                          index]
                                                                      [
                                                                      'featured_image'] ==
                                                                  null
                                                              ? 'null'
                                                              : url +
                                                                  controller
                                                                      .similarProduct[
                                                                          index]
                                                                          [
                                                                          'featured_image']
                                                                          [
                                                                          'filepath']
                                                                      .toString(),
                                                          productName: controller
                                                                  .similarProduct[
                                                              index]['name'],
                                                          productPrice: controller
                                                                              .similarProduct[index]
                                                                          ['variant_ids'][0]
                                                                      [
                                                                      'sale_price'] ==
                                                                  null
                                                              ? 'null'
                                                              : controller
                                                                  .similarProduct[
                                                                      index][
                                                                      'variant_ids']
                                                                      [0][
                                                                      'sale_price']
                                                                  .toString(),
                                                          discountPrice: controller
                                                              .similarProduct[
                                                                  index][
                                                                  'variant_ids']
                                                                  [0]['price']
                                                              .toString(),
                                                          discountRate:
                                                              '${((100 - (controller.similarProduct[index]['variant_ids'][0]['sale_price'] == null ? 0 : controller.similarProduct[index]['variant_ids'][0]['sale_price']) * 100 / controller.similarProduct[index]['variant_ids'][0]['price']).round())}% off',
                                                        ),
                                                      ));
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                            !AuthDetails.isUserLogin()
                                ? Container()
                                : const Divider(
                                    thickness: 10,
                                    // color: themegreyColor,
                                  ),
                            !AuthDetails.isUserLogin()
                                ? Container()
                                : AnimatedContainer(
                                    duration: const Duration(seconds: 5),
                                    child: Padding(
                                      padding: pageSurroundingPadding,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Coupons:',
                                              style: txtTheme()
                                                  .titleLarge!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                          const SizedBox(height: 15),
                                          Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              // color: themegreyColor,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/icon/cupon.svg',
                                                    // color: themetitleColor,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: TextFormField(
                                                      key: controller.targetKey,
                                                      focusNode: controller
                                                          .targetFocusNode,
                                                      controller: controller
                                                          .couponController,
                                                      textInputAction:
                                                          TextInputAction.done,
                                                      // inputFormatters: [
                                                      //   FilteringTextInputFormatter
                                                      //       .allow(RegExp(
                                                      //           r'[A-Z]')), // Allow only capital letters
                                                      // ],
                                                      onChanged: (value) {
                                                        controller
                                                                .couponController
                                                                .value =
                                                            TextEditingValue(
                                                                text: value
                                                                    .toUpperCase(),
                                                                selection: controller
                                                                    .couponController
                                                                    .selection);
                                                        controller.isCouponApply
                                                            .value = false;
                                                      },
                                                      style: txtTheme()
                                                          .titleLarge!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText:
                                                            'Enter Coupons',
                                                        // hintStyle: txtTheme()
                                                        //     .titleLarge!
                                                        //     .copyWith(
                                                        //         color:
                                                        //             themetitleColor),
                                                        border:
                                                            InputBorder.none,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        errorBorder:
                                                            InputBorder.none,
                                                        disabledBorder:
                                                            InputBorder.none,
                                                      ),
                                                    ),
                                                  ),
                                                  Obx(
                                                    () => controller
                                                            .isCouponApply.value
                                                        ? IconButton(
                                                            onPressed: () {
                                                              controller
                                                                  .couponController
                                                                  .text = '';
                                                              controller
                                                                  .couponDetails
                                                                  .clear();

                                                              // controller.applyCoupon(coupon: controller.couponController.text);
                                                              controller
                                                                  .isCouponApply
                                                                  .value = false;
                                                            },
                                                            icon: const Icon(
                                                                Icons.cancel),
                                                          )
                                                        : TextButton(
                                                            onPressed: () {
                                                              if (controller
                                                                  .couponController
                                                                  .text
                                                                  .isNotEmpty) {
                                                                Get.focusScope
                                                                    ?.unfocus();
                                                                controller
                                                                    .applyCoupon(
                                                                        coupon: controller
                                                                            .couponController
                                                                            .text)
                                                                    .then(
                                                                        (value) {
                                                                  if (value
                                                                      .containsKey(
                                                                          'discount_amount')) {
                                                                    Get.dialog(
                                                                      AlertDialog(
                                                                        content:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            Center(
                                                                              child: Stack(
                                                                                alignment: Alignment.center,
                                                                                children: [
                                                                                  Lottie.asset(
                                                                                    'assets/lotti/sparkles.json',
                                                                                    height: 250,
                                                                                    repeat: true,
                                                                                  ),
                                                                                  Center(
                                                                                    child: Lottie.asset(
                                                                                      'assets/lotti/couponapplyanimation.json',
                                                                                      height: 140,
                                                                                      repeat: true,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            const Text(
                                                                              'Congratulations!',
                                                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'lato'),
                                                                            ),
                                                                            const SizedBox(height: 10),
                                                                            RichText(
                                                                              textAlign: TextAlign.center,
                                                                              text: TextSpan(
                                                                                style: const TextStyle(fontFamily: 'lato', color: Colors.black),
                                                                                children: [
                                                                                  const TextSpan(
                                                                                    text: 'You have successfully applied the coupon \n you have saved ',
                                                                                  ),
                                                                                  TextSpan(
                                                                                    text: '\u{20B9}${value['discount_amount'].toString()}',
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                });

                                                                controller
                                                                    .isCouponApply
                                                                    .value = true;
                                                              }
                                                            },
                                                            child: const Text(
                                                              'Apply',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'lato',
                                                              ),
                                                            ),
                                                          ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Obx(
                                          //   () {
                                          //     return Text(controller
                                          //             .couponDetails.isEmpty
                                          //         ? ''
                                          //         : controller
                                          //             .couponDetails['message'],style: TextStyle(if),);
                                          //   },
                                          // ),
                                          Obx(
                                            () => AnimatedOpacity(
                                              opacity: controller
                                                      .couponDetails.isEmpty
                                                  ? 0
                                                  : 1,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              child: SlideTransition(
                                                position: Tween<Offset>(
                                                  begin: const Offset(0, 0.1),
                                                  end: const Offset(0, 1),
                                                ).animate(CurvedAnimation(
                                                  parent: controller
                                                      .couponeMessageAnimationController,
                                                  curve: Curves.easeOut,
                                                )),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 3.0),
                                                  child: Text(
                                                    controller.couponDetails[
                                                            'message']
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      // color: controller
                                                      //                 .couponDetails[
                                                      //             'message'] ==
                                                      //         'Applyed'
                                                      //     ? themeGreenColor
                                                      //     : themeRedColor
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                            const Divider(
                              thickness: 10,
                              // color: themegreyColor,
                            ),
                            Padding(
                              padding: pageSurroundingPadding,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 15),
                                  const Text(
                                    'Order Details:',
                                    style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 20),
                                  // orderDetial(
                                  //   couponPrefix: controller.couponDetails
                                  //           .containsKey('coupon_type')
                                  //       ? controller.couponDetails[
                                  //                   'coupon_type'] ==
                                  //               'fixAmount'
                                  //           ? '(\u{20B9}${controller.couponDetails['discount_value']})'
                                  //           : '(%${controller.couponDetails['discount_value'].toString()})'
                                  //       : '',
                                  //   price: AuthDetails.isUserLogin()
                                  //       ? controller.otherCartDetails['total']
                                  //           .toString()
                                  //       : controller.bagpriceAmount.value
                                  //           .toString(),
                                  //   savedPrice: AuthDetails.isUserLogin()
                                  //       ? (controller.otherCartDetails['total'] -
                                  //               controller
                                  //                   .otherCartDetails['subtotal'])
                                  //           .toString()
                                  //       : controller.discountAmount.toString(),
                                  //   cuponValue: controller
                                  //           .couponDetails.isNotEmpty
                                  //       ? controller.couponDetails['message'] ==
                                  //               'Applyed'
                                  //           ? '-\u{20B9}${controller.couponDetails['discount_amount'].toString()}'
                                  //           : 'Apply Coupon'
                                  //       : 'Apply Coupon', // error
                                  //   deliveryStatus: 'Calculated on checkout',
                                  //   totalAmount: AuthDetails.isUserLogin()
                                  //       ? (controller.otherCartDetails['total'] -
                                  //               (controller.otherCartDetails[
                                  //                       'total'] -
                                  //                   controller.otherCartDetails[
                                  //                       'subtotal']) -
                                  //               (controller.couponDetails
                                  //                       .containsKey(
                                  //                           'discount_amount')
                                  //                   ? controller.couponDetails[
                                  //                       'discount_amount']
                                  //                   : 0))
                                  //           .toString()
                                  //       : controller.totalAmount.toString(),
                                  // ),
                                  orderDetial(
                                    couponPrefix:
                                        controller.viewCouponPrefix.value,
                                    price: controller.viewprice.value,
                                    savedPrice: controller.viewsavedPrice.value,
                                    cuponValue:
                                        controller.viewCouponAmount.value,
                                    deliveryStatus: 'Calculated on CheckOut',
                                    totalAmount:
                                        controller.viewTotalAmount.value,
                                  ),
                                  const SizedBox(height: 10),
                                  // Container(
                                  //   height: 40,
                                  //   decoration: BoxDecoration(
                                  //       borderRadius: BorderRadius.circular(3),
                                  //       color: themegreyColor),
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.symmetric(
                                  //         horizontal: 10),
                                  //     child: Row(
                                  //       children: [
                                  //         SvgPicture.asset(
                                  //             'assets/icon/dilevery.svg',
                                  //             color: themetitleColor),
                                  //         const SizedBox(width: 10),
                                  //         Text(
                                  //             'No Delivery Charges applied on this order ',
                                  //             style: txtTheme()
                                  //                 .titleLarge!
                                  //                 .copyWith(
                                  //                     color: themetitleColor)),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                  // const SizedBox(height: 15)
                                ],
                              ),
                            ),
                            const Divider(
                              thickness: 10,
                              // color: themegreyColor,
                            ),
                            const SizedBox(height: 15),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: ShippingDetials(
                                    image: 'assets/icon/returning.svg',
                                    shippinOptions: "7 Day Return ",
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                  child: ShippingDetials(
                                    image: 'assets/icon/support.svg',
                                    shippinOptions: "24/7 Support ",
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                  child: ShippingDetials(
                                    image: 'assets/icon/wallet 1.svg',
                                    shippinOptions: "Secure Payment",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                    // Obx(() {
                    //   return
                    GetBuilder<CartController>(
                      builder: (controller) {
                        return bottomButton(
                          totalAmount: controller.viewTotalAmount.value,
                          opacity: 1,
                          deliveryAmount: 'Calculated On Checkout',
                          buttonText: 'Place Order',
                          priceText: controller.viewTotalAmount.value,
                          keypressEvent: () {
                            if (AuthDetails.isUserLogin()) {
                              Get.to(() => DeliveryDetialView());
                            } else {
                              controller.calculateWeight();
                              print(controller.guestUserCartWeight);
                              Get.to(() => AddUpdateAddress());
                            }
                            // controller.scrollToTarget();
                          },
                          otherText: 'View details',
                          // );
                          // }
                        );
                      },
                    ),
                  ],
                ),
              )),
      ),
    );
  }
}

class ShippingDetials extends StatelessWidget {
  const ShippingDetials({
    Key? key,
    required this.shippinOptions,
    required this.image,
  }) : super(key: key);
  final String shippinOptions;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
              child: SvgPicture.asset(
            image,
            // color: themetitleColor,
          )),
        ),
        const SizedBox(height: 5.0),
        Text(
          shippinOptions,
          style: txtTheme().titleLarge!.copyWith(fontSize: 12),
        )
      ],
    );
  }
}

class ShoppingCartItem extends GetView<CartController> {
  ShoppingCartItem({
    Key? key,
    required this.assetImage,
    required this.productName,
    required this.quantity,
    required this.pressForIncrement,
    required this.pressForDecrement,
    required this.price,
    required this.discount,
    required this.discountPrice,
    required this.onRemove,
    required this.onMovetoWishlist,
    required this.variantName,
    required this.likeWidget,
    required this.goToProductDetail,
    this.item,
  }) : super(key: key);

  String assetImage;
  String productName;
  String discountPrice;
  String discount;
  int price;
  final dynamic item;
  final int quantity;
  final Function() pressForIncrement;
  final Function() pressForDecrement;
  VoidCallback onRemove;
  String variantName;
  VoidCallback onMovetoWishlist;
  Widget likeWidget;
  VoidCallback goToProductDetail;

  @override
  Widget build(BuildContext context) {
    print('variant name ${variantName}');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Builder(builder: (context) {
        return GestureDetector(
          onTap: goToProductDetail,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: CachedNetworkImage(
                  width: 110,
                  height: 120,
                  fit: BoxFit.cover,
                  imageUrl: assetImage,
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(color: Colors.grey.shade300),
                    child: const Center(
                      child: Icon(Icons.error),
                    ),
                  ),
                  progressIndicatorBuilder: (context, url, progress) =>
                      Container(
                    decoration: BoxDecoration(color: Colors.grey.shade300),
                    height: 165,
                    child: Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: HelperFunctions().loadingIndicator(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),

              // Text("Qunantity ${subtitle}",
              //     style: txtTheme()
              //         .titleLarge!
              //         .copyWith(color: themeSecondrytext, fontSize: 13)),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: Get.width * 0.5,
                      child: Text(productName, style: txtTheme().titleLarge)),
                  const SizedBox(height: 3.0),

                  variantName == 'null' || variantName == ''
                      ? Container()
                      : Text(
                          variantName,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                  // SizedBox(
                  //   height: 2,
                  // ),
                  RichText(
                    text: TextSpan(
                        text: '\u{20B9}$price ',
                        style: txtTheme().titleLarge!.copyWith(fontSize: 12),
                        children: [
                          TextSpan(
                              text: '\u{20B9}$discountPrice',
                              style: txtTheme().titleLarge!.copyWith(
                                  // color: themeSecondrytext,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 12)),
                          const TextSpan(text: ' '),
                          TextSpan(
                              text: '($discount)',
                              style: txtTheme()
                                  .titleLarge!
                                  .copyWith(fontSize: 12)),
                        ]),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    width: Get.width * 0.32,
                    height: 25,
                    decoration: BoxDecoration(
                        // color: themegreyColor,
                        borderRadius: BorderRadius.circular(3)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: pressForDecrement,
                            icon: const Icon(Icons.remove, size: 14)),
                        // Text(quantity.toString()),
                        // GetBuilder<CartController>(
                        // builder: (controller) {
                        // Text(controller.productQuntity[quantity].toString()),
                        Text(quantity.toString()),

                        // },
                        // ),
                        IconButton(
                            onPressed: pressForIncrement,
                            icon: const Icon(Icons.add, size: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Container(
                    width: Get.width * 0.55,
                    // color: themegreyColor,
                    height: 1.0,
                  ),
                  const SizedBox(height: 5.0),
                  SizedBox(
                    width: Get.width * 0.55,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: onMovetoWishlist,
                            child: Row(
                              children: [
                                likeWidget,
                                const SizedBox(width: 5.0),
                                Text('Move to wishlist',
                                    style: txtTheme()
                                        .titleLarge!
                                        .copyWith(fontSize: 13))
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 1.1,
                          // color: themeTextColor,
                          height: 15,
                        ),
                        const SizedBox(width: 08),
                        GestureDetector(
                          onTap: () {
                            removeItemModel(
                                context: context, onRemove: onRemove);
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete,
                                size: 16,
                              ),
                              const SizedBox(width: 5.0),
                              Text('Remove',
                                  style: txtTheme()
                                      .titleLarge!
                                      .copyWith(fontSize: 13))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  removeItemModel(
      {required BuildContext context, required VoidCallback onRemove}) {
    return Get.dialog(
      barrierDismissible: false,
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
              "Are you sure you want to remove product from the cart?",
              style: txtTheme().titleLarge!.copyWith(),
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
              style: TextStyle(color: Colors.grey),
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
    // return Get.defaultDialog(
    //     title: "",
    //     titleStyle: TextStyle(height: 0.0),
    //     contentPadding: EdgeInsets.zero,
    //     content: Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
    //       child: SizedBox(
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               'Remove Item',
    //               style: txtTheme().headlineSmall,
    //             ),
    //             Text(
    //               "Are you sure you want to remove product from the cart?",
    //               style:
    //                   txtTheme().titleLarge!.copyWith(color: themeSecondrytext),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //     actions: [
    //       Material(
    //         elevation: 05,
    //         child: SizedBox(
    //             width: Get.width,
    //             height: 50,
    //             child: Row(
    //               children: [
    //                 Expanded(
    //                   flex: 2,
    //                   child: GestureDetector(
    //                     onTap: () {
    //                       Get.back();
    //                     },
    //                     child: Center(
    //                       child: Text("Back".toUpperCase(),
    //                           style:
    //                               txtTheme().headlineSmall!.copyWith(fontSize: 16)),
    //                     ),
    //                   ),
    //                 ),
    //                 const VerticalDivider(
    //                   width: 20,
    //                   thickness: 1.5,
    //                   indent: 10,
    //                   endIndent: 10,
    //                   color: themegreyColor,
    //                 ),
    //                 Expanded(
    //                   flex: 1,
    //                   child: GestureDetector(
    //                     onTap: onRemove,
    //                     child: Center(
    //                       child: Text("Remove".toUpperCase(),
    //                           style: txtTheme().headlineSmall!.copyWith(
    //                               color: themeRedColor, fontSize: 16)),
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             )),
    //       )
    //     ],
    //     radius: 0.0);
  }
}

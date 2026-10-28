import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zouhi/app/modules/address/views/delivery_detial_view.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/buttons/appbutton.dart';
import 'package:zouhi/components/buttons/bottombutton.dart';
import 'package:zouhi/components/oderdetail.dart';
import 'package:zouhi/components/productcard.dart';
import 'package:zouhi/components/product_image_placeholder.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';
import 'package:lottie/lottie.dart';

class CartView extends GetView<CartController> {
  CartView({Key? key}) : super(key: key);

  var bottomController = Get.put(BottombarController());
  // WishlistController wishListController = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Shopping Cart',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
          iconTheme: IconThemeData(color: context.colors.onSurface),
          elevation: 0,
        ),
        body: RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: Obx(
            () => controller.isCartEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      alignment: Alignment.center,
                      height: Get.height -
                          AppBar().preferredSize.height -
                          MediaQuery.of(context).padding.top -
                          40,
                      child: _buildEmptyCart(),
                    ),
                  )
                : Stack(
                    children: [_buildCartContent(), _buildBottomButton()],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Padding(
      padding: pageSurroundingPadding,
      child: Column(
        children: [
          Lottie.asset('assets/lotti/emptyanimation.json'),
          const SizedBox(height: 20),
          const Text(
            'Whoops !! Cart is Empty',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(
            width: 320,
            child: Text(
              'Looks like you haven\'t added anything to your cart yet. You will find a lot of interesting products on our "Shop" page',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            itemText: 'START SHOPPING',
            keypressEvent: () {
              BottombarController.switchTab(1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Positioned(
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
            _buildCartItems(),
            _buildSimilarProducts(),
            if (AuthDetails.isUserLogin()) _buildCouponSection(),
            _buildOrderDetails(),
            //_buildShippingInfo(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems() {
    return Obx(
      () => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) =>
            Divider(thickness: 10, color: context.themegreyColor),
        itemCount: controller.cartItems.length,
        itemBuilder: (context, index) {
          var cartItem = controller.cartItems[index];
          var product = cartItem['product'];
          var variant = controller.getVariantForItem(cartItem);

          if (product == null || variant == null) {
            return Container(); // Skip invalid items
          }

          return _buildCartItem(cartItem, product, variant, index);
        },
      ),
    );
  }

  Widget _buildCartItem(
    dynamic cartItem,
    dynamic product,
    dynamic variant,
    int index,
  ) {
    // debugPrint("cart Item ----- $cartItem");
    // debugPrint("Product Item ----- $product");
    // debugPrint("Variant Item ----- $variant");

    // Get featured image
    String? featuredImage = HelperFunctions().getImage(
      variant['front_image'] ??
          variant['featured_image'] ??
          product['featured_image'],
    );

    // Calculate prices with precision
    double p = (double.tryParse(variant['price']?.toString() ?? '0') ?? 0.0)
        .toConvertedPrice();
    double sp =
        (double.tryParse(variant['sale_price']?.toString() ?? '0') ?? 0.0)
            .toConvertedPrice();
    if (sp <= 0) sp = 0.0;

    String displayPrice =
        (sp > 0) ? sp.toStringAsFixed(2) : p.toStringAsFixed(2);
    String displayOriginal = (sp > 0) ? p.toStringAsFixed(2) : '';

    // Calculate discount percentage
    var discountPercentage = 0;
    if (sp > 0 && sp < p && p > 0) {
      discountPercentage = ((p - sp) * 100 / p).round();
    }

    return ShoppingCartItem(
      variantName: variant['name'] ?? variant['variant'] ?? '',
      productType: product['type'] ?? 'simple',
      variant: variant,
      goToProductDetail: () {
        Get.toNamed(
          Routes.PRODUCTDETAILS,
          arguments: {'productId': product['_id']},
        );
      },
      assetImage: featuredImage,
      productName: product['name'] ?? 'Unknown Product',
      quantity: cartItem['quantity'] ?? 1,
      pressForIncrement: () =>
          _handleIncrement(cartItem, product, variant, index),
      pressForDecrement: () => _handleDecrement(
        cartItem,
        product,
        variant,
        index,
        cartItem['quantity'] ?? 1,
      ),
      price: displayPrice,
      discount: discountPercentage > 0 ? '$discountPercentage% off' : '',
      discountPrice: displayOriginal,
      onRemove: () async {
        Get.back();
        await controller.removeCartProduct(
          productId: product['_id'],
          variantId: variant['_id'],
          itemId: cartItem['_id'], // Pass the unique cart item ID
          index: index,
        );
      },
      onMovetoWishlist: () =>
          _moveToWishlist(cartItem, product, variant, index),
      likeWidget: GetBuilder<WishlistController>(
        builder: (wishlistController) {
          return wishlistController.wishlistProductIds.contains(product['_id'])
              ? SvgPicture.asset('assets/icon/like.svg')
              : SvgPicture.asset('assets/icon/unlike.svg');
        },
      ),
    );
  }

  void _handleIncrement(
    dynamic cartItem,
    dynamic product,
    dynamic variant,
    int index,
  ) {
    controller.isRefresh.value = true;

    if (AuthDetails.isUserLogin()) {
      controller.addToCart(
        productId: product['_id'],
        quantity: 1,
        variantId: variant['_id'],
        productType: cartItem['producttype'] ?? 'simple',
        itemId: cartItem['_id'], // Pass the unique cart item ID
      );
    } else {
      controller.increment(index);
    }
  }

  void _handleDecrement(
    dynamic cartItem,
    dynamic product,
    dynamic variant,
    int index,
    int quantity,
  ) {
    controller.isRefresh.value = true;

    if (AuthDetails.isUserLogin()) {
      if (quantity > 1) {
        controller.addToCart(
          productId: product['_id'],
          quantity: -1,
          variantId: variant['_id'],
          productType: cartItem['producttype'] ?? 'simple',
          itemId: cartItem['_id'], // Pass the unique cart item ID
        );
      }
    } else {
      controller.decrement(index);
    }
  }

  void _moveToWishlist(
    dynamic cartItem,
    dynamic product,
    dynamic variant,
    int index,
  ) async {
    final wishlistController = Get.isRegistered<WishlistController>()
        ? Get.find<WishlistController>()
        : Get.put(WishlistController());

    if (!wishlistController.isProductInWishlist(
      product['_id'].toString(),
      variantId: variant['_id']?.toString(),
    )) {
      await wishlistController.addProductToWishlist(
        productid: product['_id'].toString(),
        variant_id: variant['_id']?.toString(),
      );
    }

    // Only take the item out of the cart once it is really in the wishlist.
    if (!wishlistController.wishlistProductIds
        .contains(product['_id'].toString())) {
      HelperFunctions.defaultdialogbox(
        'Could not add the product to your wishlist.',
        Colors.red,
      );
      return;
    }

    controller.clearCoupon();

    await controller.removeCartProduct(
      productId: product['_id'],
      variantId: variant['_id'],
      itemId: cartItem['_id'], // Added itemId
      index: index,
      showSuccessDialog: false,
    );

    HelperFunctions.defaultdialogbox(
      'The Product Has been successfully added to Wishlist',
      Colors.green,
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (Get.isDialogOpen ?? false) Get.back();
    });
  }

  Widget _buildSimilarProducts() {
    return Obx(
      () => controller.similarProduct.isEmpty
          ? Container()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                    thickness: 10,
                    color: Get.context!.themegreyColor,
                    height: 40),
                Padding(
                  padding: pageSurroundingPadding.copyWith(top: 0, bottom: 0),
                  child: Text(
                    "You May also Like",
                    style: txtTheme().headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 230,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.similarProduct.length,
                    itemBuilder: (context, index) =>
                        _buildSimilarProductCard(index),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSimilarProductCard(int index) {
    var product = controller.similarProduct[index];
    var variants =
        (product['variants'] ?? product['variant_ids'] ?? []) as List;
    if (variants.isEmpty) return Container();

    double? originalPrice;
    double? salePrice;
    bool isVariable =
        product['type'] == 'variable' || product['type'] == 'variant';

    if (product['type'] == 'simple') {
      Map? v = variants.isNotEmpty ? variants.first : null;
      originalPrice = double.tryParse(
        v?['price']?.toString() ?? product['price']?.toString() ?? '0',
      );
      salePrice = double.tryParse(
        v?['sale_price']?.toString() ??
            product['sale_price']?.toString() ??
            '0',
      );
    } else if (isVariable) {
      double? minEffective;
      Map? lowestVariant;
      for (var v in variants) {
        if (v is! Map) continue;
        double vP = double.tryParse(v['price']?.toString() ?? '0') ?? 0.0;
        double vSP = double.tryParse(v['sale_price']?.toString() ?? '0') ?? 0.0;
        double effective = (vSP > 0) ? vSP : vP;
        if (minEffective == null || effective < minEffective) {
          minEffective = effective;
          lowestVariant = v;
        }
      }
      if (lowestVariant != null) {
        originalPrice = double.tryParse(
          lowestVariant['price']?.toString() ?? '0',
        );
        salePrice = double.tryParse(
          lowestVariant['sale_price']?.toString() ?? '0',
        );
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
          '${((originalPrice - salePrice) * 100 / originalPrice).round()}% off';
    }

    String? lowestP, highestP;
    if (isVariable) {
      double? min, max;
      for (var v in variants) {
        if (v is! Map) continue;
        double vP = double.tryParse(v['price']?.toString() ?? '0') ?? 0.0;
        double vSP = double.tryParse(v['sale_price']?.toString() ?? '0') ?? 0.0;
        double effective = (vSP > 0) ? vSP : vP;
        if (min == null || effective < min) min = effective;
        if (max == null || effective > max) max = effective;
      }
      lowestP = min?.toConvertedPrice().toStringAsFixed(2);
      highestP = max?.toConvertedPrice().toStringAsFixed(2);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () {
          Get.toNamed(
            Routes.PRODUCTDETAILS,
            preventDuplicates: false,
            arguments: {'productId': product['_id']},
          );
        },
        child: ProductCard(
          highestPrice: highestP ?? '',
          lowestPrice: lowestP ?? '',
          productType: product['type'] ?? 'simple',
          like: GetBuilder<WishlistController>(
            builder: (wishlistController) {
              return wishlistController.wishlistProductIds.contains(
                product['_id'],
              )
                  ? SvgPicture.asset('assets/icon/like.svg')
                  : SvgPicture.asset('assets/icon/unlike.svg');
            },
          ),
          onLike: () async {
            // await wishListController.addProductToWishlist(
            //     productid: product['_id']);
            // await wishListController.getwishlist();
          },
          averageRating: double.parse(
            (product['average_rating'] ?? 0).toString(),
          ),
          assetImage: HelperFunctions().getImage(product['featured_image']),
          productName: product['name'] ?? 'Unknown Product',
          productPrice: displayPrice,
          discountRate: discountRate,
          discountPrice: displayOriginal,
        ),
      ),
    );
  }

  Widget _buildCouponSection() {
    return Column(
      children: [
        Divider(thickness: 10, color: Get.context!.themegreyColor),
        Padding(
          padding: pageSurroundingPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Coupons:',
                    style: txtTheme().headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Get.context!.themeTextColor,
                        ),
                  ),
                  InkWell(
                    onTap: () => Get.toNamed(Routes.COUPONS),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Coupons',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Get.context!.themePrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: Get.context!.themePrimaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Get.context!.themegreyColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icon/cupon.svg',
                        color: Get.context!.themetitleColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: _buildCouponTextField()),
                      _buildCouponActionButton(),
                    ],
                  ),
                ),
              ),
              _buildCouponMessage(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCouponTextField() {
    return Obx(
      () => TextFormField(
        key: controller.targetKey,
        focusNode: controller.targetFocusNode,
        controller: controller.couponController,
        textInputAction: TextInputAction.done,
        readOnly: controller.isCouponApply.value,
        onChanged: (value) {
          controller.couponController.value = TextEditingValue(
            text: value.toUpperCase(),
            selection: controller.couponController.selection,
          );
          controller.isCouponApply.value = false;
        },
        style: txtTheme().headlineSmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: Get.context!.themeTextColor,
              fontSize: 14,
            ),
        decoration: InputDecoration(
          hintText: controller.isCouponApply.value
              ? controller.viewCouponCode.value
              : 'Enter Coupons',
          hintStyle: TextStyle(
            color: Get.context!.themeSecondrytext,
            fontSize: 14,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCouponActionButton() {
    return Obx(
      () => controller.isCouponApply.value
          ? IconButton(
              onPressed: () {
                controller.clearCoupon();
              },
              icon: const Icon(Icons.cancel),
            )
          : TextButton(
              onPressed: () => _applyCoupon(),
              child: Text(
                'Apply',
                style: TextStyle(
                    fontFamily: 'Poppins', color: Get.context!.themeRedColor),
              ),
            ),
    );
  }

  void _applyCoupon() {
    if (controller.couponController.text.isNotEmpty) {
      Get.focusScope?.unfocus();
      controller.applyCoupon(coupon: controller.couponController.text).then((
        value,
      ) {
        if (value != null && value.containsKey('code')) {
          controller.isCouponApply.value = true;
          _showCouponSuccessDialog(value);
        } else {
          // Handle invalid coupon
          controller.isCouponApply.value = false;
          String errorMessage = value != null && value.containsKey('message')
              ? value['message']
              : 'Invalid coupon code';
          HelperFunctions.defaultdialogbox(errorMessage, Colors.red);
        }
      });
    }
  }

  // void _showCouponSuccessDialog(dynamic couponResponse) {
  //   var couponData = couponResponse['coupon'];
  //   var discountAmount = 0.0;

  //   // if (couponData['type'] == 'fixAmount') {
  //   //   discountAmount = (couponData['type_value'] ?? 0).toDouble();
  //   // } else if (couponData['type'] == 'percentage') {
  //   //   // Calculate percentage discount based on current total
  //   //   var currentTotal =
  //   //       double.tryParse(controller.viewTotalAmount.value) ?? 0.0;
  //   //   discountAmount = currentTotal * (couponData['type_value'] ?? 0) / 100;
  //   // }

  //   if (couponData['type'] == 'fixAmount') {
  //     discountAmount = (couponData['type_value'] ?? 0).toDouble();
  //     print(
  //         "💵 Fixed discount applied: \$${discountAmount.toStringAsFixed(2)}");
  //   } else if (couponData['type'] == 'percentage') {
  //     // Calculate percentage discount based on current total
  //     var currentTotal =
  //         double.tryParse(controller.viewTotalAmount.value) ?? 0.0;
  //     discountAmount = currentTotal * (couponData['type_value'] ?? 0) / 100;
  //     // discountAmount = controller.discountAmount.value;
  //     print(
  //         "📊 Percentage discount applied: ${couponData['type_value']}% of \$${controller.viewTotalAmount.value} = \$${discountAmount.toStringAsFixed(2)}.    ----  ");
  //   } else {
  //     print("❌ Unknown coupon type: ${couponData['type']}");
  //   }

  //   Get.dialog(
  //     AlertDialog(
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Center(
  //             child: Stack(
  //               alignment: Alignment.center,
  //               children: [
  //                 Lottie.asset('assets/lotti/sparkles.json',
  //                     height: 250, repeat: true),
  //                 Center(
  //                   child: Lottie.asset(
  //                       'assets/lotti/couponapplyanimation.json',
  //                       height: 140,
  //                       repeat: true),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           const Text('Congratulations!',
  //               style: TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                   fontFamily: 'Poppins')),
  //           const SizedBox(height: 10),
  //           RichText(
  //             textAlign: TextAlign.center,
  //             text: TextSpan(
  //               style: const TextStyle(fontFamily: 'Poppins', color: Colors.black),
  //               children: [
  //                 const TextSpan(
  //                     text:
  //                         'You have successfully applied the coupon \n you have saved '),
  //                 TextSpan(
  //                   text: '${controller.viewCouponAmount.value}',
  //                   style: const TextStyle(color: themeGreenColor),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  void _showCouponSuccessDialog(dynamic couponResponse) {
    var couponData = couponResponse;
    var discountAmount = 0.0;

    if (couponData['discount_type'] != 'PERCENTAGE') {
      discountAmount =
          double.tryParse(couponData['discount_amount']?.toString() ?? '0') ??
              0.0;
      print(
        "💵 Fixed discount applied: \$${discountAmount.toStringAsFixed(2)}",
      );
    } else if (couponData['discount_type'] == 'PERCENTAGE') {
      discountAmount =
          double.tryParse(couponData['discount_amount']?.toString() ?? '0') ??
              0.0;
      print(
        "📊 Percentage discount applied: ${couponData['discount_value']}% = \$${discountAmount.toStringAsFixed(2)}",
      );
    } else {
      print("❌ Unknown coupon type: ${couponData['discount_type']}");
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                    fontFamily: 'Poppins', color: Get.context!.colors.onSurface),
                children: [
                  const TextSpan(
                    text:
                        'You have successfully applied the coupon \n you have saved ',
                  ),
                  TextSpan(
                    text: controller.viewCouponAmount.value.replaceAll("-", ""),
                    style: TextStyle(color: Get.context!.themeGreenColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: themeGreenColor,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            //   onPressed: () {
            //     Get.back(); // closes the dialog
            //   },
            //   child: const Text("Close"),
            // ),
            AppButton(
              itemText: 'Close',
              keypressEvent: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponMessage() {
    return Obx(
      () => AnimatedOpacity(
        opacity: controller.couponDetails.isEmpty ? 0 : 1,
        duration: const Duration(milliseconds: 500),
        child: Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: Text(
            controller.couponDetails.containsKey('code')
                ? 'Coupon applied successfully'
                : controller.couponDetails['message']?.toString() ??
                    'Invalid coupon',
            style: TextStyle(
              fontSize: 13,
              color: controller.couponDetails.containsKey('code')
                  ? Get.context!.themeGreenColor
                  : Get.context!.themeRedColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Column(
      children: [
        Divider(thickness: 10, color: Get.context!.themegreyColor),
        Padding(
          padding: pageSurroundingPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Text(
                'Order Details:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Get.context!.themeTextColor,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                double originalBagTotal =
                    double.tryParse(controller.viewPrice.value) ?? 0.0;
                double itemSavings =
                    double.tryParse(controller.viewSavedPrice.value) ?? 0.0;
                double couponDiscountAmount =
                    double.tryParse(controller.couponDiscountAmount.value) ??
                        0.0;
                double subTotal =
                    double.tryParse(controller.viewSubTotalAmount.value) ?? 0.0;
                double taxableValue = subTotal - couponDiscountAmount;
                double totalTaxAmount = controller.tax.value.toConvertedPrice();
                double finalTotal =
                    double.tryParse(controller.viewTotalAmount.value) ?? 0.0;

                List<ItemTaxBreakdown> breakdown = controller.taxBreakdownList
                    .map(
                      (e) => ItemTaxBreakdown(
                        name: e['name']?.toString() ?? 'Product',
                        taxPercent: double.tryParse(
                              e['tax_percent']?.toString() ?? '0',
                            ) ??
                            0.0,
                        taxAmount: (double.tryParse(
                                  e['tax_amount']?.toString() ?? '0',
                                ) ??
                                0.0)
                            .toConvertedPrice(),
                      ),
                    )
                    .toList();

                String symbol = currency;
                if (Get.isRegistered<CurrencyController>()) {
                  symbol = Get.find<CurrencyController>()
                          .selectedCurrency['symbol']
                          ?.toString() ??
                      currency;
                }

                return PriceBreakdownWidget(
                  originalBagTotal: originalBagTotal,
                  itemSavings: itemSavings,
                  couponCode: controller.viewCouponCode.value == 'Apply Coupon'
                      ? ''
                      : controller.viewCouponCode.value,
                  couponDiscountPrefix: controller.viewCouponPrefix.value,
                  couponDiscountAmount: couponDiscountAmount,
                  taxableValue: taxableValue,
                  totalTaxAmount: totalTaxAmount,
                  itemTaxBreakdown: breakdown,
                  finalTotal: finalTotal,
                  currencySymbol: symbol,
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildShippingInfo() {
  //   return const Column(
  //     children: [
  //       Divider(thickness: 10, color: themegreyColor),
  //       SizedBox(height: 15),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Flexible(
  //             child: ShippingDetails(
  //               image: 'assets/icon/returning.svg',
  //               shippingOptions: "7 Day Return",
  //             ),
  //           ),
  //           SizedBox(width: 20),
  //           Flexible(
  //             child: ShippingDetails(
  //               image: 'assets/icon/support.svg',
  //               shippingOptions: "24/7 Support",
  //             ),
  //           ),
  //           SizedBox(width: 20),
  //           Flexible(
  //             child: ShippingDetails(
  //               image: 'assets/icon/wallet 1.svg',
  //               shippingOptions: "Secure Payment",
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildBottomButton() {
    return GetBuilder<CartController>(
      builder: (controller) {
        return Obx(
          () {
            String symbol = currency;
            if (Get.isRegistered<CurrencyController>()) {
              symbol = Get.find<CurrencyController>()
                      .selectedCurrency['symbol']
                      ?.toString() ??
                  currency;
            }
            return bottomButton(
              totalAmount: controller.viewTotalAmount.value,
              opacity: 1,
              //deliveryAmount: 'Calculated On Checkout',
              buttonText: 'Place Order',
              priceText: controller.viewTotalAmount.value,
              currencySymbol: symbol,
              keypressEvent: () {
                if (AuthDetails.isUserLogin()) {
                  Get.to(() => DeliveryDetialView());
                  //Get.toNamed(Routes.MANAGEADDRESS);
                } else {
                  HelperFunctions.showLoginDialog(
                      "Please login to place a new order.");
                }
              },
              otherText: 'View details',
            );
          },
        );
      },
    );
  }
}

class ShippingDetails extends StatelessWidget {
  const ShippingDetails({
    Key? key,
    required this.shippingOptions,
    required this.image,
  }) : super(key: key);

  final String shippingOptions;
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
            color: context.themegreyColor,
          ),
          child: Center(
              child: SvgPicture.asset(image, color: context.themetitleColor)),
        ),
        const SizedBox(height: 5.0),
        Text(
          shippingOptions,
          style: txtTheme().headlineSmall!.copyWith(
                color: context.themetitleColor,
                fontSize: 12,
              ),
        ),
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
    required this.productType,
    required this.pressForIncrement,
    required this.pressForDecrement,
    required this.price,
    required this.discount,
    required this.discountPrice,
    required this.onRemove,
    required this.onMovetoWishlist,
    required this.variantName,
    required this.likeWidget,
    required this.variant,
    required this.goToProductDetail,
  }) : super(key: key);

  final String? assetImage;
  final String productName;
  final String discountPrice;
  final String discount;
  final dynamic variant;
  final String productType;
  final String price;
  final int quantity;
  final Function() pressForIncrement;
  final Function() pressForDecrement;
  final VoidCallback onRemove;
  final String variantName;
  final VoidCallback onMovetoWishlist;
  final Widget likeWidget;
  final VoidCallback goToProductDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: GestureDetector(
        onTap: goToProductDetail,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProductImage(),
            const SizedBox(width: 15),
            Expanded(child: _buildProductDetails()),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: Container(
        width: 110,
        height: 120,
        color: Get.context!.themegreyColor,
        child: (assetImage != null &&
                assetImage!.isNotEmpty &&
                assetImage != HelperFunctions.getNoImage())
            ? CachedNetworkImage(
                width: 110,
                height: 120,
                fit: BoxFit.contain,
                imageUrl: assetImage!,
                errorWidget: (context, url, error) => const SizedBox(
                  width: 110,
                  height: 120,
                  child: ProductImagePlaceholder(radius: 5),
                ),
                progressIndicatorBuilder: (context, url, progress) => Container(
                  decoration: BoxDecoration(color: context.themegreyColor),
                  height: 120,
                  child: Center(
                    child:
                        SizedBox(child: HelperFunctions().loadingIndicator()),
                  ),
                ),
              )
            : const SizedBox(
                width: 110,
                height: 120,
                child: ProductImagePlaceholder(radius: 5),
              ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productName,
          style: txtTheme().headlineSmall!.copyWith(
                color: Get.context!.themeTextColor,
              ),
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
        if (variantName.isNotEmpty && productType == "variable")
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              variantName,
              style: txtTheme().headlineSmall!.copyWith(
                    fontSize: 12,
                    color: Get.context!.themeSecondrytext,
                  ),
            ),
          ),
        const SizedBox(height: 3.0),
        _buildPriceInfo(),
        const SizedBox(height: 10.0),
        _buildQuantityControls(),
        const SizedBox(height: 5.0),
        Container(
            width: Get.width * 0.55,
            color: Get.context!.themegreyColor,
            height: 1.0),
        const SizedBox(height: 5.0),
        _buildActionButtons(),
      ],
    );
  }

  String get _currencySymbol {
    if (Get.isRegistered<CurrencyController>()) {
      return Get.find<CurrencyController>()
              .selectedCurrency['symbol']
              ?.toString() ??
          currency;
    }
    return currency;
  }

  Widget _buildPriceInfo() {
    return RichText(
      text: TextSpan(
        text: '$_currencySymbol$price ',
        style: txtTheme().headlineSmall!.copyWith(
              fontSize: 12,
              color: Get.context!.themeTextColor,
            ),
        children: [
          if (discountPrice.isNotEmpty)
            TextSpan(
              text: '$_currencySymbol$discountPrice',
              style: txtTheme().headlineSmall!.copyWith(
                    color: Get.context!.themeSecondrytext,
                    decoration: TextDecoration.lineThrough,
                    fontSize: 12,
                  ),
            ),
          const TextSpan(text: ' '),
          if (discount.isNotEmpty)
            TextSpan(
              text: '($discount)',
              style: txtTheme().headlineSmall!.copyWith(
                    color: Get.context!.themeRedColor,
                    fontSize: 12,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls() {
    return IntrinsicWidth(
      child: Container(
        height: 25,
        decoration: BoxDecoration(
          color: Get.context!.themegreyColor,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: pressForDecrement,
              icon: Icon(Icons.remove,
                  size: 14, color: Get.context!.themeTextColor),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                quantity.toString(),
                style: TextStyle(
                  color: Get.context!.themeTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: pressForIncrement,
              icon: Icon(Icons.add,
                  size: 14, color: Get.context!.themeTextColor),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: Get.width * 0.55,
      child: Row(
        children: [
          // Expanded(
          //   child: GestureDetector(
          //     onTap: onMovetoWishlist,
          //     child: Row(
          //       children: [
          //         likeWidget,
          //         const SizedBox(width: 5.0),
          //         Text('Move to wishlist',
          //             style: txtTheme().headlineSmall!.copyWith(fontSize: 13))
          //       ],
          //     ),
          //   ),
          // ),
          // Container(width: 1.1, color: themeTextColor, height: 15),
          // const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showRemoveDialog(),
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded,
                    size: 16, color: Get.context!.themeTextColor),
                const SizedBox(width: 5.0),
                Text(
                  'Remove',
                  style: txtTheme().headlineSmall!.copyWith(
                        fontSize: 13,
                        color: Get.context!.themeTextColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog() {
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        actionsPadding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ).copyWith(top: 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Remove Item', style: txtTheme().headlineMedium),
            Text(
              "Are you sure you want to remove product from the cart?",
              style: txtTheme().headlineSmall!.copyWith(
                    color: Get.context!.themeSecondrytext,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Back',
                style: TextStyle(color: Get.context!.themeSecondrytext)),
          ),
          TextButton(
            onPressed: onRemove,
            child: Text('Remove',
                style: TextStyle(color: Get.context!.themeRedColor)),
          ),
        ],
      ),
    );
  }
}

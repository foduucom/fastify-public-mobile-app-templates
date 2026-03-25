import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/components/commonWidgets/secondary_app_header.dart';
import 'package:foduu_ecommerce/components/shimmer/cart_shimmer.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';

class CartView extends GetView<CartController> {
  CartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            GetStorage().erase();
          },
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.02,
          ),
          child: Column(
            children: [
              SecondaryAppHeader(
                title: "My Cart",
              ),
              SizedBox(height: height * 0.001),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const CartShimmer();
                  }

                  if (controller.cartItems.isEmpty) {
                    return _buildEmptyCart(
                        context, colorScheme, textTheme, width, height);
                  }

                  return _buildCartContent(
                      context, colorScheme, textTheme, width, height);
                }),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Obx(() => controller.cartItems.isEmpty
            ? const SizedBox.shrink()
            : _bottombar(width: width, height: height)),
      ),
    );
  }

  Widget _buildEmptyCart(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    double width,
    double height,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/lotti/emptyanimation.json',
          height: height * 0.3,
        ),
        const SizedBox(height: 20),
        Text(
          'Whoops !! Cart is Empty',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 320,
          child: Text(
            'Looks like you haven\'t added anything to your cart yet. You will find a lot of interesting products on our "Shop" page',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          itemText: 'START SHOPPING',
          keypressEvent: () {
            if (Get.isRegistered<BottombarController>()) {
              Get.find<BottombarController>().currentPageIndex.value = 0;
              Get.find<BottombarController>().pageController.jumpToPage(0);
            }
            Get.back();
          },
        ),
      ],
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    double width,
    double height,
  ) {
    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      child: ListView.separated(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.cartItems.length,
        separatorBuilder: (_, __) => SizedBox(height: height * 0.025),
        itemBuilder: (context, index) {
          return _cartItemRow(index);
        },
      ),
    );
  }

  Widget _bottombar({required width, required height}) {
    return Container(
      width: width,
      height: height * 0.42,
      padding: EdgeInsets.all(width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coupon Section
          Container(
            width: width * 0.90,
            constraints: BoxConstraints(minHeight: height * 0.055),
            padding: EdgeInsets.symmetric(horizontal: width * 0.025),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height * 0.01),
              border: Border.all(color: DefaultThemeColors.darklight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.couponController,
                    decoration: const InputDecoration(
                      hintText: "Enter Promo Code",
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: height * 0.018,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Obx(() => TextButton(
                      onPressed: controller.isClicked.value
                          ? null
                          : () {
                              if (controller.couponController.text.isNotEmpty) {
                                controller.isClicked.value = true;
                                controller
                                    .applyCoupon(
                                        coupon:
                                            controller.couponController.text)
                                    .then((_) {
                                  controller.isClicked.value = false;
                                }).catchError((e) {
                                  controller.isClicked.value = false;
                                });
                              }
                            },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        controller.isClicked.value ? "Applying..." : "Apply",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: height * 0.018,
                          fontWeight: FontWeight.w600,
                          color: controller.isClicked.value
                              ? Colors.grey
                              : Get.theme.primaryColor,
                        ),
                      ),
                    )),
              ],
            ),
          ),

          // Coupon Message
          Obx(() => controller.couponeMessage.value.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(top: height * 0.01),
                  child: Text(
                    controller.couponeMessage.value,
                    style: TextStyle(
                      color: controller.couponeMessage.value.contains('success')
                          ? Colors.green
                          : Colors.red,
                      fontSize: height * 0.014,
                    ),
                  ),
                )
              : const SizedBox.shrink()),

          SizedBox(height: height * 0.015),

          // Price Details
          SizedBox(
            width: width * 0.90,
            height: height * 0.18,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _priceRow("Subtotal", "₹${controller.subTotal.value}"),
                _priceRow("Delivery Fee", "Free"),
                _priceRow("Discount",
                    "- ₹${(controller.subTotal.value - controller.total.value).toStringAsFixed(2)}",
                    color: Colors.green),
                const Divider(),
                _priceRow(
                    "Total", "₹${controller.total.value.toStringAsFixed(2)}",
                    isBold: true, fontSize: height * 0.022),
              ],
            ),
          ),

          SizedBox(height: height * 0.015),

          // Checkout Button
          PrimaryActionButton(
            text: "Proceed to Checkout",
            onPressed: () {
              Get.toNamed(Routes.ADDRESS_LIST);
            },
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String value,
      {bool isBold = false, Color? color, double? fontSize}) {
    final height = Get.height;
    final width = Get.width;

    return SizedBox(
      width: width * 0.90,
      height: height * 0.035,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: fontSize ?? height * 0.018,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? DefaultThemeColors.darklighter,
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: fontSize ?? height * 0.018,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartItemRow(int index) {
    final width = Get.width;
    final height = Get.height;

    return Obx(() {
      final product = controller.getProduct(index);
      final variant = controller.getVariant(index);
      final quantity = controller.getQuantity(index);
      final productId = controller.getProductId(index);
      final variantId = controller.getVariantId(index);

      // Use ProductHelper to get image and price info
      final imageUrl = ProductHelper.getProductImage(product);
      debugPrint("------------------------------------OOOO-----");
      debugPrint('--------------------------------------------------');
      debugPrint('🛒 CART IMAGE HIT -> Product: ${product['name']}');
      debugPrint('🔗 URL: $imageUrl');
      debugPrint('--------------------------------------------------');

      // Get variant's effective price
      final variantPrice = HelperFunctions.parseAmount(
          variant['sale_price'] ?? variant['price']);
      final variantRegularPrice = HelperFunctions.parseAmount(variant['price']);
      final hasDiscount =
          HelperFunctions.parseAmount(variant['sale_price']) > 0 &&
              variantRegularPrice >
                  HelperFunctions.parseAmount(variant['sale_price']);

      return Container(
        width: width * 0.92,
        height: height * 0.13,
        padding: EdgeInsets.all(width * 0.026),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height * 0.015),
          border: Border.all(
            color: DefaultThemeColors.darklight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image - Fixed width
            SizedBox(
              width: height * 0.09,
              height: height * 0.09,
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.PRODUCTDETAILS,
                      arguments: {'productId': product['_id']});
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(height * 0.012),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: height * 0.09,
                    height: height * 0.09,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey[400]),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: width * 0.025),

            // Product Details - Takes remaining space
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product['name'] ?? 'Product Name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: height * 0.016,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (variant['name'] != null &&
                      variant['name'].toString().isNotEmpty)
                    Text(
                      variant['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: height * 0.014,
                        fontWeight: FontWeight.w500,
                        color: DefaultThemeColors.lightDarker,
                      ),
                    ),
                  SizedBox(height: height * 0.005),
                  // Price Row - Keep Row but let it shrink properly
                  Row(
                    children: [
                      Text(
                        "₹${variantPrice.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: height * 0.016,
                          fontWeight: FontWeight.w700,
                          color: Get.theme.primaryColor,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          "₹${variantRegularPrice.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: height * 0.014,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            "${(100 - (variantPrice * 100 / variantRegularPrice)).round()}% off",
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: height * 0.0125,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Right side controls - Fixed width group
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quantity Controls
                Container(
                  width: height * 0.12,
                  height: height * 0.04,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height * 0.02),
                    border: Border.all(color: DefaultThemeColors.darklight),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Decrement
                      GestureDetector(
                        onTap: () {
                          if (quantity > 1) {
                            controller.decrementItem(
                                productId, variantId, quantity);
                          }
                        },
                        child: Container(
                          width: height * 0.03,
                          height: height * 0.03,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: quantity > 1
                                ? Get.theme.primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                          child: Icon(
                            Icons.remove,
                            size: height * 0.016,
                            color: quantity > 1
                                ? Get.theme.primaryColor
                                : Colors.grey,
                          ),
                        ),
                      ),

                      // Quantity Text
                      Text(
                        "$quantity",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: height * 0.015,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      // Increment
                      GestureDetector(
                        onTap: () {
                          controller.incrementItem(productId, variantId);
                        },
                        child: Container(
                          width: height * 0.03,
                          height: height * 0.03,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Get.theme.primaryColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.add,
                            size: height * 0.016,
                            color: Get.theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: width * 0.01),
                // Delete Button - Fixed width
                SizedBox(
                  width: height * 0.032,
                  height: height * 0.032,
                  child: IconButton(
                    onPressed: () {
                      _showDeleteConfirmation(
                          index, product['_id'], variant['_id']);
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      size: height * 0.022,
                      color: Colors.red,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showDeleteConfirmation(int index, String productId, String variantId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Product'),
        content: const Text(
            'Are you sure you want to remove this product from cart?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeItem(productId, variantId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

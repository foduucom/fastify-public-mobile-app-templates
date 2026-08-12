import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../components/shimmer/cart_shimmer.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';
import 'package:get_storage/get_storage.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:foduu_ecommerce/components/oderdetail.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class CartView extends GetView<CartController> {
  const CartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'cart_fab',
        onPressed: () {
          GetStorage().erase();
        },
      ),
      appBar: AppBar(
        title: Obx(() => Text(
              controller.cartItems.isEmpty
                  ? 'Shopping Cart'
                  : 'Shopping Cart (${controller.cartItems.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const CartShimmer();
        }

        if (controller.cartItems.isEmpty) {
          return _buildEmptyCart(context, colorScheme, textTheme);
        }

        return _buildCartContent(context, colorScheme, textTheme);
      }),
      bottomNavigationBar: Obx(() => controller.cartItems.isEmpty
          ? const SizedBox.shrink()
          : _buildBottomBar(context, colorScheme, textTheme)),
    );
  }

  Widget _buildEmptyCart(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lotti/emptyanimation.json',
              height: 200,
            ),
            const SizedBox(height: 24),
            Text(
              'Your Cart is Empty',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Looks like you haven\'t added anything to your cart yet.\nExplore our products and find something you love!',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
                itemText: 'START SHOPPING',
                keypressEvent: () {
                  if (Get.isRegistered<BottombarController>()) {
                    Get.find<BottombarController>().currentPageIndex.value = 0;
                    Get.find<BottombarController>()
                        .pageController
                        .jumpToPage(0);
                  }
                  Get.back();
                })
          ],
        ),
      ),
    );
  }

  // ── Cart Content ──────────────────────────────────────
  Widget _buildCartContent(
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
                itemCount: controller.cartItems.length,
                separatorBuilder: (_, __) => Divider(
                  thickness: 1,
                  color: colorScheme.outline.withOpacity(0.3),
                ),
                itemBuilder: (context, index) {
                  return _CartItemCard(
                    controller: controller,
                    index: index,
                  );
                },
              )),

          // ── Coupon Section ──
          Obx(() => AuthDetails.isUserLogin()
              ? _buildCouponSection(context, colorScheme, textTheme)
              : const SizedBox.shrink()),

          if (AuthDetails.isUserLogin()) const Divider(thickness: 8),

          // ── Order Summary ──
          _buildOrderSummary(context, colorScheme, textTheme),

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

  // ── Order Summary ─────────────────────────────────────
  Widget _buildOrderSummary(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Details:',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            double originalBagTotal = controller.bagPriceAmount.value;
            double itemSavings = controller.discountAmount.value;
            double couponDiscountAmount =
                double.tryParse(controller.couponDiscountAmount.value) ?? 0.0;
            double taxableValue =
                controller.subTotalAmount.value - couponDiscountAmount;
            double totalTaxAmount = controller.tax.value;
            double finalTotal = controller.totalAmount.value;

            List<ItemTaxBreakdown> breakdown = controller.taxBreakdownList
                .map((e) => ItemTaxBreakdown(
                      name: e['name']?.toString() ?? 'Product',
                      variantName: e['variant_name']?.toString(),
                      taxPercent: double.tryParse(
                              e['tax_percent']?.toString() ?? '0') ??
                          0.0,
                      taxAmount:
                          double.tryParse(e['tax_amount']?.toString() ?? '0') ??
                              0.0,
                    ))
                .toList();

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
            );
          }),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    TextTheme textTheme,
    ColorScheme colorScheme, {
    Color? valueColor,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium),
        Text(
          value,
          style: valueStyle ??
              textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
        ),
      ],
    );
  }

  // ── Bottom Bar ────────────────────────────────────────
  Widget _buildBottomBar(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Obx(() => Text(
                        '₹${controller.totalAmount.value.toStringAsFixed(2)}',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(Routes.ADDRESS_LIST);
                  },
                  child: const Text(
                    'Place Order',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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

  // ── Coupon Section Widgets ─────────────────────────────────
  Widget _buildCouponSection(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coupons:',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: colorScheme.surfaceVariant.withOpacity(0.4),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icon/cupon.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCouponTextField(context, colorScheme, textTheme)),
                  _buildCouponActionButton(context, colorScheme),
                ],
              ),
            ),
          ),
          _buildCouponMessage(colorScheme),
        ],
      ),
    );
  }

  Widget _buildCouponTextField(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Obx(() => TextFormField(
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
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: controller.isCouponApply.value
                ? controller.viewCouponCode.value
                : 'Enter Coupons',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintStyle: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
        ));
  }

  Widget _buildCouponActionButton(BuildContext context, ColorScheme colorScheme) {
    return Obx(() => controller.isCouponApply.value
        ? IconButton(
            onPressed: () {
              controller.clearCoupon();
            },
            icon: Icon(Icons.cancel, color: colorScheme.error),
          )
        : TextButton(
            onPressed: () => _applyCoupon(context, colorScheme),
            child: Text(
              'Apply',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ));
  }

  void _applyCoupon(BuildContext context, ColorScheme colorScheme) {
    if (controller.couponController.text.isNotEmpty) {
      Get.focusScope?.unfocus();
      controller
          .applyCoupon(coupon: controller.couponController.text)
          .then((value) {
        if (value != null && value.containsKey('code')) {
          controller.isCouponApply.value = true;
          _showCouponSuccessDialog(context, value, colorScheme);
        } else {
          controller.isCouponApply.value = false;
          String errorMessage = value != null && value.containsKey('message')
              ? value['message']
              : 'Invalid coupon code';
          HelperFunctions().showSnackBarError(errorMessage);
        }
      });
    }
  }

  void _showCouponSuccessDialog(
      BuildContext context, dynamic couponResponse, ColorScheme colorScheme) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.asset('assets/lotti/sparkles.json',
                      height: 250, repeat: true),
                  Center(
                    child: Lottie.asset(
                        'assets/lotti/couponapplyanimation.json',
                        height: 140,
                        repeat: true),
                  ),
                ],
              ),
            ),
            const Text(
              'Congratulations!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'lato',
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontFamily: 'lato', color: Colors.black),
                children: [
                  const TextSpan(
                      text:
                          'You have successfully applied the coupon \n you have saved '),
                  TextSpan(
                    text: controller.viewCouponAmount.value.replaceAll("-", ""),
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              itemText: 'Close',
              keypressEvent: () {
                Get.back();
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCouponMessage(ColorScheme colorScheme) {
    return Obx(() => AnimatedOpacity(
          opacity: controller.couponDetails.isEmpty ? 0 : 1,
          duration: const Duration(milliseconds: 500),
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              controller.couponDetails.containsKey('code')
                  ? 'Coupon applied successfully'
                  : controller.couponDetails['message']?.toString() ??
                      'Invalid coupon',
              style: TextStyle(
                fontSize: 13,
                color: controller.couponDetails.containsKey('code')
                    ? Colors.green
                    : colorScheme.error,
              ),
            ),
          ),
        ));
  }
}

class _CartItemCard extends StatelessWidget {
  final CartController controller;
  final int index;

  const _CartItemCard({
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final product = controller.getProduct(index);
    final variant = controller.getVariant(index);
    final quantity = controller.getQuantity(index);
    final productId = controller.getProductId(index);
    final variantId = controller.getVariantId(index);

    // Resolve variant-specific image if variable product, otherwise use parent product image
    final attributes = product['attributes'];
    final isVariableProduct = attributes is List && attributes.isNotEmpty;
    String imageUrl;
    if (isVariableProduct && variant['front_image'] != null) {
      final variantImageUrl =
          HelperFunctions().getImage(variant['front_image']);
      if (variantImageUrl != HelperFunctions.getNoImage() &&
          variantImageUrl.isNotEmpty) {
        imageUrl = variantImageUrl;
      } else {
        imageUrl = ProductHelper.getProductImage(product);
      }
    } else {
      imageUrl = ProductHelper.getProductImage(product);
    }

    debugPrint("------------------------------------OOOO-----");
    debugPrint('--------------------------------------------------');
    debugPrint('🛒 CART IMAGE HIT -> Product: ${product['name']}');
    debugPrint('🔗 URL: $imageUrl');
    debugPrint('--------------------------------------------------');

    // Get variant's effective price
    final variantPrice =
        HelperFunctions.parseAmount(variant['sale_price'] ?? variant['price']);
    final variantRegularPrice = HelperFunctions.parseAmount(variant['price']);
    final hasDiscount =
        HelperFunctions.parseAmount(variant['sale_price']) > 0 &&
            variantRegularPrice >
                HelperFunctions.parseAmount(variant['sale_price']);

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
              child: Container(
                width: 100,
                height: 110,
                color: colorScheme.surfaceVariant.withOpacity(0.4),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 100,
                  height: 110,
                  fit: BoxFit.contain,
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
          ),

          const SizedBox(width: 12),

          // ── Product Details ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                GestureDetector(
                  onTap: () => _navigateToProduct(productId),
                  child: Text(
                    product['name'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Variant Name
                if (variant['name'] != null &&
                    variant['name'] != product['name'] &&
                    variant['variant_name']
                        .toString()
                        .isNotEmpty) // Variant Name
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      variant['name'] ?? '',
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

                const SizedBox(height: 10),

                // Quantity Controls & Remove
                Row(
                  children: [
                    // Quantity Selector
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: colorScheme.outline.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _quantityButton(
                            icon: Icons.remove,
                            onTap: () => controller.decrementItem(
                                productId, variantId, quantity),
                            colorScheme: colorScheme,
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 36),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '$quantity',
                              textAlign: TextAlign.center,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _quantityButton(
                            icon: Icons.add,
                            onTap: () =>
                                controller.incrementItem(productId, variantId),
                            colorScheme: colorScheme,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Remove Button
                    TextButton.icon(
                      onPressed: () =>
                          controller.removeItem(productId, variantId),
                      icon: Icon(Icons.delete_outline,
                          size: 18, color: colorScheme.error),
                      label: Text(
                        'Remove',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: colorScheme.onSurface),
      ),
    );
  }

  void _navigateToProduct(String productId) {
    Get.toNamed(Routes.PRODUCTDETAILS, arguments: {'productId': productId});
  }
}

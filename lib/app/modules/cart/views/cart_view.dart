import 'package:foduu_ecommerce/components/resilience/friendly_error_state.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/commonWidgets/secondary_app_header.dart';
import 'package:foduu_ecommerce/components/shimmer/cart_shimmer.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:get/get.dart';

class CartView extends GetView<CartController> {
  const CartView({Key? key}) : super(key: key);

  ColorScheme get colorScheme => Theme.of(Get.context!).colorScheme;
  TextTheme get textTheme => Theme.of(Get.context!).textTheme;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: SecondaryAppHeader(
          title: "My Cart",
          showRight: false,
          extraActions: [
            IconButton(
              onPressed: () => CartService.to.fetchCart(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const CartShimmer();
                  }

                  if (controller.cartItems.isEmpty &&
                      CartService.to.loadError.value) {
                    return FriendlyErrorState(
                      onRetry: () => CartService.to.fetchCart(),
                    );
                  }

                  if (controller.cartItems.isEmpty) {
                    return _buildEmptyCart(context);
                  }

                  return _buildCartContent(context);
                }),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Obx(
          () => controller.cartItems.isEmpty
              ? const SizedBox.shrink()
              : _buildStickyCheckoutBar(context),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  EMPTY CART STATE
  // ══════════════════════════════════════════════════════════
  Widget _buildEmptyCart(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/emptyimagecart.png',
                height: height * 0.22,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) => Icon(
                  Icons.remove_shopping_cart_outlined,
                  size: height * 0.15,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your Cart is Empty',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Looks like you haven\'t added anything to your cart yet.\nExplore our latest collections and find something you love!',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (Get.isRegistered<BottombarController>()) {
                      final bottomBar = Get.find<BottombarController>();
                      bottomBar.currentPageIndex.value = 0;
                      if (bottomBar.pageController.hasClients) {
                        bottomBar.pageController.jumpToPage(0);
                      }
                    }
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                  label: const Text(
                    'START SHOPPING',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  SCROLLABLE CART CONTENT (ITEMS + COUPON + BILL SUMMARY)
  // ══════════════════════════════════════════════════════════
  Widget _buildCartContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      child: ListView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        children: [
          // Items Count Subheading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${controller.cartItems.length} ${controller.cartItems.length == 1 ? 'Item in Cart' : 'Items in Cart'}",
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Prices inclusive of all taxes",
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cart Items List
          ...List.generate(
            controller.cartItems.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _cartItemRow(index, context),
            ),
          ),

          const SizedBox(height: 8),

          // Coupon Section Card
          _buildCouponCard(context),

          const SizedBox(height: 16),

          // Bill Summary Card
          _buildBillSummaryCard(context),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  CART ITEM CARD (CLEAN, RESPONSIVE, ZERO OVERFLOW)
  // ══════════════════════════════════════════════════════════
  Widget _cartItemRow(int index, BuildContext context) {
    return Obx(() {
      final product = controller.getProduct(index);
      final variant = controller.getVariant(index);
      final quantity = controller.getQuantity(index);
      final productId = controller.getProductId(index);
      final variantId = controller.getVariantId(index);

      final imageUrl = ProductHelper.getProductImage(product);
      final productName = product['name'] ?? 'Product Name';
      final variantName = (variant['name'] ?? '').toString().trim();
      final showVariantSubtitle = variantName.isNotEmpty &&
          variantName.toLowerCase() != productName.toString().toLowerCase();

      final variantPrice = HelperFunctions.parseAmount(
        variant['sale_price'] ?? variant['price'],
      );
      final variantRegularPrice = HelperFunctions.parseAmount(variant['price']);
      final hasDiscount =
          HelperFunctions.parseAmount(variant['sale_price']) > 0 &&
              variantRegularPrice >
                  HelperFunctions.parseAmount(variant['sale_price']);

      final discountPercent = hasDiscount && variantRegularPrice > 0
          ? ((100 - (variantPrice * 100 / variantRegularPrice)).round())
          : 0;

      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Thumbnail
            GestureDetector(
              onTap: () {
                if (product['_id'] != null) {
                  Get.toNamed(
                    Routes.PRODUCTDETAILS,
                    arguments: {'productId': product['_id']},
                  );
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 82,
                  height: 82,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 82,
                    height: 82,
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 82,
                    height: 82,
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: colorScheme.onSurfaceVariant,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Product Details (Title, Variant, Price, Stepper)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Product Title & Delete Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _showDeleteConfirmation(
                            index, productId, variantId),
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 4.0, bottom: 4.0),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: colorScheme.error.withOpacity(0.85),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Variant Chip (only if distinct)
                  if (showVariantSubtitle) ...[
                    const SizedBox(height: 3),
                    Text(
                      variantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Bottom Row: Price Breakdown & Quantity Stepper
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Pricing Block with Wrap to guarantee ZERO overflow
                      Flexible(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            Text(
                              "₹${variantPrice.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                            if (hasDiscount) ...[
                              Text(
                                "₹${variantRegularPrice.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.lineThrough,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "$discountPercent% off",
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Quantity Stepper [- qty +]
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.35),
                          ),
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Minus Button
                            InkWell(
                              onTap: () {
                                if (quantity > 1) {
                                  controller.decrementItem(
                                      productId, variantId, quantity);
                                } else {
                                  _showDeleteConfirmation(
                                      index, productId, variantId);
                                }
                              },
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(20)),
                              child: Container(
                                width: 28,
                                height: 32,
                                alignment: Alignment.center,
                                child: Icon(
                                  quantity > 1
                                      ? Icons.remove
                                      : Icons.delete_outline,
                                  size: 14,
                                  color: quantity > 1
                                      ? colorScheme.onSurface
                                      : colorScheme.error,
                                ),
                              ),
                            ),

                            // Quantity Display
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "$quantity",
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            // Plus Button
                            InkWell(
                              onTap: () => controller.incrementItem(
                                  productId, variantId),
                              borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(20)),
                              child: Container(
                                width: 28,
                                height: 32,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.add,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
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
    });
  }

  // ══════════════════════════════════════════════════════════
  //  COUPON PROMO CARD
  // ══════════════════════════════════════════════════════════
  Widget _buildCouponCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer_outlined,
                  size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                "Apply Promo Code",
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: controller.couponController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: "Enter Promo Code",
                      hintStyle: TextStyle(fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Obx(
                  () => TextButton(
                    onPressed: controller.isClicked.value
                        ? null
                        : () {
                            if (controller.couponController.text
                                .trim()
                                .isNotEmpty) {
                              controller.isClicked.value = true;
                              controller
                                  .applyCoupon(
                                      coupon: controller.couponController.text
                                          .trim())
                                  .then((_) {
                                controller.isClicked.value = false;
                              }).catchError((e) {
                                controller.isClicked.value = false;
                              });
                            }
                          },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      foregroundColor: colorScheme.primary,
                    ),
                    child: Text(
                      controller.isClicked.value ? "Applying..." : "Apply",
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => controller.couponeMessage.value.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          controller.couponeMessage.value.contains('success')
                              ? Icons.check_circle_outline
                              : Icons.error_outline,
                          size: 14,
                          color: controller.couponeMessage.value
                                  .contains('success')
                              ? Colors.green
                              : colorScheme.error,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            controller.couponeMessage.value,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: controller.couponeMessage.value
                                      .contains('success')
                                  ? Colors.green
                                  : colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  BILL SUMMARY BREAKDOWN CARD
  // ══════════════════════════════════════════════════════════
  Widget _buildBillSummaryCard(BuildContext context) {
    return Obx(() {
      final subTotal = controller.subTotal.value;
      final total = controller.total.value;
      final discount = subTotal > total ? (subTotal - total) : 0.0;

      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  "Price Details",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _summaryLine("Subtotal", "₹${subTotal.toStringAsFixed(2)}"),
            const SizedBox(height: 10),
            _summaryLine(
              "Delivery Fee",
              "FREE",
              valueColor: Colors.green,
              valueBold: true,
            ),
            if (discount > 0) ...[
              const SizedBox(height: 10),
              _summaryLine(
                "Discount",
                "- ₹${discount.toStringAsFixed(2)}",
                valueColor: Colors.green,
                valueBold: true,
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Amount",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  "₹${total.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _summaryLine(
    String label,
    String value, {
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  //  STICKY BOTTOM CHECKOUT BAR
  // ══════════════════════════════════════════════════════════
  Widget _buildStickyCheckoutBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.18),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, -3),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final total = controller.total.value;

          return Row(
            children: [
              // Total Summary Column
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "₹${total.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Primary Checkout Button
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    if (AuthDetails.isUserLogin()) {
                      Get.toNamed(Routes.ADDRESS_LIST);
                    } else {
                      Get.snackbar(
                        "Login Required",
                        "Please sign in to proceed with your order",
                        backgroundColor: colorScheme.error,
                        colorText: colorScheme.onError,
                        margin: const EdgeInsets.all(16),
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Proceed to Checkout",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  DELETE CONFIRMATION DIALOG
  // ══════════════════════════════════════════════════════════
  void _showDeleteConfirmation(int index, String productId, String variantId) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove from Cart',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: const Text(
          'Are you sure you want to remove this item from your cart?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeItem(productId, variantId);
            },
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: const Text('Remove',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

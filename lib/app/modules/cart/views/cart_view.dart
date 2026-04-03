import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../components/app_back_button.dart';
import '../../../../components/app_bar2.dart';
import '../../../../components/shimmer/cart_shimmer.dart';
import '/components/buttons/appbutton.dart';
import '/core/foduuStudio/foduu_studio_layout_view.dart';
import '/app/modules/bottomar/controllers/bottombar_controller.dart';
import '/app/modules/cart/controllers/cart_controller.dart';
import '/app/routes/app_pages.dart';
import '/constants/helper_functions.dart';
import '/constants/product_helper.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class CartView extends GetView<CartController> {
  const CartView({Key? key}) : super(key: key);

  // ── Open Coupon Bottom Sheet ──────────────────────────────────────────
  void _openCouponSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CouponBottomSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar2(
        title: 'My Cart',
        showBackButton: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const CartShimmer();
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

  // ── Empty Cart ────────────────────────────────────────────────────────
  Widget _buildEmptyCart(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lotti/emptyanimation.json', height: 200),
            const SizedBox(height: 24),
            Text('Your Cart is Empty',
                style:
                textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Looks like you haven\'t added anything to your cart yet.\nExplore our products and find something you love!',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 32),
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
        ),
      ),
    );
  }

  // ── Cart Content ──────────────────────────────────────────────────────
  Widget _buildCartContent(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return RefreshIndicator(
      color: colorScheme.primary,
      onRefresh: controller.onRefresh,
      child: ListView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        children: [

          const SizedBox(height: 8),

          // ── Cart Items ───────────────────────────────────────────
          Obx(() => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.cartItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) => _CartItemCard(
              controller: controller,
              index: index,
            ),
          )),

          const SizedBox(height: 16),

          // ── Coupon Row — taps to open bottom sheet ───────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => _openCouponSheet(context),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_offer_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(() => Text(
                        controller.appliedCoupon.value.isNotEmpty
                            ? controller.appliedCoupon.value
                            : 'Select or Enter Coupon Code',
                        style: TextStyle(
                          color: controller.appliedCoupon.value.isNotEmpty
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade400,
                          fontSize: 14,
                          fontWeight:
                          controller.appliedCoupon.value.isNotEmpty
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      )),
                    ),
                    Obx(() => controller.appliedCoupon.value.isNotEmpty
                        ? GestureDetector(
                      onTap: () => controller.clearCoupon(),
                      child: Icon(Icons.close,
                          color: Colors.grey.shade400, size: 18),
                    )
                        : Icon(Icons.chevron_right,
                        color: Colors.grey.shade400, size: 20)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Order Summary ────────────────────────────────────────
          _buildOrderSummary(context, colorScheme, textTheme),

          // ── Dynamic Layout Widgets ───────────────────────────────
          Obx(() => controller.widgetList.isNotEmpty
              ? FoduuStudioLayoutView.embedded(
            widgetList: controller.widgetList,
            isLoading: controller.isLayoutLoading,
          )
              : const SizedBox.shrink()),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Order Summary ─────────────────────────────────────────────────────
  Widget _buildOrderSummary(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Obx(() => _summaryRow(
            context: context,
            label: 'Sub Total',
            value:
            '\$${controller.subTotal.value.toStringAsFixed(2)}',
            textTheme: textTheme,
          )),
          const SizedBox(height: 12),
          _summaryRow(
            context: context,
            label: 'Shipping',
            value: 'FREE',
            textTheme: textTheme,
            valueColor: colorScheme.primary,
          ),

          // ── Coupon Discount Row (shown only when coupon applied) ──
          Obx(() => controller.couponDiscount.value > 0
              ? Column(
            children: [
              const SizedBox(height: 12),
              _summaryRow(
                context: context,
                label: 'Coupon Discount',
                value:
                '-\$${controller.couponDiscount.value.toStringAsFixed(2)}',
                textTheme: textTheme,
                valueColor: Colors.green,
              ),
            ],
          )
              : const SizedBox.shrink()),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey.shade200, thickness: 1),
          ),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '\$ ',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: controller.total.value
                          .toStringAsFixed(2),
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required BuildContext context,
    required String label,
    required String value,
    required TextTheme textTheme,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            )),
        Text(value,
            style: textTheme.bodyLarge?.copyWith(
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────
  Widget _buildBottomBar(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () => Get.toNamed(Routes.ADDRESS_LIST),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: Text(
            'Continue',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Coupon Bottom Sheet ───────────────────────────────────────────────────────
class _CouponBottomSheet extends StatefulWidget {
  final CartController controller;
  const _CouponBottomSheet({required this.controller});

  @override
  State<_CouponBottomSheet> createState() => _CouponBottomSheetState();
}

class _CouponBottomSheetState extends State<_CouponBottomSheet> {
  String? _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.controller.appliedCoupon.value.isNotEmpty
        ? widget.controller.appliedCoupon.value
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    // Use coupons from controller; fallback to dummy list if empty
// ✅ AFTER — explicitly typed
    final List<Map<String, dynamic>> coupons =
    widget.controller.availableCoupons.isNotEmpty
        ? List<Map<String, dynamic>>.from(
        widget.controller.availableCoupons)
        : <Map<String, dynamic>>[
      {
        'title': '50% Cashback',
        'code': 'CASH50',
        'expires': 'Expired in 2 days',
        'discount': 50.0,
      },
      {
        'title': '15% Discount',
        'code': 'DISC15',
        'expires': 'Expired in 1 days',
        'discount': 15.0,
      },
      {
        'title': '10% Cashback',
        'code': 'CASH10',
        'expires': 'Expired in 7 days',
        'discount': 10.0,
      },
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Drag Handle ─────────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // ── Title Row ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Coupon',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.close,
                          color: Colors.black87, size: 24),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Coupon List ─────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: coupons.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final coupon = coupons[index];
                    final code  = coupon['code']?.toString() ?? '';
                    final isSelected = _selectedCode == code;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedCode = code),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary
                              .withValues(alpha: 0.04)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [

                            // Coupon badge icon
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colorScheme.primary
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.discount_outlined,
                                color: colorScheme.primary,
                                size: 22,
                              ),
                            ),

                            const SizedBox(width: 14),

                            // Title + expiry
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    coupon['title']?.toString() ?? '',
                                    style: textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        coupon['expires']
                                            ?.toString() ??
                                            '',
                                        style:
                                        textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () {
                                          // TODO: show coupon detail
                                        },
                                        child: Text(
                                          'See Detail',
                                          style: textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Checkmark when selected
                            if (isSelected)
                              Icon(Icons.check,
                                  color: colorScheme.primary, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ── Use Coupon Button ───────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _selectedCode == null
                      ? null
                      : () {
                    final selected = coupons.firstWhere(
                          (c) =>
                      c['code']?.toString() == _selectedCode,
                      orElse: () =>  <String, dynamic>{},
                    );
                    if (selected.isNotEmpty) {
                      widget.controller.applyCouponFromSheet(
                        code: _selectedCode!,
                        title: selected['title']?.toString() ?? '',
                        discount: (selected['discount'] as num?)
                            ?.toDouble() ??
                            0,
                      );
                    }
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Use Coupon',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

// ── Cart Item Card ────────────────────────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final CartController controller;
  final int index;

  const _CartItemCard({required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    final product    = controller.getProduct(index);
    final variant    = controller.getVariant(index);
    final quantity   = controller.getQuantity(index);
    final productId  = controller.getProductId(index);
    final variantId  = controller.getVariantId(index);

    final imageUrl            = ProductHelper.getProductImage(product);
    final variantPrice        = HelperFunctions.parseAmount(variant['sale_price'] ?? variant['price']);
    final variantRegularPrice = HelperFunctions.parseAmount(variant['price']);
    final hasDiscount         = HelperFunctions.parseAmount(variant['sale_price']) > 0 &&
        variantRegularPrice > HelperFunctions.parseAmount(variant['sale_price']);
    final discountPercent = hasDiscount
        ? (100 - (variantPrice * 100 / variantRegularPrice)).round()
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Get.toNamed(Routes.PRODUCTDETAILS,
                arguments: {'productId': productId}),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 110,
                      height: 110,
                      color: Colors.grey.shade100,
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey.shade400),
                    ),
                    progressIndicatorBuilder: (_, __, progress) => Container(
                      width: 110,
                      height: 110,
                      color: Colors.grey.shade100,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: progress.progress,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                      ),
                      child: Text(
                        '$discountPercent%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed(Routes.PRODUCTDETAILS,
                      arguments: {'productId': productId}),
                  child: Text(
                    product['name'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  variant['name']?.toString().isNotEmpty == true
                      ? 'For ${variant['name']}'
                      : 'For 1Kg',
                  style: textTheme.bodySmall
                      ?.copyWith(color: Colors.grey.shade500),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('\$$variantPrice',
                        style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    if (hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text('\$$variantRegularPrice',
                          style: textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.red.shade300,
                            decorationColor: Colors.red.shade300,
                          )),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _stepperBtn(
                          icon: Icons.remove,
                          onTap: () => controller.decrementItem(
                              productId, variantId, quantity),
                          colorScheme: colorScheme),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('$quantity',
                            style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                      ),
                      _stepperBtn(
                          icon: Icons.add,
                          onTap: () =>
                              controller.incrementItem(productId, variantId),
                          colorScheme: colorScheme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepperBtn(
      {required IconData icon,
        required VoidCallback onTap,
        required ColorScheme colorScheme}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 1))
          ],
        ),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }
}
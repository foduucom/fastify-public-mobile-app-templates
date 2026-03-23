import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app_colors.dart';
import '../../../../components/app_bar/custom_app_bar.dart';
import '../../../../components/app_bar/custom_app_bar2.dart';
import '../controller/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            AppTopBar(title: 'Add to Cart'),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1A1A1A)),
                  );
                }
                if (controller.cartItems.isEmpty) return _EmptyCart();
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, i) {
                    final item = controller.cartItems[i];
                    return _CartItemCard(
                      key: ValueKey(controller.itemId(item)), // ✅ prevents full rebuild
                      item: item,
                    );
                  },
                );
              }),
            ),
            Obx(() {
              if (controller.cartItems.isEmpty) return const SizedBox.shrink();
              return _BottomBar();
            }),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Bar ─────────────────────────────────────────────────────
class _BottomBar extends GetView<CartController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Total',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w400,
                  )),
              Obx(() => Text(
                '\$${controller.total.value.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              )),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: controller.onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: AppColors.scaffoldBackground,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                child: const Text('Checkout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty Cart ─────────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: const BoxDecoration(
                color: AppColors.scaffoldBackground, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_basket_outlined,
                size: 44, color: AppColors.scaffoldBackground),
          ),
          const SizedBox(height: 20),
          const Text('Your cart is empty',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          const Text('Add items to get started',
              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text('Continue Shopping',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cart Item Card ─────────────────────────────────────────────────
class _CartItemCard extends GetView<CartController> {
  final Map<String, dynamic> item;
  const _CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final name     = controller.itemName(item);
    final price    = controller.itemPrice(item);
    final imageUrl = controller.itemImage(item);
    final qty      = controller.itemQuantity(item);
    final id       = controller.itemId(item);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // ── Image ──────────────────────────────────────────
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3F0),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFFD0D0D0)),
              ),
              errorWidget: (_, __, ___) => const Icon(
                  Icons.chair_outlined,
                  size: 40, color: Color(0xFFD0D0D0)),
            )
                : const Icon(Icons.chair_outlined,
                size: 40, color: Color(0xFFD0D0D0)),
          ),
          const SizedBox(width: 14),

          // ── Info + Controls ────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text('\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    )),
                const SizedBox(height: 10),
                Obx(() {
                  final loading = controller.updatingItemId.value == id;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity Counter
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 4, vertical: 4),
                      //   decoration: BoxDecoration(
                      //     color: const Color(0xFFF0EEEB),
                      //     borderRadius: BorderRadius.circular(50),
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       _QtyButton(
                      //         icon: Icons.remove,
                      //         onTap: loading
                      //             ? null
                      //             : () => controller.updateQuantity(item, qty - 1),
                      //       ),
                      //       const SizedBox(width: 12),
                      //       Text('$qty',
                      //           style: const TextStyle(
                      //             fontSize: 15,
                      //             fontWeight: FontWeight.w600,
                      //             color: Color(0xFF1A1A1A),
                      //           )),
                      //       const SizedBox(width: 12),
                      //       _QtyButton(
                      //         icon: Icons.add,
                      //         onTap: loading
                      //             ? null
                      //             : () => controller.updateQuantity(item, qty + 1),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // Delete Button
                      GestureDetector(
                        onTap: loading ? null : () => controller.removeItem(item),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: loading
                              ? const Padding(
                            padding: EdgeInsets.all(9),
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF1A1A1A)),
                          )
                              : const Icon(Icons.delete_outline,
                              size: 18, color: Color(0xFF9E9E9E)),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: const Color(0xFF1A1A1A)),
      ),
    );
  }
}

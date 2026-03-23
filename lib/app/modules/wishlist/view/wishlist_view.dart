import 'package:cached_network_image/cached_network_image.dart'; // ✅ ADD THIS
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../components/app_bar/custom_app_bar.dart';
import '../controller/wishlist_controller.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WishlistController());

    return Scaffold(
      backgroundColor: const Color(0xFFEEECE8),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            AppTopBar(title: 'Wishlist'),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1A1A1A)),
                  );
                }
                if (controller.items.isEmpty) return _EmptyWishlist();
                return RefreshIndicator(
                  color: const Color(0xFF1A1A1A),
                  onRefresh: controller.fetchWishlist,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 4),
                    itemCount: controller.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) => _WishlistCard(
                      item: controller.items[i],
                      controller: controller,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────
class _EmptyWishlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.favorite_border_rounded,
                size: 44, color: Color(0xFFD0D0D0)),
          ),
          const SizedBox(height: 20),
          const Text('Your wishlist is empty',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          const Text('Save items you love here',
              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text('Explore Products',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wishlist Card ─────────────────────────────────────────────────
class _WishlistCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final WishlistController controller;
  const _WishlistCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final imageUrl   = controller.itemImage(item);
    final name       = controller.itemName(item);
    final variant    = controller.variantName(item);
    final price      = controller.itemPrice(item);
    final origPrice  = controller.originalPrice(item);
    final discounted = controller.hasDiscount(item);
    final wId        = controller.wishlistId(item);
    final pId        = controller.productId(item);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Image ─────────────────────────────────────────────
          GestureDetector(
            onTap: () => Get.toNamed('/productdetails', arguments: pId),
            child: Container(
              width: 90, height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3F0),
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(          // ✅ replaces Image.network
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFD0D0D0)),
                ),
                errorWidget: (_, __, ___) => _imageFallback(),
              )
                  : _imageFallback(),
            ),
          ),
          const SizedBox(width: 14),

          // ── Info ──────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                GestureDetector(
                  onTap: () =>
                      Get.toNamed('/productdetails', arguments: pId),
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (variant.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(variant,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],

                const SizedBox(height: 10),

                // ── Price Row ──────────────────────────────────
                Row(
                  children: [
                    Text('\$${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        )),
                    if (discounted) ...[
                      const SizedBox(width: 6),
                      Text('\$${origPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9E9E9E),
                            decoration: TextDecoration.lineThrough,
                          )),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${(((origPrice - price) / origPrice) * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // ── Action Buttons ─────────────────────────────
                Row(
                  children: [
                    // 🔹 VIEW BUTTON
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.toNamed(
                          '/productdetails',
                          arguments: pId,
                        ),
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_basket_outlined,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'View',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // 🔹 MOVE TO CART BUTTON
                    Flexible(
                      child: GestureDetector(
                        onTap: () => controller.removeItem(item),
                        child: Container(
                          height: 32, // 🔻 smaller height
                          padding: const EdgeInsets.symmetric(horizontal: 6), // 🔻 less padding
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.add_shopping_cart,
                                size: 14, // 🔻 smaller icon
                                color: Color(0xFF4CAF50),
                              ),
                              SizedBox(width: 3),
                              Flexible( // ✅ THIS is critical
                                child: Text(
                                  "Move",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11, // 🔻 smaller text
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() => const Icon(
      Icons.image_not_supported_outlined,
      size: 36,
      color: Color(0xFFD0D0D0));
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';

/// Modal Bottom Sheet that informs the user that an item in their cart is out
/// of stock and provides standard e-commerce resolution actions.
Future<void> showOutOfStockBottomSheet({
  required String productName,
  Map<String, dynamic>? cartItem,
  required Future<void> Function() onRemoveAndContinue,
  Future<void> Function()? onSaveToWishlist,
  required VoidCallback onReturnToCart,
}) async {
  if (Get.isBottomSheetOpen == true) return;

  final context = Get.context!;
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  // Extract product details if cartItem is available
  final product = cartItem?['product_id'] is Map
      ? cartItem!['product_id'] as Map
      : (cartItem?['product'] is Map ? cartItem!['product'] as Map : <String, dynamic>{});
  final variant = cartItem?['variant_id'] is Map
      ? cartItem!['variant_id'] as Map
      : (cartItem?['variant'] is Map ? cartItem!['variant'] as Map : <String, dynamic>{});

  final displayName = productName.isNotEmpty
      ? productName
      : (product['name']?.toString() ?? 'Selected Item');

  final String imageUrl = HelperFunctions().getImage(
    variant['front_image'] ??
        variant['featured_image'] ??
        product['featured_image'] ??
        product['front_image'] ??
        cartItem?['image'],
  );

  final variantName = variant['name']?.toString() ??
      variant['variant']?.toString() ??
      cartItem?['variant_name']?.toString() ??
      '';

  final priceVal = double.tryParse(
          (variant['price'] ?? product['price'] ?? cartItem?['price'] ?? 0)
              .toString()) ??
      0.0;
  final displayPrice =
      priceVal > 0 ? '\$${priceVal.toStringAsFixed(2)}' : '';

  await Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle pill
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Warning icon badge
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.remove_shopping_cart_outlined,
                  size: 28,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              'Item Out of Stock',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lato',
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle
            Text(
              'One or more items in your cart became unavailable before your order was completed. Please update your order to proceed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                fontFamily: 'Lato',
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 18),

            // Product summary preview card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Product thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 58,
                      height: 58,
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: Colors.grey.withOpacity(0.15),
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.grey.withOpacity(0.15),
                                child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                              ),
                            )
                          : Container(
                              color: Colors.grey.withOpacity(0.15),
                              child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Lato',
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (variantName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Variant: $variantName',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Lato',
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Out of stock',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Lato',
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            if (displayPrice.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                displayPrice,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Lato',
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action 1: Remove & Continue (Primary)
            AppButton(
              itemText: 'Remove & Continue',
              keypressEvent: () async {
                Get.back(); // Close bottom sheet
                await onRemoveAndContinue();
              },
            ),

            // Action 2: Save to Wishlist & Remove (Secondary)
            if (onSaveToWishlist != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Get.back(); // Close bottom sheet
                    await onSaveToWishlist();
                  },
                  icon: const Icon(
                    Icons.favorite_border_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Save to Wishlist & Remove',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Lato',
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.grey.withOpacity(0.4),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],

            // Action 3: Return to Cart (Tertiary)
            const SizedBox(height: 6),
            SizedBox(
              height: 40,
              child: TextButton(
                onPressed: () {
                  Get.back(); // Close bottom sheet
                  onReturnToCart();
                },
                child: Text(
                  'Return to Cart',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lato',
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
  );
}

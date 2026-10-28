import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/components/product_image_placeholder.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

/// Modal Bottom Sheet that informs the user that an item in their cart is out
/// of stock and provides standard e-commerce resolution actions.
Future<void> showOutOfStockBottomSheet({
  required String productName,
  Map<String, dynamic>? cartItem,
  required Future<bool> Function() onRemoveAndContinue,
  Future<bool> Function()? onSaveToWishlist,
  required VoidCallback onReturnToCart,
}) async {
  if (Get.isBottomSheetOpen == true) return;

  // Extract product details if cartItem is available
  final product = cartItem?['product'] is Map
      ? cartItem!['product'] as Map
      : <String, dynamic>{};
  final variant = cartItem?['variant'] is Map
      ? cartItem!['variant'] as Map
      : <String, dynamic>{};

  final displayName = productName.isNotEmpty
      ? productName
      : (product['name']?.toString() ?? 'Selected Item');

  final String imageUrl = HelperFunctions().getImage(
    variant['front_image'] ??
        variant['featured_image'] ??
        product['featured_image'] ??
        product['front_image'],
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

  bool isRemoving = false;
  bool isSavingWishlist = false;

  await Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) {
        final isBusy = isRemoving || isSavingWishlist;

        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
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
                      color: context.themegreyColor.withValues(alpha: 0.5),
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
                      color: context.themeRedColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.remove_shopping_cart_outlined,
                      size: 28,
                      color: context.themeRedColor,
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
                    fontFamily: 'Poppins',
                    color: context.themeTextColor,
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
                    fontFamily: 'Poppins',
                    color: context.themeSecondrytext,
                  ),
                ),
                const SizedBox(height: 18),

                // Product summary preview card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? context.themegreyColor.withValues(alpha: 0.18)
                        : const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.themeRedColor.withValues(alpha: 0.25),
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
                                  placeholder: (context, url) =>
                                      const ProductImagePlaceholder(),
                                  errorWidget: (context, url, error) =>
                                      const ProductImagePlaceholder(),
                                )
                              : const ProductImagePlaceholder(),
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
                                fontFamily: 'Poppins',
                                color: context.themeTextColor,
                              ),
                            ),
                            if (variantName.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Variant: $variantName',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Poppins',
                                  color: context.themeSecondrytext,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: context.themeRedColor
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Out of stock',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      color: context.themeRedColor,
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
                                      fontFamily: 'Poppins',
                                      color: context.themeSecondrytext,
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
                SizedBox(
                  width: double.infinity,
                  height: themeButtonHeight,
                  child: ElevatedButton(
                    onPressed: isBusy
                        ? null
                        : () async {
                            setState(() => isRemoving = true);
                            final success = await onRemoveAndContinue();
                            if (success) {
                              if (Get.isBottomSheetOpen == true) Get.back();
                            } else {
                              setState(() => isRemoving = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themePrimaryColor,
                      disabledBackgroundColor:
                          themePrimaryColor.withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(themeButtonRadius),
                      ),
                    ),
                    child: isRemoving
                        ? HelperFunctions()
                            .loadingIndicator(color: Colors.white)
                        : const Text(
                            'REMOVE & CONTINUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                  ),
                ),

                // Action 2: Save to Wishlist & Remove (Secondary)
                if (onSaveToWishlist != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: themeButtonHeight,
                    child: OutlinedButton.icon(
                      onPressed: isBusy
                          ? null
                          : () async {
                              setState(() => isSavingWishlist = true);
                              final success = await onSaveToWishlist();
                              if (success) {
                                if (Get.isBottomSheetOpen == true) Get.back();
                              } else {
                                setState(() => isSavingWishlist = false);
                              }
                            },
                      icon: isSavingWishlist
                          ? const SizedBox.shrink()
                          : Icon(
                              Icons.favorite_border_rounded,
                              size: 18,
                              color: context.themeTextColor,
                            ),
                      label: isSavingWishlist
                          ? HelperFunctions().loadingIndicator(
                              color: context.themePrimaryColor)
                          : Text(
                              'Save to Wishlist & Remove',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: context.themeTextColor,
                              ),
                            ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: context.themegreyColor.withValues(alpha: 0.6),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(themeButtonRadius),
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
                    onPressed: isBusy
                        ? null
                        : () {
                            Get.back(); // Close bottom sheet
                            onReturnToCart();
                          },
                    child: Text(
                      'Return to Cart',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: isBusy
                            ? context.themeSecondrytext.withValues(alpha: 0.5)
                            : context.themeSecondrytext,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
  );
}

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_mixin.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:get/get.dart';

class WishlistController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  RxList<Map<String, dynamic>> get wishlistItems =>
      WishListService.to.wishListItems;
  var isLoading = false.obs;
  var isCartLoading = false.obs;
  var scrollController = ScrollController();
  var itemQuantities = <String, int>{}.obs;
  var viewMode = 'list'.obs; // or 'grid' as default

  void setViewMode(String mode) {
    viewMode.value = mode;
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    fetchLayout('wishlist');
    if (AuthDetails.isUserLogin()) {
      await fetchWishlist();
    }
  }

  Future<void> fetchWishlist() async {
    isLoading.value = true;
    await WishListService.to.fetchWishList();
    isLoading.value = false;
  }

  Future<void> onRefresh() async {
    await fetchWishlist();
  }

  Map<String, dynamic> getProduct(int index) {
    if (index >= wishlistItems.length) return {};
    final item = wishlistItems[index];
    if (item['product_id'] != null && item['product_id'] is Map) {
      return Map<String, dynamic>.from(item['product_id']);
    }
    return {};
  }

  Map<String, dynamic> getVariant(int index) {
    if (index >= wishlistItems.length) return {};
    final item = wishlistItems[index];
    if (item['variant_id'] != null && item['variant_id'] is Map) {
      return Map<String, dynamic>.from(item['variant_id']);
    }
    // Fallback: Use the product itself as the variant (for simple products)
    return getProduct(index);
  }

  Map<String, dynamic> getPriceInfo(int index) {
    final variant = getVariant(index);
    return ProductHelper.calculatePriceInfo(variant);
  }

  String getStoreName(int index) {
    if (index >= wishlistItems.length) return 'Store Name';
    final product = getProduct(index);
    return (product['shop_id']?['name'] ??
            product['storeName'] ??
            product['shop_name'] ??
            'Store Name')
        .toString();
  }

  int getQuantity(int index) {
    return wishlistItems[index]['quantity'] ?? 1;
  }

  String getVariantSlug(int index) {
    final item = wishlistItems[index];
    return (item['variant_slug'] ??
            item['variant_id']?['slug'] ??
            item['product_id']?['slug'] ??
            item['slug'] ??
            '')
        .toString();
  }

  String getProductId(int index) {
    if (index >= wishlistItems.length) return '';
    final item = wishlistItems[index];
    final product = item['product_id'];

    if (product is Map) {
      return (product['_id'] ?? product['id'] ?? '').toString();
    }

    return '';
  }

  String? getVariantId(int index) {
    if (index >= wishlistItems.length) return null;
    final item = wishlistItems[index];
    final variant = item['variant_id'];

    if (variant is Map) {
      return (variant['_id'] ?? variant['id'] ?? '').toString();
    }

    return (item['variant_id'] ?? '').toString().isNotEmpty
        ? item['variant_id'].toString()
        : null;
  }

  String _getItemKey(int index) {
    return "${getProductId(index)}_${getVariantId(index) ?? 'no_variant'}";
  }

  int getItemQuantity(int index) {
    return itemQuantities[_getItemKey(index)] ?? 1;
  }

  void incrementItemQuantity(int index) {
    String key = _getItemKey(index);
    int current = itemQuantities[key] ?? 1;
    if (current < 10) {
      itemQuantities[key] = current + 1;
    }
  }

  void decrementItemQuantity(int index) {
    String key = _getItemKey(index);
    int current = itemQuantities[key] ?? 1;
    if (current > 1) {
      itemQuantities[key] = current - 1;
    }
  }

  Future<void> addToCart(int index) async {
    isCartLoading.value = true;
    try {
      final product = getProduct(index);
      final productId = getProductId(index);
      final quantity = getItemQuantity(index);

      if (productId.isEmpty) return;

      String? variantId = getVariantId(index);

      // If no variant stored in wishlist, try product's first variant
      if (variantId == null || variantId.isEmpty) {
        final variants = product['variants'] as List?;
        if (variants != null && variants.isNotEmpty) {
          variantId =
              (variants.first['_id'] ?? variants.first['id'])?.toString();
        }
      }

      if (variantId == null || variantId.isEmpty) {
        Get.snackbar(
          "Select Variant",
          "Please open the product to select a variant before adding to cart",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      await Get.find<CartService>().manageCart(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
        product: product,
      );

      Get.snackbar(
        "Success",
        "Added to cart successfully",
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error adding to cart from wishlist: $e");
      Get.snackbar(
        "Error",
        "Failed to add to cart",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isCartLoading.value = false;
    }
  }
}

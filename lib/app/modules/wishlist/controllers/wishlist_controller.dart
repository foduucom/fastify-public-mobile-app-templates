import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_mixin.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:get/get.dart';

class WishlistController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  RxList<Map<String, dynamic>> get wishlistItems =>
      WishListService.to.wishListItems;
  var isLoading = false.obs;
  var scrollController = ScrollController();

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
    final product = getProduct(index);
    return ProductHelper.calculatePriceInfo(product);
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
}

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_mixin.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';
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
    final item = wishlistItems[index];
    if (item.containsKey('product_id') && item['product_id'] is Map) {
      return Map<String, dynamic>.from(item['product_id']);
    }
    return Map<String, dynamic>.from(item);
  }

  Map<String, dynamic> getVariant(int index) {
    final item = wishlistItems[index];
    if (item.containsKey('variant_id') && item['variant_id'] is Map) {
      return Map<String, dynamic>.from(item['variant_id']);
    }
    return Map<String, dynamic>.from(item);
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
    final item = wishlistItems[index];
    final product = item['product_id'];

    if (product is Map) {
      return (product['_id'] ?? product['id'] ?? '').toString();
    }

    // Fallback: check if the item itself has the ID (flattened structure)
    return (item['_id'] ?? item['id'] ?? '').toString();
  }
}

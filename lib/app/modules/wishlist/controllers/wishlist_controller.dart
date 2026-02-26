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
    return Map<String, dynamic>.from(wishlistItems[index]['product_id'] ?? {});
  }

  Map<String, dynamic> getVariant(int index) {
    return Map<String, dynamic>.from(wishlistItems[index]['variant_id'] ?? {});
  }

  int getQuantity(int index) {
    return wishlistItems[index]['quantity'] ?? 1;
  }

  String getVariantSlug(int index) {
    return wishlistItems[index]['variant_slug'] ?? '';
  }

  String getProductId(int index) {
    final product = wishlistItems[index]['product_id'];
    if (product is Map) {
      return product['_id'] ?? product['id'] ?? '';
    }
    return product?.toString() ?? '';
  }
}

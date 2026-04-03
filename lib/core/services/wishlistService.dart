import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '/app/data/basic_provider.dart';
import '/app/controllers/api_exception_handle_controller.dart';

class WishListService extends GetxService with BaseController {
  /// Convenience accessor: CartService.to
  static WishListService get to => Get.find<WishListService>();

  // ── Reactive state ───────────────────────────────────────
  var wishListItems = <Map<String, dynamic>>[].obs;
  var subTotal = 0.0.obs;
  var total = 0.0.obs;

  /// Number of distinct line-items in the cart
  int get wishListItemCount => wishListItems.length;

  // ── Fetch full cart ──────────────────────────────────────
  Future<void> fetchWishList() async {
    try {
      var response = await BasicProvider("wishlist/list")
          .getRequest()
          .catchError(handleError);

      if (response == null) {
        wishListItems.clear();
        return;
      }

      parseWishListResponse(response);
    } catch (e, stackTrack) {
      debugPrint('WishlistService.fetchWishList error: $e');
    }
  }

  // ── Add  ──────────────────────────
  Future<dynamic> addWishlist({
    required String productId,
    required String variantSlug,
    String? variantId,
  }) async {
    var form = {
      'product_id': productId,
      'variant_slug': variantSlug,
      if (variantId != null) 'variant_id': variantId,
    };
    var response = await BasicProvider("wishlist/add")
        .postRequest(form)
        .catchError(handleError);
    if (response != null && response is! String) {
      parseWishListResponse(response);
    }
    return response;
  }

  // ── Remove item ──────────────────────────────────────────
  Future<dynamic> removeFromWishlist({
    required String productId,
    required String variantSlug,
    String? variantId,
  }) async {
    var form = {
      'product_id': productId,
      'variant_slug': variantSlug,
      if (variantId != null) 'variant_id': variantId,
    };
    var response = await BasicProvider("wishlist/remove")
        .postRequest(form)
        .catchError(handleError);
    if (response != null && response is! String) {
      parseWishListResponse(response);
    }
    return response;
  }

  bool isInWishlist(String productId) {
    return wishListItems.any((item) {
      final product = item['product_id'];
      if (product is Map) {
        return (product['_id'] ?? product['id']).toString() ==
            productId.toString();
      }
      return product?.toString() == productId.toString();
    });
  }

  Future<void> toggleWishlist({
    required String productId,
    required String variantSlug,
    String? variantId,
  }) async {
    if (isInWishlist(productId)) {
      await removeFromWishlist(
          productId: productId, variantSlug: variantSlug, variantId: variantId);
    } else {
      await addWishlist(
          productId: productId, variantSlug: variantSlug, variantId: variantId);
    }
  }

  void parseWishListResponse(dynamic data) {
    if (data is List) {
      wishListItems.value =
          data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      wishListItems.clear();
    }
  }
}

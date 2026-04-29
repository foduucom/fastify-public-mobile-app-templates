import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';

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
    Map<String, dynamic>? productData,
  }) async {
    final bool currentlyInWishlist = isInWishlist(productId);

    // --- Optimistic Update: Update UI instantly ---
    if (currentlyInWishlist) {
      wishListItems.removeWhere((item) {
        final id = item['product_id'];
        if (id is Map) {
          return (id['_id'] ?? id['id']).toString() == productId.toString();
        }
        return id?.toString() == productId.toString();
      });
    } else {
      // Add a placeholder item to reflect in UI immediately
      wishListItems.add({
        'product_id': productData ?? productId,
        'variant_slug': variantSlug,
        if (variantId != null) 'variant_id': variantId,
      });
    }

    try {
      if (currentlyInWishlist) {
        await removeFromWishlist(
            productId: productId,
            variantSlug: variantSlug,
            variantId: variantId);
      } else {
        await addWishlist(
            productId: productId,
            variantSlug: variantSlug,
            variantId: variantId);
      }
    } catch (e) {
      // Revert if API fails by re-fetching the true state
      debugPrint('Wishlist toggle failed, reverting... $e');
      await fetchWishList();
    }
  }

  void parseWishListResponse(dynamic data) {
    List<dynamic>? items;
    if (data is List) {
      items = data;
    } else if (data is Map) {
      // API might return { "status": "success", "data": [...] }
      // Or { "status": "success", "data": "Product added..." }
      final d = data['data'];
      if (d is List) {
        items = d;
      } else {
        // If data is a String (success message), don't clear the list
        // as we've already updated it optimistically.
        return;
      }
    }

    if (items != null) {
      wishListItems.value =
          items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
  }
}

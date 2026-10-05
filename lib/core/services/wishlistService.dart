import 'package:foduu_ecommerce/constants/resilience_strings.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
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

  /// True when the last fetch failed (e.g. backend unreachable). The list is
  /// kept as-is so a failure never looks like an empty wishlist.
  final loadError = false.obs;

  /// Number of distinct line-items in the cart
  int get wishListItemCount => wishListItems.length;

  // ── Fetch full cart ──────────────────────────────────────
  Future<void> fetchWishList() async {
    try {
      var response = await BasicProvider("wishlist/list")
          .getRequest()
          .catchError(handleError);

      if (response == null) {
        loadError.value = true;
        return;
      }

      loadError.value = false;
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
    print("add wishlist form === $form");
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
    print("remove wishlist form === $form");
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
    final snapshot = List<Map<String, dynamic>>.from(wishListItems);
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
      final response = currentlyInWishlist
          ? await removeFromWishlist(
              productId: productId,
              variantSlug: variantSlug,
              variantId: variantId)
          : await addWishlist(
              productId: productId,
              variantSlug: variantSlug,
              variantId: variantId);
      if (response == null) _rollback(snapshot);
    } catch (e) {
      // Revert if API fails by re-fetching the true state
      debugPrint('Wishlist toggle failed, reverting... $e');
      _rollback(snapshot);
    }
  }

  /// The write failed (handleError turns failures into null): restore the
  /// pre-tap state and tell the user calmly.
  void _rollback(List<Map<String, dynamic>> snapshot) {
    wishListItems.value = snapshot;
    HelperFunctions().showSnackBarError(ResilienceStrings.writeFailed);
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
      wishListItems.value = items
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }
}

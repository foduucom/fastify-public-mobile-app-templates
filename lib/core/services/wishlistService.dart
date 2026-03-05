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

      print("In WishlistService fetchWishList response: $response");
      printInfo(info: response.toString());
      parseWishListResponse(response);
    } catch (e, stackTrack) {
      debugPrint('WishlistService.fetchWishList error: $e');
    }
  }

  // ── Add  ──────────────────────────
  // In WishListService class
  Future<Map<String, dynamic>?> addWishlist({
    required String productId,
    required String variantSlug,
  }) async {
    var form = {
      'product_id': productId,
      'variant_slug': variantSlug,
    };

    var response = await BasicProvider("wishlist/add")
        .postRequest(form)
        .catchError(handleError);

    // Handle both Map and String responses
    if (response != null) {
      if (response is Map<String, dynamic>) {
        parseWishListResponse(response);
        return response;
      } else if (response is String) {
        // If response is just a success message, fetch the updated wishlist
        printInfo(info: 'Wishlist add response: $response');
        await fetchWishList(); // Fetch updated wishlist
        return {'message': response};
      }
    }
    return null;
  }

// Similarly update removeFromWishlist
  Future<Map<String, dynamic>?> removeFromWishlist({
    required String productId,
    required String variantSlug,
  }) async {
    var form = {
      'product_id': productId,
      'variant_slug': variantSlug,
    };

    var response = await BasicProvider("wishlist/remove")
        .postRequest(form)
        .catchError(handleError);

    // Handle both Map and String responses
    if (response != null) {
      if (response is Map<String, dynamic>) {
        parseWishListResponse(response);
        return response;
      } else if (response is String) {
        // If response is just a success message, fetch the updated wishlist
        printInfo(info: 'Wishlist remove response: $response');
        await fetchWishList(); // Fetch updated wishlist
        return {'message': response};
      }
    }
    return null;
  }

  bool isInWishlist(String productId) {
    return wishListItems.any((item) {
      final product = item['product_id'];
      String? id;
      if (product is Map) {
        id = (product['_id'] ?? product['id'])?.toString();
      } else {
        id = (item['_id'] ?? item['id'])?.toString();
      }
      return id == productId.toString();
    });
  }

  Future<void> toggleWishlist({
    required String productId,
    required String variantSlug,
  }) async {
    try {
      if (isInWishlist(productId)) {
        await removeFromWishlist(
            productId: productId, variantSlug: variantSlug);
      } else {
        await addWishlist(productId: productId, variantSlug: variantSlug);
      }
      await fetchWishList();
    } catch (e) {
      printError(info: 'Error toggling wishlist: $e');
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

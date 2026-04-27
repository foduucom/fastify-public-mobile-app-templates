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
    if (response != null) {
      if (!isInWishlist(productId)) {
        wishListItems.add({
          'product_id': {'_id': productId, 'id': productId},
          'variant_slug': variantSlug,
          if (variantId != null) 'variant_id': variantId,
        });
      }
      fetchWishList();
    }
    return response;
  }

  Future<dynamic> removeFromWishlist({
    required String productId,
    required String variantSlug,
    String? variantId,
  }) async {
    // If variantId is null, try to find it in the local wishlist items
    if (variantId == null || variantId.isEmpty) {
      final item = wishListItems.firstWhereOrNull((element) {
        final p = element['product_id'];
        final pid = (p is Map) ? (p['_id'] ?? p['id']) : p;
        return pid.toString() == productId.toString();
      });
      if (item != null) {
        final v = item['variant_id'];
        variantId =
            (v is Map) ? (v['_id'] ?? v['id'])?.toString() : v?.toString();
      }
    }

    var form = {
      'product_id': productId,
      'variant_slug': variantSlug,
      if (variantId != null && variantId.isNotEmpty) 'variant_id': variantId,
    };
    var response = await BasicProvider("wishlist/remove")
        .postRequest(form)
        .catchError(handleError);
    if (response != null) {
      wishListItems.removeWhere((item) {
        final p = item['product_id'];
        final pid = (p is Map) ? (p['_id'] ?? p['id']) : p;
        if (pid.toString() != productId.toString()) return false;

        if (variantId != null && variantId.isNotEmpty) {
          final v = item['variant_id'];
          final vid = (v is Map) ? (v['_id'] ?? v['id']) : v;
          return vid.toString() == variantId.toString();
        }
        return true;
      });
      fetchWishList();
    }
    return response;
  }

  bool isInWishlist(String productId, {String? variantId}) {
    return wishListItems.any((item) {
      final p = item['product_id'];
      final pid = (p is Map) ? (p['_id'] ?? p['id']) : p;
      if (pid.toString() != productId.toString()) return false;

      if (variantId != null && variantId.isNotEmpty) {
        final v = item['variant_id'];
        final vid = (v is Map) ? (v['_id'] ?? v['id']) : v;
        return vid.toString() == variantId.toString();
      }
      return true;
    });
  }

  Future<void> toggleWishlist({
    required String productId,
    required String variantSlug,
    String? variantId,
  }) async {
    if (isInWishlist(productId, variantId: variantId)) {
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

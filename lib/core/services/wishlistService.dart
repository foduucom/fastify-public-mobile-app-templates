import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '/app/data/basic_provider.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/modules/auth/auth_details.dart';
import '/constants/helper_functions.dart';
import '/constants/resilience_strings.dart';

class WishListService extends GetxService with BaseController {
  /// Convenience accessor: CartService.to
  static WishListService get to => Get.find<WishListService>();

  // ── Reactive state ───────────────────────────────────────
  var wishListItems = <Map<String, dynamic>>[].obs;
  var subTotal = 0.0.obs;
  var total = 0.0.obs;
  final loadError = false.obs;

  /// Number of distinct line-items in the cart
  int get wishListItemCount => wishListItems.length;

  // ── Fetch full cart ──────────────────────────────────────
  Future<void> fetchWishList() async {
    loadError.value = false;
    if (!AuthDetails.isUserLogin()) {
      wishListItems.clear();
      return;
    }

    try {
      var response = await BasicProvider("wishlist/list")
          .getRequest()
          .catchError(handleError);

      if (response == null) {
        loadError.value = true;
        return;
      }

      loadError.value = !parseWishListResponse(response);
    } catch (e) {
      loadError.value = true;
      debugPrint('WishlistService.fetchWishList error: $e');
    }
  }

  // ── Add  ──────────────────────────
  Future<dynamic> addWishlist({
    required String productId,
    required String variantSlug,
    String? variantId,
    Map<String, dynamic>? productData,
  }) async {
    if (!AuthDetails.isUserLogin()) {
      HelperFunctions().showSnackBarError("You are not authorized");
      return null;
    }

    final snapshot = List<Map<String, dynamic>>.from(wishListItems);
    if (!_containsWishlistItem(productId, variantSlug, variantId)) {
      wishListItems.add({
        'product_id': productData ?? productId,
        'variant_slug': variantSlug,
        if (variantId != null) 'variant_id': variantId,
      });
    }

    var form = {
      'product_id': productId,
      'variant_slug': variantSlug,
      if (variantId != null) 'variant_id': variantId,
    };
    try {
      final response = await BasicProvider("wishlist/add")
          .postRequest(form)
          .catchError(handleError);
      if (response == null) {
        wishListItems.assignAll(snapshot);
        HelperFunctions().showSnackBarError(ResilienceStrings.writeFailed);
      } else {
        final updatedFromList = parseWishListResponse(response);
        if (!updatedFromList) {
          await fetchWishList();
        }
      }
      return response;
    } catch (e) {
      wishListItems.assignAll(snapshot);
      HelperFunctions().showSnackBarError(ResilienceStrings.writeFailed);
      debugPrint('Wishlist add failed: $e');
      return null;
    }
  }

  // ── Remove item ──────────────────────────────────────────
  Future<dynamic> removeFromWishlist({
    required String productId,
    required String variantSlug,
    String? variantId,
  }) async {
    if (!AuthDetails.isUserLogin()) {
      HelperFunctions().showSnackBarError("You are not authorized");
      return null;
    }

    final snapshot = List<Map<String, dynamic>>.from(wishListItems);
    wishListItems.removeWhere((item) =>
        _matchesWishlistItem(item, productId, variantSlug, variantId));

    var form = {
      'product_id': productId,
      'variant_slug': variantSlug,
      if (variantId != null) 'variant_id': variantId,
    };
    try {
      final response = await BasicProvider("wishlist/remove")
          .postRequest(form)
          .catchError(handleError);
      if (response == null) {
        wishListItems.assignAll(snapshot);
        HelperFunctions().showSnackBarError(ResilienceStrings.writeFailed);
      } else {
        final updatedFromList = parseWishListResponse(response);
        if (!updatedFromList) {
          await fetchWishList();
        }
      }
      return response;
    } catch (e) {
      wishListItems.assignAll(snapshot);
      HelperFunctions().showSnackBarError(ResilienceStrings.writeFailed);
      debugPrint('Wishlist remove failed: $e');
      return null;
    }
  }

  bool _containsWishlistItem(
          String productId, String variantSlug, String? variantId) =>
      wishListItems.any((item) =>
          _matchesWishlistItem(item, productId, variantSlug, variantId));

  bool _matchesWishlistItem(
    Map<String, dynamic> item,
    String productId,
    String variantSlug,
    String? variantId,
  ) {
    final product = item['product_id'];
    final itemProductId = product is Map
        ? (product['_id'] ?? product['id'] ?? '').toString()
        : product?.toString() ?? '';
    if (itemProductId != productId) return false;

    final itemVariant = item['variant_id'];
    final itemVariantId = itemVariant is Map
        ? (itemVariant['_id'] ?? itemVariant['id'] ?? '').toString()
        : itemVariant?.toString() ?? '';
    if (variantId != null && variantId.isNotEmpty && itemVariantId.isNotEmpty) {
      return itemVariantId == variantId;
    }
    final itemSlug = (item['variant_slug'] ??
            (itemVariant is Map ? itemVariant['slug'] : null) ??
            '')
        .toString();
    return variantSlug.isEmpty || itemSlug.isEmpty || itemSlug == variantSlug;
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
    if (!AuthDetails.isUserLogin()) {
      HelperFunctions().showSnackBarError("You are not authorized");
      return;
    }

    if (isInWishlist(productId)) {
      await removeFromWishlist(
          productId: productId, variantSlug: variantSlug, variantId: variantId);
    } else {
      await addWishlist(
          productId: productId,
          variantSlug: variantSlug,
          variantId: variantId,
          productData: productData);
    }
  }

  bool parseWishListResponse(dynamic data) {
    dynamic items = data;
    for (var depth = 0; depth < 3 && items is Map; depth++) {
      if (items['data'] is List) {
        items = items['data'];
      } else if (items['items'] is List) {
        items = items['items'];
      } else if (items['wishlist'] is List) {
        items = items['wishlist'];
      } else {
        return false;
      }
    }
    if (items is! List || items.any((item) => item is! Map)) return false;
    wishListItems.assignAll(
      items.map((item) => Map<String, dynamic>.from(item as Map)),
    );
    return true;
  }
}

import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum LoadFailure { none, offline, server }

class WishlistController extends GetxController with BaseController {
  final count = 0.obs;
  RxBool isLoading = false.obs;

  /// True when the last list fetch failed, so the UI doesn't show a failure as an empty wishlist.
  /// Why the last wishlist load failed; drives which error UI is shown.
  final loadFailure = LoadFailure.none.obs;
  bool get loadError => loadFailure.value != LoadFailure.none;
  var wishList = <dynamic>[].obs;
  RxList<String> wishlistProductIds = <String>[].obs;
  var box = GetStorage();

  bool isProductInWishlist(String productId, {String? variantId}) {
    if (productId.isEmpty) return false;
    if (wishlistProductIds.contains(productId)) return true;
    return wishList.any((item) {
      if (item is! Map) return false;
      var productObj = item['product'] ?? item['product_id'];
      var pid = productObj is Map
          ? (productObj['_id'] ?? productObj['id'])?.toString()
          : productObj?.toString();
      if (pid == productId) return true;
      var directPid = (item['product_id'] ?? item['product'])?.toString();
      return directPid == productId;
    });
  }

  void toggleLocalWishlist(String productId, String? variantId, bool isAdd, {Map? productDetails}) {
    if (isAdd) {
      if (isProductInWishlist(productId)) return;
      var productObj = productDetails ?? {'_id': productId};
      var item = {
        'product': productObj,
        'product_id': productId,
        'variant_id': variantId ?? '',
        'variant': variantId != null ? {'_id': variantId} : null,
      };
      wishList.add(item);
      if (!wishlistProductIds.contains(productId)) {
        wishlistProductIds.add(productId);
      }
    } else {
      wishList.removeWhere((item) {
        if (item is! Map) return false;
        var productObj = item['product'] ?? item['product_id'];
        var pid = productObj is Map
            ? (productObj['_id'] ?? productObj['id'])?.toString()
            : productObj?.toString();
        return pid == productId;
      });
      wishlistProductIds.remove(productId);
    }
    update();
  }

  Future<bool> toggleWishlist({
    required String productid,
    String? variant_id,
    String? variantSlug,
    Map? productDetails,
  }) async {
    if (!AuthDetails.isUserLogin()) {
      print('toggleWishlist blocked: User is not logged in.');
      return false;
    }

    final bool isCurrentlyIn = isProductInWishlist(productid);
    final bool willAdd = !isCurrentlyIn;

    // Resolve form payload before modifying local wishList so variant resolution works
    var form = await _buildForm(productid, variant_id, variantSlug);

    // Optimistic state update
    if (willAdd) {
      if (!wishlistProductIds.contains(productid)) {
        wishlistProductIds.add(productid);
      }
      var productObj = productDetails ?? {'_id': productid};
      var item = {
        'product': productObj,
        'product_id': productid,
        'variant_id': variant_id ?? '',
        'variant': variant_id != null ? {'_id': variant_id} : null,
      };
      if (!wishList.any((e) =>
          (e is Map &&
              ((e['product']?['_id'] ?? e['product_id'])?.toString() ==
                  productid)))) {
        wishList.add(item);
      }
    } else {
      wishlistProductIds.remove(productid);
      wishList.removeWhere((e) =>
          (e is Map &&
              ((e['product']?['_id'] ?? e['product_id'])?.toString() ==
                  productid)));
    }
    update();

    try {
      final endpoint = willAdd ? 'wishlist/add' : 'wishlist/remove';
      var response = await BasicProvider(endpoint)
          .postRequest(form)
          .catchError(handleError);

      if (response == null) {
        // Rollback on request failure
        if (willAdd) {
          wishlistProductIds.remove(productid);
          wishList.removeWhere((e) =>
              (e is Map &&
                  ((e['product']?['_id'] ?? e['product_id'])?.toString() ==
                      productid)));
        } else {
          if (!wishlistProductIds.contains(productid)) {
            wishlistProductIds.add(productid);
          }
        }
        update();
        return isCurrentlyIn;
      }

      await getwishlist();
      return willAdd;
    } catch (e) {
      print('toggleWishlist error: $e');
      if (willAdd) {
        wishlistProductIds.remove(productid);
        wishList.removeWhere((e) =>
            (e is Map &&
                ((e['product']?['_id'] ?? e['product_id'])?.toString() ==
                    productid)));
      } else {
        if (!wishlistProductIds.contains(productid)) {
          wishlistProductIds.add(productid);
        }
      }
      update();
      return isCurrentlyIn;
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    if (AuthDetails.isUserLogin()) {
      await getwishlist();
    }
  }

  Future<void> addProductToWishlist(
      {required String productid,
      String? variant_id,
      String? variantSlug}) async {
    try {
      if (!AuthDetails.isUserLogin()) {
        print('addProductToWishlist blocked: User is not logged in.');
        return;
      }
      if (!wishlistProductIds.contains(productid)) {
        wishlistProductIds.add(productid);
        update();
      }
      var form = await _buildForm(productid, variant_id, variantSlug);
      var response = await BasicProvider('wishlist/add')
          .postRequest(form)
          .catchError(handleError);
      if (response == null) {
        wishlistProductIds.remove(productid);
        update();
        return;
      }
      await getwishlist();
    } catch (e) {
      print('wishlist error $e');
    }
  }

  Future<void> removeProductFromWishlist(
      {required String productid,
      String? variant_id,
      String? variantSlug}) async {
    try {
      if (!AuthDetails.isUserLogin()) {
        print('removeProductFromWishlist blocked: User is not logged in.');
        return;
      }
      var form = await _buildForm(productid, variant_id, variantSlug);
      var response = await BasicProvider('wishlist/remove')
          .postRequest(form)
          .catchError(handleError);
      if (response == null) {
        // Write failed: restore the id removed optimistically by the caller.
        if (!wishlistProductIds.contains(productid)) {
          wishlistProductIds.add(productid);
        }
        update();
        return;
      }
      await getwishlist();
    } catch (e) {
      print('wishlist remove error $e');
    }
  }

  /// Backend expects `variant_slug` (and `variant_id` only when known).
  Future<Map<String, dynamic>> _buildForm(
      String productId, String? variantId, String? variantSlug) async {
    String vId = _getEffectiveVariantId(productId, variantId);
    String slug = (variantSlug ?? '').trim();
    if (slug.isEmpty) slug = _resolveVariantSlug(productId, vId);
    if (slug.isEmpty) slug = await _fetchVariantSlug(productId, vId);
    return {
      'product_id': productId,
      'variant_slug': slug,
      if (vId.isNotEmpty) 'variant_id': vId,
    };
  }

  /// Fetch the product and pick the matching variant's slug (falls back to first variant, then product slug).
  Future<String> _fetchVariantSlug(String productId, String variantId) async {
    try {
      var res = await BasicProvider('products/$productId').getRequest();
      if (res is Map && res['product'] is Map) res = res['product'];
      if (res is! Map) return '';
      var variants = (res['variants'] ?? res['variant_ids']) as List?;
      Map? match;
      if (variants != null) {
        for (var v in variants) {
          if (v is Map && (v['_id'] ?? v['id'])?.toString() == variantId) {
            match = v;
            break;
          }
        }
        // Only fall back to the first variant when no specific variant was
        // requested; otherwise a wrong slug would be sent for the wrong variant.
        if (match == null &&
            variantId.isEmpty &&
            variants.isNotEmpty &&
            variants.first is Map) {
          match = variants.first;
        }
      }
      return (match?['slug'] ??
              match?['variant_slug'] ??
              res['variant_slug'] ??
              res['slug'] ??
              '')
          .toString();
    } catch (e) {
      print('wishlist slug fetch error $e');
      return '';
    }
  }

  /// Find a slug from the wishlist copy of the product (variant first, then product).
  String _resolveVariantSlug(String productId, String variantId) {
    var item = wishList.firstWhereOrNull((i) {
      if (i is! Map) return false;
      var p = i['product'];
      return p is Map && p['_id']?.toString() == productId;
    });
    if (item == null) return '';
    var variant = getVariantForItem(item);
    String? slug;
    if (variant is Map) {
      slug = (variant['slug'] ?? variant['variant_slug'])?.toString();
    }
    slug ??= (item['variant_slug'] ?? item['product']?['slug'])?.toString();
    return slug ?? '';
  }

  String _getEffectiveVariantId(String productId, String? variantId) {
    String actualVariantId = variantId ?? '';
    if (actualVariantId == 'null') actualVariantId = '';

    // If variantId matches productId or is empty, try to find the correct variant ID from wishlist items
    if (actualVariantId.isEmpty || actualVariantId == productId) {
      var itemWithDetails = wishList.firstWhereOrNull((item) {
        if (item is! Map) return false;
        var productObj = item['product'] ?? item['product_id'];
        var pid = productObj is Map
            ? productObj['_id']?.toString()
            : productObj?.toString();
        return pid == productId;
      });

      if (itemWithDetails != null) {
        var variant = getVariantForItem(itemWithDetails);
        if (variant != null &&
            variant is Map &&
            variant['_id'] != null &&
            variant['_id'] != productId) {
          actualVariantId = variant['_id'].toString();
          print(
              'DEBUG Wishlist: Resolved variant ID to $actualVariantId from item details');
        }
      }
    }

    // Fallback: if they are identical, backend rejects it, so clear it
    if (actualVariantId == productId) {
      print(
          'DEBUG Wishlist: variantId matches productId, clearing it to empty string');
      actualVariantId = '';
    }

    return actualVariantId;
  }

  /// Get the appropriate variant for a wishlist item (similar to cart items)
  dynamic getVariantForItem(dynamic item) {
    if (item == null || item is! Map) return null;

    // 1. If variant is already a populated object in the item, return it
    var directVariant = item['variant'] ?? item['variant_id'];
    if (directVariant != null &&
        directVariant is Map &&
        (directVariant['_id'] != null || directVariant['id'] != null)) {
      return directVariant;
    }

    // 2. Otherwise, try to find it in the product's variant list
    if (item['product'] == null || item['product'] is! Map) {
      return null;
    }

    var productObj = item['product'];
    // Try to find variants in either 'variant_ids' or 'variants'
    var variants =
        (productObj['variant_ids'] ?? productObj['variants']) as List?;

    // 3. For simple products, try to get the first variant if available
    if (productObj['type'] == 'simple') {
      if (variants != null && variants.isNotEmpty) {
        if (variants[0] is Map) {
          return variants[0];
        } else if (variants[0] is String) {
          return {'_id': variants[0]};
        }
      }
      return null;
    }

    if (variants == null || variants.isEmpty) {
      return null;
    }

    // If directVariant is just an ID, find it in variants list
    if (directVariant != null) {
      String directVidStr = directVariant.toString();
      for (var v in variants) {
        if (v is Map) {
          var vid = (v['_id'] ?? v['id'])?.toString();
          if (vid == directVidStr) {
            return v;
          }
        } else if (v is String && v == directVidStr) {
          return {'_id': v};
        }
      }
    }

    // Fallback to first variant
    if (variants.first is Map) {
      return variants.first;
    } else if (variants.first is String) {
      return {'_id': variants.first};
    }
    return null;
  }

  Future<void> getwishlist() async {
    isLoading.value = true;
    try {
      final provider = BasicProvider('wishlist/list');
      var response = await provider.getRequest().catchError(handleError);

      if (response == null) {
        switch (provider.lastFailure) {
          case RequestFailure.offline:
            loadFailure.value = LoadFailure.offline;
            break;
          case RequestFailure.guestSkipped:
            // Signed out: nothing to show, and nothing went wrong.
            loadFailure.value = LoadFailure.none;
            break;
          default:
            // Auth failures already triggered the session teardown/redirect;
            // anything else is a server-side problem, not connectivity.
            loadFailure.value = LoadFailure.server;
        }
        isLoading.value = false;
        return;
      }
      loadFailure.value = LoadFailure.none;

      dynamic data;
      if (response is List) {
        data = response;
      } else if (response is Map) {
        data = response['data'] ?? response;
        if (data is Map && data.containsKey('data')) {
          data = data['data'];
        }
      }

      if (data is List) {
        wishList.clear();
        wishlistProductIds.clear();
        final Map<String, Map<String, dynamic>> uniqueProducts = {};

        for (var element in data) {
          if (element is Map) {
            var productObj = element['product'] ?? element['product_id'];
            if (productObj != null && productObj is Map) {
              final pId = (productObj['_id'] ?? productObj['id'])?.toString() ?? '';
              if (pId.isEmpty) continue;

              Map<String, dynamic> normalizedItem =
                  Map<String, dynamic>.from(element);
              normalizedItem['product'] = productObj;

              if (!uniqueProducts.containsKey(pId)) {
                uniqueProducts[pId] = normalizedItem;
              } else {
                // If existing stored item has no variant info but duplicate has variant info, upgrade to richer one
                var existingVar = uniqueProducts[pId]!['variant'] ?? uniqueProducts[pId]!['variant_id'];
                var newVar = element['variant'] ?? element['variant_id'];
                bool existingHasVar = existingVar != null && existingVar != '' && (existingVar is! Map || existingVar.isNotEmpty);
                bool newHasVar = newVar != null && newVar != '' && (newVar is! Map || newVar.isNotEmpty);
                if (!existingHasVar && newHasVar) {
                  uniqueProducts[pId] = normalizedItem;
                }
              }
            }
          }
        }

        for (var entry in uniqueProducts.entries) {
          wishList.add(entry.value);
          wishlistProductIds.add(entry.key);
        }
        print('Wishlist updated: ${wishList.length} items');
      }
      update();
    } catch (e) {
      print('Error getting wishlist: $e');
      loadFailure.value = LoadFailure.server;
    } finally {
      isLoading.value = false;
    }
  }
  // Future<void> fetchWishlist() async {
  //   isLoading.value = true;
  //   var response = await BasicProvider('public/product/get-wishlist')
  //       .getRequest()
  //       .catchError(handleError);
  //   print(response);
  //   if (response == null) {
  //     isLoading.value = false;
  //     return;
  //   }

  //   if (response is List) {
  //     wishList.addAll(response);
  //     print(wishList);
  //   } else if (response is Map<String, dynamic>) {
  //     response.forEach((key, value) {
  //       wishList.add(value);
  //     });
  //   }
  //   isLoading.value = false;
  // }
}

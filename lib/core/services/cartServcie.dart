import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

class CartService extends GetxService with BaseController {
  /// Convenience accessor: CartService.to
  static CartService get to => Get.find<CartService>();

  static const String _localCartKey = 'local_cart';
  final _box = GetStorage();

  // ── Reactive state ───────────────────────────────────────
  var cartItems = <Map<String, dynamic>>[].obs;
  var subTotal = 0.0.obs;
  var total = 0.0.obs;

  /// True when the last fetch failed (e.g. backend unreachable). Items are
  /// kept as-is so a failure never looks like an empty cart.
  final loadError = false.obs;

  /// Number of distinct line-items in the cart
  int get cartItemCount => cartItems.length;

  bool get _isGuest => !AuthDetails.isUserLogin();

  // ══════════════════════════════════════════════════════════
  //  FETCH CART
  // ══════════════════════════════════════════════════════════
  Future<void> fetchCart() async {
    if (_isGuest) {
      _loadLocalCart();
      return;
    }

    try {
      var response =
          await BasicProvider("cart").getRequest().catchError(handleError);

      if (response == null) {
        // Keep what we have: a failed fetch must not look like an empty cart.
        loadError.value = true;
        return;
      }

      loadError.value = false;
      parseCartResponse(response);
    } catch (e) {
      debugPrint('CartService.fetchCart error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  //  ADD / INCREMENT / DECREMENT
  // ══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> manageCart({
    required String productId,
    required String variantId,
    required int quantity,
    Map<String, dynamic>? product,
  }) async {
    if (_isGuest) {
      _manageLocalCart(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
        product: product,
      );
      return null;
    }

    var form = {
      'product_id': productId,
      'variant_id': variantId,
      'quantity': quantity,
    };
    var response = await BasicProvider("cart/manage")
        .postRequest(form)
        .catchError(handleError);
    if (response != null) {
      // Apply the manage response immediately so quantity updates are instant.
      parseCartResponse(response);

      // cart/manage returns featured_image as a bare ObjectId string (not the
      // full image object), so we follow up with a fetchCart() call to get the
      // complete product data — including the correct image URL — without
      // requiring the user to pull-to-refresh manually.
      await fetchCart();
    }
    return response;
  }

  // ══════════════════════════════════════════════════════════
  //  REMOVE ITEM
  // ══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> removeFromCart({
    required String productId,
    required String variantSlug,
  }) async {
    if (_isGuest) {
      _removeLocalCartItem(productId: productId, variantSlug: variantSlug);
      return {'local': true};
    }

    var form = {
      'product_id': productId,
      'variant_id': variantSlug,
    };
    var response = await BasicProvider("cart/remove")
        .postRequest(form)
        .catchError(handleError);
    if (response != null) {
      parseCartResponse(response);
    }
    return response;
  }

  // ══════════════════════════════════════════════════════════
  //  SYNC LOCAL CART → SERVER  (called after login)
  // ══════════════════════════════════════════════════════════
  Future<void> syncLocalCartToServer() async {
    final localItems = _readLocalCart();
    if (localItems.isEmpty) return;

    try {
      // Build the list in the format the API expects
      final List<Map<String, dynamic>> items = localItems.map((item) {
        final product = item['product_id'];
        final pid = product is Map
            ? (product['_id'] ?? product['id'] ?? '')
            : product.toString();
        return {
          'product_id': pid,
          'variant_id': item['variant_id'] ?? '',
          'quantity': item['quantity'] ?? 1,
        };
      }).toList();

      var response = await BasicProvider("cart/manage")
          .postRequest({'items': items}).catchError(handleError);

      if (response != null) {
        parseCartResponse(response);
      }

      // Clear local cart regardless of response
      _clearLocalCart();
    } catch (e) {
      debugPrint('CartService.syncLocalCartToServer error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  //  PARSE API RESPONSE
  // ══════════════════════════════════════════════════════════
  void parseCartResponse(dynamic data) {
    if (data == null || data is! Map) return;

    final rawItems = data['items'] ?? data['data'] ?? data['cart'];
    final items = rawItems is List ? rawItems : [];

    // Build a lookup of existing image objects keyed by product ID so we can
    // restore them when cart/manage returns featured_image as a bare string ID.
    final Map<String, dynamic> existingImages = {};
    for (final item in cartItems) {
      final p = item['product_id'];
      if (p is Map) {
        final pid = (p['_id'] ?? p['id'] ?? '').toString();
        final img = p['featured_image'];
        if (pid.isNotEmpty && img is Map) {
          existingImages[pid] = img;
        }
      }
    }

    cartItems.value = items.whereType<Map>().map((e) {
      final item = Map<String, dynamic>.from(e);
      final p = item['product_id'];
      if (p is Map) {
        final product = Map<String, dynamic>.from(p);
        final img = product['featured_image'];
        // API returned a bare ID string — restore the full image object if we
        // have it from the previous fetch so the URL builds correctly.
        if (img is String && img.isNotEmpty) {
          final restored = existingImages[img] ??
              existingImages[product['_id'] ?? product['id'] ?? ''];
          if (restored != null) {
            product['featured_image'] = restored;
          }
        }
        item['product_id'] = product;
      }
      return item;
    }).toList();

    subTotal.value = HelperFunctions.parseAmount(data['sub_total']);
    total.value = HelperFunctions.parseAmount(data['total']);
  }

  // ══════════════════════════════════════════════════════════
  //  LOCAL CART — private helpers
  // ══════════════════════════════════════════════════════════

  /// Read raw list from GetStorage
  List<Map<String, dynamic>> _readLocalCart() {
    final raw = _box.read<List>(_localCartKey);
    if (raw == null) return [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Load local cart into reactive state
  void _loadLocalCart() {
    cartItems.value = _readLocalCart();
    _recalculateLocalTotals();
  }

  /// Persist current cartItems to GetStorage
  void _saveLocalCart() {
    _box.write(_localCartKey, cartItems.toList());
  }

  /// Clear local cart from storage and reactive state
  void _clearLocalCart() {
    _box.remove(_localCartKey);
  }

  /// Recalculate subtotal / total from local items
  void _recalculateLocalTotals() {
    double sub = 0;
    double tot = 0;

    for (var item in cartItems) {
      final qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;

      // 1. Resolve variant
      Map<String, dynamic>? variant;
      if (item['variant'] is Map && (item['variant'] as Map).isNotEmpty) {
        variant = Map<String, dynamic>.from(item['variant']);
      } else if (item['variant_id'] is Map &&
          (item['variant_id'] as Map).isNotEmpty) {
        variant = Map<String, dynamic>.from(item['variant_id']);
      }

      // If variant was not resolved directly, look in product_id
      final product = item['product_id'] ?? item['product'];
      if (variant == null && product is Map) {
        final variants = product['variants'] as List? ?? [];
        final targetVid = item['variant_id']?.toString() ?? '';
        for (var v in variants) {
          if (v is Map && v['_id']?.toString() == targetVid) {
            variant = Map<String, dynamic>.from(v);
            break;
          }
        }
        if (variant == null && variants.isNotEmpty && variants.first is Map) {
          variant = Map<String, dynamic>.from(variants.first);
        }
      }

      // 2. Resolve prices safely
      double regularPrice = 0.0;
      double salePrice = 0.0;

      if (variant != null) {
        regularPrice = HelperFunctions.parseAmount(variant['price']);
        salePrice = HelperFunctions.parseAmount(variant['sale_price']);
      }

      // Fallback to product level price if variant price is 0
      if (regularPrice <= 0 && product is Map) {
        regularPrice = HelperFunctions.parseAmount(product['price']);
        if (salePrice <= 0) {
          salePrice = HelperFunctions.parseAmount(product['sale_price']);
        }
      }

      // If regular price is 0 but sale price is > 0, set regularPrice to salePrice
      if (regularPrice <= 0 && salePrice > 0) {
        regularPrice = salePrice;
      }

      final effectivePrice =
          (salePrice > 0 && salePrice <= regularPrice) ? salePrice : regularPrice;

      sub += regularPrice * qty;
      tot += effectivePrice * qty;
    }

    subTotal.value = sub;
    total.value = tot;
  }

  /// Add / increment / decrement in local cart
  void _manageLocalCart({
    required String productId,
    required String variantId,
    required int quantity,
    Map<String, dynamic>? product,
  }) {
    final existingIndex = cartItems.indexWhere((item) {
      final p = item['product_id'];
      final pid = p is Map ? (p['_id'] ?? p['id'] ?? '') : p.toString();
      return pid == productId && item['variant_id'] == variantId;
    });

    if (existingIndex != -1) {
      // Update existing item quantity
      final current = Map<String, dynamic>.from(cartItems[existingIndex]);
      final currentQty =
          int.tryParse(current['quantity']?.toString() ?? '1') ?? 1;
      final newQty = currentQty + quantity;

      if (newQty <= 0) {
        // Remove item if quantity drops to 0 or below
        cartItems.removeAt(existingIndex);
      } else {
        current['quantity'] = newQty;
        cartItems[existingIndex] = current;
      }
    } else if (quantity > 0 && product != null) {
      // Add new item — find the matching variant from the product
      Map<String, dynamic> variantData = {};
      final variants = product['variants'] as List? ?? [];
      for (var v in variants) {
        if (v['_id'] == variantId) {
          variantData = Map<String, dynamic>.from(v);
          break;
        }
      }

      cartItems.add({
        'product_id': Map<String, dynamic>.from(product),
        'variant_id': variantId,
        'variant': variantData,
        'quantity': quantity,
      });
    }

    _recalculateLocalTotals();
    _saveLocalCart();
    cartItems.refresh();
  }

  /// Remove an item from local cart
  void _removeLocalCartItem({
    required String productId,
    required String variantSlug,
  }) {
    cartItems.removeWhere((item) {
      final p = item['product_id'];
      final pid = p is Map ? (p['_id'] ?? p['id'] ?? '') : p.toString();
      return pid == productId && item['variant_id'] == variantSlug;
    });

    _recalculateLocalTotals();
    _saveLocalCart();
    cartItems.refresh();
  }
}

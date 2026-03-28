import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '/app/data/basic_provider.dart';
import '/app/modules/auth/auth_details.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/constants/helper_functions.dart';

class CartService extends GetxService with BaseController {
  /// Convenience accessor: CartService.to
  static CartService get to => Get.find<CartService>();

  static const String _localCartKey = 'local_cart';
  final _box = GetStorage();

  // ── Reactive state ───────────────────────────────────────
  var cartItems = <Map<String, dynamic>>[].obs;
  var subTotal = 0.0.obs;
  var total = 0.0.obs;

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
        cartItems.clear();
        subTotal.value = 0;
        total.value = 0;
        return;
      }

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
      parseCartResponse(response);
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
  void parseCartResponse(Map<String, dynamic> data) {
    final items = data['items'] as List? ?? [];
    cartItems.value = items.map((e) => Map<String, dynamic>.from(e)).toList();
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
      final qty = (item['quantity'] ?? 1) as int;
      final variant = item['variant'];
      if (variant is Map) {
        final salePrice = variant['sale_price'];
        final price = variant['price'];
        final regularPrice = HelperFunctions.parseAmount(price);

        // total uses sale_price if available, otherwise regular price
        final parsedSalePrice = HelperFunctions.parseAmount(salePrice);
        final effectivePrice = (salePrice != null && parsedSalePrice > 0)
            ? parsedSalePrice
            : regularPrice;

        sub += regularPrice * qty;
        tot += effectivePrice * qty;
      }
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
      final newQty = ((current['quantity'] ?? 1) as int) + quantity;

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

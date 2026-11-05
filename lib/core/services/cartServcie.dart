import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '/app/data/basic_provider.dart';
import '/app/modules/auth/auth_details.dart';
import '/app/controllers/api_exception_handle_controller.dart';

class CartService extends GetxService with BaseController {
  /// Convenience accessor: CartService.to
  static CartService get to => Get.find<CartService>();

  static const String _localCartKey = 'local_cart';
  final _box = GetStorage();

  // ── Reactive state ───────────────────────────────────────
  var cartItems = <Map<String, dynamic>>[].obs;
  var subTotal = 0.0.obs;
  var total = 0.0.obs;
  final loadError = false.obs;

  /// Number of distinct line-items in the cart
  int get cartItemCount => cartItems.length;

  bool get _isGuest => !AuthDetails.isUserLogin();

  // ══════════════════════════════════════════════════════════
  //  FETCH CART
  // ══════════════════════════════════════════════════════════
  Future<void> fetchCart() async {
    loadError.value = false;
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
      loadError.value = true;
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
    // Some API responses wrap the cart in `data`, while others return it at
    // the top level. Accept both formats before reading the line items/totals.
    final payload = data['data'] is Map
        ? Map<String, dynamic>.from(data['data'] as Map)
        : data;
    final rawItems = payload['items'] ?? payload['cart_items'];
    cartItems.value = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
        : <Map<String, dynamic>>[];

    final calculated = _calculateTotals(cartItems);
    final apiSubtotal = _parsePrice(
      payload['sub_total'] ?? payload['subtotal'] ?? payload['subTotal'],
    );
    final apiTotal = _parsePrice(payload['total'] ?? payload['grand_total']);

    // A zero/missing total is common in incomplete cart responses. Derive it
    // from the same variant prices used to render each cart line instead.
    subTotal.value = apiSubtotal > 0 ? apiSubtotal : calculated.$1;
    total.value = apiTotal > 0 ? apiTotal : calculated.$2;
  }

  double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    if (value == null) return 0;
    // Handles formatted API values such as "₹1,200.00" as well as numbers
    // serialized as strings.
    final normalized = value
        .toString()
        .replaceAll(',', '')
        .replaceAll('₹', '')
        .trim();
    return double.tryParse(normalized) ?? 0;
  }

  (double, double) _calculateTotals(Iterable<Map<String, dynamic>> items) {
    var subtotal = 0.0;
    var total = 0.0;

    for (final item in items) {
      final quantity = _parsePrice(item['quantity']);
      final qty = quantity > 0 ? quantity : 1;
      final variantValue = item['variant'] ?? item['variant_id'];
      final variant =
          variantValue is Map ? variantValue : const <String, dynamic>{};
      final regularPrice = _parsePrice(
        variant['price'] ??
            item['regular_price'] ??
            item['unit_price'] ??
            item['price'],
      );
      final salePrice = _parsePrice(
        variant['sale_price'] ?? item['sale_price'] ?? item['unit_price'],
      );
      final effectivePrice = salePrice > 0 ? salePrice : regularPrice;

      subtotal += (regularPrice > 0 ? regularPrice : effectivePrice) * qty;
      total += effectivePrice * qty;
    }
    return (subtotal, total);
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
    final (subtotal, calculatedTotal) = _calculateTotals(cartItems);
    subTotal.value = subtotal;
    total.value = calculatedTotal;
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

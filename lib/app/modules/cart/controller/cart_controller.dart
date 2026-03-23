import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/constants/constants.dart';

class CartController extends GetxController with BaseController {

  final RxBool   isLoading      = false.obs;
  final RxString updatingItemId = ''.obs;

  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
  final RxDouble subTotal = 0.0.obs;
  final RxDouble total    = 0.0.obs;

  static String get _imgBase => assetURL;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  // ── Fetch Cart ────────────────────────────────────────────────
  Future<void> fetchCart() async {
    isLoading(true);
    try {
      final response = await BasicProvider('cart').getRequest();
      if (response != null) _parseCart(response);
    } catch (e) {
      debugPrint('CartController fetch error: $e');
    } finally {
      isLoading(false);
    }
  }

  // ── Parse Cart ─────────────────────────────────────────────────
  void _parseCart(dynamic response) {
    if (response is! Map) return;
    final data = Map<String, dynamic>.from(response);

    subTotal.value = double.tryParse(data['sub_total']?.toString() ?? '0') ?? 0.0;
    total.value    = double.tryParse(data['total']?.toString()     ?? '0') ?? 0.0;

    final rawItems = data['items'];
    if (rawItems is List) {
      final newItems = rawItems
          .map<Map<String, dynamic>>((i) => Map<String, dynamic>.from(i as Map))
          .toList();
      _smartUpdateList(newItems);
    }
    debugPrint('🛒 Cart: ${cartItems.length} items | subtotal:${subTotal.value} total:${total.value}');
  }

  // ── Smart diff — no full list replacement ─────────────────────
  void _smartUpdateList(List<Map<String, dynamic>> newItems) {
    // Remove items no longer in server response
    cartItems.removeWhere((existing) {
      final id = itemId(existing);
      return !newItems.any((n) => itemId(n) == id);
    });

    // Update changed items / append new ones
    for (final newItem in newItems) {
      final newId = itemId(newItem);
      final idx   = cartItems.indexWhere((e) => itemId(e) == newId);
      if (idx >= 0) {
        if (cartItems[idx]['quantity'] != newItem['quantity']) {
          cartItems[idx] = newItem;
        }
      } else {
        cartItems.add(newItem);
      }
    }
  }

  // ── URL Fixer ──────────────────────────────────────────────────
  String _fixUrl(String url) {
    if (url.isEmpty) return url;
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    if (uri.path.startsWith('/images/')) {
      return '$_imgBase${uri.path.substring(8)}';
    }
    return url;
  }

  // ── Helpers ────────────────────────────────────────────────────
  String itemName(Map item) {
    final product = item['product_id'];
    if (product is Map) return product['name']?.toString() ?? 'Product';
    return 'Product';
  }

  double itemPrice(Map item) {
    final variant = item['variant_id'];
    if (variant is Map) {
      final sp = double.tryParse(variant['sale_price']?.toString() ?? '') ?? 0.0;
      final p  = double.tryParse(variant['price']?.toString()      ?? '') ?? 0.0;
      if (sp > 0) return sp;
      if (p  > 0) return p;
    }
    // fallback to unit_price from cart item
    return double.tryParse(item['unit_price']?.toString() ?? '0') ?? 0.0;
  }

  String itemImage(Map item) {
    final product = item['product_id'];
    if (product is Map) {
      final fi = product['featured_image'];
      if (fi is Map) {
        final du = fi['download_url']?.toString() ?? '';
        if (du.isNotEmpty) return _fixUrl(du);
        final fp = fi['filepath']?.toString() ?? '';
        if (fp.isNotEmpty) return '$_imgBase$fp';
      }
    }
    final variant = item['variant_id'];
    if (variant is Map) {
      final gallery = variant['gallery'];
      if (gallery is List && gallery.isNotEmpty && gallery[0] is Map) {
        final g  = gallery[0] as Map;
        final du = g['download_url']?.toString() ?? '';
        if (du.isNotEmpty) return _fixUrl(du);
        final fp = g['filepath']?.toString() ?? '';
        if (fp.isNotEmpty) return '$_imgBase$fp';
      }
    }
    return '';
  }

  int itemQuantity(Map item) =>
      int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;

  String _productId(Map item) {
    final p = item['product_id'];
    if (p is Map) return p['_id']?.toString() ?? '';
    return p?.toString() ?? '';
  }

  String _variantId(Map item) {
    final v = item['variant_id'];
    if (v is Map) return v['_id']?.toString() ?? '';
    return v?.toString() ?? '';
  }

  String itemId(Map item) =>
      item['_id']?.toString() ?? '${_productId(item)}_${_variantId(item)}';

  // ── Update Quantity ────────────────────────────────────────────
  Future<void> updateQuantity(Map<String, dynamic> item, int newQty) async {
    if (newQty <= 0) { removeItem(item); return; }

    final id  = itemId(item);
    final idx = cartItems.indexWhere((e) => itemId(e) == id);

    // Optimistic update
    if (idx >= 0) {
      final updated = Map<String, dynamic>.from(cartItems[idx]);
      updated['quantity'] = newQty;
      cartItems[idx] = updated;
    }

    updatingItemId.value = id;
    try {
      final response = await BasicProvider('cart/manage').postRequest({
        'items': [
          {
            'product_id': _productId(item),
            'variant_id': _variantId(item),
            'quantity':   newQty,
          }
        ],
      });
      if (response != null) {
        await fetchCart(); // silent sync — smart diff won't flicker
      } else {
        await fetchCart(); // revert
      }
    } catch (e) {
      debugPrint('Update quantity error: $e');
      await fetchCart(); // revert
    } finally {
      updatingItemId.value = '';
    }
  }

  // ── Remove Item ────────────────────────────────────────────────
  Future<void> removeItem(Map<String, dynamic> item) async {
    final id   = itemId(item);
    final name = itemName(item);

    updatingItemId.value = id;
    cartItems.removeWhere((e) => itemId(e) == id); // optimistic remove

    try {
      final response = await BasicProvider('cart/remove').postRequest({
        'product_id': _productId(item),
        'variant_id': _variantId(item),
      });
      if (response != null) {
        await fetchCart(); // sync totals
        Get.snackbar(
          'Removed', '$name removed from cart',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF1A1A1A),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
        );
      } else {
        await fetchCart(); // revert
      }
    } catch (e) {
      debugPrint('Remove item error: $e');
      await fetchCart(); // revert
    } finally {
      updatingItemId.value = '';
    }
  }

  void onCheckout() => Get.toNamed('/checkout');
}

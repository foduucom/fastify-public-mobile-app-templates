import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '/app/data/basic_provider.dart';
import '/app/controllers/api_exception_handle_controller.dart';

class CartService extends GetxService with BaseController {
  /// Convenience accessor: CartService.to
  static CartService get to => Get.find<CartService>();

  // ── Reactive state ───────────────────────────────────────
  var cartItems = <Map<String, dynamic>>[].obs;
  var subTotal = 0.0.obs;
  var total = 0.0.obs;

  /// Number of distinct line-items in the cart
  int get cartItemCount => cartItems.length;

  // ── Fetch full cart ──────────────────────────────────────
  Future<void> fetchCart() async {
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

  // ── Add / increment / decrement ──────────────────────────
  Future<Map<String, dynamic>?> manageCart({
    required String productId,
    required String variantSlug,
    required int quantity,
  }) async {
    var form = {
      'product_id': productId,
      'variant_slug': variantSlug,
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

  // ── Remove item ──────────────────────────────────────────
  Future<Map<String, dynamic>?> removeFromCart({
    required String productId,
    required String variantSlug,
  }) async {
    var form = {
      'product_id': productId,
      'variant_slug': variantSlug,
    };
    var response = await BasicProvider("cart/remove")
        .postRequest(form)
        .catchError(handleError);
    if (response != null) {
      parseCartResponse(response);
    }
    return response;
  }

  // ── Parse API response & update state ────────────────────
  void parseCartResponse(Map<String, dynamic> data) {
    final items = data['items'] as List? ?? [];
    cartItems.value = items.map((e) => Map<String, dynamic>.from(e)).toList();
    subTotal.value = (data['sub_total'] ?? 0).toDouble();
    total.value = (data['total'] ?? 0).toDouble();
  }
}

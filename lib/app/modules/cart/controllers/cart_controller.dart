import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import '/constants/constants.dart';
import '/core/foduuStudio/foduu_studio_layout_mixin.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/core/services/cartServcie.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';

class CartController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  final _cartService = CartService.to;
  var couponDetails = {}.obs;
  var couponeMessage = ''.obs;
  late TextEditingController couponController;
  var allCoupon = [].obs;
  var isCouponApply = false.obs;
  var isClicked = false.obs;
  late AnimationController couponeMessageAnimationController;

  RxList<Map<String, dynamic>> get cartItems => _cartService.cartItems;
  RxDouble get subTotal => _cartService.subTotal;
  RxDouble get total => _cartService.total;

  var isLoading = false.obs;
  var isUpdating = false.obs; // true while increment/decrement/remove in-flight

  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchLayout('cart');
    fetchCart();
    couponController = TextEditingController();
  }

  @override
  void onReady() {
    super.onReady();
    // Re-fetch on ready to ensure we have the latest state when the view is active
    fetchCart();
  }

  @override
  void onClose() {
    if (kIsWeb) {
      disableSocketUpdates(websiteDomain, 'cart');
    }
    super.onClose();
  }

  Future<void> fetchCart() async {
    try {
      isLoading.value = true;
      await _cartService.fetchCart();
    } catch (e) {
      debugPrint('CartController.fetchCart error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<dynamic> applyCoupon({required String coupon}) async {
    HelperFunctions().showOverlayLoader();
    try {
      var form = {'coupon': coupon};

      Map<String, dynamic>? response = await BasicProvider(
        "cart/apply/coupon",
      ).postRequest(form).catchError(handleError);

      if (response == null || response.isEmpty) {
        return;
      }

      couponDetails.clear();
      couponDetails.addAll(response);

      return response;
    } catch (e) {
      debugPrint('CartController.applyCoupon error: $e');
    } finally {
      HelperFunctions().hideOverlayLoader();
    }
  }

  Future<void> incrementItem(String productId, String variantId) async {
    try {
      isUpdating.value = true;
      await _cartService.manageCart(
        productId: productId,
        variantId: variantId,
        quantity: 1,
      );
    } catch (e) {
      debugPrint('CartController.incrementItem error: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> decrementItem(
    String productId,
    String variantId,
    int currentQty,
  ) async {
    if (currentQty <= 1) {
      _showRemoveConfirmation(productId, variantId);
      return;
    }

    try {
      isUpdating.value = true;
      await _cartService.manageCart(
        productId: productId,
        variantId: variantId,
        quantity: -1,
      );
    } catch (e) {
      debugPrint('CartController.decrementItem error: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> removeItem(String productId, String variantSlug) async {
    HelperFunctions().showOverlayLoader();
    try {
      isUpdating.value = true;

      var response = await _cartService.removeFromCart(
        productId: productId,
        variantSlug: variantSlug,
      );

      // For API cart, null means we need to re-fetch
      // For local cart, response is non-null (handled internally)
      if (response == null) {
        await _cartService.fetchCart();
      }
    } catch (e) {
      debugPrint('CartController.removeItem error: $e');
    } finally {
      isUpdating.value = false;
      HelperFunctions().hideOverlayLoader();
    }
  }

  Future<void> onRefresh() async {
    await fetchCart();
  }

  void _showRemoveConfirmation(String productId, String variantSlug) {
    Get.defaultDialog(
      title: 'Remove Item',
      middleText: 'Are you sure you want to remove this item from the cart?',
      textConfirm: 'Remove',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        removeItem(productId, variantSlug);
      },
    );
  }

  Map<String, dynamic> getProduct(int index) {
    if (index >= cartItems.length) return {};
    final item = cartItems[index];

    Map<String, dynamic> productMap = {};

    // Priority 1: Check for 'product' key (common when populated)
    final productObj = item['product'];
    if (productObj is Map) {
      productMap = Map<String, dynamic>.from(productObj);
    } else {
      // Priority 2: Check 'product_id' key
      final productData = item['product_id'];
      if (productData is Map) {
        productMap = Map<String, dynamic>.from(productData);
      } else if (productData is String) {
        // Fallback: If it's a String, return a Map with just the ID
        return {'_id': productData};
      }
    }

    if (productMap.isEmpty) return {};

    // --- NORMALIZATION FOR PRODUCT HELPER ---
    // Ensure 'featured_image' exists as expected by ProductHelper
    if (productMap['featured_image'] == null) {
      final img = productMap['image'] ?? productMap['thumbnail'];
      if (img != null) {
        productMap['featured_image'] = img;
      }
    }

    // If featured_image is a Map but lacks 'filepath', try to map 'download_url'
    final featImg = productMap['featured_image'];
    if (featImg is Map &&
        featImg['filepath'] == null &&
        featImg['filePath'] == null) {
      if (featImg['download_url'] != null) {
        // HelperFunctions expects 'filepath' to append to base URL,
        // but if we have a full download_url, we might need a different hack.
        // However, user said HelperFunctions works perfectly fine, so maybe
        // they just need the right keys.
        featImg['filepath'] = featImg['download_url'];
      }
    }

    return productMap;
  }

  Map<String, dynamic> getVariant(int index) {
    if (index >= cartItems.length) return {};
    final item = cartItems[index];

    // Priority 1: Check for 'variant' key
    final variantObj = item['variant'];
    if (variantObj is Map) {
      return Map<String, dynamic>.from(variantObj);
    }

    // Priority 2: Check 'variant_id' key
    final variantData = item['variant_id'];
    if (variantData is Map) {
      return Map<String, dynamic>.from(variantData);
    }

    // Fallback: If it's a String, return a Map with just the ID
    if (variantData is String) {
      return {'_id': variantData};
    }

    return {};
  }

  int getQuantity(int index) {
    final qty = cartItems[index]['quantity'];
    if (qty is int) return qty;
    if (qty is String) return int.tryParse(qty) ?? 1;
    return 1;
  }

  String getVariantId(int index) {
    final variant = cartItems[index]['variant_id'];

    if (variant is String) {
      return variant;
    } else if (variant is Map) {
      return (variant['_id'] ?? variant['id'] ?? '').toString();
    }

    return '';
  }

  String getProductId(int index) {
    final product = cartItems[index]['product_id'];
    if (product is Map) {
      return (product['_id'] ?? product['id'] ?? '').toString();
    }
    return product?.toString() ?? '';
  }

  double get savings => subTotal.value - total.value;
}

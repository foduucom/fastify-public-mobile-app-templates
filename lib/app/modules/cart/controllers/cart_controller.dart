import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/constants/constants.dart';
import '/core/foduuStudio/foduu_studio_layout_mixin.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/core/services/cartServcie.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';

class CartController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  final _cartService = CartService.to;

  RxList<Map<String, dynamic>> get cartItems => _cartService.cartItems;
  RxDouble get subTotal => _cartService.subTotal;
  RxDouble get total => _cartService.total;

  var isLoading = false.obs;
  var isUpdating = false.obs; // true while increment/decrement/remove in-flight
  var appliedCoupon    = ''.obs;
  var couponDiscount   = 0.0.obs;
  var availableCoupons = <Map<String, dynamic>>[].obs;
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchLayout('cart');
    fetchCart();
  }
  void clearCoupon() {
    appliedCoupon.value  = '';
    couponDiscount.value = 0.0;
  }
  void applyCouponFromSheet({
    required String code,
    required String title,
    required double discount,
  }) {
    appliedCoupon.value  = title;
    // discount is a percentage — apply to subTotal
    couponDiscount.value = subTotal.value * discount / 100;
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
      String productId, String variantId, int currentQty) async {
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
    try {
      isUpdating.value = true;
      HelperFunctions().showOverlayLoader();

      var response = await _cartService.removeFromCart(
        productId: productId,
        variantSlug: variantSlug,
      );

      // For API cart, null means we need to re-fetch
      // For local cart, response is non-null (handled internally)
      if (response == null) {
        await _cartService.fetchCart();
      }

      if (Get.isDialogOpen ?? false) {
        Get.until((route) => !Get.isDialogOpen!);
      }
    } catch (e) {
      debugPrint('CartController.removeItem error: $e');
    } finally {
      isUpdating.value = false;
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
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      onConfirm: () {
        Get.back();
        removeItem(productId, variantSlug);
      },
    );
  }

  Map<String, dynamic> getProduct(int index) {
    final product = cartItems[index]['product_id'];
    if (product is Map) {
      return Map<String, dynamic>.from(product);
    }
    // If it's a String (ID), return a Map with just the ID
    if (product is String) {
      return {'_id': product};
    }
    return {};
  }

  Map<String, dynamic> getVariant(int index) {
    final variant =
        cartItems[index]['variant'] ?? cartItems[index]['variant_id'];

    if (variant is Map) {
      return Map<String, dynamic>.from(variant);
    }
    // If it's a String (ID), return a Map with just the ID
    if (variant is String) {
      return {'_id': variant};
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

  TextEditingController? get promoController => null;

  void applyPromo() {}
}

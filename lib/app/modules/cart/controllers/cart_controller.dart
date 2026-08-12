import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_mixin.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:get/get.dart';

class CartController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  final _cartService = CartService.to;

  RxList<Map<String, dynamic>> get cartItems => _cartService.cartItems;
  RxDouble get subTotal => subTotalAmount;
  RxDouble get total => totalAmount;

  var isLoading = false.obs;
  var isUpdating = false.obs; // true while increment/decrement/remove in-flight

  ScrollController scrollController = ScrollController();

  // Price breakdown variables matching Amerex project
  var bagPriceAmount = 0.0.obs;
  var discountAmount = 0.0.obs;
  var subTotalAmount = 0.0.obs;
  var totalAmount = 0.0.obs;
  var tax = 0.0.obs;
  var taxPercentage = 0.0.obs;
  var taxBreakdownList = <Map<String, dynamic>>[].obs;

  // Coupon related
  var couponDetails = <String, dynamic>{}.obs;
  var couponDiscountAmount = '0.00'.obs;
  var isCouponApply = false.obs;
  late TextEditingController couponController;

  // UI bindings
  var viewCouponPrefix = ''.obs;
  var viewPrice = ''.obs;
  var viewCouponCode = 'Apply Coupon'.obs;
  var viewCouponAmount = 'Apply Coupon'.obs;
  var viewSavedPrice = ''.obs;
  var viewSubTotalAmount = ''.obs;
  var viewTotalAmount = ''.obs;

  final GlobalKey targetKey = GlobalKey();
  FocusNode targetFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    couponController = TextEditingController();
    fetchLayout('cart');
    fetchCart().then((_) => calculateCartTotals());

    // Register worker to calculate totals dynamically when cartItems changes
    ever(cartItems, (_) => calculateCartTotals());
  }

  @override
  void onClose() {
    couponController.dispose();
    targetFocusNode.dispose();
    if (kIsWeb) {
      disableSocketUpdates(websiteDomain, 'cart');
    }
    super.onClose();
  }

  dynamic getVariantForItem(dynamic item) {
    if (item == null || item is! Map) return null;

    var directVariant = item['variant'] ?? item['variant_id'];
    if (directVariant != null &&
        directVariant is Map &&
        (directVariant['_id'] != null || directVariant['id'] != null)) {
      return directVariant;
    }

    if (item['product_id'] == null || item['product_id'] is! Map) {
      return null;
    }

    var productObj = item['product_id'];
    var variants =
        (productObj['variant_ids'] ?? productObj['variants']) as List?;

    if (productObj['type'] == 'simple') {
      if (variants != null && variants.isNotEmpty) {
        return variants[0];
      }
      return productObj;
    }

    if (variants == null || variants.isEmpty) {
      return null;
    }

    if (directVariant != null) {
      String directVidStr = directVariant.toString();
      for (var v in variants) {
        if (v is Map) {
          var vid = (v['_id'] ?? v['id'])?.toString();
          if (vid == directVidStr) {
            return v;
          }
        }
      }
    }

    return variants[0];
  }

  void calculateCartTotals() {
    bagPriceAmount.value = 0.0;
    discountAmount.value = 0.0;
    subTotalAmount.value = 0.0;
    totalAmount.value = 0.0;
    tax.value = 0.0;
    taxPercentage.value = 0.0;
    taxBreakdownList.clear();

    double totalTaxableAmount = 0.0;
    List<Map<String, dynamic>> tempTaxBreakdown = [];

    for (var item in cartItems) {
      if (item['product_id'] != null && item['quantity'] != null) {
        var product = item['product_id'];
        var quantity = int.tryParse(item['quantity'].toString()) ?? 1;

        var variant = getVariantForItem(item);
        if (variant != null && variant is Map) {
          var price =
              double.tryParse(variant['price']?.toString() ?? '0') ?? 0.0;
          var salePrice =
              double.tryParse(variant['sale_price']?.toString() ?? '0') ?? 0.0;

          var effectivePrice = (salePrice > 0) ? salePrice : price;
          var itemTotal = effectivePrice * quantity;

          bagPriceAmount.value += price * quantity;
          totalAmount.value += itemTotal;

          bool isTaxable =
              product['isTaxable'] == true || product['isTaxable'] == 'true';
          double taxPercent =
              double.tryParse(product['tax']?.toString() ?? '0') ?? 0.0;
          if (isTaxable && taxPercent > 0) {
            double itemTax = (effectivePrice * taxPercent) / 100;
            double totalItemTax = itemTax * quantity;
            tax.value += totalItemTax;
            totalTaxableAmount += itemTotal;

            String? variantName;
            if (variant['name'] != null && variant['name'] != product['name']) {
              variantName = variant['name'].toString();
            }

            tempTaxBreakdown.add({
              'name': product['name'] ?? 'Product',
              'variant_name': variantName,
              'tax_percent': taxPercent,
              'tax_amount': totalItemTax,
              'percentage': taxPercent,
              'taxableAmount': itemTotal,
              'taxAmount': totalItemTax,
            });
          }
        }
      }
    }

    subTotalAmount.value = totalAmount.value;
    taxBreakdownList.assignAll(tempTaxBreakdown);

    if (totalTaxableAmount > 0) {
      taxPercentage.value = (tax.value / totalTaxableAmount) * 100;
    }

    discountAmount.value = bagPriceAmount.value - totalAmount.value;

    // Apply coupon discount if valid coupon is applied
    if (couponDetails.isNotEmpty && couponDetails.containsKey('code')) {
      var couponData = couponDetails;

      var couponDiscount =
          double.tryParse(couponData['discount_amount']?.toString() ?? '0') ??
              0.0;

      couponDiscountAmount.value = couponDiscount.toString();

      // Adjust tax if the API returned a new tax calculation
      if (couponData.containsKey('new_tax_amount') &&
          couponData['new_tax_amount'] != null) {
        tax.value = double.tryParse(couponData['new_tax_amount'].toString()) ??
            tax.value;
      }

      // Update tax breakdown if provided by API
      if (couponData.containsKey('item_tax_breakdown') &&
          couponData['item_tax_breakdown'] is List) {
        taxBreakdownList.clear();
        for (var item in couponData['item_tax_breakdown']) {
          double percent =
              double.tryParse(item['tax_percent']?.toString() ?? '0') ?? 0.0;
          double amount =
              double.tryParse(item['tax_amount']?.toString() ?? '0') ?? 0.0;

          // Find the variant name from cart items if possible
          String? variantName;
          var matchingCartItem = cartItems.firstWhereOrNull((cartItem) {
            var prod = cartItem['product_id'];
            var prodName = (prod is Map) ? prod['name']?.toString() : null;
            return prodName == item['name'];
          });
          if (matchingCartItem != null) {
            var variant = getVariantForItem(matchingCartItem);
            var product = matchingCartItem['product_id'];
            if (variant != null && variant is Map && product is Map) {
              if (variant['name'] != null &&
                  variant['name'] != product['name']) {
                variantName = variant['name'].toString();
              }
            }
          }

          taxBreakdownList.add({
            'name': item['name'] ?? 'Product',
            'variant_name': variantName,
            'tax_percent': percent,
            'tax_amount': amount,
            'percentage': percent,
            'taxAmount': amount,
            'taxableAmount': percent > 0 ? (amount * 100 / percent) : 0.0,
          });
        }
      }

      totalAmount.value =
          (totalAmount.value - couponDiscount).clamp(0.0, double.infinity);
    }

    totalAmount.value += tax.value;

    updateOrderDetails();
  }

  void updateOrderDetails() {
    viewPrice.value = bagPriceAmount.value.toStringAsFixed(2);
    viewSubTotalAmount.value = subTotalAmount.value.toStringAsFixed(2);
    viewTotalAmount.value = totalAmount.value.toStringAsFixed(2);
    viewSavedPrice.value = discountAmount.value.toStringAsFixed(2);

    if (couponDetails.isNotEmpty && couponDetails.containsKey('code')) {
      var couponData = couponDetails;
      viewCouponCode.value = couponData['code'] ?? couponController.text;
      isCouponApply.value = true;

      if (couponController.text.toUpperCase() !=
          viewCouponCode.value.toUpperCase()) {
        couponController.text = viewCouponCode.value;
      }

      var couponDiscount =
          double.tryParse(couponData['discount_amount']?.toString() ?? '0') ??
              0.0;
      var discountType = couponData['discount_type'];
      var discountValue = couponData['discount_value'];

      if (discountType == 'PERCENTAGE') {
        viewCouponPrefix.value = '$discountValue%';
      } else {
        viewCouponPrefix.value = '';
      }

      viewCouponAmount.value = '-₹${couponDiscount.toStringAsFixed(2)}';
    } else {
      viewCouponCode.value = 'Apply Coupon';
      viewCouponAmount.value = 'Apply Coupon';
      viewCouponPrefix.value = '';
    }
  }

  Future<dynamic> applyCoupon({required String coupon}) async {
    try {
      HelperFunctions().showOverlayLoader();

      var form = {
        'coupon_code': coupon.trim(),
      };

      var response = await BasicProvider("cart/apply-coupon")
          .postRequest(form)
          .catchError(handleError);

      if (response != null && response.isNotEmpty) {
        couponDetails.clear();
        couponDetails.addAll(response);
        calculateCartTotals();
      }

      Get.until((route) => !Get.isDialogOpen!);
      return response;
    } catch (e) {
      debugPrint('Error applying coupon: $e');
      Get.until((route) => !Get.isDialogOpen!);
      return null;
    }
  }

  void clearCoupon() {
    couponDetails.clear();
    isCouponApply.value = false;
    couponDiscountAmount.value = '0.00';
    couponController.clear();
    calculateCartTotals();
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
      clearCoupon();
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
      clearCoupon();
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
      clearCoupon();
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
      confirmTextColor: Colors.white,
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

  double get savings => discountAmount.value;
}

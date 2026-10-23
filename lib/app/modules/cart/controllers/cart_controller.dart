import 'dart:convert';
import 'package:zouhi/app/modules/auth/token_manager.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/modules/shop/views/productdetail_view.dart';
import 'package:zouhi/constants/app_exceptions.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:zouhi/components/cart_auth_bottom_sheet.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';

class CartController extends GetxController
    with BaseController, SingleGetTickerProviderMixin {
  var box = GetStorage();

  // Main cart data - using the actual API structure
  var cartItems = <dynamic>[].obs;
  var guestUserCartList = <dynamic>[].obs;
  var isRefresh = false.obs;
  var isClicked = false.obs;

  // Cache for product details to avoid redundant API calls
  final Map<String, dynamic> _productCache = {};

  // Coupon related
  var couponDetails = <String, dynamic>{}.obs;
  var couponDiscountAmount = ''.obs;
  var isCouponApply = false.obs;
  late TextEditingController couponController;
  late AnimationController couponeMessageAnimationController;

  // Cart totals
  var bagPriceAmount = 0.0.obs;
  var discountAmount = 0.0.obs;
  var subTotalAmount = 0.0.obs;
  var totalAmount = 0.0.obs;
  var tax = 0.0.obs;
  var taxPercentage = 0.0.obs;
  var taxBreakdownList = <Map<String, dynamic>>[].obs;

  // Similar products
  var similarProduct = <dynamic>[].obs;
  var categoriesID = <String>[].obs;

  // UI bindings
  var viewCouponPrefix = ''.obs;
  var viewPrice = ''.obs;
  var viewCouponCode = ''.obs;
  var viewCouponAmount = ''.obs;
  var viewSavedPrice = ''.obs;
  var viewSubTotalAmount = ''.obs;
  var viewTotalAmount = ''.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey targetKey = GlobalKey();
  ScrollController scrollController = ScrollController();
  FocusNode targetFocusNode = FocusNode();

  // Guest cart weight calculation
  var guestUserCartWeight = 0.0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    couponeMessageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    couponController = TextEditingController();

    if (AuthDetails.isUserLogin()) {
      await getCartProduct();
    } else {
      await loadGuestCart();
    }

    if (Get.isRegistered<CurrencyController>()) {
      ever(Get.find<CurrencyController>().selectedCurrency, (_) {
        updateOrderDetails();
      });
    }

    calculateCartTotals();
    getSimilarProducts();
  }

  @override
  void onClose() {
    // couponeMessageAnimationController.dispose();
    // couponController.dispose();
    // scrollController.dispose();
    // targetFocusNode.dispose();
    super.onClose();
  }

  /// Get cart products for logged-in users with optional retry logic
  Future<void> getCartProduct({String? coupon, int retryCount = 0}) async {
    const int maxRetries = 3;
    try {
      dynamic response;
      try {
        response = await BasicProvider("cart").getRequest(
            queryParams: coupon != null ? {'coupon': coupon} : null);
      } on UnAuthorizedException {
        // Session teardown + user messaging is owned by SessionService; the
        // cart just shows nothing.
        cartItems.clear();
        resetCartTotals();
        return;
      } catch (err) {
        response = null;
      }

      // Check if response is malformed or missing expected fields
      bool isMalformed = response == null ||
          (response is Map &&
              !response.containsKey('items') &&
              !response.containsKey('data'));

      // Check if data is "raw" (contains only IDs, not populated objects)
      // This is the race condition the USER reported.
      bool isRaw = false;
      if (!isMalformed && response is Map) {
        var items = response['items'] ??
            (response['data'] is Map ? response['data']['items'] : null);
        if (items is List && items.isNotEmpty) {
          var firstItem = items.first;
          if (firstItem is Map) {
            // If product_id is a String, the backend hasn't populated it yet
            if (firstItem['product_id'] is String &&
                firstItem['product'] == null) {
              isRaw = true;
            }
          }
        }
      }

      if ((isMalformed || isRaw) && retryCount < maxRetries) {
        int delayMs = (retryCount + 1) * 1000; // 1s, 2s, 3s backoff
        await Future.delayed(Duration(milliseconds: delayMs));
        return await getCartProduct(coupon: coupon, retryCount: retryCount + 1);
      }

      await _handleCartResponse(response);
    } catch (e, stack) {
      if (retryCount == 0) {
        cartItems.clear();
        resetCartTotals();
      }
    }
  }

  /// Helper to handle and normalize cart data from various endpoints
  Future<void> _handleCartResponse(dynamic response) async {
    dynamic data = response;

    // Handle potential double-wrapping {status: success, data: {data: {items: []}}}
    if (data != null &&
        data is Map &&
        data.containsKey('status') &&
        data.containsKey('data')) {
      data = data['data'];
    }

    // Some APIs might have another level of 'data'
    if (data != null &&
        data is Map &&
        !data.containsKey('items') &&
        data.containsKey('data')) {
      data = data['data'];
    }

    if (data != null && data is Map && data.containsKey('items')) {
      var rawItems = data['items'];

      if (rawItems is List) {
        // Identify which products need details populated
        List<String> pIdsToFetch = [];
        for (var item in rawItems) {
          if (item is Map) {
            var pId = item['product_id'];
            if (pId is String && item['product'] == null) {
              if (!_productCache.containsKey(pId)) {
                pIdsToFetch.add(pId);
              }
            }
          }
        }

        // Fetch missing product details in parallel
        if (pIdsToFetch.isNotEmpty) {
          await Future.wait(pIdsToFetch.map((id) async {
            var details = await getProductDetails(id);
            if (details != null) {
              _productCache[id] = details;
            }
          }));
        }

        List<dynamic> normalizedItems = [];
        for (int i = 0; i < rawItems.length; i++) {
          var item = rawItems[i];
          if (item is Map) {
            Map<String, dynamic> normalized = Map<String, dynamic>.from(item);

            // Populate product details from cache if missing
            if (normalized['product'] == null &&
                normalized['product_id'] is String) {
              normalized['product'] = _productCache[normalized['product_id']];
            }

            // IMPORTANT: If this is a response from a 'remove' call, it might ONLY have IDs.
            // We should try to preserve existing product details if the product_id matches.
            var existingItem = cartItems.firstWhereOrNull(
                (element) => element['_id'] == normalized['_id']);

            // Map product_id to product if it's a populated object
            if (normalized['product_id'] != null) {
              if (normalized['product'] == null) {
                if (normalized['product_id'] is Map) {
                  normalized['product'] = normalized['product_id'];
                } else if (existingItem != null &&
                    existingItem['product'] != null) {
                  // Reuse existing product details if the IDs match
                  normalized['product'] = existingItem['product'];
                }
              }
            }

            // Map variant_id to variant if it's a populated object
            if (normalized['variant_id'] != null) {
              if (normalized['variant'] == null) {
                if (normalized['variant_id'] is Map) {
                  normalized['variant'] = normalized['variant_id'];
                } else if (existingItem != null &&
                    existingItem['variant'] != null) {
                  normalized['variant'] = existingItem['variant'];
                }
              }
            }

            // Ensure quantity is an int
            if (normalized['quantity'] != null) {
              normalized['quantity'] =
                  int.tryParse(normalized['quantity'].toString()) ?? 1;
            }

            normalizedItems.add(normalized);
          } else {
            normalizedItems.add(item);
          }
        }

        cartItems.assignAll(normalizedItems);

        // Extract category IDs safely
        categoriesID.clear();
        for (var item in cartItems) {
          if (item is Map &&
              item['product'] != null &&
              item['product'] is Map &&
              item['product']['categories'] != null &&
              item['product']['categories'] is List) {
            List categories = item['product']['categories'];
            for (var category in categories) {
              if (category is Map && category['_id'] != null) {
                if (!categoriesID.contains(category['_id'])) {
                  categoriesID.add(category['_id']);
                }
              }
            }
          }
        }

        calculateCartTotals();
        getSimilarProducts();
      } else {
        cartItems.clear();
        resetCartTotals();
      }
    } else {
      cartItems.clear();
      resetCartTotals();
    }
  }

  /// Load guest user cart from local storage
  Future<void> loadGuestCart() async {
    try {
      var storedCart = box.read('guestUserCartList');
      if (storedCart != null && storedCart is List) {
        guestUserCartList.value = List.from(storedCart);

        // For guest users, we need to fetch product details for each item
        cartItems.clear();
        for (var guestItem in guestUserCartList) {
          if (guestItem['_id'] != null) {
            var productDetails = await getProductDetails(guestItem['_id']);
            if (productDetails != null) {
              // Create a cart item structure similar to logged-in users
              var cartItem = {
                'product': productDetails,
                'quantity': guestItem['quantity'] ?? 1,
                'variant_name': guestItem['variant_name'],
                'producttype': guestItem['producttype'],
              };
              cartItems.add(cartItem);
            }
          }
        }

        calculateCartTotals();
        calculateGuestCartWeight();
      }
    } catch (e) {
      print('Error loading guest cart: $e');
    }
  }

  /// Get product details (used to populate cart items)
  Future<dynamic> getProductDetails(String productId) async {
    try {
      // Try the authenticated endpoint first (same as ProductDetailController)
      var response = await BasicProvider("products/$productId")
          .getRequest()
          .catchError((err) => null);

      // Fallback to public endpoint if needed
      if (response == null) {
        response = await BasicProvider("public/product/show/$productId")
            .getRequest()
            .catchError((err) => null);
      }

      if (response != null) {
        // Extract categories for similar products
        if (response['categories'] != null) {
          List categories = response['categories'];
          for (var category in categories) {
            if (category['_id'] != null &&
                !categoriesID.contains(category['_id'])) {
              categoriesID.add(category['_id']);
            }
          }
        }
        return response;
      }
    } catch (e) {
      print('Error fetching product details: $e');
    }
    return null;
  }

  /// Calculate cart totals correctly based on API structure
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
      if (item['product'] != null && item['quantity'] != null) {
        var product = item['product'];
        var quantity = int.tryParse(item['quantity'].toString()) ?? 1;

        // Get the correct variant
        var variant = getVariantForItem(item);
        if (variant != null && variant is Map) {
          var price =
              double.tryParse(variant['price']?.toString() ?? '0') ?? 0.0;
          var salePrice =
              double.tryParse(variant['sale_price']?.toString() ?? '0') ?? 0.0;

          // Use sale price if available and greater than 0, otherwise use regular price
          var effectivePrice = (salePrice > 0) ? salePrice : price;
          var itemTotal = effectivePrice * quantity;

          bagPriceAmount.value += price * quantity; // Original price total
          totalAmount.value += itemTotal; // Effective price total

          // Calculate tax based on the product's taxability flags
          bool isTaxable =
              product['isTaxable'] == true || product['isTaxable'] == 'true';
          double taxPercent =
              double.tryParse(product['tax']?.toString() ?? '0') ?? 0.0;
          if (isTaxable && taxPercent > 0) {
            double itemTax = (effectivePrice * taxPercent) / 100;
            double totalItemTax = itemTax * quantity;
            tax.value += totalItemTax;
            totalTaxableAmount += itemTotal;

            tempTaxBreakdown.add({
              'name': product['name'] ?? 'Product',
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

    // Calculate discount
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
          taxBreakdownList.add({
            'name': item['name'] ?? 'Product',
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

    // Add the accumulated tax to the total cart amount
    totalAmount.value += tax.value;

    updateOrderDetails();
  }

  /// Get the appropriate variant for a cart item
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
    // because the backend often expects the specific variant ID even for simple products.
    if (productObj['type'] == 'simple') {
      if (variants != null && variants.isNotEmpty) {
        return variants[0];
      }
      return productObj;
    }

    if (variants == null || variants.isEmpty) {
      return null;
    }

    if (AuthDetails.isUserLogin()) {
      // If directVariant is just an ID, find it in variants list
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
    } else {
      // For guest users, match by variant name
      if (item['variant_name'] != null) {
        String variantNameStr = item['variant_name'].toString().toLowerCase();
        for (var variant in variants) {
          if (variant is Map) {
            var vName = (variant['variant'] ?? variant['name'])
                ?.toString()
                .toLowerCase();
            if (vName == variantNameStr) {
              return variant;
            }
          }
        }
      }
    }

    // Fallback to first variant
    return variants[0];
  }

  /// Calculate weight for guest cart (for shipping)
  void calculateGuestCartWeight() {
    guestUserCartWeight.value = 0.0;

    for (int index = 0; index < cartItems.length; index++) {
      var item = cartItems[index];
      var variant = getVariantForItem(item);
      var quantity = item['quantity'] ?? 1;

      if (variant != null) {
        var weight =
            double.tryParse(variant['weight']?.toString() ?? '0') ?? 0.0;
        var weightUnit = variant['weight_unit'];

        if (weight > 0) {
          if (weightUnit == 'gm') {
            guestUserCartWeight.value +=
                (weight * quantity) / 1000; // Convert to kg
          } else if (weightUnit == 'kg') {
            guestUserCartWeight.value += weight * quantity;
          } else {
            guestUserCartWeight.value += 0.5 * quantity; // Default weight
          }
        } else {
          guestUserCartWeight.value +=
              0.5 * quantity; // Default weight if not specified
        }
      }
    }
  }

  /// Reset cart totals
  void resetCartTotals() {
    bagPriceAmount.value = 0.0;
    discountAmount.value = 0.0;
    subTotalAmount.value = 0.0;
    totalAmount.value = 0.0;
    tax.value = 0.0;
    taxPercentage.value = 0.0;
    taxBreakdownList.clear();
    updateOrderDetails();
  }

  /// Update order details for UI display
  // void updateOrderDetails() {
  //   viewPrice.value = bagPriceAmount.value.toStringAsFixed(2);
  //   viewTotalAmount.value = totalAmount.value.toStringAsFixed(2);
  //   viewSavedPrice.value = discountAmount.value.toStringAsFixed(2);

  //   // Coupon display logic
  //   if (couponDetails.containsKey('discount_amount') && isCouponApply.value) {
  //     viewCouponCode.value = couponController.text;
  //     viewCouponAmount.value = '-₹${couponDetails['discount_amount']}';
  //     viewCouponPrefix.value = couponDetails['coupon_type'] == 'percentage'
  //         ? '(${couponDetails['discount_value']}%)'
  //         : '';
  //   } else {
  //     viewCouponCode.value = 'Apply Coupon';
  //     viewCouponAmount.value = 'Apply Coupon';
  //     viewCouponPrefix.value = '';
  //   }
  // }
  // void updateOrderDetails() {
  //   viewPrice.value = bagPriceAmount.value.toStringAsFixed(2);
  //   viewTotalAmount.value = totalAmount.value.toStringAsFixed(2);
  //   viewSavedPrice.value = discountAmount.value.toStringAsFixed(2);

  //   // Coupon display logic based on new response structure
  //   if (couponDetails.containsKey('isValid') &&
  //       couponDetails['isValid'] == true &&
  //       couponDetails.containsKey('coupon') &&
  //       isCouponApply.value) {
  //     var couponData = couponDetails['coupon'];
  //     viewCouponCode.value = couponData['code'] ?? couponController.text;

  //     // Calculate discount amount for display
  //     var couponDiscount = 0.0;
  //     if (couponData['type'] == 'fixAmount') {
  //       couponDiscount = (couponData['type_value'] ?? 0).toDouble();
  //       viewCouponPrefix.value = '';
  //     } else if (couponData['type'] == 'percentage') {
  //       var originalTotal = totalAmount.value +
  //           (couponData['type'] == 'percentage'
  //               ? (bagPriceAmount.value * (couponData['type_value'] ?? 0) / 100)
  //               : (couponData['type_value'] ?? 0).toDouble());
  //       couponDiscount = originalTotal * (couponData['type_value'] ?? 0) / 100;
  //       viewCouponPrefix.value = '(${couponData['type_value']}%)';
  //     }

  //     viewCouponAmount.value = '-₹${couponDiscount.toStringAsFixed(2)}';
  //     print('🤒🤒🤒🤒 ${viewCouponAmount}');
  //   } else {
  //     viewCouponCode.value = 'Apply Coupon';
  //     viewCouponAmount.value = 'Apply Coupon';
  //     viewCouponPrefix.value = '';
  //   }
  // }
  void updateOrderDetails() {
    double rate = 1.0;
    if (Get.isRegistered<CurrencyController>()) {
      final currencyCtrl = Get.find<CurrencyController>();
      if (currencyCtrl.selectedCurrency.isNotEmpty &&
          currencyCtrl.selectedCurrency['exchange_rate'] != null) {
        rate = double.tryParse(
                currencyCtrl.selectedCurrency['exchange_rate'].toString()) ??
            1.0;
      }
    }

    viewPrice.value = (bagPriceAmount.value * rate).toStringAsFixed(2);
    viewSubTotalAmount.value = (subTotalAmount.value * rate).toStringAsFixed(2);
    viewTotalAmount.value = (totalAmount.value * rate).toStringAsFixed(2);
    viewSavedPrice.value = (discountAmount.value * rate).toStringAsFixed(2);

    // Coupon display logic based on new response structure
    if (couponDetails.isNotEmpty && couponDetails.containsKey('code')) {
      var couponData = couponDetails;
      viewCouponCode.value = couponData['code'] ?? couponController.text;
      isCouponApply.value = true;

      if (couponController.text.toUpperCase() !=
          viewCouponCode.value.toUpperCase()) {
        couponController.text = viewCouponCode.value;
      }

      // Get discount amount directly from the API response
      var couponDiscount =
          double.tryParse(couponData['discount_amount']?.toString() ?? '0') ??
              0.0;
      var discountType = couponData['discount_type'];
      var discountValue = couponData['discount_value'];

      if (discountType?.toString().toUpperCase() == 'PERCENTAGE') {
        viewCouponPrefix.value = '$discountValue%';
      } else {
        viewCouponPrefix.value = '';
      }

      String symbol = currency;
      if (Get.isRegistered<CurrencyController>()) {
        symbol = Get.find<CurrencyController>()
                .selectedCurrency['symbol']
                ?.toString() ??
            currency;
      }

      // Convert couponDiscount to selected currency
      double convertedCouponDiscount = couponDiscount * rate;
      couponDiscountAmount.value = convertedCouponDiscount.toStringAsFixed(2);
      viewCouponAmount.value =
          '-$symbol${convertedCouponDiscount.toStringAsFixed(2)}';
    } else {
      viewCouponCode.value = 'Apply Coupon';
      viewCouponAmount.value = 'Apply Coupon';
      viewCouponPrefix.value = '';
    }
  }

  /// Add item to cart
  Future<void> addToCart({
    required String productId,
    required int quantity,
    required String variantId,
    required String productType,
    String? itemId,
  }) async {
    if (!AuthDetails.isUserLogin()) {
      isRefresh.value = false;
      showCartAuthBottomSheet();
      return;
    }
    try {
      if (AuthDetails.isUserLogin()) {
        // Check if item already exists in cart for quantity validation
        var existingCartItem = cartItems.firstWhereOrNull((cartItem) =>
            cartItem['product']?['_id'] == productId &&
            cartItem['variant']?['_id'] == variantId);

        var currentQty = existingCartItem?['quantity'] ?? 0;
        var newQty = currentQty + quantity;

        // Find variant to check available quantity
        if (existingCartItem != null) {
          var variant = existingCartItem['variant'];
          var variantQty = variant?['quantity'];

          if (variantQty != null && newQty > variantQty) {
            HelperFunctions.defaultdialogbox(
                "You can't add more than available quantity.", Colors.red);
            return;
          }
        }

        // Safety check: The backend fails if variant_id == product_id.
        // Resolve a valid variant ID from cartItems or product details.
        String actualVariantId =
            await _resolveDefaultVariantId(productId, variantId);
        if (actualVariantId == productId) {
          actualVariantId = '';
        }

        var body = {
          'quantity': quantity,
          'variant_id': actualVariantId,
          'product_id': productId,
          '_id': itemId,
        };

        var response = await BasicProvider("cart/manage")
            .postRequest(body)
            .catchError(handleError);

        if (response != null && response is Map) {
          // Clear coupon when cart changes
          clearCoupon();
          await _handleCartResponse(response);

          bool missingDetails =
              cartItems.any((item) => item is Map && item['product'] == null);
          if (missingDetails && AuthDetails.isUserLogin()) {
            await getCartProduct();
          }
        } else if (response != null) {
          // If we got a success status but non-map data, refresh to be safe
          await getCartProduct();
        }
      } else {
        // Guest user cart
        var newItem = {
          '_id': productId,
          'quantity': quantity,
          'variant_name': variantId == 'null' ? null : variantId,
          'producttype': productType
        };

        // Check if item already exists
        bool itemExists = guestUserCartList.any((item) =>
            item['_id'] == productId &&
            item['variant_name'] == newItem['variant_name']);

        if (!itemExists) {
          guestUserCartList.add(newItem);
          box.write('guestUserCartList', guestUserCartList.toList());
          await loadGuestCart();
        }
      }
    } catch (e) {
      print('Error adding to cart: $e');
      HelperFunctions.defaultdialogbox("Failed to update cart.", Colors.red);
    }
  }

  Future<String> _resolveDefaultVariantId(
      String productId, String variantId) async {
    String actual = _getEffectiveVariantId(productId, variantId);
    if (actual.isNotEmpty && actual != productId) {
      return actual;
    }

    try {
      final res = await BasicProvider('products/$productId').getRequest();
      Map? prodMap;
      if (res is Map) {
        if (res['product'] is Map) {
          prodMap = res['product'];
        } else if (res['data'] is Map) {
          prodMap = res['data'];
        } else {
          prodMap = res;
        }
      }

      if (prodMap != null) {
        final variants =
            (prodMap['variants'] ?? prodMap['variant_ids']) as List?;
        if (variants != null && variants.isNotEmpty) {
          for (var v in variants) {
            if (v is Map &&
                v['is_default'] == true &&
                v['_id'] != null &&
                v['_id'] != productId) {
              return v['_id'].toString();
            }
          }
          for (var v in variants) {
            if (v is Map && v['_id'] != null && v['_id'] != productId) {
              return v['_id'].toString();
            } else if (v is String && v != productId && v.isNotEmpty) {
              return v;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to resolve default variant for $productId: $e');
    }

    return '';
  }

  String _getEffectiveVariantId(String productId, String variantId) {
    String actualVariantId = variantId;
    if (actualVariantId == 'null') actualVariantId = '';

    // If variantId matches productId or is empty, try to find the correct variant ID from cart items
    if (actualVariantId.isEmpty || actualVariantId == productId) {
      var itemWithDetails = cartItems.firstWhereOrNull((item) =>
          item['product'] != null && item['product']['_id'] == productId);

      if (itemWithDetails != null) {
        var variant = getVariantForItem(itemWithDetails);
        if (variant != null &&
            variant['_id'] != null &&
            variant['_id'] != productId) {
          actualVariantId = variant['_id'];
          debugPrint(
              'DEBUG: Resolved variant ID to $actualVariantId from item details');
        }
      }
    }

    // Fallback: if they are identical, backend rejects it, so clear it
    if (actualVariantId == productId) {
      debugPrint(
          'DEBUG: variantId matches productId, clearing it to empty string');
      actualVariantId = '';
    }

    return actualVariantId;
  }

  /// Find a cart item and its index by product name or id.
  Map<String, dynamic>? findCartItem({String? productName, String? productId}) {
    for (int i = 0; i < cartItems.length; i++) {
      final item = cartItems[i];
      if (item is Map) {
        final p = item['product'];
        final pId = (p is Map ? p['_id'] : item['product_id'])?.toString();
        final pName = (p is Map ? p['name'] : item['name'])?.toString();

        if (productId != null && productId.isNotEmpty && pId == productId) {
          return {'item': item, 'index': i};
        }
        if (productName != null && productName.isNotEmpty && pName != null) {
          if (pName.trim().toLowerCase() == productName.trim().toLowerCase()) {
            return {'item': item, 'index': i};
          }
          if (productName.toLowerCase().contains(pName.toLowerCase()) ||
              pName.toLowerCase().contains(productName.toLowerCase())) {
            return {'item': item, 'index': i};
          }
        }
      }
    }
    return null;
  }

  Future<bool> removeCartProduct({
    required String productId,
    required int index,
    required String variantId,
    String? itemId,
    bool showSuccessDialog = true,
  }) async {
    dynamic removedItem;
    int removedIndex = -1;

    try {
      if (AuthDetails.isUserLogin()) {
        String actualVariantId = _getEffectiveVariantId(productId, variantId);

        // Optimistic UI update: find and remove item from cartItems immediately
        removedIndex = cartItems.indexWhere((item) =>
            (itemId != null && item['_id'] == itemId) ||
            (item['product'] != null &&
                item['product']['_id'] == productId &&
                (item['variant'] != null
                    ? item['variant']['_id'] == variantId ||
                        item['variant']['_id'] == actualVariantId
                    : true)));

        if (removedIndex != -1) {
          removedItem = cartItems[removedIndex];
          cartItems.removeAt(removedIndex);
        } else if (index >= 0 && index < cartItems.length) {
          removedItem = cartItems[index];
          cartItems.removeAt(index);
        } else {
          cartItems.removeWhere((item) =>
              (itemId != null && item['_id'] == itemId) ||
              (item['product'] != null &&
                  item['product']['_id'] == productId &&
                  (item['variant'] != null
                      ? item['variant']['_id'] == variantId ||
                          item['variant']['_id'] == actualVariantId
                      : true)));
        }

        // Recalculate totals immediately so the screen updates smoothly
        calculateCartTotals();

        // Reverting to cart/remove as manage doesn't allow 0 quantity.
        // We'll be more surgical with the parameters.
        var requestBody = <String, dynamic>{
          '_id': itemId, // The unique cart item ID
          'product_id': productId,
        };

        if (actualVariantId.isNotEmpty) {
          requestBody['variant_id'] = actualVariantId;
        }

        debugPrint('DEBUG: removeCartProduct REQUEST BODY: $requestBody');

        var response = await BasicProvider("cart/remove")
            .postRequest(requestBody)
            .catchError(handleError);

        debugPrint('DEBUG: removeCartProduct RESPONSE: $response');

        if (response != null) {
          clearCoupon();

          // Update the cart state
          await _handleCartResponse(response);

          // Force local removal if the backend returned cached item
          // This ensures the UI is always in sync with the user's action
          cartItems.removeWhere((item) =>
              (itemId != null && item['_id'] == itemId) ||
              (item['product'] != null &&
                  item['product']['_id'] == productId &&
                  (item['variant'] != null
                      ? item['variant']['_id'] == variantId ||
                          item['variant']['_id'] == actualVariantId
                      : true)));

          calculateCartTotals();

          if (showSuccessDialog) {
            HelperFunctions.defaultdialogbox(
                'Item removed from cart.', Colors.green);
            Future.delayed(const Duration(seconds: 2), () {
              if (Get.isDialogOpen ?? false) Get.back();
            });
          }
          return true;
        } else {
          // Rollback optimistic removal on failure
          if (removedItem != null) {
            if (removedIndex >= 0 && removedIndex <= cartItems.length) {
              cartItems.insert(removedIndex, removedItem);
            } else {
              cartItems.add(removedItem);
            }
            calculateCartTotals();
          }

          if (showSuccessDialog) {
            HelperFunctions.defaultdialogbox(
                'Could not remove item from cart.', Colors.red);
            Future.delayed(const Duration(seconds: 2), () {
              if (Get.isDialogOpen ?? false) Get.back();
            });
          }
          return false;
        }
      } else {
        guestUserCartList.removeWhere((item) =>
            item['_id'] == productId &&
            (item['variant_name'] == variantId ||
                (variantId == 'null' && item['variant_name'] == null)));

        box.write('guestUserCartList', guestUserCartList.toList());
        await loadGuestCart();
        if (showSuccessDialog) {
          HelperFunctions.defaultdialogbox(
              'Item removed from cart.', Colors.green);
          Future.delayed(const Duration(seconds: 2), () {
            if (Get.isDialogOpen ?? false) Get.back();
          });
        }
        return true;
      }
    } catch (e) {
      print('Error removing from cart: $e');
      // Rollback optimistic removal on exception
      if (removedItem != null) {
        if (removedIndex >= 0 && removedIndex <= cartItems.length) {
          cartItems.insert(removedIndex, removedItem);
        } else {
          cartItems.add(removedItem);
        }
        calculateCartTotals();
      }

      if (showSuccessDialog) {
        HelperFunctions.defaultdialogbox(
            'Could not remove item from cart.', Colors.red);
        Future.delayed(const Duration(seconds: 2), () {
          if (Get.isDialogOpen ?? false) Get.back();
        });
      }
      return false;
    }
  }

  /// Increment/decrement quantity by [delta] for a product, working for both
  /// guest and logged-in carts. Removes the item if the resulting quantity
  /// would drop to 0 or below.
  Future<void> updateCartQuantity({
    required String productId,
    required String variantId,
    required int delta,
  }) async {
    if (AuthDetails.isUserLogin()) {
      var existingCartItem = cartItems.firstWhereOrNull((cartItem) =>
          cartItem['product']?['_id'] == productId &&
          (cartItem['variant']?['_id'] == variantId ||
              variantId.isEmpty ||
              cartItem['variant'] == null));

      if (existingCartItem == null) return;

      var currentQty = existingCartItem['quantity'] ?? 1;
      var newQty = currentQty + delta;
      var resolvedVid =
          existingCartItem['variant']?['_id']?.toString() ?? variantId;

      if (newQty <= 0) {
        await removeCartProduct(
          productId: productId,
          index: cartItems.indexOf(existingCartItem),
          variantId: resolvedVid,
          itemId: existingCartItem['_id']?.toString(),
        );
      } else {
        await addToCart(
          productId: productId,
          quantity: delta,
          variantId: resolvedVid,
          productType: existingCartItem['product']?['type'] ?? 'simple',
          itemId: existingCartItem['_id']?.toString(),
        );
      }
    } else {
      int index = guestUserCartList.indexWhere((item) =>
          item['_id'] == productId &&
          (item['variant_name'] == variantId ||
              (variantId.isEmpty && item['variant_name'] == null)));

      if (index == -1) return;

      var currentQty = guestUserCartList[index]['quantity'] ?? 1;
      if (currentQty + delta <= 0) {
        await removeCartProduct(
          productId: productId,
          index: index,
          variantId: variantId,
        );
      } else if (delta > 0) {
        increment(index);
      } else if (delta < 0) {
        decrement(index);
      }
    }
  }

  /// Apply coupon
  // Future<dynamic> applyCoupon({required String coupon}) async {
  //   try {
  //     HelperFunctions().showOverlayLoader();

  //     var form = {
  //       // 'coupon': coupon
  //       'coupon_code': 'couponCode',
  //       'total_amount': 'grandTotal',
  //       // user_id: user.id || null,
  //       'products': cartItems,
  //     };
  //     var response = await BasicProvider("public/coupons/check-coupon")
  //         .postRequest(form)
  //         .catchError(handleError);

  //     if (response != null && response.isNotEmpty) {
  //       couponDetails.clear();
  //       couponDetails.addAll(response);
  //       calculateCartTotals();
  //     }

  //     Get.until((route) => !Get.isDialogOpen!);
  //     return response;
  //   } catch (e) {
  //     print('Error applying coupon: $e');
  //     Get.until((route) => !Get.isDialogOpen!);
  //     return null;
  //   }
  // }

  Future<dynamic> applyCoupon({required String coupon}) async {
    try {
      HelperFunctions().showOverlayLoader();

      var form = {'code': coupon.trim()};

      // TEMP diagnostics: compare with the Postman request (code + user).
      try {
        final jwt = TokenManager.accessToken?.split('.');
        final payload = jwt != null && jwt.length > 1
            ? utf8.decode(base64Url.decode(base64Url.normalize(jwt[1])))
            : 'no token';
        debugPrint('apply-coupon body=$form units=${form['code']!.codeUnits} '
            'cartItems=${cartItems.map((e) => e['_id']).toList()} jwt=$payload');
      } catch (e) {
        debugPrint('apply-coupon diag failed: $e');
      }

      var response = await BasicProvider("cart/apply-coupon")
          .postRequest(form)
          .catchError(handleError);

      // The API returns the whole server cart. Pull out the coupon fields and
      // expose them under the `code` / `discount_*` keys the UI relies on.
      if (response is Map && response.isNotEmpty) {
        final options = response['options'];
        final nestedCoupon = options is Map ? options['coupon'] : null;
        final appliedCode = (response['applied_coupon'] ??
                (nestedCoupon is Map ? nestedCoupon['code'] : null))
            ?.toString();

        if (appliedCode == null || appliedCode.isEmpty) {
          Get.until((route) => !Get.isDialogOpen!);
          return {
            'message': response['message']?.toString() ?? 'Invalid coupon code'
          };
        }

        final details = <String, dynamic>{
          'code': appliedCode,
          'coupon_type': response['coupon_type'],
          'discount_type': response['discount_type'],
          'discount_value': response['discount_value'],
          'discount_amount': response['discount_amount'],
          'sub_total': response['sub_total'],
          'total': response['total'],
          'grand_total': response['grand_total'],
        };
        couponDetails.clear();
        couponDetails.addAll(details);
        calculateCartTotals();
        Get.until((route) => !Get.isDialogOpen!);
        return details;
      } else if (response is String && response.isNotEmpty) {
        Get.until((route) => !Get.isDialogOpen!);
        return {'message': response};
      }

      Get.until((route) => !Get.isDialogOpen!);
      return response;
    } catch (e) {
      print('Error applying coupon: $e');
      Get.until((route) => !Get.isDialogOpen!);
      return null;
    }
  }

  /// Clear coupon
  void clearCoupon() {
    couponDetails.clear();
    isCouponApply.value = false;
    couponDiscountAmount.value = '';
    couponController.clear();
    calculateCartTotals();
  }

  /// Get similar products
  Future<void> getSimilarProducts() async {
    if (categoriesID.isEmpty) return;

    try {
      var response = await BasicProvider("public/product/categorywise")
          .postRequest({"categories": categoriesID}).catchError(handleError);

      if (response != null) {
        similarProduct.clear();
        if (response is List) {
          similarProduct.addAll(response);
        } else if (response is Map && response['data'] != null) {
          similarProduct.addAll(response['data']);
        } else {
          debugPrint(
              '⚠️ Unexpected response type in getSimilarProducts: ${response.runtimeType}');
        }
      }
    } catch (e) {
      print('Error fetching similar products: $e');
    }
  }

  /// Refresh cart
  Future<void> onRefresh() async {
    categoriesID.clear();
    if (AuthDetails.isUserLogin()) {
      await getCartProduct();
    } else {
      await loadGuestCart();
    }
    getSimilarProducts();
  }

  /// Increment quantity for guest users
  void increment(int index) {
    if (index < guestUserCartList.length) {
      var currentQty = guestUserCartList[index]['quantity'] ?? 1;
      if (currentQty < 10) {
        guestUserCartList[index]['quantity'] = currentQty + 1;
        box.write('guestUserCartList', guestUserCartList.toList());

        // Update the corresponding cart item
        if (index < cartItems.length) {
          cartItems[index]['quantity'] = currentQty + 1;
          calculateCartTotals();
        }
      }
    }
  }

  /// Decrement quantity for guest users
  void decrement(int index) {
    if (index < guestUserCartList.length) {
      var currentQty = guestUserCartList[index]['quantity'] ?? 1;
      if (currentQty > 1) {
        guestUserCartList[index]['quantity'] = currentQty - 1;
        box.write('guestUserCartList', guestUserCartList.toList());

        // Update the corresponding cart item
        if (index < cartItems.length) {
          cartItems[index]['quantity'] = currentQty - 1;
          calculateCartTotals();
        }
      }
    }
  }

  // Helper getter for checking if cart is empty
  bool get isCartEmpty => cartItems.isEmpty;

  // Helper getter for cart item count
  int get cartItemCount => cartItems.length;

  // Helper getter for total quantity
  int get totalQuantity {
    return cartItems.fold(
        0, (sum, item) => sum + (item['quantity'] ?? 0) as int);
  }
}

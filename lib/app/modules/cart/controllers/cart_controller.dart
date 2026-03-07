import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CartController extends GetxController
    with BaseController, SingleGetTickerProviderMixin {
  final CartService _cartService = Get.find<CartService>();
  var box = GetStorage();

  // These will be derived from CartService
  var cartProducts = [].obs; // Formatted cart items for UI
  var productDetails = [].obs; // Product details
  var productQuntity = [].obs; // ADD THIS - Product quantities
  var otherCartDetails = {}.obs;
  var couponDetails = {}.obs;
  var guestUserCartList = [];
  var isCouponApply = false.obs;
  var allCoupon = [].obs;
  var couponeMessage = ''.obs;
  late TextEditingController couponController;
  var isRefresh = false.obs;
  var isClicked = false.obs;
  late AnimationController couponeMessageAnimationController;
  var guestUserCartWeight;

  var bagpriceAmount = 0.0.obs;
  var discountAmount = 0.0.obs;
  var totalAmount = 0.0.obs;

  var similarProduct = [].obs;
  var categoriesID = [].obs;

  var viewCouponPrefix = ''.obs;
  var viewprice = ''.obs;
  var viewcouponCode = ''.obs;
  var viewCouponAmount = ''.obs;
  var viewsavedPrice = ''.obs;
  var viewTotalAmount = ''.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey targetKey = GlobalKey();

  ScrollController scrollController = ScrollController();
  FocusNode targetFocusNode = FocusNode();

  @override
  Future<void> onInit() async {
    super.onInit();
    couponController = TextEditingController();

    // Listen to cart service changes
    ever(_cartService.cartItems, (_) => _updateFromService());
    ever(_cartService.subTotal, (_) => _updateFromService());
    ever(_cartService.total, (_) => _updateFromService());

    await getCartProduct();
    getOrderDetails();
  }

  void _updateFromService() {
    // Transform service cart items to UI format
    _transformCartItems();
    getOrderDetails();
    update();
  }

  void _transformCartItems() {
    if (AuthDetails.isUserLogin()) {
      // Transform service cart items to the format expected by UI
      List<dynamic> newProducts = [];
      List<dynamic> newCartItems = [];
      List<dynamic> newQuantities = []; // ADD THIS

      for (var item in _cartService.cartItems) {
        // Handle product_id being either a Map or a String (ID)
        var rawProduct = item['product_id'];
        var product = rawProduct is Map
            ? rawProduct as Map<String, dynamic>
            : {'_id': rawProduct?.toString() ?? ''};

        // Handle variant being either a Map or a String (ID)
        var variant = item['variant'] is Map
            ? item['variant'] as Map<String, dynamic>
            : (item['variant_id'] is Map
                ? item['variant_id'] as Map<String, dynamic>
                : null);

        // If variant object is missing but we have a variant_id string, use it
        String vId = variant?['_id']?.toString() ?? '';
        if (vId.isEmpty && item['variant_id'] is String) {
          vId = item['variant_id'];
        }

        newProducts.add(product);

        // Calculate price for the item (handle simple product fallback)
        num itemPrice = 0;
        if (variant != null) {
          itemPrice = variant['sale_price'] ?? variant['price'] ?? 0;
        } else {
          itemPrice = product['sale_price'] ?? product['price'] ?? 0;

          // BI-99: Fallback to variants if top-level price is 0 for simple product
          if (itemPrice == 0 &&
              product['variants'] != null &&
              product['variants'] is List &&
              product['variants'].isNotEmpty) {
            final variants = product['variants'] as List;
            final defaultVariant = variants.firstWhere(
                (v) => v['is_default'] == true,
                orElse: () => variants.first);
            if (defaultVariant != null) {
              itemPrice =
                  defaultVariant['sale_price'] ?? defaultVariant['price'] ?? 0;
            }
          }
        }

        newCartItems.add({
          'productId': product['_id']?.toString() ?? '',
          'value': {
            'quantity': item['quantity'] ?? 1,
            'variant_name': variant?['name'] ?? '',
            'producttype': product['type'] ?? 'simple',
            'variant_id': vId,
            'price': itemPrice,
          }
        });
        newQuantities.add(item['quantity'] ?? 1); // ADD THIS
      }

      productDetails.assignAll(newProducts);
      cartProducts.assignAll(newCartItems);
      productQuntity.assignAll(newQuantities); // ADD THIS

      // Update totals
      bagpriceAmount.value = _cartService.subTotal.value;
      totalAmount.value = _cartService.total.value;
      discountAmount.value = bagpriceAmount.value - totalAmount.value;
    } else {
      // For guest users, use local cart data
      _loadGuestCartData();
    }
  }

  void _loadGuestCartData() {
    guestUserCartList = box.read('guestUserCartList') ?? [];
    // Initialize quantities for guest users
    productQuntity.clear();
    for (var item in guestUserCartList) {
      productQuntity.add(item['quantity'] ?? 1);
    }
  }

  void getOrderDetails() {
    if (AuthDetails.isUserLogin()) {
      viewCouponPrefix.value = couponDetails.containsKey('coupon_type')
          ? couponDetails['coupon_type'] == 'fixAmount'
              ? '(\u{20B9}${couponDetails['discount_value']})'
              : '(${couponDetails['discount_value'].toString()}%)'
          : '';

      viewprice.value = bagpriceAmount.value.toStringAsFixed(2);
      viewTotalAmount.value = totalAmount.value.toStringAsFixed(2);

      viewcouponCode.value = couponDetails['message'] == 'Applyed'
          ? couponController.text.toString()
          : 'Apply Coupon';
      viewCouponAmount.value = couponDetails['message'] == 'Applyed'
          ? '-\u{20B9}${couponDetails['discount_amount'].toString()}'
          : 'Apply Coupon';

      viewsavedPrice.value = discountAmount.value.toStringAsFixed(2);
    } else {
      viewCouponPrefix.value = '';
      viewprice.value = bagpriceAmount.value.toStringAsFixed(2);
      viewTotalAmount.value = totalAmount.value.toStringAsFixed(2);
      viewcouponCode.value = '';
      viewCouponAmount.value = 'Apply Coupon';
      viewsavedPrice.value = discountAmount.value.toStringAsFixed(2);
    }
    update();
  }

  void gettotalAmount() {
    if (!AuthDetails.isUserLogin()) {
      bagpriceAmount.value = 0.0;
      discountAmount.value = 0.0;
      totalAmount.value = 0.0;
      var savingtemp = 0;

      for (var i = 0; i < productDetails.length; i++) {
        var product = productDetails[i];

        num priceVal = 0;
        num salePriceVal = 0;

        if (product['type'] == 'variant' &&
            product['variant_ids'] != null &&
            product['variant_ids'].isNotEmpty) {
          var variantIndex = getVariantIndex(i);
          if (variantIndex >= 0 &&
              variantIndex < product['variant_ids'].length) {
            priceVal = product['variant_ids'][variantIndex]['price'] ?? 0;
            salePriceVal =
                product['variant_ids'][variantIndex]['sale_price'] ?? 0;
          }
        } else {
          priceVal = product['price'] ?? 0;
          salePriceVal = product['sale_price'] ?? 0;

          // BI-99: Fallback to variants if top-level price is 0 for simple product
          if (priceVal == 0 &&
              salePriceVal == 0 &&
              product['variants'] != null &&
              product['variants'] is List &&
              product['variants'].isNotEmpty) {
            final variants = product['variants'] as List;
            final defaultVariant = variants.firstWhere(
                (v) => v['is_default'] == true,
                orElse: () => variants.first);
            if (defaultVariant != null) {
              priceVal = defaultVariant['price'] ?? 0;
              salePriceVal = defaultVariant['sale_price'] ?? 0;
            }
          }
        }

        bagpriceAmount.value +=
            (priceVal * (productQuntity[i] ?? 1)).toDouble();
        savingtemp += (salePriceVal * (productQuntity[i] ?? 1)).toInt();
      }

      discountAmount.value = bagpriceAmount.value - savingtemp;
      totalAmount.value = savingtemp.toDouble();
      getOrderDetails();
    }
  }

  void calculateWeight() {
    List<String> productTypes = [];
    List<String?> variantNames = [];

    var list = box.read('guestUserCartList');

    if (list != null) {
      for (int i = 0; i < list.length; i++) {
        String? productType = list[i]['producttype'];
        String? variantName = list[i]['variant_name'];

        if (productType != null) {
          productTypes.add(productType);
        }
        if (variantName != null) {
          variantNames.add(variantName);
        }
      }

      guestUserCartWeight = 0.00;
      for (var index = 0; index < list.length; index++) {
        if (index < productDetails.length && index < productQuntity.length) {
          if (productTypes[index] == 'variant') {
            List productallvariant = productDetails[index]['variant_ids'];
            for (int i = 0; i < productallvariant.length; i++) {
              if (variantNames[index] ==
                  productDetails[index]['variant_ids'][i]['variant']) {
                var weightUnit =
                    productDetails[index]['variant_ids'][i]['weight_unit'];
                var weight = productDetails[index]['variant_ids'][i]['weight'];

                if (weightUnit == 'gm') {
                  guestUserCartWeight +=
                      (double.parse(weight) * (productQuntity[index] ?? 1)) /
                          1000;
                } else if (weightUnit == 'kg') {
                  guestUserCartWeight +=
                      (double.parse(weight) * (productQuntity[index] ?? 1));
                } else {
                  guestUserCartWeight += 0.5;
                }
              }
            }
          } else {
            if (productDetails[index]['variant_ids'] != null &&
                productDetails[index]['variant_ids'] is List &&
                productDetails[index]['variant_ids'].isNotEmpty) {
              var weightUnit =
                  productDetails[index]['variant_ids'][0]['weight_unit'];
              var weight = productDetails[index]['variant_ids'][0]['weight'];
              if (weightUnit != null && weight != null) {
                if (weightUnit == 'gm') {
                  guestUserCartWeight += double.parse(weight.toString()) / 1000;
                } else if (weightUnit == 'kg') {
                  guestUserCartWeight += double.parse(weight.toString());
                }
              } else {
                guestUserCartWeight += 0.5;
              }
            } else {
              // Fallback for flat product structure if no variants
              var weight = productDetails[index]['weight'];
              var weightUnit = productDetails[index]['weight_unit'];
              if (weight != null && weightUnit != null) {
                if (weightUnit == 'gm') {
                  guestUserCartWeight += double.parse(weight.toString()) / 1000;
                } else {
                  guestUserCartWeight += double.parse(weight.toString());
                }
              } else {
                guestUserCartWeight += 0.5;
              }
            }
          }
        }
      }
    }
  }

  int getVariantIndex(int index) {
    if (index >= productDetails.length) return 0;

    if (AuthDetails.isUserLogin()) {
      if (index < cartProducts.length &&
          cartProducts[index]['value']['producttype'] == 'variant') {
        for (int i = 0; i < productDetails[index]['variant_ids'].length; i++) {
          if (cartProducts[index]['value']['variant_name'] ==
              productDetails[index]['variant_ids'][i]['variant']) {
            return i;
          }
        }
      }
      return 0;
    } else {
      List<String> productTypes = [];
      List<String?> variantNames = [];
      var list = box.read('guestUserCartList');

      if (list != null && index < list.length) {
        for (int i = 0; i < list.length; i++) {
          String? productType = list[i]['producttype'];
          String? variantName = list[i]['variant_name'];

          if (productType != null) {
            productTypes.add(productType);
          }
          if (variantName != null) {
            variantNames.add(variantName);
          }
        }

        if (index < productTypes.length && productTypes[index] == 'variant') {
          List productallvariant = productDetails[index]['variant_ids'];
          for (int i = 0; i < productallvariant.length; i++) {
            if (index < variantNames.length &&
                variantNames[index] ==
                    productDetails[index]['variant_ids'][i]['variant']) {
              return i;
            }
          }
        }
        return 0;
      }
      return 0;
    }
  }

  Future<void> removeCartProduct(
      {required String productId, required int index}) async {
    try {
      if (AuthDetails.isUserLogin()) {
        HelperFunctions().showOverlayLoader();

        var variantId = '';
        if (index < cartProducts.length) {
          variantId = cartProducts[index]['value']['variant_id'] ?? '';
        }

        // Fallback: If variant_id is missing, try to find it
        if (variantId.isEmpty && index < productDetails.length) {
          var product = productDetails[index];
          if (product['type'] == 'variable') {
            int vIdx = getVariantIndex(index);
            if (product['variant_ids'] != null &&
                vIdx < product['variant_ids'].length) {
              variantId = product['variant_ids'][vIdx]['_id'] ?? '';
            }
          }
        }

        var response = await _cartService.removeFromCart(
          productId: productId,
          variantSlug: variantId,
        );

        if (response == null) {
          Get.until((route) => !Get.isDialogOpen!);
          return;
        }

        couponDetails.value = {};
        isCouponApply.value = false;
        couponController.text = '';

        Get.until((route) => !Get.isDialogOpen!);
        HelperFunctions.defaultdialogbox('Remove Product From Cart');
        await Future.delayed(const Duration(seconds: 2));
        Get.until((route) => !Get.isDialogOpen!);
      } else {
        guestUserCartList = box.read('guestUserCartList');
        if (guestUserCartList.isNotEmpty && index < guestUserCartList.length) {
          guestUserCartList.removeAt(index);
          if (index < cartProducts.length) cartProducts.removeAt(index);
          if (index < productDetails.length) productDetails.removeAt(index);
          if (index < productQuntity.length)
            productQuntity.removeAt(index); // ADD THIS

          box.write('cartProducts', productDetails);
          gettotalAmount();
          List<dynamic> cartList = guestUserCartList.toList();
          box.write('guestUserCartList', cartList);
        }
      }
    } catch (e) {
      print('cart controller error $e');
      Get.until((route) => !Get.isDialogOpen!);
    }
  }

  Future<dynamic> applyCoupon({required String coupon}) async {
    HelperFunctions().showOverlayLoader();
    var form = {'coupon': coupon};

    Map<String, dynamic>? response = await BasicProvider("cart/apply/coupon")
        .postRequest(form)
        .catchError(handleError);

    if (response == null || response.isEmpty) {
      Get.until((route) => !Get.isDialogOpen!);
      return;
    }

    couponDetails.clear();
    couponDetails.addAll(response);

    // Refresh cart after coupon apply
    await getCartProduct();

    Get.until((route) => !Get.isDialogOpen!);
    getOrderDetails();
    return response;
  }

  Future<void> getCartProduct({String? coupon}) async {
    if (AuthDetails.isUserLogin()) {
      await _cartService.fetchCart();
      // The transformation happens automatically via ever listener
    } else {
      guestUserCartList = box.read('guestUserCartList');

      if (guestUserCartList != null && guestUserCartList.isNotEmpty) {
        cartProducts.clear();
        productDetails.clear();
        productQuntity.clear(); // ADD THIS

        for (int i = 0; i < guestUserCartList.length; i++) {
          await getProductDetials(id: guestUserCartList[i]['_id']);
        }
        box.write('cartProducts', productDetails);
        gettotalAmount();
      } else {
        print('guest user cart list is null or not found in storage');
      }
    }
  }

  dynamic getProductDetials({required String id}) async {
    try {
      var response = await BasicProvider("product/show/$id")
          .getRequest()
          .catchError(handleError);
      if (response == null) return;

      List list = response['categories'];
      categoriesID.clear();
      if (list.isNotEmpty) {
        for (var i = 0; i < list.length; i++) {
          categoriesID.add(list[i]['_id']);
        }
      }

      if (AuthDetails.isUserLogin()) {
        return;
      } else {
        productDetails.add(response);
        productQuntity.add(1); // NOW THIS WILL WORK
        cartProducts.add(response);
      }
    } catch (e) {
      print('cart controller error $e');
    }
  }

  Future<void> addToCart({
    required String productId,
    required int quantity,
    required String variantName,
    required String productType,
    Map<String, dynamic>? product,
  }) async {
    if (AuthDetails.isUserLogin()) {
      // Find variant ID from product data
      String variantId = '';
      if (product != null && product['variants'] != null) {
        for (var v in product['variants']) {
          if (v['name'] == variantName) {
            variantId = v['_id'] ?? '';
            break;
          }
        }
      }

      var response = await _cartService.manageCart(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
        product: product,
      );

      if (response == null) return;

      couponDetails.value = {};
      isCouponApply.value = false;
      couponController.text = '';

      await getCartProduct();
      getSimilarProduct(categoriesID);
    } else {
      var guestForm = {
        '_id': productId,
        'quantity': quantity,
        'variant_name': variantName.toString() == 'null' ? null : variantName,
        'producttype': productType
      };

      guestUserCartList = box.read('guestUserCartList') ?? [];
      bool found = false;

      for (var i = 0; i < guestUserCartList.length; i++) {
        if (guestUserCartList[i]['_id'] == guestForm['_id']) {
          guestUserCartList[i]['quantity'] = quantity;
          if (i < productQuntity.length) {
            productQuntity[i] = quantity; // UPDATE QUANTITY
          }
          found = true;
          break;
        }
      }

      if (!found) {
        guestUserCartList.add(guestForm);
        productQuntity.add(quantity); // ADD QUANTITY FOR NEW ITEM
      }

      List<dynamic> cartList = guestUserCartList.toList();
      box.write('guestUserCartList', cartList);
      getCartProduct();
    }
  }

  Future<void> updateQuantity(int index, int quantity) async {
    if (quantity < 1) return;

    if (index >= productDetails.length || index >= productQuntity.length)
      return;

    var product = productDetails[index];
    int currentQty = productQuntity[index];
    int delta = quantity - currentQty;

    if (delta == 0) return;

    if (AuthDetails.isUserLogin()) {
      String productId = product['_id'].toString();
      String variantId = '';

      if (index < cartProducts.length) {
        variantId = cartProducts[index]['value']['variant_id'] ?? '';
      }

      // Fallback: If variant_id is missing, try to find it
      if (variantId.isEmpty && product['type'] == 'variable') {
        int vIdx = getVariantIndex(index);
        if (product['variant_ids'] != null &&
            vIdx < product['variant_ids'].length) {
          variantId = product['variant_ids'][vIdx]['_id'] ?? '';
        }
      }

      await _cartService.manageCart(
        productId: productId,
        variantId: variantId,
        quantity: delta,
        product: product,
      );

      // Update local quantity immediately for better UX
      if (index < productQuntity.length) {
        productQuntity[index] = quantity;
      }
    } else {
      if (index < guestUserCartList.length) {
        var variantName = guestUserCartList[index]['variant_name'] ?? '';
        var productType = guestUserCartList[index]['producttype'] ?? 'simple';

        await addToCart(
          productId: product['_id'],
          quantity: quantity,
          variantName: variantName,
          productType: productType,
          product: product,
        );

        // Update local quantity
        if (index < productQuntity.length) {
          productQuntity[index] = quantity;
        }
      }
    }
    update();
  }

  dynamic getVariantPrice(int index) {
    if (index >= cartProducts.length || index >= productDetails.length)
      return 0;

    // Check if price is already cached
    if (cartProducts[index]['value'] != null &&
        cartProducts[index]['value']['price'] != null) {
      return cartProducts[index]['value']['price'];
    }

    var product = productDetails[index];
    var variantIndex = getVariantIndex(index);

    if (product['variant_ids'] == null ||
        product['variant_ids'].isEmpty ||
        variantIndex >= product['variant_ids'].length) {
      return 0;
    }

    var variant = product['variant_ids'][variantIndex];
    return variant['sale_price'] ?? variant['price'] ?? 0;
  }

  Future<void> onRefresh() async {
    categoriesID.clear();
    await getCartProduct();
    getSimilarProduct(categoriesID);
  }

  void getCoupn() async {
    try {
      var response =
          await BasicProvider("coupons").getRequest().catchError(handleError);
      if (response == null) return;
      allCoupon.clear();
      allCoupon.addAll(response['data']);
    } catch (e) {
      print('get coupon error $e');
    }
  }

  void increment(int index) {
    if (index < productQuntity.length && productQuntity[index] != 10) {
      productQuntity[index]++;
      if (index < guestUserCartList.length) {
        guestUserCartList[index]['quantity']++;
      }
      gettotalAmount();
      update();
    }
  }

  void decrement(int index) {
    if (index < productQuntity.length && productQuntity[index] > 1) {
      productQuntity[index]--;
      if (index < guestUserCartList.length) {
        guestUserCartList[index]['quantity']--;
      }
      gettotalAmount();
      update();
    }
  }

  Future<void> getSimilarProduct(List category) async {
    try {
      var response = await BasicProvider("product/categorywise")
          .postRequest({"categories": category}).catchError(handleError);
      if (response == null) return;
      similarProduct.clear();
      similarProduct.addAll(response['data']);
    } catch (e) {
      print('similar product error $e');
    }
  }

  var dropdownvalue = 'Qty: 1'.obs;
  var items = [
    'Qty: 1',
    'Qty: 2',
    'Qty: 3',
    'Qty: 4',
  ];

  var sizedropDownvalue = 'Size: S'.obs;
  var sizeList = [
    'Size: S',
    'Size: M',
    'Size: L',
    'Size: XL',
  ];
}

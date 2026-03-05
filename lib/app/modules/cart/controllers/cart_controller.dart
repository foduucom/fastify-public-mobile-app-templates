import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CartController extends GetxController
    with BaseController, SingleGetTickerProviderMixin {
  var addToProductsLIst = List<dynamic>.empty().obs;
  var box = GetStorage();

  var cartProducts = [].obs;
  var productDetails = [].obs;
  var variantDetails = [].obs;
  // var productQuntity = 0.obs;
  var productQuntity = [].obs;
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

  var demoProductDetails = [];
  var demoCartProduct = [];

  var bagpriceAmount = 0.obs;
  var discountAmount = 0.obs;
  var totalAmount = 0.obs;

  var similarProduct = [].obs;
  var categoriesID = [].obs;
  var demoCategoriesId = [];

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

    // couponeMessageAnimationController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 500),
    // );
    // if (!AuthDetails.isUserLogin()) {
    //   // boxProductRead();
    // }
    // couponController = TextEditingController();
    // await getCartProduct();
    // gettotalAmount();
    // getSimilarProduct(categoriesID);
    // totalAmount();
    // await productsAddedToCart();
    // subTotal.value = ShoppingCartController().subTotal();
  }

  void getOrderDetails() {
    if (AuthDetails.isUserLogin()) {
      viewCouponPrefix.value = couponDetails.containsKey('coupon_type')
          ? couponDetails['coupon_type'] == 'fixAmount'
              ? '(\u{20B9}${couponDetails['discount_value']})'
              : '(${couponDetails['discount_value'].toString()}%)'
          : '';
      viewprice.value = AuthDetails.isUserLogin()
          ? otherCartDetails['total'].toString()
          : bagpriceAmount.value.toString();
      viewTotalAmount.value = AuthDetails.isUserLogin()
          ? ((((otherCartDetails['total'] ?? 0) -
                      ((otherCartDetails['total'] ?? 0) -
                          (otherCartDetails['subtotal'] ?? 0))) -
                  (couponDetails.containsKey('discount_amount')
                      ? (couponDetails['discount_amount'] ?? 0.00)
                      : 0.00)))
              .toString()
          : totalAmount.toString();
      // totalAmount.value = 'testing';
      viewcouponCode.value = couponDetails['message'] == 'Applyed'
          ? couponController.text.toString()
          : 'Apply Coupon';
      viewCouponAmount.value = couponDetails['message'] == 'Applyed'
          ? '-\u{20B9}${couponDetails['discount_amount'].toString()}'
          : 'Apply Coupon';
      viewsavedPrice.value = AuthDetails.isUserLogin()
          ? (otherCartDetails['total'] - otherCartDetails['subtotal'])
              .toString()
          : discountAmount.value.toString();
    } else {
      viewCouponPrefix.value = '';
      viewprice.value = bagpriceAmount.value.toString();
      viewTotalAmount.value = totalAmount.value.toString();
      viewcouponCode.value = '';
      viewCouponAmount.value = 'Apply Coupon';
      viewsavedPrice.value = discountAmount.value.toString();
    }
  }

  void gettotalAmount() {
    if (!AuthDetails.isUserLogin()) {
      bagpriceAmount.value = 0;
      discountAmount.value = 0;
      totalAmount.value = 0;
      var savingtemp = 0;
      for (var i = 0; i < productDetails.length; i++) {
        var product = productDetails[i];
        var variantIndex = getVariantIndex(i);
        bagpriceAmount.value = (bagpriceAmount.value +
                (product['variant_ids'][variantIndex]['price'] *
                    productQuntity[i]))
            .toInt();
        savingtemp = (savingtemp +
                ((product['variant_ids'][variantIndex]['sale_price'] *
                    productQuntity[i])))
            .toInt();

        discountAmount.value = bagpriceAmount.value - savingtemp;
        // totalAmount.value = bagpriceAmount.value - discountAmount.value;
        totalAmount.value = savingtemp;
        getOrderDetails();
        // totalAmount.value = 55;
      }
    }
    // subTotal.value = subTotal.value + amount;
  }

  // Future<void> boxProductRead() async {
  //   var boxProductDetails = box.read('cartProducts');
  //   var boxCartProductId = box.read('cartProductId');
  //   otherCartDetails.value = box.read('otherCartDetails');
  //   if (boxProductDetails != null && boxCartProductId != null) {
  //     productDetails.clear();
  //     for (int i = 0; i < cartProducts.length; i++) {
  //       addToProductsLIst.add(cartProducts[i]);
  //     }
  //     productDetails.addAll(boxProductDetails);
  //     cartProducts.addAll(boxCartProductId);
  //   }
  // }

  void calculateWeight() {
    List<String> productTypes = [];
    List<String?> variantNames = [];
    // print('get variant index  $cartProducts');
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
                    (double.parse(weight) * productQuntity[index]) / 1000;
              } else if (weightUnit == 'kg') {
                guestUserCartWeight +=
                    (double.parse(weight) * productQuntity[index]);
              } else {
                guestUserCartWeight += 0.5;
              }
            }
          }
        } else {
          print('<<<<<<<<<<<<<<<<<<<<<<<<$index>>>>>>>>>>>>>>>>>>>>>>>>');
          print(productDetails);
          var weightUnit =
              productDetails[index]['variant_ids'][0]['weight_unit'];
          if (weightUnit != null) {
            var weight = productDetails[index]['variant_ids'][0]['weight'];
            if (weightUnit == 'gm') {
              guestUserCartWeight += double.parse(weight) / 1000;
            } else if (weightUnit == 'kg') {
              guestUserCartWeight += double.parse(weight);
            } else if (weightUnit == null) {
              guestUserCartWeight += 0.5;
            }
          } else {}
        }
      }

      // return 0;
    }
    // return 0;
  }

  int getVariantIndex(int index) {
    if (AuthDetails.isUserLogin()) {
      if (cartProducts[index]['value']['producttype'] == 'variant') {
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
      // print('get variant index  $cartProducts');
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
        if (productTypes[index] == 'variant') {
          List productallvariant = productDetails[index]['variant_ids'];
          for (int i = 0; i < productallvariant.length; i++) {
            if (variantNames[index] ==
                productDetails[index]['variant_ids'][i]['variant']) {
              return i;
            }
          }
        }
        return 0;
      }
      return 0;
    }

    // return 0;
  }

  Future<void> removeCartProduct(
      {required String productId, required int index}) async {
    try {
      if (AuthDetails.isUserLogin()) {
        HelperFunctions().showOverlayLoader();

        var response = await BasicProvider("public/cart/delete/$productId")
            .getRequest()
            .catchError(handleError);
        if (response == null) return;

        couponDetails.value = {};
        isCouponApply.value = false;
        couponController.text = '';

        getCartProduct();
        update();
        Get.until((route) => !Get.isDialogOpen!);
        HelperFunctions.defaultdialogbox('Remove Product From Cart');
        await Future.delayed(const Duration(seconds: 2));
        Get.until((route) => !Get.isDialogOpen!);
        // box.write('cartProductId', cartProducts);
        // box.write('cartProducts', productDetails);
      } else {
        guestUserCartList = box.read('guestUserCartList');
        if (guestUserCartList.isNotEmpty) {
          guestUserCartList.removeAt(index);
          cartProducts.removeAt(index);
          productDetails.removeAt(index);
          // box.write('cartProductId', cartProducts);
          box.write('cartProducts', productDetails);
          gettotalAmount();
          List<dynamic> cartList = guestUserCartList.toList();
          box.write('guestUserCartList', cartList);
        }
      }
    } catch (e) {
      print('cart controller error $e');
    }
  }

  Future<dynamic> applyCoupon({required String coupon}) async {
    HelperFunctions().showOverlayLoader();
    var form = {'coupon': coupon};
    Map<String, dynamic> response =
        await BasicProvider("public/cart/apply/coupon")
            .postRequest(form)
            .catchError(handleError);

    if (response.isEmpty) return;
    couponDetails.clear();
    couponDetails.addAll(response);
    Get.until((route) => !Get.isDialogOpen!);
    getOrderDetails();
    return response;
  }

  Future<void> getCartProduct({String? coupon}) async {
    if (AuthDetails.isUserLogin()) {
      Map<String, dynamic>? response = await BasicProvider("public/cart")
          .getRequest(queryParams: {'coupon': coupon}).catchError(handleError);

      if (response != null && response.containsKey('cartitems')) {
        otherCartDetails.value = response;

        Map<String, dynamic> json = response['cartitems']['value'];

        demoCartProduct.clear();
        demoProductDetails = [];
        json.forEach((key, value) {
          demoCartProduct.add({'productId': key, 'value': value});
        });

        cartProducts.value = demoCartProduct;
        for (int i = 0; i < demoCartProduct.length; i++) {
          if (demoCartProduct[i]['productId'] != null) {
            await getProductDetials(id: demoCartProduct[i]['productId']);
          }
        }
        productDetails.value = demoProductDetails;

        getOrderDetails();
        getSimilarProduct(categoriesID);
        gettotalAmount();
        update();
        // Get.until((route) => !Get.isDialogOpen!);
      } else {
        productDetails.clear();
        cartProducts.clear();
        demoCartProduct.clear();
        demoProductDetails.clear();
      }
    } else {
      guestUserCartList = box.read('guestUserCartList');

      if (guestUserCartList != null) {
        cartProducts.clear();
        productDetails.clear();

        // list.forEach((item) {
        //   Map<String, dynamic> valueMap = item['value'];
        //   cartProducts.add(valueMap);
        // });

        // for (int i = 0; i < cartProducts.length; i++) {
        //   await getProductDetials(id: cartProducts[i].keys.first);
        // }
        for (int i = 0; i < guestUserCartList.length; i++) {
          await getProductDetials(id: guestUserCartList[i]['_id']);
        }
        // box.write('cartProductId', cartProducts);
        box.write('cartProducts', productDetails);
        gettotalAmount();
      } else {
        print('guest user cart list is null or not found in storage');
      }
    }
  }

  dynamic getProductDetials({required String id}) async {
    try {
      var response = await BasicProvider("public/product/show/$id")
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
        demoProductDetails.add(response);
        return;
      } else {
        productDetails.add(response);
        productQuntity.add(1);
        cartProducts.add(response);
      }
    } catch (e) {
      print('cart controller error $e');
    }
  }

  Future<void> addToCart(
      {required String productId,
      required int quantity,
      required String variantName,
      required String productType}) async {
    var form = {
      'value': {
        productId: {
          'quantity': quantity,
          'variant_name': variantName.toString(),
          'producttype': productType
        }
      }
    };

    if (AuthDetails.isUserLogin()) {
      var response = await BasicProvider("public/cart/create")
          .postRequest(form)
          .catchError(handleError);

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
          found = true;
          break;
        }
      }
      if (!found) {
        guestUserCartList.add(guestForm);
      }
      List<dynamic> cartList = guestUserCartList.toList();
      box.write('guestUserCartList', cartList);
      getCartProduct();
    }
  }

  Future<void> updateQuantity(int index, int quantity) async {
    if (quantity < 1) return;
    var product = productDetails[index];
    var variantName = AuthDetails.isUserLogin()
        ? cartProducts[index]['value']['variant_name'] ?? ''
        : guestUserCartList[index]['variant_name'] ?? '';
    var productType = AuthDetails.isUserLogin()
        ? cartProducts[index]['value']['producttype'] ?? 'simple'
        : guestUserCartList[index]['producttype'] ?? 'simple';

    await addToCart(
      productId: product['_id'],
      quantity: quantity,
      variantName: variantName,
      productType: productType,
    );
  }

  dynamic getVariantPrice(int index) {
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
      var response = await BasicProvider("public/coupons")
          .getRequest()
          .catchError(handleError);
      if (response == null) return;
      allCoupon.clear();
      allCoupon.addAll(response['data']);
    } catch (e) {
      print('get coupon error $e');
    }
  }

  void increment(int index) {
    if (productQuntity[index] != 10) {
      productQuntity[index]++;
      guestUserCartList[index]['quantity']++;
      gettotalAmount();
      update();
    }
  }

  void decrement(int index) {
    if (productQuntity[index] > 1) {
      productQuntity[index]--;
      // totalAmount();
      gettotalAmount();
      guestUserCartList[index]['quantity']--;

      update();
    }
  }

  Future<void> getSimilarProduct(List category) async {
    try {
      // similarProduct.clear();
      var response =
          await BasicProvider("public/product/categorywise").postRequest(
        {"categories": category},
      ).catchError(handleError);
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

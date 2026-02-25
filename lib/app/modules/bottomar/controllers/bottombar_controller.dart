import 'package:badges/badges.dart' as badges;
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BottombarController extends GetxController with BaseController {
  // late GlobalKey<ScaffoldState> key;
  var pageController = PageController();
  RxBool isLiked = false.obs;
  var box = GetStorage();
  var currentPageIndex = 0.obs;
  final isLogin = false.obs;
  final authDetails = {}.obs;
  var cart = List<dynamic>.empty().obs;
  var itemsInCart = 0.obs;

  @override
  void onInit() async {
    // box.erase();
    // key = GlobalKey();
    super.onInit();
    await AuthDetails().updateUserDetailsFromServer();
    // var user = box.read('userDetails')['userData'];
    // if (authDetails['userData'] != null) {
    //   isLogin(true);
    // }
    //getUserDetails();
    // getShippingSetting();
    // updateFirebaseToken();
    if (AuthDetails.isUserLogin()) {
      getShippingSetting();
    }
    // onRefreshToken();

    // print(box.read('token')['customer']);
    // var boxCart = box.read("cart");
    // if (boxCart != null) {}
  }

  void getShippingSetting() async {
    try {
      var response = await BasicProvider("public/shipping-detail")
          .getRequest()
          .catchError(handleError);
      if (response == null) return;
      var form = {
        'email': response['value']['email'],
        'password': response['value']['password']
      };
      var response2 = await BasicProvider("public/orders/shippinglogin")
          .postRequest(form)
          .catchError(handleError);
      if (response2 == null) return;
    } catch (e) {
      print('get coupon error $e');
    }
  }

  Future<void> addToWishList(item, selectedVariation) async {
    HelperFunctions().showOverlayLoader();
    var strVariation = "";
    if (selectedVariation.length > 0) {
      selectedVariation.forEach((key, value) {
        if (strVariation == "") {
          strVariation = value;
        } else {
          strVariation = "$strVariation/$value";
        }
      });
    }

    var form = FormData({
      'product_id': item['product_id'] ?? item['id'],
      'image': item['image'],
      'producttype': item["producttype"] ?? item["type"],
      'variant': strVariation
    });

    var response = await BasicProvider('public/product/add-to-wishlist')
        .postRequest(form)
        .catchError(handleError);
    print(response);
    if (response == null) return;
    Get.until((route) => !Get.isDialogOpen!);
    // ShoppingHelper.defaultdialogbox(
    //     'Product Added to Wishlist'.tr, themePrimaryColor);
    Future.delayed(Duration(seconds: 1), (() => Get.back()));
  }

  void onTabChange(value) {
    currentPageIndex.value = value;
    pageController.jumpToPage(value);
    update();
  }

  void goToCart() {
    // var cartList = box.read("cart");
    // if (cartList.isNotEmpty) {
    //   // Get.toNamed(Routes.CART);
    // } else {
    //   Get.to(() => const EmptycartView());
    // }
  }

  @override
  void onReady() {
    super.onReady();
  }

  void addToCart(dynamic item) {
    // ShoppingCartController().addToCart(item);
  }

  cartbadge({Widget? child, required int badgeNumber, VoidCallback? onTap}) {
    // if (Get.find<CartController>().cartProducts.isEmpty) {
    //   return Container(child: child);
    // } else {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        child: badges.Badge(
            badgeAnimation: const badges.BadgeAnimation.fade(
                animationDuration: Duration(seconds: 1),
                loopAnimation: false,
                curve: Curves.fastOutSlowIn),
            badgeStyle: const badges.BadgeStyle(padding: EdgeInsets.all(4.0)),
            badgeContent: Text(badgeNumber.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            child: child),
      ),
    );
    // }
  }

  @override
  void onClose() {
    pageController.dispose(); // Don't forget to dispose
    super.onClose();
  }

  Future<void> logout() async {
    // var form = FormData({});
    // var response =
    //     await BasicProvider("logout").postRequest(form).catchError(handleError);
    // if (response == null) return;
    box.erase();
    isLogin(false);
    isOtpLogin
        ? Get.offAllNamed(Routes.MOBILELOGIN)
        : Get.offAllNamed(Routes.LOGIN);
  }

  getUserDetails() async {
    // var details = AuthDetails.getUserDetails();
    // if (details != null) {
    //   var usertoken = AuthDetails.getUserDetails();
    //   final f = await AuthDetails().updateUserDetailsFromServer();
    //   print(f);
    //   // authDetails.addAll();
    // }

    try {
      if (AuthDetails.isUserLogin()) {
        var userBoxData = box.read('userData');
        if (userBoxData != null) {
          var userDetails = await AuthDetails().updateUserDetailsFromServer();
          authDetails.addAll(userDetails);
        }
      }
    } catch (e) {
      print('bottom bar controller error $e');
    }
  }
}

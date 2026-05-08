import 'package:badges/badges.dart' as badges;
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/firebase_notification.dart';
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

  @override
  void onInit() async {
    super.onInit();

    await AuthDetails().updateUserDetailsFromServer();

    // Always fetch cart — CartService handles guest (local) vs logged-in (API)
    CartService.to.fetchCart();
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

  void onTabChange(value) {
    currentPageIndex.value = value;
    pageController.jumpToPage(value);
    update();
  }

  @override
  void onReady() {
    super.onReady();
  }

  void addToCart(dynamic item) {
    // ShoppingCartController().addToCart(item);
  }

  cartbadge({Widget? child, required int badgeNumber, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        child: badges.Badge(
            showBadge: badgeNumber > 0,
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
  }

  @override
  void onClose() {}

  Future<void> logout() async {
    // var form = FormData({});
    // var response = await BasicProvider("auth/logout")
    //     .postRequest(form)
    //     .catchError(handleError);
    // print("logout response $response");
    // if (response == null) return;
    
    // Cleanup Firebase topics before clearing storage
    await FirebaseHelpers.afterLogoutUnsubscribe();
    
    box.erase();
    isLogin(false);
    isOtpLogin
        ? Get.offAllNamed(Routes.MOBILELOGIN)
        : Get.offAllNamed(Routes.LOGIN);
  }
}

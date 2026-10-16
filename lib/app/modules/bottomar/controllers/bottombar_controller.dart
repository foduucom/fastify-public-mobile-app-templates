import 'package:foduu_ecommerce/services/api_cache.dart';
import 'package:badges/badges.dart' as badges;
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/firebase_notification.dart';
import 'package:foduu_ecommerce/app/data/services/session_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:foduu_ecommerce/app/modules/shop/controllers/shop_controller.dart';

class BottombarController extends GetxController with BaseController {
  // late GlobalKey<ScaffoldState> key;
  var pageController = PageController();
  RxBool isLiked = false.obs;
  var box = GetStorage();
  var currentPageIndex = 0.obs;
  final isLogin = false.obs;
  final authDetails = {}.obs;
  final List<int> tabHistory = [0];

  @override
  void onInit() async {
    super.onInit();

    if (Get.arguments != null &&
        Get.arguments is Map &&
        Get.arguments['index'] != null) {
      final idx = Get.arguments['index'];
      if (idx is int) {
        currentPageIndex.value = idx;
        tabHistory.clear();
        tabHistory.add(idx);
        pageController = PageController(initialPage: idx);
      }
      if (idx == 3 && Get.arguments['shopArguments'] != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ShopController shopController =
              Get.isRegistered<ShopController>()
                  ? Get.find<ShopController>()
                  : Get.put(ShopController());
          shopController.applyArguments(Get.arguments['shopArguments']);
        });
      }
    }

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

  void onTabChange(int value, {bool recordHistory = true}) {
    if (recordHistory && (tabHistory.isEmpty || tabHistory.last != value)) {
      tabHistory.add(value);
    }
    currentPageIndex.value = value;
    if (pageController.hasClients) {
      pageController.jumpToPage(value);
    }
    update();
  }

  bool popTabHistory() {
    if (tabHistory.length > 1) {
      tabHistory.removeLast();
      final prevTab = tabHistory.last;
      onTabChange(prevTab, recordHistory: false);
      return true;
    }
    return false;
  }

  void openShopWithCategory(Map<String, dynamic> args) {
    onTabChange(3);
    final ShopController shopController = Get.isRegistered<ShopController>()
        ? Get.find<ShopController>()
        : Get.put(ShopController());
    shopController.applyArguments(args);
    Get.until((route) => route.settings.name == Routes.BOTTOMBAR || route.isFirst);
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
    final userData = box.read('userData');
    final userId = userData is Map ? userData['_id']?.toString() : null;
    final otpLogin = isOtpLogin;

    // Local sign-out first; Firebase cleanup is fire-and-forget so an
    // unreachable Firebase can never block the user from logging out.
    await SessionService.clearLocalSession();
    SessionService.unsubscribeFromPushInBackground(userId);
    isLogin(false);
    otpLogin
        ? Get.offAllNamed(Routes.MOBILELOGIN)
        : Get.offAllNamed(Routes.LOGIN);
  }
}

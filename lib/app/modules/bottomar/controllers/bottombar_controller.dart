import 'dart:async';
import 'package:zouhi/app/data/services/notification_service.dart';
import 'package:zouhi/app/data/services/session_service.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:get/get.dart';

// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zouhi/app/modules/auth/token_manager.dart';
import 'package:zouhi/app/modules/Profie/profile/controllers/profile_controller.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:zouhi/app/modules/shop/controllers/shop_controller.dart';

import 'package:zouhi/constants/theme_ext.dart';

class BottombarController extends GetxController
    with BaseController, WidgetsBindingObserver {
  // late GlobalKey<ScaffoldState> key;
  var pageController = PageController();
  RxBool isLiked = false.obs;
  var box = GetStorage();
  var currentPageIndex = 0.obs;
  final isLogin = false.obs;
  final isLoggingOut = false.obs;
  final authDetails = {}.obs;
  var cart = List<dynamic>.empty().obs;
  var itemsInCart = 0.obs;

  var undreadNotificatoin = 0.obs;
  var userData = {};

  var saap_discountPercentage = 0.0.obs;

  /// Safely switch to one of the 5 faces of BottombarView from anywhere in the app:
  /// 0 = Home, 1 = Shop, 2 = Cart, 3 = Wishlist, 4 = Profile
  static void switchTab(int index, {Map<String, dynamic>? arguments}) {
    if (Get.isRegistered<BottombarController>()) {
      final controller = Get.find<BottombarController>();

      // Dismiss dialogs if open
      if (Get.isDialogOpen == true) {
        Get.until((route) => !Get.isDialogOpen!);
      }

      // Pop back to BottombarView if there are stacked routes on top
      Get.until((route) => route.settings.name == Routes.BOTTOMBAR || route.isFirst);

      // If switching to Shop (Tab 1), apply arguments or clear filters for clean view
      if (index == 1) {
        if (!Get.isRegistered<ShopController>()) {
          Get.put(ShopController());
        }
        final shop = Get.find<ShopController>();
        if (arguments != null) {
          shop.applyArguments(arguments, refresh: true);
        } else {
          shop.clearAllFilters();
        }
      }

      controller.onTabChange(index);
    } else {
      Get.offAllNamed(Routes.BOTTOMBAR, arguments: {
        'pageIndex': index,
        if (arguments != null) ...arguments,
      });
    }
  }

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SessionService.revalidate();
    }
  }

  @override
  void onInit() async {
    if (Get.arguments != null && Get.arguments is Map) {
      final index = Get.arguments['pageIndex'];
      if (index is int) {
        currentPageIndex.value = index;
        pageController = PageController(initialPage: index);
        if (index == 1 && Get.isRegistered<ShopController>()) {
          Get.find<ShopController>().applyArguments(
              Map<String, dynamic>.from(Get.arguments),
              refresh: true);
        }
      }
    }
    super.onInit();
    // var user = box.read('userDetails')['userData'];
    // if (authDetails['userData'] != null) {
    //   isLogin(true);
    // }
    if (AuthDetails.isUserLogin()) {
      await getUserDetails();
      userData = box.read('userData') ?? {};
      getShippingSetting();
      updateNotificatoinToken();
      requestNotificationPermissions();
    }
    //getSaapDiscount();

    // onRefreshToken();

    // print(box.read('token')['customer']);
    // var boxCart = box.read("cart");
    // if (boxCart != null) {}
  }

  Future<void> getNotificationCount() async {
    try {
      var response = await BasicProvider("frontend/notifications/count")
          .getRequest()
          .catchError(handleError);

      if (response == null) return;
      undreadNotificatoin.value = response;
    } catch (e) {
      print('get firebase token error $e');
    }
  }

  void getShippingSetting() async {
    try {
      // var response = await BasicProvider("public/shipping-detail")
      //     .getRequest()
      //     .catchError(handleError);
      // if (response == null ||
      //     response is! Map ||
      //     response['value'] == null ||
      //     response['value'] is! Map) return;
      // var form = {
      //   'email': response['value']['email'],
      //   'password': response['value']['password']
      // };
      // var response2 = await BasicProvider("public/orders/shippinglogin")
      //     .postRequest(form)
      //     .catchError(handleError);
      // if (response2 == null) return;
    } catch (e) {
      print('get coupon error $e');
    }
  }

  // void getSaapDiscount() async {
  //   try {
  //     var response = await BasicProvider("public/settings/saap-code")
  //         .getRequest()
  //         .catchError(handleError);

  //     print(response);
  //     // if (response == null) return;

  //     if (response != null && response is Map && response['value'] != null) {
  //       saap_discountPercentage.value =
  //           double.parse((response['value'] ?? 0.0).toString());
  //     }
  //   } catch (e) {
  //     print('get coupon error $e');
  //   }
  // }

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

  void addToCart(dynamic item) {
    // ShoppingCartController().addToCart(item);
  }

  cartbadge({Widget? child, required int? badgeNumber, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        child: badges.Badge(
            showBadge:
                badgeNumber != null && badgeNumber > 0, // Only show if > 0

            badgeAnimation: const badges.BadgeAnimation.fade(
                animationDuration: Duration(seconds: 1),
                loopAnimation: false,
                curve: Curves.fastOutSlowIn),
            badgeStyle: const badges.BadgeStyle(
                badgeColor: themeRedColor, padding: EdgeInsets.all(4.0)),
            badgeContent: Text(badgeNumber.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            child: child),
      ),
    );
  }

  Future<void> logout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;
    try {
      try {
        await BasicProvider("auth/logout")
            .postRequest({}).timeout(const Duration(seconds: 8));
      } catch (e) {
        print("Backend logout error: $e");
      }
      // Fire-and-forget: Firebase can hang when unreachable and must never
      // block the local logout.
      unawaited(NotificationService.unsubscribeFromAllTopics());
      final otpLogin = isOtpLogin;
      try {
        Get.delete<ProfileController>(force: true);
        Get.delete<BottombarController>(force: true);
        Get.delete<CartController>(force: true);
        Get.delete<WishlistController>(force: true);
        Get.delete<HomepageController>(force: true);
      } catch (_) {}
      await box.erase();
      await TokenManager.clearTokens();
      isLogin(false);
      HelperFunctions().showSnackBarSuccess("Logged out successfully");
      otpLogin
          ? Get.offAllNamed(Routes.MOBILELOGIN)
          : Get.offAllNamed(Routes.LOGIN);
    } finally {
      isLoggingOut.value = false;
    }
  }

  void confirmAndLogout(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        decoration: BoxDecoration(
          color: context.themeWhiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: context.themeRedColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: context.themeRedColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Log Out',
                style: Latofont.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.themetitleColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to log out of your account?',
                textAlign: TextAlign.center,
                style: Latofont.copyWith(
                  fontSize: 14,
                  color: context.themeSecondrytext,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: context.themegreyColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: Latofont.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.themetitleColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: isLoggingOut.value
                            ? null
                            : () async {
                                Get.back();
                                await logout();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.themeRedColor,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoggingOut.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Log Out',
                                style: Latofont.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> getUserDetails() async {
    try {
      if (AuthDetails.isUserLogin()) {
        var userDetails = await AuthDetails().updateUserDetailsFromServer();
        if (userDetails != null && userDetails is Map) {
          authDetails.addAll(userDetails.cast<dynamic, dynamic>());
        } else {
          var userBoxData = box.read('userData');
          if (userBoxData != null && userBoxData is Map) {
            authDetails.addAll(userBoxData.cast<dynamic, dynamic>());
          }
        }
      }
    } catch (e) {
      print('bottom bar controller error $e');
    }
  }

  List appTitle = [
    {"name": "Category"},
    {"name": "Shop"},
    {"name": "Wishlist"},
    {"name": "Profile"},
  ].obs;

  void onNotificationRefreshToken() {
    // Already handled automatically in NotificationService.init()
    NotificationService.saveTokenToBackend();
  }

  void updateNotificatoinToken() async {
    await NotificationService.saveTokenToBackend();
  }

  Future<void> requestNotificationPermissions() async {
    final isAllowed = await NotificationService.isNotificationAllowed();
    if (!isAllowed) {
      await NotificationService.requestPermissionToSendNotifications();
    }
  }
}

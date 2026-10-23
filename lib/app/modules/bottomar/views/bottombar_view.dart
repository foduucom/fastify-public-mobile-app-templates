import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:zouhi/app/modules/cart/views/cart_view.dart';
import 'package:zouhi/app/modules/homepage/views/home.dart';
import 'package:zouhi/app/modules/Profie/profile/views/profile_view.dart';
import 'package:zouhi/app/modules/shop/views/shop_view.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/app/modules/wishlist/views/wishlist_view.dart';
import 'package:get/get.dart';

import 'package:zouhi/components/offline_ribbon.dart';
import '../../../../../constants/theme_ext.dart';
import '../controllers/bottombar_controller.dart';

// ignore: must_be_immutable
class BottombarView extends GetView<BottombarController> {
  BottombarView({super.key});

  var cartController = Get.put(CartController());
  // var notifcationController = Get.put(NotificationsController());
  var wishListController = Get.put(WishlistController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: controller.currentPageIndex.value == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (controller.currentPageIndex.value != 0) {
            controller.onTabChange(0);
          }
        },
        child: SafeArea(
          child: Scaffold(
        body: Column(
          children: [
            const OfflineRibbon(),
            Expanded(
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: PageView(
                        controller: controller.pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          HomePageView(),
                          // Testinghome(),
                          // DemoHomePage(),
                          //CategoryView(),
                          ShopView(),
                          CartView(),
                          WishlistView(),

                          ProfileView()
                        ]),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                  color: Color.fromARGB(96, 168, 164, 164),
                  spreadRadius: 0,
                  blurRadius: 10),
            ],
          ),
          child: Obx(
            () => BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: context.colors.surface,
              unselectedItemColor: context.themeTextColor,
              selectedItemColor: context.themeTextColor,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              unselectedLabelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  height: 2,
                  color: context.themeTextColor),
              selectedLabelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  height: 2,
                  color: context.themeRedColor),
              onTap: (value) {
                controller.onTabChange(value);
              },
              currentIndex: controller.currentPageIndex.value,
              items: [
                BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/icon/fill2.svg',
                      colorFilter: ColorFilter.mode(
                          context.themeSecondrytext, BlendMode.srcIn),
                    ),
                    activeIcon: SvgPicture.asset(
                      'assets/icon/home.svg',
                      colorFilter: ColorFilter.mode(
                          context.themePrimaryColor, BlendMode.srcIn),
                    ),
                    label: 'HOME'),
                BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/icon/cateorey.svg',
                      colorFilter: ColorFilter.mode(
                          context.themeSecondrytext, BlendMode.srcIn),
                    ),
                    activeIcon: SvgPicture.asset(
                      'assets/icon/activecategory.svg',
                      colorFilter: ColorFilter.mode(
                          context.themePrimaryColor, BlendMode.srcIn),
                    ),
                    label: 'SHOP'),
                BottomNavigationBarItem(
                  icon: controller.cartbadge(
                    onTap: () {
                      controller.currentPageIndex.value = 2;
                      controller.pageController.jumpToPage(2);
                    },
                    child: SvgPicture.asset(
                      'assets/icon/bottombarcart.svg',
                      colorFilter: ColorFilter.mode(
                          context.themeSecondrytext, BlendMode.srcIn),
                    ),
                    badgeNumber: Get.find<CartController>().cartItemCount,
                  ),
                  activeIcon: controller.cartbadge(
                      onTap: () {
                        controller.currentPageIndex.value = 2;
                        controller.pageController.jumpToPage(2);
                      },
                      child: SvgPicture.asset(
                        'assets/icon/bottombarlikecart 1 (3).svg',
                        colorFilter: ColorFilter.mode(
                            context.themePrimaryColor, BlendMode.srcIn),
                      ),
                      badgeNumber: Get.find<CartController>().cartItemCount),
                  label: 'CART',
                ),
                BottomNavigationBarItem(
                  icon: controller.cartbadge(
                    onTap: () {
                      controller.currentPageIndex.value = 3;
                      controller.pageController.jumpToPage(3);
                    },
                    child: SvgPicture.asset(
                      'assets/icon/bottomicon.svg',
                      colorFilter: ColorFilter.mode(
                          context.themeSecondrytext, BlendMode.srcIn),
                    ),
                    badgeNumber: wishListController.wishlistProductIds.length,
                  ),
                  activeIcon: controller.cartbadge(
                    onTap: () {
                      controller.currentPageIndex.value = 3;
                      controller.pageController.jumpToPage(3);
                    },
                    child: SvgPicture.asset(
                      'assets/icon/bottomlikeicon.svg',
                      colorFilter: ColorFilter.mode(
                          context.themePrimaryColor, BlendMode.srcIn),
                    ),
                    badgeNumber: wishListController.wishlistProductIds.length,
                  ),
                  label: 'WISHLIST',
                ),
                BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/icon/bottomprofile.svg',
                      colorFilter: ColorFilter.mode(
                          context.themeSecondrytext, BlendMode.srcIn),
                    ),
                    activeIcon: SvgPicture.asset(
                      'assets/icon/bottomactiveprofile.svg',
                      colorFilter: ColorFilter.mode(
                          context.themePrimaryColor, BlendMode.srcIn),
                    ),
                    label: 'PROFILE'),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
  }
}

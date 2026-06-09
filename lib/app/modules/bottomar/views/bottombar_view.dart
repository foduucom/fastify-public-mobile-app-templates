import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/home_view.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/modules/cart/views/cart_view.dart';
import 'package:foduu_ecommerce/app/modules/category/views/category_view.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/views/profile_view.dart';
import 'package:foduu_ecommerce/app/modules/notification/controller/notification_controller.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/views/wishlist_view.dart';
import 'package:get/get.dart';

import '../../../../../constants/constants.dart';
import '../controllers/bottombar_controller.dart';

// ignore: must_be_immutable
class BottombarView extends GetView<BottombarController> {
  BottombarView({super.key});

  var cartController = Get.put(CartController());
  var notifcationController = Get.put(NotificationsController());
  var wishListController = Get.put(WishlistController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to quit?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        if (shouldExit == true) SystemNavigator.pop();
      },
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox.expand(
              child: PageView(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // HomepageView(),
                    Testinghome(),
                    // DemoHomePage(),
                    CategoryView(),
                    CartView(),
                    WishlistView(),

                    ProfileView()
                  ]),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
                  // color: Color.fromARGB(96, 168, 164, 164),
                  spreadRadius: 0,
                  blurRadius: 10),
            ],
          ),
          child: Obx(
            () => BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              // unselectedItemColor: Theme.of(context).colorScheme.secondary,
              // selectedItemColor: Theme.of(context).colorScheme.primary,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 10,
                height: 1.4,
              ),
              selectedLabelStyle: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 10,
                height: 1.4,
              ),
              onTap: (value) {
                controller.onTabChange(value);
              },
              currentIndex: controller.currentPageIndex.value,
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icon/fill2.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    'assets/icon/home.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'HOME',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icon/cateorey.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    'assets/icon/activecategory.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'CATEGORY',
                ),
                BottomNavigationBarItem(
                  icon: controller.cartbadge(
                    onTap: () {
                      controller.currentPageIndex.value = 2;
                      controller.pageController.jumpToPage(2);
                    },
                    child: SvgPicture.asset(
                      'assets/icon/bottombarcart.svg',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                    badgeNumber: CartService.to.cartItemCount,
                  ),
                  activeIcon: controller.cartbadge(
                    onTap: () {},
                    child: SvgPicture.asset(
                      'assets/icon/cartfilledicon.svg',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    badgeNumber: CartService.to.cartItemCount,
                  ),
                  label: 'CART',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icon/bottomicon.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    'assets/icon/bottomlikeicon.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'WISHLIST',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icon/bottomprofile.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    'assets/icon/bottomactiveprofile.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'PROFILE',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/modules/cart/views/cart_view.dart';
import 'package:foduu_ecommerce/app/modules/shop/views/shop_view.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/home_page_view.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/material/responsive_bottom_nav.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/material/responsive_common_header.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/views/profile_view.dart';
import 'package:foduu_ecommerce/app/modules/notification/controller/notification_controller.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/views/wishlist_view.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/components/home_component/customDrawer.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:get/get.dart';

import '../../../../../constants/constants.dart';
import '../controllers/bottombar_controller.dart';

// ignore: must_be_immutable
class BottombarView extends GetView<BottombarController> {
  BottombarView({super.key});

  ColorScheme get colorScheme => Theme.of(Get.context!).colorScheme;
  TextTheme get textTheme => Theme.of(Get.context!).textTheme;

  var cartController = Get.put(CartController());
  var notifcationController = Get.put(NotificationsController());
  var wishListController = Get.put(WishlistController());
  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;

    return Scaffold(
      drawer: Drawer(
        child: AuthDetails.isUserLogin()
            ? const CustomDrawer()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: Text(
                    'Login to View Profile',
                    style: txtTheme().displayMedium,
                  )),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: Get.width * 0.6,
                    child: AppButton(
                        itemText: 'Login',
                        keypressEvent: () {
                          Get.offAllNamed(Routes.LOGIN);
                        }),
                  ),
                ],
              ),
      ),
      body: SafeArea(
        bottom: false,
        child: Builder(
          builder: (scaffoldContext) => Column(
          children: [
            // ONE COMMON HEADER FOR HOME PAGE
            Obx(() {
              // Header for Home (0); other pages provide their own dedicated AppBars
              final index = controller.currentPageIndex.value;
              if (index == 0) {
                return ResponsiveCommonHeader(
                  width: width,
                  height: height,
                  onSearchTap: () => Get.toNamed(Routes.SEARCH),
                  onCartTap: () => controller.onTabChange(4),
                  onMessageTap: () => Scaffold.of(scaffoldContext).openDrawer(),
                  onNotificationTap: () => Get.toNamed(Routes.NOTIFICATION),
                );
              }
              // Hide common header for Account (1), Shop (2), Wishlist (3), Cart (4)
              return const SizedBox.shrink();
            }),

            // PageView takes remaining space
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  HomePageView(),
                  ProfileView(),
                  const ShopView(),
                  WishlistView(),
                  CartView(),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Obx(() {
      return ResponsiveBottomNav(
        height: Get.height,
        currentIndex: controller.currentPageIndex.value,
        onTap: controller.onTabChange,
        backgroundColor: context.surfaceColor,
        activeColor: colorScheme.primary,
        inactiveColor: context.onSurfaceVariantColor,
        borderColor: context.outlineColor,
        items: [
          const BottomNavItem(
            activeIcon: Icons.home_rounded,
            inactiveIcon: Icons.home_outlined,
            label: 'Home',
          ),
          const BottomNavItem(
            activeIcon: Icons.person_rounded,
            inactiveIcon: Icons.person_outline_rounded,
            label: 'Account',
          ),
          const BottomNavItem(
            activeIcon: Icons.storefront_rounded,
            inactiveIcon: Icons.storefront_outlined,
            label: 'Shop',
          ),
          BottomNavItem(
            activeIcon: Icons.favorite_rounded,
            inactiveIcon: Icons.favorite_outline_rounded,
            label: 'Wishlist',
            badgeCount: wishListController.wishlistItems.length,
          ),
          BottomNavItem(
            activeIcon: Icons.shopping_bag_rounded,
            inactiveIcon: Icons.shopping_bag_outlined,
            label: 'Cart',
            badgeCount: cartController.cartItems.length,
          ),
        ],
      );
    });
  }
}

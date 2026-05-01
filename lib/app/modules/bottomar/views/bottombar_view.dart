import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/modules/cart/views/cart_view.dart';
import 'package:foduu_ecommerce/app/modules/category/views/category_view.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/home_page_view.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/material/responsive_bottom_nav.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/material/responsive_common_header.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/views/profile_view.dart';
import 'package:foduu_ecommerce/app/modules/notification/controller/notification_controller.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/views/wishlist_view.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ONE COMMON HEADER FOR ALL PAGES
            Obx(() {
              // Show header for first 3 tabs only (Home, Category, Wishlist)
              if (controller.currentPageIndex.value <= 2) {
                return ResponsiveCommonHeader(
                  width: width,
                  height: height,
                  onSearchTap: () => Get.toNamed(Routes.SEARCH),
                  onCartTap: () => Get.toNamed(Routes.CART),
                  onMessageTap: () => print("Message tapped"),
                  onNotificationTap: () => Get.toNamed(Routes.NOTIFICATION),
                );
              }
              // Hide header for Profile page (index 3)
              return const SizedBox.shrink();
            }),

            // PageView takes remaining space
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  HomePageView(),
                  CategoryView(),
                  WishlistView(),
                  ProfileView(),
                ],
              ),
            ),
          ],
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
            activeIcon: Icons.grid_view_rounded,
            inactiveIcon: Icons.grid_view_outlined,
            label: 'Category',
          ),
          BottomNavItem(
            activeIcon: Icons.favorite_rounded,
            inactiveIcon: Icons.favorite_outline_rounded,
            label: 'Wishlist',
            badgeCount: wishListController.wishlistItems.length,
          ),
          const BottomNavItem(
            activeIcon: Icons.person_rounded,
            inactiveIcon: Icons.person_outline_rounded,
            label: 'Profile',
          ),
        ],
      );
    });
  }
}

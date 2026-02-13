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

  var cartController = Get.put(CartController());
  var notifcationController = Get.put(NotificationsController());
  var wishListController = Get.put(WishlistController());

  // @override
  // Widget build(BuildContext context) {
  //   return SafeArea(
  //     child: Scaffold(
  //       body: Stack(
  //         children: [
  //           SizedBox.expand(
  //             child: PageView(
  //                 controller: controller.pageController,
  //                 physics: const NeverScrollableScrollPhysics(),
  //                 children: [
  //                   // HomepageView(),
  //                   HomePageView(),
  //                   // DemoHomePage(),
  //                   CategoryView(),
  //                   CartView(),
  //                   WishlistView(),

  //                   ProfileView()
  //                 ]),
  //           ),
  //         ],
  //       ),
  //       bottomNavigationBar: Container(
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(30),
  //           boxShadow: [
  //             BoxShadow(
  //                 color:
  //                     Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
  //                 // color: Color.fromARGB(96, 168, 164, 164),
  //                 spreadRadius: 0,
  //                 blurRadius: 10),
  //           ],
  //         ),
  //         child: Obx(
  //           () => BottomNavigationBar(
  //             type: BottomNavigationBarType.fixed,
  //             // unselectedItemColor: Theme.of(context).colorScheme.secondary,
  //             // selectedItemColor: Theme.of(context).colorScheme.primary,
  //             showSelectedLabels: true,
  //             showUnselectedLabels: true,
  //             unselectedLabelStyle: const TextStyle(
  //               fontFamily: 'Lato',
  //               fontSize: 10,
  //               height: 2,
  //             ),
  //             selectedLabelStyle: const TextStyle(
  //               fontFamily: 'Lato',
  //               fontSize: 10,
  //               height: 2,
  //             ),
  //             onTap: (value) {
  //               controller.onTabChange(value);
  //             },
  //             currentIndex: controller.currentPageIndex.value,
  //             items: [
  //               BottomNavigationBarItem(
  //                 icon: SvgPicture.asset(
  //                   'assets/icon/fill2.svg',
  //                   colorFilter: ColorFilter.mode(
  //                     Theme.of(context).colorScheme.onSurfaceVariant,
  //                     BlendMode.srcIn,
  //                   ),
  //                 ),
  //                 activeIcon: SvgPicture.asset(
  //                   'assets/icon/home.svg',
  //                   colorFilter: ColorFilter.mode(
  //                     Theme.of(context).colorScheme.primary,
  //                     BlendMode.srcIn,
  //                   ),
  //                 ),
  //                 label: 'HOME',
  //               ),
  //               BottomNavigationBarItem(
  //                 icon: SvgPicture.asset(
  //                   'assets/icon/cateorey.svg',
  //                   colorFilter: ColorFilter.mode(
  //                     Theme.of(context).colorScheme.onSurfaceVariant,
  //                     BlendMode.srcIn,
  //                   ),
  //                 ),
  //                 activeIcon: SvgPicture.asset(
  //                   'assets/icon/activecategory.svg',
  //                   colorFilter: ColorFilter.mode(
  //                     Theme.of(context).colorScheme.primary,
  //                     BlendMode.srcIn,
  //                   ),
  //                 ),
  //                 label: 'CATEGORY',
  //               ),
  //               BottomNavigationBarItem(
  //                 icon: controller.cartbadge(
  //                   onTap: () {
  //                     controller.currentPageIndex.value = 2;
  //                     controller.pageController.jumpToPage(2);
  //                   },
  //                   child: SvgPicture.asset(
  //                     'assets/icon/bottombarcart.svg',
  //                     colorFilter: ColorFilter.mode(
  //                       Theme.of(context).colorScheme.onSurfaceVariant,
  //                       BlendMode.srcIn,
  //                     ),
  //                   ),
  //                   badgeNumber:
  //                       Get.find<CartController>().productDetails.length,
  //                 ),
  //                 activeIcon: controller.cartbadge(
  //                   onTap: () {},
  //                   child: SvgPicture.asset(
  //                     'assets/icon/bottombarlikecart.svg',
  //                     colorFilter: ColorFilter.mode(
  //                       Theme.of(context).colorScheme.primary,
  //                       BlendMode.srcIn,
  //                     ),
  //                   ),
  //                   badgeNumber:
  //                       Get.find<CartController>().productDetails.length,
  //                 ),
  //                 label: 'CART',
  //               ),
  //               BottomNavigationBarItem(
  //                 icon: SvgPicture.asset(
  //                   'assets/icon/bottomicon.svg',
  //                   colorFilter: ColorFilter.mode(
  //                     Theme.of(context).colorScheme.onSurfaceVariant,
  //                     BlendMode.srcIn,
  //                   ),
  //                 ),
  //                 activeIcon: SvgPicture.asset(
  //                   'assets/icon/bottomlikeicon.svg',
  //                   colorFilter: ColorFilter.mode(
  //                     Theme.of(context).colorScheme.primary,
  //                     BlendMode.srcIn,
  //                   ),
  //                 ),
  //                 label: 'WISHLIST',
  //               ),
  //               BottomNavigationBarItem(
  //                 icon: SvgPicture.asset(
  //                   'assets/icon/bottomprofile.svg',
  //                   colorFilter: ColorFilter.mode(
  //                     Theme.of(context).colorScheme.onSurfaceVariant,
  //                     BlendMode.srcIn,
  //                   ),
  //                 ),
  //                 activeIcon: SvgPicture.asset(
  //                   'assets/icon/bottomactiveprofile.svg',
  //                   colorFilter: ColorFilter.mode(
  //                     Theme.of(context).colorScheme.primary,
  //                     BlendMode.srcIn,
  //                   ),
  //                 ),
  //                 label: 'PROFILE',
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // ONE COMMON HEADER FOR ALL PAGES
            Obx(() {
              // Show header for first 3 tabs only (Home, Category, Wishlist)
              if (controller.currentPageIndex.value <= 2) {
                return ResponsiveCommonHeader(
                  width: width,
                  height: height,
                  onSearchTap: () => print("Search tapped"),
                  onCartTap: () => print("Cart tapped"),
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
                  // REMOVE HEADERS FROM ALL THESE PAGES
                  HomePageView(),
                  CategoryView(),
                  WishlistView(),
                  ProfileView(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Obx(() {
      return ResponsiveBottomNav(
        height: Get.height,
        currentIndex: controller.currentPageIndex.value,
        onTap: controller.onTabChange,
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        activeColor: DefaultThemeColors.mainprimary,
        inactiveColor: DefaultThemeColors.darkmain,
        borderColor: DefaultThemeColors.darklight,
        items: const [
          BottomNavItem(
            activeIcon: Icons.home_filled,
            inactiveIcon: Icons.home_outlined,
            label: 'Home',
          ),
          BottomNavItem(
            activeIcon: Icons.category,
            inactiveIcon: Icons.category_outlined,
            label: 'Category',
          ),
          BottomNavItem(
            activeIcon: Icons.favorite,
            inactiveIcon: Icons.favorite_border,
            label: 'Wishlist',
          ),
          BottomNavItem(
            activeIcon: Icons.person,
            inactiveIcon: Icons.person_outline,
            label: 'Profile',
          ),
        ],
      );
    });
  }
}

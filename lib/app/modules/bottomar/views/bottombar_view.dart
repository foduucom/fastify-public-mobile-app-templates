import 'package:flutter/material.dart';
import 'package:new_fastify_template/app/modules/homepage/views/home_view.dart';
import '../../explore/view/explore_view.dart';
import '../../homepage/controllers/home_controller2.dart';
import '../../homepage/views/view.dart';
import '/core/services/cartServcie.dart';
import 'package:flutter_svg/svg.dart';
// ← ADD
import '/app/modules/cart/controllers/cart_controller.dart';
import '/app/modules/cart/views/cart_view.dart';
import '/app/modules/category/views/category_view.dart';
import '/app/modules/category/controllers/category_controller.dart';
import '/app/modules/Profie/profile/views/profile_view.dart';
import '/app/modules/notification/controller/notification_controller.dart';
import '/app/modules/wishlist/controllers/wishlist_controller.dart';
import '/app/modules/wishlist/views/wishlist_view.dart';
import 'package:get/get.dart';
import '../../../../../constants/constants.dart';
import '../controllers/bottombar_controller.dart';

// ignore: must_be_immutable
class BottombarView extends GetView<BottombarController> {
  BottombarView({super.key});

  // ── Register ALL tab controllers here ──────────────────────────────

  final cartController = Get.put(CartController());
  final notifcationController = Get.put(NotificationsController());
  final wishListController = Get.put(WishlistController());
  final categoryController = Get.put(CategoryController());
  //final homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SizedBox.expand(
        child: PageView(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // ← use const where possible
            //const HomeView(),
            Testinghome(),
            //const ExploreView(),
            CategoryView(),
            const CartView(),
            WishlistView(),
            ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Obx(
          () => BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: colorScheme.primary,
            unselectedItemColor: colorScheme.onSurfaceVariant,
            currentIndex: controller.currentPageIndex.value,
            onTap: (value) => controller.onTabChange(value),
            items: [
              // ── Home ─────────────────────────────────────────────
              BottomNavigationBarItem(
                label: '',
                icon: SvgPicture.asset(
                  'assets/icon/fill2.svg',
                  colorFilter: ColorFilter.mode(
                      colorScheme.onSurfaceVariant, BlendMode.srcIn),
                ),
                activeIcon: SvgPicture.asset(
                  'assets/icon/home.svg',
                  colorFilter:
                      ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
                ),
              ),

              // ── Category ─────────────────────────────────────────
              BottomNavigationBarItem(
                label: '',
                icon: SvgPicture.asset(
                  'assets/icon/Discovery.svg',
                  colorFilter: ColorFilter.mode(
                      colorScheme.onSurfaceVariant, BlendMode.srcIn),
                ),
                activeIcon: SvgPicture.asset(
                  'assets/icon/Discovery.svg',
                  colorFilter:
                      ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
                ),
              ),

              // ── Cart (with badge) ─────────────────────────────────
              BottomNavigationBarItem(
                label: '',
                icon: controller.cartbadge(
                  onTap: () {
                    controller.currentPageIndex.value = 2;
                    controller.pageController.jumpToPage(2);
                  },
                  child: SvgPicture.asset(
                    'assets/icon/cart.svg',
                    colorFilter: ColorFilter.mode(
                        colorScheme.onSurfaceVariant, BlendMode.srcIn),
                  ),
                  badgeNumber: CartService.to.cartItemCount,
                ),
                activeIcon: controller.cartbadge(
                  onTap: () {},
                  child: SvgPicture.asset(
                    'assets/icon/cart_fill.svg',
                    colorFilter:
                        ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
                  ),
                  badgeNumber: CartService.to.cartItemCount,
                ),
              ),

              // ── Wishlist ──────────────────────────────────────────
              BottomNavigationBarItem(
                label: '',
                icon: SvgPicture.asset(
                  'assets/icon/heart.svg', // ← use .svg not .png
                  colorFilter: ColorFilter.mode(
                      colorScheme.onSurfaceVariant, BlendMode.srcIn),
                ),
                activeIcon: SvgPicture.asset(
                  'assets/icon/like.svg', // ← filled heart variant
                  colorFilter:
                      ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
                ),
              ),

              // ── Profile ───────────────────────────────────────────
              BottomNavigationBarItem(
                label: '',
                icon: SvgPicture.asset(
                  'assets/icon/bottomprofile.svg',
                  colorFilter: ColorFilter.mode(
                      colorScheme.onSurfaceVariant, BlendMode.srcIn),
                ),
                activeIcon: SvgPicture.asset(
                  'assets/icon/bottomactiveprofile.svg',
                  colorFilter:
                      ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

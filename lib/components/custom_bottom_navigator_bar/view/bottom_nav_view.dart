import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/modules/ai/view/ai_view.dart';
import '../../../app/modules/cart/controller/cart_controller.dart';
import '../../../app/modules/cart/view/cart_view.dart';
import '../../../app/modules/ordre_history/controller/order_controller.dart';
import '../../../app/modules/ordre_history/model/model.dart';
import '../../../app/modules/ordre_history/view/order_history_view.dart';
import '../../../app/modules/profile/controller/profile_controller.dart';
import '../../../app/modules/profile/view/profile_view.dart';
import '../../../app/modules/wishlist/view/wishlist_view.dart';
import '/app/modules/homepage/views/home_view.dart';
import '/app/modules/homepage/controllers/homepage_controller.dart';


import '../controller/bottom_nav_controller.dart';

class BottomNavView extends GetView<BottomNavController> {
  const BottomNavView({super.key});

  Widget _buildPage(int index) {
    switch (index) {
      case 0:  return HomeView();
      case 1:  return CartView();
      case 2:  return  AiRoomoaView();
      case 3:  return WishlistView();   // ✅ uncommented
      case 4:  return ProfileView();
      default: return HomeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Register HomeController before HomeView builds
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    if (!Get.isRegistered<OrderHistoryController>()) {
      Get.put(OrderHistoryController());
    }
    if (!Get.isRegistered<CartController>()) {       // ✅ ADD
      Get.put(CartController());                     // ✅ ADD
    }


    return Obx(() => Scaffold(
      backgroundColor: const Color(0xFFEEECE8),
      extendBody: true,
      body: _buildPage(controller.selectedIndex.value),
      bottomNavigationBar: _RoomoraBottomNav(),
    ));
  }
}

// ── Custom Bottom Nav Bar ──────────────────────────────────────────
class _RoomoraBottomNav extends GetView<BottomNavController> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Obx(
              () => Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                _NavItem(
                  assetPath: 'assets/icons/ic_home.png',
                  fallbackIcon: Icons.home_outlined,
                  index: 0,
                  selectedIndex: controller.selectedIndex.value,
                  onTap: () => controller.changePage(0),
                ),

                _NavItem(
                  assetPath: 'assets/icons/ic_shop.png',
                  fallbackIcon: Icons.shopping_bag_outlined,
                  index: 1,
                  selectedIndex: controller.selectedIndex.value,
                  onTap: () => controller.changePage(1),
                ),

                _ScanButton(onTap: controller.onScanTap),

                _NavItem(
                  assetPath: 'assets/icons/ic_wishlist.png',
                  fallbackIcon: Icons.favorite_outline,
                  index: 3,
                  selectedIndex: controller.selectedIndex.value,
                  onTap: () => controller.changePage(3),
                ),

                _NavItem(
                  assetPath: 'assets/icons/ic_profile.png',
                  fallbackIcon: Icons.person_outline,
                  index: 4,
                  selectedIndex: controller.selectedIndex.value,
                  onTap: () => controller.changePage(4),
                  isProfile: true,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nav Item ───────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final String assetPath;
  final IconData fallbackIcon;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;
  final bool isProfile;

  const _NavItem({
    required this.assetPath,
    required this.fallbackIcon,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    this.isProfile = false,
  });

  bool get isSelected => selectedIndex == index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isSelected && isProfile
              ? const LinearGradient(
            colors: [Color(0xFFFFD6D6), Color(0xFFFFB3B3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isSelected && !isProfile
              ? Colors.white
              : isSelected
              ? null
              : const Color(0xFFF0EEEB),
          boxShadow: isSelected
              ? [BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )]
              : [],
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: 20,
            height: 20,
            color: isSelected
                ? const Color(0xFF1A1A1A)
                : const Color(0xFF9E9E9E),
            errorBuilder: (_, __, ___) => Icon(
              fallbackIcon,
              size: 16,
              color: isSelected
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFF9E9E9E),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Elevated Scan Button ───────────────────────────────────────────
class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -36),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:  Colors.white38,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/icons/ic_scan.png',
              width: 28,
              height: 28,
              color: const Color(0xFF1A1A1A),
              errorBuilder: (_, __, ___) => const Icon(
                Icons.qr_code_scanner,
                size: 28,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class IntroController extends GetxController {
  var pageController    = PageController();
  var selectedPageIndex = 0.obs;
  final box             = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _handleInitialRoute(); // ✅ was missing — this drives the 2s delay
  }

  @override
  void onClose() {
    pageController.dispose();
  }

  // ── Auto-navigate after splash delay ─────────────────────────────
  void _handleInitialRoute() {
    final bool hasSeenOnboarding = box.read('isIntroViewed') ?? false;
    Future.delayed(const Duration(seconds: 1), () {
      if (hasSeenOnboarding) {
        Get.offAllNamed(Routes.LOGIN);
      } else {
        Get.offNamed(Routes.ONBOARDING);
      }
    });
  }

  // ── Called by Skip / Get Started buttons ─────────────────────────
  void onProceedNext() {
    try {
      final bool isOnLastPage =
          selectedPageIndex.value + 1 == introPage.length;

      if (Get.currentRoute == Routes.ONBOARDING) {
        if (!isOnLastPage) {
          pageController.animateToPage(
            selectedPageIndex.value + 1,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        } else {
          box.write('isIntroViewed', true);
          Get.offAllNamed(Routes.LOGIN);
        }
        return;
      }

      box.write('isIntroViewed', true);
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      debugPrint('IntroController.onProceedNext error: $e');
    }
  }

  List introPage = [
    {
      "image": "assets/images/onboarding_1.png",
      "title": "Welcome to Biggest Online Store",
      "descrition": "Latest trends in clothing for women, men & kids. Find new arrivals, fashion catalogs, collections & lookbooks every week.",
    },
    {
      "image": "assets/images/onboarding_2.png",
      "title": "Perfect Pair for Everyone",
      "descrition": "500+ Brands and more than 1,00,000+ apparel and accessories. Discover what works best for you with 30 Days Return policy.",
    },
    {
      "image": "assets/images/onboarding_3.png",
      "title": "Find all New Favourites",
      "descrition": "New arrivals, fashion catalogs & collections every week. Premium Brands. Free Shipping. Secure Payments.",
    },
  ];
}
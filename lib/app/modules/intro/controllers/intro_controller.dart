import 'package:flutter/cupertino.dart';
import '/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class IntroController extends GetxController {
  var pageController = PageController();
  var selectedPageIndex = 0.obs;
  final box = GetStorage();

  @override
  void onInit() {
    print('ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd');
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  void onProceedNext() {
    try {
      box.write("isIntroViewed", true);
      Get.offNamed(Routes.CREATE_ACCOUNT);
    } catch (e) {
      print('home controller $e');
    }
  }

  List introPage = [
    {
      "image": "assets/lotti/83374-ecommerce.json",
      "title": "Welcome to Biggest Online Store",
      "descrition":
          "Latest trends in clothing for women, men & kids at Multikart. Find new arrivals​, fashion catalogs, collections & lookbooks every week.",
    },
    {
      "image": "assets/lotti/74384-swipe-for-shopping.json",
      "title": "Pefect Pair for Everyone",
      "descrition":
          "500+ Brands and more than 1,00,000 +  apparel and accessories. Discover what works best for you with  30 Days Return policy.",
    },
    {
      "image": "assets/lotti/33897-workout.json",
      "title": "Find all New Favourites",
      "descrition":
          "new arrivals​, fashion catalogs & collections every week. Premium Brands. Free Shipping Available. Hassle Free Installations. Secure Payments.",
    }
  ];
}

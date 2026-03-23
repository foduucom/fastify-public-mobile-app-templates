import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';


class OnboardingItem {
  final String imagePath;
  final String title;
  final String subtitle;

  const OnboardingItem({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

class OnboardingController extends GetxController {
  final pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<OnboardingItem> pages = const [
    OnboardingItem(
      imagePath: 'assets/images/onboarding_1.png',
      title: 'Discover Your\nDream Space',
      subtitle:
      'Explore thousands of furniture pieces\ncurated just for your home.',
    ),
    OnboardingItem(
      imagePath: 'assets/images/onboarding_2.png',
      title: 'Effortless Furniture\nExploration',
      subtitle:
      'Browse the latest trends and curated looks\non your home screen.',
    ),
    OnboardingItem(
      imagePath: 'assets/images/onboarding_3.png',
      title: 'Your Virtual\nFurniture Assistant',
      subtitle:
      'Roomora helps you personalize interiors and\ntransform spaces with smart AI.',
    ),
  ];

  bool get isLastPage => currentPage.value == pages.length - 1;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void onNext() {
    if (isLastPage) {
      onGetStarted();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void onSkip() {
    Get.offAllNamed(Routes.CREATE_ACCOUNT);
  }

  void onGetStarted() {
    Get.offAllNamed(Routes.CREATE_ACCOUNT);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

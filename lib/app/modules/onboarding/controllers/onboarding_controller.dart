import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  //TODO: Implement OnboardingController

  //Reactive variables
  final RxInt currentIndex = 0.obs;
  //final RxBool isLoading = false.obs;

  // Non Reactive variables
  final PageController pageController = PageController();
  Timer? autoPaginationTimer;
  final int totalPages = 3;

  //Onboarding Content Page
  final List<Map<String, String>> pageContents = [
    {
      'image': 'assets/images/womenAtOnboarding.png',
      'description': 'Your Fashion Companion for All Things Trendy',
    },
    {
      'image': 'assets/images/womenAtOnboarding2.png',
      'description':
          'Stay Ahead of the Style Curve with Our Curated Collections',
    },
    {
      'image': 'assets/images/womenAtOnboarding3.png',
      'description': 'Create Your Fashion Profile and Unleash Your Style.',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 3), () {
      startAutoPagination();
    });
  }

  void startAutoPagination() {
    // Cancel any existing timer
    autoPaginationTimer?.cancel();

    autoPaginationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Check if controller is still attached
      if (!pageController.hasClients) {
        timer.cancel();
        return;
      }

      try {
        if (currentIndex.value < totalPages - 1) {
          // Move to next page
          pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          // Reset to first page
          pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } catch (e) {
        print("Auto pagination error: $e");
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    stopAutoPagination();
    // Don't dispose if still in use
    if (pageController.hasClients) {
      pageController.dispose();
    }
    super.onClose();
  }

  // Stop auto-pagination timer
  void stopAutoPagination() {
    autoPaginationTimer?.cancel();
    autoPaginationTimer = null;
  }

  // Restart auto pagination timer
  void restartAutoPagination() {
    stopAutoPagination();
    startAutoPagination();
  }

  // Handle page change
  void handlePageChange(int page) {
    currentIndex.value = page;
    restartAutoPagination();
  }

  void handleSkipPress() {
    navigateToMainApp();
  }

  // Navigate to main app
  void navigateToMainApp() {
    stopAutoPagination();
    Get.offAllNamed(Routes.LOGIN);
  }

  // Manual navigation (if user taps on indicator dots)
  void goToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  // Get current page content
  Map<String, String> getCurrentPageContent() {
    return pageContents[currentIndex.value];
  }

  // Get Specific page content
  Map<String, String> getPageContent(int page) {
    return pageContents[page];
  }

  // Check if it's the last page
  bool get isLastPage => currentIndex.value == totalPages - 1;
}

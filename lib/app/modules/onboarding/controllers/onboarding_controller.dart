import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foddu/app/data/basic_provider.dart';
import 'package:foddu/app/data/models/intro_slider_model.dart';
import 'package:foddu/app/modules/auth/auth_details.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  // Reactive variables
  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPaused = false.obs;
  final RxList<IntroSlideItem> slides = <IntroSlideItem>[].obs;

  // Non-reactive variables
  final PageController pageController = PageController();
  Timer? autoPaginationTimer;

  // Default fallback slides (only used if network is unreachable on first install)
  static final List<IntroSlideItem> fallbackSlides = [
    IntroSlideItem.fromAsset(
      assetPath: 'assets/images/womenAtOnboarding.png',
      description: 'Your Fashion Companion for All Things Trendy',
      buttonText: 'Skip',
      order: 0,
    ),
    IntroSlideItem.fromAsset(
      assetPath: 'assets/images/womenAtOnboarding2.png',
      description: 'Stay Ahead of the Style Curve with Our Curated Collections',
      buttonText: 'Skip',
      order: 1,
    ),
    IntroSlideItem.fromAsset(
      assetPath: 'assets/images/womenAtOnboarding3.png',
      description: 'Create Your Fashion Profile and Unleash Your Style.',
      buttonText: 'Get Started',
      order: 2,
    ),
  ];

  // Dynamic getters
  int get totalPages => slides.isEmpty ? fallbackSlides.length : slides.length;
  bool get isLastPage => currentIndex.value >= totalPages - 1;

  IntroSlideItem get currentSlide {
    if (slides.isNotEmpty && currentIndex.value < slides.length) {
      return slides[currentIndex.value];
    }
    if (currentIndex.value < fallbackSlides.length) {
      return fallbackSlides[currentIndex.value];
    }
    return fallbackSlides.first;
  }

  IntroSlideItem getSlide(int index) {
    if (slides.isNotEmpty && index < slides.length) {
      return slides[index];
    }
    if (index < fallbackSlides.length) {
      return fallbackSlides[index];
    }
    return fallbackSlides.first;
  }

  @override
  void onInit() {
    super.onInit();
    // Start with fallback slides so UI is never blank
    slides.assignAll(fallbackSlides);

    // Fetch dynamic slides from backend
    fetchIntroSlides();

    // Start auto pagination timer
    Future.delayed(const Duration(seconds: 3), () {
      startAutoPagination();
    });
  }

  /// Fetches intro slider from backend via BasicProvider (cached & retried)
  Future<void> fetchIntroSlides() async {
    try {
      isLoading.value = true;
      debugPrint("🚀 [Onboarding] Fetching intro slides from slider/intro...");
      final response =
          await BasicProvider("slider/intro").getRequest(useCache: true);

      debugPrint("📦 [Onboarding] Response type: ${response.runtimeType}");

      if (response != null) {
        List<dynamic>? contentList;

        if (response is Map) {
          // Check if BasicProvider unwrapped responseBody["data"]
          if (response['content'] is List) {
            contentList = response['content'] as List;
          } else if (response['data'] is Map &&
              response['data']['content'] is List) {
            contentList = response['data']['content'] as List;
          }
        } else if (response is List) {
          contentList = response;
        }

        if (contentList != null && contentList.isNotEmpty) {
          final items = contentList
              .whereType<Map>()
              .map((item) => IntroSlideItem.fromJson(item))
              .toList();

          if (items.isNotEmpty) {
            items.sort((a, b) => a.order.compareTo(b.order));
            slides.assignAll(items);
            slides.refresh();
            debugPrint("✅ [Onboarding] Successfully loaded ${items.length} dynamic slides from backend!");

            // Pre-cache backend WebP images
            for (final item in items) {
              if (!item.isAsset && item.fullImageUrl.isNotEmpty) {
                debugPrint("🖼️ [Onboarding] Pre-caching: ${item.fullImageUrl}");
                try {
                  CachedNetworkImageProvider(item.fullImageUrl)
                      .resolve(ImageConfiguration.empty);
                } catch (e) {
                  debugPrint("Image pre-cache warning: $e");
                }
              }
            }

            restartAutoPagination();
          }
        } else {
          debugPrint("⚠️ [Onboarding] Content list is empty in response: $response");
        }
      }
    } catch (e) {
      debugPrint("❌ [Onboarding] Error fetching intro slides: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void startAutoPagination() {
    autoPaginationTimer?.cancel();

    autoPaginationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!pageController.hasClients) {
        timer.cancel();
        return;
      }

      // If user is currently touching/holding the screen, don't auto-advance
      if (isPaused.value) return;

      try {
        if (currentIndex.value < totalPages - 1) {
          pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
          );
        } else {
          pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          );
        }
      } catch (e) {
        debugPrint("Auto pagination error: $e");
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    stopAutoPagination();
    if (pageController.hasClients) {
      pageController.dispose();
    }
    super.onClose();
  }

  void stopAutoPagination() {
    autoPaginationTimer?.cancel();
    autoPaginationTimer = null;
  }

  void restartAutoPagination() {
    stopAutoPagination();
    startAutoPagination();
  }

  void pauseAutoPagination() {
    isPaused.value = true;
  }

  void resumeAutoPagination() {
    isPaused.value = false;
  }

  void handlePageChange(int page) {
    currentIndex.value = page;
    restartAutoPagination();
  }

  /// Tapping top-right Skip button (instantly exits to login)
  void handleSkipPress() {
    navigateToMainApp();
  }

  /// Tapping primary bottom button
  void handlePrimaryButtonPress() {
    if (isLastPage) {
      navigateToMainApp();
    } else {
      goToPage(currentIndex.value + 1);
    }
  }

  /// Navigate to login/main app and save viewed state
  void navigateToMainApp() {
    stopAutoPagination();
    AuthDetails.markIntroViewed();
    Get.offAllNamed(Routes.LOGIN);
  }

  void goToPage(int page) {
    if (!pageController.hasClients) return;
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }
}

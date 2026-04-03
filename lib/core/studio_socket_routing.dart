import 'dart:convert';
import '/app/modules/bottomar/controllers/bottombar_controller.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';
import '/helpers/socket_helper.dart';
import 'package:get/get.dart';

class StudioSocketRouting extends GetxController {
  final String? initialSlug;
  StudioSocketRouting({this.initialSlug});

  final SocketHelper _socketHelper = SocketHelper();

  // Map of bottom bar slugs to their tab indices
  // Index 0=Home, 1=Category, 2=Cart, 3=Wishlist, 4=Profile
  static const Map<String, int> _bottomBarTabs = {
    'home': 0,
    'category': 1,
    'cart': 2,
    'wishlist': 3,
    'profile': 4,
  };

  @override
  void onInit() {
    super.onInit();
    _connectAndListen();
  }

  @override
  void onReady() {
    super.onReady();

    navigateToSlug(initialSlug ?? 'home');
  }

  void _connectAndListen() {
    try {
      // Ensure socket is connected (SocketHelper usually handles singleton)
      _socketHelper.connect();

      final eventName = '$websiteDomain:mobileapp:route';
      print('🌐 StudioSocketRouting: Listening for event: $eventName');

      // Clear existing listeners to avoid duplicates
      _socketHelper.off(eventName);

      _socketHelper.on(eventName, (data) {
        print('📨 StudioSocketRouting: Received data: $data');
        _handleRouteEvent(data);
      });
    } catch (e) {
      print('❌ StudioSocketRouting: Error initializing socket: $e');
    }
  }

  void _handleRouteEvent(dynamic data) {
    try {
      dynamic decodedData;
      if (data is String) {
        decodedData = json.decode(data);
      } else {
        decodedData = data;
      }

      if (decodedData != null && decodedData['route'] != null) {
        String slug = decodedData['route'];
        print('🚀 StudioSocketRouting: Navigating to slug: $slug');
        navigateToSlug(slug);
      } else {
        print('⚠️ StudioSocketRouting: Invalid or missing slug in data');
      }
    } catch (e) {
      print('❌ StudioSocketRouting: Error handling route event: $e');
    }
  }

  /// Navigates to the bottom bar and switches to the given tab index.
  /// Handles two scenarios:
  /// 1. Already on the bottom bar screen → just switch the tab.
  /// 2. On a different screen → navigate to bottom bar first, then switch tab.
  void _navigateToBottomBarTab(int tabIndex) {
    // Check if BottombarController is already registered (we're on the bottom bar screen)
    if (Get.isRegistered<BottombarController>()) {
      final controller = Get.find<BottombarController>();
      controller.onTabChange(tabIndex);
      // Pop any screens stacked on top of the bottom bar
      Get.until((route) => route.settings.name == Routes.BOTTOMBAR);
    } else {
      // Navigate to bottom bar first, then switch tab after it's ready
      Get.offAllNamed(Routes.BOTTOMBAR);
      // Use a slight delay to ensure the controller is initialized
      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.isRegistered<BottombarController>()) {
          Get.find<BottombarController>().onTabChange(tabIndex);
        }
      });
    }
  }

  void navigateToSlug(String slug) {
    // Normalize: lowercase and strip leading slash so both "home" and "/home" work
    String normalizedSlug = slug.toLowerCase().replaceFirst(RegExp(r'^/'), '');

    // Check if the slug corresponds to a bottom bar tab
    final tabIndex = _bottomBarTabs[normalizedSlug];
    if (tabIndex != null) {
      print(
          '🔄 StudioSocketRouting: Switching to bottom bar tab $tabIndex for slug: $slug');
      _navigateToBottomBarTab(tabIndex);
      return;
    }

    // Non-bottom-bar routes: push as standalone screens
    switch (normalizedSlug) {
      case 'detailcategory':
        Get.toNamed(Routes.DETAILCATEGORY);
        break;
      case 'search':
        Get.toNamed(Routes.SEARCH);
        break;
      case 'product-listing':
        Get.toNamed(Routes.SHOPPRODUCTLISTVIEW);
        break;
      default:
        Get.toNamed(Routes.CUSTOMPAGE,
            arguments: {'slug': slug, 'label': 'No lable'});
      // print(
      //     'ℹ️ StudioSocketRouting: Attempting direct navigation for: $slug');
      // if (slug.startsWith('/')) {
      //   Get.toNamed(slug);
      // } else {
      //   print('⚠️ StudioSocketRouting: No specific handler for slug: $slug');
      // }
    }
  }

  @override
  void onClose() {
    final eventName = '$websiteDomain:mobileapp:route';
    _socketHelper.off(eventName);
    super.onClose();
  }
}

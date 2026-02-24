import 'dart:convert';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/helpers/socket_helper.dart';
import 'package:get/get.dart';

class StudioSocketRouting extends GetxController {
  final String? initialSlug;
  StudioSocketRouting({this.initialSlug});

  final SocketHelper _socketHelper = SocketHelper();

  @override
  void onInit() {
    super.onInit();
    _connectAndListen();
  }

  @override
  void onReady() {
    super.onReady();
    print('swapnil Initial slug Sutdio socket routing : $initialSlug');
    // if (initialSlug != null &&
    //     initialSlug != 'home' &&
    //     initialSlug!.isNotEmpty) {
    print(
        '🚀 StudioSocketRouting: Initial slug found, navigating: $initialSlug');
    navigateToSlug(initialSlug ?? 'home');
    // }
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

  void navigateToSlug(String slug) {
    switch (slug.toLowerCase()) {
      case 'home':
        Get.offAllNamed(Routes.BOTTOMBAR);
        break;
      case 'category':
        Get.toNamed(Routes.CATEGORY);
        break;
      case 'detailcategory':
        Get.toNamed(Routes.DETAILCATEGORY);
        break;
      case 'wishlist':
        Get.toNamed(Routes.WISHLIST);
        break;
      case 'cart':
        Get.toNamed(Routes.CART);
        break;

      case 'profile':
        Get.toNamed(Routes.PROFILE);
        break;
      case 'search':
        Get.toNamed(Routes.SEARCH);
        break;
      case 'product-listing':
        Get.toNamed(Routes.SHOPPRODUCTLISTVIEW);
        break;
      default:
        print(
            'ℹ️ StudioSocketRouting: Attempting direct navigation for: $slug');
        if (slug.startsWith('/')) {
          Get.toNamed(slug);
        } else {
          print('⚠️ StudioSocketRouting: No specific handler for slug: $slug');
        }
    }
  }

  @override
  void onClose() {
    final eventName = '$websiteDomain:mobileapp:route';
    _socketHelper.off(eventName);
    super.onClose();
  }
}

import 'dart:convert';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/aboutus/controllers/aboutus_controller.dart';
import 'package:foduu_ecommerce/app/modules/blog/controller/blog_controller.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/contact/controller/contact_controller.dart';
import 'package:foduu_ecommerce/app/modules/helpandsupport/controllers/helpandsupport_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/core/config/app_config.dart';
import 'package:foduu_ecommerce/helpers/socket_helper.dart';
import 'package:get/get.dart';
import 'package:foduu_ecommerce/app/modules/shop/shop_navigation.dart';

class StudioSocketRouting extends GetxController {
  final String? initialSlug;
  StudioSocketRouting({this.initialSlug});

  final SocketHelper _socketHelper = SocketHelper();

  // Map of bottom bar slugs to their tab indices
  // Index 0=Home, 1=Shop/Category, 2=Wishlist, 3=Cart, 4=Account/Profile
  static const Map<String, int> _bottomBarTabs = {
    'home': 0,
    'shop': 1,
    'category': 1,
    'wishlist': 2,
    'cart': 3,
    'account': 4,
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
      final themeEventName = '$websiteDomain:mobileapp:theme';
      final settingsEventName = '$websiteDomain:mobileapp:settings';
      print('🌐 StudioSocketRouting: Listening for event: $eventName');

      // Clear existing listeners to avoid duplicates
      _socketHelper.off(eventName);
      _socketHelper.off(themeEventName);
      _socketHelper.off(settingsEventName);

      _socketHelper.on(eventName, (data) {
        print('📨 StudioSocketRouting: Received data: $data');
        _handleRouteEvent(data);
      });
      _socketHelper.on(
          themeEventName, (data) => _handleThemeOrSettingsEvent(data));
      _socketHelper.on(
          settingsEventName, (data) => _handleThemeOrSettingsEvent(data));
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
        openShop();
        break;
      case 'about-us':
      case 'about':
      case 'aboutus':
        if (Get.currentRoute == Routes.ABOUTUS) {
          if (Get.isRegistered<AboutusController>()) {
            Get.find<AboutusController>().fetchAboutUs();
          }
        } else {
          Get.toNamed(Routes.ABOUTUS);
        }
        break;
      case 'contact-us':
      case 'contact':
        if (Get.currentRoute == Routes.CONTACT) {
          if (Get.isRegistered<ContactController>()) {
            Get.find<ContactController>().fetchContactLayout();
          }
        } else {
          Get.toNamed(Routes.CONTACT);
        }
        break;
      case 'faq':
      case 'faqs':
      case 'help':
      case 'helpandsupport':
      case 'help-and-support':
        if (Get.currentRoute == Routes.HELPANDSUPPORT ||
            Get.currentRoute == Routes.FAQ) {
          if (Get.isRegistered<HelpandsupportController>()) {
            Get.find<HelpandsupportController>().getFaqs();
          }
        } else {
          Get.toNamed(Routes.HELPANDSUPPORT);
        }
        break;
      case 'blog':
      case 'blogs':
      case 'articles':
        if (Get.currentRoute == Routes.BLOG) {
          if (Get.isRegistered<BlogController>()) {
            Get.find<BlogController>().onRefresh();
          }
        } else {
          Get.toNamed(Routes.BLOG);
        }
        break;
      default:
      // Get.toNamed(Routes.CUSTOMPAGE,
      //     arguments: {'slug': slug, 'label': 'No lable'});
      // print(
      //     'ℹ️ StudioSocketRouting: Attempting direct navigation for: $slug');
      // if (slug.startsWith('/')) {
      //   Get.toNamed(slug);
      // } else {
      //   print('⚠️ StudioSocketRouting: No specific handler for slug: $slug');
      // }
    }
  }

  Future<void> _handleThemeOrSettingsEvent(dynamic data) async {
    try {
      dynamic decoded = data is String ? json.decode(data) : data;
      if (decoded is Map) {
        final palette = decoded['app_theme_color'] ?? decoded['theme_color'];
        if (palette is Map) {
          final updated = DynamicThemeManager()
              .updateFromApi(Map<String, dynamic>.from(palette));
          if (updated && Get.isRegistered<ThemeController>()) {
            Get.find<ThemeController>().refreshTheme();
          }
        }
      }
      final response =
          await BasicProvider('public-settings').getRequest(useCache: false);
      final settings = AppConfig.instance.applyPublicSettings(response);
      if (settings != null) {
        final palette = AppConfig.instance.extractThemePalette(settings);
        if (palette != null &&
            DynamicThemeManager().updateFromApi(palette) &&
            Get.isRegistered<ThemeController>()) {
          Get.find<ThemeController>().refreshTheme();
        }
      }
    } catch (e) {
      print('⚠️ StudioSocketRouting: Error refreshing theme/settings: $e');
    }
  }

  @override
  void onClose() {
    _socketHelper.off('$websiteDomain:mobileapp:route');
    _socketHelper.off('$websiteDomain:mobileapp:theme');
    _socketHelper.off('$websiteDomain:mobileapp:settings');
    super.onClose();
  }
}

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/helpers/socket_helper.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/modules/shop/shop_navigation.dart';
import 'package:zouhi/app/modules/aboutus/controllers/aboutus_controller.dart';
import 'package:zouhi/app/modules/helpandsupport/controllers/policy_controller.dart';
import 'package:zouhi/app/modules/pages/solutions/controllers/solutions_controller.dart';
import 'package:zouhi/app/modules/contact/controller/contact_controller.dart';
import 'package:zouhi/app/modules/cable_assemblies/controllers/cable_assemblies_controller.dart';
import 'package:zouhi/app/modules/mtp_solution/controllers/mtp_solution_controller.dart';

class StudioSocketRouting extends GetxController {
  final String? initialSlug;
  StudioSocketRouting({this.initialSlug});

  final SocketHelper _socketHelper = SocketHelper();

  // Map of bottom bar slugs to their tab indices
  // Index 0=Home, 1=Account/Profile, 2=Shop/Category, 3=Wishlist, 4=Cart
  static const Map<String, int> _bottomBarTabs = {
    'home': 0,
    'account': 1,
    'profile': 1,
    'shop': 2,
    'category': 2,
    'wishlist': 3,
    'cart': 4,
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
      case 'terms-and-conditions':
      case 'terms-conditions':
      case 'terms':
        if (Get.currentRoute == Routes.POLICY_DETAIL) {
          if (Get.isRegistered<PolicyController>()) {
            Get.find<PolicyController>().fetchPolicy('terms', forceRefresh: true);
          }
        } else {
          Get.toNamed(
            Routes.POLICY_DETAIL,
            arguments: {'type': 'terms', 'title': 'Terms & Conditions'},
          );
        }
        break;
      case 'privacy-policy':
      case 'privacy':
        if (Get.currentRoute == Routes.POLICY_DETAIL) {
          if (Get.isRegistered<PolicyController>()) {
            Get.find<PolicyController>().fetchPolicy('privacy', forceRefresh: true);
          }
        } else {
          Get.toNamed(
            Routes.POLICY_DETAIL,
            arguments: {'type': 'privacy', 'title': 'Privacy Policy'},
          );
        }
        break;
      case 'solution':
      case 'solutions':
        if (Get.currentRoute == Routes.SOLUTION ||
            Get.currentRoute == Routes.SOLUTIONS) {
          if (Get.isRegistered<SolutionsController>()) {
            Get.find<SolutionsController>().fetchSolutions();
          }
        } else {
          Get.toNamed(Routes.SOLUTION);
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
      case 'cable-assemblies':
      case 'cable-assembler':
        if (Get.currentRoute == Routes.CABLE_ASSEMBLIES) {
          if (Get.isRegistered<CableAssembliesController>()) {
            Get.find<CableAssembliesController>().fetchCableAssembliesLayout();
          }
        } else {
          Get.toNamed(Routes.CABLE_ASSEMBLIES);
        }
        break;
      case 'mtp-solution':
      case 'mtp-solutions':
        if (Get.currentRoute == Routes.MTP_SOLUTION) {
          if (Get.isRegistered<MtpSolutionController>()) {
            Get.find<MtpSolutionController>().fetchMtpSolutionLayout();
          }
        } else {
          Get.toNamed(Routes.MTP_SOLUTION);
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

  @override
  void onClose() {
    final eventName = '$websiteDomain:mobileapp:route';
    _socketHelper.off(eventName);
    super.onClose();
  }
}

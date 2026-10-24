import 'package:zouhi/app/data/services/session_service.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';
import '../auth/auth_details.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:zouhi/constants/theme_ext.dart';

import 'package:get/get.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';

class SplashscreenView extends StatefulWidget with BaseController {
  SplashscreenView({super.key});

  @override
  State<SplashscreenView> createState() => _SplashscreenViewState();
}

class _SplashscreenViewState extends State<SplashscreenView> {
  bool isLoading = true;
  bool currencyFailed = false;
  List list = [];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Prices can't render without the currency; fall back to the cached one
    // and otherwise let the user retry.
    final currencyCtrl = Get.find<CurrencyController>();
    if (!await currencyCtrl.fetchCurrency()) {
      if (mounted) setState(() => currencyFailed = true);
      return;
    }
    if (mounted && currencyFailed) setState(() => currencyFailed = false);

    try {
      // Validate the stored session once before any authenticated request.
      await SessionService.bootstrap();
      if (AuthDetails.isUserLogin()) {
        Get.put(BottombarController(), permanent: true);
        Get.put(CartController(), permanent: true); // loads its own data in onInit
        final wishlistCtrl = Get.put(WishlistController(), permanent: true);
        final homeCtrl = Get.put(HomepageController(), permanent: true);

        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          // HelperFunctions().showSnackBarError(
          //     "You are offline. Showing cached offline data.");
          await Future.delayed(const Duration(seconds: 2));
        } else {
          await Future.wait(<Future<void>>[
            wishlistCtrl.getwishlist(),
            homeCtrl.refreshAllData(),
            Future.delayed(const Duration(seconds: 2)),
          ]);
        }
      } else if (SessionService.pendingNotice == null) {
        await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
    } finally {
      _navigateOnce();
    }
  }

  /// The one and only boot navigation. Skipped if something else already
  /// moved the user away (or this screen is gone) so Login is never rebuilt.
  void _navigateOnce() {
    if (!mounted || Get.currentRoute != Routes.SPLASH) return;
    if (kIsWeb) {
      // In web preview (e.g. Studio editor iframe), do not redirect to Login.
      // StudioSocketRouting directly handles navigating to initialSlug (e.g. about-us or home).
      return;
    }
    if (AuthDetails.isUserLogin()) {
      Get.offAllNamed(Routes.BOTTOMBAR);
    } else {
      isOtpLogin
          ? Get.offAllNamed(Routes.MOBILELOGIN)
          : Get.offAllNamed(Routes.LOGIN);
      Future.delayed(
          const Duration(milliseconds: 400), SessionService.showPendingNotice);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: initScreen(context),
    );
  }

  initScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeWhiteColor,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/VIC-Logo-Final-1213.png',
                width: 250,
              ),
            ),
          ),
          if (currencyFailed) ...[
            const Text('Unable to load store settings.'),
            TextButton(
              onPressed: _initializeApp,
              child: const Text('Retry'),
            ),
          ] else
            CircularProgressIndicator(
              backgroundColor: context.themePrimaryLight,
              color: context.themeBlueColor,
              strokeWidth: 3.5,
            ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}

import 'dart:async';

// import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:foduu_ecommerce/core/services/wishlistService.dart';
import 'package:foduu_ecommerce/core/studio_socket_routing.dart';
import '/constants/constants.dart';
import '/core/services/cartServcie.dart';
import '/constants/dynamic_theme.dart';
import 'core/foduuStudio/register_default_widgets.dart';
import 'package:foduu_ecommerce/app/data/services/session_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/app/routes/app_pages.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:foduu_ecommerce/constants/firebase_notification.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/services/local_storage_notification_service.dart';
import 'package:foduu_ecommerce/services/notification_sync_service.dart';
import 'package:foduu_ecommerce/services/payment_service.dart';
import 'firebase_options.dart';
import 'package:foduu_ecommerce/components/resilience/reconnecting_banner.dart';
import 'package:foduu_ecommerce/services/api_cache.dart';
import 'package:foduu_ecommerce/services/api_health_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await ApiCache.init();
  Get.put(ApiHealthService(), permanent: true);

  Get.put(LocalStorageNotificationService());
  Get.put(NotificationSyncService());
  Get.put(CartService());
  Get.put(PaymentService()); // Initialize PaymentService
  Get.put(WishListService());

  if (kIsWeb) {
    var accessKey = Uri.base.queryParameters['api_key'];
    var domain = Uri.base.queryParameters['domain_name'];
    String? slug = Uri.base.queryParameters['slug'] ?? 'home';
    if (accessKey == null && Uri.base.fragment.isNotEmpty) {
      try {
        final fragmentUri = Uri.parse(Uri.base.fragment);
        accessKey = fragmentUri.queryParameters['api_key'];
        domain = fragmentUri.queryParameters['domain_name'];
        slug = fragmentUri.queryParameters['slug'];
        print('Access Key: $accessKey');
        print('Domain: $domain');
        print('Slug: $slug');
      } catch (e) {
        print("Error parsing URI fragment: $e");
      }
    }

    if (accessKey != null && accessKey.isNotEmpty) {
      ACCESS_KEY = accessKey;
    }

    if (domain != null && domain.isNotEmpty) {
      websiteDomain = domain;
    }

    Get.put(StudioSocketRouting(initialSlug: slug));
  }

  // Initialize dynamic theme from storage
  await DynamicThemeManager().init();

  // Register ThemeController globally
  Get.put(ThemeController());

  // Register all dynamic layout widgets
  registerDefaultWidgets();

  // Choose the first screen from local state so network/Firebase startup
  // cannot leave iOS sitting on its blank native launch screen.
  final box = GetStorage();
  final isLogin = box.read('isLogin') == true || box.read('isLogin') == 'true';
  final initialRoute = isLogin
      ? Routes.BOTTOMBAR
      : (isOtpLogin ? Routes.MOBILELOGIN : Routes.LOGIN);

  runApp(MyApp(initialRoute: initialRoute));

  // These tasks are best-effort and run after the first frame. Firebase config,
  // push permissions, and network requests must not prevent the app UI opening.
  if (!kIsWeb) unawaited(_initializeFirebaseServices());
  unawaited(_refreshPublicSettings(box));
  if (isLogin) unawaited(_validateSessionAfterLaunch());
}

Future<void> _initializeFirebaseServices() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
    await FirebaseHelpers.firebaseInitialise()
        .timeout(const Duration(seconds: 15));
    await FirebaseHelpers.getFCMToken().timeout(const Duration(seconds: 10));
  } catch (error, stackTrace) {
    debugPrint('Firebase startup skipped: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

Future<void> _validateSessionAfterLaunch() async {
  try {
    final isValid = await SessionService.validateAtLaunch();
    if (isValid) return;

    await WidgetsBinding.instance.endOfFrame;
    final route = isOtpLogin ? Routes.MOBILELOGIN : Routes.LOGIN;
    Get.offAllNamed(route);
    if (SessionService.pendingNotice != null) {
      await Future.delayed(const Duration(milliseconds: 400));
      SessionService.showPendingNotice();
    }
  } catch (error, stackTrace) {
    debugPrint('Session validation skipped: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

Future<void> _refreshPublicSettings(GetStorage box) async {
  try {
    final response = await BasicProvider('public-settings').getRequest();
    print('public-settings loaded');

    final settings = response is Map ? response['storeSettings'] : null;
    if (settings is! Map) return;

    final authPreference = settings['auth_preference'];
    if (authPreference != null) box.write('auth_preference', authPreference);

    final storeName = settings['name'] ?? settings['store_name'];
    if (storeName != null) box.write('store_name', storeName);

    if (settings['app_theme_color'] != null) {
      DynamicThemeManager().updateFromApi(settings['app_theme_color']);
      Get.find<ThemeController>().refreshTheme();
    }
  } catch (e) {
    print('Error during initApp: $e');
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Foduu",
          initialRoute: initialRoute,
          getPages: AppPages.routes,
          theme: themeController.lightTheme,
          darkTheme: themeController.darkTheme,
          themeMode: themeController.themeMode,
          builder: (context, child) =>
              ResilienceShell(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}

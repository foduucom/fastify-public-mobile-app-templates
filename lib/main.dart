// import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:foduu_ecommerce/core/services/wishlistService.dart';
import 'package:foduu_ecommerce/core/studio_socket_routing.dart';
import '/constants/constants.dart';
import '/core/services/cartServcie.dart';
import '/constants/dynamic_theme.dart';
import 'core/foduuStudio/register_default_widgets.dart';
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

  // Initialize Firebase and push notifications
  if (!kIsWeb) {
    await Firebase.initializeApp();
    await FirebaseHelpers.firebaseInitialise();
    await FirebaseHelpers.getFCMToken();
  }

  // Initialize dynamic theme from storage
  await DynamicThemeManager().init();

  // Register ThemeController globally
  Get.put(ThemeController());

  // Register all dynamic layout widgets
  registerDefaultWidgets();

  // Initialize App and get initial route
  String initialRoute = await _initApp();

  runApp(MyApp(initialRoute: initialRoute));

  // Remove splash screen after app is ready
  // Splash screen removed (flutter_native_splash not configured)
}

Future<String> _initApp() async {
  final box = GetStorage();
  final bool isLogin = box.read('isLogin') ?? false;

  final refresh = _refreshPublicSettings(box);
  // First ever launch has no saved settings, so give them a short window to
  // arrive. Returning users start immediately from saved settings and the
  // refresh finishes in the background; a 5xx never logs anyone out.
  if (box.read('auth_preference') == null) {
    await refresh.timeout(const Duration(seconds: 10), onTimeout: () {});
  }
  return isLogin ? Routes.BOTTOMBAR : Routes.LOGIN;
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
          title: "My App",
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

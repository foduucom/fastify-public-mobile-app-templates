import 'dart:async';

import 'package:foduu_ecommerce/core/config/app_config.dart';
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
  final appConfig = await AppConfig.init();
  Get.put(ApiHealthService(), permanent: true);

  Get.put(LocalStorageNotificationService());
  Get.put(NotificationSyncService());
  Get.put(CartService());
  Get.put(PaymentService()); // Initialize PaymentService
  Get.put(WishListService());

  if (kIsWeb) {
    Get.put(StudioSocketRouting(initialSlug: appConfig.initialSlug));
  }

  // Register ThemeController globally
  Get.put(ThemeController());

  // Register all dynamic layout widgets
  registerDefaultWidgets();

  // Start the app UI before Firebase or network initialization. The Flutter
  // splash route owns settings/session loading and provides a visible fallback
  // while these services initialize.
  runApp(const MyApp(initialRoute: Routes.SPLASH));

  if (!kIsWeb) unawaited(_initializeFirebase());
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    await FirebaseHelpers.firebaseInitialise();
    await FirebaseHelpers.getFCMToken();
  } catch (error, stackTrace) {
    debugPrint('Firebase startup initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
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
          title: appName,
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

import 'dart:async';

// import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:foduu_ecommerce/core/config/app_config.dart';
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
import 'package:flutter_native_splash/flutter_native_splash.dart';
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
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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
  FlutterNativeSplash.remove();

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
    unawaited(_initializeNotificationHandlers());
    await FirebaseHelpers.getFCMToken().timeout(const Duration(seconds: 10));
    await FirebaseHelpers.syncTopics();
  } catch (error, stackTrace) {
    debugPrint('Firebase startup skipped: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

Future<void> _initializeNotificationHandlers() async {
  try {
    await FirebaseHelpers.firebaseInitialise();
  } catch (error, stackTrace) {
    debugPrint('Notification handler setup failed: $error');
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
  final themeController = Get.isRegistered<ThemeController>()
      ? Get.find<ThemeController>()
      : null;
  themeController?.setThemeLoading(true);
  try {
    final response = await BasicProvider('public-settings').getRequest();
    print('public-settings loaded');

    final settings = AppConfig.instance.applyPublicSettings(response);
    if (settings == null) {
      themeController?.setThemeError(
          'Store settings missing. Unable to load backend theme.');
      return;
    }

    final palette = AppConfig.instance.extractThemePalette(settings);
    if (palette != null) {
      final themeUpdated = DynamicThemeManager().updateFromApi(palette);
      if (themeUpdated) {
        themeController?.setThemeError(null);
        themeController?.refreshTheme();
      } else if (!DynamicThemeManager().hasTheme) {
        themeController?.setThemeError(
            'Backend returned an unusable theme palette.');
      }
    } else if (!DynamicThemeManager().hasTheme) {
      themeController?.setThemeError(
          'Backend did not return app_theme_color.');
    }
  } catch (e) {
    print('Error during initApp: $e');
    if (!DynamicThemeManager().hasTheme) {
      themeController?.setThemeError('Unable to reach store settings.');
    }
  } finally {
    themeController?.setThemeLoading(false);
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
          builder: (context, child) {
            if (!themeController.hasTheme) {
              return _ThemeRequiredGate(
                isLoading: themeController.isThemeLoading,
                errorMessage: themeController.themeError,
                onRetry: () => _refreshPublicSettings(GetStorage()),
              );
            }
            return ResilienceShell(child: child ?? const SizedBox.shrink());
          },
        );
      },
    );
  }
}

class _ThemeRequiredGate extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const _ThemeRequiredGate({
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading) ...[
                  CircularProgressIndicator(color: fg),
                  const SizedBox(height: 16),
                  Text(
                    'Loading store theme...',
                    style: TextStyle(color: fg, fontSize: 15),
                  ),
                ] else ...[
                  Icon(Icons.palette_outlined, size: 40, color: fg),
                  const SizedBox(height: 12),
                  Text(
                    errorMessage ?? 'Store theme unavailable.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: fg,
                      side: BorderSide(color: fg),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

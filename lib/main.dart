import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';
import 'constants/constants.dart';
import 'constants/dynamic_theme.dart';
import 'constants/firebase_notification.dart';
import 'core/config/app_config.dart';
import 'core/foduuStudio/register_default_widgets.dart';
import 'core/services/cartServcie.dart';
import 'core/services/wishlistService.dart';
import 'core/studio_socket_routing.dart';
import 'services/api_cache.dart';
import 'services/api_health_service.dart';
import 'services/local_storage_notification_service.dart';
import 'services/notification_sync_service.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    _initializeApplication();
  } else {
    WidgetsBinding.instance.deferFirstFrame();
    runApp(const StartupSplash());
    unawaited(_initializeApplication());
  }
}

Future<void> _initializeApplication() async {
  var persistentStorageAvailable = true;
  try {
    await GetStorage.init();
  } catch (error, stackTrace) {
    persistentStorageAvailable = false;
    // GetStorage keeps an in-memory container even when its disk initialization
    // fails. Continue into the app with empty/default state rather than leaving
    // the user on the native launch screen; persistent writes may be unavailable
    // for this session, so keep the failure visible in diagnostics.
    debugPrint(
      'Persistent storage unavailable; continuing with defaults: $error',
    );
    debugPrintStack(stackTrace: stackTrace);
  }
  try {
    await ApiCache.init();
  } catch (error, stackTrace) {
    // The API cache is an optimization. A cache failure must not prevent the
    // app from replacing the startup splash with its first usable screen.
    debugPrint('API cache initialization skipped: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  // Dynamic CMS sections must be registered before the homepage fetches its
  // layout, otherwise the API data arrives but no section widgets are built.
  registerDefaultWidgets();

  final appConfig = await AppConfig.init();

  if (kIsWeb) {
    Get.put(StudioSocketRouting(initialSlug: appConfig.initialSlug));
  }

  // Load cached theme colors before building MaterialApp. If persisted theme
  // data is malformed, the manager's built-in defaults still let startup
  // continue instead of leaving the native launch screen visible.
  try {
    await DynamicThemeManager().init();
  } catch (error, stackTrace) {
    debugPrint('Cached theme load skipped; using default theme: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  // ✅ Register ThemeController once — available everywhere
  Get.put(ThemeController(), permanent: true);

  // Lock to portrait mode
  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Status bar overlay
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  // Determine initial route
  final initialRoute = await _initApp();

  // Let the first branded frame reach the display before replacing the
  // bootstrap app, including on fast local starts.
  if (!kIsWeb) {
    await WidgetsBinding.instance.endOfFrame;
  }
  runApp(
    MyApp(
      initialRoute: initialRoute,
      persistentStorageAvailable: persistentStorageAvailable,
    ),
  );
  if (!kIsWeb) unawaited(_initializeFirebaseServices());
}

/// First Flutter frame while local startup work completes. Keeping this screen
/// independent of GetX, storage, and dynamic themes avoids a blank frame while
/// those services are initialized.
class StartupSplash extends StatefulWidget {
  const StartupSplash({super.key});

  @override
  State<StartupSplash> createState() => _StartupSplashState();
}

class _StartupSplashState extends State<StartupSplash> {
  bool _firstFramePreparationStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstFramePreparationStarted) return;
    _firstFramePreparationStarted = true;
    _prepareFirstFrame();
  }

  Future<void> _prepareFirstFrame() async {
    try {
      await precacheImage(
        const AssetImage('assets/images/splash.png'),
        context,
      );
    } catch (error) {
      debugPrint('Splash image preload failed: $error');
    } finally {
      // Keep the native launch screen visible until the branded Flutter frame
      // is ready, avoiding a white frame while the splash asset decodes.
      WidgetsBinding.instance.allowFirstFrame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          final screenHeight = MediaQuery.sizeOf(context).height;

          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  top: screenHeight * 0.04,
                  right: 0,
                  left: 0,
                  bottom: screenHeight * 0.18,
                  child: Image.asset(
                    'assets/images/splash.png',
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  bottom: screenHeight * 0.06,
                  child: const SizedBox.square(
                    dimension: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<void> _initializeFirebaseServices() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 10));
    }
    await FirebaseHelpers.firebaseInitialise().timeout(
      const Duration(seconds: 10),
    );
    await FirebaseHelpers.getFCMToken().timeout(const Duration(seconds: 10));
  } catch (e, stackTrace) {
    debugPrint('Push notification startup skipped: $e');
    debugPrintStack(stackTrace: stackTrace);
  }
}

Future<String> _initApp() async {
  final box = GetStorage();
  bool isLogin = box.read('isLogin') == true || box.read('isLogin') == 'true';

  // In Web / Studio mode, bypass Splash and Onboarding directly to BOTTOMBAR.
  // StudioSocketRouting will immediately navigate to the requested slug.
  if (kIsWeb) {
    return Routes.BOTTOMBAR;
  }

  if (isLogin) {
    return Routes.BOTTOMBAR;
  }
  return Routes.SPLASH;
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final bool persistentStorageAvailable;

  const MyApp({
    super.key,
    required this.initialRoute,
    required this.persistentStorageAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final themeCtrl =
        Get.find<ThemeController>(); // ✅ finds registered controller

    return GetMaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,

      // ── Dynamic Themes ─────────────────────────────────────────
      themeMode: themeCtrl.themeMode, // ✅ reactive
      theme: themeCtrl.lightTheme, // ✅ dynamic light
      darkTheme: themeCtrl.darkTheme, // ✅ dynamic dark
      // ── Routing ────────────────────────────────────────────────
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      // Register services before the initial route (and its controllers) are
      // constructed. Route widget fields can resolve these during creation.
      initialBinding: BindingsBuilder(() {
        Get.put(CartService(), permanent: true);
        Get.put(WishListService(), permanent: true);
        Get.put(ApiHealthService(), permanent: true);
        Get.put(LocalStorageNotificationService(), permanent: true);
        Get.put(NotificationSyncService(), permanent: true);
      }),

      // ── Transitions ────────────────────────────────────────────
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),

      // ── Locale ─────────────────────────────────────────────────
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      builder: (context, child) => Column(
        children: [
          if (!persistentStorageAvailable)
            Material(
              color: Theme.of(context).colorScheme.errorContainer,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Device storage is unavailable. Some changes may not be saved.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          Expanded(child: child ?? const SizedBox.shrink()),
        ],
      ),
    );
  }
}

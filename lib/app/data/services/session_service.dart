import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/modules/Profie/profile/controllers/profile_controller.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/data/services/notification_service.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/auth/token_manager.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/app_exceptions.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';

/// Single owner of "is this session still valid" decisions.
///
/// - [expire] is the only place a dead session is torn down: it clears the
///   stored session, routes to login and tells the user exactly once, however
///   many in-flight requests fail at the same time.
/// - [bootstrap] validates the stored session once at launch (before any
///   authenticated request is fired), so a stale `isLogin` flag never lands
///   the user on the home screen without usable tokens.
class SessionService {
  SessionService._();

  static bool _isExpiring = false;

  /// Message to show once the Login screen is on screen (never while routes
  /// are being replaced, when a snackbar would attach to a dying Scaffold).
  static String? pendingNotice;

  /// True while the splash screen owns navigation (app launch).
  static bool get _onSplash => Get.currentRoute == Routes.SPLASH;

  static void showPendingNotice() {
    final notice = pendingNotice;
    if (notice == null) return;
    pendingNotice = null;
    HelperFunctions().showSnackBarError(notice);
  }

  /// Tears down a genuinely expired session (invalid/missing refresh token).
  /// Never call this for transient failures such as network errors or 5xx.
  static Future<void> expire({String? message}) async {
    // Already torn down (or a guest): nothing to expire. Prevents the double
    // teardown when refresh and the caller's error handler both report it.
    if (_isExpiring || !AuthDetails.isUserLogin()) return;
    _isExpiring = true;
    try {
      if (kDebugMode)
        debugPrint('SessionService.expire: ${message ?? "session ended"}');
      // Local teardown first: it must never wait on Firebase or the network.
      final otpLogin = isOtpLogin;
      await GetStorage().erase();
      await TokenManager.clearTokens();
      AuthDetails.loggedIn.value = false;
      try {
        _resetInMemoryState();
      } catch (e) {
        if (kDebugMode) debugPrint('SessionService reset error: $e');
      }
      // Best effort, fire-and-forget: Firebase can hang when unreachable.
      unawaited(NotificationService.unsubscribeFromAllTopics());
      pendingNotice = message != null
          ? "$message Your session seems to be expired!"
          : "Your session seems to be expired!";
      if (_onSplash) {
        // Boot: the splash screen is the single owner of navigation and will
        // route to Login once, then show the notice.
        return;
      }
      otpLogin
          ? Get.offAllNamed(Routes.MOBILELOGIN)
          : Get.offAllNamed(Routes.LOGIN);
      // Let the fade-in finish so the message lands on the Login screen.
      Future.delayed(const Duration(milliseconds: 400), showPendingNotice);
    } finally {
      _isExpiring = false;
    }
  }

  /// Drops user-specific data held by long-lived controllers so nothing from
  /// the dead session (name, wishlist, cart) can still be rendered.
  static void _resetInMemoryState() {
    if (Get.isRegistered<ProfileController>()) {
      final c = Get.find<ProfileController>();
      c.profiledata.clear();
      c.nameController.clear();
      c.emailController.clear();
      c.phoneController.clear();
      c.lastNameController.clear();
      c.dobController.clear();
      c.genderController.clear();
    }
    if (Get.isRegistered<WishlistController>()) {
      final c = Get.find<WishlistController>();
      c.wishList.clear();
      c.wishlistProductIds.clear();
      c.loadFailure.value = LoadFailure.none;
    }
    if (Get.isRegistered<CartController>()) {
      final c = Get.find<CartController>();
      c.cartItems.clear();
      c.resetCartTotals();
    }
  }

  /// Cheap check for app resume: refreshes an expired access token and tears
  /// the session down only if the refresh token is definitively rejected.
  static Future<void> revalidate() async {
    if (!AuthDetails.isUserLogin()) return;
    if ((TokenManager.refreshToken ?? '').isEmpty) {
      await expire(message: 'No refresh token.');
      return;
    }
    if (!TokenManager.isAccessTokenExpired()) return;
    try {
      await BasicProvider.refreshSession();
    } on UnAuthorizedException {
      // refreshSession already ran expire().
    } catch (_) {
      // Transient (offline / 5xx): keep the session.
    }
  }

  /// Validates the stored session at launch. Silent: the caller routes based
  /// on [AuthDetails.isUserLogin] afterwards.
  static Future<void> bootstrap() async {
    if (!AuthDetails.isUserLogin()) return;

    final hasAccess = (TokenManager.accessToken ?? '').isNotEmpty;
    final hasRefresh = (TokenManager.refreshToken ?? '').isNotEmpty;

    if (!hasAccess && !hasRefresh) {
      await _clearSilently();
      return;
    }

    if (TokenManager.isAccessTokenExpired() && hasRefresh) {
      try {
        await BasicProvider.refreshSession(silent: true);
      } on UnAuthorizedException {
        await _clearSilently();
      } catch (_) {
        // Transient failure (offline / 5xx): keep the session and let normal
        // requests retry the refresh later.
      }
    }

    if (!AuthDetails.isUserLogin()) return;

    // The access token can look valid locally (opaque token, clock skew,
    // revoked server-side). Confirm once, before the app starts loading
    // authenticated data, so a dead session is found here and not mid-load.
    try {
      final profile = await BasicProvider("auth/customer/profile")
          .getRequest()
          .timeout(const Duration(seconds: 10));
      if (profile != null) GetStorage().write('userData', profile);
    } on UnAuthorizedException {
      // Refresh already failed definitively (expire() ran silently on splash).
      if (AuthDetails.isUserLogin()) await _clearSilently();
    } catch (_) {
      // Offline / timeout / 5xx: keep the session.
    }
  }

  static Future<void> _clearSilently() async {
    await TokenManager.clearTokens();
    await GetStorage().write('isLogin', false);
  }
}

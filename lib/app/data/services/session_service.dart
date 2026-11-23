import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:foddu/app/data/basic_provider.dart';
import 'package:foddu/app/modules/profile_legacy/profile/controllers/profile_controller.dart';
import 'package:foddu/app/modules/auth/auth_details.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:foddu/constants/app_exceptions.dart';
import 'package:foddu/constants/constants.dart';
import 'package:foddu/constants/firebase_notification.dart';
import 'package:foddu/constants/helper_functions.dart';
import 'package:foddu/core/services/cartServcie.dart';
import 'package:foddu/core/services/wishlistService.dart';
import 'package:foddu/services/api_cache.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Single owner of "is this session still valid" decisions.
///
/// - [expire] is the only place a dead session is torn down. It is idempotent
///   (many in-flight requests can fail with 401 at once), does all local work
///   first so it can never hang on Firebase/network, navigates exactly once
///   and shows the "session expired" notice only after Login is on screen.
/// - [validateAtLaunch] confirms the stored session once, before the first
///   screen is chosen, so a dead session goes straight to Login instead of
///   flashing the app and being kicked out mid-load.
class SessionService {
  SessionService._();

  static bool _isExpiring = false;

  /// Shown once the Login screen is visible (never while routes are being
  /// replaced, when a snackbar would attach to a dying Scaffold).
  static String? pendingNotice;

  /// Keys that contain account/session data. Other app preferences and local
  /// conveniences (theme, currency, recent searches, store settings) survive.
  static const _sessionKeys = [
    'userData',
    'isLogin',
    'token',
    'refreshToken',
    'accessToken',
    'tokenExpiry',
    'otpEmail',
    'auth_token',
    'user_name',
    'user_email',
    'user_id',
    'userEmail',
    'userName',
    'userId',
    'userDetails',
    'local_cart',
    'cart',
    'wishlist',
  ];

  static void showPendingNotice() {
    final notice = pendingNotice;
    if (notice == null) return;
    pendingNotice = null;
    HelperFunctions().showSnackBarError(notice);
  }

  /// Wipes the local session: storage, caches, reactive login flag and the
  /// user data held in long-lived services. Pure local work, never awaits
  /// Firebase or the network.
  static Future<void> clearLocalSession() async {
    final box = GetStorage();
    for (final key in _sessionKeys) {
      await box.remove(key);
    }
    await ApiCache.clear();
    await FirebaseHelpers.clearLocalNotifications();
    AuthDetails.loggedIn.value = false;
    try {
      if (Get.isRegistered<WishListService>()) {
        WishListService.to.wishListItems.clear();
        WishListService.to.loadError.value = false;
      }
      if (Get.isRegistered<CartService>()) {
        CartService.to.cartItems.clear();
        CartService.to.subTotal.value = 0;
        CartService.to.total.value = 0;
        CartService.to.loadError.value = false;
      }
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().profiledata.clear();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('SessionService reset error: $e');
    }
  }

  /// User initiated sign-out: start server/FCM cleanup without making local
  /// sign-out wait on either network service.
  static Future<void> signOut() async {
    final box = GetStorage();
    final userData = box.read('userData');
    final userId = userData is Map
        ? (userData['_id'] ?? userData['id'])?.toString()
        : null;
    final useMobileLogin = isOtpLogin;

    unawaited(_requestServerLogout());
    await clearLocalSession();
    unsubscribeFromPushInBackground(userId);
    useMobileLogin
        ? Get.offAllNamed(Routes.MOBILELOGIN)
        : Get.offAllNamed(Routes.LOGIN);
  }

  static Future<void> _requestServerLogout() async {
    try {
      await BasicProvider('auth/logout').postRequest({});
    } catch (_) {
      // Local logout must complete even when the API is unavailable.
    }
  }

  /// Best-effort FCM topic cleanup. Fire-and-forget: Firebase can hang when
  /// unreachable and must never block sign-out.
  static void unsubscribeFromPushInBackground(String? userId) {
    unawaited(FirebaseHelpers.afterLogoutUnsubscribe(userId: userId));
  }

  /// Tears down a genuinely expired session (401/403 on an authenticated
  /// call). Never call this for network errors or 5xx.
  static Future<void> expire({String? message}) async {
    // Already torn down (or never signed in): nothing to do.
    if (_isExpiring || !AuthDetails.isUserLogin()) return;
    _isExpiring = true;
    try {
      if (kDebugMode) {
        debugPrint('SessionService.expire: ${message ?? "session ended"}');
      }
      final userData = GetStorage().read('userData');
      final userId = userData is Map ? userData['_id']?.toString() : null;
      final otpLogin = isOtpLogin;

      await clearLocalSession();
      unsubscribeFromPushInBackground(userId);

      pendingNotice = "Your session seems to be expired!";
      otpLogin
          ? Get.offAllNamed(Routes.MOBILELOGIN)
          : Get.offAllNamed(Routes.LOGIN);
      // Let the fade-in finish so the message lands on the Login screen.
      Future.delayed(const Duration(milliseconds: 400), showPendingNotice);
    } finally {
      _isExpiring = false;
    }
  }

  /// Called before `runApp`. Returns true when the stored session is still
  /// usable. A definitive rejection (401/403) clears the session silently
  /// and queues the notice for Login; offline/timeouts/5xx keep the session.
  static Future<bool> validateAtLaunch() async {
    if (!AuthDetails.isUserLogin()) return false;
    final token = AuthDetails.getToken();
    if (token == null || token.isEmpty) {
      await clearLocalSession();
      return false;
    }
    try {
      final profile = await BasicProvider('auth/customer/profile')
          .getRequest(useCache: false, retry: false)
          .timeout(const Duration(seconds: 8));
      if (profile != null) GetStorage().write('userData', profile);
    } on UnAuthorizedException {
      final userData = GetStorage().read('userData');
      final userId = userData is Map ? userData['_id']?.toString() : null;
      await clearLocalSession();
      unsubscribeFromPushInBackground(userId);
      pendingNotice = "Your session seems to be expired!";
      return false;
    } catch (_) {
      // Offline / timeout / 5xx: keep the session, normal calls will retry.
    }
    return true;
  }
}

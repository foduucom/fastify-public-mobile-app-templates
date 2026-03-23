import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/routes/app_pages.dart';

class AuthDetails with BaseController {
  static final box = GetStorage();

  // ─────────────────────────────────────────────────────────────
  //  KEYS
  // ─────────────────────────────────────────────────────────────
  static const _kUserData    = 'userData';
  static const _kIsLogin     = 'isLogin';
  static const _kToken       = 'token';
  static const _kTokenExpiry = 'tokenExpiry';
  static const _kIntroViewed = 'isIntroViewed';
  static const _kOtpEmail    = 'otpEmail';

  // ─────────────────────────────────────────────────────────────
  //  AUTH CHECKS
  // ─────────────────────────────────────────────────────────────

  /// Returns true if userData is stored
  static bool checkAuthentication() {
    try {
      return box.read(_kUserData) != null;
    } catch (e) {
      debugPrint('checkAuthentication error: $e');
      return false;
    }
  }

  /// Returns true if isLogin flag is set AND a token exists
  static bool isUserLogin() {
    try {
      final isLogin = box.read(_kIsLogin);
      final hasToken = getToken() != null;
      return (isLogin == true || isLogin == 'true') && hasToken;
    } catch (e) {
      debugPrint('isUserLogin error: $e');
      return false;
    }
  }

  /// Returns true if onboarding/intro was already viewed
  static bool isIntroViewed() {
    try {
      return box.read(_kIntroViewed) == true;
    } catch (e) {
      debugPrint('isIntroViewed error: $e');
      return false;
    }
  }

  static void markIntroViewed() {
    box.write(_kIntroViewed, true);
  }

  // ─────────────────────────────────────────────────────────────
  //  TOKEN
  // ─────────────────────────────────────────────────────────────

  /// Get stored bearer token
  static String? getToken() {
    try {
      return box.read<String?>(_kToken);
    } catch (e) {
      debugPrint('getToken error: $e');
      return null;
    }
  }

  /// Save token directly (called after OTP verify)
  static void saveToken(String token) {
    box.write(_kToken, token);
  }

  /// Check if token is expired (if expiry was stored)
  static bool isTokenExpired() {
    try {
      final expiry = box.read<String?>(_kTokenExpiry);
      if (expiry == null) return false;
      return DateTime.now().isAfter(DateTime.parse(expiry));
    } catch (e) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  OTP EMAIL (temp storage during auth flow)
  // ─────────────────────────────────────────────────────────────

  /// Save email before navigating to OTP screen
  static void saveOtpEmail(String email) {
    box.write(_kOtpEmail, email);
  }

  /// Get the email saved for OTP verification
  static String? getOtpEmail() {
    return box.read<String?>(_kOtpEmail);
  }

  static void clearOtpEmail() {
    box.remove(_kOtpEmail);
  }

  // ─────────────────────────────────────────────────────────────
  //  SAVE LOGIN RESPONSE (called after OTP verify success)
  // ─────────────────────────────────────────────────────────────

  /// Handles all response shapes your API might return:
  ///   { access_token: "..." }
  ///   { token: "..." }
  ///   { token: { value: "...", expiry: "..." } }
  static void saveLoginResponse(dynamic response) {
    if (response == null) return;

    try {
      // Save full user data
      box.write(_kUserData, response);
      box.write(_kIsLogin, true);

      // ── Handle access_token (OTP flow) ──────────────────────
      if (response['access_token'] != null) {
        box.write(_kToken, response['access_token'].toString());
      }
      // ── Handle token string ──────────────────────────────────
      else if (response['token'] != null) {
        if (response['token'] is Map) {
          box.write(_kToken, response['token']['value']);
          if (response['token']['expiry'] != null) {
            box.write(_kTokenExpiry, response['token']['expiry']);
          }
        } else {
          box.write(_kToken, response['token'].toString());
        }
      }

      // Clear temp OTP email after successful login
      clearOtpEmail();

      debugPrint('✅ Login response saved. Token: ${getToken()}');
    } catch (e) {
      debugPrint('saveLoginResponse error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  USER DETAILS
  // ─────────────────────────────────────────────────────────────

  /// Get locally stored user data
  static dynamic getUserDetails() {
    try {
      return box.read(_kUserData);
    } catch (e) {
      debugPrint('getUserDetails error: $e');
      return null;
    }
  }

  /// Convenience getters from stored userData
  static String get userName {
    try {
      return getUserDetails()?['name'] ?? '';
    } catch (_) { return ''; }
  }

  static String get userEmail {
    try {
      return getUserDetails()?['email'] ?? getOtpEmail() ?? '';
    } catch (_) { return ''; }
  }

  static String get userAvatar {
    try {
      return getUserDetails()?['avatar'] ?? '';
    } catch (_) { return ''; }
  }

  /// Fetch latest profile from server and update local storage
  Future<dynamic> updateUserDetailsFromServer() async {
    if (!AuthDetails.isUserLogin()) return null;

    try {
      final response = await BasicProvider('public/customer/profile')
          .getRequest()
          .catchError(handleError);

      if (response != null) {
        box.write(_kUserData, response);
        debugPrint('✅ User profile updated from server');
        return response;
      }
    } catch (e) {
      debugPrint('updateUserDetailsFromServer error: $e');
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  //  LOGOUT
  // ─────────────────────────────────────────────────────────────

  /// Full logout — clears all stored auth data and redirects
  static Future<void> logout() async {
    try {
      // Optional: call logout API
      await BasicProvider('auth/logout').postRequest({}).catchError((_) {});
    } catch (_) {}

    // Clear all stored keys
    box.remove(_kUserData);
    box.remove(_kIsLogin);
    box.remove(_kToken);
    box.remove(_kTokenExpiry);
    box.remove(_kOtpEmail);

    debugPrint('✅ Logged out — storage cleared');
    Get.offAllNamed(Routes.CREATE_ACCOUNT);
  }
}

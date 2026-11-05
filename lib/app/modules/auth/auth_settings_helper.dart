import 'package:get_storage/get_storage.dart';

/// Helper class to manage authentication settings from API.
///
/// Source of truth: `data.storeSettings.auth_preference` from
/// `GET /api/public-settings`. The `auth_method` field is the MASTER key.
///
/// Values of `auth_method`:
///   - "email_otp"       → Email OTP flow (default / safe fallback)
///   - "email_password"  → Email + Password flow
///   - "phone_otp"       → Phone / WhatsApp OTP flow
class AuthSettingsHelper {
  static final _box = GetStorage();

  /// Get auth preference from storage
  static Map<String, dynamic>? getAuthPreference() {
    try {
      return _box.read('auth_preference');
    } catch (e) {
      print('Error reading auth preference: $e');
      return null;
    }
  }

  /// Returns the master `auth_method` from API response.
  /// Defaults to "email_otp" when storage is unpopulated (safe passwordless default).
  static String getAuthMethod() {
    final authPref = getAuthPreference();
    if (authPref == null) return 'email_otp';
    return (authPref['auth_method'] as String?) ?? 'email_otp';
  }

  /// Check if email OTP authentication is enabled
  static bool isEmailOtpEnabled() {
    final authPref = getAuthPreference();
    if (authPref == null) return true; // Safe default
    if (authPref['auth_method'] == 'email_otp') return true;
    return authPref['email_otp'] == true;
  }

  /// Check if email/password authentication is enabled
  /// Defaults to false so password is only enabled when explicitly configured.
  static bool isEmailPasswordEnabled() {
    final authPref = getAuthPreference();
    if (authPref == null) return false;
    if (authPref['auth_method'] == 'email_password') return true;
    return authPref['email_password'] == true;
  }

  /// Check if mobile authentication is enabled
  static bool isMobileOtpEnabled() {
    final authPref = getAuthPreference();
    if (authPref == null) return false;
    if (authPref['auth_method'] == 'phone_otp') return true;
    return authPref['phone_otp'] == true || authPref['mobile_otp'] == true;
  }

  /// Get the current authentication type
  static String getAuthType() {
    switch (getAuthMethod()) {
      case 'email_password':
        return 'password';
      case 'phone_otp':
        return 'mobile_otp';
      case 'email_otp':
      default:
        return 'otp';
    }
  }

  /// Save auth preference to storage
  static void saveAuthPreference(Map<String, dynamic> authPref) {
    try {
      _box.write('auth_preference', authPref);
    } catch (e) {
      print('Error saving auth preference: $e');
    }
  }
}

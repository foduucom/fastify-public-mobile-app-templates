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
      final value = _box.read('auth_preference');
      return value is Map ? Map<String, dynamic>.from(value) : null;
    } catch (e) {
      print('Error reading auth preference: $e');
      return null;
    }
  }

  static bool _toBool(dynamic value, {required bool defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    switch (value.toString().trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
        return true;
      case 'false':
      case '0':
      case 'no':
        return false;
      default:
        return defaultValue;
    }
  }

  static String _normalizeMethod(dynamic value) {
    switch (value?.toString().trim().toLowerCase()) {
      case 'otp':
      case 'email_otp':
        return 'email_otp';
      case 'password':
      case 'email_password':
        return 'email_password';
      case 'mobile_otp':
      case 'phone_otp':
        return 'phone_otp';
      default:
        return '';
    }
  }

  /// Returns the master `auth_method` from API response.
  /// Defaults to "email_otp" when storage is unpopulated (safe passwordless default).
  static String getAuthMethod() {
    final authPref = getAuthPreference();
    if (authPref == null) return 'email_otp';
    final configured = _normalizeMethod(authPref['auth_method']);
    if (configured.isNotEmpty) return configured;
    if (_toBool(authPref['email_otp'], defaultValue: false)) {
      return 'email_otp';
    }
    if (_toBool(authPref['phone_otp'] ?? authPref['mobile_otp'],
        defaultValue: false)) {
      return 'phone_otp';
    }
    if (_toBool(authPref['email_password'], defaultValue: false)) {
      return 'email_password';
    }
    return 'email_otp';
  }

  /// Check if email OTP authentication is enabled
  static bool isEmailOtpEnabled() {
    final authPref = getAuthPreference();
    if (authPref == null) return true; // Safe default
    final method = _normalizeMethod(authPref['auth_method']);
    if (method.isNotEmpty) return method == 'email_otp';
    return _toBool(authPref['email_otp'], defaultValue: false);
  }

  /// Check if email/password authentication is enabled
  /// Defaults to false so password is only enabled when explicitly configured.
  static bool isEmailPasswordEnabled() {
    final authPref = getAuthPreference();
    if (authPref == null) return false;
    final method = _normalizeMethod(authPref['auth_method']);
    if (method.isNotEmpty) return method == 'email_password';
    return _toBool(authPref['email_password'], defaultValue: false);
  }

  /// Check if mobile authentication is enabled
  static bool isMobileOtpEnabled() {
    final authPref = getAuthPreference();
    if (authPref == null) return false;
    final method = _normalizeMethod(authPref['auth_method']);
    if (method.isNotEmpty) return method == 'phone_otp';
    return _toBool(
      authPref['phone_otp'] ?? authPref['mobile_otp'],
      defaultValue: false,
    );
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

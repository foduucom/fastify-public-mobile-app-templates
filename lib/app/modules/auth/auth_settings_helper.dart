import 'package:get_storage/get_storage.dart';

/// Helper class to manage authentication settings from API
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

  /// Check if email OTP authentication is enabled
  static bool isEmailOtpEnabled() {
    final authPref = getAuthPreference();
    return authPref?['email_otp'] ?? false;
  }

  /// Check if email/password authentication is enabled
  static bool isEmailPasswordEnabled() {
    final authPref = getAuthPreference();
    return authPref?['email_password'] ?? true;
  }

  /// Check if mobile authentication is enabled
  static bool isEmailMobileEnabled() {
    final authPref = getAuthPreference();
    return authPref?['email_mobile'] ?? false;
  }

  /// Get the current authentication type
  static String getAuthType() {
    if (isEmailOtpEnabled()) return 'otp';
    if (isEmailPasswordEnabled()) return 'password';
    return 'password'; // default fallback
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

import 'package:get_storage/get_storage.dart';

/// Helper class to manage authentication settings from API
class AuthSettingsHelper {
  static final _box = GetStorage();

  /// Get auth preference from storage
  static Map<String, dynamic>? getAuthPreference() {
    try {
      final data = _box.read('auth_preference');
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (e) {
      print('Error reading auth preference: $e');
      return null;
    }
  }

  /// Helper to safely parse dynamic boolean-like values
  static bool _toBool(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return defaultValue;
  }

  /// Check if email OTP authentication is enabled
  static bool isEmailOtpEnabled() {
    final authPref = getAuthPreference();
    if (authPref == null) return false;
    final authMethod = authPref['auth_method']?.toString().toLowerCase().trim();
    if (authMethod == 'email_otp' || authMethod == 'otp') return true;
    if (authMethod != null && authMethod.isNotEmpty) return false;
    return _toBool(authPref['email_otp'], false);
  }

  /// Check if email/password authentication is enabled
  static bool isEmailPasswordEnabled() {
    final authPref = getAuthPreference();
    if (authPref == null) return true;
    final authMethod = authPref['auth_method']?.toString().toLowerCase().trim();
    if (authMethod == 'password' || authMethod == 'email_password') return true;
    if (authMethod != null && authMethod.isNotEmpty) return false;
    return _toBool(authPref['email_password'], true);
  }

  /// Check if mobile authentication is enabled
  static bool isMobileOtpEnabled() {
    final authPref = getAuthPreference();
    if (authPref == null) return false;
    final authMethod = authPref['auth_method']?.toString().toLowerCase().trim();
    if (authMethod == 'mobile_otp') return true;
    if (authMethod != null && authMethod.isNotEmpty) return false;
    return _toBool(authPref['mobile_otp'], false);
  }

  /// Get the current authentication type: 'otp', 'mobile_otp', or 'password'
  static String getAuthType() {
    final authPref = getAuthPreference();
    final authMethod = authPref?['auth_method']?.toString().toLowerCase().trim();

    if (authMethod == 'email_otp' || authMethod == 'otp') return 'otp';
    if (authMethod == 'mobile_otp') return 'mobile_otp';
    if (authMethod == 'password' || authMethod == 'email_password') return 'password';

    // Fallback based on individual flags
    if (isEmailOtpEnabled()) return 'otp';
    if (isMobileOtpEnabled()) return 'mobile_otp';
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

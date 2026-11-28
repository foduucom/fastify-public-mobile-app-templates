import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Centralized, reactive runtime configuration for multi-tenant Web emulator
/// and white-label mobile builds.
///
/// Resolution priority:
/// 1. Runtime Web URL query/fragment params (`domain_name`, `api_key`, `slug`, `socket_url`, `theme`)
/// 2. Compile-time `--dart-define` values (`DOMAIN_NAME`, `ACCESS_KEY`, `SOCKET_URL`, `APP_MODE`)
/// 3. Persisted per-domain snapshot in `GetStorage`
/// 4. Safe built-in defaults
class AppConfig extends GetxController {
  AppConfig._();

  static final AppConfig _fallback = AppConfig._();

  static AppConfig get instance =>
      Get.isRegistered<AppConfig>() ? Get.find<AppConfig>() : _fallback;

  // Compile-time overrides for white-label native builds.
  static const String _envDomain = String.fromEnvironment('DOMAIN_NAME');
  static const String _envAccessKey = String.fromEnvironment('ACCESS_KEY');
  static const String _envSocketUrl = String.fromEnvironment('SOCKET_URL');
  static const String _envAppMode = String.fromEnvironment('APP_MODE');
  static const String _envAppName = String.fromEnvironment('APP_NAME');
  static const String _envSupportEmail = String.fromEnvironment('SUPPORT_EMAIL');
  static const String _envSupportContact =
      String.fromEnvironment('SUPPORT_CONTACT');

  static const String _defaultDomain = 'foduu-electronics-store.foduu.store';
  static const String _defaultSocketUrl = 'https://studio.foduu.store/';
  static const String _defaultAccessKey =
      '05d10194b9290dd506a530a0693b7f551a39a395989c6bb1';
  static const String _defaultAppMode = 'test';
  static const String _defaultAppName = 'Store';
  static const String _defaultSupportEmail = 'support@vbought.com';
  static const String _defaultSupportContact = '1-800-570-7777';

  String websiteDomain =
      _envDomain.isNotEmpty ? _envDomain : _defaultDomain;
  String accessKey =
      _envAccessKey.isNotEmpty ? _envAccessKey : _defaultAccessKey;
  String socketUrl =
      _envSocketUrl.isNotEmpty ? _normalizeTrailingSlash(_envSocketUrl) : _defaultSocketUrl;
  String appMode = _envAppMode.isNotEmpty ? _envAppMode : _defaultAppMode;

  String appName = _envAppName.isNotEmpty ? _envAppName : _defaultAppName;
  String storeLogo = '';
  String supportEmail =
      _envSupportEmail.isNotEmpty ? _envSupportEmail : _defaultSupportEmail;
  String supportContact = _envSupportContact.isNotEmpty
      ? _envSupportContact
      : _defaultSupportContact;
  bool isOtpLogin = false;

  String initialSlug = 'home';
  String activeThemeSlug = '';
  String activeThemeVersion = '';
  String fontFamily = '';
  double? borderRadiusOverride;
  double? buttonBorderRadiusOverride;

  /// Always derived dynamically from [websiteDomain].
  String get url => 'https://$websiteDomain/';
  String get assetURL => '${url}images/';
  String get apiURL => '${url}api/';

  String get _storageNamespaceKey => 'app_config_$websiteDomain';

  /// Initializes [AppConfig] and registers it permanently with GetX.
  static Future<AppConfig> init() async {
    final config = _fallback;
    config._resolveInitialEnvironment();
    config._restoreFromStorage();
    if (!Get.isRegistered<AppConfig>()) {
      Get.put<AppConfig>(config, permanent: true);
    }
    return config;
  }

  void _resolveInitialEnvironment() {
    if (!kIsWeb) return;

    final params = _extractWebParams();
    final domain = params['domain_name'] ?? params['domain'];
    final key = params['api_key'] ?? params['access_key'];
    final slug = params['slug'];
    final socket = params['socket_url'] ?? params['studio_url'];
    final theme = params['theme'] ?? params['theme_slug'] ?? params['theme_id'];

    if (domain != null && domain.trim().isNotEmpty) {
      websiteDomain = _cleanDomain(domain);
    }
    if (key != null && key.trim().isNotEmpty) {
      accessKey = key.trim();
    }
    if (slug != null && slug.trim().isNotEmpty) {
      initialSlug = slug.trim();
    }
    if (socket != null && socket.trim().isNotEmpty) {
      socketUrl = _normalizeTrailingSlash(socket);
    } else if (_envSocketUrl.isEmpty &&
        Uri.base.hasAuthority &&
        Uri.base.path.contains('/owner/emulator')) {
      socketUrl = _normalizeTrailingSlash(Uri.base.origin);
    }
    if (theme != null && theme.trim().isNotEmpty) {
      activeThemeSlug = theme.trim();
    }
  }

  Map<String, String> _extractWebParams() {
    final merged = <String, String>{};
    merged.addAll(Uri.base.queryParameters);
    if (Uri.base.fragment.isNotEmpty) {
      try {
        final fragmentUri = Uri.parse(Uri.base.fragment);
        fragmentUri.queryParameters.forEach((k, v) {
          merged.putIfAbsent(k, () => v);
        });
      } catch (_) {}
    }
    return merged;
  }

  void _restoreFromStorage() {
    final box = GetStorage();
    final saved = box.read(_storageNamespaceKey);
    if (saved is Map) {
      final name = saved['appName']?.toString().trim() ?? '';
      if (name.isNotEmpty) appName = name;

      final logo = saved['storeLogo']?.toString().trim() ?? '';
      if (logo.isNotEmpty) storeLogo = logo;

      final email = saved['supportEmail']?.toString().trim() ?? '';
      if (email.isNotEmpty) supportEmail = email;

      final contact = saved['supportContact']?.toString().trim() ?? '';
      if (contact.isNotEmpty) supportContact = contact;

      if (saved['isOtpLogin'] is bool) {
        isOtpLogin = saved['isOtpLogin'] as bool;
      }

      final themeSlug = saved['activeThemeSlug']?.toString().trim() ?? '';
      if (themeSlug.isNotEmpty) activeThemeSlug = themeSlug;

      final themeVersion = saved['activeThemeVersion']?.toString().trim() ?? '';
      if (themeVersion.isNotEmpty) activeThemeVersion = themeVersion;

      final font = saved['fontFamily']?.toString().trim() ?? '';
      if (font.isNotEmpty) fontFamily = font;

      final radius = _toDouble(saved['borderRadiusOverride']);
      if (radius != null) borderRadiusOverride = radius;

      final btnRadius = _toDouble(saved['buttonBorderRadiusOverride']);
      if (btnRadius != null) buttonBorderRadiusOverride = btnRadius;
    }

    // Keep legacy flat keys synchronized with the active domain so existing
    // widgets reading GetStorage() directly stay consistent when switching domains.
    if (saved is Map) {
      if (appName != _defaultAppName) box.write('store_name', appName);
      if (storeLogo.isNotEmpty) box.write('store_logo', storeLogo);
      if (saved['authPreference'] is Map) {
        box.write(
          'auth_preference',
          Map<String, dynamic>.from(saved['authPreference'] as Map),
        );
      }
    } else if (kIsWeb) {
      box.remove('store_name');
      box.remove('store_logo');
      box.remove('auth_preference');
    }
  }

  /// Extracts `storeSettings` from a `public-settings` API payload, updates
  /// runtime constants + storage, and returns the parsed settings map (if any).
  Map<String, dynamic>? applyPublicSettings(dynamic response) {
    final settings = _extractStoreSettings(response);
    if (settings == null) return null;

    final box = GetStorage();

    final name = _firstNonEmpty([
      settings['name'],
      settings['store_name'],
      settings['app_name'],
    ]);
    if (name != null) {
      appName = name;
      box.write('store_name', name);
    }

    final logo = _firstNonEmpty([
      settings['logo'],
      settings['app_logo'],
      settings['store_logo'],
    ]);
    if (logo != null) {
      storeLogo = logo;
      box.write('store_logo', logo);
    }

    final email = _firstNonEmpty([
      settings['support_email'],
      settings['email'],
      settings['contact_email'],
    ]);
    if (email != null) {
      supportEmail = email;
    }

    final contact = _firstNonEmpty([
      settings['support_contact'],
      settings['support_phone'],
      settings['phone'],
      settings['contact_number'],
      settings['mobile'],
    ]);
    if (contact != null) {
      supportContact = contact;
    }

    final authPref = settings['auth_preference'];
    if (authPref is Map) {
      final normalizedAuth = Map<String, dynamic>.from(authPref);
      box.write('auth_preference', normalizedAuth);
      isOtpLogin = _resolveOtpLogin(normalizedAuth, settings);
    } else if (settings['is_otp_login'] is bool) {
      isOtpLogin = settings['is_otp_login'] as bool;
    }

    // Active theme metadata (e.g. foduu_ecommerce, zouhi, new_fastify_template).
    final activeTheme = settings['active_theme'] ??
        settings['app_theme'] ??
        settings['theme_data'];
    if (activeTheme is Map) {
      final slug = _firstNonEmpty([
        activeTheme['slug'],
        activeTheme['name'],
        activeTheme['template'],
        activeTheme['theme_name'],
      ]);
      if (slug != null) activeThemeSlug = slug;

      final version = _firstNonEmpty([activeTheme['version']]);
      if (version != null) activeThemeVersion = version;

      final font = _firstNonEmpty([
        activeTheme['font_family'],
        activeTheme['fontFamily'],
      ]);
      if (font != null) fontFamily = font;

      borderRadiusOverride = _toDouble(activeTheme['border_radius']) ??
          borderRadiusOverride;
      buttonBorderRadiusOverride =
          _toDouble(activeTheme['button_border_radius']) ??
              buttonBorderRadiusOverride;
    } else {
      final slug = _firstNonEmpty([
        settings['active_theme'],
        settings['theme_name'],
        settings['template'],
        settings['theme'],
      ]);
      if (slug != null) activeThemeSlug = slug;

      final font = _firstNonEmpty([
        settings['font_family'],
        settings['fontFamily'],
      ]);
      if (font != null) fontFamily = font;

      borderRadiusOverride =
          _toDouble(settings['border_radius']) ?? borderRadiusOverride;
      buttonBorderRadiusOverride =
          _toDouble(settings['button_border_radius']) ??
              buttonBorderRadiusOverride;
    }

    box.write(_storageNamespaceKey, {
      'appName': appName,
      'storeLogo': storeLogo,
      'supportEmail': supportEmail,
      'supportContact': supportContact,
      'isOtpLogin': isOtpLogin,
      'activeThemeSlug': activeThemeSlug,
      'activeThemeVersion': activeThemeVersion,
      'fontFamily': fontFamily,
      'borderRadiusOverride': borderRadiusOverride,
      'buttonBorderRadiusOverride': buttonBorderRadiusOverride,
      if (authPref is Map) 'authPreference': Map<String, dynamic>.from(authPref),
    });

    update();
    return settings;
  }

  /// Resolves the theme color map from `public-settings` (`storeSettings` or
  /// nested `active_theme`).
  Map<String, dynamic>? extractThemePalette(Map<String, dynamic> settings) {
    final direct = settings['app_theme_color'] ?? settings['theme_color'];
    if (direct is Map) {
      return Map<String, dynamic>.from(direct);
    }
    final activeTheme = settings['active_theme'] ??
        settings['app_theme'] ??
        settings['theme_data'];
    if (activeTheme is Map) {
      final nested = activeTheme['app_theme_color'] ??
          activeTheme['theme_color'] ??
          activeTheme['colors'];
      if (nested is Map) {
        return Map<String, dynamic>.from(nested);
      }
    }
    return null;
  }

  static Map<String, dynamic>? _extractStoreSettings(dynamic response) {
    if (response is! Map) return null;
    if (response['storeSettings'] is Map) {
      return Map<String, dynamic>.from(response['storeSettings'] as Map);
    }
    if (response['data'] is Map &&
        (response['data'] as Map)['storeSettings'] is Map) {
      return Map<String, dynamic>.from(
        (response['data'] as Map)['storeSettings'] as Map,
      );
    }
    return null;
  }

  static bool _resolveOtpLogin(
    Map<String, dynamic> authPref,
    Map<String, dynamic> settings,
  ) {
    if (settings['is_otp_login'] is bool) {
      return settings['is_otp_login'] as bool;
    }
    final otpEnabled = authPref['otp_login'] == true ||
        authPref['mobile_login'] == true ||
        authPref['phone_login'] == true;
    final emailEnabled = authPref['email_login'] == true ||
        authPref['password_login'] == true;
    if (otpEnabled && !emailEnabled) return true;
    final loginType = authPref['login_type']?.toString().toLowerCase().trim();
    if (loginType == 'otp' || loginType == 'mobile') return true;
    return false;
  }

  static String _cleanDomain(String raw) {
    var d = raw.trim();
    d = d.replaceFirst(RegExp(r'^https?://'), '');
    if (d.endsWith('/')) d = d.substring(0, d.length - 1);
    return d;
  }

  static String _normalizeTrailingSlash(String raw) {
    final trimmed = raw.trim();
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }

  static String? _firstNonEmpty(List<dynamic> candidates) {
    for (final c in candidates) {
      if (c == null) continue;
      final s = c.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }
}

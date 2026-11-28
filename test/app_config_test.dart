import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/core/config/app_config.dart';
import 'package:get_storage/get_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync('app_config_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async {
        if (call.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      },
    );
    await GetStorage.init();
  });

  test('constants.dart URLs react dynamically to websiteDomain changes', () {
    websiteDomain = 'custom-store.foduu.store';
    expect(url, 'https://custom-store.foduu.store/');
    expect(apiURL, 'https://custom-store.foduu.store/api/');
    expect(assetURL, 'https://custom-store.foduu.store/images/');
  });

  test('AppConfig.applyPublicSettings hydrates store and theme fields', () {
    final settings = AppConfig.instance.applyPublicSettings({
      'storeSettings': {
        'name': 'Demo Electro',
        'logo': 'logo.png',
        'support_email': 'help@demoelectro.com',
        'support_contact': '+1-555-0100',
        'auth_preference': {'otp_login': true, 'email_login': false},
        'active_theme': {
          'slug': 'zouhi',
          'version': 'v1.0.0',
          'border_radius': 12,
          'app_theme_color': {
            'light': {'primary': '#17191c', 'secondary': '#c79c68'},
          },
        },
      },
    });

    expect(settings, isNotNull);
    expect(appName, 'Demo Electro');
    expect(supportEmail, 'help@demoelectro.com');
    expect(supportContact, '+1-555-0100');
    expect(isOtpLogin, isTrue);
    expect(AppConfig.instance.activeThemeSlug, 'zouhi');
    expect(AppConfig.instance.activeThemeVersion, 'v1.0.0');
    expect(AppConfig.instance.borderRadiusOverride, 12.0);
    expect(
      AppConfig.instance.extractThemePalette(settings!)?['light'],
      isA<Map>(),
    );
  });
}

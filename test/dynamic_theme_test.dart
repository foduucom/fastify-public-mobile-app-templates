import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  const MethodChannel pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('dynamic_theme_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      return null;
    });
    await GetStorage.init();
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('DynamicThemeManager (zero fallback)', () {
    setUp(() {
      DynamicThemeManager().clearTheme();
    });

    test('starts without a theme and rejects all-black API payload', () {
      final manager = DynamicThemeManager();
      expect(manager.hasTheme, isFalse);

      final updated = manager.updateFromApi({
        'light': {
          'primary': '#000000',
          'secondary': '#000000',
          'background': '#000000',
          'surface': '#000000',
          'onPrimary': '#000000',
          'onBackground': '#000000',
          'onSurface': '#000000',
        },
        'dark': {
          'primary': '#000000',
          'secondary': '#000000',
          'background': '#000000',
          'surface': '#000000',
          'onPrimary': '#000000',
          'onBackground': '#000000',
          'onSurface': '#000000',
        },
      });

      expect(updated, isFalse);
      expect(manager.hasTheme, isFalse);
    });

    test('applies valid backend palette and semantic extension', () {
      final manager = DynamicThemeManager();
      final updated = manager.updateFromApi({
        'light': {
          'primary': '#17191C',
          'onPrimary': '#FFFFFF',
          'secondary': '#C79C60',
          'onSecondary': '#17191C',
          'background': '#FFFFFF',
          'onBackground': '#17191C',
          'surface': '#FFFFFF',
          'onSurface': '#17191C',
          'surfaceVariant': '#F8FAFC',
          'onSurfaceVariant': '#626364',
          'outline': '#E5E7EB',
          'error': '#B83B36',
          'onError': '#FFFFFF',
        },
      });

      expect(updated, isTrue);
      expect(manager.hasTheme, isTrue);

      final colors = manager.lightColors;
      expect(colors.primary, const Color(0xFF17191C));
      expect(colors.onPrimary, const Color(0xFFFFFFFF));
      expect(colors.secondary, const Color(0xFFC79C60));
      expect(colors.onSecondary, const Color(0xFF17191C));
      expect(colors.background, const Color(0xFFFFFFFF));
      expect(colors.surface, const Color(0xFFFFFFFF));
      expect(colors.surfaceVariant, const Color(0xFFF8FAFC));
      expect(colors.onSurfaceVariant, const Color(0xFF626364));
      expect(colors.outline, const Color(0xFFE5E7EB));
      expect(colors.error, const Color(0xFFB83B36));
      expect(colors.discountPrice, const Color(0xFFC79C60));

      final semantic = AppSemanticColors.fromColorScheme(
        ColorScheme.light(
          primary: colors.primary,
          secondary: colors.secondary,
          onSecondary: colors.onSecondary,
          onSurfaceVariant: colors.onSurfaceVariant,
        ),
      );
      expect(semantic.discountPrice, const Color(0xFFC79C60));
      expect(semantic.mutedText, const Color(0xFF626364));
    });

    test('accepts Studio 8-key payload without error field', () {
      final manager = DynamicThemeManager();
      final updated = manager.updateFromApi({
        'light': {
          'primary': '#17191C',
          'onPrimary': '#FFFFFF',
          'secondary': '#C79C60',
          'onSecondary': '#17191C',
          'background': '#FFFFFF',
          'onBackground': '#17191C',
          'surface': '#FFFFFF',
          'onSurface': '#17191C',
        },
      });

      expect(updated, isTrue);
      expect(manager.hasTheme, isTrue);
      expect(manager.lightColors.primary, const Color(0xFF17191C));
      expect(manager.lightColors.secondary, const Color(0xFFC79C60));
    });
  });
}

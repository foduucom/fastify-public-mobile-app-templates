import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic e-commerce colors derived strictly from the backend theme payload.
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color price;
  final Color discountPrice;
  final Color mutedText;

  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.price,
    required this.discountPrice,
    required this.mutedText,
  });

  factory AppSemanticColors.fromColorScheme(ColorScheme scheme) {
    return AppSemanticColors(
      success: scheme.secondary,
      onSuccess: scheme.onSecondary,
      warning: scheme.secondary,
      onWarning: scheme.onSecondary,
      price: scheme.primary,
      discountPrice: scheme.secondary,
      mutedText: scheme.onSurfaceVariant,
    );
  }

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? price,
    Color? discountPrice,
    Color? mutedText,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      mutedText: mutedText ?? this.mutedText,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      onWarning: Color.lerp(onWarning, other.onWarning, t) ?? onWarning,
      price: Color.lerp(price, other.price, t) ?? price,
      discountPrice:
          Color.lerp(discountPrice, other.discountPrice, t) ?? discountPrice,
      mutedText: Color.lerp(mutedText, other.mutedText, t) ?? mutedText,
    );
  }
}

class AppThemeColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color error;

  final Color onPrimary;
  final Color onSecondary;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color onError;

  final Color outline;
  final Color surfaceVariant;
  final Color onSurfaceVariant;

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color price;
  final Color discountPrice;
  final Color mutedText;

  AppThemeColors._({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.error,
    required this.onPrimary,
    required this.onSecondary,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.onError,
    required this.outline,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.price,
    required this.discountPrice,
    required this.mutedText,
  });

  factory AppThemeColors.fromCoreColors({
    required Color primary,
    required Color secondary,
    required Color background,
    required Color error,
    required bool isDark,
    required Color onPrimary,
    required Color onSecondary,
    required Color onBackground,
    required Color surface,
    required Color onSurface,
    required Color onError,
    required Color outline,
    required Color surfaceVariant,
    required Color onSurfaceVariant,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? price,
    Color? discountPrice,
    Color? mutedText,
  }) {
    final resolvedSuccess = success ?? secondary;
    final resolvedWarning = warning ?? secondary;
    return AppThemeColors._(
      primary: primary,
      secondary: secondary,
      background: background,
      error: error,
      onPrimary: onPrimary,
      onSecondary: onSecondary,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      onError: onError,
      outline: outline,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      success: resolvedSuccess,
      onSuccess: onSuccess ?? _contrastOn(resolvedSuccess),
      warning: resolvedWarning,
      onWarning: onWarning ?? _contrastOn(resolvedWarning),
      price: price ?? primary,
      discountPrice: discountPrice ?? secondary,
      mutedText: mutedText ?? onSurfaceVariant,
    );
  }

  /// Neutral monochrome shell used ONLY before the backend supplies a theme.
  factory AppThemeColors.neutralShell({required bool isDark}) {
    const white = Colors.white;
    const black = Colors.black;
    final bg = isDark ? black : white;
    final fg = isDark ? white : black;
    return AppThemeColors.fromCoreColors(
      primary: fg,
      secondary: fg,
      background: bg,
      error: fg,
      isDark: isDark,
      onPrimary: bg,
      onSecondary: bg,
      onBackground: fg,
      surface: bg,
      onSurface: fg,
      onError: bg,
      outline: fg.withOpacity(0.18),
      surfaceVariant: Color.lerp(bg, fg, 0.06) ?? bg,
      onSurfaceVariant: fg.withOpacity(0.65),
    );
  }

  static Color _contrastOn(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  /// Parse strictly from API response. Returns null if required core tokens
  /// are missing or unparseable (no hardcoded brand fallback).
  static AppThemeColors? tryFromThemeMap(
      Map<String, dynamic> themeMap, bool isDark) {
    debugPrint('🌐 Parsing ${isDark ? "DARK" : "LIGHT"} theme colors');

    final primary = _hexToColor(themeMap['primary']?.toString());
    final secondary = _hexToColor(themeMap['secondary']?.toString());
    final background = _hexToColor(themeMap['background']?.toString());
    final surface = _hexToColor(themeMap['surface']?.toString()) ?? background;

    if (primary == null ||
        secondary == null ||
        background == null ||
        surface == null) {
      debugPrint('⚠️ Missing required backend theme colors for '
          '${isDark ? "DARK" : "LIGHT"} theme');
      return null;
    }

    // Studio's 8-key Theme Colors UI omits `error`; derive from `secondary`
    // when absent rather than rejecting an otherwise valid backend palette.
    final error = _hexToColor(themeMap['error']?.toString()) ?? secondary;

    final onBackground =
        _hexToColor(themeMap['onBackground']?.toString()) ??
            _contrastOn(background);
    final onSurface =
        _hexToColor(themeMap['onSurface']?.toString()) ?? _contrastOn(surface);
    final onPrimary =
        _hexToColor(themeMap['onPrimary']?.toString()) ?? _contrastOn(primary);
    final onSecondary =
        _hexToColor(themeMap['onSecondary']?.toString()) ??
            _contrastOn(secondary);
    final onError =
        _hexToColor(themeMap['onError']?.toString()) ?? _contrastOn(error);
    final surfaceVariant =
        _hexToColor(themeMap['surfaceVariant']?.toString()) ??
            (Color.lerp(surface, onSurface, 0.05) ?? surface);
    final onSurfaceVariant =
        _hexToColor(themeMap['onSurfaceVariant']?.toString()) ??
            onSurface.withOpacity(0.68);
    final outline = _hexToColor(themeMap['outline']?.toString()) ??
        onSurface.withOpacity(0.16);

    return AppThemeColors.fromCoreColors(
      primary: primary,
      secondary: secondary,
      background: background,
      error: error,
      isDark: isDark,
      onPrimary: onPrimary,
      onSecondary: onSecondary,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      onError: onError,
      outline: outline,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      success: _hexToColor(themeMap['success']?.toString()),
      onSuccess: _hexToColor(themeMap['onSuccess']?.toString()),
      warning: _hexToColor(themeMap['warning']?.toString()),
      onWarning: _hexToColor(themeMap['onWarning']?.toString()),
      price: _hexToColor(themeMap['price']?.toString()),
      discountPrice: _hexToColor(themeMap['discountPrice']?.toString()),
      mutedText: _hexToColor(themeMap['mutedText']?.toString()),
    );
  }

  static Color? _hexToColor(String? hexString) {
    if (hexString == null || hexString.trim().isEmpty) {
      return null;
    }

    hexString = hexString.trim().replaceAll('#', '');

    if (hexString.length == 6) {
      hexString = 'FF$hexString';
    }

    try {
      final color = Color(int.parse(hexString, radix: 16));
      debugPrint('🎨 Parsed color: #$hexString');
      return color;
    } catch (e) {
      debugPrint('❌ Failed to parse color: $hexString');
      return null;
    }
  }

  /// Convert to JSON for storage (store ALL colors for full persistence)
  Map<String, dynamic> toJson() {
    return {
      'primary': _colorToHex(primary),
      'onPrimary': _colorToHex(onPrimary),
      'secondary': _colorToHex(secondary),
      'onSecondary': _colorToHex(onSecondary),
      'background': _colorToHex(background),
      'onBackground': _colorToHex(onBackground),
      'surface': _colorToHex(surface),
      'onSurface': _colorToHex(onSurface),
      'error': _colorToHex(error),
      'onError': _colorToHex(onError),
      'outline': _colorToHex(outline),
      'surfaceVariant': _colorToHex(surfaceVariant),
      'onSurfaceVariant': _colorToHex(onSurfaceVariant),
      'success': _colorToHex(success),
      'onSuccess': _colorToHex(onSuccess),
      'warning': _colorToHex(warning),
      'onWarning': _colorToHex(onWarning),
      'price': _colorToHex(price),
      'discountPrice': _colorToHex(discountPrice),
      'mutedText': _colorToHex(mutedText),
    };
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}

/// Theme Manager using GetX for reactive updates
/// Strictly driven by backend API colors with no hardcoded brand fallback.
class DynamicThemeManager {
  static final DynamicThemeManager _instance = DynamicThemeManager._internal();
  factory DynamicThemeManager() => _instance;
  DynamicThemeManager._internal();

  final _box = GetStorage();
  static const String _lightThemeKey = 'app_theme_colors_light';
  static const String _darkThemeKey = 'app_theme_colors_dark';

  AppThemeColors? _lightColors;
  AppThemeColors? _darkColors;

  ThemeData? _cachedLightTheme;
  ThemeData? _cachedDarkTheme;

  /// True once at least a valid backend light theme has been loaded.
  bool get hasTheme => _lightColors != null;

  AppThemeColors get lightColors =>
      _lightColors ?? AppThemeColors.neutralShell(isDark: false);
  AppThemeColors get darkColors =>
      _darkColors ?? _lightColors ?? AppThemeColors.neutralShell(isDark: true);

  /// Get colors based on current brightness
  AppThemeColors getColors(Brightness brightness) {
    return brightness == Brightness.dark ? darkColors : lightColors;
  }

  /// Initialize theme from storage (strictly backend-cached, no brand fallback)
  Future<void> init() async {
    debugPrint('📦 Initializing DynamicThemeManager');

    // Load light theme
    final storedLight = _box.read(_lightThemeKey);
    if (storedLight != null) {
      debugPrint('💾 Light theme found in storage, loading...');
      final storedColors = Map<String, dynamic>.from(storedLight);
      final parsed = _isUsableThemeMap(storedColors)
          ? AppThemeColors.tryFromThemeMap(storedColors, false)
          : null;
      if (parsed != null) {
        _lightColors = parsed;
      } else {
        debugPrint('⚠️ Stored light theme is unusable; removing cached entry');
        _lightColors = null;
        _box.remove(_lightThemeKey);
      }
      _cachedLightTheme = null;
    } else {
      debugPrint('ℹ️ No stored light theme found; waiting for backend theme');
    }

    // Load dark theme
    final storedDark = _box.read(_darkThemeKey);
    if (storedDark != null) {
      debugPrint('💾 Dark theme found in storage, loading...');
      final storedColors = Map<String, dynamic>.from(storedDark);
      final parsed = _isUsableThemeMap(storedColors)
          ? AppThemeColors.tryFromThemeMap(storedColors, true)
          : null;
      if (parsed != null) {
        _darkColors = parsed;
      } else {
        debugPrint('⚠️ Stored dark theme is unusable; removing cached entry');
        _darkColors = null;
        _box.remove(_darkThemeKey);
      }
      _cachedDarkTheme = null;
    } else {
      debugPrint('ℹ️ No stored dark theme found');
    }
  }

  /// Update theme colors from API response
  /// Expected format: { "light": { "primary": "#xxx", "secondary": "#xxx", "background": "#xxx", "error": "#xxx" }, "dark": { ... } }
  bool updateFromApi(Map<String, dynamic> appThemeColor) {
    debugPrint('🌐 Updating themes from API');
    var updated = false;

    // Parse light theme
    final lightTheme = appThemeColor['light'];
    if (lightTheme is Map) {
      final lightColors = Map<String, dynamic>.from(lightTheme);
      final parsed = _isUsableThemeMap(lightColors)
          ? AppThemeColors.tryFromThemeMap(lightColors, false)
          : null;
      if (parsed != null) {
        _lightColors = parsed;
        _cachedLightTheme = null;
        _box.write(_lightThemeKey, _lightColors!.toJson());
        debugPrint('✅ Light theme updated & saved successfully');
        updated = true;
      } else {
        debugPrint('⚠️ Ignoring unusable light theme from API');
      }
    } else {
      debugPrint('⚠️ API response does not contain a light theme map');
    }

    // Parse dark theme
    final darkTheme = appThemeColor['dark'];
    if (darkTheme is Map) {
      final darkColors = Map<String, dynamic>.from(darkTheme);
      final parsed = _isUsableThemeMap(darkColors)
          ? AppThemeColors.tryFromThemeMap(darkColors, true)
          : null;
      if (parsed != null) {
        _darkColors = parsed;
        _cachedDarkTheme = null;
        _box.write(_darkThemeKey, _darkColors!.toJson());
        debugPrint('✅ Dark theme updated & saved successfully');
        updated = true;
      } else {
        debugPrint('⚠️ Ignoring unusable dark theme from API');
      }
    } else {
      debugPrint('⚠️ API response does not contain a dark theme map');
    }

    return updated;
  }

  /// Reject palettes whose core colors all collapse to the same value. This
  /// prevents malformed API responses (for example, every token set to black)
  /// from replacing a working app theme and being persisted across sessions.
  bool _isUsableThemeMap(Map<String, dynamic> themeMap) {
    const coreTokens = [
      'primary',
      'secondary',
      'background',
      'surface',
      'onPrimary',
      'onBackground',
      'onSurface',
    ];
    final providedTokens =
        coreTokens.where(themeMap.containsKey).toList(growable: false);
    if (providedTokens.length < 3) return false;

    final parsedColors = <Color>[];
    for (final token in providedTokens) {
      final value = themeMap[token];
      if (value is! String) return false;
      final color = AppThemeColors._hexToColor(value);
      if (color == null) return false;
      parsedColors.add(color);
    }

    return parsedColors.map((color) => color.value).toSet().length > 1;
  }

  /// Clear stored themes
  void clearTheme() {
    debugPrint('♻️ Clearing stored themes');
    _box.remove(_lightThemeKey);
    _box.remove(_darkThemeKey);
    _lightColors = null;
    _darkColors = null;
    _cachedLightTheme = null;
    _cachedDarkTheme = null;
  }

  /// Build LIGHT ThemeData
  ThemeData buildLightTheme() {
    _cachedLightTheme ??= _buildTheme(
      lightColors,
      _lightColors == null ? Brightness.light : Brightness.light,
    );
    return _cachedLightTheme!;
  }

  /// Build DARK ThemeData (falls back to backend lightTheme if backend omitted dark)
  ThemeData buildDarkTheme() {
    if (_darkColors == null && _lightColors != null) {
      return buildLightTheme();
    }
    _cachedDarkTheme ??= _buildTheme(darkColors, Brightness.dark);
    return _cachedDarkTheme!;
  }

  /// Internal method to build ThemeData from colors
  ThemeData _buildTheme(AppThemeColors colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      appBarTheme: AppBarTheme(
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        toolbarTextStyle: TextStyle(
          color: colors.onSurface,
          fontWeight: FontWeight.w500,
        ),
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 16.0,
        ),
        iconTheme: IconThemeData(
          color: colors.onSurface,
        ),
        backgroundColor: colors.surface,
        elevation: 0,
      ),
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      scaffoldBackgroundColor: colors.background,
      extensions: [
        AppSemanticColors(
          success: colors.success,
          onSuccess: colors.onSuccess,
          warning: colors.warning,
          onWarning: colors.onWarning,
          price: colors.price,
          discountPrice: colors.discountPrice,
          mutedText: colors.mutedText,
        ),
      ],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.secondary,
        onSecondary: colors.onSecondary,
        surface: colors.surface,
        onSurface: colors.onSurface,
        background: colors.background,
        onBackground: colors.onBackground,
        error: colors.error,
        onError: colors.onError,
        outline: colors.outline,
        outlineVariant: isDark
            ? colors.outline.withOpacity(0.20)
            : colors.outline.withOpacity(0.25),
        surfaceVariant: colors.surfaceVariant,
        onSurfaceVariant: colors.onSurfaceVariant,
      ),
      textTheme: _buildTextTheme(colors),
      primaryColor: colors.primary,
      cardColor: colors.surface,
      dividerColor: isDark
          ? colors.outline.withOpacity(0.15)
          : colors.outline.withOpacity(0.20),
      dividerTheme: DividerThemeData(
        color: isDark
            ? colors.outline.withOpacity(0.15)
            : colors.outline.withOpacity(0.20),
        thickness: 1.0,
        space: 1.0,
      ),
      canvasColor: colors.background,
      iconTheme: IconThemeData(color: colors.onSurface),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceVariant,
        hintStyle: TextStyle(color: colors.onSurfaceVariant),
        labelStyle: TextStyle(color: colors.onSurface),
        prefixIconColor: colors.onSurfaceVariant,
        suffixIconColor: colors.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurfaceVariant,
        elevation: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.secondary,
        foregroundColor: colors.onSecondary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceVariant,
        labelStyle: TextStyle(color: colors.onSurface),
        selectedColor: colors.primary,
        secondarySelectedColor: colors.secondary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(color: colors.onSurface),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? colors.onSurface : colors.surface,
        contentTextStyle: TextStyle(
          color: isDark ? colors.surface : colors.onSurface,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return colors.surfaceVariant;
        }),
        checkColor: WidgetStateProperty.all(colors.onPrimary),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return colors.onSurfaceVariant;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return colors.surfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary.withOpacity(0.5);
          }
          return colors.onSurfaceVariant;
        }),
      ),
    );
  }

  TextTheme _buildTextTheme(AppThemeColors colors) {
    return GoogleFonts.plusJakartaSansTextTheme(TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: colors.onBackground,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colors.onBackground,
      ),
      displaySmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: colors.onBackground,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colors.onBackground,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: colors.onBackground,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: colors.onBackground,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.onBackground,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colors.onBackground,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.onBackground,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: colors.onBackground,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: colors.onBackground,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: colors.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.onBackground,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.onBackground,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        color: colors.onSurfaceVariant,
      ),
    ));
  }
}

/// Reactive Theme Controller using GetX
class ThemeController extends GetxController {
  /// Observable theme mode
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;

  // Single instance of theme manager
  final DynamicThemeManager _themeManager = DynamicThemeManager();

  final _box = GetStorage();
  static const String _themeModeKey = 'theme_mode';

  bool _isThemeLoading = false;
  String? _themeError;

  bool get hasTheme => _themeManager.hasTheme;
  bool get isThemeLoading => _isThemeLoading;
  String? get themeError => _themeError;

  void setThemeLoading(bool loading) {
    if (_isThemeLoading == loading) return;
    _isThemeLoading = loading;
    update();
  }

  void setThemeError(String? error) {
    if (_themeError == error) return;
    _themeError = error;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();

    // Listen to theme mode changes
    ever(_themeMode, (_) {
      update(); // Trigger rebuild when theme mode changes
    });
  }

  /// Initialize theme manager (Now called from Splash Screen)
  Future<void> initThemeManager() async {
    await _themeManager.init();
    debugPrint("we are gettinmg this after debugg");
    refreshTheme();
  }

  void _loadThemeMode() {
    final stored = _box.read(_themeModeKey);
    if (stored != null) {
      _themeMode.value = ThemeMode.values.firstWhere(
        (mode) => mode.name == stored,
        orElse: () => ThemeMode.system,
      );
    }
  }

  /// Get current light theme - recomputed each time
  ThemeData get lightTheme {
    debugPrint('🎨 Building light theme for mode: ${_themeMode.value}');
    return _themeManager.buildLightTheme();
  }

  /// Get current dark theme - recomputed each time
  ThemeData get darkTheme {
    debugPrint('🎨 Building dark theme for mode: ${_themeMode.value}');
    return _themeManager.buildDarkTheme();
  }

  /// Set theme mode (light, dark, or system)
  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    _box.write(_themeModeKey, mode.name);
    Get.changeThemeMode(mode);
    update(); // Force update
  }

  /// Toggle between light and dark mode
  void toggleTheme() {
    if (_themeMode.value == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else if (_themeMode.value == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      // If system, check current brightness and toggle opposite
      final brightness = Get.mediaQuery.platformBrightness;
      if (brightness == Brightness.dark) {
        setThemeMode(ThemeMode.light);
      } else {
        setThemeMode(ThemeMode.dark);
      }
    }
  }

  /// Update theme from API
  void updateThemeFromApi(Map<String, dynamic> appThemeColor) {
    if (_themeManager.updateFromApi(appThemeColor)) {
      refreshTheme();
    }
  }

  /// Call this after updating theme from API to trigger rebuild
  void refreshTheme() {
    debugPrint('🔄 Refreshing app theme...');
    // MyApp listens to this controller with GetBuilder, so this rebuilds the
    // app theme without tearing down active scroll and semantics subtrees.
    update();
  }

  /// Clear stored themes
  void resetToDefault() {
    _themeManager.clearTheme();
    refreshTheme();
  }
}

/// Extension to easily access theme colors anywhere
extension ThemeColorExtension on BuildContext {
  /// Get current ColorSchemeP
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get current TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Quick access to common colors
  Color get primaryColor => colorScheme.primary;
  Color get onPrimaryColor => colorScheme.onPrimary;
  Color get secondaryColor => colorScheme.secondary;
  Color get backgroundColor => colorScheme.background;
  Color get onBackgroundColor => colorScheme.onBackground;
  Color get surfaceColor => colorScheme.surface;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get errorColor => colorScheme.error;
  Color get outlineColor => colorScheme.outline;

  // 👇 ADD THESE TWO LINES 👇
  Color get surfaceVariantColor => colorScheme.surfaceVariant;
  Color get onSurfaceVariantColor => colorScheme.onSurfaceVariant;

  /// Semantic e-commerce colors derived from the backend theme
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>() ??
      AppSemanticColors.fromColorScheme(colorScheme);

  /// Check if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

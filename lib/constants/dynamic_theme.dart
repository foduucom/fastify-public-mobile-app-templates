import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DefaultThemeColors {
  DefaultThemeColors._(); // Private constructor - prevents instantiation
  // ============ LIGHT THEME DEFAULTS ============
  static const Color lightPrimary = Color(0xFF6200EE);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFF03DAC6);
  static const Color lightOnSecondary = Color(0xFF000000);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF000000);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF000000);
  static const Color lightError = Color(0xFFB00020);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightOutline = Color(0xFFDDDDDD);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  static const Color lightOnSurfaceVariant = Color(0xFF666666);
  // ============ DARK THEME DEFAULTS ============
  static const Color darkPrimary = Color(0xFFBB86FC);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkSecondary = Color(0xFF03DAC6);
  static const Color darkOnSecondary = Color(0xFF000000);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkError = Color(0xFFCF6679);
  static const Color darkOnError = Color(0xFF000000);
  static const Color darkOutline = Color(0xFF444444);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkOnSurfaceVariant = Color(0xFFAAAAAA);
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
  }) {
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
    );
  }

  /// Default LIGHT theme colors (fallback)
  factory AppThemeColors.defaultsLight() {
    debugPrint('🎨 Using default LIGHT theme colors');
    return AppThemeColors.fromCoreColors(
      primary: DefaultThemeColors.lightPrimary,
      secondary: DefaultThemeColors.lightSecondary,
      background: DefaultThemeColors.lightBackground,
      error: DefaultThemeColors.lightError,
      isDark: false,
      onPrimary: DefaultThemeColors.lightOnPrimary,
      onSecondary: DefaultThemeColors.lightOnSecondary,
      onBackground: DefaultThemeColors.lightOnBackground,
      surface: DefaultThemeColors.lightSurface,
      onSurface: DefaultThemeColors.lightOnSurface,
      onError: DefaultThemeColors.lightOnError,
      outline: DefaultThemeColors.lightOutline,
      surfaceVariant: DefaultThemeColors.lightSurfaceVariant,
      onSurfaceVariant: DefaultThemeColors.lightOnSurfaceVariant,
    );
  }

  /// Default DARK theme colors (fallback)
  factory AppThemeColors.defaultsDark() {
    debugPrint('🎨 Using default DARK theme colors');
    return AppThemeColors.fromCoreColors(
      primary: DefaultThemeColors.darkPrimary,
      secondary: DefaultThemeColors.darkSecondary,
      background: DefaultThemeColors.darkBackground,
      error: DefaultThemeColors.darkError,
      isDark: true,
      onPrimary: DefaultThemeColors.darkOnPrimary,
      onSecondary: DefaultThemeColors.darkOnSecondary,
      onBackground: DefaultThemeColors.darkOnBackground,
      surface: DefaultThemeColors.darkSurface,
      onSurface: DefaultThemeColors.darkOnSurface,
      onError: DefaultThemeColors.darkOnError,
      outline: DefaultThemeColors.darkOutline,
      surfaceVariant: DefaultThemeColors.darkSurfaceVariant,
      onSurfaceVariant: DefaultThemeColors.darkOnSurfaceVariant,
    );
  }
  factory AppThemeColors.fromThemeMap(
    Map<String, dynamic> themeMap,
    bool isDark,
  ) {
    debugPrint('🌐 Generating ${isDark ? "DARK" : "LIGHT"} theme from API');

    // 1️⃣ Parse main colors from API
    final primary = _hexToColor(themeMap['primary']) ??
        (isDark
            ? DefaultThemeColors.darkPrimary
            : DefaultThemeColors.lightPrimary);

    final secondary = _hexToColor(themeMap['secondary']) ?? primary;

    final background = _hexToColor(themeMap['background']) ??
        (isDark ? Colors.black : Colors.white);

    final surface = _hexToColor(themeMap['surface']) ?? background;

    final error = _hexToColor(themeMap['error']) ??
        (isDark ? DefaultThemeColors.darkError : DefaultThemeColors.lightError);

    // 2️⃣ Auto-generate Material ColorScheme from primary
    final generatedScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    // 3️⃣ Override generated colors with API if available
    return AppThemeColors._(
      primary: primary,
      secondary: secondary,
      background: background,
      surface: surface,
      error: error,
      onPrimary:
          _hexToColor(themeMap['onPrimary']) ?? generatedScheme.onPrimary,
      onSecondary:
          _hexToColor(themeMap['onSecondary']) ?? generatedScheme.onSecondary,
      onBackground:
          _hexToColor(themeMap['onBackground']) ?? generatedScheme.onBackground,
      onSurface:
          _hexToColor(themeMap['onSurface']) ?? generatedScheme.onSurface,
      onError: _hexToColor(themeMap['onError']) ?? generatedScheme.onError,
      outline: _hexToColor(themeMap['outline']) ?? generatedScheme.outline,
      surfaceVariant: _hexToColor(themeMap['surfaceVariant']) ??
          generatedScheme.surfaceVariant,
      onSurfaceVariant: _hexToColor(themeMap['onSurfaceVariant']) ??
          generatedScheme.onSurfaceVariant,
    );
  }

  static Color? _hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) {
      debugPrint('⚠️ Hex color missing');
      return null;
    }

    hexString = hexString.replaceAll('#', '');

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

  /// Convert to JSON for storage (all colors)
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
    };
  }

  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }
}

/// Theme Manager using GetX for reactive updates
/// Supports both light and dark themes from API
class DynamicThemeManager {
  static final DynamicThemeManager _instance = DynamicThemeManager._internal();
  factory DynamicThemeManager() => _instance;
  DynamicThemeManager._internal();

  final _box = GetStorage();
  static const String _lightThemeKey = 'app_theme_colors_light';
  static const String _darkThemeKey = 'app_theme_colors_dark';

  AppThemeColors _lightColors = AppThemeColors.defaultsLight();
  AppThemeColors _darkColors = AppThemeColors.defaultsDark();

  AppThemeColors get lightColors => _lightColors;
  AppThemeColors get darkColors => _darkColors;

  /// Get colors based on current brightness
  AppThemeColors getColors(Brightness brightness) {
    return brightness == Brightness.dark ? _darkColors : _lightColors;
  }

  /// Initialize theme from storage or use defaults
  Future<void> init() async {
    debugPrint('📦 Initializing DynamicThemeManager');

    // Load light theme
    final storedLight = _box.read(_lightThemeKey);
    if (storedLight != null) {
      debugPrint('💾 Light theme found in storage, loading...');
      _lightColors = AppThemeColors.fromThemeMap(
        Map<String, dynamic>.from(storedLight),
        false,
      );
    } else {
      debugPrint('ℹ️ No stored light theme found, using defaults');
    }

    // Load dark theme
    final storedDark = _box.read(_darkThemeKey);
    if (storedDark != null) {
      debugPrint('💾 Dark theme found in storage, loading...');
      _darkColors = AppThemeColors.fromThemeMap(
        Map<String, dynamic>.from(storedDark),
        true,
      );
    } else {
      debugPrint('ℹ️ No stored dark theme found, using defaults');
    }
  }

  /// Update theme colors from API response
  /// Expected format: { "light": { "primary": "#xxx", "secondary": "#xxx", "background": "#xxx", "error": "#xxx" }, "dark": { ... } }
  void updateFromApi(Map<String, dynamic> appThemeColor) {
    debugPrint('🌐 Updating themes from API');
    debugPrint('appThemeColor update working $appThemeColor');

    // Parse light theme
    if (appThemeColor.containsKey('light') && appThemeColor['light'] != null) {
      _lightColors = AppThemeColors.fromThemeMap(
        Map<String, dynamic>.from(appThemeColor['light']),
        false,
      );
      _box.write(_lightThemeKey, _lightColors.toJson());
      debugPrint('✅ Light theme updated & saved successfully');
    } else {
      debugPrint('⚠️ API response does not contain light theme');
    }

    // Parse dark theme
    if (appThemeColor.containsKey('dark') && appThemeColor['dark'] != null) {
      _darkColors = AppThemeColors.fromThemeMap(
        Map<String, dynamic>.from(appThemeColor['dark']),
        true,
      );
      _box.write(_darkThemeKey, _darkColors.toJson());
      debugPrint('✅ Dark theme updated & saved successfully');
    } else {
      debugPrint('⚠️ API response does not contain dark theme');
    }
  }

  /// Clear stored themes (reset to defaults)
  void clearTheme() {
    debugPrint('♻️ Clearing stored themes & resetting to defaults');
    _box.remove(_lightThemeKey);
    _box.remove(_darkThemeKey);
    _lightColors = AppThemeColors.defaultsLight();
    _darkColors = AppThemeColors.defaultsDark();
  }

  /// Build LIGHT ThemeData
  ThemeData buildLightTheme() {
    debugPrint('🎭 Building LIGHT ThemeData');
    return _buildTheme(_lightColors, Brightness.light);
  }

  /// Build DARK ThemeData
  ThemeData buildDarkTheme() {
    debugPrint('🎭 Building DARK ThemeData');
    return _buildTheme(_darkColors, Brightness.dark);
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
      fontFamily: 'Lato',
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.secondary,
        onSecondary: colors.onSecondary,
        surface: colors.surface,
        onSurface: colors.onSurface,
        // ignore: deprecated_member_use
        background: colors.background,
        // ignore: deprecated_member_use
        onBackground: colors.onBackground,
        error: colors.error,
        onError: colors.onError,
        outline: colors.outline,
        // ignore: deprecated_member_use
        surfaceVariant: colors.surfaceVariant,
        onSurfaceVariant: colors.onSurfaceVariant,
      ),
      textTheme: _buildTextTheme(colors),
      primaryColor: colors.primary,
      cardColor: colors.surface,
      dividerTheme: DividerThemeData(
          color: colors.surfaceVariant.withValues(alpha: 0.5), thickness: 8),
      iconTheme: IconThemeData(color: colors.onBackground),
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
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(color: colors.onSurface),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? colors.surface : colors.onBackground,
        contentTextStyle: TextStyle(
          color: isDark ? colors.onSurface : colors.background,
        ),
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
            return colors.primary.withValues(alpha: 0.5);
          }
          return colors.onSurfaceVariant;
        }),
      ),
    );
  }

  TextTheme _buildTextTheme(AppThemeColors colors) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      displaySmall: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w500, color: colors.onSurface),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: colors.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: colors.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colors.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: colors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: colors.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: colors.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}

/// Reactive Theme Controller using GetX
class ThemeController extends GetxController {
  /// Observable theme mode
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;

  final _box = GetStorage();
  static const String _themeModeKey = 'theme_mode';

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
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

  /// Get current light theme
  ThemeData get lightTheme => DynamicThemeManager().buildLightTheme();

  /// Get current dark theme
  ThemeData get darkTheme => DynamicThemeManager().buildDarkTheme();

  /// Set theme mode (light, dark, or system)
  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    _box.write(_themeModeKey, mode.name);
    Get.changeThemeMode(mode);
    update();
  }

  /// Toggle between light and dark mode
  void toggleTheme() {
    if (_themeMode.value == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  /// Call this after updating theme from API to trigger rebuild
  void refreshTheme() {
    debugPrint('🔄 Refreshing app theme...');
    Get.forceAppUpdate();
    update();
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
  // ignore: deprecated_member_use
  Color get backgroundColor => colorScheme.background;
  // ignore: deprecated_member_use
  Color get onBackgroundColor => colorScheme.onBackground;
  Color get surfaceColor => colorScheme.surface;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get errorColor => colorScheme.error;
  Color get outlineColor => colorScheme.outline;

  /// Check if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

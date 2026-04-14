import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DefaultThemeColors {
  DefaultThemeColors._(); // Private constructor - prevents instantiation
  // ============ STILIFY ANIKET COLORS ============
  static const Color lightSecondary = Color(0xFFFA9571);
  static const Color lighterSecondary = Color(0xFFFBAF95);
  static const Color lightDarker = Color(0xFFC2C2C2); //It's Original Color
  static const Color mainprimary = Color(0xFF702F6E);
  static const Color darklighter = Color(0xFFA3A3A3);
  static const Color darkmain = Color(0xFF666666);
  static const Color alertSuccessLight = Color(0xFF3BC24F);
  static const Color alertErrorLighter = Color(0xFFFF6766);
  static const Color darklight = Color(0xFFE0E0E0);
  static const Color secondarymain = Color(0xFFF97A4E);
  static const Color darkdark = Color(0xFF4C4C4C);
  static const Color alertWarninglight = Color(0xFFF9A825);

  // ============ LIGHT THEME DEFAULTS ============
  static const Color lightPrimary = Color(0xFF6200EE);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  //static const Color lightSecondary = Color(0xFF03DAC6);
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

  /// Parse from API response
  factory AppThemeColors.fromThemeMap(
      Map<String, dynamic> themeMap, bool isDark) {
    debugPrint('🌐 Parsing ${isDark ? "DARK" : "LIGHT"} theme colors');

    return AppThemeColors.fromCoreColors(
      primary: _hexToColor(themeMap['primary']) ??
          (isDark
              ? DefaultThemeColors.darkPrimary
              : DefaultThemeColors.lightPrimary),
      secondary: _hexToColor(themeMap['secondary']) ??
          (isDark
              ? DefaultThemeColors.darkSecondary
              : DefaultThemeColors.lightSecondary),
      background: _hexToColor(themeMap['background']) ??
          (isDark
              ? DefaultThemeColors.darkBackground
              : DefaultThemeColors.lightBackground),
      error: _hexToColor(themeMap['error']) ??
          (isDark
              ? DefaultThemeColors.darkError
              : DefaultThemeColors.lightError),
      isDark: isDark,
      onPrimary: _hexToColor(themeMap['onPrimary']) ??
          (isDark
              ? DefaultThemeColors.darkOnPrimary
              : DefaultThemeColors.lightOnPrimary),
      onSecondary: _hexToColor(themeMap['onSecondary']) ??
          (isDark
              ? DefaultThemeColors.darkOnSecondary
              : DefaultThemeColors.lightOnSecondary),
      onBackground: _hexToColor(themeMap['onBackground']) ??
          (isDark
              ? DefaultThemeColors.darkOnBackground
              : DefaultThemeColors.lightOnBackground),
      surface: _hexToColor(themeMap['surface']) ??
          (isDark
              ? DefaultThemeColors.darkSurface
              : DefaultThemeColors.lightSurface),
      onSurface: _hexToColor(themeMap['onSurface']) ??
          (isDark
              ? DefaultThemeColors.darkOnSurface
              : DefaultThemeColors.lightOnSurface),
      onError: _hexToColor(themeMap['onError']) ??
          (isDark
              ? DefaultThemeColors.darkOnError
              : DefaultThemeColors.lightOnError),
      outline: _hexToColor(themeMap['outline']) ??
          (isDark
              ? DefaultThemeColors.darkOutline
              : DefaultThemeColors.lightOutline),
      surfaceVariant: _hexToColor(themeMap['surfaceVariant']) ??
          (isDark
              ? DefaultThemeColors.darkSurfaceVariant
              : DefaultThemeColors.lightSurfaceVariant),
      onSurfaceVariant: _hexToColor(themeMap['onSurfaceVariant']) ??
          (isDark
              ? DefaultThemeColors.darkOnSurfaceVariant
              : DefaultThemeColors.lightOnSurfaceVariant),
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
    };
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
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
        background: colors.background,
        onBackground: colors.onBackground,
        error: colors.error,
        onError: colors.onError,
        outline: colors.outline,
        surfaceVariant: colors.surfaceVariant,
        onSurfaceVariant: colors.onSurfaceVariant,
      ),
      textTheme: _buildTextTheme(colors),
      primaryColor: colors.primary,
      cardColor: colors.surface,
      dividerColor: colors.outline,
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
    return TextTheme(
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
    );
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

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();

    // Initialize theme manager
    _themeManager.init();
    debugPrint("we are gettinmg this after debugg");

    // Listen to theme mode changes
    ever(_themeMode, (_) {
      update(); // Trigger rebuild when theme mode changes
    });
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
    _themeManager.updateFromApi(appThemeColor);
    refreshTheme();
  }

  /// Call this after updating theme from API to trigger rebuild
  void refreshTheme() {
    debugPrint('🔄 Refreshing app theme...');
    update(); // This will trigger GetBuilder to rebuild
    Get.forceAppUpdate(); // Force entire app to rebuild
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

  /// Check if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

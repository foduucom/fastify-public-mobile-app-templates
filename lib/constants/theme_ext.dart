import 'package:flutter/material.dart';
import 'package:zouhi/constants/constants.dart' as c;

/// Theme-aware accessors for the brand colors in constants.dart.
/// The app is light-only (matches the parent site); `isDark` is kept so
/// existing call sites keep compiling and always resolves to false.
extension AppTheme on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get themePrimaryColor => colors.primary;
  Color get themePrimaryDark => c.themePrimaryDark;
  Color get themePrimaryLight => c.themePrimaryLight;
  Color get themeBackground => c.themeBackground;
  Color get themeSecondryColor => colors.secondary;
  Color get themeTextColor => colors.onSurface;
  Color get themetitleColor => c.themeHeadingColor;
  Color get themeSecondrytext => c.themeSecondrytext;
  Color get themeBorderColor => colors.outline;
  Color get themeWhiteColor => colors.surface;
  Color get themegreyColor => c.themegreyColor;
  Color get themeCardColor =>
      isDark ? const Color(0xFF1E293B) : Theme.of(this).cardColor;

  // Status / accent colors.
  Color get themePurpleColor => c.themePurpleColor;
  Color get themeRedColor => c.themeRedColor;
  Color get themeYellowColor => c.themeYellowColor;
  Color get themeSkyBlueColor => c.themeSkyBlueColor;
  Color get themeBlueColor => c.themeBlueColor;
  Color get themeGreenColor => c.themeGreenColor;
  Color get themeTealColor => c.themeTealColor;
}

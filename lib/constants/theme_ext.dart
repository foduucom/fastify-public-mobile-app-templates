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
  Color get themePrimaryLight => colors.surfaceVariant;
  Color get themeBackground => colors.background;
  Color get themeSecondryColor => colors.secondary;
  Color get themeTextColor => colors.onSurface;
  Color get themetitleColor => colors.onSurface;
  Color get themeSecondrytext => colors.onSurfaceVariant;
  Color get themeBorderColor => colors.outline;
  Color get themeWhiteColor => colors.surface;
  Color get themegreyColor => colors.surfaceVariant;
  Color get themeCardColor => Theme.of(this).cardColor;

  // Status / accent colors.
  Color get themePurpleColor => c.themePurpleColor;
  Color get themeRedColor => colors.error;
  Color get themeYellowColor => c.themeYellowColor;
  Color get themeSkyBlueColor => c.themeSkyBlueColor;
  Color get themeBlueColor => c.themeBlueColor;
  Color get themeGreenColor => c.themeGreenColor;
  Color get themeTealColor => c.themeTealColor;
}


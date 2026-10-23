import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zouhi/constants/constants.dart';

const String appFontFamily = 'Poppins';

/// Type scale modelled on the parent site (Poppins, slate text colours).
TextTheme txtTheme() {
  return const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: themeHeadingColor,
    ),
    displayMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: themeHeadingColor,
    ),
    displaySmall: TextStyle(fontSize: 16, color: themeTextColor),
    headlineMedium: TextStyle(
      fontSize: 15.5,
      fontWeight: FontWeight.w600,
      color: themeHeadingColor,
    ),
    headlineSmall: TextStyle(fontSize: 14, color: themeTextColor),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: themeHeadingColor,
    ),
    titleMedium: TextStyle(fontSize: 10, color: themeTextColor),
    bodyLarge: TextStyle(fontSize: 16, color: themeTextColor),
    bodyMedium: TextStyle(fontSize: 14, color: themeTextColor),
    bodySmall: TextStyle(fontSize: 12, color: themeSecondrytext),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  );
}

ThemeData lightThemeData() {
  const colorScheme = ColorScheme.light(
    primary: themePrimaryColor,
    onPrimary: Colors.white,
    primaryContainer: themePrimaryLight,
    onPrimaryContainer: themePrimaryDark,
    secondary: themeSecondryColor,
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: themeTextColor,
    error: themeRedColor,
    onError: Colors.white,
    outline: themeBorderColor,
  );

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(themeButtonRadius),
  );
  const buttonText = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  const buttonSize = Size.fromHeight(themeButtonHeight);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: appFontFamily,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: themeBackground,
    canvasColor: Colors.white,
    dividerColor: themeBorderColor,
    textTheme: txtTheme(),
    iconTheme: const IconThemeData(color: themeTextColor),
    primaryColor: themePrimaryColor,
    cardColor: Colors.white,
    splashFactory: InkRipple.splashFactory,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      foregroundColor: themeHeadingColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: themeBorderColor)),
      toolbarTextStyle: TextStyle(
        fontFamily: appFontFamily,
        color: themeHeadingColor,
        fontWeight: FontWeight.w500,
      ),
      titleTextStyle: TextStyle(
        fontFamily: appFontFamily,
        color: themeHeadingColor,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      ),
      iconTheme: IconThemeData(color: themeHeadingColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: themePrimaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: themeBorderColor,
        elevation: 0,
        minimumSize: buttonSize,
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: themePrimaryColor,
        foregroundColor: Colors.white,
        minimumSize: buttonSize,
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: themePrimaryColor,
        minimumSize: buttonSize,
        side: const BorderSide(color: themePrimaryColor),
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: themePrimaryColor,
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: const Color(0x0F000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: const TextStyle(
        fontFamily: appFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: themeHeadingColor,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: themePrimaryColor,
      unselectedItemColor: themeSecondrytext,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle:
          TextStyle(fontFamily: appFontFamily, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontFamily: appFontFamily),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: themePrimaryLight,
      side: const BorderSide(color: themeBorderColor),
      labelStyle: const TextStyle(
        fontFamily: appFontFamily,
        fontSize: 13,
        color: themeTextColor,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: themeSecondrytext, fontSize: 14),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(themeButtonRadius),
        borderSide: const BorderSide(color: themeBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(themeButtonRadius),
        borderSide: const BorderSide(color: themeBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(themeButtonRadius),
        borderSide: const BorderSide(color: themePrimaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(themeButtonRadius),
        borderSide: const BorderSide(color: themeRedColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(themeButtonRadius),
        borderSide: const BorderSide(color: themeRedColor, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: themeBorderColor,
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: themePrimaryColor,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: themeSecondryColor,
      contentTextStyle: const TextStyle(
        fontFamily: appFontFamily,
        color: Colors.white,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(themeButtonRadius),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? themePrimaryColor : null,
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? themePrimaryColor : null,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? themePrimaryColor : null,
      ),
    ),
  );
}

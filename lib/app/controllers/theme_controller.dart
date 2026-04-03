import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  // Reactive theme mode with default as system
  var themeMode = ThemeMode.system.obs;

  void setLightMode() => themeMode.value = ThemeMode.light;

  void setDarkMode() => themeMode.value = ThemeMode.dark;

  void setSystemMode() => themeMode.value = ThemeMode.system;

  // Optional: toggle between light and dark
  void toggleTheme() {
    if (themeMode.value == ThemeMode.light) {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.light;
    }
  }
}

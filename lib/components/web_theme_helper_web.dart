import 'dart:js_interop';

@JS('setAppWebViewTheme')
external void _setAppWebViewTheme(bool isDark);

void setWebThemeMode(bool isDark) {
  try {
    _setAppWebViewTheme(isDark);
  } catch (e) {
    // Graceful fallback if DOM or JS context is unavailable
  }
}

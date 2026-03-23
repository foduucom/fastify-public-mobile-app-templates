import 'package:flutter/material.dart';


class AppColors {
  AppColors._();

  // ── Static fixed colors (never change) ──────────────────────
  static const Color scaffoldBackground  = Color(0xFFECE8E5);
  static const Color titleText           = Color(0xFF000000);
  static const Color subtitleText        = Color(0xFF9E9E9E);
  static const Color labelText           = Color(0xFF1A1A1A);
  static const Color hintText            = Color(0xFFBDBDBD);
  static const Color buttonText          = Color(0xFFFFFFFF);
  static const Color fieldBackground     = Color(0xFFFFFFFF);
  static const Color fieldBorder         = Color(0xFFE0E0E0);
  static const Color eyeIcon             = Color(0xFF9E9E9E);
  static const Color primaryButtonActive = Color(0xFF1A1A1A);
  static const Color socialButtonBg      = Color(0xFFFFFFFF);
  static const Color socialButtonBorder  = Color(0xFFE0E0E0);
  static const Color socialButtonText    = Color(0xFF000000);
  static const Color dividerLine         = Color(0xFFCCCCCC);
  static const Color googleRed           = Color(0xFFDB4437);
  static const Color facebookBlue        = Color(0xFF1877F2);

  // ── Dynamic colors from socket/API theme ─────────────────────
  // Use these in your widgets instead of hardcoded colors
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color onPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;

  static Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  static Color background(BuildContext context) =>
      Theme.of(context).colorScheme.background;

  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color onSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color outline(BuildContext context) =>
      Theme.of(context).colorScheme.outline;

  static Color error(BuildContext context) =>
      Theme.of(context).colorScheme.error;
}

import 'package:flutter/material.dart';

/// Builder function signature: takes content_json map and returns a Widget.
typedef SectionWidgetBuilder = Widget Function(
    Map<String, dynamic>? contentJson);

/// Singleton registry that maps section `type` strings to widget builders.
///
/// Usage:
/// ```dart
/// WidgetRegistry().register('slider', (json) => FoduuSlider(sliderData: json ?? {}));
/// ```
///
/// To add a new widget type, just call `register(...)` — no controller or view
/// changes needed.
class WidgetRegistry {
  static final WidgetRegistry _instance = WidgetRegistry._();
  factory WidgetRegistry() => _instance;
  WidgetRegistry._();

  final Map<String, SectionWidgetBuilder> _builders = {};

  /// Register a widget builder for [type].
  /// Call this once at app startup (e.g. in `main.dart`).
  void register(String type, SectionWidgetBuilder builder) {
    _builders[type] = builder;
  }

  /// Build a widget from a raw section map `{ "type": "...", "content_json": {...} }`.
  /// Returns `null` if the type is unknown.
  Widget? build(Map<String, dynamic> section) {
    final type = section['type']?.toString();
    final visible = section['visible'] != false;
    final builder = type == null ? null : _builders[type];
    if (builder == null || !visible) return null;

    final rawContent = section['content_json'] ?? section['contentJson'];
    final content = rawContent is Map
        ? Map<String, dynamic>.from(rawContent)
        : null;
    return builder(content);
  }

  /// Check whether a builder exists for [type].
  bool hasType(String type) => _builders.containsKey(type);

  /// List all registered type names (useful for debugging).
  List<String> get registeredTypes => _builders.keys.toList();
}

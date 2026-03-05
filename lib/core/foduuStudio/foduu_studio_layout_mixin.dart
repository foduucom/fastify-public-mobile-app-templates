// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import '/app/data/basic_provider.dart';
import '/helpers/socket_helper.dart';
import 'package:get/get.dart';

import 'widget_registry.dart';

/// Mixin that gives any GetxController dynamic-layout capabilities.
///
/// Usage:
/// ```dart
/// class MyPageController extends GetxController
///     with BaseController, DynamicLayoutMixin {
///   @override
///   void onInit() {
///     super.onInit();
///     fetchLayout('my-page-slug');
///   }
/// }
/// ```
///
/// Provides:
/// - [widgetList] — observable list of built widgets for the view.
/// - [isLayoutLoading] — observable loading flag.
/// - [fetchLayout] — fetches sections JSON from API and builds widgets.
/// - [buildLayout] — converts a raw `List<Map>` of sections into widgets.
/// - [enableSocketUpdates] / [disableSocketUpdates] — live layout updates.
mixin FoduuStudioLayoutMixin on GetxController {
  // ─── Observable state ────────────────────────────────────────
  final widgetList = <Widget>[].obs;
  final isLayoutLoading = true.obs;

  // ─── Internal state ──────────────────────────────────────────
  List _initialComponents = [];
  List _lastSocketSections = [];

  final SocketHelper _layoutSocketHelper = SocketHelper();
  final WidgetRegistry _registry = WidgetRegistry();

  String? _currentDomain;
  String? _currentSlug;

  // ─── Static registry: slug → mixin instance ─────────────────
  // Keeps one socket listener per event name.  When the event fires
  // it broadcasts to ALL registered controllers instead of only the
  // last one that called enableSocketUpdates().
  static final Map<String, FoduuStudioLayoutMixin> _slugHandlers = {};
  static String? _registeredEventName;

  // ─── Static block types that can be updated without API call ─
  static const _localUpdateOnlyTypes = [
    'spacer',
    'divider',
    'text_block',
    'rich_text',
  ];

  // ═══════════════════════════════════════════════════════════════
  //  PUBLIC API
  // ═══════════════════════════════════════════════════════════════

  /// Build the [widgetList] from a raw list of section maps.
  void buildLayout(List sections) {
    widgetList.clear();
    for (var section in sections) {
      if (section is Map<String, dynamic>) {
        final widget = _registry.build(section);
        if (widget != null) widgetList.add(widget);
      }
    }
  }

  /// Fetch layout JSON from the API and build widgets.
  ///
  /// - [slug] — the page slug, e.g. `'home'`, `'category'`, etc.
  /// - [requestBody] — if provided, uses POST `mobile-app/by-json` instead of GET.
  Future<dynamic> fetchLayout(String slug, {dynamic requestBody}) async {
    try {
      isLayoutLoading.value = true;
      dynamic response;

      // Ensure socket is connected and listener is enabled on web
      if (kIsWeb) {
        if (!_layoutSocketHelper.isConnected) {
          _layoutSocketHelper.connect();
        }
        enableSocketUpdates(domain: websiteDomain, slug: slug);
      }

      if (requestBody != null) {
        response = await BasicProvider("mobile-app/by-json")
            .postRequest(requestBody)
            .catchError((e, stackTrace) => _handleApiError(e, stackTrace));
      } else {
        response = await BasicProvider("mobile-app/$slug")
            .getRequest()
            .catchError((e, stackTrace) => _handleApiError(e, stackTrace));
      }
      print('Hi Fetch Layout Response $response');

      if (response != null) {
        var list = response['sections'];
        if (list != null && list is List) {
          _initialComponents = list;
          buildLayout(list);
        }
      }

      return response;
    } catch (e) {
      print('DynamicLayoutMixin fetchLayout error: $e');
    } finally {
      isLayoutLoading.value = false;
    }
  }

  /// Enable real-time socket-driven layout updates.
  ///
  /// Registers this controller for socket events. Multiple controllers
  /// can coexist — the socket listener is registered ONCE. When a socket
  /// event fires, the `slug` in the data payload determines which
  /// controller handles it.
  void enableSocketUpdates({
    required String domain,
    required String slug,
  }) {
    try {
      if (_currentDomain == domain && _currentSlug == slug) return;

      _currentDomain = domain;
      _currentSlug = slug;

      // Register this controller for the given slug
      _slugHandlers[slug] = this;

      final eventName = '${domain}:mobileapp';

      // Only set up the socket listener ONCE across all controllers
      if (_registeredEventName != eventName) {
        if (_registeredEventName != null) {
          _layoutSocketHelper.off(_registeredEventName!);
        }

        print(
            '🟢 DynamicLayout: Setting up SHARED socket listener for: $eventName');
        _layoutSocketHelper.on(eventName, (data) {
          _dispatchSocketEvent(data);
        });

        _registeredEventName = eventName;
      } else {
        print(
            '🟢 DynamicLayout: Registered slug "$slug" on existing listener ($eventName)');
      }
    } catch (e) {
      print('❌ DynamicLayout: enableSocketUpdates error: $e');
    }
  }

  /// Stop listening for socket updates for this controller's slug.
  void disableSocketUpdates(String domain, String slug) {
    _slugHandlers.remove(slug);
    print(
        '🔴 DynamicLayout: Unregistered slug "$slug" (${_slugHandlers.length} remaining)');

    // If no more handlers, remove the socket listener entirely
    if (_slugHandlers.isEmpty && _registeredEventName != null) {
      _layoutSocketHelper.off(_registeredEventName!);
      _registeredEventName = null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  SOCKET INTERNALS
  // ═══════════════════════════════════════════════════════════════

  /// Central dispatch — parses the slug from the socket data and routes
  /// the event ONLY to the controller registered for that slug.
  static void _dispatchSocketEvent(dynamic data) {
    if (data == null) {
      print('⚠️ DynamicLayout: Socket data is null');
      return;
    }

    dynamic decodedData;
    if (data is String) {
      decodedData = json.decode(data);
    } else {
      decodedData = data;
    }

    // ── Resolve the content payload ──
    // Format 1 (new): slug, theme_color, sections at root level
    // Format 2 (legacy): nested inside decodedData['content_json']
    dynamic contentPayload;
    if (decodedData.containsKey('content_json')) {
      contentPayload = decodedData['content_json'];
      if (contentPayload is String) {
        contentPayload = json.decode(contentPayload);
      }
    } else {
      contentPayload = decodedData;
    }

    // ── Extract slug from data ──
    // slug can be at root level or inside content_json
    final String? dataSlug =
        decodedData['slug']?.toString() ?? contentPayload['slug']?.toString();

    print('📩 DynamicLayout: Socket event received for slug: "$dataSlug"');
    print('   Registered slugs: ${_slugHandlers.keys.toList()}');

    // ── Handle Theme Update (applies globally) ──
    var themeData = contentPayload['theme_color'];
    if (themeData != null) {
      print('🎨 DynamicLayout: Theme update detected');
      DynamicThemeManager().updateFromApi(themeData);

      if (Get.isRegistered<ThemeController>()) {
        Get.find<ThemeController>().refreshTheme();
      }
    }

    // ── Handle Section Update (slug-specific) ──
    var newSections = contentPayload['sections'];
    if (newSections != null && newSections is List && dataSlug != null) {
      final handler = _slugHandlers[dataSlug];
      if (handler != null) {
        print('   ✅ Dispatching sections to slug: "$dataSlug"');
        handler._handleSectionUpdate(newSections, dataSlug);
      } else {
        print(
            '   ⚠️ No controller registered for slug: "$dataSlug" — ignoring sections');
      }
    }
  }

  void _handleSectionUpdate(List newSections, String slug) {
    print('🧩 DynamicLayout: Sections received: ${newSections.length}');

    // First socket event → store and fetch from API
    if (_lastSocketSections.isEmpty) {
      print('🔄 First socket event. Fetching from API...');
      _lastSocketSections =
          List.from(newSections.map((e) => json.decode(json.encode(e))));
      fetchLayout(slug, requestBody: newSections);
      return;
    }

    // Structural change: blocks added or removed
    if (_lastSocketSections.length != newSections.length) {
      print(
          '⚠️ Section count changed: ${_lastSocketSections.length} → ${newSections.length}');
      _lastSocketSections =
          List.from(newSections.map((e) => json.decode(json.encode(e))));
      fetchLayout(slug, requestBody: newSections);
      return;
    }

    // Check for block type changes
    bool hasTypeChange = false;
    for (int i = 0; i < _lastSocketSections.length; i++) {
      if (_lastSocketSections[i]['type'] != newSections[i]['type']) {
        print(
            '⚠️ Block type changed at $i: ${_lastSocketSections[i]['type']} → ${newSections[i]['type']}');
        hasTypeChange = true;
        break;
      }
    }
    if (hasTypeChange) {
      _lastSocketSections =
          List.from(newSections.map((e) => json.decode(json.encode(e))));
      fetchLayout(slug, requestBody: newSections);
      return;
    }

    // Compare against last socket config
    bool hasDynamicChange = false;
    bool hasStaticChange = false;
    List<int> staticChangedIndices = [];

    for (int i = 0; i < _lastSocketSections.length; i++) {
      var oldItem = _lastSocketSections[i];
      var newItem = newSections[i];

      if (json.encode(oldItem) == json.encode(newItem)) continue;

      if (_localUpdateOnlyTypes.contains(newItem['type'])) {
        print(
            '✏️ Static block updated at $i (${newItem['type']}), updating locally');
        staticChangedIndices.add(i);
        hasStaticChange = true;
      } else {
        print(
            '⚠️ Dynamic block changed at $i (${newItem['type']}), API call needed');
        hasDynamicChange = true;
      }
    }

    _lastSocketSections =
        List.from(newSections.map((e) => json.decode(json.encode(e))));

    if (hasDynamicChange) {
      print('🚀 Dynamic changes detected. Fetching from API...');
      fetchLayout(slug, requestBody: newSections);
    } else if (hasStaticChange) {
      print('✅ Only static changes. Updating UI directly...');
      for (int idx in staticChangedIndices) {
        _initialComponents[idx] = newSections[idx];
      }
      buildLayout(_initialComponents);
    } else {
      print('ℹ️ No changes detected.');
    }
  }

  // ─── Error handling (delegates to BaseController if available) ─
  dynamic _handleApiError(dynamic error, StackTrace stackTrace) {
    print('DynamicLayoutMixin API error: $error');
    print('DynamicLayoutMixin API stackTrace: $stackTrace');
  }
}
